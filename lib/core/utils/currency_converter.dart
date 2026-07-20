import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';

/// Converts between the currencies the app accepts and its storage unit (KHR).
///
/// Every transaction is persisted in whole riel (`amountKhr`), so a USD entry
/// must be converted on the way in. We use a fixed reference rate rather than a
/// live feed to keep the app fully offline; swap [khrPerUsd] for a fetched rate
/// if/when a backend exists. The default (~NBC reference) also matches the
/// KHR/USD figures the app already displays elsewhere.
class CurrencyConverter {
  CurrencyConverter._();

  /// Riel per US dollar. Approximate, fixed reference rate.
  static const int khrPerUsd = 4100;

  /// Converts a US-dollar amount to whole riel.
  static int usdToKhr(double usd) => (usd * khrPerUsd).round();

  /// Converts whole riel to US dollars.
  static double khrToUsd(int khr) => khr / khrPerUsd;

  /// Normalises an amount entered in [currency] into the stored riel unit.
  /// KHR is taken as-is (rounded); USD is converted via [usdToKhr].
  static int toKhr(double amount, ECurrencyType currency) =>
      currency == ECurrencyType.usd ? usdToKhr(amount) : amount.round();
}
