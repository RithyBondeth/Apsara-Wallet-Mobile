import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/biometric_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/pin_login_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/reset_password_screen.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(debugShowCheckedModeBanner: false, home: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final screens = <String, Widget>{
    'register': const RegisterScreen(),
    'forgot_password': const ForgotPasswordScreen(),
    'otp': const OtpScreen(),
    'reset_password': const ResetPasswordScreen(),
    'pin_setup': const PinSetupScreen(),
    'pin_login': const PinLoginScreen(),
    'biometric': const BiometricScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} renders settled', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(_wrap(entry.value));
      // Let fonts finish loading and decode the shared auth backdrop.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final context = tester.element(find.byType(MaterialApp));
        await precacheImage(
          const AssetImage(AssetPathConstant.authBackground),
          context,
        );
      });
      await tester.pump(const Duration(milliseconds: 2600));
      await expectLater(
        find.byType(entry.value.runtimeType),
        matchesGoldenFile('goldens/${entry.key}_settled.png'),
      );
    });
  }
}
