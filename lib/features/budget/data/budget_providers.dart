import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/core/providers/offline_status_provider.dart';
import 'package:apsara_wallet_mobile/core/storages/json_cache.dart';
import 'package:apsara_wallet_mobile/core/storages/storage_keys.dart';
import 'package:apsara_wallet_mobile/features/budget/data/budget_api.dart';
import 'package:apsara_wallet_mobile/features/budget/data/budget_mock_data.dart';
import 'package:apsara_wallet_mobile/features/categories/data/category_api.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';

/// The budget month ("YYYY-MM"), derived from the app clock (overridable in
/// tests via [nowProvider]).
final budgetMonthProvider = Provider<String>((ref) {
  final now = ref.watch(nowProvider);
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

/// The user's per-category budgets for the current month, API-backed. Add/edit
/// (upsert) and delete flow through the backend and refresh so the Budget
/// screen and the dashboard bar stay in sync.
class BudgetNotifier extends AsyncNotifier<BudgetData> {
  BudgetApi get _api => ref.read(budgetApiProvider);

  List<ApiBudget> _raw = const [];

  @override
  Future<BudgetData> build() async {
    final month = ref.watch(budgetMonthProvider);
    final index = await ref.watch(categoryIndexProvider.future);

    // Live fetch → cache; on failure serve the last good snapshot (stale) if
    // present, else rethrow so the Budget screen can retry.
    final cache = ref.read(jsonCacheProvider);
    List<dynamic> raw;
    try {
      raw = await _api.fetchRaw(month);
      await cache.writeList(StorageKeys.cachedBudget, raw);
      _markOffline(stale: false);
    } catch (e) {
      final cached = await cache.readList(StorageKeys.cachedBudget);
      if (cached == null) {
        // No snapshot — degrade to an empty budget (dashboard bar falls back
        // to income, as before); nothing stale to flag.
        _markOffline(stale: false);
        raw = const [];
      } else {
        raw = cached;
        _markOffline(stale: true);
      }
    }
    final apiBudgets =
        raw.map((e) => ApiBudget.fromJson(e as Map<String, dynamic>)).toList();
    _raw = apiBudgets;

    final categories = apiBudgets
        .map(
          (b) => CategoryBudget(
            category: categoryById(index.slugForUuid(b.categoryId) ?? ''),
            limitKhr: b.limitKhr,
            spentKhr: b.spentKhr,
          ),
        )
        .toList();

    return BudgetData(
      monthLabel: DateFormat.yMMMM().format(DateTime.parse('$month-01')),
      totalBudgetKhr: categories.fold<int>(0, (s, c) => s + c.limitKhr),
      spentKhr: categories.fold<int>(0, (s, c) => s + c.spentKhr),
      categories: categories,
    );
  }

  // Deferred so we never modify another provider during this one's build.
  void _markOffline({required bool stale}) {
    Future.microtask(() {
      final notifier = ref.read(offlineSourcesProvider.notifier);
      stale ? notifier.markStale('budget') : notifier.markFresh('budget');
    });
  }

  /// Create or update the budget for [category] this month.
  Future<void> setBudget(TxCategory category, int limitKhr) async {
    final index = await ref.read(categoryIndexProvider.future);
    final uuid = index.uuidForSlug(category.id);
    if (uuid == null) throw StateError('category-map-failed');
    final ok = await _api.upsert(
      categoryId: uuid,
      month: ref.read(budgetMonthProvider),
      limitKhr: limitKhr,
    );
    if (!ok) throw StateError('budget-upsert-failed');
    await _reload();
  }

  /// Deletes [category]'s budget for this month (no-op if none set).
  Future<void> removeBudget(TxCategory category) async {
    final index = await ref.read(categoryIndexProvider.future);
    final uuid = index.uuidForSlug(category.id);
    final match = _raw.where((b) => b.categoryId == uuid);
    if (match.isEmpty) return;
    await _api.delete(match.first.id);
    await _reload();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final budgetDataProvider =
    AsyncNotifierProvider<BudgetNotifier, BudgetData>(BudgetNotifier.new);

/// This month's total budget (sum of category limits), for the dashboard bar.
/// 0 when the user hasn't set any budget yet.
final monthlyBudgetTotalProvider = Provider<int>((ref) {
  return ref.watch(budgetDataProvider).valueOrNull?.totalBudgetKhr ?? 0;
});
