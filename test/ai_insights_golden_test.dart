import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/ledger_overrides.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/insights/presentation/screens/ai_insights_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_bottom_bar.dart';

import 'support/test_database.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() async {
    // The screen now derives its report from the live ledger, so seed a fresh
    // in-memory database (with the Phase-1 sample) before each case.
    await initTestDatabase();

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

  testWidgets('AI Insights renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      ProviderScope(
        overrides: sampleLedgerOverrides(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AiInsightsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.text('Financial Health Score'), findsOneWidget);
    // Computed from the seeded sample ledger (high income, low expenses).
    expect(find.text('90'), findsOneWidget); // counted-up score

    await expectLater(
      find.byType(AiInsightsScreen),
      matchesGoldenFile('goldens/ai_insights_settled.png'),
    );
  });

  testWidgets('Analytics sparkles button opens AI Insights', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final router = AppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: sampleLedgerOverrides(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router.config(
            deepLinkBuilder: (_) => DeepLink.single(const DashboardRoute()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.tap(find.byKey(AppBottomBar.tabKey(1)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(AnalyticsScreen), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.sparkles));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.byType(AiInsightsScreen), findsOneWidget);
  });
}
