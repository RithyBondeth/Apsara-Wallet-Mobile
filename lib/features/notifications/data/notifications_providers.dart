import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/providers/notification_prefs_provider.dart';
import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_api.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_models.dart';
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
      return ref
          .watch(notificationsProvider)
          .whenData(
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

/// Posts this calendar month's insight digest (total expense + count) once
/// the ledger has loaded. The backend dedupes per month; when it does create
/// one, the inbox is refreshed. Note the provider re-runs whenever the ledger
/// changes — [_insightPeriodsPosted] is what makes it fire once per month.
/// Periods this session has already sent an insight for. The provider
/// re-runs on every ledger change (it watches the ledger), and two rebuilds in
/// quick succession used to fire two concurrent posts that both passed the
/// server's dedupe check — one digest a month is the whole point, so the
/// second attempt is dropped here before it leaves the device.
final _insightPeriodsPosted = <String>{};

final insightAutoPostProvider = FutureProvider<void>((ref) async {
  final now = ref.watch(nowProvider);
  final ledger = await ref.watch(transactionsProvider.future);
  final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  if (_insightPeriodsPosted.contains(month)) return;
  final monthExpenses = ledger.where(
    (t) =>
        t.type == ETransactionType.expense &&
        t.date.year == now.year &&
        t.date.month == now.month,
  );
  final count = monthExpenses.length;
  if (count == 0) return;
  final spentKhr = monthExpenses.fold<int>(0, (s, t) => s + t.amountKhr);

  _insightPeriodsPosted.add(month);
  final created = await ref
      .read(notificationApiProvider)
      .emitInsight(periodKey: month, spentKhr: spentKhr, count: count);
  if (created) ref.invalidate(notificationsProvider);
});
