import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/language_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/providers/locale_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';

/// A compact pill that shows the active language and lets the user switch
/// between English and Khmer. Reads and updates [localeProvider], so the whole
/// app (and its font) re-renders in the chosen language immediately.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final border = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.textMuted.withValues(alpha: 0.35);

    return PopupMenuButton<ELanguage>(
      initialValue: current,
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
      child: Container(
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
      ),
    );
  }
}
