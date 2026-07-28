import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';

/// UI-only mock data for the Analytics screen (Phase 1). Latin-grouped KHR
/// formatting to match the design ("KHR 1,265,700"), not the ៛ symbol.

final NumberFormat _khr = NumberFormat.decimalPattern('en_US');

/// `442000` -> `"442,000"`.
String formatKhr(num value) => _khr.format(value);

/// One slice of the expense breakdown donut / category list.
class ExpenseCategory {
  const ExpenseCategory({
    required this.name,
    required this.amountKhr,
    required this.fraction,
    required this.color,
    required this.icon,
  });

  final String name;
  final int amountKhr;

  /// Share of total expense, 0..1.
  final double fraction;
  final Color color;
  final IconData icon;

  int get percent => (fraction * 100).round();
}

/// Everything the Analytics tabs render.
class AnalyticsData {
  const AnalyticsData({
    required this.totalExpenseKhr,
    required this.categories,
    required this.dailyTrend,
    required this.trendMax,
    required this.trendAxisLabels,
  });

  final int totalExpenseKhr;
  final List<ExpenseCategory> categories;

  /// Per-day expense values (KHR) driving the trend line.
  final List<double> dailyTrend;

  /// Upper bound for the trend Y axis (KHR).
  final double trendMax;

  /// Sparse X labels, evenly distributed across [dailyTrend].
  final List<String> trendAxisLabels;

  static const AnalyticsData sample = AnalyticsData(
    totalExpenseKhr: 1265700,
    categories: [
      ExpenseCategory(
        name: 'Food & Dining',
        amountKhr: 442000,
        fraction: 0.35,
        color: AppColors.info,
        icon: LucideIcons.utensils,
      ),
      ExpenseCategory(
        name: 'Transport',
        amountKhr: 253000,
        fraction: 0.20,
        color: AppColors.expense,
        icon: LucideIcons.car,
      ),
      ExpenseCategory(
        name: 'Shopping',
        amountKhr: 189000,
        fraction: 0.15,
        color: AppGradients.goldCore,
        icon: LucideIcons.shoppingBag,
      ),
      ExpenseCategory(
        name: 'Bills & Utilities',
        amountKhr: 126000,
        fraction: 0.10,
        color: AppColors.warning,
        icon: LucideIcons.receipt,
      ),
      ExpenseCategory(
        name: 'Others',
        amountKhr: 255700,
        fraction: 0.20,
        color: AppColors.textMuted,
        icon: LucideIcons.ellipsis,
      ),
    ],
    dailyTrend: [
      30000, 34000, 45000, 62000, 80000, 66000, 58000, 72000,
      122000, 104000, 92000, 100000, 118000, 96000, 120000, 108000,
      95000,
    ],
    trendMax: 150000,
    trendAxisLabels: ['1 May', '8 May', '15 May', '22 May', '31 May'],
  );
}
