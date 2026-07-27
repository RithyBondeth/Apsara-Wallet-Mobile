import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// Lightweight, deliberately permissive email check — the backend is the real
/// authority; this only catches obvious typos before a round-trip.
bool isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}

/// House error toast for the auth flow.
void showAuthSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
