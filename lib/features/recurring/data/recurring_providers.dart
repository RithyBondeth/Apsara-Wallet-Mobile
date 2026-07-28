import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/categories/data/category_api.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_api.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_rule.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';

/// The user's recurring rules, backed by the API. Add/update/remove flow
/// through the backend and refresh; [runDue] posts every due occurrence into
/// the ledger (server-side) then refreshes transactions and wallets so every
/// surface reflects the new entries.
///
/// Mapping backend UUIDs → app models needs the wallet list and the category
/// index, which are awaited first (same seam as [TransactionsNotifier]).
class RecurringNotifier extends AsyncNotifier<List<RecurringRule>> {
  RecurringApi get _api => ref.read(recurringApiProvider);

  @override
  Future<List<RecurringRule>> build() async {
    final index = await ref.watch(categoryIndexProvider.future);
    final userCats = await ref.watch(userCategoriesProvider.future);
    final wallets = await ref.watch(walletsProvider.future);
    final nameById = {
      for (final w in wallets)
        if (w.id != null) w.id!: w.name,
    };

    final bySlug = <String, TxCategory>{
      for (final c in [...expenseCategories, ...incomeCategories]) c.id: c,
      for (final c in [...userCats.expense, ...userCats.income]) c.id: c,
    };

    final apiRules = await _api.list();
    return apiRules.map((r) {
      final slug = index.slugForUuid(r.categoryId);
      final category =
          (slug != null ? bySlug[slug] : null) ?? categoryById(slug ?? '');
      return r.toRule(
        walletName: nameById[r.walletId] ?? '',
        category: category,
      );
    }).toList();
  }

  Future<void> add(RecurringRule rule) async {
    final (walletId, categoryId) = await _resolveIds(rule);
    final ok = await _api.create(
      title: rule.title,
      walletId: walletId,
      categoryId: categoryId,
      amountKhr: rule.amountKhr,
      type: rule.type,
      frequency: rule.frequency,
      nextDue: rule.nextDue,
      note: rule.note,
    );
    if (!ok) throw StateError('recurring-create-failed');
    await _reload();
  }

  Future<void> edit(RecurringRule rule) async {
    final (walletId, categoryId) = await _resolveIds(rule);
    final ok = await _api.update(
      id: rule.id,
      title: rule.title,
      walletId: walletId,
      categoryId: categoryId,
      amountKhr: rule.amountKhr,
      type: rule.type,
      frequency: rule.frequency,
      nextDue: rule.nextDue,
      note: rule.note,
    );
    if (!ok) throw StateError('recurring-update-failed');
    await _reload();
  }

  Future<void> remove(String id) async {
    await _api.delete(id);
    await _reload();
  }

  /// Posts due occurrences to the ledger. When anything posted, refreshes the
  /// ledger + wallets so the dashboard, history and balances pick it up.
  Future<RunDueResult> runDue() async {
    final result = await _api.run();
    if (result.postedAny) {
      ref.invalidate(transactionsProvider);
      ref.invalidate(walletsProvider);
    }
    await _reload();
    return result;
  }

  /// Resolves the app-model rule's wallet name → wallet UUID and category slug
  /// → category UUID. Falls back to the first wallet / an "Others" category so
  /// a stray name/slug never blocks the save (mirrors [TransactionsNotifier]).
  Future<(String, String)> _resolveIds(RecurringRule rule) async {
    final index = await ref.read(categoryIndexProvider.future);
    final wallets = await ref.read(walletsProvider.future);
    if (wallets.isEmpty) throw StateError('no-wallet');

    final wallet = wallets.firstWhere(
      (w) => w.name == rule.walletName,
      orElse: () => wallets.first,
    );
    final categoryId = index.uuidForSlug(rule.category.id) ??
        index.uuidForSlug(
          rule.type == ETransactionType.income
              ? 'othersIncome'
              : 'othersExpense',
        );
    if (wallet.id == null || categoryId == null) {
      throw StateError('map-failed');
    }
    return (wallet.id!, categoryId);
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final recurringProvider =
    AsyncNotifierProvider<RecurringNotifier, List<RecurringRule>>(
  RecurringNotifier.new,
);

/// Estimated total monthly expense commitment across all recurring expenses.
/// 0 while the list is loading or empty.
final recurringMonthlyExpenseProvider = Provider<double>((ref) {
  final rules = ref.watch(recurringProvider).valueOrNull ?? const [];
  return rules
      .where((r) => !r.isIncome)
      .fold<double>(0, (sum, r) => sum + r.monthlyKhr);
});

/// One-shot trigger that posts any due recurring occurrences on app start.
/// FutureProvider caches for the session, so it runs once; the dashboard
/// watches it silently (its value isn't rendered).
final recurringAutoPostProvider = FutureProvider<RunDueResult>((ref) async {
  return ref.read(recurringProvider.notifier).runDue();
});
