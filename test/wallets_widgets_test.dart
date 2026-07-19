import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/widgets/total_balance_card.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/widgets/wallet_card.dart';

/// Component-level render tests for the wallets building blocks. These import
/// only the widgets + data (not the screen, which pulls in the full router),
/// so they build and run independently of sibling in-flight features.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    final oldOnError = FlutterError.onError!;
    FlutterError.onError = (details) {
      final msg = details.exception.toString();
      // Tolerate missing fonts / bundled asset images under the test harness.
      if (msg.contains('google_fonts') ||
          msg.contains('Unable to load asset') ||
          msg.contains('was not found in the application assets')) {
        return;
      }
      oldOnError(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);
  });

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );

  testWidgets('TotalBalanceCard shows the combined balance and wallet count',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      wrap(
        TotalBalanceCard(
          data: WalletsData.sample,
          balanceHidden: false,
          onToggleBalance: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('2,584,300'), findsOneWidget); // KHR total
    expect(find.text('≈ USD 645.20'), findsOneWidget);
    expect(find.text('4 wallets'), findsOneWidget);
  });

  testWidgets('TotalBalanceCard masks amounts when hidden', (tester) async {
    await tester.pumpWidget(
      wrap(
        TotalBalanceCard(
          data: WalletsData.sample,
          balanceHidden: true,
          onToggleBalance: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('••••••••'), findsOneWidget);
    expect(find.text('2,584,300'), findsNothing);
  });

  testWidgets('WalletCard renders name, type/account and balances',
      (tester) async {
    final wallet = WalletsData.sample.wallets.first; // ABA Bank (primary)
    await tester.pumpWidget(
      wrap(WalletCard(wallet: wallet, balanceHidden: false)),
    );
    await tester.pump();

    expect(find.text('ABA Bank'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('ABA'), findsOneWidget); // logo short code
    expect(find.textContaining('•••• 1234'), findsOneWidget);
    expect(find.text('KHR 1,250,000'), findsOneWidget);
  });

  testWidgets('Cash wallet falls back to an icon and hides masking',
      (tester) async {
    final cash = WalletsData.sample.wallets
        .firstWhere((w) => w.kind == WalletKind.cash);
    expect(cash.maskedAccount, isNull);

    await tester.pumpWidget(
      wrap(WalletCard(wallet: cash, balanceHidden: false)),
    );
    await tester.pump();

    expect(find.text('Cash Wallet'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget); // kind label only
  });

  test('Sample wallet balances sum to the stated total', () {
    final sum = WalletsData.sample.wallets
        .fold<int>(0, (acc, w) => acc + w.balanceKhr);
    expect(sum, WalletsData.sample.totalBalanceKhr);
  });
}
