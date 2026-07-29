import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';

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

  /// Newest-first list. Pulls a generous page (the dashboard/list don't
  /// paginate yet); [limit] caps it.
  Future<List<ApiTransaction>> list({int limit = 200}) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/transactions',
      query: {'limit': limit},
    );
    if (!res.success || res.data == null) return const [];
    final data = res.data!['data'];
    if (data is! List) return const [];
    return data
        .map((e) => ApiTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Raw transaction JSON, throwing when the request fails so callers can fall
  /// back to a cached copy instead of silently rendering an empty ledger.
  Future<List<dynamic>> fetchRaw({int limit = 200}) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/transactions',
      query: {'limit': limit},
    );
    if (!res.success || res.data == null) throw Exception(res.message);
    final data = res.data!['data'];
    if (data is! List) throw Exception('unexpected transactions response');
    return data;
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
    final res = await _api.post<Map<String, dynamic>>('/transactions', data: {
      'title': title,
      'walletId': walletId,
      'categoryId': categoryId,
      'amountKhr': amountKhr,
      'type': type.name,
      'date': date.toUtc().toIso8601String(),
      if (note != null && note.isNotEmpty) 'note': note,
    });
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
