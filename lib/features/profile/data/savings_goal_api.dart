import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/features/profile/data/savings_goals_mock_data.dart';
import 'package:apsara_wallet_mobile/features/profile/data/savings_icon_choices.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_api.dart'
    show parseHexColor;

/// A savings goal as returned by `GET /savings-goals`. Tracking only — the
/// backend never moves money; `savedKhr` is a plain running total.
class ApiSavingsGoal {
  const ApiSavingsGoal({
    required this.id,
    required this.name,
    required this.savedKhr,
    required this.targetKhr,
    this.icon,
    this.color,
  });

  final String id;
  final String name;
  final int savedKhr;
  final int targetKhr;
  final String? icon; // icon token
  final String? color; // '#RRGGBB'

  factory ApiSavingsGoal.fromJson(Map<String, dynamic> json) => ApiSavingsGoal(
        id: json['id'] as String,
        name: json['name'] as String,
        savedKhr: (json['savedKhr'] as num?)?.toInt() ?? 0,
        targetKhr: (json['targetKhr'] as num).toInt(),
        icon: json['icon'] as String?,
        color: json['color'] as String?,
      );

  /// Maps to the app's [SavingsGoal] — always a `customName` (API goals carry
  /// their own name, not an l10n key), icon/color resolved from the tokens.
  SavingsGoal toGoal() => SavingsGoal(
        id: id,
        icon: savingsIconFromToken(icon),
        color: parseHexColor(color) ?? AppColors.primary,
        savedKhr: savedKhr,
        targetKhr: targetKhr,
        customName: name,
      );
}

class SavingsGoalApi {
  SavingsGoalApi(this._api);

  final ApiClient _api;

  Future<List<ApiSavingsGoal>> list() async {
    final res = await _api.get<List<dynamic>>('/savings-goals');
    if (!res.success || res.data == null) return const [];
    return res.data!
        .map((e) => ApiSavingsGoal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> create({
    required String name,
    required int targetKhr,
    int savedKhr = 0,
    String? icon,
    String? color,
  }) async {
    final res = await _api.post<Map<String, dynamic>>('/savings-goals', data: {
      'name': name,
      'targetKhr': targetKhr,
      'savedKhr': savedKhr,
      'icon': ?icon,
      'color': ?color,
    });
    return res.success;
  }

  Future<bool> update({
    required String id,
    required String name,
    required int targetKhr,
    String? icon,
    String? color,
  }) async {
    final res = await _api.patch<Map<String, dynamic>>(
      '/savings-goals/$id',
      data: {
        'name': name,
        'targetKhr': targetKhr,
        'icon': ?icon,
        'color': ?color,
      },
    );
    return res.success;
  }

  Future<bool> addFunds(String id, int amountKhr) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/savings-goals/$id/add-funds',
      data: {'amountKhr': amountKhr},
    );
    return res.success;
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete<Map<String, dynamic>>('/savings-goals/$id');
    return res.success;
  }
}

final savingsGoalApiProvider = Provider<SavingsGoalApi>(
  (ref) => SavingsGoalApi(ref.watch(apiClientProvider)),
);
