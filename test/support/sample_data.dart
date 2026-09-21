import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/features/budget/data/budget_data.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_models.dart';
import 'package:apsara_wallet_mobile/features/profile/data/savings_goal.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_rule.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_record.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_models.dart';

/// Deterministic sample fixtures for widget, golden and unit tests.
///
/// These used to live beside the production models (and were seeded into a
/// local SQLite store on first launch). The app now renders only what the API
/// returns, so the fixtures belong to the test tree. Dates are anchored to a
/// fixed May 2024 instead of the real clock so grouping and goldens stay stable.

/// The base "now" the sample is relative to (May 2024).
final DateTime _txBaseDate = DateTime(2024, 5, 20);

DateTime _txAt(int daysAgo, int hour, int minute) => DateTime(
  _txBaseDate.year,
  _txBaseDate.month,
  _txBaseDate.day - daysAgo,
  hour,
  minute,
);

/// Sample history — spread across several days and types. The
/// first four ids mirror the dashboard's recent list so a tap there opens the
/// matching detail.
List<TransactionRecord> sampleTransactions() => [
  TransactionRecord(
    id: 'grab-food',
    title: 'Grab Food',
    category: expenseCategories[0],
    walletName: 'Cash Wallet',
    date: _txAt(0, 8, 30),
    amountKhr: 18000,
    type: ETransactionType.expense,
    note: 'Lunch delivery',
  ),
  TransactionRecord(
    id: 'aba-salary',
    title: 'ABA Salary',
    category: incomeCategories[0],
    walletName: 'ABA Bank',
    date: _txAt(0, 8, 0),
    amountKhr: 3500000,
    type: ETransactionType.income,
    note: 'Monthly salary',
  ),
  TransactionRecord(
    id: 'aeon-mall',
    title: 'AEON Mall',
    category: expenseCategories[2],
    walletName: 'ABA Bank',
    date: _txAt(1, 18, 20),
    amountKhr: 45000,
    type: ETransactionType.expense,
  ),
  TransactionRecord(
    id: 'coffee-shop',
    title: 'Coffee Shop',
    category: expenseCategories[0],
    walletName: 'Cash Wallet',
    date: _txAt(1, 9, 15),
    amountKhr: 12000,
    type: ETransactionType.expense,
    note: 'Morning coffee',
  ),
  TransactionRecord(
    id: 'phone-topup',
    title: 'Phone Top-up',
    category: expenseCategories[3], // Bills & Utilities
    walletName: 'Wing',
    date: _txAt(1, 14, 0),
    amountKhr: 20000,
    type: ETransactionType.expense,
    note: 'Cellcard mobile credit',
  ),
  TransactionRecord(
    id: 'electricity',
    title: 'Electricity Bill',
    category: expenseCategories[3],
    walletName: 'ABA Bank',
    date: _txAt(2, 11, 0),
    amountKhr: 85000,
    type: ETransactionType.expense,
  ),
  TransactionRecord(
    id: 'freelance',
    title: 'Freelance Project',
    category: incomeCategories[1],
    walletName: 'ABA Bank',
    date: _txAt(2, 16, 30),
    amountKhr: 600000,
    type: ETransactionType.income,
    note: 'Logo design payment',
  ),
  TransactionRecord(
    id: 'super-market',
    title: 'Phnom Penh Super',
    category: expenseCategories[2],
    walletName: 'Cash Wallet',
    date: _txAt(3, 19, 45),
    amountKhr: 62000,
    type: ETransactionType.expense,
  ),
  TransactionRecord(
    id: 'gym',
    title: 'Gym Membership',
    category: expenseCategories[4],
    walletName: 'ABA Bank',
    date: _txAt(3, 6, 0),
    amountKhr: 40000,
    type: ETransactionType.expense,
  ),
  TransactionRecord(
    id: 'book-store',
    title: 'Book Store',
    category: expenseCategories[5],
    walletName: 'Cash Wallet',
    date: _txAt(3, 15, 10),
    amountKhr: 28000,
    type: ETransactionType.expense,
  ),
];

const WalletsData sampleWalletsData = WalletsData(
  totalBalanceKhr: 2584300,
  totalBalanceUsd: 645.20,
  wallets: [
    Wallet(
      name: 'ABA Bank',
      kind: WalletKind.bank,
      balanceKhr: 1250000,
      balanceUsd: 312.08,
      brandColor: Color(0xFF1E4FA3),
      accountLast4: '1234',
      shortCode: 'ABA',
      isPrimary: true,
    ),
    Wallet(
      name: 'ACLEDA Bank',
      kind: WalletKind.bank,
      balanceKhr: 850000,
      balanceUsd: 212.22,
      brandColor: Color(0xFFC79A2E),
      accountLast4: '5678',
      shortCode: 'ACL',
    ),
    Wallet(
      name: 'Cash Wallet',
      kind: WalletKind.cash,
      balanceKhr: 320000,
      balanceUsd: 79.89,
      brandColor: AppColors.income,
      icon: LucideIcons.banknote,
    ),
    Wallet(
      name: 'Wing',
      kind: WalletKind.ewallet,
      balanceKhr: 164300,
      balanceUsd: 41.01,
      brandColor: Color(0xFF00A9E0),
      accountLast4: '9012',
      shortCode: 'Wing',
    ),
  ],
);

