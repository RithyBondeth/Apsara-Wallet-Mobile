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
  /// Matches `applicationId` in android/app/build.gradle.kts and the iOS
  /// PRODUCT_BUNDLE_IDENTIFIER. Permanent once published.
  static const String androidPackageId = 'com.apsarawallet.app';

  /// Sentinel meaning "no App Store record exists yet".
  static const String _unassignedIosAppId = '000000000';

  /// TODO(store): numeric App Store ID, assigned when the app record is first
  /// created in App Store Connect. Replace [_unassignedIosAppId] with it —
  /// [appStoreUrlOrNull] starts returning a real link the moment you do.
  static const String iosAppId = _unassignedIosAppId;

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageId';
  static const String appStoreUrl = 'https://apps.apple.com/app/id$iosAppId';

  /// Whether the app has a published App Store record to link to.
  static bool get hasAppStoreListing => iosAppId != _unassignedIosAppId;

  /// The App Store link, or null while the listing does not exist. Callers
  /// must skip the link rather than send the user to a dead store page.
  static String? get appStoreUrlOrNull =>
      hasAppStoreListing ? appStoreUrl : null;

  // =========================
  // CURRENCY
  // =========================
  /// Offline/last-resort USD→KHR rate (riel is a de-facto USD peg ~4100).
  /// The live rate comes from `GET /fx/rates`; this is only the fallback when
  /// the app has never reached the backend and has no cached rate.
  static const double defaultKhrPerUsd = 4100;

  // =========================
  // BIOMETRIC
  // =========================
  /// Prompt shown by the OS biometric sheet.
  static const String biometricReason =
      'Authenticate to access Apsara Wallet securely';

  // =========================
  // FEATURE FLAGS (no backend yet — keep hidden so the UI never shows a
  // control that only says "coming soon"; store reviewers flag those, and
  // Apple requires Sign in with Apple the moment Google sign-in is offered)
  // =========================
  /// Google / Facebook sign-in buttons on Login and Register.
  static const bool enableSocialLogin = false;

  /// Two-factor toggle on Security & Privacy.
  static const bool enableAccountSecurityExtras = false;
}
