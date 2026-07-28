import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// A single row inside a profile / settings group card.
///
/// A tinted icon tile leads, a title (and optional subtitle) fills the middle,
/// and the trailing edge shows one of: a chevron (navigation), a value label,
/// a switch, or a custom widget — depending on which optional is supplied.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor = AppColors.primary,
    this.onTap,
    this.value,
    this.trailing,
    this.showChevron = true,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Accent for the leading icon tile (also drives the destructive variant).
  final Color iconColor;

  final VoidCallback? onTap;

  /// Optional right-aligned value text (e.g. "English", "KHR").
  final String? value;

  /// Optional trailing widget (e.g. a [Switch]); wins over [value]/chevron.
  final Widget? trailing;

  /// Whether to draw the trailing chevron when no [trailing]/[value] is given.
  final bool showChevron;

  /// Red styling for sign-out / delete style rows.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tint = destructive ? AppColors.expense : iconColor;
    final titleColor =
        destructive ? AppColors.expense : AppColors.textPrimary;

    Widget? trailingWidget = trailing;
    trailingWidget ??= value != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value!,
                style: AppFont.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ],
          )
        : (showChevron
            ? const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textMuted,
              )
            : null);

    return PressScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFont.titleSmall.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppFont.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailingWidget,
            ],
          ],
        ),
      ),
    );
  }
}
