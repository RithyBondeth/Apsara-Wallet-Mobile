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
    // Prefer the server's own message when present — NestJS returns
    // `{ statusCode, message, error }` where `message` is a string (e.g.
    // "Invalid email or password", "Email already registered") or, for
    // validation failures, a list of strings.
    final serverMessage = _extractMessage(error);
    if (serverMessage != null) return serverMessage;

    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Validation Error';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      default:
        return 'Oops something went wrong';
    }
  }

  /// Pulls a human-readable message out of a NestJS error body, handling both
  /// the string and string-list shapes of `message`.
  static String? _extractMessage(dynamic error) {
    if (error is! Map || !error.containsKey('message')) return null;
    final message = error['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) {
      return message.map((e) => e.toString()).join('\n');
    }
    return null;
  }
}
