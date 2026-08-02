import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/ledger_overrides.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/screens/wallets_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_bottom_bar.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    final oldOnError = FlutterError.onError!;
    FlutterError.onError = (details) {
      final msg = details.exception.toString();
      if (msg.contains('google_fonts') ||
          msg.contains('was not found in the application assets')) {
        return;
      }
      oldOnError(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);
  });

  testWidgets('Tapping the Wallets tab routes to WalletsScreen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    final router = AppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: sampleLedgerOverrides(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router.config(
            deepLinkBuilder: (_) => DeepLink.single(const DashboardRoute()),
          ),
        ),
      ),
    );

    // Dashboard has an endless ambient loop, so pump fixed frames instead of
    // pumpAndSettle (which would never settle).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(WalletsScreen), findsNothing);

    // Tap the Wallets tab in the bottom bar.
    await tester.tap(find.byKey(AppBottomBar.tabKey(2)));
    await tester.pump(); // start the route transition
    await tester.pump(const Duration(milliseconds: 500)); // animate in
    await tester.pump(const Duration(milliseconds: 1400)); // wallets intro

    expect(find.byType(WalletsScreen), findsOneWidget);
    // Hero + at least the first wallet rendered.
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('ABA Bank'), findsOneWidget);
  });
}
