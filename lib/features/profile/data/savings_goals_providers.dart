import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/features/profile/data/savings_goal_api.dart';
import 'package:apsara_wallet_mobile/features/profile/data/savings_goals_mock_data.dart';
import 'package:apsara_wallet_mobile/features/profile/data/savings_icon_choices.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_api.dart'
    show colorToHex;

/// The user's savings goals, backed by the API. Create / add-funds flow through
/// the backend and refresh. Tracking only — no wallet or ledger side effects.
class SavingsGoalsNotifier extends AsyncNotifier<List<SavingsGoal>> {
  SavingsGoalApi get _api => ref.read(savingsGoalApiProvider);

  @override
  Future<List<SavingsGoal>> build() async {
    final apiGoals = await _api.list();
    return apiGoals.map((g) => g.toGoal()).toList();
  }

  /// Creates a goal from a draft built by the new-goal sheet (name/target, with
  /// its icon + color persisted as tokens).
  Future<void> addGoal(SavingsGoal draft) async {
    final ok = await _api.create(
      name: draft.customName ?? '',
      targetKhr: draft.targetKhr,
      savedKhr: draft.savedKhr,
      icon: savingsIconToken(draft.icon),
      color: colorToHex(draft.color),
    );
    if (!ok) throw StateError('savings-create-failed');
    await _reload();
  }

  /// Edits a goal's name / target / icon / colour (not its saved total).
  /// Requires [draft].id — the server id of the goal being edited.
  Future<void> edit(SavingsGoal draft) async {
    final ok = await _api.update(
      id: draft.id,
      name: draft.customName ?? '',
      targetKhr: draft.targetKhr,
      icon: savingsIconToken(draft.icon),
      color: colorToHex(draft.color),
    );
    if (!ok) throw StateError('savings-update-failed');
    await _reload();
  }

  /// Adds [amountKhr] to a goal's saved total.
  Future<void> addFunds(String id, int amountKhr) async {
    final ok = await _api.addFunds(id, amountKhr);
    if (!ok) throw StateError('savings-add-funds-failed');
    await _reload();
  }

  Future<void> remove(String id) async {
    await _api.delete(id);
    await _reload();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final savingsGoalsProvider =
    AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoal>>(
  SavingsGoalsNotifier.new,
);
