import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/providers/offline_status_provider.dart';
import 'package:apsara_wallet_mobile/core/storages/json_cache.dart';
import 'package:apsara_wallet_mobile/core/storages/storage_keys.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_api.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';

/// The user's wallets, loaded from the backend. Adding a wallet POSTs to the
/// API then refreshes so every surface (Wallets screen, dashboard totals)
/// updates at once.
class WalletsNotifier extends AsyncNotifier<List<Wallet>> {
  WalletApi get _api => ref.read(walletApiProvider);

  @override
  Future<List<Wallet>> build() async {
    final cache = ref.read(jsonCacheProvider);
    try {
      final raw = await _api.fetchRaw();
      await cache.writeList(StorageKeys.cachedWallets, raw);
      _mark(stale: false);
      return _parse(raw);
    } catch (e) {
      // Network down — serve the last good snapshot if we have one, so the
      // screen stays useful offline. No snapshot → surface the error (retry).
      final cached = await cache.readList(StorageKeys.cachedWallets);
      if (cached != null) {
        _mark(stale: true);
        return _parse(cached);
      }
      rethrow;
    }
  }

  List<Wallet> _parse(List<dynamic> raw) => raw
      .map((e) => ApiWallet.fromJson(e as Map<String, dynamic>).toWallet())
      .toList();

  // Deferred so we never modify another provider during this one's build.
  void _mark({required bool stale}) {
    Future.microtask(() {
      final notifier = ref.read(offlineSourcesProvider.notifier);
      stale ? notifier.markStale('wallets') : notifier.markFresh('wallets');
    });
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

  /// Persists a new manual order. Optimistically shows [ordered] immediately,
  /// then persists; on failure it reloads to the server's truth.
  Future<void> reorder(List<Wallet> ordered) async {
    state = AsyncData([...ordered]);
    final ids = [
      for (final w in ordered)
        if (w.id != null) w.id!,
    ];
    final ok = await _api.reorder(ids);
    if (!ok) await _reload();
  }

  /// Makes [id] the primary wallet (backend clears the flag on the others).
  Future<void> setPrimary(String id) async {
    final ok = await _api.setPrimary(id);
    if (!ok) throw StateError('wallet-set-primary-failed');
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
