import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

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

Widget _router(AppRouter router) {
  return ProviderScope(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router.config(),
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

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
  }

  testWidgets('Transactions list renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(_wrap(const TransactionsListScreen()));
    await settle(tester);

    expect(find.text('Grab Food'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);

    await expectLater(
      find.byType(TransactionsListScreen),
      matchesGoldenFile('goldens/transactions_list.png'),
    );
  });

  testWidgets('Transaction detail renders settled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(_wrap(const TransactionDetailScreen(id: 'aba-salary')));
    await settle(tester);

    expect(find.text('ABA Salary'), findsOneWidget);
    expect(find.text('Monthly salary'), findsOneWidget);
    expect(find.text('+ KHR 3,500,000'), findsOneWidget);

    await expectLater(
      find.byType(TransactionDetailScreen),
      matchesGoldenFile('goldens/transaction_detail.png'),
    );
  });

  testWidgets('Type filter narrows the list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(_wrap(const TransactionsListScreen()));
    await settle(tester);

    await tester.tap(find.text('Income'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('ABA Salary'), findsOneWidget);
    expect(find.text('Grab Food'), findsNothing);
  });

  testWidgets('Search narrows the list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(_wrap(const TransactionsListScreen()));
    await settle(tester);

    await tester.enterText(find.byType(TextField).first, 'coffee');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Coffee Shop'), findsOneWidget);
    expect(find.text('ABA Salary'), findsNothing);
  });

  testWidgets('Dashboard See All opens list; row opens detail', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final router = AppRouter();
    await tester.pumpWidget(_router(router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.tap(find.text('See All'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(TransactionsListScreen), findsOneWidget);

    await tester.tap(find.text('Grab Food'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
    expect(find.text('Lunch delivery'), findsOneWidget);
  });

  testWidgets('Delete flow confirms and pops back to the list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final router = AppRouter();
    await tester.pumpWidget(_router(router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));

    await tester.tap(find.text('See All'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.tap(find.text('Grab Food'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(TransactionDetailScreen), findsOneWidget);

    // Delete row → confirm sheet → confirm.
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Delete transaction?'), findsOneWidget);

    await tester.tap(find.text('Delete').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.byType(TransactionsListScreen), findsOneWidget);
  });
}
