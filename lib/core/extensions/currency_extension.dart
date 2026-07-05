import 'package:intl/intl.dart';

extension CurrencyExtension on num {
  String toUSD() {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(this);
  }

  String toKHR() {
    return NumberFormat.currency(
      locale: 'km_KH',
      symbol: '៛',
      decimalDigits: 0,
    ).format(this);
  }
}
