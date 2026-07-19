import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

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

  testWidgets('Tapping the Profile tab routes to ProfileScreen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    final router = AppRouter();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router.config(),
        ),
      ),
    );
    // Dashboard has an endless ambient loop, so pump fixed frames instead of
    // pumpAndSettle (which would never settle).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));

    // Starts on the dashboard (initial route).
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);

    // Tap the Profile tab in the bottom bar.
    await tester.tap(find.text('Profile'));
    await tester.pump(); // start the route transition
    await tester.pump(const Duration(milliseconds: 500)); // let it animate in
    await tester.pump(const Duration(milliseconds: 1400)); // profile intro

    // The Profile screen should now be on top.
    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
