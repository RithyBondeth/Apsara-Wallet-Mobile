import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/security/app_lock_storage.dart';
import 'package:apsara_wallet_mobile/core/security/biometric_service.dart';
import 'package:apsara_wallet_mobile/core/security/pin_codec.dart';

/// Outcome of a PIN unlock attempt.
enum PinUnlockResult { success, wrong, lockedOut }

/// How many wrong PINs before a cool-down, and how long that cool-down lasts.
const _maxAttempts = 5;
const _lockoutDuration = Duration(seconds: 30);

class AppLockState {
  const AppLockState({
    this.isLoaded = false,
    this.isPinSet = false,
    this.isBiometricEnabled = false,
    this.isBiometricAvailable = false,
    this.isLocked = false,
    this.backgroundTimeout = Duration.zero,
    this.failedAttempts = 0,
    this.lockedOutUntil,
  });

  final bool isLoaded;
  final bool isPinSet;
  final bool isBiometricEnabled;
  final bool isBiometricAvailable;
  final bool isLocked;
  final Duration backgroundTimeout;
  final int failedAttempts;
  final DateTime? lockedOutUntil;

  /// App-lock is active exactly when a PIN has been set.
  bool get lockEnabled => isPinSet;

  /// Biometric can be offered on the lock screen right now.
  bool get canUseBiometric =>
      isPinSet && isBiometricEnabled && isBiometricAvailable;

  AppLockState copyWith({
    bool? isLoaded,
    bool? isPinSet,
    bool? isBiometricEnabled,
    bool? isBiometricAvailable,
    bool? isLocked,
    Duration? backgroundTimeout,
    int? failedAttempts,
    DateTime? lockedOutUntil,
    bool clearLockout = false,
  }) {
    return AppLockState(
      isLoaded: isLoaded ?? this.isLoaded,
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isLocked: isLocked ?? this.isLocked,
      backgroundTimeout: backgroundTimeout ?? this.backgroundTimeout,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedOutUntil:
          clearLockout ? null : (lockedOutUntil ?? this.lockedOutUntil),
    );
  }
}

/// Owns the local app-lock: PIN + biometric configuration and the current
/// locked/unlocked state. Locking policy (cold-start + resume-after-timeout)
/// is driven from the splash screen and the [AppLockGate] lifecycle observer.
class AppLockController extends StateNotifier<AppLockState> {
  AppLockController(this._storage, this._biometric)
      : super(const AppLockState());

  final AppLockStorage _storage;
  final BiometricService _biometric;

  DateTime? _backgroundedAt;

  /// True while a biometric system prompt is on screen. The OS briefly
  /// backgrounds the app to show it, which must NOT be treated as the user
  /// leaving (or it would spuriously re-lock mid-scan).
  bool _authInProgress = false;

