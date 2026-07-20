import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/about_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/help_support_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/savings_goals_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/security_screen.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/screens/wallets_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

/// Every Profile menu tile must reach its destination — the sub-pages were
/// previously dead `onTap: () {}` stubs.
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

  Future<void> bootToProfile(WidgetTester tester) async {
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(ProfileScreen), findsOneWidget);
  }

  Future<void> tapTile(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pump();
    await tester.tap(find.text(label));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
  }

  final cases = <String, Type>{
    'My Wallets': WalletsScreen,
    'Security & Privacy': SecurityScreen,
    'Notifications': NotificationsScreen,
    'Savings Goals': SavingsGoalsScreen,
    'Help & Support': HelpSupportScreen,
    'About Apsara Wallet': AboutScreen,
  };

  cases.forEach((label, screen) {
    testWidgets('Profile "$label" tile opens $screen', (tester) async {
      await bootToProfile(tester);
      await tapTile(tester, label);
      expect(find.byType(screen), findsOneWidget);
    });
  });
}
