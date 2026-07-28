import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_mock_data.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// A notification as returned by `GET /notifications`. `type` + `data` drive
/// client-side localization; `title`/`body` are the server's English fallback.
class ApiNotification {
  const ApiNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.type,
    this.data,
  });

  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final String? type;
  final Map<String, dynamic>? data;

  factory ApiNotification.fromJson(Map<String, dynamic> json) =>
      ApiNotification(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        read: json['read'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        type: json['type'] as String?,
        data: (json['data'] as Map?)?.cast<String, dynamic>(),
      );

  /// Maps to the app's [AppNotification], resolving localized copy + icon/color
  /// from [type]/[data], with `minutesAgo` computed against [now]. Falls back
  /// to the server-rendered title/body for unknown types.
  AppNotification toAppNotification({required DateTime now}) {
    final minutesAgo = now.difference(createdAt).inMinutes.clamp(0, 1 << 30);
    final copy = _copyFor(type, data ?? const {}, title, body);
    return AppNotification(
      id: id,
      icon: copy.icon,
      color: copy.color,
      minutesAgo: minutesAgo,
      titleOf: copy.titleOf,
      bodyOf: copy.bodyOf,
      read: read,
    );
  }
}

typedef _L10nText = String Function(AppLocalizations l10n);

class _NotifCopy {
  const _NotifCopy(this.icon, this.color, this.titleOf, this.bodyOf);
  final IconData icon;
  final Color color;
  final _L10nText titleOf;
  final _L10nText bodyOf;
}

/// Resolves localized copy + icon/color for a notification type. Unknown types
/// fall back to the server's plain [fallbackTitle]/[fallbackBody].
_NotifCopy _copyFor(
  String? type,
  Map<String, dynamic> data,
  String fallbackTitle,
  String fallbackBody,
) {
  switch (type) {
    case 'recurring_posted':
      final count = (data['count'] as num?)?.toInt() ?? 0;
      return _NotifCopy(
        LucideIcons.repeat,
        AppColors.primary,
        (l) => l.notifTypeRecurringTitle,
        (l) => l.notifTypeRecurringBody(count),
      );
    case 'savings_milestone':
      final name = data['name'] as String? ?? '';
      final pct = (data['pct'] as num?)?.toInt() ?? 0;
      final done = pct >= 100;
      return _NotifCopy(
        LucideIcons.piggyBank,
        AppColors.income,
        (l) => done
            ? l.notifTypeSavingsDoneTitle
            : l.notifTypeSavingsHalfTitle,
        (l) => done
            ? l.notifTypeSavingsDoneBody(name)
            : l.notifTypeSavingsHalfBody(name),
      );
    case 'budget_alert':
      final category = data['category'] as String? ?? '';
      return _NotifCopy(
        LucideIcons.chartPie,
        AppColors.warning,
        (l) => l.notifTypeBudgetTitle,
        (l) => l.notifTypeBudgetBody(category),
      );
    case 'security_login':
      return _NotifCopy(
        LucideIcons.shieldCheck,
        AppColors.info,
        (l) => l.notifTypeSecurityLoginTitle,
        (l) => l.notifTypeSecurityLoginBody,
      );
    case 'security_password':
      return _NotifCopy(
        LucideIcons.lockKeyhole,
        AppColors.warning,
        (l) => l.notifTypeSecurityPasswordTitle,
        (l) => l.notifTypeSecurityPasswordBody,
      );
    case 'security_profile':
      return _NotifCopy(
        LucideIcons.userRound,
        AppColors.info,
        (l) => l.notifTypeSecurityProfileTitle,
        (l) => l.notifTypeSecurityProfileBody,
      );
    default:
      return _NotifCopy(
        LucideIcons.bell,
        AppColors.primary,
        (_) => fallbackTitle,
        (_) => fallbackBody,
      );
  }
}

class NotificationApi {
  NotificationApi(this._api);

  final ApiClient _api;

  Future<List<ApiNotification>> list() async {
    final res = await _api.get<List<dynamic>>('/notifications');
    if (!res.success || res.data == null) return const [];
    return res.data!
        .map((e) => ApiNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> markRead(String id) async {
    final res = await _api.patch<Map<String, dynamic>>('/notifications/$id/read');
    return res.success;
  }

  Future<bool> markAllRead() async {
    final res = await _api.post<Map<String, dynamic>>('/notifications/read-all');
    return res.success;
  }
}

final notificationApiProvider = Provider<NotificationApi>(
  (ref) => NotificationApi(ref.watch(apiClientProvider)),
);
