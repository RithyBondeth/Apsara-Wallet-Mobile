import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/features/wallets/data/wallet_api.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';

/// The user's wallets, loaded from the backend. Adding a wallet POSTs to the
/// API then refreshes so every surface (Wallets screen, dashboard totals)
/// updates at once.
class WalletsNotifier extends AsyncNotifier<List<Wallet>> {
  WalletApi get _api => ref.read(walletApiProvider);

  @override
  Future<List<Wallet>> build() async {
    final apiWallets = await _api.list();
    return apiWallets.map((w) => w.toWallet()).toList();
  }

  Future<void> add(Wallet wallet) async {
    final ok = await _api.create(wallet);
    if (!ok) throw StateError('wallet-create-failed');
    await _reload();
  }

  /// Edits a wallet in place (name/kind/balance/color/primary). Requires the
  /// backend id — [wallet].id must be non-null.
  Future<void> edit(Wallet wallet) async {
    final id = wallet.id;
    if (id == null) throw StateError('wallet-no-id');
    final ok = await _api.update(id, wallet);
    if (!ok) throw StateError('wallet-update-failed');
    await _reload();
  }

  /// Deletes a wallet. Returns the outcome so the caller can explain the
  /// [WalletDeleteOutcome.hasTransactions] case instead of a generic error.
  Future<WalletDeleteOutcome> remove(String id) async {
    final outcome = await _api.delete(id);
    if (outcome == WalletDeleteOutcome.ok) await _reload();
    return outcome;
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final walletsProvider =
    AsyncNotifierProvider<WalletsNotifier, List<Wallet>>(WalletsNotifier.new);

/// Per-wallet balance keyed by name — taken straight from the backend wallet
/// records (the server owns the balance figure; it is not derived from the
/// transaction ledger).
final walletBalancesProvider =
    Provider<Map<String, ({int khr, double usd})>>((ref) {
  final wallets = ref.watch(walletsProvider).valueOrNull ?? const [];
  return {
    for (final w in wallets) w.name: (khr: w.balanceKhr, usd: w.balanceUsd),
  };
});

/// Combined balance across every wallet.
final walletsTotalProvider = Provider<({int khr, double usd})>((ref) {
  final wallets = ref.watch(walletsProvider).valueOrNull ?? const [];
  return (
    khr: wallets.fold<int>(0, (sum, w) => sum + w.balanceKhr),
    usd: wallets.fold<double>(0, (sum, w) => sum + w.balanceUsd),
  );
});
