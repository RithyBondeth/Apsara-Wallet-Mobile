import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_bottom_bar.dart';

/// Regression: the centre "+" button must open Add Transaction from every tab
/// that shows it — it was previously a no-op on Analytics & Wallets, and later
/// opened the camera (with an immediate permission prompt) instead of the
/// form most users actually want.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    final oldOnError = FlutterError.onError!;
    FlutterError.onError = (details) {
      final msg = details.exception.toString();
      if (msg.contains('google_fonts') ||
          msg.contains('was not found in the application assets') ||
          msg.contains('MissingPluginException')) {
        return; // no camera plugin under the test harness
      }
      oldOnError(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final router = AppRouter();
    await tester.pumpWidget(
      ProviderScope(
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
  }

  Future<void> tapAddAndSettle(WidgetTester tester) async {
    await tester.tap(find.byType(AppBottomBarCenterButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('Centre button opens AddTransactionScreen from the dashboard', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tapAddAndSettle(tester);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
  });

  testWidgets('Centre button opens AddTransactionScreen from Analytics', (
    tester,
  ) async {
    await pumpApp(tester);

    // Home -> Analytics.
    await tester.tap(find.byKey(AppBottomBar.tabKey(1)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(AnalyticsScreen), findsOneWidget);

    await tapAddAndSettle(tester);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
  });
}
