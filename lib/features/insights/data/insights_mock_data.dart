import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// UI-only mock data for the AI Insights screen (Phase 1). Copy lives in
/// l10n (resolved via functions, like the category catalog) so the whole
/// screen follows the language switcher.
class InsightTip {
  const InsightTip({
    required this.icon,
    required this.color,
    required this.bodyOf,
  });

  final IconData icon;
  final Color color;
  final String Function(AppLocalizations l10n) bodyOf;
}

class InsightsData {
  const InsightsData({required this.healthScore, required this.tips});

  /// 0..100 — drives the gauge.
  final int healthScore;
  final List<InsightTip> tips;

  static const InsightsData sample = InsightsData(
    healthScore: 78,
    tips: [
      InsightTip(
        icon: LucideIcons.calendarDays,
        color: AppColors.info,
        bodyOf: _weekend,
      ),
      InsightTip(
        icon: LucideIcons.repeat,
        color: AppGradients.goldDeep,
        bodyOf: _subscriptions,
      ),
      InsightTip(
        icon: LucideIcons.piggyBank,
        color: AppColors.income,
        bodyOf: _saving,
      ),
    ],
  );

  static String _weekend(AppLocalizations l) => l.insightsWeekendTip;
  static String _subscriptions(AppLocalizations l) => l.insightsSubscriptionsTip;
  static String _saving(AppLocalizations l) => l.insightsSavingTip;
}
