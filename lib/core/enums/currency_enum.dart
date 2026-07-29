enum ECurrencyType {
  usd,
  khr;

  /// Stable storage/code value ('usd' | 'khr').
  String get code => name;

  /// Currency symbol used in money labels.
  String get symbol => this == ECurrencyType.usd ? '\$' : '៛';

  /// Short label for pickers.
  String get label => this == ECurrencyType.usd ? 'USD' : 'KHR';

  /// Parses a stored code, defaulting to KHR (the app's base currency).
  static ECurrencyType fromCode(String? code) {
    return code == ECurrencyType.usd.code
        ? ECurrencyType.usd
        : ECurrencyType.khr;
  }
}
