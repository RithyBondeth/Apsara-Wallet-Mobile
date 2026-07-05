class StorageKeys {
  StorageKeys._();

  // ==================================================
  // AUTH
  // ==================================================
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';

  // ==================================================
  // SECURITY
  // ==================================================
  static const String pinCode = 'pin_code';
  static const String biometricEnabled = 'biometric_enabled';
  static const String isLoggedIn = 'is_logged_in';

  // ==================================================
  // USER DATA
  // ==================================================
  static const String userProfile = 'user_profile';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';

  // ==================================================
  // APP SETTINGS
  // ==================================================
  static const String themeMode = 'theme_mode';
  static const String language = 'language';

  // ==================================================
  // WALLET
  // ==================================================
  static const String walletBalance = 'wallet_balance';
  static const String selectedCurrency = 'selected_currency';

  // ==================================================
  // CACHE
  // ==================================================
  static const String cachedTransactions = 'cached_transactions';
  static const String lastSyncTime = 'last_sync_time';
}
