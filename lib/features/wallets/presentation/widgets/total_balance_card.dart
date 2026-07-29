import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/providers/money_format_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/count_up_text.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/shimmer_sweep.dart';

/// The emerald "Total Balance" hero at the top of the Wallets screen — an
/// Angkor-temple card ([AssetPathConstant.walletBackground]) with the combined
/// balance across every wallet, a KHR/USD readout and a privacy toggle.
class TotalBalanceCard extends StatelessWidget {
  const TotalBalanceCard({
    super.key,
    required this.data,
    required this.balanceHidden,
    required this.onToggleBalance,
  });

  final WalletsData data;
  final bool balanceHidden;
  final VoidCallback onToggleBalance;

  static const Color _ivory = Color(0xFFF3F1E7);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Emerald base fills the card edge-to-edge so the artwork's transparent
        // margins/rounded corners read as part of the card instead of letting
        // the page background show through as a lighter frame.
        gradient: AppGradients.emerald,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330B5B3D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Stack(
          children: [
            // Temple + gold-mandala artwork fills the card.
            Positioned.fill(
              child: Image.asset(
                AssetPathConstant.walletBackground,
                fit: BoxFit.cover,
              ),
            ),
            // Emerald scrim keeps the left-aligned text legible over the art.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppGradients.emeraldDeep.withValues(alpha: 0.82),
                      AppGradients.emeraldCore.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.dashboardTotalBalance,
                        style: AppFont.labelLarge.copyWith(
                          color: _ivory.withValues(alpha: 0.85),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onToggleBalance,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            balanceHidden
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                            size: 18,
                            color: _ivory.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Scale the balance down on narrow cards / large amounts so
                  // the KHR readout never overflows.
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Consumer(
                            builder: (context, ref, _) => Text(
                              ref.watch(moneyFormatterProvider).code,
                              style: AppFont.titleMedium.copyWith(
                                color: AppGradients.goldLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          if (balanceHidden)
                            Text(
                              '••••••••',
                              style: AppFont.headingLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            )
                          else
                            ShimmerSweep(
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final money =
                                      ref.watch(moneyFormatterProvider);
                                  return CountUpText(
                                    value: data.totalBalanceKhr,
                                    formatter: (v) => money.number(v.round()),
                                    style: AppFont.headingLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Consumer(
                    builder: (context, ref, _) {
                      final isUsd = ref.watch(moneyFormatterProvider).currency ==
                          ECurrencyType.usd;
                      final text = balanceHidden
                          ? (isUsd ? '≈ KHR ••••••' : '≈ USD ••••••')
                          : (isUsd
                              ? '≈ KHR ${formatKhr(data.totalBalanceKhr)}'
                              : '≈ USD ${formatUsd(data.totalBalanceUsd)}');
                      return Text(
                        text,
                        style: AppFont.bodyMedium.copyWith(
                          color: _ivory.withValues(alpha: 0.78),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _WalletCountChip(count: data.walletCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small translucent pill: "4 wallets".
class _WalletCountChip extends StatelessWidget {
  const _WalletCountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.wallet, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            context.l10n.walletsWalletCount(count),
            style: AppFont.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
