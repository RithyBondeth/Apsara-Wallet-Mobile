import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/legal_document_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/rate_app_sheet.dart';
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

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
  }

  testWidgets('Terms of Service renders real content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    await tester.pumpWidget(_wrap(const TermsOfServiceScreen()));
    await settle(tester);

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.textContaining('Last updated'), findsOneWidget);
    expect(find.text('1. Acceptance of Terms'), findsOneWidget);
    // The "coming soon" stub must be gone.
    expect(find.text('Coming soon'), findsNothing);
  });

  testWidgets('Privacy Policy renders real content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    await tester.pumpWidget(_wrap(const PrivacyPolicyScreen()));
    await settle(tester);

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('1. Information We Collect'), findsOneWidget);

    // Contact card is the last item in the scrolling list.
    await tester.scrollUntilVisible(
      find.text('Contact Us'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Contact Us'), findsOneWidget);
  });

  testWidgets('Rate sheet: submit disabled until a star is picked',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showRateAppSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Enjoying Apsara Wallet?'), findsOneWidget);

    // With no star selected, tapping submit is a no-op — sheet stays open.
    await tester.tap(find.text('Submit Rating'));
    await tester.pumpAndSettle();
    expect(find.text('Enjoying Apsara Wallet?'), findsOneWidget);
  });

  testWidgets('Rate sheet: picking a star then submitting thanks the user',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showRateAppSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Pick 3 stars (a low rating stays in-app — no store launch).
    final stars = find.byIcon(Icons.star_outline_rounded);
    expect(stars, findsNWidgets(5));
    await tester.tap(stars.at(2));
    await tester.pump();
    // Third star is now filled.
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));

    await tester.tap(find.text('Submit Rating'));
    await tester.pumpAndSettle(); // process pop + snackbar

    expect(find.text('Enjoying Apsara Wallet?'), findsNothing); // closed
    expect(find.text('Thanks for your feedback!'), findsOneWidget);
  });
}
