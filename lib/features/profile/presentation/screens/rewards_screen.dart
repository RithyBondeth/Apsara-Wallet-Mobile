import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_sub_scaffold.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Rewards & Offers (Phase 1, UI-only): a gold points card and a list of
/// claimable offers. Redeem / Claim just confirm with a snackbar.
@RoutePage()
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  /// Dark brown reads cleanly on the gold foil (same as the membership badge).
  static const Color _onGold = Color(0xFF5A420E);

  void _confirm(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Text(
          message,
          style: AppFont.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offers = [
      (LucideIcons.utensils, l10n.rewardsOffer1Title, l10n.rewardsOffer1Body),
      (LucideIcons.arrowRightLeft, l10n.rewardsOffer2Title,
          l10n.rewardsOffer2Body),
      (LucideIcons.sparkles, l10n.rewardsOffer3Title, l10n.rewardsOffer3Body),
    ];

    return SettingsSubScaffold(
      title: l10n.rewardsTitle,
      children: [
        _PointsCard(
          pointsLabel: l10n.rewardsPointsLabel,
          tier: l10n.rewardsTier,
          redeem: l10n.rewardsRedeem,
          onGold: _onGold,
          onRedeem: () => _confirm(context, l10n.rewardsClaimed),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Text(
                l10n.rewardsSectionOffers.toUpperCase(),
                style: AppFont.labelMedium.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < offers.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              _OfferCard(
                icon: offers[i].$1,
                title: offers[i].$2,
                body: offers[i].$3,
                claimLabel: l10n.rewardsClaim,
                onClaim: () => _confirm(context, l10n.rewardsClaimed),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({
    required this.pointsLabel,
    required this.tier,
    required this.redeem,
    required this.onGold,
    required this.onRedeem,
  });

  final String pointsLabel;
  final String tier;
  final String redeem;
  final Color onGold;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppGradients.goldFoil,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33957400),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                pointsLabel,
                style: AppFont.labelLarge.copyWith(
                  color: onGold.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Icon(LucideIcons.crown, size: 20, color: onGold),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '2,450',
            style: AppFont.headingLarge.copyWith(
              color: onGold,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: onGold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  tier,
                  style: AppFont.labelMedium.copyWith(
                    color: onGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              PressScale(
                onTap: onRedeem,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: onGold,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    redeem,
                    style: AppFont.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.claimLabel,
    required this.onClaim,
  });

  final IconData icon;
  final String title;
  final String body;
  final String claimLabel;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppGradients.goldCore.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppGradients.goldDeep, size: 21),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFont.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AppFont.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PressScale(
            onTap: onClaim,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                claimLabel,
                style: AppFont.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
