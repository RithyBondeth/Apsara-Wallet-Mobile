import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/utils/currency_converter.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';

/// The session's wallet list, seeded from the Phase-1 sample. UI-only for now
/// (not persisted): adding a wallet appends here so the Wallets screen and
/// Wallet Detail share one source. Identified by list index.
class WalletsNotifier extends Notifier<List<Wallet>> {
  @override
  List<Wallet> build() => [...WalletsData.sample.wallets];

  void add(Wallet wallet) => state = [...state, wallet];
}

final walletsProvider =
    NotifierProvider<WalletsNotifier, List<Wallet>>(WalletsNotifier.new);

/// Net movement (income − expense) in riel for [walletName] across [txs].
int _netKhr(String walletName, List<TransactionRecord> txs) => txs
    .where((t) => t.walletName == walletName)
    .fold<int>(
      0,
      (sum, t) =>
          sum + (t.type == ETransactionType.income ? t.amountKhr : -t.amountKhr),
    );

/// Live, ledger-derived balance for each wallet, keyed by wallet name.
///
/// The ledger is the single source of truth: a wallet's displayed balance
/// moves as transactions against it are added or removed. Each wallet's seed
/// [Wallet.balanceKhr] is treated as its balance at the seed moment, so the
/// baseline is `seed − (movements already in the seeded ledger)`; adding the
/// current ledger's movements back yields today's balance. This means the
/// initial values exactly equal the seed (the seeded ledger and the seed
/// baseline cancel), while later edits are reflected faithfully.
final walletBalancesProvider =
    Provider<Map<String, ({int khr, double usd})>>((ref) {
  final wallets = ref.watch(walletsProvider);
  final live = ref.watch(transactionsProvider).valueOrNull ?? const [];
  final seed = sampleTransactions();

  return {
    for (final w in wallets)
      w.name: () {
        final seedNet = _netKhr(w.name, seed);
        final liveNet = _netKhr(w.name, live);
        final khr = w.balanceKhr - seedNet + liveNet;
        final usd = w.balanceUsd -
            CurrencyConverter.khrToUsd(seedNet) +
            CurrencyConverter.khrToUsd(liveNet);
        return (khr: khr, usd: usd);
      }(),
  };
});

/// Combined ledger-derived balance across every wallet.
final walletsTotalProvider = Provider<({int khr, double usd})>((ref) {
  final balances = ref.watch(walletBalancesProvider).values;
  return (
    khr: balances.fold<int>(0, (sum, b) => sum + b.khr),
    usd: balances.fold<double>(0, (sum, b) => sum + b.usd),
  );
});
