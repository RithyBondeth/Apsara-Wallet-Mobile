import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_rule.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';

/// A recurring rule as returned by `GET /recurring` (ids are backend UUIDs).
class ApiRecurringRule {
  const ApiRecurringRule({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.title,
    required this.amountKhr,
    required this.type,
    required this.frequency,
    required this.nextDue,
    this.note,
  });

  final String id;
  final String walletId;
  final String categoryId;
  final String title;
  final int amountKhr;
  final String type; // 'income' | 'expense'
  final String frequency; // 'weekly' | 'monthly'
  final String nextDue; // ISO 8601
  final String? note;

  factory ApiRecurringRule.fromJson(Map<String, dynamic> json) =>
      ApiRecurringRule(
        id: json['id'] as String,
        walletId: json['walletId'] as String,
        categoryId: json['categoryId'] as String,
        title: json['title'] as String,
        amountKhr: (json['amountKhr'] as num).toInt(),
        type: json['type'] as String,
        frequency: json['frequency'] as String,
        nextDue: json['nextDue'] as String,
        note: json['note'] as String?,
      );

  /// Maps to the app's [RecurringRule]. [walletName] is resolved from the
  /// wallet list and [category] from the category index; both fall back
  /// gracefully so an unknown id never crashes the screen.
  RecurringRule toRule({
    required String walletName,
    required TxCategory category,
  }) {
    return RecurringRule(
      id: id,
      title: title,
      category: category,
      walletName: walletName,
      amountKhr: amountKhr,
      type: ETransactionType.values.byName(type),
      frequency: frequency == 'weekly'
          ? ERecurrenceFrequency.weekly
          : ERecurrenceFrequency.monthly,
      nextDue: DateTime.parse(nextDue).toLocal(),
      note: note,
    );
  }
}

/// Outcome of `POST /recurring/run` — how many occurrences were posted.
class RunDueResult {
  const RunDueResult({required this.posted, required this.rulesRun});

  final int posted;
  final int rulesRun;

  bool get postedAny => posted > 0;

  factory RunDueResult.fromJson(Map<String, dynamic> json) => RunDueResult(
        posted: (json['posted'] as num?)?.toInt() ?? 0,
        rulesRun: (json['rulesRun'] as num?)?.toInt() ?? 0,
      );
}

class RecurringApi {
  RecurringApi(this._api);

  final ApiClient _api;

  Future<List<ApiRecurringRule>> list() async {
    final res = await _api.get<List<dynamic>>('/recurring');
    if (!res.success || res.data == null) return const [];
    return res.data!
        .map((e) => ApiRecurringRule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> create({
    required String title,
    required String walletId,
    required String categoryId,
    required int amountKhr,
    required ETransactionType type,
    required ERecurrenceFrequency frequency,
    required DateTime nextDue,
    String? note,
  }) async {
    final res = await _api.post<Map<String, dynamic>>('/recurring', data: {
      'title': title,
      'walletId': walletId,
      'categoryId': categoryId,
      'amountKhr': amountKhr,
      'type': type.name,
      'frequency': frequency.name,
      'nextDue': nextDue.toUtc().toIso8601String(),
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
    required ERecurrenceFrequency frequency,
    required DateTime nextDue,
    String? note,
  }) async {
    final res = await _api.patch<Map<String, dynamic>>('/recurring/$id', data: {
      'title': title,
      'walletId': walletId,
      'categoryId': categoryId,
      'amountKhr': amountKhr,
      'type': type.name,
      'frequency': frequency.name,
      'nextDue': nextDue.toUtc().toIso8601String(),
      'note': note,
    });
    return res.success;
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete<Map<String, dynamic>>('/recurring/$id');
    return res.success;
  }

  /// Posts every due occurrence to the ledger and advances the rules.
  Future<RunDueResult> run() async {
    final res = await _api.post<Map<String, dynamic>>('/recurring/run');
    if (!res.success || res.data == null) {
      return const RunDueResult(posted: 0, rulesRun: 0);
    }
    return RunDueResult.fromJson(res.data!);
  }
}

final recurringApiProvider = Provider<RecurringApi>(
  (ref) => RecurringApi(ref.watch(apiClientProvider)),
);
