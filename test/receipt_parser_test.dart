import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/features/scan/data/receipt_parser.dart';

void main() {
  group('ReceiptParser', () {
    test('parses a typical USD supermarket receipt', () {
      final receipt = ReceiptParser.parse([
        'LUCKY SUPERMARKET',
        'Sihanouk Blvd, Phnom Penh',
        'Tel: 023 123 456',
        '19/07/2026 14:32',
        'Jasmine Rice 5kg      8.50',
        'Fresh Milk 1L x2      3.60',
        'Angkor Beer 6-pack    6.00',
        'Vegetables            4.25',
        'Cooking Oil 2L        5.90',
        'Subtotal             28.25',
        'VAT 10%               2.83',
        'TOTAL                31.08',
        'CASH                 40.00',
        'CHANGE                8.92',
        'Thank you!',
      ]);

      expect(receipt.merchant, 'Lucky Supermarket');
      expect(receipt.dateLabel, '19/07/2026');
      expect(receipt.total, 31.08);
      expect(receipt.subtotal, 28.25);
      expect(receipt.tax, 2.83);
      expect(receipt.taxLabel, 'VAT');
      expect(receipt.currency, ECurrencyType.usd);
      expect(receipt.categoryLabel, 'Groceries');

      // Summary lines (subtotal/vat/total/cash/change) are excluded as items.
      final names = receipt.items.map((i) => i.name).toList();
      expect(names, contains('Jasmine Rice 5kg'));
      expect(names, contains('Angkor Beer 6-pack'));
      expect(names.any((n) => n.toLowerCase().contains('total')), isFalse);
      expect(names.any((n) => n.toLowerCase().contains('change')), isFalse);

      // Quantity is stripped from the name and captured.
      final milk = receipt.items.firstWhere(
        (i) => i.name.startsWith('Fresh Milk'),
      );
      expect(milk.amount, 3.60);
      expect(milk.quantity, 2);
    });

    test('detects KHR currency and no-decimal amounts', () {
      final receipt = ReceiptParser.parse([
        'ផ្សារ Chip Mong',
        'Coffee              8000៛',
        'Water               2000៛',
        'Total ៛            10,000',
      ]);

      expect(receipt.currency, ECurrencyType.khr);
      expect(receipt.total, 10000);
    });

    test('picks the largest amount when no total keyword is present', () {
      final receipt = ReceiptParser.parse([
        'Corner Shop',
        'Item A     2.00',
        'Item B    15.50',
        'Item C     4.00',
      ]);

      expect(receipt.total, 15.50);
    });

    test('handles European-style decimals (1.234,56)', () {
      final receipt = ReceiptParser.parse(['Store', 'Total   1.234,56']);

      expect(receipt.total, 1234.56);
    });

    test('returns a blank receipt for empty OCR output', () {
      final receipt = ReceiptParser.parse([]);
      expect(receipt.merchant, '');
      expect(receipt.total, 0);
      expect(receipt.items, isEmpty);
      expect(receipt.categoryLabel, 'Uncategorised');
    });

    test('infers Dining category from keywords', () {
      final receipt = ReceiptParser.parse([
        'Brown Coffee & Bakery',
        'Latte    3.50',
        'Total    3.50',
      ]);
      expect(receipt.categoryLabel, 'Dining');
    });
  });
}
