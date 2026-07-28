import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_section.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_sub_scaffold.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_tile.dart';

const String _supportEmail = 'support@apsarawallet.com';
const String _supportPhone = '+855 23 999 888';

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      content: Text(
        message,
        style: AppFont.bodyMedium.copyWith(color: Colors.white),
      ),
    ),
  );
}

/// Opens [uri] in the appropriate external app (mail client, dialer). Falls
/// back to a snackbar if no handler is available.
Future<void> _launch(BuildContext context, Uri uri) async {
  final launched =
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    _snack(context, context.l10n.commonComingSoon);
  }
}

/// Help & Support (Phase 1, UI-only): contact channels and an expandable FAQ.
@RoutePage()
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final faqs = [
      (l10n.helpFaq1Q, l10n.helpFaq1A),
      (l10n.helpFaq2Q, l10n.helpFaq2A),
      (l10n.helpFaq3Q, l10n.helpFaq3A),
    ];

    return SettingsSubScaffold(
      title: l10n.helpTitle,
      children: [
        SettingsSection(
          title: l10n.helpSectionContact,
          children: [
            SettingsTile(
              icon: LucideIcons.messageCircle,
              title: l10n.helpChat,
              subtitle: l10n.helpChatSubtitle,
              onTap: () => _snack(context, l10n.commonComingSoon),
            ),
            SettingsTile(
              icon: LucideIcons.mail,
              title: l10n.helpEmail,
              subtitle: _supportEmail,
              iconColor: AppColors.info,
              onTap: () => _launch(
                context,
                Uri(scheme: 'mailto', path: _supportEmail),
              ),
            ),
            SettingsTile(
              icon: LucideIcons.phone,
              title: l10n.helpCall,
              subtitle: _supportPhone,
              iconColor: AppColors.income,
              onTap: () => _launch(
                context,
                Uri(scheme: 'tel', path: _supportPhone.replaceAll(' ', '')),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Text(
                l10n.helpSectionFaq.toUpperCase(),
                style: AppFont.labelMedium.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (var i = 0; i < faqs.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.surfaceVariant,
                      ),
                    _FaqItem(question: faqs[i].$1, answer: faqs[i].$2),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A single expandable FAQ row — question always visible; the answer reveals
/// with a rotate-chevron and size animation on tap.
class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _open = !_open),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: AppFont.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: AppDurations.fast,
                  child: const Icon(
                    LucideIcons.chevronDown,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  widget.answer,
                  style: AppFont.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: AppDurations.fast,
            ),
          ],
        ),
      ),
    );
  }
}
