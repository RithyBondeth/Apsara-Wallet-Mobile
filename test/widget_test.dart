// App smoke test: boots the real app and verifies the launch flow —
// splash first, then the automatic handoff to onboarding.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/app/app.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/splash_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env.dev');
  });

  testWidgets('App boots to splash and hands off to onboarding',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(); // let auto_route resolve the initial route
    expect(find.byType(SplashScreen), findsOneWidget);

    // Splash exits on its own after intro + hold.
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(OnBoardingScreen), findsOneWidget);
  });
}
