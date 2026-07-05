enum Environment { dev, staging, prod }

class AppEnvironmentConfig {
  static Environment _environment = Environment.dev;
  static Environment get environment => _environment;

  static void setEnvironment(Environment env) => _environment = env;

  static String get envFileName {
    switch (_environment) {
      case Environment.dev:
        return '.env.dev';
      case Environment.staging:
        return '.env.staging';
      case Environment.prod:
        return '.env.prod';
    }
  }

  static bool get isDevelopment => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.prod;
}
