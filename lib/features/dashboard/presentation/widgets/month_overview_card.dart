import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/dashboard/data/dashboard_mock_data.dart';

/// "This Month Overview" summary card — income vs expense totals and an
/// animated budget-usage bar.
class MonthOverviewCard extends StatelessWidget {
  const MonthOverviewCard({
    super.key,
    required this.data,
    required this.progress,
  });

  final DashboardData data;

  /// 0..1 fill for the budget bar, tweened by the entrance controller.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (data.budgetUsedFraction * 100).round();

    return Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.dashboardMonthOverviewTitle,
                  style: AppFont.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                data.monthLabel,
                style: AppFont.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: context.l10n.dashboardIncome,
                  amountKhr: data.monthIncomeKhr,
                  color: AppColors.income,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: context.l10n.dashboardExpense,
                  amountKhr: data.monthExpenseKhr,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _BudgetBar(progress: progress),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.dashboardRemaining,
                      style: AppFont.labelMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // Budget target = this month's income; remaining is what
                      // is left after this month's spend (floored at zero).
                      'KHR ${formatKhr((data.budgetKhr - data.monthExpenseKhr).clamp(0, data.budgetKhr))}',
                      style: AppFont.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$pct%',
                style: AppFont.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.amountKhr,
    required this.color,
  });

  final String label;
  final int amountKhr;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFont.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'KHR ${formatKhr(amountKhr)}',
          style: AppFont.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Rounded track with a gold-to-emerald gradient fill.
class _BudgetBar extends StatelessWidget {
  const _BudgetBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                color: AppColors.surfaceVariant,
              ),
              Container(
                height: 10,
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppGradients.emeraldGlow, AppColors.primary],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
