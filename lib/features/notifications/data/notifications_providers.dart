import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/providers/notification_prefs_provider.dart';
import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_api.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';

/// The user's notifications, backed by the API. Tapping a row marks it read;
/// "mark all read" clears every unread. Relative timestamps derive from each
/// notification's `createdAt` against [nowProvider].
class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  NotificationApi get _api => ref.read(notificationApiProvider);

  @override
  Future<List<AppNotification>> build() async {
    final now = ref.watch(nowProvider);
    final apiItems = await _api.list();
    return apiItems.map((n) => n.toAppNotification(now: now)).toList();
  }

  Future<void> markRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final i = current.indexWhere((n) => n.id == id);
    if (i < 0 || current[i].read) return;
    // Optimistic — reflect the read state immediately, then persist.
    final next = [...current];
    next[i] = next[i].copyWith(read: true);
    state = AsyncData(next);
    await _api.markRead(id);
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null || current.every((n) => n.read)) return;
    state = AsyncData([for (final n in current) n.copyWith(read: true)]);
    await _api.markAllRead();
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

/// Whether a notification's category is currently allowed by the user's
/// preferences. Security alerts are never suppressible.
bool _allowedByPrefs(ENotifCategory c, NotificationPrefs p) {
  switch (c) {
    case ENotifCategory.security:
      return true;
    case ENotifCategory.budget:
      return p.budgetWarnings;
    case ENotifCategory.promotion:
      return p.promotions;
    case ENotifCategory.activity:
      return p.transactionAlerts;
  }
}

/// The inbox filtered by the user's notification preferences — the list the
/// UI actually shows. Category toggles (transaction alerts / budget warnings /
/// promotions) hide their notifications; security always shows.
final visibleNotificationsProvider =
    Provider<AsyncValue<List<AppNotification>>>((ref) {
  final prefs = ref.watch(notificationPrefsProvider);
  return ref.watch(notificationsProvider).whenData(
        (items) =>
            items.where((n) => _allowedByPrefs(n.category, prefs)).toList(),
      );
});

/// Count of unread (visible) notifications, for the dashboard bell dot. Returns
/// 0 when the master push toggle is off (no nudge) or while loading.
final unreadNotificationsProvider = Provider<int>((ref) {
  final prefs = ref.watch(notificationPrefsProvider);
  if (!prefs.push) return 0;
  final items = ref.watch(visibleNotificationsProvider).valueOrNull ?? const [];
  return items.where((n) => !n.read).length;
});

/// One-shot: posts this calendar month's insight digest (total expense + count)
/// on app open. The backend dedupes per month, so this is a no-op after the
/// first post; when it does create one, the inbox is refreshed. Awaits the
/// ledger, so it runs once transactions are loaded. FutureProvider caches for
/// the session (fires once).
final insightAutoPostProvider = FutureProvider<void>((ref) async {
  final now = ref.watch(nowProvider);
  final ledger = await ref.watch(transactionsProvider.future);
  final month =
      '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final monthExpenses = ledger.where(
    (t) =>
        t.type == ETransactionType.expense &&
        t.date.year == now.year &&
        t.date.month == now.month,
  );
  final count = monthExpenses.length;
  if (count == 0) return;
  final spentKhr = monthExpenses.fold<int>(0, (s, t) => s + t.amountKhr);

  final created = await ref
      .read(notificationApiProvider)
      .emitInsight(periodKey: month, spentKhr: spentKhr, count: count);
  if (created) ref.invalidate(notificationsProvider);
});
