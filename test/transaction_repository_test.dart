import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/database/app_database.dart';
import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_repository.dart';

import 'support/test_database.dart';

/// Proves the persistence foundation: real inserts/queries/deletes against a
/// SQLite database (in-memory ffi), independent of any UI.
void main() {
  late TransactionRepository repo;

  setUp(() async {
    await initTestDatabase();
    repo = TransactionRepository(AppDatabase.instance);
  });

  test('opens seeded with the sample transactions, newest first', () async {
    final all = await repo.getAll();
    expect(all, isNotEmpty);
    expect(all.length, sampleTransactions().length);
    // Ordered by date descending.
    for (var i = 1; i < all.length; i++) {
      expect(
        all[i - 1].date.isAfter(all[i].date) ||
            all[i - 1].date.isAtSameMomentAs(all[i].date),
        isTrue,
      );
    }
  });

  test('insert adds a row that getAll and getById return', () async {
    final before = (await repo.getAll()).length;
    final record = TransactionRecord(
      id: 'unit-test-tx',
      title: 'Test Coffee',
      category: categoryById('food'),
      walletName: 'Cash Wallet',
      date: DateTime(2024, 5, 20, 10, 0),
      amountKhr: 9000,
      type: ETransactionType.expense,
      note: 'unit test',
    );

    await repo.insert(record);

    expect((await repo.getAll()).length, before + 1);
    final fetched = await repo.getById('unit-test-tx');
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Test Coffee');
    expect(fetched.amountKhr, 9000);
    expect(fetched.category.id, 'food');
    expect(fetched.type, ETransactionType.expense);
    expect(fetched.note, 'unit test');
  });

  test('delete removes the row', () async {
    await repo.delete('grab-food');
    expect(await repo.getById('grab-food'), isNull);
  });

  test('reset re-seeds a fresh database', () async {
    await repo.delete('grab-food');
    expect(await repo.getById('grab-food'), isNull);

    await initTestDatabase(); // fresh in-memory db
    final fresh = TransactionRepository(AppDatabase.instance);
    expect(await fresh.getById('grab-food'), isNotNull);
  });
}
