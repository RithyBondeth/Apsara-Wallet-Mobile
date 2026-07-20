import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/about_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/help_support_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/savings_goals_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/security_screen.dart';
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
    await tester.pumpWidget(_wrap(const SavingsGoalsScreen()));
    await settle(tester);

    expect(find.text('Total Saved'), findsOneWidget);
    expect(find.text('Motorbike'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget); // motorbike 4.5M/6M

    await expectLater(
      find.byType(SavingsGoalsScreen),
      matchesGoldenFile('goldens/savings_goals_settled.png'),
    );
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
    expect(
      find.textContaining('encrypted and protected'),
      findsOneWidget,
    );
  });

  testWidgets('About renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(_wrap(const AboutScreen()));
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(MaterialApp));
      await precacheImage(
        const AssetImage('assets/logos/logo.png'),
        ctx,
      );
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
