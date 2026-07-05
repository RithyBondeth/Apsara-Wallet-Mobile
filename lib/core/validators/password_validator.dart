import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';

class PasswordValidator {
  PasswordValidator._();

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password is too long';
    }

    return null;
  }
}
