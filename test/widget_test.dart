// App smoke test: boots the real app and verifies the launch flow —
// splash first, then the automatic handoff to the welcome screen — and that
// an incoming deep link lands on the right screen whether it arrives at
// cold start or while the app is already running.

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/app/app.dart';
import 'package:apsara_wallet_mobile/core/deep_links/deep_link_provider.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/reset_password_screen.dart';
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

  /// Boots the app with a controllable link source in place of app_links.
  Future<StreamController<Uri>> boot(WidgetTester tester) async {
    final links = StreamController<Uri>.broadcast();
    addTearDown(links.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [deepLinkSourceProvider.overrideWithValue(links.stream)],
        child: const MyApp(),
      ),
    );
    return links;
  }

  /// Splash exits on its own after intro + hold.
  Future<void> letSplashFinish(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Screens run looping ambient animations, so `pumpAndSettle` never
  /// settles; pump through a route transition explicitly instead.
  Future<void> letRouteTransition(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('App boots to splash and hands off to welcome', (tester) async {
    await boot(tester);
    await tester.pump(); // resolve localizations delegates
    await tester.pump(); // let auto_route resolve the initial route
    expect(find.byType(SplashScreen), findsOneWidget);

    await letSplashFinish(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets(
    'A reset link at cold start opens the reset screen over welcome',
    (tester) async {
      final links = await boot(tester);
      await tester.pump();
      // app_links replays the launching link as soon as we subscribe — i.e.
      // while the splash is still up.
      links.add(Uri.parse('apsarawallet://reset-password?token=cold-start'));
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(ResetPasswordScreen), findsNothing);

      await letSplashFinish(tester);
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      final screen = tester.widget<ResetPasswordScreen>(
        find.byType(ResetPasswordScreen),
      );
      expect(screen.token, 'cold-start');

      // Welcome sits underneath, so "back" is sane.
      tester.element(find.byType(ResetPasswordScreen)).router.maybePop();
      await letRouteTransition(tester);
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(ResetPasswordScreen), findsNothing);
    },
  );

  testWidgets('A reset link while running pushes the reset screen', (
    tester,
  ) async {
    final links = await boot(tester);
    await tester.pump();
    await tester.pump();
    await letSplashFinish(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);

    links.add(Uri.parse('apsarawallet://reset-password?token=warm'));
    await letRouteTransition(tester);

    final screen = tester.widget<ResetPasswordScreen>(
      find.byType(ResetPasswordScreen),
    );
    expect(screen.token, 'warm');
  });

  testWidgets('An unknown link is ignored', (tester) async {
    final links = await boot(tester);
    await tester.pump();
    await tester.pump();
    await letSplashFinish(tester);

    links.add(Uri.parse('apsarawallet://not-a-thing?token=x'));
    await letRouteTransition(tester);

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsNothing);
  });
}
