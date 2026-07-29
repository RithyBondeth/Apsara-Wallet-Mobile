import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations_en.dart';

/// B4: day grouping is now relative to an injected "now", not a pinned 2024
/// base — so entries added on the real clock bucket correctly.
void main() {
  setUpAll(() => initializeDateFormatting('en'));

  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 7, 20, 9, 0);

  test('same day is Today, previous day is Yesterday', () {
    expect(
      transactionGroupLabel(l10n, 'en', DateTime(2026, 7, 20, 14), now),
      l10n.notifToday,
    );
    expect(
      transactionGroupLabel(l10n, 'en', DateTime(2026, 7, 19, 8), now),
      l10n.notifYesterday,
    );
  });

  test('older days fall back to an absolute date', () {
    final label = transactionGroupLabel(l10n, 'en', DateTime(2026, 7, 15), now);
    expect(label, isNot(l10n.notifToday));
    expect(label, isNot(l10n.notifYesterday));
  });

  test('the "now" reference moves the buckets', () {
    // The very same date reads as Today under one clock, older under a later one.
    final date = DateTime(2026, 7, 20, 12);
    expect(transactionGroupLabel(l10n, 'en', date, date), l10n.notifToday);
    expect(
      transactionGroupLabel(l10n, 'en', date, DateTime(2026, 7, 25)),
      isNot(l10n.notifToday),
    );
  });
}
