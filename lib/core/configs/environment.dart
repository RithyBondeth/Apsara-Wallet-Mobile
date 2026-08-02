import 'package:apsara_wallet_mobile/core/enums/environment_enum.dart';

class AppEnvironmentConfig {
  AppEnvironmentConfig._();

  /// Environment chosen at build time:
  ///
  ///     flutter build appbundle --release --dart-define=ENV=prod
  ///
  /// Defaults to `dev` so a plain `flutter run` still points at the local
  /// backend. Release builds MUST pass `--dart-define` — see RELEASE.md.
  static const String _envFromBuild =
      String.fromEnvironment('ENV', defaultValue: 'dev');

  /// Parses the `ENV` dart-define, falling back to [EEnvironmentType.dev] for
  /// an unrecognised value rather than throwing at startup.
  static EEnvironmentType get buildEnvironment => switch (_envFromBuild) {
        'prod' || 'production' => EEnvironmentType.prod,
        'staging' || 'stg' => EEnvironmentType.staging,
        _ => EEnvironmentType.dev,
      };

  static EEnvironmentType _environment = EEnvironmentType.dev;
  static EEnvironmentType get environment => _environment;

  static void setEnvironment(EEnvironmentType env) => _environment = env;

  static String get envFileName {
    switch (_environment) {
      case EEnvironmentType.dev:
        return '.env.dev';
      case EEnvironmentType.staging:
        return '.env.staging';
      case EEnvironmentType.prod:
        return '.env.prod';
    }
  }

  static bool get isDevelopment => _environment == EEnvironmentType.dev;
  static bool get isStaging => _environment == EEnvironmentType.staging;
  static bool get isProduction => _environment == EEnvironmentType.prod;
}
