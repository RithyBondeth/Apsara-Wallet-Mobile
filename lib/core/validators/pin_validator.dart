import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';

class PinValidator {
  PinValidator._();

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }

    if (value.length != AppConstants.pinLength) {
      return 'PIN must be ${AppConstants.pinLength} digits';
    }

    final regex = RegExp(r'^[0-9]+$');

    if (!regex.hasMatch(value)) {
      return 'PIN must contain only numbers';
    }

    return null;
  }
}
