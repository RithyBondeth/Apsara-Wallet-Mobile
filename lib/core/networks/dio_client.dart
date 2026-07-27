import 'dart:io' show Platform;

import 'package:apsara_wallet_mobile/core/configs/config_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  return createDio(ref);
});

Dio createDio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: resolveApiBaseUrl(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([LoggerInterceptor(), AuthInterceptor(ref)]);

  return dio;
}

/// The configured base URL, with a dev convenience: an Android emulator can't
/// reach the host machine over `localhost`/`127.0.0.1` — it must use the
/// special alias `10.0.2.2`. We rewrite it here so a single `.env` value works
/// across iOS simulator, Android emulator and web without per-dev edits.
String resolveApiBaseUrl() {
  final raw = AppConfigService.apiBaseURL;
  if (!kIsWeb && Platform.isAndroid) {
    return raw
        .replaceFirst('://localhost', '://10.0.2.2')
        .replaceFirst('://127.0.0.1', '://10.0.2.2');
  }
  return raw;
}
