// App smoke test: boots the real app and verifies the launch flow —
// splash first, then the automatic handoff to the welcome screen.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/app/app.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/welcome_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Fonts (incl. the Khmer fallback) fall back to bundled/default faces in
    // tests rather than hitting the network.
    GoogleFonts.config.allowRuntimeFetching = false;
    await dotenv.load(fileName: '.env.dev');
    // The splash now restores any saved session on boot, which reads secure
    // storage — give it an empty in-memory store so the app boots signed-out.
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('App boots to splash and hands off to welcome', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(); // resolve localizations delegates
    await tester.pump(); // let auto_route resolve the initial route
    expect(find.byType(SplashScreen), findsOneWidget);

    // Splash exits on its own after intro + hold.
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
