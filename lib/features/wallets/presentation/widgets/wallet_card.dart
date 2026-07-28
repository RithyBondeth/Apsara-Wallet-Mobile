import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// One funding source in the wallets list: a branded logo tile, the wallet's
/// name and type/account line, and its balance in KHR (with a small USD sub).
class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.wallet,
    required this.balanceHidden,
    this.onTap,
    this.balanceKhr,
    this.balanceUsd,
  });

  final Wallet wallet;
  final bool balanceHidden;
  final VoidCallback? onTap;

  /// Ledger-derived balance to show; falls back to the wallet's own seed
  /// balance when not supplied.
  final int? balanceKhr;
  final double? balanceUsd;

  @override
  Widget build(BuildContext context) {
    final khr = balanceKhr ?? wallet.balanceKhr;
    final usd = balanceUsd ?? wallet.balanceUsd;
    final subtitle = wallet.maskedAccount == null
        ? wallet.kind.label
        : '${wallet.kind.label} · ${wallet.maskedAccount}';

    return PressScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
            _LogoTile(wallet: wallet),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          wallet.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.titleSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (wallet.isPrimary) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const _PrimaryBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppFont.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balanceHidden ? 'KHR ••••••' : 'KHR ${formatKhr(khr)}',
                  style: AppFont.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  balanceHidden ? '≈ ••••' : '≈ \$${formatUsd(usd)}',
                  style: AppFont.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded brand tile — a short code ("ABA") when present, else a glyph.
class _LogoTile extends StatelessWidget {
  const _LogoTile({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            wallet.brandColor,
            Color.lerp(wallet.brandColor, Colors.black, 0.22)!,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: wallet.brandColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: wallet.shortCode != null
          ? Text(
              wallet.shortCode!,
              style: AppFont.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            )
          : Icon(
              wallet.icon ?? LucideIcons.wallet,
              color: Colors.white,
              size: 24,
            ),
    );
  }
}

/// Tiny emerald "Primary" pill next to the default wallet's name.
class _PrimaryBadge extends StatelessWidget {
  const _PrimaryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        context.l10n.walletCardPrimaryBadge,
        style: AppFont.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
