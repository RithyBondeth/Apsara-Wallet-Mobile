import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/providers/offline_status_provider.dart';
import 'package:apsara_wallet_mobile/core/storages/json_cache.dart';
import 'package:apsara_wallet_mobile/core/storages/storage_keys.dart';
import 'package:apsara_wallet_mobile/features/categories/data/category_api.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_api.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';

/// The live list of transactions, newest first, backed by the API.
///
/// Every surface (dashboard, history, detail, wallet detail) watches this;
/// [add]/[remove] POST/DELETE to the backend and refresh so all update at
/// once. Mapping backend UUIDs → app models needs the wallet list and the
/// category index, which are awaited first.
class TransactionsNotifier extends AsyncNotifier<List<TransactionRecord>> {
  TransactionApi get _api => ref.read(transactionApiProvider);

  @override
  Future<List<TransactionRecord>> build() async {
    final index = await ref.watch(categoryIndexProvider.future);
    final userCats = await ref.watch(userCategoriesProvider.future);
    final wallets = await ref.watch(walletsProvider.future);
    final nameById = {
      for (final w in wallets)
        if (w.id != null) w.id!: w.name,
    };

    // Resolve a category slug → TxCategory: static system catalog + the user's
    // own categories. Falls back to the static resolver for anything unknown.
    final bySlug = <String, TxCategory>{
      for (final c in [...expenseCategories, ...incomeCategories]) c.id: c,
      for (final c in [...userCats.expense, ...userCats.income]) c.id: c,
    };

    // Live fetch → cache the raw snapshot; on network failure fall back to the
    // last good snapshot (stale) so the ledger stays readable offline. No
    // snapshot → rethrow so the screen can offer a retry.
    final cache = ref.read(jsonCacheProvider);
    List<dynamic> raw;
    try {
      raw = await _api.fetchRaw();
      await cache.writeList(StorageKeys.cachedTransactions, raw);
      _markOffline(stale: false);
    } catch (e) {
      final cached = await cache.readList(StorageKeys.cachedTransactions);
      if (cached == null) rethrow;
      raw = cached;
      _markOffline(stale: true);
    }
    final apiTxns = raw
        .map((e) => ApiTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
    final records = apiTxns
        .map((t) {
          final slug = index.slugForUuid(t.categoryId);
          final category = (slug != null ? bySlug[slug] : null) ??
              categoryById(slug ?? '');
          return t.toRecord(
            walletName: nameById[t.walletId] ?? '',
            category: category,
          );
        })
        .toList()
      // Newest first — every surface (dashboard, history, wallet detail)
      // expects this ordering.
      ..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  // Deferred so we never modify another provider during this one's build.
  void _markOffline({required bool stale}) {
    Future.microtask(() {
      final notifier = ref.read(offlineSourcesProvider.notifier);
      stale
          ? notifier.markStale('transactions')
          : notifier.markFresh('transactions');
    });
  }

  Future<void> add(TransactionRecord record) async {
    final index = await ref.read(categoryIndexProvider.future);
    final wallets = await ref.read(walletsProvider.future);
    if (wallets.isEmpty) {
      throw StateError('no-wallet');
    }

    // Resolve the backend ids. Fall back to the first wallet / an "Others"
    // category so a stray name/slug never blocks the save.
    final wallet = wallets.firstWhere(
      (w) => w.name == record.walletName,
      orElse: () => wallets.first,
    );
    final categoryId = index.uuidForSlug(record.category.id) ??
        index.uuidForSlug(
          record.type == ETransactionType.income
              ? 'othersIncome'
              : 'othersExpense',
        );
    if (wallet.id == null || categoryId == null) {
      throw StateError('map-failed');
    }

    final ok = await _api.create(
      title: record.title,
      walletId: wallet.id!,
      categoryId: categoryId,
      amountKhr: record.amountKhr,
      type: record.type,
      date: record.date,
      note: record.note,
    );
    if (!ok) throw StateError('create-failed');
    // The backend moved the wallet balance too — refresh wallets so the
    // dashboard total and wallet balances reflect it.
    ref.invalidate(walletsProvider);
    await _reload();
  }

  /// Edits an existing transaction in place (PATCH), preserving its id and
  /// created-at. The backend rebalances wallets (reverses the old effect,
  /// applies the new), so we invalidate wallets to reflect the change.
  Future<void> edit(TransactionRecord record) async {
    final index = await ref.read(categoryIndexProvider.future);
    final wallets = await ref.read(walletsProvider.future);
    if (wallets.isEmpty) throw StateError('no-wallet');

    final wallet = wallets.firstWhere(
      (w) => w.name == record.walletName,
      orElse: () => wallets.first,
    );
    final categoryId = index.uuidForSlug(record.category.id) ??
        index.uuidForSlug(
          record.type == ETransactionType.income
              ? 'othersIncome'
              : 'othersExpense',
        );
    if (wallet.id == null || categoryId == null) {
      throw StateError('map-failed');
    }

    final ok = await _api.update(
      id: record.id,
      title: record.title,
      walletId: wallet.id!,
      categoryId: categoryId,
      amountKhr: record.amountKhr,
      type: record.type,
      date: record.date,
      note: record.note,
    );
    if (!ok) throw StateError('update-failed');
    ref.invalidate(walletsProvider);
    await _reload();
  }

  Future<void> remove(String id) async {
    await _api.delete(id);
    ref.invalidate(walletsProvider);
    await _reload();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionRecord>>(
  TransactionsNotifier.new,
);
