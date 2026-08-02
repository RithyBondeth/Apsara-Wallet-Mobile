import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';

import 'support/ledger_overrides.dart';

/// Wallet balances now come straight from the (API-backed) wallet records —
/// the server owns the figure. [walletBalancesProvider] exposes them per name
/// and [walletsTotalProvider] sums across every wallet.
void main() {
  final sample = WalletsData.sample.wallets;

  Future<ProviderContainer> booted() async {
    final container = ProviderContainer(overrides: sampleLedgerOverrides());
    addTearDown(container.dispose);
    await container.read(walletsProvider.future);
    return container;
  }

  test('per-wallet balance matches the wallet record', () async {
    final container = await booted();
    final balances = container.read(walletBalancesProvider);
    for (final w in sample) {
      expect(balances[w.name]!.khr, w.balanceKhr);
      expect(balances[w.name]!.usd, w.balanceUsd);
    }
  });

  test('total balance sums every wallet', () async {
    final container = await booted();
    final total = container.read(walletsTotalProvider);
    final expectedKhr = sample.fold<int>(0, (s, w) => s + w.balanceKhr);
    final expectedUsd = sample.fold<double>(0, (s, w) => s + w.balanceUsd);
    expect(total.khr, expectedKhr);
    expect(total.usd, expectedUsd);
  });

  test('adding a wallet raises the total', () async {
    final container = await booted();
    final before = container.read(walletsTotalProvider).khr;
    await container
        .read(walletsProvider.notifier)
        .add(
          const Wallet(
            name: 'New Wallet',
            kind: WalletKind.cash,
            balanceKhr: 100000,
            balanceUsd: 25,
            brandColor: Color(0xFF0B5B3D),
          ),
        );
    expect(container.read(walletsTotalProvider).khr, before + 100000);
  });
}
