import 'package:apsara_wallet_mobile/core/configs/config_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  return createDio(ref);
});

Dio createDio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfigService.apiBaseURL,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([LoggerInterceptor(), AuthInterceptor(ref)]);

  return dio;
}
