import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';

import 'support/test_database.dart';

/// B5: wallet balances are derived from the ledger (one source of truth). The
/// initial values still equal the seed, and they move when transactions
/// against a wallet are added or removed.
void main() {
  setUp(() async {
    await initTestDatabase();
  });

  Future<ProviderContainer> booted() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(transactionsProvider.future); // load seeded ledger
    return container;
  }

  test('initial derived balances equal the seed', () async {
    final container = await booted();
    final balances = container.read(walletBalancesProvider);
    expect(balances['Cash Wallet']!.khr, 320000);
    expect(balances['ABA Bank']!.khr, 1250000);
    expect(balances['ACLEDA Bank']!.khr, 850000);
  });

  test('adding an expense lowers only that wallet', () async {
    final container = await booted();
    await container.read(transactionsProvider.notifier).add(
          TransactionRecord(
            id: 'new-cash-expense',
            title: 'Snacks',
            category: categoryById('food'),
            walletName: 'Cash Wallet',
            date: DateTime(2024, 5, 20),
            amountKhr: 10000,
            type: ETransactionType.expense,
          ),
        );

    final balances = container.read(walletBalancesProvider);
    expect(balances['Cash Wallet']!.khr, 310000); // 320,000 − 10,000
    expect(balances['ABA Bank']!.khr, 1250000); // untouched
  });

  test('deleting a seeded income drops that wallet', () async {
    final container = await booted();
    // Remove the ABA "freelance" income of 600,000.
    await container.read(transactionsProvider.notifier).remove('freelance');

    final balances = container.read(walletBalancesProvider);
    expect(balances['ABA Bank']!.khr, 650000); // 1,250,000 − 600,000
  });
}
