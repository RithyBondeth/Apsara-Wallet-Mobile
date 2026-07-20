import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// A single notification (Phase 1, UI-only). Title/body resolve their copy
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
  });

  final String id;
  final IconData icon;
  final Color color;
  final int minutesAgo;
  final String Function(AppLocalizations l10n) titleOf;
  final String Function(AppLocalizations l10n) bodyOf;
  final bool read;

  /// Today = within the last 24h; anything older groups under "Earlier".
  bool get isToday => minutesAgo < 1440;

  String relativeLabel(AppLocalizations l10n) {
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
      );
}

/// The Phase-1 sample inbox — a mix of read/unread, today/earlier.
List<AppNotification> sampleNotifications() => [
      AppNotification(
        id: 'tx',
        icon: LucideIcons.arrowDownLeft,
        color: AppColors.income,
        minutesAgo: 25,
        titleOf: (l) => l.notifTxTitle,
        bodyOf: (l) => l.notifTxBody,
      ),
      AppNotification(
        id: 'budget',
        icon: LucideIcons.chartPie,
        color: AppColors.warning,
        minutesAgo: 180,
        titleOf: (l) => l.notifBudgetTitle,
        bodyOf: (l) => l.notifBudgetBody,
      ),
      AppNotification(
        id: 'security',
        icon: LucideIcons.shieldCheck,
        color: AppColors.info,
        minutesAgo: 480,
        titleOf: (l) => l.notifSecurityTitle,
        bodyOf: (l) => l.notifSecurityBody,
      ),
      AppNotification(
        id: 'reward',
        icon: LucideIcons.gift,
        color: AppGradients.goldCore,
        minutesAgo: 1560, // yesterday
        titleOf: (l) => l.notifRewardTitle,
        bodyOf: (l) => l.notifRewardBody,
        read: true,
      ),
      AppNotification(
        id: 'insight',
        icon: LucideIcons.sparkles,
        color: const Color(0xFF6C63D2),
        minutesAgo: 2880, // 2 days
        titleOf: (l) => l.notifInsightTitle,
        bodyOf: (l) => l.notifInsightBody,
        read: true,
      ),
      AppNotification(
        id: 'bill',
        icon: LucideIcons.receipt,
        color: AppColors.expense,
        minutesAgo: 4320, // 3 days
        titleOf: (l) => l.notifBillTitle,
        bodyOf: (l) => l.notifBillBody,
        read: true,
      ),
    ];