  /// Loads persisted config. Does not change [AppLockState.isLocked] — the
  /// caller decides when to lock (see [lockIfEnabled]).
  Future<void> load() async {
    try {
      final isPinSet = await _storage.isPinSet();
      final biometricEnabled = await _storage.readBiometricEnabled();
      final available = await _biometric.isAvailable();
      final timeout = await _storage.readBackgroundTimeout();
      state = state.copyWith(
        isLoaded: true,
        isPinSet: isPinSet,
        isBiometricEnabled: biometricEnabled,
        isBiometricAvailable: available,
        backgroundTimeout: Duration(seconds: timeout),
      );
    } catch (_) {
      // Secure store unavailable (e.g. in a widget test with no plugin) —
      // fall back to "no lock configured" rather than surfacing an error.
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> setPin(String pin) async {
    final salt = PinCodec.generateSalt();
    final hash = PinCodec.hash(pin, salt);
    await _storage.savePin(hash: hash, salt: salt);
    state = state.copyWith(
      isPinSet: true,
      isLocked: false,
      failedAttempts: 0,
      clearLockout: true,
    );
  }

  /// Turns the whole feature off: clears the PIN and biometric opt-in.
  Future<void> disableLock() async {
    await _storage.clearAll();
    state = state.copyWith(
      isPinSet: false,
      isBiometricEnabled: false,
      isLocked: false,
      failedAttempts: 0,
      clearLockout: true,
    );
  }

  /// Enables biometric unlock — requires a PIN fallback and a capable device,
  /// and confirms with a live scan before persisting the choice.
  Future<bool> enableBiometric(String reason) async {
    if (!state.isPinSet) return false;
    // Check availability live so this doesn't depend on load() having run
    // (e.g. during the just-signed-up onboarding flow).
    final available = await _biometric.isAvailable();
    if (available != state.isBiometricAvailable) {
      state = state.copyWith(isBiometricAvailable: available);
    }
    if (!available) return false;
    final ok = await _runBiometric(reason);
    if (!ok) return false;
    await _storage.setBiometricEnabled(true);
    state = state.copyWith(isBiometricEnabled: true);
    return true;
  }

  /// Runs a biometric scan while suppressing background-triggered locking.
  Future<bool> _runBiometric(String reason) async {
    _authInProgress = true;
    try {
      return await _biometric.authenticate(reason);
    } finally {
      _authInProgress = false;
    }
  }

  Future<void> disableBiometric() async {
    await _storage.setBiometricEnabled(false);
    state = state.copyWith(isBiometricEnabled: false);
  }

  Future<void> setBackgroundTimeout(Duration timeout) async {
    await _storage.setBackgroundTimeout(timeout.inSeconds);
    state = state.copyWith(backgroundTimeout: timeout);
  }

  PinUnlockResult _lockoutCheck() {
    final until = state.lockedOutUntil;
    if (until != null && DateTime.now().isBefore(until)) {
      return PinUnlockResult.lockedOut;
    }
    return PinUnlockResult.success; // sentinel: "not locked out"
  }

  Future<PinUnlockResult> unlockWithPin(String pin) async {
    if (_lockoutCheck() == PinUnlockResult.lockedOut) {
      return PinUnlockResult.lockedOut;
    }
    final hash = await _storage.readPinHash();
    final salt = await _storage.readPinSalt();
    if (hash == null || salt == null) {
      // No PIN on record — nothing to verify against; treat as unlocked.
      state = state.copyWith(isLocked: false);
      return PinUnlockResult.success;
    }
    if (PinCodec.verify(pin, salt: salt, expectedHash: hash)) {
      state = state.copyWith(
        isLocked: false,
        failedAttempts: 0,
        clearLockout: true,
      );
      return PinUnlockResult.success;
    }
    final attempts = state.failedAttempts + 1;
    if (attempts >= _maxAttempts) {
      state = state.copyWith(
        failedAttempts: attempts,
        lockedOutUntil: DateTime.now().add(_lockoutDuration),
      );
      return PinUnlockResult.lockedOut;
    }
    state = state.copyWith(failedAttempts: attempts);
    return PinUnlockResult.wrong;
  }

  Future<bool> unlockWithBiometric(String reason) async {
    if (!state.canUseBiometric) return false;
    final ok = await _runBiometric(reason);
    if (ok) {
      state = state.copyWith(
        isLocked: false,
        failedAttempts: 0,
        clearLockout: true,
      );
    }
    return ok;
  }

  /// Remaining seconds in the current lockout window (0 if none).
  int get lockoutSecondsLeft {
    final until = state.lockedOutUntil;
    if (until == null) return 0;
    final left = until.difference(DateTime.now()).inSeconds;
    return left > 0 ? left : 0;
  }

  /// Locks now if the feature is enabled. Used on cold start (from splash).
  void lockIfEnabled() {
    if (state.lockEnabled) state = state.copyWith(isLocked: true);
  }

  /// Marks the session as unlocked — called after a fresh password login so
  /// the user isn't immediately asked for their PIN too.
  void markUnlocked() {
    if (state.isLocked) state = state.copyWith(isLocked: false);
  }

  // --- Lifecycle, driven by AppLockGate ---------------------------------

  void onBackgrounded() {
    if (!state.lockEnabled || _authInProgress) return;
    // With no grace window (the default), lock the moment we're backgrounded
    // so returning always requires the PIN/biometric — and the app-switcher
    // snapshot shows the lock screen rather than the user's finances.
    if (state.backgroundTimeout == Duration.zero) {
      state = state.copyWith(isLocked: true);
    } else {
      _backgroundedAt = DateTime.now();
    }
  }

  void onForegrounded() {
    if (!state.lockEnabled) return;
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null) return;
    if (DateTime.now().difference(since) >= state.backgroundTimeout) {
      state = state.copyWith(isLocked: true);
    }
  }
}

final appLockControllerProvider =
    StateNotifierProvider<AppLockController, AppLockState>((ref) {
  return AppLockController(
    ref.watch(appLockStorageProvider),
    ref.watch(biometricServiceProvider),
  );
});
