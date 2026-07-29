import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/categories/presentation/screens/categories_screen.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_bottom_bar.dart';

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

  testWidgets('Categories renders settled and toggles to income', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const CategoriesScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.text('Food & Dining'), findsOneWidget);

    await expectLater(
      find.byType(CategoriesScreen),
      matchesGoldenFile('goldens/categories_expense.png'),
    );

    await tester.tap(find.text('Income'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food & Dining'), findsNothing);
  });

  testWidgets('Search filters the grid', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_wrap(const CategoriesScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    await tester.enterText(find.byType(TextField).first, 'tra');
    await tester.pump();

    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Food & Dining'), findsNothing);
  });

  testWidgets('Profile Categories tile opens CategoriesScreen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final router = AppRouter();
    await tester.pumpWidget(
      ProviderScope(
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

    await tester.tap(find.byKey(AppBottomBar.tabKey(3)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.ensureVisible(find.text('Categories'));
    await tester.pump();
    await tester.tap(find.text('Categories'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.byType(CategoriesScreen), findsOneWidget);
  });
}
