import 'package:dio/dio.dart';
import 'dart:developer';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this.dio);

  final Dio dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Scaffold retry logic if applicable
    log('RetryInterceptor: Captured error for ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}
