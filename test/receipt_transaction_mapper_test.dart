import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/scan/data/receipt_transaction_mapper.dart';
import 'package:apsara_wallet_mobile/features/scan/data/scanned_receipt.dart';

/// B3: the scan pipeline now persists — this pins the receipt → transaction
/// mapping (category translation, currency conversion, title fallback).
void main() {
  final date = DateTime(2026, 7, 20, 10);

  test('maps a USD grocery receipt to a converted KHR expense', () {
    final receipt = ScannedReceipt(
      merchant: 'Lucky Supermarket',
      location: 'Phnom Penh',
      dateLabel: '20 Jul 2026',
      categoryLabel: 'Groceries',
      categoryIcon: ScannedReceipt.empty().categoryIcon,
      items: [],
      total: 31.08,
      currency: ECurrencyType.usd,
    );

    final record = ReceiptTransactionMapper.toTransaction(
      receipt,
      id: 'r1',
      walletName: 'Cash Wallet',
      date: date,
    );

    expect(record.type, ETransactionType.expense);
    expect(record.title, 'Lucky Supermarket');
    expect(record.category.id, 'food'); // Groceries → Food & Dining
    expect(record.amountKhr, (31.08 * 4100).round()); // USD → riel
    expect(record.walletName, 'Cash Wallet');
    expect(record.note, 'Phnom Penh');
  });

  test(
    'KHR receipt keeps its amount; unknown category falls back to Others',
    () {
      final receipt = ScannedReceipt(
        merchant: '',
        dateLabel: '',
        categoryLabel: 'Uncategorised',
        categoryIcon: ScannedReceipt.empty().categoryIcon,
        items: [],
        total: 12000,
        currency: ECurrencyType.khr,
      );

      final record = ReceiptTransactionMapper.toTransaction(
        receipt,
        id: 'r2',
        walletName: 'Wing',
        date: date,
      );

      expect(record.amountKhr, 12000);
      expect(record.category.id, 'othersExpense');
      // Empty merchant falls back to the category label.
      expect(record.title, 'Uncategorised');
    },
  );
}
