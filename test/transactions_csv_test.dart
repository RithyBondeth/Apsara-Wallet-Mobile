import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transactions_csv.dart';

void main() {
  final cat = expenseCategories.first;

  TransactionRecord tx({
    required String title,
    String? note,
    int amount = 1000,
    ETransactionType type = ETransactionType.expense,
  }) =>
      TransactionRecord(
        id: 't',
        title: title,
        category: cat,
        walletName: 'ABA, Bank', // comma on purpose
        date: DateTime(2026, 7, 28, 9, 5),
        amountKhr: amount,
        type: type,
        note: note,
      );

  test('header row + RFC-4180 escaping of commas and quotes', () {
    final csv = buildTransactionsCsv(
      txns: [
        tx(title: 'Lunch, big', note: 'said "hi"'),
        tx(title: 'Salary', amount: 500000, type: ETransactionType.income),
      ],
      categoryLabel: (_) => 'Food',
      typeLabel: (t) =>
          t == ETransactionType.income ? 'Income' : 'Expense',
    );
    final lines = csv.split('\r\n');

    expect(lines.first, 'Date,Title,Category,Wallet,Type,Amount (KHR),Note');
    expect(lines.length, 3);
    // Fields with commas are quoted; embedded quotes are doubled.
    expect(lines[1], contains('"Lunch, big"'));
    expect(lines[1], contains('"ABA, Bank"'));
    expect(lines[1], contains('"said ""hi"""'));
    expect(lines[1], contains(',1000,'));
    expect(lines[2], contains('Salary'));
    expect(lines[2], contains('Income'));
    expect(lines[2], contains('500000'));
  });

  test('empty list yields just the header row', () {
    final csv = buildTransactionsCsv(
      txns: const [],
      categoryLabel: (_) => 'x',
      typeLabel: (_) => 'x',
    );
    expect(csv, 'Date,Title,Category,Wallet,Type,Amount (KHR),Note');
  });
}
