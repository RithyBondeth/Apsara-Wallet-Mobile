import 'package:intl/intl.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';

/// English CSV column headers, in output order. Kept English (not localized)
/// because CSV headers are for spreadsheet interchange; the row *values*
/// (category, type) are localized to match the app.
const List<String> kTransactionsCsvHeaders = [
  'Date',
  'Title',
  'Category',
  'Wallet',
  'Type',
  'Amount (KHR)',
  'Note',
];

/// Quotes a CSV field only when it must be (contains a comma, quote, or line
/// break), doubling any embedded quotes — RFC 4180.
String _csvField(String value) {
  if (value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

/// Builds an RFC-4180 CSV (CRLF-separated) of [txns]. Pure — the caller passes
/// the localized category/type resolvers so this stays unit-testable without
/// a BuildContext.
String buildTransactionsCsv({
  required List<TransactionRecord> txns,
  required String Function(TxCategory) categoryLabel,
  required String Function(ETransactionType) typeLabel,
  String localeTag = 'en_US',
}) {
  final df = DateFormat('yyyy-MM-dd HH:mm', localeTag);
  final rows = <String>[kTransactionsCsvHeaders.map(_csvField).join(',')];
  for (final t in txns) {
    rows.add(
      [
        df.format(t.date),
        t.title,
        categoryLabel(t.category),
        t.walletName,
        typeLabel(t.type),
        t.amountKhr.toString(),
        t.note ?? '',
      ].map(_csvField).join(','),
    );
  }
  return rows.join('\r\n');
}
