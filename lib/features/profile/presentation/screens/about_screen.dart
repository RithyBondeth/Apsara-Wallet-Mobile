import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_section.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_sub_scaffold.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_tile.dart';

/// Honest placeholder for links without a destination yet.
void _comingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      content: Text(
        context.l10n.commonComingSoon,
        style: AppFont.bodyMedium.copyWith(color: Colors.white),
      ),
    ),
  );
}

/// About Apsara Wallet (Phase 1, UI-only): brand block, mission statement and
/// legal / links list.
@RoutePage()
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsSubScaffold(
      title: l10n.aboutTitle,
      children: [
        _BrandBlock(
          name: AppConstants.appName,
          tagline: l10n.aboutTagline,
          version: '${l10n.aboutVersion} ${AppConstants.appVersion}',
        ),
        Container(
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
          child: Text(
            l10n.aboutMission,
            textAlign: TextAlign.center,
            style: AppFont.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        SettingsSection(
          children: [
            SettingsTile(
              icon: LucideIcons.fileText,
              title: l10n.aboutTerms,
              onTap: () => _comingSoon(context),
            ),
            SettingsTile(
              icon: LucideIcons.shieldCheck,
              title: l10n.aboutPrivacy,
              iconColor: AppColors.income,
              onTap: () => _comingSoon(context),
            ),
            SettingsTile(
              icon: LucideIcons.scale,
              title: l10n.aboutLicenses,
              iconColor: AppColors.textSecondary,
              onTap: () => showLicensePage(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
              ),
            ),
            SettingsTile(
              icon: LucideIcons.star,
              title: l10n.aboutRate,
              iconColor: AppColors.warning,
              onTap: () => _comingSoon(context),
            ),
          ],
        ),
      ],
    );
  }
}

/// Centred logo + app name + tagline + version.
class _BrandBlock extends StatelessWidget {
  const _BrandBlock({
    required this.name,
    required this.tagline,
    required this.version,
  });

  final String name;
  final String tagline;
  final String version;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            AssetPathConstant.logo,
            fit: BoxFit.contain,
            semanticLabel: name,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          name,
          style: AppFont.headingSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tagline,
          style: AppFont.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          version,
          style: AppFont.labelMedium.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
