import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/analytics/data/analytics_mock_data.dart';

/// Three quick stats under the Trends tab — average, peak and total spend
/// derived from the daily series.
class TrendSummaryRow extends StatelessWidget {
  const TrendSummaryRow({super.key, required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final series = data.dailyTrend;
    final total = series.fold<double>(0, (a, b) => a + b);
    final avg = series.isEmpty ? 0.0 : total / series.length;
    final peak = series.isEmpty ? 0.0 : series.reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: LucideIcons.chartNoAxesColumn,
            label: context.l10n.analyticsAvgPerDay,
            value: formatKhr(avg.round()),
            tint: AppColors.info,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatTile(
            icon: LucideIcons.trendingUp,
            label: context.l10n.analyticsPeakDay,
            value: formatKhr(peak.round()),
            tint: AppColors.expense,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatTile(
            icon: LucideIcons.wallet,
            label: context.l10n.analyticsTotal,
            value: formatKhr(total.round()),
            tint: AppGradients.goldCore,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppFont.labelSmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppFont.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
