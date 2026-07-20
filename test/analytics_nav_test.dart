import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/screens/wallets_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

/// Regression: from the Analytics screen the bottom bar must still reach the
/// Wallets and Profile destinations (they were previously stubbed out).
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

  Future<void> bootToAnalytics(WidgetTester tester) async {
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
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Home -> Analytics.
    await tester.tap(find.text('Analytics'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(AnalyticsScreen), findsOneWidget);
  }

  testWidgets('Analytics -> Wallets tab routes to WalletsScreen',
      (tester) async {
    await bootToAnalytics(tester);

    await tester.tap(find.text('Wallets'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.byType(WalletsScreen), findsOneWidget);
    expect(find.byType(AnalyticsScreen), findsNothing);
  });

  testWidgets('Analytics -> Profile tab routes to ProfileScreen',
      (tester) async {
    await bootToAnalytics(tester);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
