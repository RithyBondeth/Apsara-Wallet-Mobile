import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/add_tx_pickers.dart'
    show WalletBrandTile;
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// A single wallet/account: an emerald balance hero and the transactions
/// recorded against it (live from [transactionsProvider], matched by name).
@RoutePage()
class WalletDetailScreen extends ConsumerStatefulWidget {
  const WalletDetailScreen({super.key, required this.index});

  final int index;

  @override
  ConsumerState<WalletDetailScreen> createState() =>
      _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  String _kindLabel(BuildContext context, WalletKind kind) => switch (kind) {
        WalletKind.bank => context.l10n.walletTypeBank,
        WalletKind.cash => context.l10n.walletTypeCash,
        WalletKind.ewallet => context.l10n.walletTypeEwallet,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = Localizations.localeOf(context).toString();
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    final wallets = ref.watch(walletsProvider).valueOrNull ?? const [];
    if (widget.index < 0 || widget.index >= wallets.length) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final wallet = wallets[widget.index];
    final balance = ref.watch(walletBalancesProvider)[wallet.name];

    final txs = (ref.watch(transactionsProvider).valueOrNull ?? [])
        .where((t) => t.walletName == wallet.name)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FadeSlideIn(
                controller: _intro,
                start: 0.0,
                end: 0.4,
                offset: const Offset(0, 10),
                child: _AppBar(title: wallet.name),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.md,
                    AppSpacing.xxl,
                    bottomSafe + AppSpacing.xxxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.08,
                        end: 0.5,
                        child: _BalanceHero(
                          wallet: wallet,
                          balanceKhr: balance?.khr ?? wallet.balanceKhr,
                          balanceUsd: balance?.usd ?? wallet.balanceUsd,
                          kindLabel: _kindLabel(context, wallet.kind),
                          balanceLabel: l10n.walletBalanceLabel,
                          primaryLabel: l10n.walletCardPrimaryBadge,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.18,
                        end: 0.6,
                        child: Text(
                          l10n.walletRecentActivity,
                          style: AppFont.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (txs.isEmpty)
                        FadeSlideIn(
                          controller: _intro,
                          start: 0.24,
                          end: 0.7,
                          child: _EmptyActivity(label: l10n.walletNoActivity),
                        )
                      else
                        for (var i = 0; i < txs.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.md),
                          FadeSlideIn(
                            controller: _intro,
                            start: (0.24 + i * 0.06).clamp(0.0, 0.7),
                            end: (0.64 + i * 0.06).clamp(0.0, 1.0),
                            child: _ActivityTile(
                              record: txs[i],
                              localeTag: localeTag,
                              onTap: () => context.router.push(
                                TransactionDetailRoute(id: txs[i].id),
                              ),
                            ),
                          ),
                        ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          PressScale(
            onTap: () => context.router.maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: const Icon(
                LucideIcons.chevronLeft,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({
    required this.wallet,
    required this.balanceKhr,
    required this.balanceUsd,
    required this.kindLabel,
    required this.balanceLabel,
    required this.primaryLabel,
  });

  final Wallet wallet;
  final int balanceKhr;
  final double balanceUsd;
  final String kindLabel;
  final String balanceLabel;
  final String primaryLabel;

  static const Color _ivory = Color(0xFFF3F1E7);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WalletBrandTile(wallet: wallet, size: 46),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: AppFont.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      wallet.maskedAccount ?? kindLabel,
                      style: AppFont.bodySmall.copyWith(
                        color: _ivory.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (wallet.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.goldFoil,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    primaryLabel,
                    style: AppFont.labelSmall.copyWith(
                      color: const Color(0xFF5A420E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            balanceLabel,
            style: AppFont.labelMedium.copyWith(
              color: _ivory.withValues(alpha: 0.8),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'KHR ',
                style: AppFont.titleMedium.copyWith(
                  color: AppGradients.goldLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                formatKhr(balanceKhr),
                style: AppFont.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '≈ USD ${formatUsd(balanceUsd)}',
            style: AppFont.bodyMedium.copyWith(
              color: _ivory.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.record,
    required this.localeTag,
    required this.onTap,
  });

  final TransactionRecord record;
  final String localeTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = record;
    final amountColor =
        t.isIncome ? AppColors.income : AppColors.textPrimary;
    return PressScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(t.category.icon, color: t.category.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.category.labelOf(l10n)} · ${t.timeLabel(localeTag)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${t.sign} KHR ${formatKhr(t.amountKhr)}',
              style: AppFont.titleSmall.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.receiptText,
            size: 30,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppFont.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
