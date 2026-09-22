import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/features/scan/data/receipt_category.dart';
import 'package:apsara_wallet_mobile/features/scan/data/receipt_parser.dart';

/// The exact lines Apple Vision produces for a two-column supermarket receipt
/// once the native plugin groups observations into rows (label, two spaces,
/// amount). Before row grouping the parser got "8.50" and "Jasmine Rice 5kg"
/// as separate, interleaved lines and read the total as $10.00 from "VAT 10%".
const _visionRows = [
  'LUCKY SUPERMARKET',
  'Sihanouk Blvd, Phnom Penh',
  '20/09/2026 14:32',
  'Jasmine Rice 5kg  8.50',
  'Fresh Milk 1L x2  7.20',
  'Angkor Beer 6-pack  6.00',
  'Fresh Vegetables  4.25',
  'Cooking Oil 2L  5.90',
  'SUBTOTAL  31.85',
  'VAT 10%  3.19',
  'TOTAL  USD 35.04',
  'VISA **** 4242',
  'Thank you for shopping with us',
];

void main() {
  test('parses a column receipt emitted as rows', () {
    final r = ReceiptParser.parse(_visionRows);

    expect(r.merchant, 'Lucky Supermarket'); // title-cased from the header
    expect(r.currency, ECurrencyType.usd);
    expect(r.total, 35.04);
    expect(r.subtotal, 31.85);
    expect(r.tax, 3.19);
    expect(r.category, ReceiptCategory.groceries);
    expect(r.items.map((i) => i.name).toList(), [
      'Jasmine Rice 5kg',
      'Fresh Milk 1L',
      'Angkor Beer 6-pack',
      'Fresh Vegetables',
      'Cooking Oil 2L',
    ]);
    expect(r.items.map((i) => i.amount).toList(), [
      8.50,
      7.20,
      6.00,
      4.25,
      5.90,
    ]);
    expect(r.items[1].quantity, 2);
    // The printed date + time, so the saved expense lands on the day paid.
    expect(r.date, DateTime(2026, 9, 20, 14, 32));
  });

  group('parseDate', () {
    test('day-first, ISO and month-name forms', () {
      expect(ReceiptParser.parseDate('20/09/2026', ''), DateTime(2026, 9, 20));
      expect(
        ReceiptParser.parseDate('2026-09-20', 'paid 08:05'),
        DateTime(2026, 9, 20, 8, 5),
      );
      expect(ReceiptParser.parseDate('19 Jul 2026', ''), DateTime(2026, 7, 19));
      expect(ReceiptParser.parseDate('Sep 5, 26', ''), DateTime(2026, 9, 5));
    });

    test('rejects impossible dates instead of rolling them', () {
      expect(ReceiptParser.parseDate('31/02/2026', ''), isNull);
      expect(ReceiptParser.parseDate('20/13/2026', ''), isNull);
    });
  });
}
