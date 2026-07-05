class AmountValidator {
  AmountValidator._();

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);

    if (amount == null) {
      return 'Enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }
}
