import 'package:apsara_wallet_mobile/core/security/app_lock_storage.dart';
import 'package:apsara_wallet_mobile/core/security/biometric_service.dart';
import 'package:apsara_wallet_mobile/features/security/application/app_lock_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for the secure store.
class _FakeStorage implements AppLockStorage {
  String? hash;
  String? salt;
  bool biometric = false;
  int timeout = 0;

  @override
  Future<String?> readPinHash() async => hash;
  @override
  Future<String?> readPinSalt() async => salt;
  @override
  Future<bool> isPinSet() async => hash != null;
  @override
  Future<void> savePin({required String hash, required String salt}) async {
    this.hash = hash;
    this.salt = salt;
  }

  @override
  Future<void> clearPin() async {
    hash = null;
    salt = null;
  }

  @override
  Future<bool> readBiometricEnabled() async => biometric;
  @override
  Future<void> setBiometricEnabled(bool enabled) async => biometric = enabled;
  @override
  Future<int> readBackgroundTimeout() async => timeout;
  @override
  Future<void> setBackgroundTimeout(int seconds) async => timeout = seconds;
  @override
  Future<void> clearAll() async {
    hash = null;
    salt = null;
    biometric = false;
  }
}

void main() {
  AppLockController make() =>
      AppLockController(_FakeStorage(), BiometricService());

  test('setting a PIN enables lock and leaves it unlocked', () async {
    final c = make();
    await c.setPin('1234');
    expect(c.state.isPinSet, isTrue);
    expect(c.state.lockEnabled, isTrue);
    expect(c.state.isLocked, isFalse);
  });

  test('backgrounding locks immediately (zero grace default)', () async {
    final c = make();
    await c.setPin('1234');
    c.onBackgrounded();
    expect(c.state.isLocked, isTrue);
  });

  test('does not lock on background when no PIN is set', () async {
    final c = make();
    c.onBackgrounded();
    expect(c.state.isLocked, isFalse);
  });

  test('correct PIN unlocks, wrong PIN keeps it locked', () async {
    final c = make();
    await c.setPin('1234');
    c.onBackgrounded();

    expect(await c.unlockWithPin('0000'), PinUnlockResult.wrong);
    expect(c.state.isLocked, isTrue);

    expect(await c.unlockWithPin('1234'), PinUnlockResult.success);
    expect(c.state.isLocked, isFalse);
  });

  test('disabling lock clears the PIN', () async {
    final c = make();
    await c.setPin('1234');
    await c.disableLock();
    expect(c.state.isPinSet, isFalse);
    c.onBackgrounded();
    expect(c.state.isLocked, isFalse);
  });
}
