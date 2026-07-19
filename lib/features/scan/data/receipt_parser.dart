import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/features/scan/data/scanned_receipt.dart';

/// Turns the raw, top-to-bottom text lines of a receipt (as produced by OCR)
/// into a structured [ScannedReceipt].
///
/// Receipts have no standard layout, so this is a best-effort heuristic pass:
/// the merchant is taken from the header, the total from keyword lines, and
/// line items from rows that end in a price. Kept as pure Dart (no ML Kit
/// types) so the logic is unit-testable without a device.
class ReceiptParser {
  ReceiptParser._();

  // A monetary amount: 1,234.56 / 1.234,56 / 12000 / 3.60 …
  static final RegExp _amount = RegExp(
    r'(?<![\w.,])(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?)(?![\w])',
  );

  static final RegExp _letters = RegExp(r'[A-Za-zក-៿]');

  // Common receipt date formats.
  static final List<RegExp> _dateRes = [
    RegExp(r'\b(\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4})\b'),
    RegExp(r'\b(\d{4}[/\-.]\d{1,2}[/\-.]\d{1,2})\b'),
    RegExp(
      r'\b(\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?\s+\d{2,4})\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?\s+\d{1,2},?\s+\d{2,4})\b',
      caseSensitive: false,
    ),
  ];

  static const List<String> _totalKeys = [
    'grand total',
    'total due',
    'amount due',
    'balance due',
    'total amount',
    'total',
    'amount',
    'balance',
  ];

  // Rows that look like line items but are really summary/footer lines.
  static const List<String> _excludeItemKeys = [
    'total',
    'subtotal',
    'sub total',
    'tax',
    'vat',
    'gst',
    'change',
    'cash',
    'card',
    'balance',
    'amount',
    'tender',
    'due',
    'discount',
    'rounding',
    'payment',
    'visa',
    'mastercard',
    'qty',
  ];

  static const Map<String, ({String label, IconData icon})> _categoryRules = {
    'supermarket': (label: 'Groceries', icon: LucideIcons.shoppingCart),
    'market': (label: 'Groceries', icon: LucideIcons.shoppingCart),
    'grocery': (label: 'Groceries', icon: LucideIcons.shoppingCart),
    'mart': (label: 'Groceries', icon: LucideIcons.shoppingCart),
    'restaurant': (label: 'Dining', icon: LucideIcons.utensils),
    'cafe': (label: 'Dining', icon: LucideIcons.coffee),
    'coffee': (label: 'Dining', icon: LucideIcons.coffee),
    'kitchen': (label: 'Dining', icon: LucideIcons.utensils),
    'pharmacy': (label: 'Health', icon: LucideIcons.pill),
    'clinic': (label: 'Health', icon: LucideIcons.stethoscope),
    'petrol': (label: 'Fuel', icon: LucideIcons.fuel),
    'station': (label: 'Fuel', icon: LucideIcons.fuel),
    'fuel': (label: 'Fuel', icon: LucideIcons.fuel),
    'mall': (label: 'Shopping', icon: LucideIcons.shoppingBag),
    'store': (label: 'Shopping', icon: LucideIcons.shoppingBag),
    'shop': (label: 'Shopping', icon: LucideIcons.shoppingBag),
  };

  /// Parse ordered [rawLines] (top-to-bottom) into a receipt. Returns an
  /// [ScannedReceipt] with whatever could be extracted; unfilled fields fall
  /// back to blanks for the user to complete.
  static ScannedReceipt parse(List<String> rawLines) {
    final lines = rawLines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return ScannedReceipt.empty();

    final joined = lines.join('\n');
    final currency = _detectCurrency(joined);

    final merchant = _findMerchant(lines);
    final dateLabel = _findDate(joined);
    final total = _findKeyedAmount(lines, _totalKeys) ?? _largestAmount(lines);
    final subtotal = _findKeyedAmount(lines, const ['subtotal', 'sub total']);
    final taxLine = _findTaxLine(lines);
    final items = _findItems(lines);
    final category = _inferCategory(merchant, joined);

    return ScannedReceipt(
      merchant: merchant ?? '',
      dateLabel: dateLabel ?? '',
      categoryLabel: category.label,
      categoryIcon: category.icon,
      items: items,
      total: total ?? 0,
      subtotal: subtotal,
      tax: taxLine?.amount,
      taxLabel: taxLine?.label ?? 'Tax',
      currency: currency,
    );
  }

  // --- helpers --------------------------------------------------------------

  static ECurrencyType _detectCurrency(String text) {
    final lower = text.toLowerCase();
    if (text.contains('៛') || lower.contains('khr') || lower.contains('riel')) {
      // A '$' anywhere usually means the total is still in USD.
      if (!text.contains(r'$') && !lower.contains('usd')) {
        return ECurrencyType.khr;
      }
    }
    return ECurrencyType.usd;
  }

  static String? _findMerchant(List<String> lines) {
    // First header line that is mostly text (not a phone number / address /
    // date) — merchants print their name at the very top.
    for (final line in lines.take(4)) {
      final letters = _letters.allMatches(line).length;
      final digits = RegExp(r'\d').allMatches(line).length;
      if (letters >= 3 && letters >= digits && !_looksLikeDate(line)) {
        return _titleCaseIfShouting(line);
      }
    }
    return _titleCaseIfShouting(lines.first);
  }

