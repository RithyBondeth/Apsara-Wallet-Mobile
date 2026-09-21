import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_record.dart';

/// Transaction as returned by `GET /transactions` (ids are backend UUIDs).
class ApiTransaction {
  const ApiTransaction({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.title,
    required this.amountKhr,
    required this.type,
    required this.date,
    this.note,
  });

  final String id;
  final String walletId;
  final String categoryId;
  final String title;
  final int amountKhr;
  final String type; // 'income' | 'expense'
  final String date; // ISO 8601
  final String? note;

  factory ApiTransaction.fromJson(Map<String, dynamic> json) => ApiTransaction(
    id: json['id'] as String,
    walletId: json['walletId'] as String,
    categoryId: json['categoryId'] as String,
    title: json['title'] as String,
    amountKhr: (json['amountKhr'] as num).toInt(),
    type: json['type'] as String,
    date: json['date'] as String,
    note: json['note'] as String?,
  );

  /// Maps to the app's [TransactionRecord]. [walletName] is resolved from the
  /// wallet list and [categorySlug] from the [CategoryIndex]; both fall back
  /// gracefully so an unknown id never crashes the ledger.
  TransactionRecord toRecord({
    required String walletName,
    required TxCategory category,
  }) {
    return TransactionRecord(
      id: id,
      title: title,
      category: category,
      walletName: walletName,
      date: DateTime.parse(date).toLocal(),
      amountKhr: amountKhr,
      type: ETransactionType.values.byName(type),
      note: note,
    );
  }
}

class TransactionApi {
  TransactionApi(this._api);

  final ApiClient _api;

  /// Rows per request. The API caps `limit` at 200.
  static const int pageSize = 200;

  /// Safety valve: never chase more pages than this in one load (50 × 200 =
  /// 10k rows, far beyond any personal ledger). Stops a bad `totalPages`
  /// from looping forever.
  static const int maxPages = 50;

  /// The user's whole ledger as raw transaction JSON, newest first.
  ///
  /// The API pages at 200 rows and every client-side surface (history,
  /// search, analytics, insights, CSV) derives from this one list, so it
  /// pages through `meta.totalPages` until the ledger is complete. Throws
  /// when any page fails: the caller then falls back to its cached snapshot,
  /// which is a better outcome than rendering a silently truncated ledger.
  Future<List<dynamic>> fetchRaw() async {
    final all = <dynamic>[];
    var page = 1;
    while (page <= maxPages) {
      final res = await _api.get<Map<String, dynamic>>(
        '/transactions',
        query: {'page': page, 'limit': pageSize},
      );
      if (!res.success || res.data == null) throw Exception(res.message);
      final data = res.data!['data'];
      if (data is! List) throw Exception('unexpected transactions response');
      all.addAll(data);

      final meta = res.data!['meta'];
      final totalPages = meta is Map ? (meta['totalPages'] as num?) : null;
      final last = totalPages == null
          ? data.length <
                pageSize // no meta: stop on a short page
          : page >= totalPages;
      if (last || data.isEmpty) break;
      page++;
    }
    return all;
  }

  Future<bool> create({
    required String title,
    required String walletId,
    required String categoryId,
    required int amountKhr,
    required ETransactionType type,
    required DateTime date,
    String? note,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/transactions',
      data: {
        'title': title,
        'walletId': walletId,
        'categoryId': categoryId,
        'amountKhr': amountKhr,
        'type': type.name,
        'date': date.toUtc().toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return res.success;
  }

  Future<bool> update({
    required String id,
    required String title,
    required String walletId,
    required String categoryId,
    required int amountKhr,
    required ETransactionType type,
    required DateTime date,
    String? note,
  }) async {
    final res = await _api.patch<Map<String, dynamic>>(
      '/transactions/$id',
      data: {
        'title': title,
        'walletId': walletId,
        'categoryId': categoryId,
        'amountKhr': amountKhr,
        'type': type.name,
        'date': date.toUtc().toIso8601String(),
        'note': note,
      },
    );
    return res.success;
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete<Map<String, dynamic>>('/transactions/$id');
    return res.success;
  }
}

final transactionApiProvider = Provider<TransactionApi>(
  (ref) => TransactionApi(ref.watch(apiClientProvider)),
);
