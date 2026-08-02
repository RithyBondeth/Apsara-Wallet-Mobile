import 'dart:async';

import 'package:apsara_wallet_mobile/core/configs/config_service.dart';
import 'package:apsara_wallet_mobile/core/configs/environment.dart';
import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/enums/environment_enum.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Crash and error reporting, wired to Sentry.
///
/// Reporting is opt-in per environment: it runs only when `SENTRY_DSN` is set
/// in the loaded `.env`. With no DSN — every widget test, and any build whose
/// env file leaves the key blank — [runGuarded] just runs the app, so nothing
/// here can break a build that has not been given a project yet.
class CrashReporting {
  CrashReporting._();

  static bool get isEnabled => AppConfigService.sentryDsn.isNotEmpty;

  /// Runs [appRunner] with crash reporting installed when a DSN is present,
  /// and unchanged when it is not.
  static Future<void> runGuarded(FutureOr<void> Function() appRunner) async {
    if (!isEnabled) {
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = AppConfigService.sentryDsn;
        options.environment = _environmentName;

        // Groups issues by shipped version, so a regression is traceable to
        // the build that introduced it.
        options.release = 'apsara-wallet-mobile@${AppConstants.appVersion}';

        // This is a finance app: never let the SDK attach usernames, emails,
        // IP addresses or request bodies to an event.
        options.sendDefaultPii = false;

        // Crash reporting only. Performance tracing is a separate quota and
        // buys us little on an app this size — enable deliberately, later.
        options.tracesSampleRate = 0.0;

        // Breadcrumbs record the taps and navigations leading up to a crash,
        // but console output can carry balances and account names.
        options.enablePrintBreadcrumbs = false;

        // Full sampling in staging (few users, every crash matters), throttled
        // in production so a crash loop cannot exhaust the quota.
        options.sampleRate =
            AppEnvironmentConfig.isProduction ? 0.5 : 1.0;
      },
      appRunner: appRunner,
    );
  }

  static String get _environmentName =>
      switch (AppEnvironmentConfig.environment) {
        EEnvironmentType.prod => 'production',
        EEnvironmentType.staging => 'staging',
        EEnvironmentType.dev => 'development',
      };
}
