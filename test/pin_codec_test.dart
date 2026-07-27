import 'package:apsara_wallet_mobile/core/security/pin_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PinCodec', () {
    test('hash is deterministic for the same pin + salt', () {
      const salt = 'fixed-salt';
      expect(PinCodec.hash('1234', salt), PinCodec.hash('1234', salt));
    });

    test('verify accepts the correct pin and rejects wrong ones', () {
      final salt = PinCodec.generateSalt();
      final hash = PinCodec.hash('4321', salt);
      expect(PinCodec.verify('4321', salt: salt, expectedHash: hash), isTrue);
      expect(PinCodec.verify('0000', salt: salt, expectedHash: hash), isFalse);
    });

    test('same pin under different salts yields different hashes', () {
      final h1 = PinCodec.hash('1234', PinCodec.generateSalt());
      final h2 = PinCodec.hash('1234', PinCodec.generateSalt());
      expect(h1, isNot(equals(h2)));
    });

    test('generateSalt returns unique values', () {
      final salts = List.generate(50, (_) => PinCodec.generateSalt());
      expect(salts.toSet().length, salts.length);
    });
  });
}
