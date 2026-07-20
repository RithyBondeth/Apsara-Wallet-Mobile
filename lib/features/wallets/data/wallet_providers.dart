import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Combined balance across every wallet, recomputed as the list changes.
final walletsTotalProvider = Provider<({int khr, double usd})>((ref) {
  final wallets = ref.watch(walletsProvider);
  return (
    khr: wallets.fold<int>(0, (sum, w) => sum + w.balanceKhr),
    usd: wallets.fold<double>(0, (sum, w) => sum + w.balanceUsd),
  );
});
