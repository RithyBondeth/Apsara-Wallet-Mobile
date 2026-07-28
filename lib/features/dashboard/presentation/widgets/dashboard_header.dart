import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/features/dashboard/data/dashboard_mock_data.dart';
import 'package:apsara_wallet_mobile/shared/widgets/controls/language_switcher.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/count_up_text.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/shimmer_sweep.dart';

/// The emerald hero at the top of the dashboard: greeting, notifications,
/// the drifting apsara brand mark, and the total-balance readout with a
/// privacy toggle.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.data,
    required this.ambient,
    required this.balanceHidden,
    required this.onToggleBalance,
    required this.onTapBell,
    required this.onOpenMenu,
    this.hasUnread = false,
  });

  final DashboardData data;
  final AnimationController ambient;
  final bool balanceHidden;
  final VoidCallback onToggleBalance;
  final VoidCallback onTapBell;
  final VoidCallback onOpenMenu;
  final bool hasUnread;

  static const Color _ivory = Color(0xFFF3F1E7);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.emerald,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xxl),
          bottomRight: Radius.circular(AppRadius.xxl),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x330B5B3D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // --- Drifting apsara brand mark (soft, top-right) ----------------
          Positioned(
            top: topInset + 6,
            right: -14,
            child: _FloatingApsara(ambient: ambient),
          ),

          Padding(
            // Extra bottom room so the USD line clears the action cards
            // that float up over the header's lower edge.
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              topInset + AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.huge + AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _greetingRow(context),
                const SizedBox(height: AppSpacing.xxl),
                _balanceBlock(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _greetingRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MenuButton(onTap: onOpenMenu),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.dashboardGreeting,
                style: AppFont.bodyMedium.copyWith(
                  color: _ivory.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${data.userName} 👋',
                style: AppFont.headingSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const LanguageSwitcher.compact(),
        const SizedBox(width: AppSpacing.sm),
        _BellButton(onTap: onTapBell, hasUnread: hasUnread),
      ],
    );
  }

  TextStyle get _khrStyle => AppFont.headingLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  TextStyle get _usdStyle =>
      AppFont.bodyMedium.copyWith(color: _ivory.withValues(alpha: 0.75));

  /// Cross-fades between the real amount and its privacy-dot stand-in with a
  /// small vertical drift, so toggling the eye feels like a reveal.
  Widget _revealSwitcher({
    required bool hidden,
    required Widget hiddenChild,
    required Widget child,
  }) {
    return AnimatedSwitcher(
      duration: AppDurations.medium,
      switchInCurve: AppCurves.entrance,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (w, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.35),
            end: Offset.zero,
          ).animate(anim),
          child: w,
        ),
      ),
      child: hidden ? hiddenChild : child,
    );
  }

  Widget _balanceBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.dashboardTotalBalance,
              style: AppFont.labelLarge.copyWith(
                color: _ivory.withValues(alpha: 0.80),
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
                  balanceHidden ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: _ivory.withValues(alpha: 0.80),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'KHR',
              style: AppFont.titleMedium.copyWith(
                color: AppGradients.goldLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _revealSwitcher(
              hidden: balanceHidden,
              hiddenChild: Text(
                '••••••••',
                key: const ValueKey('khr-hidden'),
                style: _khrStyle,
              ),
              child: ShimmerSweep(
                key: const ValueKey('khr-shown'),
                child: CountUpText(
                  value: data.balanceKhr,
                  formatter: (v) => formatKhr(v.round()),
                  style: _khrStyle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        _revealSwitcher(
          hidden: balanceHidden,
          hiddenChild: Text(
            '≈ USD ••••••',
            key: const ValueKey('usd-hidden'),
            style: _usdStyle,
          ),
          child: CountUpText(
            key: const ValueKey('usd-shown'),
            value: data.balanceUsd,
            formatter: (v) => '≈ USD ${formatUsd(v)}',
            style: _usdStyle,
          ),
        ),
      ],
    );
  }
}

/// Circular translucent notification button with an unread dot.
/// Translucent circular hamburger that opens the side menu.
class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: const Icon(LucideIcons.menu, size: 20, color: Colors.white),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap, this.hasUnread = false});

  final VoidCallback onTap;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(LucideIcons.bell, size: 20, color: Colors.white),
            if (hasUnread)
              Positioned(
                top: 11,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppGradients.goldCore,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppGradients.emeraldCore,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The brand apsara mark, gently bobbing and breathing a gold halo — driven
/// by the shared ambient loop so the header always feels alive.
class _FloatingApsara extends StatelessWidget {
  const _FloatingApsara({required this.ambient});

  final AnimationController ambient;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (context, child) {
        final phase = ambient.value * 2 * math.pi;
        final pulse = 0.75 + 0.25 * math.sin(phase * 2);
        return Transform.translate(
          offset: Offset(0, 4 * math.sin(phase)),
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppGradients.goldLight.withValues(alpha: 0.22 * pulse),
                        AppGradients.goldLight.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                child!,
              ],
            ),
          ),
        );
      },
      child: Opacity(
        opacity: 0.92,
        child: Image.asset(
          AssetPathConstant.logo,
          width: 118,
          height: 118,
          fit: BoxFit.contain,
          semanticLabel: '${AppConstants.appName} emblem',
        ),
      ),
    );
  }
}
