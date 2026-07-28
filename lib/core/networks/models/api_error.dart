class ApiError {
  final int? statusCode;
  final String message;
  final dynamic details;

  ApiError({this.statusCode, required this.message, this.details});
}
