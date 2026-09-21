import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// Turns a raw API error string into copy for the current language.
///
/// Error text reaches the UI as a plain string from two places: messages the
/// NestJS backend returns in its error body ("Invalid email or password",
/// "Wallet not found", …) and the client-side transport messages
/// [ApiException] produces ("No Internet connection", "Not found"). Both are
/// English. Known strings map to a localized line here; an unknown server
/// message is shown as-is only when the UI is in English, otherwise it falls
/// back to the generic line so a Khmer user never sees raw English.
String localizedApiError(AppLocalizations l10n, String? raw) {
  final key = raw?.trim();
  if (key == null || key.isEmpty) return l10n.apiErrorGeneric;
  final known = _known[key];
  if (known != null) return known(l10n);
  return l10n.localeName == 'en' ? key : l10n.apiErrorGeneric;
}

typedef _Resolver = String Function(AppLocalizations l10n);

final Map<String, _Resolver> _known = {
  // Backend (see the API's *Exception('…') messages).
  'Invalid email or password': (l) => l.apiErrorInvalidCredentials,
  'Email already registered': (l) => l.apiErrorEmailTaken,
  'Incorrect password': (l) => l.apiErrorIncorrectPassword,
  'Incorrect current password': (l) => l.changePasswordWrongCurrent,
  'Invalid refresh token': (l) => l.authSessionExpired,
  'Invalid reset token': (l) => l.apiErrorInvalidResetToken,
  'Invalid or expired reset token': (l) => l.apiErrorInvalidResetToken,
  'User not found': (l) => l.apiErrorNotFound,
  'Wallet not found': (l) => l.apiErrorNotFound,
  'Category not found': (l) => l.apiErrorNotFound,
  'Transaction not found': (l) => l.apiErrorNotFound,
  'Budget not found': (l) => l.apiErrorNotFound,
  'Savings goal not found': (l) => l.apiErrorNotFound,
  'Recurring rule not found': (l) => l.apiErrorNotFound,
  'Notification not found': (l) => l.apiErrorNotFound,
  'Insufficient balance in source wallet': (l) => l.apiErrorInsufficientBalance,
  'Cannot transfer to the same wallet': (l) => l.apiErrorSameWallet,
  'Both wallets must be your own': (l) => l.apiErrorNotYourWallet,
  'Reorder list must be your own wallets': (l) => l.apiErrorNotYourWallet,
  'System categories cannot be modified': (l) => l.apiErrorSystemCategory,
  'System categories cannot be deleted': (l) => l.apiErrorSystemCategory,
  // Client transport (ApiException).
  'No Internet connection': (l) => l.apiErrorOffline,
  'Connection timeout with API server': (l) => l.apiErrorTimeout,
  'Receive timeout in connection with API server': (l) => l.apiErrorTimeout,
  'Send timeout in connection with API server': (l) => l.apiErrorTimeout,
  'Request to API server was cancelled': (l) => l.apiErrorGeneric,
  'Bad Certificate': (l) => l.apiErrorGeneric,
  'Unexpected error occurred': (l) => l.apiErrorGeneric,
  'Bad request': (l) => l.apiErrorGeneric,
  'Unauthorized': (l) => l.authSessionExpired,
  'Forbidden': (l) => l.apiErrorGeneric,
  'Not found': (l) => l.apiErrorNotFound,
  'Conflict': (l) => l.apiErrorGeneric,
  'Validation Error': (l) => l.apiErrorGeneric,
  'Internal server error': (l) => l.apiErrorServer,
  'Bad gateway': (l) => l.apiErrorServer,
  'Oops something went wrong': (l) => l.apiErrorGeneric,
};
