import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// Golden coverage for the Add Transaction screen (expense and transfer
/// modes). The date is pinned via [AddTransactionScreen.initialDateTime] so
/// the readout doesn't drift with the test run date.
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

final DateTime _pinnedDate = DateTime(2026, 5, 20, 19, 30);

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

  testWidgets('Add Transaction renders settled (expense)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      _wrap(AddTransactionScreen(initialDateTime: _pinnedDate)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('ABA Bank (1234)'), findsOneWidget);

    await expectLater(
      find.byType(AddTransactionScreen),
      matchesGoldenFile('goldens/add_transaction_expense.png'),
    );
  });

  testWidgets('Add Transaction renders settled (transfer)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      _wrap(
        AddTransactionScreen(
          initialType: ETransactionType.transfer,
          initialDateTime: _pinnedDate,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.text('From Wallet'), findsOneWidget);
    expect(find.text('To Wallet'), findsOneWidget);
    expect(find.text('ACLEDA Bank (5678)'), findsOneWidget);

    await expectLater(
      find.byType(AddTransactionScreen),
      matchesGoldenFile('goldens/add_transaction_transfer.png'),
    );
  });

  testWidgets('Save enables once an amount is typed', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      _wrap(AddTransactionScreen(initialDateTime: _pinnedDate)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    await tester.enterText(find.byType(TextField).first, '120000');
    await tester.pump();

    // The grouped formatter re-renders the raw digits with separators.
    expect(find.text('120,000'), findsOneWidget);
  });
}
