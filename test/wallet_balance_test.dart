import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/providers/fx_rate_provider.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_models.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';

import 'support/ledger_overrides.dart';
import 'support/sample_data.dart';

/// Riel balances come straight from the (API-backed) wallet records — the
/// server owns the figure. The USD figure is *derived* from riel at the FX
/// rate (the record's own `balanceUsd` is never moved by the ledger, so it
/// must not be displayed). [walletBalancesProvider] exposes them per name and
/// [walletsTotalProvider] sums across every wallet.
void main() {
  final sample = sampleWalletsData.wallets;

  Future<ProviderContainer> booted() async {
    final container = ProviderContainer(overrides: sampleLedgerOverrides());
    addTearDown(container.dispose);
    await container.read(walletsProvider.future);
    return container;
  }

  /// The rate the container resolved to (live, cached, or the pegged
  /// fallback) — USD assertions are made relative to it.
  Future<double> rateOf(ProviderContainer c) async =>
      (await c.read(fxRateProvider.future)).khrPerUsd;

  test('per-wallet balance matches the wallet record, USD derived from riel',
      () async {
    final container = await booted();
    final rate = await rateOf(container);
    final balances = container.read(walletBalancesProvider);
    for (final w in sample) {
      expect(balances[w.name]!.khr, w.balanceKhr);
      expect(balances[w.name]!.usd, closeTo(w.balanceKhr / rate, 1e-9));
      // Never the stored column — the ledger doesn't maintain it.
      expect(balances[w.name]!.usd, isNot(equals(w.balanceUsd)));
    }
  });

  test('total balance sums every wallet', () async {
    final container = await booted();
    final rate = await rateOf(container);
    final total = container.read(walletsTotalProvider);
    final expectedKhr = sample.fold<int>(0, (s, w) => s + w.balanceKhr);
    expect(total.khr, expectedKhr);
    expect(total.usd, closeTo(expectedKhr / rate, 1e-9));
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
