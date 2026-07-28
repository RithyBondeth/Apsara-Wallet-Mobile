import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String usd(num value) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(value);
  }

  static String khr(num value) {
    return NumberFormat.currency(
      locale: 'km_KH',
      symbol: '៛',
      decimalDigits: 0,
    ).format(value);
  }
}
