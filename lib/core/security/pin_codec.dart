import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hashes and verifies the app-lock PIN. The raw PIN is never persisted — only
/// a per-device random salt and the salted SHA-256 digest are stored (in the
/// platform secure store). A 4-digit PIN is inherently low-entropy, so the real
/// protection is the secure store + the attempt lockout in AppLockController;
/// hashing simply avoids ever keeping the PIN in recoverable form.
class PinCodec {
  const PinCodec._();

  static String generateSalt([int bytes = 16]) {
    final rnd = Random.secure();
    return base64Url.encode(List<int>.generate(bytes, (_) => rnd.nextInt(256)));
  }

  static String hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  static bool verify(
    String pin, {
    required String salt,
    required String expectedHash,
  }) {
    return _constantTimeEquals(hash(pin, salt), expectedHash);
  }

  /// Length-independent compare that avoids leaking the match position via
  /// timing. Both inputs here are hex SHA-256 digests of equal length.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var mismatch = 0;
    for (var i = 0; i < a.length; i++) {
      mismatch |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return mismatch == 0;
  }
}
