import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';

/// UI-only mock data for the dashboard. No backend — Phase 1 is presentation
/// only, so these fixtures drive every widget on the screen.

final NumberFormat _khrFormat = NumberFormat.decimalPattern('en_US');
final NumberFormat _usdFormat = NumberFormat('#,##0.00', 'en_US');

/// `2584300` -> `"2,584,300"`.
String formatKhr(num value) => _khrFormat.format(value);

/// `645.2` -> `"645.20"`.
String formatUsd(num value) => _usdFormat.format(value);

/// A single row in the recent-transactions list.
class DashboardTransaction {
  const DashboardTransaction({
    required this.title,
    required this.time,
    required this.amountKhr,
    required this.type,
    required this.icon,
    required this.tint,
    this.id,
  });

  /// Matches a [TransactionRecord.id] in the history sample so a tap on the
  /// dashboard opens the same detail; null rows are non-navigable.
  final String? id;

  final String title;
  final String time;
  final int amountKhr;
  final ETransactionType type;
  final IconData icon;

  /// Brand-ish accent used for the leading icon tile.
  final Color tint;

  bool get isIncome => type == ETransactionType.income;
}

/// Everything the dashboard renders, gathered in one place.
class DashboardData {
  const DashboardData({
    required this.userName,
    required this.balanceKhr,
    required this.balanceUsd,
    required this.monthLabel,
    required this.monthIncomeKhr,
    required this.monthExpenseKhr,
    required this.budgetKhr,
    required this.budgetUsedFraction,
    required this.transactions,
  });

  final String userName;
  final int balanceKhr;
  final double balanceUsd;

  final String monthLabel;
  final int monthIncomeKhr;
  final int monthExpenseKhr;
  final int budgetKhr;

  /// 0..1 share of the budget spent (drives the progress bar).
  final double budgetUsedFraction;

  final List<DashboardTransaction> transactions;

  static const DashboardData sample = DashboardData(
    userName: 'Sokunthea',
    balanceKhr: 2584300,
    balanceUsd: 645.20,
    monthLabel: 'May 2024',
    monthIncomeKhr: 3850000,
    monthExpenseKhr: 1265700,
    budgetKhr: 2000000,
    budgetUsedFraction: 0.63,
    transactions: [
      DashboardTransaction(
        id: 'grab-food',
        title: 'Grab Food',
        time: 'Today, 8:30 AM',
        amountKhr: 18000,
        type: ETransactionType.expense,
        icon: LucideIcons.utensils,
        tint: Color(0xFF00B14F),
      ),
      DashboardTransaction(
        id: 'aba-salary',
        title: 'ABA Salary',
        time: 'Today, 8:00 AM',
        amountKhr: 3500000,
        type: ETransactionType.income,
        icon: LucideIcons.banknote,
        tint: Color(0xFF1E4FA3),
      ),
      DashboardTransaction(
        id: 'aeon-mall',
        title: 'AEON Mall',
        time: 'Yesterday, 6:20 PM',
        amountKhr: 45000,
        type: ETransactionType.expense,
        icon: LucideIcons.shoppingBag,
        tint: Color(0xFF7C3AED),
      ),
      DashboardTransaction(
        id: 'coffee-shop',
        title: 'Coffee Shop',
        time: 'Yesterday, 9:15 AM',
        amountKhr: 12000,
        type: ETransactionType.expense,
        icon: LucideIcons.coffee,
        tint: Color(0xFF9A6B4F),
      ),
    ],
  );
}
