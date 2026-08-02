import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';

/// A per-category monthly budget as returned by `GET /budgets` — the limit the
/// user set plus the live spend computed from the ledger.
class ApiBudget {
  const ApiBudget({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.limitKhr,
    required this.spentKhr,
  });

  final String id;
  final String categoryId; // UUID
  final String month; // YYYY-MM
  final int limitKhr;
  final int spentKhr;

  factory ApiBudget.fromJson(Map<String, dynamic> json) => ApiBudget(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        month: json['month'] as String,
        limitKhr: (json['limitKhr'] as num).toInt(),
        spentKhr: (json['spentKhr'] as num?)?.toInt() ?? 0,
      );
}

class BudgetApi {
  BudgetApi(this._api);

  final ApiClient _api;

  Future<List<ApiBudget>> list(String month) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/budgets',
      query: {'month': month},
    );
    final data = res.data?['budgets'];
    if (!res.success || data is! List) return const [];
    return data
        .map((e) => ApiBudget.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Raw budget JSON for [month], throwing on failure so the notifier can fall
  /// back to a cached snapshot instead of silently showing no budgets.
  Future<List<dynamic>> fetchRaw(String month) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/budgets',
      query: {'month': month},
    );
    final data = res.data?['budgets'];
    if (!res.success || data is! List) throw Exception(res.message);
    return data;
  }

  /// Create or update the budget for (month, category).
  Future<bool> upsert({
    required String categoryId,
    required String month,
    required int limitKhr,
  }) async {
    final res = await _api.post<Map<String, dynamic>>('/budgets', data: {
      'categoryId': categoryId,
      'month': month,
      'limitKhr': limitKhr,
    });
    return res.success;
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete<Map<String, dynamic>>('/budgets/$id');
    return res.success;
  }
}

final budgetApiProvider = Provider<BudgetApi>(
  (ref) => BudgetApi(ref.watch(apiClientProvider)),
);
