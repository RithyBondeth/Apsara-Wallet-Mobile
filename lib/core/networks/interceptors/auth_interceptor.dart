import 'package:apsara_wallet_mobile/core/networks/dio_client.dart';
import 'package:apsara_wallet_mobile/core/storage/token_storage.dart';
import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Attaches the bearer token to outgoing requests and transparently refreshes
/// it on a `401`, retrying the original request once. If the refresh itself
/// fails, the session is cleared and the app is told to sign out.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.ref);

  final Ref ref;

  /// Marks a request that has already been retried after a refresh, so a
  /// second `401` can't spin into an infinite refresh loop.
  static const _retriedFlag = 'auth_retried';

  bool _isAuthPath(String path) => path.contains('/auth/');

  TokenStorage get _storage => ref.read(tokenStorageProvider);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Auth endpoints (login/register/refresh/logout) don't need — and
    // shouldn't depend on — a bearer token.
    if (!_isAuthPath(options.path)) {
      final token = await _storage.readAccessToken();
      if (token != null && !options.headers.containsKey('Authorization')) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final options = err.requestOptions;
    final canRetry = response?.statusCode == 401 &&
        !_isAuthPath(options.path) &&
        options.extra[_retriedFlag] != true;

    if (!canRetry) {
      return handler.next(err);
    }

    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) {
      _signOut();
      return handler.next(err);
    }

    // Use a bare Dio (no interceptors) so refresh + retry can't recurse
    // through this interceptor.
    final bare = Dio(BaseOptions(baseUrl: resolveApiBaseUrl()));
    try {
      final refreshRes = await bare.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = refreshRes.data;
      final newAccess = data?['accessToken'] as String?;
      final newRefresh = data?['refreshToken'] as String?;
      if (newAccess == null || newRefresh == null) {
        _signOut();
        return handler.next(err);
      }

      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      options
        ..headers['Authorization'] = 'Bearer $newAccess'
        ..extra[_retriedFlag] = true;
      final retried = await bare.fetch<dynamic>(options);
      return handler.resolve(retried);
    } on DioException {
      _signOut();
      return handler.next(err);
    } finally {
      bare.close(force: true);
    }
  }

  void _signOut() {
    // Clear persisted tokens and flip app state; the router guard reacts and
    // bounces to the login screen.
    _storage.clear();
    ref.read(authControllerProvider.notifier).onSessionExpired();
  }
}
