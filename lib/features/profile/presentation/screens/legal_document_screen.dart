import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/data/legal_content.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_sub_scaffold.dart';

/// Terms of Service — a real, readable legal page (was a "coming soon" stub).
@RoutePage()
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentView(
      title: context.l10n.settingsTermsOfService,
      document: LegalContent.terms,
    );
  }
}

/// Privacy Policy — a real, readable legal page (was a "coming soon" stub).
@RoutePage()
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentView(
      title: context.l10n.settingsPrivacyPolicy,
      document: LegalContent.privacy,
    );
  }
}

/// Renders a [LegalDocument] inside the shared profile sub-page chrome: an
/// intro card carrying the "last updated" stamp and lead paragraph, followed
/// by one card per section. The [SettingsSubScaffold] cascades each card in.
class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({
    super.key,
    required this.title,
    required this.document,
  });

  final String title;
  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsSubScaffold(
      title: title,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.legalLastUpdated} ${document.lastUpdated}',
                style: AppFont.labelMedium.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              _Paragraph(document.intro),
            ],
          ),
        ),
        for (final section in document.sections)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.heading,
                  style: AppFont.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (var i = 0; i < section.paragraphs.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _Paragraph(section.paragraphs[i]),
                ],
              ],
            ),
          ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.legalContactHeading,
                style: AppFont.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _Paragraph(AppConstants.supportEmail),
            ],
          ),
        ),
      ],
    );
  }
}

/// White rounded container matching the About screen's mission card.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
      child: child,
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFont.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }
}
