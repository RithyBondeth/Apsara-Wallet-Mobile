import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
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

  testWidgets('Dashboard renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const DashboardScreen()));
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
