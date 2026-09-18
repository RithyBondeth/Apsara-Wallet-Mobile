import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/screens/scan_receipt_screen.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/receipt_review_sheet.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/scan_capture_controls.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

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

  testWidgets('Scan screen builds with the capture chrome', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const ScanReceiptScreen()));
    // No camera plugin in the test host — the screen must still build and show
    // its controls rather than crashing.
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byType(ScanReceiptScreen), findsOneWidget);
    expect(find.byType(ScanCaptureControls), findsOneWidget);
    expect(find.text('Scan Receipt'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);
    expect(find.byType(ReceiptReviewSheet), findsNothing);
  });

  testWidgets('Manual entry swaps the scanner for the Add Transaction form',
      (tester) async {
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
            deepLinkBuilder: (_) => DeepLink.single(const ScanReceiptRoute()),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(ScanReceiptScreen), findsOneWidget);

    await tester.tap(find.text('Manual'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(AddTransactionScreen), findsOneWidget);
    // Replaced, not pushed: Back must not return to the camera.
    expect(find.byType(ScanReceiptScreen), findsNothing);
    expect(find.byType(ReceiptReviewSheet), findsNothing);
  });
}
