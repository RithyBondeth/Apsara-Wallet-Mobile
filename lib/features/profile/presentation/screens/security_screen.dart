import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_section.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_sub_scaffold.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_tile.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_toggle.dart';

/// Security & Privacy preferences (Phase 1, UI-only): authentication options
/// and privacy switches. Toggles hold local state; the chevron rows show a
/// "coming soon" note since PIN/password flows aren't built yet.
@RoutePage()
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometric = true;
  bool _twoFactor = false;
  bool _appLock = true;
  bool _hideBalance = false;

  void _comingSoon() {
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsSubScaffold(
      title: l10n.securityTitle,
      children: [
        SettingsSection(
          title: l10n.securitySectionAuth,
          children: [
            SettingsTile(
              icon: LucideIcons.lockKeyhole,
              title: l10n.securityChangePin,
              subtitle: l10n.securityChangePinSubtitle,
              onTap: _comingSoon,
            ),
            SettingsTile(
              icon: LucideIcons.fingerprint,
              title: l10n.securityBiometric,
              subtitle: l10n.securityBiometricSubtitle,
              iconColor: AppColors.income,
              showChevron: false,
              trailing: SettingsToggle(
                value: _biometric,
                onChanged: (v) => setState(() => _biometric = v),
              ),
            ),
            SettingsTile(
              icon: LucideIcons.shieldCheck,
              title: l10n.securityTwoFactor,
              subtitle: l10n.securityTwoFactorSubtitle,
              iconColor: AppColors.info,
              showChevron: false,
              trailing: SettingsToggle(
                value: _twoFactor,
                onChanged: (v) => setState(() => _twoFactor = v),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: l10n.securitySectionPrivacy,
          children: [
            SettingsTile(
              icon: LucideIcons.keyRound,
              title: l10n.securityChangePassword,
              subtitle: l10n.securityChangePasswordSubtitle,
              onTap: _comingSoon,
            ),
            SettingsTile(
              icon: LucideIcons.smartphone,
              title: l10n.securityAppLock,
              subtitle: l10n.securityAppLockSubtitle,
              iconColor: AppColors.warning,
              showChevron: false,
              trailing: SettingsToggle(
                value: _appLock,
                onChanged: (v) => setState(() => _appLock = v),
              ),
            ),
            SettingsTile(
              icon: LucideIcons.eyeOff,
              title: l10n.securityHideBalance,
              subtitle: l10n.securityHideBalanceSubtitle,
              iconColor: AppColors.textSecondary,
              showChevron: false,
              trailing: SettingsToggle(
                value: _hideBalance,
                onChanged: (v) => setState(() => _hideBalance = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}
