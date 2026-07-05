import 'package:apsara_wallet_mobile/core/storages/secure_storage_service.dart';
import 'package:apsara_wallet_mobile/core/storages/shared_prefs_service.dart';
import 'package:apsara_wallet_mobile/core/storages/storage_keys.dart';

class StorageManager {
  StorageManager(this._secureStorage, this._prefs);

  final SecureStorageService _secureStorage;
  final SharedPrefsService _prefs;

  // =====================
  // TOKEN
  // =====================
  Future<void> saveToken(String token) async {
    await _secureStorage.write(StorageKeys.accessToken, token);
  }

  Future<String?> getToken() {
    return _secureStorage.read(StorageKeys.accessToken);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(StorageKeys.accessToken);
  }

  // =====================
  // PIN
  // =====================
  Future<void> savePin(String pin) async {
    await _secureStorage.write(StorageKeys.pinCode, pin);
  }

  Future<String?> getPin() {
    return _secureStorage.read(StorageKeys.pinCode);
  }

  // =====================
  // BIOMETRIC
  // =====================
  Future<void> setBiometricEnabled(bool value) async {
    await _prefs.setBool(StorageKeys.biometricEnabled, value);
  }

  Future<bool> isBiometricEnabled() {
    return _prefs.getBool(StorageKeys.biometricEnabled);
  }

  // =====================
  // ONBOARDING
  // =====================
  Future<void> setOnboardingSeen() async {
    await _prefs.setBool(StorageKeys.onboardingSeen, true);
  }

  Future<bool> isOnboardingSeen() {
    return _prefs.getBool(StorageKeys.onboardingSeen);
  }

  // =====================
  // LOGOUT (IMPORTANT)
  // =====================
  Future<void> clearAll() async {
    await _secureStorage.clear();
  }
}
