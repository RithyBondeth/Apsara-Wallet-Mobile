import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/database/app_database.dart';
import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/core/utils/currency_converter.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_repository.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

import 'support/test_database.dart';

/// Covers the two Add-Transaction fixes: USD amounts no longer save as 0 (B1),
/// and editing replaces the existing row instead of creating a duplicate (B2).
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late TransactionRepository repo;

  setUp(() async {
    await initTestDatabase();
    repo = TransactionRepository(AppDatabase.instance);

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

  Future<void> pumpAt(WidgetTester tester, PageRouteInfo route) async {
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
            deepLinkBuilder: (_) => DeepLink.single(route),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byType(AddTransactionScreen), findsOneWidget);
  }

  final amountField = find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == '0',
  );

  group('CurrencyConverter (B1 root cause)', () {
    test('USD converts to riel; KHR passes through', () {
      expect(CurrencyConverter.usdToKhr(12.50), 51250); // 12.50 * 4100
      expect(CurrencyConverter.toKhr(12.50, ECurrencyType.usd), 51250);
      expect(CurrencyConverter.toKhr(18000, ECurrencyType.khr), 18000);
    });
  });

  testWidgets('B1: a USD amount saves converted riel, not 0', (tester) async {
    await pumpAt(tester, AddTransactionRoute());

    // Switch the currency chip to USD.
    await tester.tap(find.text('KHR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('US Dollar'));
    await tester.pumpAndSettle();

    await tester.enterText(amountField, '12.50');
    await tester.pump();

    await tester.ensureVisible(find.text('Save Transaction'));
    await tester.pump();
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final all = await repo.getAll();
    // Before: int.tryParse('12.50') => null => stored 0. Now: 12.50 * 4100.
    expect(all.any((t) => t.amountKhr == 51250), isTrue);
    expect(all.any((t) => t.amountKhr == 0), isFalse);
  });

  testWidgets('B2: editing replaces the row instead of duplicating it',
      (tester) async {
    final original = (await repo.getById('grab-food'))!;
    final countBefore = (await repo.getAll()).length;
    expect(original.amountKhr, 18000);

    await pumpAt(
      tester,
      AddTransactionRoute(initialType: original.type, initialRecord: original),
    );

    // Edit mode: header reads "Edit Transaction" and fields are prefilled.
    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(find.text('Grab Food'), findsOneWidget);
    expect(find.text('18,000'), findsOneWidget);

    await tester.enterText(amountField, '25000');
    await tester.pump();

    await tester.ensureVisible(find.text('Save Transaction'));
    await tester.pump();
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Same id updated, no new row created.
    final after = await repo.getAll();
    expect(after.length, countBefore);
    final updated = await repo.getById('grab-food');
    expect(updated, isNotNull);
    expect(updated!.amountKhr, 25000);
    expect(updated.title, 'Grab Food'); // untouched fields preserved
  });
}
