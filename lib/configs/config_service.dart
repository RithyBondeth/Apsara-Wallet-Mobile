import 'package:apsara_wallet_mobile/configs/environment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfigService {
  static Future<void> initialize(Environment env) async {
    AppEnvironmentConfig.setEnvironment(env);
    await dotenv.load(fileName: AppEnvironmentConfig.envFileName);
  }

  static String get appName => dotenv.get('APP_NAME', fallback: 'ApsaraWallet');
  static String get apiBaseURL => dotenv.get('API_BASE_URL', fallback: '');
  static bool get debugMode =>
      dotenv.get('DEBUG_MODE', fallback: 'false').toLowerCase() == 'true';
}
