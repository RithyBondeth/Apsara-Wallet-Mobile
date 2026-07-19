import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';

/// Frosted bottom navigation with a docked emerald action button.
///
/// The centre "+" is supplied separately as the [Scaffold.floatingActionButton]
/// (see [DashboardCenterButton]) so it can sit in the notch; this bar only
/// paints the four tabs around it.
class DashboardBottomBar extends StatelessWidget {
  const DashboardBottomBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      elevation: 0,
      height: 68,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: LucideIcons.house,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => onSelect(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: LucideIcons.chartColumn,
              label: 'Analytics',
              selected: currentIndex == 1,
              onTap: () => onSelect(1),
            ),
          ),
          // Gap for the docked centre button.
          const SizedBox(width: 64),
          Expanded(
            child: _NavItem(
              icon: LucideIcons.wallet,
              label: 'Wallets',
              selected: currentIndex == 2,
              onTap: () => onSelect(2),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: LucideIcons.user,
              label: 'Profile',
              selected: currentIndex == 3,
              onTap: () => onSelect(3),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return InkResponse(
      onTap: onTap,
      radius: 40,
      highlightColor: Colors.transparent,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppFont.labelSmall.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// The raised emerald "+" that docks into the nav-bar notch.
class DashboardCenterButton extends StatelessWidget {
  const DashboardCenterButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x4D0B5B3D),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }
}
