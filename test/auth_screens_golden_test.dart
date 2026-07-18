import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/welcome_screen.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(debugShowCheckedModeBanner: false, home: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // google_fonts reports a missing-font exception per style in tests; that
  // is expected here (fonts fall back), so filter those and keep the rest.
  setUp(() {
    final oldOnError = FlutterError.onError!;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('google_fonts') ||
          details.exception
              .toString()
              .contains('was not found in the application assets')) {
        return;
      }
      oldOnError(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);
  });

  testWidgets('Onboarding renders mid-cascade and settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const OnBoardingScreen()));
    await tester.pump(const Duration(milliseconds: 700));
    await expectLater(
      find.byType(OnBoardingScreen),
      matchesGoldenFile('goldens/onboarding_mid.png'),
    );
    await tester.pump(const Duration(milliseconds: 1900));
    await expectLater(
      find.byType(OnBoardingScreen),
      matchesGoldenFile('goldens/onboarding_settled.png'),
    );
  });

  testWidgets('Login renders mid-cascade and settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('goldens/login_mid.png'),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('goldens/login_settled.png'),
    );
  });

  // Runs after the others so the Ubuntu fonts are already warm.
  testWidgets('Welcome renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const WelcomeScreen()));
    // Decode the apsara illustration (asset images need real async).
    await tester.runAsync(() async {
      final context = tester.element(find.byType(WelcomeScreen));
      await precacheImage(
        const AssetImage(AssetPathConstant.apsaraFigure),
        context,
      );
    });
    await tester.pump(const Duration(milliseconds: 2600));
    await expectLater(
      find.byType(WelcomeScreen),
      matchesGoldenFile('goldens/welcome_settled.png'),
    );
  });
}
