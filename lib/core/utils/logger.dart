import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void log(String message) {
    if (kDebugMode) {
      print('🪵 Apsara Wallet: $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
    }
  }
}
