import 'package:intl/intl.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// A full transaction record for the history list + detail (Phase 1, UI-only).
///
/// Reuses [TxCategory] (icon/color/localized label) for the category so the
/// list, detail and Add-Transaction screens all speak the same taxonomy. The
/// merchant [title] and [walletName] are plain strings. [date] is anchored to
/// a FIXED base (not the real clock) so day-grouping and goldens stay stable.
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

  /// Serializes to a `transactions` table row.
  Map<String, Object?> toDbMap() => {
        'id': id,
        'title': title,
        'categoryId': category.id,
        'walletName': walletName,
        'dateMillis': date.millisecondsSinceEpoch,
        'amountKhr': amountKhr,
        'type': type.name,
        'note': note,
      };

  /// Rebuilds a record from a stored row (category resolved from the catalog).
  factory TransactionRecord.fromDbMap(Map<String, Object?> m) =>
      TransactionRecord(
        id: m['id'] as String,
        title: m['title'] as String,
        category: categoryById(m['categoryId'] as String),
        walletName: m['walletName'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(m['dateMillis'] as int),
        amountKhr: m['amountKhr'] as int,
        type: ETransactionType.values.byName(m['type'] as String),
        note: m['note'] as String?,
      );
}

/// The base "now" the sample is relative to (matches the mock "May 2024").
final DateTime _baseDate = DateTime(2024, 5, 20);

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

DateTime _at(int daysAgo, int hour, int minute) =>
    DateTime(_baseDate.year, _baseDate.month, _baseDate.day - daysAgo, hour,
        minute);

/// The Phase-1 sample history — spread across several days and types. The
/// first four ids mirror the dashboard's recent list so a tap there opens the
/// matching detail.
List<TransactionRecord> sampleTransactions() => [
      TransactionRecord(
        id: 'grab-food',
        title: 'Grab Food',
        category: expenseCategories[0],
        walletName: 'Cash Wallet',
        date: _at(0, 8, 30),
        amountKhr: 18000,
        type: ETransactionType.expense,
        note: 'Lunch delivery',
      ),
      TransactionRecord(
        id: 'aba-salary',
        title: 'ABA Salary',
        category: incomeCategories[0],
        walletName: 'ABA Bank',
        date: _at(0, 8, 0),
        amountKhr: 3500000,
        type: ETransactionType.income,
        note: 'Monthly salary',
      ),
      TransactionRecord(
        id: 'aeon-mall',
        title: 'AEON Mall',
        category: expenseCategories[2],
        walletName: 'ABA Bank',
        date: _at(1, 18, 20),
        amountKhr: 45000,
        type: ETransactionType.expense,
      ),
      TransactionRecord(
        id: 'coffee-shop',
        title: 'Coffee Shop',
        category: expenseCategories[0],
        walletName: 'Cash Wallet',
        date: _at(1, 9, 15),
        amountKhr: 12000,
        type: ETransactionType.expense,
        note: 'Morning coffee',
      ),
      TransactionRecord(
        id: 'phone-topup',
        title: 'Phone Top-up',
        category: expenseCategories[3], // Bills & Utilities
        walletName: 'Wing',
        date: _at(1, 14, 0),
        amountKhr: 20000,
        type: ETransactionType.expense,
        note: 'Cellcard mobile credit',
      ),
      TransactionRecord(
        id: 'electricity',
        title: 'Electricity Bill',
        category: expenseCategories[3],
        walletName: 'ABA Bank',
        date: _at(2, 11, 0),
        amountKhr: 85000,
        type: ETransactionType.expense,
      ),
      TransactionRecord(
        id: 'freelance',
        title: 'Freelance Project',
        category: incomeCategories[1],
        walletName: 'ABA Bank',
        date: _at(2, 16, 30),
        amountKhr: 600000,
        type: ETransactionType.income,
        note: 'Logo design payment',
      ),
      TransactionRecord(
        id: 'super-market',
        title: 'Phnom Penh Super',
        category: expenseCategories[2],
        walletName: 'Cash Wallet',
        date: _at(3, 19, 45),
        amountKhr: 62000,
        type: ETransactionType.expense,
      ),
      TransactionRecord(
        id: 'gym',
        title: 'Gym Membership',
        category: expenseCategories[4],
        walletName: 'ABA Bank',
        date: _at(3, 6, 0),
        amountKhr: 40000,
        type: ETransactionType.expense,
      ),
      TransactionRecord(
        id: 'book-store',
        title: 'Book Store',
        category: expenseCategories[5],
        walletName: 'Cash Wallet',
        date: _at(3, 15, 10),
        amountKhr: 28000,
        type: ETransactionType.expense,
      ),
    ];

/// Looks up a record by id, falling back to the first (keeps the detail screen
/// robust if an unknown id is routed).
TransactionRecord findTransaction(String id) {
  final all = sampleTransactions();
  return all.firstWhere((t) => t.id == id, orElse: () => all.first);
}
