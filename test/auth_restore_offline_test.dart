import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/core/storage/token_storage.dart';
import 'package:apsara_wallet_mobile/features/auth/data/auth_repository.dart';

/// Scripted transport for POST /auth/refresh: `null` = no connection at all,
/// otherwise the status code (and a token pair body on 2xx).
class _RefreshAdapter implements HttpClientAdapter {
  _RefreshAdapter(this.status);
  final int? status;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    expect(options.path, '/auth/refresh');
    final s = status;
    if (s == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    if (s >= 200 && s < 300) {
      return ResponseBody.fromString(
        jsonEncode({
          'accessToken': _jwt(expiresIn: const Duration(minutes: 15)),
          'refreshToken': 'refresh-2',
        }),
        s,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString('{"message":"Invalid refresh token"}', s);
  }

  @override
  void close({bool force = false}) {}
}

String _b64(Map<String, Object?> m) =>
    base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');

/// An unsigned JWT with the claims the app reads; the signature is never
/// checked on-device.
String _jwt({required Duration expiresIn}) {
  final exp = DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000;
  final payload = {
    'sub': '11111111-1111-4111-8111-111111111111',
    'email': 'sokha@test.local',
    'exp': exp,
  };
  return '${_b64({'alg': 'none'})}.${_b64(payload)}.sig';
}

void main() {
  late TokenStorage storage;

  Future<AuthRepository> repoWith(int? refreshStatus) async {
    FlutterSecureStorage.setMockInitialValues({
      'auth_access_token': _jwt(expiresIn: const Duration(minutes: -5)),
      'auth_refresh_token': 'refresh-1',
    });
    storage = TokenStorage(const FlutterSecureStorage());
    final dio = Dio()..httpClientAdapter = _RefreshAdapter(refreshStatus);
    return AuthRepository(ApiClient(dio), storage);
  }

  test('offline at boot with a stale access token keeps the session', () async {
    final repo = await repoWith(null);

    final user = await repo.restoreSession();

    expect(user, isNotNull);
    expect(user!.email, 'sokha@test.local');
    // Nothing was thrown away: the next online request can still refresh.
    expect(await storage.readRefreshToken(), 'refresh-1');
    expect(await storage.readAccessToken(), isNotNull);
  });

  test('a 5xx from the refresh endpoint also keeps the session', () async {
    final repo = await repoWith(503);
    expect(await repo.restoreSession(), isNotNull);
    expect(await storage.readRefreshToken(), 'refresh-1');
  });

  test('the server refusing the refresh token ends the session', () async {
    final repo = await repoWith(401);

    expect(await repo.restoreSession(), isNull);
    expect(await storage.readRefreshToken(), isNull);
    expect(await storage.readAccessToken(), isNull);
  });

  test('a successful refresh rotates both tokens', () async {
    final repo = await repoWith(201);

    final user = await repo.restoreSession();

    expect(user, isNotNull);
    expect(await storage.readRefreshToken(), 'refresh-2');
  });
}
