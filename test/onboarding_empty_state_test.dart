import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

import 'support/ledger_overrides.dart';

/// A fresh account (no wallets) should land on the create-first-wallet
/// onboarding CTA rather than an empty, dead-end dashboard.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('no wallets → dashboard shows the create-first-wallet CTA',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowProvider.overrideWithValue(DateTime(2024, 5, 20, 9, 0)),
          ...sampleLedgerOverrides(wallets: const [], transactions: const []),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.text('Create your first wallet'), findsOneWidget);
    expect(find.text('Create wallet'), findsOneWidget);
    // The month-overview card is not shown until there's a wallet.
    expect(find.text('This Month Overview'), findsNothing);
  });

  testWidgets('wallets present → shows the month overview, not onboarding',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowProvider.overrideWithValue(DateTime(2024, 5, 20, 9, 0)),
          ...sampleLedgerOverrides(),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.text('This Month Overview'), findsOneWidget);
    expect(find.text('Create your first wallet'), findsNothing);
  });
}
