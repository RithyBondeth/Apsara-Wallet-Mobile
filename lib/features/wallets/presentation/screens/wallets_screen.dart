import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/widgets/add_wallet_sheet.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/widgets/total_balance_card.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/widgets/wallet_card.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_bottom_bar.dart';

/// Wallets — the combined-balance hero plus a card list of every funding
/// source (bank, cash, e-wallet). Phase 1 UI with mock data.
@RoutePage()
class WalletsScreen extends ConsumerStatefulWidget {
  const WalletsScreen({super.key});

  @override
  ConsumerState<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends ConsumerState<WalletsScreen>
    with SingleTickerProviderStateMixin {
  /// One-shot entrance cascade.
  late final AnimationController _intro;

  bool _balanceHidden = false;

  Future<void> _addWallet() async {
    final wallet = await showAddWalletSheet(context);
    if (wallet == null || !mounted) return;
    ref.read(walletsProvider.notifier).add(wallet);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Text(
          context.l10n.walletAdded,
          style: AppFont.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _onNavSelect(int index) {
    if (index == 2) return; // already on Wallets
    switch (index) {
      case 0:
        // Home is the stack root — pop back to it rather than stacking.
        context.router.maybePop();
      case 1:
        // Sibling tab: swap in place so the stack stays [Dashboard, tab].
        context.router.replace(const AnalyticsRoute());
      case 3:
        context.router.push(const ProfileRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final wallets = ref.watch(walletsProvider);
    final balances = ref.watch(walletBalancesProvider);
    final total = ref.watch(walletsTotalProvider);
    final data = WalletsData(
      totalBalanceKhr: total.khr,
      totalBalanceUsd: total.usd,
      wallets: wallets,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        // Body flows under the floating nav capsule so its blur has content.
        extendBody: true,
        floatingActionButton: AppBottomBarCenterButton(
          onTap: () => context.router.push(const ScanReceiptRoute()),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar:
            AppBottomBar(currentIndex: 2, onSelect: _onNavSelect),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _AppBar(onAddWallet: _addWallet),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.sm,
                    AppSpacing.xxl,
                    bottomSafe + AppBottomBar.clearance + AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.0,
                        end: 0.5,
                        offset: const Offset(0, 14),
                        child: TotalBalanceCard(
                          data: data,
                          balanceHidden: _balanceHidden,
                          onToggleBalance: () => setState(
                            () => _balanceHidden = !_balanceHidden,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.16,
                        end: 0.62,
                        child: _SectionHeader(count: wallets.length),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (var i = 0; i < wallets.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.md),
                        FadeSlideIn(
                          controller: _intro,
                          start: (0.24 + i * 0.10).clamp(0.0, 0.8),
                          end: (0.68 + i * 0.10).clamp(0.0, 1.0),
                          offset: const Offset(0, 20),
                          child: WalletCard(
                            wallet: wallets[i],
                            balanceHidden: _balanceHidden,
                            balanceKhr: balances[wallets[i].name]?.khr,
                            balanceUsd: balances[wallets[i].name]?.usd,
                            onTap: () => context.router.push(
                              WalletDetailRoute(index: i),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.7,
                        end: 1.0,
                        child: _AddWalletCard(onTap: _addWallet),
                      ),
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

/// Centered "Wallets" title with a trailing add-wallet button.
class _AppBar extends StatelessWidget {
  const _AppBar({required this.onAddWallet});

  final VoidCallback onAddWallet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          const SizedBox(width: 44),
          Expanded(
            child: Text(
              context.l10n.walletsTitle,
              textAlign: TextAlign.center,
              style: AppFont.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PressScale(
            onTap: onAddWallet,
            pressedScale: 0.9,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                LucideIcons.plus,
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "My Wallets" row with a count on the trailing edge.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.profileMyWallets,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            context.l10n.walletsCountTotal(count),
            style: AppFont.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Dashed "Add Wallet" call-to-action at the end of the list.
class _AddWalletCard extends StatelessWidget {
  const _AddWalletCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: DottedBorderBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.plus,
                size: 20,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.walletsAddWallet,
                style: AppFont.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded rectangle with a dashed emerald border, painted via [CustomPaint].
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.primary.withValues(alpha: 0.45),
        radius: AppRadius.xl,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 6.0;
    const dashGap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
