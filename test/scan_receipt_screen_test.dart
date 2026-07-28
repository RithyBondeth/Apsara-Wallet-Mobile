import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/screens/scan_receipt_screen.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/receipt_review_sheet.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/scan_capture_controls.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

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

  testWidgets('Manual entry opens the editable review sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const ScanReceiptScreen()));
    await tester.pump(const Duration(milliseconds: 900));

    await tester.tap(find.text('Manual'));
    await tester.pump(); // start reveal
    await tester.pump(const Duration(milliseconds: 700)); // reveal animates in

    expect(find.byType(ReceiptReviewSheet), findsOneWidget);
    expect(find.text('Review receipt'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
    // Editable form fields are present (merchant, date, items, total).
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Add item'), findsOneWidget);
  });
}
