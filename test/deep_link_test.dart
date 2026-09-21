import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/deep_links/app_deep_link.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

void main() {
  group('AppDeepLink.parse', () {
    test(
      'reads the reset token from the custom-scheme link the API emails',
      () {
        final link = AppDeepLink.parse(
          Uri.parse('apsarawallet://reset-password?token=abc123'),
        );
        expect(link, const ResetPasswordDeepLink('abc123'));
        expect(link!.route, isA<ResetPasswordRoute>());
        expect((link.route as ResetPasswordRoute).args?.token, 'abc123');
      },
    );

    test('accepts the single-slash form some mail clients produce', () {
      expect(
        AppDeepLink.parse(Uri.parse('apsarawallet:/reset-password?token=t')),
        const ResetPasswordDeepLink('t'),
      );
    });

    test('accepts the https form on the marketing domain', () {
      expect(
        AppDeepLink.parse(
          Uri.parse('https://apsarawallet.app/reset-password?token=t'),
        ),
        const ResetPasswordDeepLink('t'),
      );
    });

    test('keeps the token verbatim apart from surrounding whitespace', () {
      expect(
        AppDeepLink.parse(
          Uri.parse('apsarawallet://reset-password?token=%20a.b-c_D%20'),
        ),
        const ResetPasswordDeepLink('a.b-c_D'),
      );
    });

    test('ignores a reset link with no token', () {
      expect(
        AppDeepLink.parse(Uri.parse('apsarawallet://reset-password')),
        isNull,
      );
      expect(
        AppDeepLink.parse(Uri.parse('apsarawallet://reset-password?token=')),
        isNull,
      );
    });

    test('ignores unknown destinations and other hosts / schemes', () {
      for (final raw in [
        'apsarawallet://dashboard',
        'apsarawallet://',
        'https://apsarawallet.app/privacy',
        'https://evil.example/reset-password?token=t',
        'http://localhost:3010/reset-password?token=t',
        'mailto:support@apsarawallet.app',
      ]) {
        expect(AppDeepLink.parse(Uri.parse(raw)), isNull, reason: raw);
      }
    });
  });
}