BudgetData sampleBudgetData() => BudgetData(
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

/// Sample inbox — a mix of read/unread, today/earlier.
List<AppNotification> sampleNotifications() => [
  AppNotification(
    id: 'tx',
    icon: LucideIcons.arrowDownLeft,
    color: AppColors.income,
    minutesAgo: 25,
    titleOf: (l) => l.notifTxTitle,
    bodyOf: (l) => l.notifTxBody,
  ),
  AppNotification(
    id: 'budget',
    icon: LucideIcons.chartPie,
    color: AppColors.warning,
    minutesAgo: 180,
    titleOf: (l) => l.notifBudgetTitle,
    bodyOf: (l) => l.notifBudgetBody,
    category: ENotifCategory.budget,
  ),
  AppNotification(
    id: 'security',
    icon: LucideIcons.shieldCheck,
    color: AppColors.info,
    minutesAgo: 480,
    titleOf: (l) => l.notifSecurityTitle,
    bodyOf: (l) => l.notifSecurityBody,
    category: ENotifCategory.security,
  ),
  AppNotification(
    id: 'reward',
    icon: LucideIcons.piggyBank,
    color: AppColors.income,
    minutesAgo: 1560, // yesterday
    titleOf: (l) => l.notifRewardTitle,
    bodyOf: (l) => l.notifRewardBody,
    read: true,
  ),
  AppNotification(
    id: 'insight',
    icon: LucideIcons.sparkles,
    color: const Color(0xFF6C63D2),
    minutesAgo: 2880, // 2 days
    titleOf: (l) => l.notifInsightTitle,
    bodyOf: (l) => l.notifInsightBody,
    read: true,
  ),
  AppNotification(
    id: 'bill',
    icon: LucideIcons.receipt,
    color: AppColors.expense,
    minutesAgo: 4320, // 3 days
    titleOf: (l) => l.notifBillTitle,
    bodyOf: (l) => l.notifBillBody,
    read: true,
  ),
];

/// Sample goals.
List<SavingsGoal> sampleSavingsGoals() => [
  SavingsGoal(
    id: 'motorbike',
    icon: LucideIcons.bike,
    color: AppColors.primary,
    savedKhr: 4500000,
    targetKhr: 6000000,
    nameKey: (l) => l.savingsGoalMotorbike,
  ),
  SavingsGoal(
    id: 'emergency',
    icon: LucideIcons.shieldCheck,
    color: AppColors.info,
    savedKhr: 2500000,
    targetKhr: 5000000,
    nameKey: (l) => l.savingsGoalEmergency,
  ),
  SavingsGoal(
    id: 'vacation',
    icon: LucideIcons.palmtree,
    color: AppGradients.goldCore,
    savedKhr: 1200000,
    targetKhr: 3000000,
    nameKey: (l) => l.savingsGoalVacation,
  ),
  SavingsGoal(
    id: 'laptop',
    icon: LucideIcons.laptop,
    color: Color(0xFF7C5CD6),
    savedKhr: 800000,
    targetKhr: 2000000,
    nameKey: (l) => l.savingsGoalLaptop,
  ),
];

/// Sample rules. Dates are fixed (not the
/// real clock) so the UI is deterministic under test.
List<RecurringRule> sampleRecurringRules() => [
  RecurringRule(
    id: 'rec-salary',
    title: 'Monthly Salary',
    category: categoryById('salary'),
    walletName: 'ABA Bank',
    amountKhr: 3500000,
    type: ETransactionType.income,
    frequency: ERecurrenceFrequency.monthly,
    nextDue: DateTime(2024, 6, 1),
  ),
  RecurringRule(
    id: 'rec-rent',
    title: 'House Rent',
    category: categoryById('bills'),
    walletName: 'ABA Bank',
    amountKhr: 400000,
    type: ETransactionType.expense,
    frequency: ERecurrenceFrequency.monthly,
    nextDue: DateTime(2024, 6, 5),
  ),
  RecurringRule(
    id: 'rec-phone',
    title: 'Phone Top-up',
    category: categoryById('bills'),
    walletName: 'Wing',
    amountKhr: 20000,
    type: ETransactionType.expense,
    frequency: ERecurrenceFrequency.weekly,
    nextDue: DateTime(2024, 6, 2),
  ),
  RecurringRule(
    id: 'rec-streaming',
    title: 'Streaming Plan',
    category: categoryById('entertainment'),
    walletName: 'ABA Bank',
    amountKhr: 40000,
    type: ETransactionType.expense,
    frequency: ERecurrenceFrequency.monthly,
    nextDue: DateTime(2024, 6, 10),
  ),
  RecurringRule(
    id: 'rec-gym',
    title: 'Gym Membership',
    category: categoryById('health'),
    walletName: 'Cash Wallet',
    amountKhr: 40000,
    type: ETransactionType.expense,
    frequency: ERecurrenceFrequency.monthly,
    nextDue: DateTime(2024, 6, 3),
  ),
];
