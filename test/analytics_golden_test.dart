import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/widgets/analytics_segmented_tabs.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

import 'support/ledger_overrides.dart';

// Anchor to the sample ledger's month so the derived analytics are stable.
final _fixedNow = DateTime(2024, 5, 20, 9, 0);

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      nowProvider.overrideWithValue(_fixedNow),
      ...sampleLedgerOverrides(),
    ],
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

  testWidgets('Analytics renders all three tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const AnalyticsScreen()));
    await tester.pump(const Duration(milliseconds: 1400));
    await expectLater(
      find.byType(AnalyticsScreen),
      matchesGoldenFile('goldens/analytics_overview.png'),
    );

    // Categories tab.
    await tester.tap(find.text('Categories'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
    await expectLater(
      find.byType(AnalyticsScreen),
      matchesGoldenFile('goldens/analytics_categories.png'),
    );

    // Trends tab.
    await tester.tap(find.text('Trends'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
    await expectLater(
      find.byType(AnalyticsScreen),
      matchesGoldenFile('goldens/analytics_trends.png'),
    );

    // Sanity: the segmented control is present.
    expect(find.byType(AnalyticsSegmentedTabs), findsOneWidget);
  });
}
