class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  /// HTTP status code when known (from the response or a bad-response error).
  /// Null for transport-level failures (timeout, no connection).
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });
}
