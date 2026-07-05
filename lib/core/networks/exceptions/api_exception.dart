import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return ApiException('Request to API server was cancelled');
      case DioExceptionType.connectionTimeout:
        return ApiException('Connection timeout with API server');
      case DioExceptionType.receiveTimeout:
        return ApiException('Receive timeout in connection with API server');
      case DioExceptionType.sendTimeout:
        return ApiException('Send timeout in connection with API server');
      case DioExceptionType.connectionError:
        return ApiException('No Internet connection');
      case DioExceptionType.badCertificate:
        return ApiException('Bad Certificate');
      case DioExceptionType.badResponse:
        return ApiException(
          _handleError(
            dioException.response?.statusCode,
            dioException.response?.data,
          ),
        );
      case DioExceptionType.unknown:
        return ApiException('Unexpected error occurred');
      case DioExceptionType.transformTimeout:
        throw UnimplementedError();
    }
  }

  static String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        if (error != null && error is Map && error.containsKey('message')) {
          return error['message'].toString();
        }
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 422:
        if (error != null && error is Map && error.containsKey('message')) {
          return error['message'].toString();
        }
        return 'Validation Error';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      default:
        return 'Oops something went wrong';
    }
  }
}
