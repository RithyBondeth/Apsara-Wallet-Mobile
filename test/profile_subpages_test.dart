import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/profile/data/savings_goals_mock_data.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/about_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/help_support_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/savings_goals_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/security_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

import 'support/ledger_overrides.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
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

  testWidgets('Security renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(_wrap(const SecurityScreen()));
    await settle(tester);

    expect(find.text('Biometric Login'), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);

    await expectLater(
      find.byType(SecurityScreen),
      matchesGoldenFile('goldens/security_settled.png'),
    );
  });


  testWidgets('Savings Goals renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(
      _wrap(const SavingsGoalsScreen(), overrides: sampleSavingsOverride()),
    );
    await settle(tester);

    expect(find.text('Total Saved'), findsOneWidget);
    expect(find.text('Motorbike'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget); // motorbike 4.5M/6M

    await expectLater(
      find.byType(SavingsGoalsScreen),
      matchesGoldenFile('goldens/savings_goals_settled.png'),
    );
  });

  testWidgets('Add Goal sheet has icon + colour pickers and creates a goal', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(
      _wrap(const SavingsGoalsScreen(), overrides: sampleSavingsOverride()),
    );
    await settle(tester);

    // Open the new-goal sheet from the app-bar action.
    await tester.tap(find.text('Add Goal'));
    await tester.pumpAndSettle();

    // The picker sections are present.
    expect(find.text('Icon'), findsOneWidget);
    expect(find.text('Color'), findsOneWidget);

    // Fill name + target (name field is first, target is the KHR field).
    await tester.enterText(find.byType(TextField).first, 'Test Goal');
    final amount = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '0',
    );
    await tester.enterText(amount, '500000');
    await tester.pump();

    // Save and confirm the new goal appears in the list.
    await tester.ensureVisible(find.text('Save'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Test Goal'), findsOneWidget);
  });

  testWidgets('Long-press a goal opens the edit sheet and updates it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    final goal = SavingsGoal(
      id: 'g1',
      icon: LucideIcons.target,
      color: AppColors.primary,
      savedKhr: 100000,
      targetKhr: 500000,
      customName: 'Old Name',
    );
    await tester.pumpWidget(
      _wrap(
        const SavingsGoalsScreen(),
        overrides: sampleSavingsOverride([goal]),
      ),
    );
    await settle(tester);
    expect(find.text('Old Name'), findsOneWidget);

    // Long-press opens the prefilled edit sheet.
    await tester.longPress(find.text('Old Name'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Goal'), findsOneWidget);

    // Rename and save.
    await tester.enterText(find.byType(TextField).first, 'New Name');
    await tester.pump();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('New Name'), findsOneWidget);
    expect(find.text('Old Name'), findsNothing);
  });

  testWidgets('Edit sheet deletes a goal after confirmation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    final goal = SavingsGoal(
      id: 'g9',
      icon: LucideIcons.target,
      color: AppColors.primary,
      savedKhr: 0,
      targetKhr: 300000,
      customName: 'Doomed Goal',
    );
    await tester.pumpWidget(
      _wrap(
        const SavingsGoalsScreen(),
        overrides: sampleSavingsOverride([goal]),
      ),
    );
    await settle(tester);
    expect(find.text('Doomed Goal'), findsOneWidget);

    // Long-press → edit sheet → tap "Delete Goal".
    await tester.longPress(find.text('Doomed Goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Goal'));
    await tester.pumpAndSettle();

    // Confirm dialog → confirm.
    expect(find.text('Delete this goal?'), findsOneWidget);
    await tester.tap(find.text('Delete Goal')); // dialog's confirm action
    await tester.pumpAndSettle();

    expect(find.text('Doomed Goal'), findsNothing);
  });

  testWidgets('Help & Support renders and FAQ expands', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(_wrap(const HelpSupportScreen()));
    await settle(tester);

    expect(find.text('support@apsarawallet.com'), findsOneWidget);

    await expectLater(
      find.byType(HelpSupportScreen),
      matchesGoldenFile('goldens/help_support_settled.png'),
    );

    // Tapping a question reveals its answer.
    await tester.tap(find.text('Is my financial data secure?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('encrypted and protected'), findsOneWidget);
  });

  testWidgets('About renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(_wrap(const AboutScreen()));
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(MaterialApp));
      await precacheImage(const AssetImage('assets/logos/logo.png'), ctx);
    });
    await settle(tester);

    expect(find.text('Apsara Wallet'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);

    await expectLater(
      find.byType(AboutScreen),
      matchesGoldenFile('goldens/about_settled.png'),
    );
  });
}
