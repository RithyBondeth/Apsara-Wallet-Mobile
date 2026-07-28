class PhoneValidator {
  PhoneValidator._();

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final regex = RegExp(r'^[0-9]{8,15}$');

    if (!regex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }

    return null;
  }
}
