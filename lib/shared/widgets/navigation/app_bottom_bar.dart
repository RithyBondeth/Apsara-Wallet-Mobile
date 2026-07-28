import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Minimal line navigation bar.
///
/// A flat, edge-to-edge ivory bar with a hairline top edge and thin line
/// icons. Inactive tabs are icon-only in muted grey; the selected tab warms to
/// emerald and reveals its label, which slides open beneath the icon. The
/// centre "+" is supplied separately as [Scaffold.floatingActionButton] (see
/// [AppBottomBarCenterButton]); this bar leaves a gap for it. Labels are l10n
/// (EN/KH).
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  /// Vertical space the bar occupies above the safe area. Screens set
  /// [Scaffold.extendBody] and add this to their scroll padding so content
  /// clears the bar.
  static const double clearance = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D0B5B3D),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
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
              const SizedBox(width: 64),
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
    );
  }
}

/// One tab. Inactive: a muted line icon, centred. Active: the icon warms to
/// emerald and its label slides open beneath it — the only labelled tab.
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
              Color.lerp(AppColors.textMuted, AppColors.primary, t)!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1 + 0.06 * t,
                child: Icon(icon, size: 23, color: iconColor),
              ),
              // Label reveals only for the active tab: height + opacity
              // animate together so inactive icons stay vertically centred.
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: t,
                  child: Opacity(
                    opacity: t,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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

/// The centre "+" primary action — a calm emerald disc docked on the bar's top
/// edge. Flat and quiet to match the minimal bar (no pulse/glow), still
/// shrinking under the finger like every other tappable surface.
class AppBottomBarCenterButton extends StatelessWidget {
  const AppBottomBarCenterButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.92,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: AppGradients.emerald,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330B5B3D),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 26),
      ),
    );
  }
}
