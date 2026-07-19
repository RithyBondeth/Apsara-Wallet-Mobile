import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/screens/scan_receipt_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_bottom_bar.dart';

/// Regression: the centre "scan" button must open the Scan Receipt screen from
/// every tab that shows it — it was previously a no-op on Analytics & Wallets.
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
          routerConfig: router.config(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
  }

  Future<void> tapScanAndSettle(WidgetTester tester) async {
    await tester.tap(find.byType(AppBottomBarCenterButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('Scan button opens ScanReceiptScreen from the dashboard',
      (tester) async {
    await pumpApp(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tapScanAndSettle(tester);
    expect(find.byType(ScanReceiptScreen), findsOneWidget);
  });

  testWidgets('Scan button opens ScanReceiptScreen from Analytics',
      (tester) async {
    await pumpApp(tester);

    // Home -> Analytics.
    await tester.tap(find.text('Analytics'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(AnalyticsScreen), findsOneWidget);

    await tapScanAndSettle(tester);
    expect(find.byType(ScanReceiptScreen), findsOneWidget);
  });
}
