import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/networks/api_error_l10n.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

Future<AppLocalizations> load(String code) =>
    AppLocalizations.delegate.load(Locale(code));

void main() {
  test('known backend messages resolve to Khmer copy', () async {
    final km = await load('km');
    expect(
      localizedApiError(km, 'Invalid email or password'),
      km.apiErrorInvalidCredentials,
    );
    expect(
      localizedApiError(km, 'Insufficient balance in source wallet'),
      km.apiErrorInsufficientBalance,
    );
    expect(localizedApiError(km, 'Wallet not found'), km.apiErrorNotFound);
    expect(
      localizedApiError(km, 'Incorrect current password'),
      km.changePasswordWrongCurrent,
    );
  });

  test('client transport messages resolve too', () async {
    final km = await load('km');
    expect(localizedApiError(km, 'No Internet connection'), km.apiErrorOffline);
    expect(
      localizedApiError(km, 'Connection timeout with API server'),
      km.apiErrorTimeout,
    );
    expect(localizedApiError(km, 'Internal server error'), km.apiErrorServer);
  });

  test(
    'an unknown server message is never shown raw to a Khmer user',
    () async {
      final km = await load('km');
      expect(
        localizedApiError(km, 'Some brand new backend message'),
        km.apiErrorGeneric,
      );
    },
  );

  test('an unknown server message is passed through in English', () async {
    final en = await load('en');
    expect(
      localizedApiError(en, 'Some brand new backend message'),
      'Some brand new backend message',
    );
  });

  test('null or blank falls back to the generic line', () async {
    final en = await load('en');
    expect(localizedApiError(en, null), en.apiErrorGeneric);
    expect(localizedApiError(en, '   '), en.apiErrorGeneric);
  });
}
