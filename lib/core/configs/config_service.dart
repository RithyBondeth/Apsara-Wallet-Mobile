import 'package:apsara_wallet_mobile/core/configs/environment.dart';
import 'package:apsara_wallet_mobile/core/enums/environment_enum.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfigService {
  AppConfigService._();

  static Future<void> initialize(EEnvironmentType env) async {
    AppEnvironmentConfig.setEnvironment(env);
    await dotenv.load(fileName: AppEnvironmentConfig.envFileName);
  }

  /// Reads a key, tolerating an uninitialized dotenv (e.g. in widget tests
  /// that build screens without calling [initialize]) by returning [fallback]
  /// instead of throwing a `NotInitializedError`.
  static String _get(String key, String fallback) =>
      dotenv.isInitialized ? dotenv.get(key, fallback: fallback) : fallback;

  static String get appName => _get('APP_NAME', 'ApsaraWallet');
  static String get apiBaseURL => _get('API_BASE_URL', '');
  static bool get debugMode =>
      _get('DEBUG_MODE', 'false').toLowerCase() == 'true';
}
