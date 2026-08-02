import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/core/providers/currency_provider.dart';
import 'package:apsara_wallet_mobile/core/providers/fx_rate_provider.dart';

/// Formats riel-denominated amounts in the user's chosen display currency.
///
/// All amounts in the app are stored in KHR. When KHR is selected the output
/// is `KHR 12,000` (identical to the app's long-standing format, so existing
/// layouts/goldens are unchanged). When USD is selected the amount is converted
/// with the live rate and shown as `$2.93`.
class MoneyFormatter {
  MoneyFormatter({required this.currency, required this.khrPerUsd});

  final ECurrencyType currency;
  final double khrPerUsd;

  static final NumberFormat _khr = NumberFormat.decimalPattern('en_US');
  static final NumberFormat _usd = NumberFormat('#,##0.00', 'en_US');

  /// Formats [amountKhr] (a riel amount) with a currency code/symbol prefix.
  String format(num amountKhr) {
    if (currency == ECurrencyType.usd) {
      final usd = khrPerUsd <= 0 ? 0 : amountKhr / khrPerUsd;
      return '\$${_usd.format(usd)}';
    }
    return 'KHR ${_khr.format(amountKhr)}';
  }

  /// Just the grouped number, no currency prefix (for compact chart labels).
  String number(num amountKhr) {
    if (currency == ECurrencyType.usd) {
      final usd = khrPerUsd <= 0 ? 0 : amountKhr / khrPerUsd;
      return _usd.format(usd);
    }
    return _khr.format(amountKhr);
  }

  /// Currency code/symbol shown alongside [number] when split rendering is used.
  String get code => currency == ECurrencyType.usd ? '\$' : 'KHR';
}

/// The active formatter, rebuilt when the currency choice or FX rate changes.
final moneyFormatterProvider = Provider<MoneyFormatter>((ref) {
  return MoneyFormatter(
    currency: ref.watch(currencyProvider),
    khrPerUsd: ref.watch(khrPerUsdProvider),
  );
});
