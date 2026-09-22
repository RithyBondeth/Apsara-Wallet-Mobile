import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/scan/data/receipt_category.dart';
import 'package:apsara_wallet_mobile/features/scan/data/scanned_receipt.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/receipt_review_sheet.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// The review sheet with a receipt that actually has a total and line items —
/// the shape every real OCR result has. It crashed on first use in the field
/// (LateInitializationError: `_currency` read while formatting the total
/// before it was assigned) because every earlier test only asserted the
/// sheet was *absent*.
Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

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

  testWidgets('renders a scanned receipt with a total and items', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    ScannedReceipt? saved;
    await tester.pumpWidget(
      _wrap(
        ReceiptReviewSheet(
          receipt: ScannedReceipt.sample,
          onSave: (r) => saved = r,
          onRetake: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Lucky Supermarket'), findsOneWidget);
    expect(find.text('Jasmine Rice 5kg'), findsOneWidget);
    // Category chips come from the catalog, localized.
    // The chip strip is lazy; the leading chips are what is built.
    expect(find.text('Groceries'), findsWidgets);
    expect(find.text('Dining'), findsOneWidget);
    expect(saved, isNull);
  });

  testWidgets('category chips are Khmer in Khmer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      _wrap(
        ReceiptReviewSheet(
          receipt: ScannedReceipt.sample,
          onSave: (_) {},
          onRetake: () {},
        ),
        locale: const Locale('km'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final km = await AppLocalizations.delegate.load(const Locale('km'));
    for (final c in ReceiptCategory.values.take(3)) {
      expect(find.text(c.labelOf(km)), findsWidgets, reason: c.name);
    }
    expect(find.text('Groceries'), findsNothing);

    await expectLater(
      find.byType(ReceiptReviewSheet),
      matchesGoldenFile('goldens/receipt_review_km.png'),
    );
  });
}
