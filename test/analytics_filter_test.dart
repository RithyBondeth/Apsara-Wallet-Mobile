import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

import 'support/ledger_overrides.dart';

/// The filter row must be functional: the range dropdown opens a localized
/// sheet and the calendar button/period stepper open a real date picker.
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

  Future<void> boot(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    // Also size the test VIEW: dialogs read MediaQuery orientation from it,
    // and the default 800x600 view would make the date picker lay out in
    // landscape (setSurfaceSize alone doesn't update the view).
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowProvider.overrideWithValue(DateTime(2024, 5, 20, 9, 0)),
          ...sampleLedgerOverrides(),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AnalyticsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
  }

  testWidgets('Range dropdown opens sheet and updates the label', (
    tester,
  ) async {
    await boot(tester);
    expect(find.text('This Month'), findsOneWidget);

    await tester.tap(find.text('This Month'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Time Range'), findsOneWidget);
    await tester.tap(find.text('This Week'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('This Month'), findsNothing);
  });

  testWidgets('Calendar button opens the date picker and updates the period', (
    tester,
  ) async {
    await boot(tester);
    expect(find.text('May 2024'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.calendar));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(DatePickerDialog), findsOneWidget);

    // Lock in the branded picker design (emerald header, rounded dialog).
    await expectLater(
      find.byType(DatePickerDialog),
      matchesGoldenFile('goldens/date_picker.png'),
    );

    // Pick a day in the initially shown month (May 2024), confirm.
    await tester.tap(find.text('15'));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(DatePickerDialog), findsNothing);
    expect(find.text('May 2024'), findsOneWidget);
  });

  testWidgets('Period stepper also opens the date picker', (tester) async {
    await boot(tester);

    await tester.tap(find.text('May 2024'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
