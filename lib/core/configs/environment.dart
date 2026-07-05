import 'package:apsara_wallet_mobile/core/enums/environment_enum.dart';

class AppEnvironmentConfig {
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
