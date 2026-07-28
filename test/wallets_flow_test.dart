import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/ledger_overrides.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/transfer_api.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/screens/wallet_detail_screen.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_side_menu.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/screens/wallets_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

import 'support/test_database.dart';

/// Records transfer creates so the flow can be asserted without the network.
class _FakeTransferApi implements TransferApi {
  bool created = false;
  int? amount;
  String? toWalletId;

  @override
  Future<List<ApiTransfer>> list({String? walletId}) async => const [];

  @override
  Future<bool> create({
    required String fromWalletId,
    required String toWalletId,
    required int amountKhr,
    required DateTime date,
    String? note,
  }) async {
    created = true;
    amount = amountKhr;
    this.toWalletId = toWalletId;
    return true;
  }
}

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

  testWidgets('Long-press-drag reorders the wallet list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    final alpha = Wallet(
      id: 'w-alpha',
      name: 'Alpha Bank',
      kind: WalletKind.bank,
      balanceKhr: 100000,
      balanceUsd: 0,
      brandColor: AppColors.primary,
    );
    final beta = Wallet(
      id: 'w-beta',
      name: 'Beta Cash',
      kind: WalletKind.cash,
      balanceKhr: 50000,
      balanceUsd: 0,
      brandColor: AppColors.info,
    );
    final router = AppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: sampleLedgerOverrides(wallets: [alpha, beta]),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router.config(
            deepLinkBuilder: (_) => DeepLink.single(const WalletsRoute()),
          ),
        ),
      ),
    );
    await settle(tester);

    // Alpha starts above Beta.
    expect(
      tester.getCenter(find.text('Alpha Bank')).dy <
          tester.getCenter(find.text('Beta Cash')).dy,
      isTrue,
    );

    // Long-press to pick up Alpha, then drag it down past Beta. Uses explicit
    // pumps (not pumpAndSettle) — the shrink-wrapped ReorderableListView's drag
    // auto-scroller never "settles".
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Alpha Bank')));
    await tester.pump(const Duration(milliseconds: 700)); // trigger long-press
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Beta is now above Alpha.
    expect(
      tester.getCenter(find.text('Beta Cash')).dy <
          tester.getCenter(find.text('Alpha Bank')).dy,
      isTrue,
    );
  });

  testWidgets('Transfer sheet moves money to another wallet', (tester) async {
    final fake = _FakeTransferApi();
    // Wallets need real ids for a transfer; the UI-sample wallets have none.
    final main = Wallet(
      id: 'w-main',
      name: 'Main Bank',
      kind: WalletKind.bank,
      balanceKhr: 200000,
      balanceUsd: 0,
      brandColor: AppColors.primary,
    );
    final petty = Wallet(
      id: 'w-petty',
      name: 'Petty Cash',
      kind: WalletKind.cash,
      balanceKhr: 40000,
      balanceUsd: 0,
      brandColor: AppColors.info,
    );
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final router = AppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...sampleLedgerOverrides(wallets: [main, petty]),
          transferApiProvider.overrideWithValue(fake),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router.config(
            deepLinkBuilder: (_) => DeepLink.single(const WalletsRoute()),
          ),
        ),
      ),
    );
    await settle(tester);

    // Open a wallet → its ⋮ menu → Transfer.
    await tester.tap(find.text('Main Bank').first);
    await settle(tester);
    await tester.tap(find.byIcon(LucideIcons.ellipsisVertical));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();

    // The transfer sheet is open with From/To and an amount field.
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    final amountField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '0',
    );
    await tester.enterText(amountField, '25000');
    await tester.pump();

    await tester.tap(find.widgetWithText(PrimaryButton, 'Transfer'));
    await tester.pumpAndSettle();

    expect(fake.created, isTrue);
    expect(fake.amount, 25000);
  });

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
