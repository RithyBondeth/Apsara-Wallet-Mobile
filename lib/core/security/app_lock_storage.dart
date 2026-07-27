import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the app-lock configuration in the platform secure store: the PIN
/// salt/hash, whether biometric unlock is enabled, and the re-lock timeout.
class AppLockStorage {
  AppLockStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _kPinHash = 'lock_pin_hash';
  static const _kPinSalt = 'lock_pin_salt';
  static const _kBiometric = 'lock_biometric_enabled';
  static const _kTimeout = 'lock_bg_timeout_seconds';

  Future<String?> readPinHash() => _storage.read(key: _kPinHash);
  Future<String?> readPinSalt() => _storage.read(key: _kPinSalt);

  Future<bool> isPinSet() async => (await readPinHash()) != null;

  Future<void> savePin({required String hash, required String salt}) async {
    await _storage.write(key: _kPinHash, value: hash);
    await _storage.write(key: _kPinSalt, value: salt);
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _kPinHash);
    await _storage.delete(key: _kPinSalt);
  }

  Future<bool> readBiometricEnabled() async =>
      (await _storage.read(key: _kBiometric)) == 'true';

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _kBiometric, value: enabled ? 'true' : 'false');

  /// Seconds the app may sit in the background before it re-locks. Defaults to
  /// 30s when unset.
  Future<int> readBackgroundTimeout() async {
    final raw = await _storage.read(key: _kTimeout);
    return int.tryParse(raw ?? '') ?? 30;
  }

  Future<void> setBackgroundTimeout(int seconds) =>
      _storage.write(key: _kTimeout, value: '$seconds');

  /// Full reset — used when the user turns app-lock off entirely.
  Future<void> clearAll() async {
    await clearPin();
    await _storage.delete(key: _kBiometric);
    await _storage.delete(key: _kTimeout);
  }
}

final appLockStorageProvider = Provider<AppLockStorage>((ref) {
  return AppLockStorage(const FlutterSecureStorage());
});
