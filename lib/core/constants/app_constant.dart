class AppConstants {
  AppConstants._();

  // =========================
  // APP INFO
  // =========================
  static const String appName = 'Apsara Wallet';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Digital Expense Tracker';

  /// Support / legal contact address (shown at the foot of legal pages).
  static const String supportEmail = 'support@apsarawallet.app';

  // =========================
  // STORE LISTINGS (Rate the app)
  // =========================
  // NOTE: placeholder bundle ids — update once the app is published so the
  // "Rate" action deep-links to the real store listings.
  static const String androidPackageId = 'com.example.apsara_wallet_mobile';
  static const String iosAppId = '000000000';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageId';
  static const String appStoreUrl =
      'https://apps.apple.com/app/id$iosAppId';

  // =========================
  // TIME CONFIG
  // =========================
  static const int splashDuration = 2;
  static const int apiTimeoutSeconds = 30;
  static const int resendOtpSeconds = 60;

  // =========================
  // AUTH CONFIG
  // =========================
  static const int otpLength = 6;
  static const int pinLength = 6;
  static const int maxLoginAttempts = 5;
  static const int sessionTimeoutMinutes = 15;

  // =========================
  // PASSWORD RULES
  // =========================
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;

  // =========================
  // PAGINATION
  // =========================
  static const int defaultPageSize = 20;
  static const int transactionPageSize = 30;

  // =========================
  // CURRENCY / FINANCE
  // =========================
  static const String defaultCurrency = 'USD';
  static const String secondaryCurrency = 'KHR';

  static const double minTransferAmount = 0.01;
  static const double maxTransferAmount = 10000.0;

  // =========================
  // BIOMETRIC
  // =========================
  static const String biometricReason =
      'Authenticate to access Apsara Wallet securely';

  static const int biometricTimeoutSeconds = 30;

  // =========================
  // CACHE CONFIG
  // =========================
  static const int cacheExpirationMinutes = 10;
  static const int maxCachedTransactions = 100;

  // =========================
  // NETWORK
  // =========================
  static const int maxRetryAttempts = 3;
  static const int retryDelayMilliseconds = 1500;

  // =========================
  // UI CONFIG
  // =========================
  static const double defaultBorderRadius = 12;
  static const double defaultPadding = 16;
  static const double cardElevation = 2;

  // =========================
  // FILE / MEDIA
  // =========================
  static const int maxImageSizeMB = 5;
  static const int maxProfileImageSizeMB = 2;

  // =========================
  // NOTIFICATIONS
  // =========================
  static const bool enablePushNotifications = true;

  // =========================
  // SECURITY
  // =========================
  static const bool enableBiometricLogin = true;
  static const bool enablePinLogin = true;
}
