import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

import 'support/test_database.dart';

/// A fixed "now" so the recent list's day labels (Today/Yesterday) are stable;
/// anchored to the seeded sample's most recent day.
final _fixedNow = DateTime(2024, 5, 20, 9, 0);

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [nowProvider.overrideWithValue(_fixedNow)],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

Future<void> _precache(WidgetTester tester, List<String> assets) async {
  await tester.runAsync(() async {
    final context = tester.element(find.byType(MaterialApp));
    for (final asset in assets) {
      await precacheImage(AssetImage(asset), context);
    }
  });
  await tester.pump();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    await initTestDatabase();

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

  testWidgets('Dashboard renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const DashboardScreen()));
    // Let the seeded ledger load (no-isolate ffi resolves on the pump queue)
    // so the balance, month totals and recent list are ledger-derived.
    await tester.pump();
    await tester.pump();
    await _precache(tester, const [
      AssetPathConstant.dashboardBackground,
      AssetPathConstant.logo,
    ]);
    await tester.pump(const Duration(milliseconds: 1600));
    await expectLater(
      find.byType(DashboardScreen),
      matchesGoldenFile('goldens/dashboard_settled.png'),
    );
  });
}
