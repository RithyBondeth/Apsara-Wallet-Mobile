import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/language_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/providers/locale_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';

/// Lets the user switch between English and Khmer. Reads and updates
/// [localeProvider], so the whole app (and its font) re-renders in the chosen
/// language immediately.
///
/// Two looks:
/// * default — a light pill showing a globe + the active language, for use over
///   the auth backdrop and other light surfaces;
/// * [LanguageSwitcher.compact] — a translucent circular globe button that sits
///   over dark/emerald surfaces (e.g. the dashboard header) next to siblings
///   like the notification bell.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key}) : compact = false;

  const LanguageSwitcher.compact({super.key}) : compact = true;

  /// Circular icon-only button for dark surfaces when true; light pill when
  /// false.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);

    return PopupMenuButton<ELanguage>(
      initialValue: current,
      tooltip: current.englishName,
      onSelected: (language) =>
          ref.read(localeProvider.notifier).setLanguage(language),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      itemBuilder: (context) => [
        for (final language in ELanguage.values)
          PopupMenuItem<ELanguage>(
            value: language,
            child: Row(
              children: [
                if (language == current)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(LucideIcons.check,
                        size: 16, color: AppColors.primary),
                  ),
                Text(language.nativeName),
              ],
            ),
          ),
      ],
      child: compact ? _compactChild() : _pillChild(context, current),
    );
  }

  /// Light pill: globe + active language + chevron.
  Widget _pillChild(BuildContext context, ELanguage current) {
    final border = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.textMuted.withValues(alpha: 0.35);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.globe, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            current.nativeName,
            style: AppFont.labelLarge.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: context.colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// Translucent circular globe button for dark/emerald surfaces.
  Widget _compactChild() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: const Icon(LucideIcons.globe, size: 20, color: Colors.white),
    );
  }
}
