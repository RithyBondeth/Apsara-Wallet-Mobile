import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_api.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_mock_data.dart';

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

/// Count of unread notifications, for the dashboard bell badge. 0 while loading.
final unreadNotificationsProvider = Provider<int>((ref) {
  final items = ref.watch(notificationsProvider).valueOrNull ?? const [];
  return items.where((n) => !n.read).length;
});
