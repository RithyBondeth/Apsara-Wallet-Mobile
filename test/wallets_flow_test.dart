import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/ledger_overrides.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/screens/wallet_detail_screen.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_side_menu.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/screens/wallets_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

import 'support/test_database.dart';

/// Wallet detail + add-wallet flows (Wallet cards and "+ Add Wallet" were
/// previously dead stubs). Wallet detail reads the account's live
/// transactions, so the in-memory db is initialised.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() async {
    await initTestDatabase();
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

  Widget wrapRouter(AppRouter router) {
    return ProviderScope(
      overrides: sampleLedgerOverrides(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router.config(
          deepLinkBuilder: (_) => DeepLink.single(const WalletsRoute()),
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
  }

  testWidgets('Tapping a wallet opens its detail with that account activity',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(wrapRouter(AppRouter()));
    await settle(tester);
    expect(find.byType(WalletsScreen), findsOneWidget);

    // ABA Bank has seeded transactions (e.g. ABA Salary).
    await tester.tap(find.text('ABA Bank').first);
    await settle(tester);

    expect(find.byType(WalletDetailScreen), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('ABA Salary'), findsOneWidget);

    await expectLater(
      find.byType(WalletDetailScreen),
      matchesGoldenFile('goldens/wallet_detail.png'),
    );
  });

  testWidgets('Side menu drawer renders settled', (tester) async {
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/backgrounds/sidemenu-bg.png'),
        tester.element(find.byType(DashboardScreen)),
      );
    });
    await tester.tap(find.byIcon(LucideIcons.menu));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(AppSideMenu),
      matchesGoldenFile('goldens/side_menu.png'),
    );
  });

  testWidgets('Add Wallet appends a new wallet to the list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(wrapRouter(AppRouter()));
    await settle(tester);

    await tester.ensureVisible(find.text('Add Wallet'));
    await tester.pump();
    await tester.tap(find.text('Add Wallet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(find.byType(TextField).first, 'True Money');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('True Money'), findsOneWidget);
  });

  testWidgets('Dashboard menu button opens the side drawer', (tester) async {
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.menu));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Drawer shows nav shortcuts unique to it.
    expect(find.byType(AppSideMenu), findsOneWidget);
    expect(find.text('Savings Goals'), findsOneWidget);
  });
}
