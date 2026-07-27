import 'dart:convert';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/core/storage/token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_models.dart';

/// Raised when an auth call fails; [message] is already human-readable
/// (surfaced straight from the backend where possible).
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Talks to the backend `auth` endpoints and owns session persistence.
/// The UI never touches tokens directly — it goes through here.
class AuthRepository {
  AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final TokenStorage _storage;

  Future<AuthUser> register({
    required String email,
    required String fullName,
    required String password,
    String? phone,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'fullName': fullName,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    if (!res.success || res.data == null) {
      throw AuthException(res.message);
    }
    final tokens = AuthTokens.fromJson(res.data!);
    return _persistSession(tokens, fullName: fullName);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    if (!res.success || res.data == null) {
      throw AuthException(res.message);
    }
    final tokens = AuthTokens.fromJson(res.data!);
    return _persistSession(tokens);
  }

  /// Fetches the authoritative profile from `/auth/me` (bearer attached by the
  /// interceptor) and caches it. Returns null on failure — callers keep the
  /// token-derived user in that case. This is what makes the real name show
  /// after a plain login (the token alone carries only id + email).
  Future<AuthUser?> fetchProfile() async {
    final res = await _api.get<Map<String, dynamic>>('/auth/me');
    if (!res.success || res.data == null) return null;
    final data = res.data!;
    final id = data['id'];
    final email = data['email'];
    if (id is! String || email is! String) return null;
    final user = AuthUser(
      id: id,
      email: email,
      fullName: data['fullName'] as String?,
    );
    await _storage.saveUser(jsonEncode(user.toJson()));
    return user;
  }

  /// Best-effort server-side revocation, then always clears local state so the
  /// user is signed out even if the network call fails.
  Future<void> logout() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh != null) {
      await _api.post<Map<String, dynamic>>(
        '/auth/logout',
        data: {'refreshToken': refresh},
      );
    }
    await _storage.clear();
  }

  /// Rebuilds the session on app start. Returns the user when a usable token
  /// pair exists (refreshing a stale access token if needed), else null.
  Future<AuthUser?> restoreSession() async {
    final access = await _storage.readAccessToken();
    final refresh = await _storage.readRefreshToken();
    if (access == null || refresh == null) return null;

    if (!isJwtExpired(access)) {
      return _cachedOrDecodedUser(access);
    }

    // Access token is stale — try to rotate it with the refresh token.
    final rotated = await _tryRefresh(refresh);
    if (rotated == null) {
      await _storage.clear();
      return null;
    }
    return _cachedOrDecodedUser(rotated.accessToken);
  }

  Future<AuthTokens?> _tryRefresh(String refreshToken) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    if (!res.success || res.data == null) return null;
    final tokens = AuthTokens.fromJson(res.data!);
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  Future<AuthUser> _persistSession(AuthTokens tokens, {String? fullName}) async {
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    var user = AuthUser.fromAccessToken(tokens.accessToken) ??
        AuthUser(id: '', email: '', fullName: fullName);
    if (fullName != null) {
      user = user.copyWith(fullName: fullName);
    } else {
      // Keep a previously known display name if it belongs to this account.
      final cached = await _readCachedUser();
      if (cached != null && cached.email == user.email) {
        user = user.copyWith(fullName: cached.fullName);
      }
    }
    await _storage.saveUser(jsonEncode(user.toJson()));
    return user;
  }

  /// Prefer the cached user (it may carry a display name), falling back to what
  /// the token alone can tell us.
  Future<AuthUser> _cachedOrDecodedUser(String accessToken) async {
    final decoded = AuthUser.fromAccessToken(accessToken);
    final cached = await _readCachedUser();
    if (decoded != null &&
        cached != null &&
        cached.email == decoded.email &&
        cached.fullName != null) {
      return decoded.copyWith(fullName: cached.fullName);
    }
    return decoded ?? cached ?? const AuthUser(id: '', email: '');
  }

  Future<AuthUser?> _readCachedUser() async {
    final raw = await _storage.readUser();
    if (raw == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});
