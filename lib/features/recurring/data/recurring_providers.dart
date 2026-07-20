import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/features/recurring/data/recurring_rule.dart';

/// The list of recurring entries, seeded with the Phase-1 sample.
///
/// In-memory only for now (like wallets and savings goals) — additions live
/// for the session and reset on restart. Swap the seed for a repository read
/// when persistence lands.
class RecurringNotifier extends Notifier<List<RecurringRule>> {
  @override
  List<RecurringRule> build() => sampleRecurringRules();

  void add(RecurringRule rule) => state = [...state, rule];

  /// Replaces the rule with the same id in place.
  void update(RecurringRule rule) =>
      state = [for (final r in state) if (r.id == rule.id) rule else r];

  void remove(String id) =>
      state = state.where((r) => r.id != id).toList();
}

final recurringProvider =
    NotifierProvider<RecurringNotifier, List<RecurringRule>>(
  RecurringNotifier.new,
);

/// Estimated total monthly expense commitment across all recurring expenses.
final recurringMonthlyExpenseProvider = Provider<double>((ref) {
  final rules = ref.watch(recurringProvider);
  return rules
      .where((r) => !r.isIncome)
      .fold<double>(0, (sum, r) => sum + r.monthlyKhr);
});
