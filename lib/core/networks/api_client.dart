import 'package:apsara_wallet_mobile/core/networks/exceptions/api_exception.dart';
import 'package:apsara_wallet_mobile/core/networks/models/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<T>(path, queryParameters: query);
      return ApiResponse<T>(
        success: true,
        message: 'Success',
        data: response.data,
      );
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      return ApiResponse<T>(success: false, message: error.message);
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.post<T>(path, data: data);
      return ApiResponse<T>(
        success: true,
        message: 'Success',
        data: response.data,
      );
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      return ApiResponse<T>(success: false, message: error.message);
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<T>> put<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.put<T>(path, data: data);
      return ApiResponse<T>(
        success: true,
        message: 'Success',
        data: response.data,
      );
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      return ApiResponse<T>(success: false, message: error.message);
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<T>> patch<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch<T>(path, data: data);
      return ApiResponse<T>(
        success: true,
        message: 'Success',
        data: response.data,
      );
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      return ApiResponse<T>(success: false, message: error.message);
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(String path) async {
    try {
      final response = await _dio.delete<T>(path);
      return ApiResponse<T>(
        success: true,
        message: 'Success',
        data: response.data,
      );
    } on DioException catch (e) {
      final error = ApiException.fromDioException(e);
      return ApiResponse<T>(success: false, message: error.message);
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString());
    }
  }
}
