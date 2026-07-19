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

  testWidgets('Scan simulates OCR and reveals the extracted receipt',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const ScanReceiptScreen()));
    await tester.pump(const Duration(milliseconds: 900)); // intro cascade

    // Capture phase: viewfinder chrome is present, no review sheet yet.
    expect(find.byType(ScanCaptureControls), findsOneWidget);
    expect(find.text('Align the receipt within the frame'), findsOneWidget);
    expect(find.byType(ReceiptReviewSheet), findsNothing);

    // Begin a scan (Gallery import runs the same extract flow as the shutter).
    await tester.tap(find.text('Gallery'));
    await tester.pump(); // -> analyzing
    expect(find.text('Reading your receipt…'), findsOneWidget);

    // Let the simulated OCR finish and the sheet slide up.
    await tester.pump(const Duration(milliseconds: 1800)); // OCR delay
    await tester.pump(const Duration(milliseconds: 700)); // reveal animation

    // Review phase: extracted merchant + totals are shown.
    expect(find.byType(ReceiptReviewSheet), findsOneWidget);
    expect(find.text('Receipt scanned'), findsOneWidget);
    expect(find.text('Lucky Supermarket'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
    expect(find.text('\$31.08'), findsOneWidget); // total
  });
}
