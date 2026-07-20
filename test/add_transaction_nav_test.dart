import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/screens/scan_receipt_screen.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

/// The dashboard quick actions must open the Add Transaction screen with the
/// matching mode preselected (they were previously stubbed out).
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

  Future<void> bootToDashboard(WidgetTester tester) async {
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
    expect(find.byType(DashboardScreen), findsOneWidget);
  }

  Future<void> settleRoute(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1400));
  }

  testWidgets('Add Expense quick action opens AddTransactionScreen',
      (tester) async {
    await bootToDashboard(tester);

    await tester.tap(find.text('Add Expense'));
    await settleRoute(tester);

    expect(find.byType(AddTransactionScreen), findsOneWidget);
    // Expense mode: default category row visible.
    expect(find.text('Food & Dining'), findsOneWidget);
  });

  testWidgets('Scan quick action opens the receipt scanner', (tester) async {
    await bootToDashboard(tester);

    await tester.tap(find.text('Scan'));
    await settleRoute(tester);

    expect(find.byType(ScanReceiptScreen), findsOneWidget);
  });

  testWidgets('Close returns to the dashboard', (tester) async {
    await bootToDashboard(tester);

    await tester.tap(find.text('Add Income'));
    await settleRoute(tester);
    expect(find.byType(AddTransactionScreen), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.x));
    await settleRoute(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(AddTransactionScreen), findsNothing);
  });
}
