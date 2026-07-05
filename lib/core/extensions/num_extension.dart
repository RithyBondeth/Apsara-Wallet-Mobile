extension NumExtension on num {
  String get currency {
    return '\$${toStringAsFixed(2)}';
  }
}
