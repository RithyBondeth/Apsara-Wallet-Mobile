import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/features/insights/data/insights_engine.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// A ready-to-render insight row: an icon tile colour and a localized body.
class InsightView {
  const InsightView({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;
}

/// Turns the engine's pure [Insight]/[InsightsReport] data into localized,
/// themed view models. All copy is resolved from [AppLocalizations] here so the
/// engine stays language- and Flutter-agnostic.
class InsightPresenter {
  const InsightPresenter(this.l10n, this.localeTag);

  final AppLocalizations l10n;
  final String localeTag;

  /// The "Today's Insight" headline sentence.
  String headlineBody(Insight insight) => _bodyOf(insight);

  /// The coaching line beneath the headline, keyed by the headline's kind.
  String headlineCoach(Insight insight) {
    switch (insight.kind) {
      case InsightKind.overspend:
        return l10n.insightsCoachOverspend;
      case InsightKind.savingsPositive:
        return l10n.insightsCoachSaving;
      case InsightKind.categoryUp:
        return l10n.insightsCoachReduce;
      case InsightKind.categoryDown:
        return l10n.insightsCoachKeepGoing;
      case InsightKind.topCategory:
        return l10n.insightsCoachTopCategory;
      case InsightKind.busiestDay:
        return l10n.insightsCoachDefault;
    }
  }

  /// A full view model for a "More Insights" row.
  InsightView view(Insight insight) {
    final (icon, color) = _iconColor(insight.kind);
    return InsightView(icon: icon, color: color, text: _bodyOf(insight));
  }

  /// Short qualitative label shown inside the gauge.
  String scoreLabel(HealthBand band) {
    switch (band) {
      case HealthBand.needsWork:
        return l10n.insightsScoreNeedsWork;
      case HealthBand.fair:
        return l10n.insightsScoreFair;
      case HealthBand.good:
        return l10n.insightsScoreGood;
      case HealthBand.excellent:
        return l10n.insightsScoreExcellent;
    }
  }

  Color scoreColor(HealthBand band) {
    switch (band) {
      case HealthBand.needsWork:
        return AppColors.expense;
      case HealthBand.fair:
        return AppColors.warning;
      case HealthBand.good:
      case HealthBand.excellent:
        return AppColors.income;
    }
  }

  /// The headline line of the health card (savings rate, or overspend).
  String healthSummary(InsightsReport report) {
    final pct = report.savingsRatePercent;
    return pct >= 0
        ? l10n.insightsHealthSavings(pct)
        : l10n.insightsHealthOverspent(pct.abs());
  }

  /// Band-specific encouragement beneath the summary.
  String healthEncouragement(HealthBand band) {
    switch (band) {
      case HealthBand.needsWork:
        return l10n.insightsEncourageNeedsWork;
      case HealthBand.fair:
        return l10n.insightsEncourageFair;
      case HealthBand.good:
        return l10n.insightsEncourageGood;
      case HealthBand.excellent:
        return l10n.insightsEncourageExcellent;
    }
  }

  // --- internals ------------------------------------------------------------

  (IconData, Color) _iconColor(InsightKind kind) {
    switch (kind) {
      case InsightKind.topCategory:
        return (LucideIcons.chartPie, AppColors.info);
      case InsightKind.busiestDay:
        return (LucideIcons.calendarDays, AppColors.info);
      case InsightKind.categoryUp:
        return (LucideIcons.trendingUp, AppColors.expense);
      case InsightKind.categoryDown:
        return (LucideIcons.trendingDown, AppColors.income);
      case InsightKind.savingsPositive:
        return (LucideIcons.piggyBank, AppColors.income);
      case InsightKind.overspend:
        return (LucideIcons.triangleAlert, AppColors.warning);
    }
  }

  String _bodyOf(Insight insight) {
    switch (insight.kind) {
      case InsightKind.topCategory:
        return l10n.insightTopCategory(
          _category(insight.categoryId),
          _khr(insight.amountKhr ?? 0),
          insight.percent ?? 0,
        );
      case InsightKind.busiestDay:
        return l10n.insightBusiestDay(_weekday(insight.weekday ?? 1));
      case InsightKind.categoryUp:
        return l10n.insightCategoryUp(
          insight.percent ?? 0,
          _category(insight.categoryId),
        );
      case InsightKind.categoryDown:
        return l10n.insightCategoryDown(
          insight.percent ?? 0,
          _category(insight.categoryId),
        );
      case InsightKind.savingsPositive:
        return l10n.insightSavingsPositive(
          _khr(insight.amountKhr ?? 0),
          insight.percent ?? 0,
        );
      case InsightKind.overspend:
        return l10n.insightOverspend(_khr(insight.amountKhr ?? 0));
    }
  }

  String _category(String? id) =>
      categoryById(id ?? 'othersExpense').labelOf(l10n);

  /// Localized full weekday name (Monday…Sunday). 2024-01-01 is a Monday, so
  /// offsetting by `weekday - 1` lands on the requested day.
  String _weekday(int weekday) => DateFormat.EEEE(localeTag)
      .format(DateTime(2024, 1, 1).add(Duration(days: weekday - 1)));

  /// "KHR 1,234,000" — matches how amounts read elsewhere in the app.
  String _khr(int value) => 'KHR ${NumberFormat.decimalPattern('en').format(value)}';
}
