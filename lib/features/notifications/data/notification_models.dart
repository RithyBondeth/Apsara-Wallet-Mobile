import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// Which notification-preference toggle a notification answers to. `security`
/// is never suppressible (login/password/profile alerts always surface).
enum ENotifCategory { activity, budget, security, promotion }

/// A single inbox notification. Title/body resolve their copy
/// via l10n functions — like [InsightTip] / [TxCategory] — so the whole inbox
/// follows the language switcher. [minutesAgo] is a fixed offset (not a real
/// clock) so grouping and goldens stay deterministic.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.icon,
    required this.color,
    required this.minutesAgo,
    required this.titleOf,
    required this.bodyOf,
    this.read = false,
    this.category = ENotifCategory.activity,
  });

  final String id;
  final IconData icon;
  final Color color;
  final int minutesAgo;
  final String Function(AppLocalizations l10n) titleOf;
  final String Function(AppLocalizations l10n) bodyOf;
  final bool read;
  final ENotifCategory category;

  /// Today = within the last 24h; anything older groups under "Earlier".
  bool get isToday => minutesAgo < 1440;

  String relativeLabel(AppLocalizations l10n) {
    if (minutesAgo < 1) return l10n.notifJustNow;
    if (minutesAgo < 60) return l10n.notifMinutesAgo(minutesAgo);
    if (minutesAgo < 1440) return l10n.notifHoursAgo(minutesAgo ~/ 60);
    if (minutesAgo < 2880) return l10n.notifYesterday;
    return l10n.notifDaysAgo(minutesAgo ~/ 1440);
  }

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    icon: icon,
    color: color,
    minutesAgo: minutesAgo,
    titleOf: titleOf,
    bodyOf: bodyOf,
    read: read ?? this.read,
    category: category,
  );
}
