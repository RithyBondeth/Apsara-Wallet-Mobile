import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_api.dart';

/// Serves GET /transactions from an in-memory ledger of [total] rows using
/// the API's real paging contract (`page`/`limit` in, `data` + `meta` out),
/// and records every request so a test can assert how many pages were hit.
class _PagedLedgerAdapter implements HttpClientAdapter {
  _PagedLedgerAdapter({required this.total, this.failOnPage, this.omitMeta});

  final int total;
  final int? failOnPage;
  final bool? omitMeta;
  final List<Map<String, dynamic>> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.path, '/transactions');
    requests.add(options.queryParameters);
    final page = options.queryParameters['page'] as int;
    final limit = options.queryParameters['limit'] as int;
    if (page == failOnPage) {
      return ResponseBody.fromString('{"message":"boom"}', 500);
    }
    final start = (page - 1) * limit;
    final rows = [
      for (var i = start; i < start + limit && i < total; i++)
        {'id': 'tx-$i', 'title': 'Row $i'},
    ];
    final body = {
      'data': rows,
      if (omitMeta != true)
        'meta': {
          'page': page,
          'limit': limit,
          'total': total,
          'totalPages': (total / limit).ceil(),
        },
    };
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

TransactionApi _apiOver(_PagedLedgerAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return TransactionApi(ApiClient(dio));
}

void main() {
  test(
    'fetches the whole ledger across pages, newest first order kept',
    () async {
      final adapter = _PagedLedgerAdapter(total: 450);
      final rows = await _apiOver(adapter).fetchRaw();

      expect(rows, hasLength(450));
      expect((rows.first as Map)['id'], 'tx-0');
      expect((rows.last as Map)['id'], 'tx-449');
      expect(adapter.requests.map((q) => q['page']), [1, 2, 3]);
      expect(adapter.requests.every((q) => q['limit'] == 200), isTrue);
    },
  );

  test('a ledger that fits in one page makes exactly one request', () async {
    final adapter = _PagedLedgerAdapter(total: 37);
    final rows = await _apiOver(adapter).fetchRaw();

    expect(rows, hasLength(37));
    expect(adapter.requests, hasLength(1));
  });

  test(
    'an exact multiple of the page size does not request an empty page',
    () async {
      final adapter = _PagedLedgerAdapter(total: 400);
      final rows = await _apiOver(adapter).fetchRaw();

      expect(rows, hasLength(400));
      expect(adapter.requests, hasLength(2));
    },
  );

  test('an empty ledger is one request and no rows', () async {
    final adapter = _PagedLedgerAdapter(total: 0);
    expect(await _apiOver(adapter).fetchRaw(), isEmpty);
    expect(adapter.requests, hasLength(1));
  });

  test(
    'throws when a later page fails rather than returning a partial ledger',
    () async {
      final adapter = _PagedLedgerAdapter(total: 450, failOnPage: 2);

      await expectLater(
        _apiOver(adapter).fetchRaw(),
        throwsA(isA<Exception>()),
      );
      expect(adapter.requests, hasLength(2));
    },
  );

  test('without meta, stops on the first short page', () async {
    final adapter = _PagedLedgerAdapter(total: 250, omitMeta: true);
    final rows = await _apiOver(adapter).fetchRaw();

    expect(rows, hasLength(250));
    expect(adapter.requests, hasLength(2));
  });
}
