import 'package:intl/intl.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// A full transaction record for the history list + detail, mapped from the
/// API's transaction shape by the transactions provider.
///
/// Reuses [TxCategory] (icon/color/localized label) for the category so the
/// list, detail and Add-Transaction screens all speak the same taxonomy. The
/// merchant [title] and [walletName] are plain strings.
class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.walletName,
    required this.date,
    required this.amountKhr,
    required this.type,
    this.note,
  });

  final String id;
  final String title;
  final TxCategory category;
  final String walletName;
  final DateTime date;
  final int amountKhr;
  final ETransactionType type;
  final String? note;

  bool get isIncome => type == ETransactionType.income;

  /// `+` / `-` prefix for the amount.
  String get sign => isIncome ? '+' : '-';

  String timeLabel(String localeTag) => DateFormat.jm(localeTag).format(date);
}

/// Group header for a record's day: Today / Yesterday / "17 May", relative to
/// [now] (the real clock in production; a fixed instant in tests). [localeTag]
/// comes from `Localizations.localeOf(context)` in the screen.
String transactionGroupLabel(
  AppLocalizations l10n,
  String localeTag,
  DateTime date,
  DateTime now,
) {
  final d = DateTime(date.year, date.month, date.day);
  final base = DateTime(now.year, now.month, now.day);
  final diff = base.difference(d).inDays;
  if (diff <= 0) return l10n.notifToday;
  if (diff == 1) return l10n.notifYesterday;
  return DateFormat.MMMMd(localeTag).format(date);
}
