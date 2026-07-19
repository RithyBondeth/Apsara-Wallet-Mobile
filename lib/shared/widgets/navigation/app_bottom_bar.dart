import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Floating frosted-glass navigation capsule.
///
/// Redesigned from the old edge-to-edge notched [BottomAppBar]: the bar now
/// hovers above the bottom inset as a blurred ivory capsule with a gold
/// hairline, and the selected tab sits in an emerald pill that fades/pops in.
/// Labels come from l10n (EN/KH). The centre "+" is still supplied separately
/// as the [Scaffold.floatingActionButton] (see [AppBottomBarCenterButton]) so
/// it can overlap the capsule's rim; this bar leaves a gap for it.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  /// Vertical space the floating capsule occupies above the safe area
  /// (bar height + bottom margin). Screens set [Scaffold.extendBody] and add
  /// this to their scroll padding so content clears the bar.
  static const double clearance = 76;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: SizedBox(
        height: 66,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppGradients.goldCore.withValues(alpha: 0.28),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x260B5B3D),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.house,
                      label: l10n.navHome,
                      selected: currentIndex == 0,
                      onTap: () => onSelect(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.chartColumn,
                      label: l10n.navAnalytics,
                      selected: currentIndex == 1,
                      onTap: () => onSelect(1),
                    ),
                  ),
                  // Gap for the docked centre button.
                  const SizedBox(width: 68),
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.wallet,
                      label: l10n.navWallets,
                      selected: currentIndex == 2,
                      onTap: () => onSelect(2),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.user,
                      label: l10n.navProfile,
                      selected: currentIndex == 3,
                      onTap: () => onSelect(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One tab: the icon pops with a little overshoot into an emerald pill when
/// selected; the label warms from muted grey to emerald underneath.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.90,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1.0 : 0.0),
        duration: AppDurations.medium,
        curve: AppCurves.emphasized,
        builder: (context, v, _) {
          final t = v.clamp(0.0, 1.0);
          final iconColor =
              Color.lerp(AppColors.textMuted, Colors.white, t)!;
          final labelColor =
              Color.lerp(AppColors.textMuted, AppColors.primary, t)!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 27,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: t > 0.01 ? AppGradients.emerald : null,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    if (t > 0.01)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35 * t),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Transform.scale(
                  scale: 1 + 0.08 * t,
                  child: Icon(icon, size: 20, color: iconColor),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.labelSmall.copyWith(
                  color: labelColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The raised emerald "+" that overlaps the capsule's rim — breathing a soft
/// gold-tinged glow so the primary action quietly asks for attention, and
/// shrinking under the finger like every other tappable surface.
class AppBottomBarCenterButton extends StatefulWidget {
  const AppBottomBarCenterButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<AppBottomBarCenterButton> createState() =>
      _AppBottomBarCenterButtonState();
}

class _AppBottomBarCenterButtonState extends State<AppBottomBarCenterButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppDurations.pulseLoop,
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: widget.onTap,
      pressedScale: 0.92,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          // 0..1..0 breath across the loop.
          final breath =
              0.5 + 0.5 * math.sin(_pulse.value * 2 * math.pi - math.pi / 2);
          return Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppGradients.emerald,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppGradients.goldLight.withValues(
                  alpha: 0.35 + 0.35 * breath,
                ),
                width: 1.6,
              ),
              boxShadow: [
                const BoxShadow(
                  color: Color(0x4D0B5B3D),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.18 + 0.20 * breath,
                  ),
                  blurRadius: 18 + 10 * breath,
                  spreadRadius: 1 + 3 * breath,
                ),
              ],
            ),
            child: child,
          );
        },
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }
}
