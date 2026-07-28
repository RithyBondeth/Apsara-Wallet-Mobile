import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';

/// A single line item read off a receipt. [amount] is the printed line total;
/// [quantity] is informational (shown as a badge when > 1).
class ReceiptLineItem {
  ReceiptLineItem({
    required this.name,
    required this.amount,
    this.quantity = 1,
  });

  String name;
  double amount;
  int quantity;
}

/// The structured result of an OCR receipt scan. Produced by
/// [ReceiptParser] and mutated in-place by the editable review sheet before
/// the user saves it.
class ScannedReceipt {
  ScannedReceipt({
    required this.merchant,
    this.location,
    required this.dateLabel,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.items,
    required this.total,
    this.subtotal,
    this.tax,
    this.taxLabel = 'Tax',
    this.currency = ECurrencyType.usd,
  });

  String merchant;
  String? location;
  String dateLabel;

  String categoryLabel;
  IconData categoryIcon;

  List<ReceiptLineItem> items;

  /// The authoritative amount printed on the receipt.
  double total;

  /// Optional detected breakdown — hidden when null.
  double? subtotal;
  double? tax;
  String taxLabel;

  ECurrencyType currency;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get hasBreakdown => subtotal != null || tax != null;

  static final NumberFormat _usd = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _khr = NumberFormat('#,##0', 'en_US');

  /// Formats [value] in this receipt's currency, e.g. `$31.08` or `12,000 ៛`.
  String formatMoney(num value) => currency == ECurrencyType.khr
      ? '${_khr.format(value)} ៛'
      : '\$${_usd.format(value)}';

  /// A blank receipt used when OCR finds nothing usable — the user fills it in.
  factory ScannedReceipt.empty() => ScannedReceipt(
    merchant: '',
    dateLabel: '',
    categoryLabel: 'Uncategorised',
    categoryIcon: LucideIcons.receipt,
    items: [],
    total: 0,
  );

  /// A representative fixture used as a graceful fallback (e.g. when running
  /// without a camera) and in tests.
  static ScannedReceipt get sample => ScannedReceipt(
    merchant: 'Lucky Supermarket',
    location: 'Sihanouk Blvd, Phnom Penh',
    dateLabel: '19 Jul 2026 · 14:32',
    categoryLabel: 'Groceries',
    categoryIcon: LucideIcons.shoppingCart,
    items: [
      ReceiptLineItem(name: 'Jasmine Rice 5kg', amount: 8.50),
      ReceiptLineItem(name: 'Fresh Milk 1L', amount: 3.60, quantity: 2),
      ReceiptLineItem(name: 'Angkor Beer 6-pack', amount: 6.00),
      ReceiptLineItem(name: 'Fresh Vegetables', amount: 4.25),
      ReceiptLineItem(name: 'Cooking Oil 2L', amount: 5.90),
    ],
    subtotal: 28.25,
    tax: 2.83,
    taxLabel: 'VAT (10%)',
    total: 31.08,
  );
}
