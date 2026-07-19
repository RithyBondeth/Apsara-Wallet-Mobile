import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/widgets.dart';

/// UI-only mock data for the Scan Receipt flow. Phase 1 has no camera or OCR —
/// tapping the shutter simulates a scan and reveals this pre-extracted result.

final NumberFormat _usdFormat = NumberFormat('#,##0.00', 'en_US');

/// `28.25` -> `"28.25"` (prefix the `$` at the call site).
String formatReceiptUsd(num value) => _usdFormat.format(value);

/// A single line item pulled off the receipt.
class ReceiptLineItem {
  const ReceiptLineItem({
    required this.name,
    required this.amountUsd,
    this.quantity = 1,
  });

  final String name;
  final double amountUsd;
  final int quantity;
}

/// The full result of a (simulated) receipt scan.
class ScannedReceipt {
  const ScannedReceipt({
    required this.merchant,
    required this.location,
    required this.dateLabel,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.items,
    required this.subtotalUsd,
    required this.taxUsd,
    required this.taxLabel,
  });

  final String merchant;
  final String location;
  final String dateLabel;

  final String categoryLabel;
  final IconData categoryIcon;

  final List<ReceiptLineItem> items;

  final double subtotalUsd;
  final double taxUsd;
  final String taxLabel;

  double get totalUsd => subtotalUsd + taxUsd;

  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  static const ScannedReceipt sample = ScannedReceipt(
    merchant: 'Lucky Supermarket',
    location: 'Sihanouk Blvd, Phnom Penh',
    dateLabel: '19 Jul 2026 · 14:32',
    categoryLabel: 'Groceries',
    categoryIcon: LucideIcons.shoppingCart,
    items: [
      ReceiptLineItem(name: 'Jasmine Rice 5kg', amountUsd: 8.50),
      ReceiptLineItem(name: 'Fresh Milk 1L', amountUsd: 3.60, quantity: 2),
      ReceiptLineItem(name: 'Angkor Beer 6-pack', amountUsd: 6.00),
      ReceiptLineItem(name: 'Fresh Vegetables', amountUsd: 4.25),
      ReceiptLineItem(name: 'Cooking Oil 2L', amountUsd: 5.90),
    ],
    subtotalUsd: 28.25,
    taxUsd: 2.83,
    taxLabel: 'VAT (10%)',
  );
}
