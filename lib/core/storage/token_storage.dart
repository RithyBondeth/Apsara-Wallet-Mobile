import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the auth session (JWT pair + a small cached user blob) in the
/// platform secure store — Keychain on iOS, EncryptedSharedPreferences on
/// Android — so tokens survive app restarts without touching plain prefs.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kUser = 'auth_user';

  Future<String?> readAccessToken() => _storage.read(key: _kAccess);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);
  Future<String?> readUser() => _storage.read(key: _kUser);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
  }

  Future<void> saveUser(String userJson) =>
      _storage.write(key: _kUser, value: userJson);

  /// Wipes the whole session — used on logout and when a refresh fails.
  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUser);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  // Android encryption is on by default in this version (the old
  // `encryptedSharedPreferences` flag is deprecated); iOS uses the Keychain.
  return TokenStorage(const FlutterSecureStorage());
});
