import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// How often a recurring entry repeats.
enum ERecurrenceFrequency { weekly, monthly }

/// A repeating income/expense the user tracks (salary, rent, subscriptions…).
///
/// Phase-1, UI-only: these describe *intended* repeats and drive the Recurring
/// screen. Nothing auto-posts to the ledger yet — that's left behind the same
/// data seam as the rest of the app.
class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.title,
    required this.category,
    required this.walletName,
    required this.amountKhr,
    required this.type,
    required this.frequency,
    required this.nextDue,
    this.note,
  });

  final String id;
  final String title;
  final TxCategory category;
  final String walletName;
  final int amountKhr;
  final ETransactionType type;
  final ERecurrenceFrequency frequency;
  final DateTime nextDue;
  final String? note;

  bool get isIncome => type == ETransactionType.income;

  /// `+` / `-` prefix for the amount.
  String get sign => isIncome ? '+' : '-';

  /// Amount normalised to a per-month figure (a weekly entry recurs ~52/12
  /// times a month), for the "estimated monthly" summary.
  double get monthlyKhr => frequency == ERecurrenceFrequency.monthly
      ? amountKhr.toDouble()
      : amountKhr * 52 / 12;

  RecurringRule copyWith({
    String? title,
    TxCategory? category,
    String? walletName,
    int? amountKhr,
    ETransactionType? type,
    ERecurrenceFrequency? frequency,
    DateTime? nextDue,
    String? note,
  }) =>
      RecurringRule(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        walletName: walletName ?? this.walletName,
        amountKhr: amountKhr ?? this.amountKhr,
        type: type ?? this.type,
        frequency: frequency ?? this.frequency,
        nextDue: nextDue ?? this.nextDue,
        note: note ?? this.note,
      );
}

/// Localized label for a frequency.
String recurrenceFrequencyLabel(AppLocalizations l10n, ERecurrenceFrequency f) =>
    f == ERecurrenceFrequency.weekly ? l10n.recurringWeekly : l10n.recurringMonthly;

/// Phase-1 sample so the screen opens with content. Dates are fixed (not the
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
