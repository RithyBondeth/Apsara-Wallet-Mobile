import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';

/// Budget models for the Budget screen and the dashboard's Month Overview,
/// assembled by the budget providers from the API budgets and the ledger.
class CategoryBudget {
  const CategoryBudget({
    required this.category,
    required this.limitKhr,
    required this.spentKhr,
  });

  final TxCategory category;
  final int limitKhr;
  final int spentKhr;

  double get fraction =>
      limitKhr == 0 ? 0 : (spentKhr / limitKhr).clamp(0.0, 1.0);
}

class BudgetData {
  BudgetData({
    required this.monthLabel,
    required this.totalBudgetKhr,
    required this.spentKhr,
    required this.categories,
  });

  final String monthLabel;
  final int totalBudgetKhr;
  final int spentKhr;
  final List<CategoryBudget> categories;

  double get fraction =>
      totalBudgetKhr == 0 ? 0 : (spentKhr / totalBudgetKhr).clamp(0.0, 1.0);
}