  static bool _looksLikeDate(String line) =>
      _dateRes.any((re) => re.hasMatch(line));

  static String _titleCaseIfShouting(String s) {
    final letters = _letters.allMatches(s);
    final upper = RegExp(r'[A-Z]').allMatches(s).length;
    // Preserve mixed case; only gently normalise ALL-CAPS headers.
    if (letters.isNotEmpty && upper == letters.length && s.length > 3) {
      return s
          .split(RegExp(r'\s+'))
          .map(
            (w) => w.isEmpty
                ? w
                : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
          )
          .join(' ');
    }
    return s;
  }

  static String? _findDate(String text) {
    for (final re in _dateRes) {
      final m = re.firstMatch(text);
      if (m != null) return m.group(1);
    }
    return null;
  }

  static double? _findKeyedAmount(List<String> lines, List<String> keys) {
    // Search bottom-up: totals live near the end.
    for (var i = lines.length - 1; i >= 0; i--) {
      final lower = lines[i].toLowerCase();
      if (keys.any((k) => lower.contains(k))) {
        final amt = _lastAmountIn(lines[i]);
        // Amount sometimes sits on the following line.
        if (amt != null) return amt;
        if (i + 1 < lines.length) {
          final next = _lastAmountIn(lines[i + 1]);
          if (next != null) return next;
        }
      }
    }
    return null;
  }

  static ({String label, double amount})? _findTaxLine(List<String> lines) {
    const taxKeys = ['vat', 'tax', 'gst'];
    for (var i = lines.length - 1; i >= 0; i--) {
      final lower = lines[i].toLowerCase();
      if (taxKeys.any((k) => lower.contains(k))) {
        final amt = _lastAmountIn(lines[i]);
        if (amt != null) {
          final label = lower.contains('vat')
              ? 'VAT'
              : lower.contains('gst')
              ? 'GST'
              : 'Tax';
          return (label: label, amount: amt);
        }
      }
    }
    return null;
  }

  static List<ReceiptLineItem> _findItems(List<String> lines) {
    final items = <ReceiptLineItem>[];
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (_excludeItemKeys.any((k) => lower.contains(k))) continue;
      if (_looksLikePhone(line)) continue;

      final matches = _amount.allMatches(line).toList();
      if (matches.isEmpty) continue;
      // The price is the last amount on the line; strip only that, so numbers
      // inside the name ("6-pack", "1L") survive.
      final price = matches.last;
      final amt = _toDouble(price.group(1)!);
      if (amt == null || amt == 0) continue;

      var name = line.substring(0, price.start).trim();
      name = name.replaceAll(RegExp(r'[\s.·:x*@-]+$'), '').trim();

      // Detect a quantity like "2 x" or "x2" and lift it off the name.
      var quantity = 1;
      final qtyMatch = RegExp(
        r'(?:^|\s)(\d{1,2})\s*[xX*]\b|\b[xX](\d{1,2})\b',
      ).firstMatch(name);
      if (qtyMatch != null) {
        quantity =
            int.tryParse(qtyMatch.group(1) ?? qtyMatch.group(2) ?? '1') ?? 1;
        name = name.replaceAll(qtyMatch.group(0)!, '').trim();
      }

      if (name.isEmpty || _letters.allMatches(name).length < 2) continue;
      items.add(ReceiptLineItem(name: name, amount: amt, quantity: quantity));
    }
    return items;
  }

  // A phone/reference number: a long run of digits (with spaces/dashes) that
  // isn't a price. Keeps "Tel: 023 123 456" out of the item list.
  static bool _looksLikePhone(String line) =>
      RegExp(r'\d[\d\s.\-]{6,}\d').hasMatch(line) &&
      !RegExp(r'\d[.,]\d{2}\b').hasMatch(line);

  static ({String label, IconData icon}) _inferCategory(
    String? merchant,
    String fullText,
  ) {
    final haystack = '${merchant ?? ''}\n$fullText'.toLowerCase();
    for (final entry in _categoryRules.entries) {
      if (haystack.contains(entry.key)) {
        return (label: entry.value.label, icon: entry.value.icon);
      }
    }
    return (label: 'Uncategorised', icon: LucideIcons.receipt);
  }

  static double? _largestAmount(List<String> lines) {
    double? best;
    for (final line in lines) {
      for (final m in _amount.allMatches(line)) {
        final v = _toDouble(m.group(1)!);
        if (v != null && (best == null || v > best)) best = v;
      }
    }
    return best;
  }

  static double? _lastAmountIn(String line) {
    double? last;
    for (final m in _amount.allMatches(line)) {
      final v = _toDouble(m.group(1)!);
      if (v != null) last = v;
    }
    return last;
  }

  /// Normalises `1,234.56` / `1.234,56` / `12 000` into a double.
  static double? _toDouble(String raw) {
    var s = raw.trim();
    final hasComma = s.contains(',');
    final hasDot = s.contains('.');
    if (hasComma && hasDot) {
      // The last separator is the decimal point.
      if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        s = s.replaceAll(',', '');
      }
    } else if (hasComma) {
      // Comma as decimals only when it precedes 1-2 trailing digits.
      s = RegExp(r',\d{1,2}$').hasMatch(s)
          ? s.replaceAll(',', '.')
          : s.replaceAll(',', '');
    }
    return double.tryParse(s);
  }
}
