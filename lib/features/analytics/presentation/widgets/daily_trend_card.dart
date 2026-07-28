import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/analytics/data/analytics_mock_data.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/widgets/line_chart.dart';

/// "Daily Expense Trend" card wrapping the line chart.
class DailyTrendCard extends StatelessWidget {
  const DailyTrendCard({
    super.key,
    required this.data,
    required this.progress,
    this.title,
  });

  final AnalyticsData data;
  final double progress;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? context.l10n.analyticsDailyExpenseTrend,
            style: AppFont.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LineChart(
            values: data.dailyTrend,
            maxValue: data.trendMax,
            axisLabels: data.trendAxisLabels,
            progress: progress,
          ),
        ],
      ),
    );
  }
}
