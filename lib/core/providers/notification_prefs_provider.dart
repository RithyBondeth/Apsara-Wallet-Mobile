import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/storages/shared_prefs_service.dart';
import 'package:apsara_wallet_mobile/core/storages/storage_keys.dart';

/// The user's notification preferences. All default on except promotions.
class NotificationPrefs {
  const NotificationPrefs({
    this.push = true,
    this.transactionAlerts = true,
    this.budgetWarnings = true,
    this.promotions = false,
  });

  /// Master switch — when off, nothing surfaces regardless of the categories.
  final bool push;
  final bool transactionAlerts;
  final bool budgetWarnings;
  final bool promotions;

  NotificationPrefs copyWith({
    bool? push,
    bool? transactionAlerts,
    bool? budgetWarnings,
    bool? promotions,
  }) {
    return NotificationPrefs(
      push: push ?? this.push,
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      budgetWarnings: budgetWarnings ?? this.budgetWarnings,
      promotions: promotions ?? this.promotions,
    );
  }
}

/// Holds [NotificationPrefs] and persists each toggle to SharedPrefs. Seeded in
/// [main] from storage via a provider override.
class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier(super.initial, {SharedPrefsService? prefs})
      : _prefs = prefs ?? SharedPrefsService();

  final SharedPrefsService _prefs;

  static Future<NotificationPrefs> loadSaved([SharedPrefsService? prefs]) async {
    final service = prefs ?? SharedPrefsService();
    Future<bool> read(String key, bool fallback) async {
      return service.getBoolOr(key, fallback);
    }

    return NotificationPrefs(
      push: await read(StorageKeys.notifPush, true),
      transactionAlerts: await read(StorageKeys.notifTransactionAlerts, true),
      budgetWarnings: await read(StorageKeys.notifBudgetWarnings, true),
      promotions: await read(StorageKeys.notifPromotions, false),
    );
  }

  Future<void> setPush(bool v) async {
    state = state.copyWith(push: v);
    await _prefs.setBool(StorageKeys.notifPush, v);
  }

  Future<void> setTransactionAlerts(bool v) async {
    state = state.copyWith(transactionAlerts: v);
    await _prefs.setBool(StorageKeys.notifTransactionAlerts, v);
  }

  Future<void> setBudgetWarnings(bool v) async {
    state = state.copyWith(budgetWarnings: v);
    await _prefs.setBool(StorageKeys.notifBudgetWarnings, v);
  }

  Future<void> setPromotions(bool v) async {
    state = state.copyWith(promotions: v);
    await _prefs.setBool(StorageKeys.notifPromotions, v);
  }
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  (ref) => NotificationPrefsNotifier(const NotificationPrefs()),
);
