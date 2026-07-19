import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// One tappable form row on the Add Transaction screen: a tinted leading
/// tile, the current value, and a chevron — Category, Wallet and Date & Time
/// all share this shape (see the design board mockup).
class PickerRow extends StatelessWidget {
  const PickerRow({
    super.key,
    required this.leading,
    required this.label,
    this.trailing,
    this.onTap,
  });

  /// Leading 40x40 tile (icon in a tinted circle, brand tile, …).
  final Widget leading;
  final String label;

  /// Defaults to a chevron.
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          children: [
            SizedBox(width: 40, height: 40, child: leading),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ??
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.textMuted,
                ),
          ],
        ),
      ),
    );
  }
}

/// Standard leading tile for [PickerRow]: an icon in a tinted circle.
class PickerRowIconTile extends StatelessWidget {
  const PickerRowIconTile({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 19, color: color),
    );
  }
}
