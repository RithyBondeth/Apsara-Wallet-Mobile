import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// How often a recurring entry repeats.
enum ERecurrenceFrequency { weekly, monthly }

/// A repeating income/expense the user tracks (salary, rent, subscriptions…).
///
/// Rules come from the API and drive the Recurring screen; due ones are
/// materialised into the ledger by the recurring auto-post provider (and the
/// API's own hourly scheduler).
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
  }) => RecurringRule(
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
String recurrenceFrequencyLabel(
  AppLocalizations l10n,
  ERecurrenceFrequency f,
) => f == ERecurrenceFrequency.weekly
    ? l10n.recurringWeekly
    : l10n.recurringMonthly;
