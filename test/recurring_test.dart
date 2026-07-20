import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:apsara_wallet_mobile/features/recurring/presentation/screens/recurring_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

/// Covers the new Recurring feature: it renders the seeded sample with a
/// correct monthly-expense estimate, is reachable from Profile, and its add
/// flow appends an entry.
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

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RecurringScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
  }

  testWidgets('renders the sample rules and monthly estimate', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Recurring'), findsOneWidget); // app bar title
    expect(find.text('Monthly Salary'), findsOneWidget);
    expect(find.text('House Rent'), findsOneWidget);
    expect(find.text('5 recurring entries'), findsOneWidget);
    // 400,000 + (20,000*52/12) + 40,000 + 40,000 = 566,667 (income excluded).
    expect(find.textContaining('566,667'), findsOneWidget);

    await expectLater(
      find.byType(RecurringScreen),
      matchesGoldenFile('goldens/recurring_settled.png'),
    );
  });

  testWidgets('add flow appends a new entry', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Add Recurring'));
    await tester.pumpAndSettle();

    final amountField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '0',
    );
    await tester.enterText(amountField, '15000');
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Sixth entry now present in the summary.
    expect(find.text('6 recurring entries'), findsOneWidget);
  });

  testWidgets('tapping a rule edits it in place', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('House Rent'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Recurring'), findsOneWidget);

    final amountField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '0',
    );
    await tester.enterText(amountField, '500000');
    await tester.pump();
    await tester.ensureVisible(find.text('Save'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Still 5 entries (updated, not added), with the new amount on the card.
    expect(find.text('5 recurring entries'), findsOneWidget);
    expect(find.text('- KHR 500,000'), findsOneWidget);
  });

  testWidgets('editing a rule can delete it', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('House Rent'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete'));
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('House Rent'), findsNothing);
    expect(find.text('4 recurring entries'), findsOneWidget);
  });

  testWidgets('reachable from the Profile menu', (tester) async {
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
            deepLinkBuilder: (_) => DeepLink.single(const ProfileRoute()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.ensureVisible(find.text('Recurring'));
    await tester.pump();
    await tester.tap(find.text('Recurring'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.byType(RecurringScreen), findsOneWidget);
  });
}
