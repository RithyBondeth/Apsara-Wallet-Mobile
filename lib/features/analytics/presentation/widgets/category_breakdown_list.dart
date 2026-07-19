import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/analytics/data/analytics_mock_data.dart';

/// The Categories tab: every expense category ranked with an icon tile,
/// amount, share and a proportional bar. [progress] eases the bars in.
class CategoryBreakdownList extends StatelessWidget {
  const CategoryBreakdownList({
    super.key,
    required this.data,
    required this.progress,
  });

  final AnalyticsData data;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final sorted = [...data.categories]
      ..sort((a, b) => b.amountKhr.compareTo(a.amountKhr));

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
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.analyticsSpendingByCategory,
                  style: AppFont.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'KHR ${formatKhr(data.totalExpenseKhr)}',
                style: AppFont.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < sorted.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.xl),
            _CategoryRow(category: sorted[i], progress: progress),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.progress});

  final ExpenseCategory category;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final c = category;
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(c.icon, color: c.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: AppFont.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'KHR ${formatKhr(c.amountKhr)}',
                    style: AppFont.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${c.percent}%',
              style: AppFont.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: AppColors.surfaceVariant,
                ),
                Container(
                  height: 8,
                  width: constraints.maxWidth *
                      (c.fraction * progress).clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: c.color,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
