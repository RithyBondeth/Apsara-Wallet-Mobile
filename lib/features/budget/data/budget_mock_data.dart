import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';

/// UI-only mock data for the Budget screen (Phase 1). Totals mirror the
/// dashboard's Month Overview (KHR 1,265,700 spent of 2,000,000) so the two
/// surfaces tell one story.
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

  static BudgetData sample() => BudgetData(
        monthLabel: 'May 2024',
        totalBudgetKhr: 2000000,
        spentKhr: 1265700,
        categories: [
          CategoryBudget(
            category: expenseCategories[0], // Food & Dining
            limitKhr: 700000,
            spentKhr: 442000,
          ),
          CategoryBudget(
            category: expenseCategories[1], // Transport
            limitKhr: 400000,
            spentKhr: 253000,
          ),
          CategoryBudget(
            category: expenseCategories[2], // Shopping
            limitKhr: 300000,
            spentKhr: 189000,
          ),
          CategoryBudget(
            category: expenseCategories[3], // Bills & Utilities
            limitKhr: 250000,
            spentKhr: 126000,
          ),
          CategoryBudget(
            category: expenseCategories[10], // Others
            limitKhr: 350000,
            spentKhr: 255700,
          ),
        ],
      );
}
