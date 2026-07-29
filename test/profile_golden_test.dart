import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/settings_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

import 'support/ledger_overrides.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: sampleLedgerOverrides(),
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
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    final oldOnError = FlutterError.onError!;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('google_fonts') ||
          details.exception.toString().contains(
            'was not found in the application assets',
          )) {
        return;
      }
      oldOnError(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);
  });

  testWidgets('Profile renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(_wrap(const ProfileScreen()));
    await tester.pump(const Duration(milliseconds: 1400));
    await expectLater(
      find.byType(ProfileScreen),
      matchesGoldenFile('goldens/profile_settled.png'),
    );
  });

  testWidgets('Settings renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 1300));
    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings_settled.png'),
    );
  });
}
