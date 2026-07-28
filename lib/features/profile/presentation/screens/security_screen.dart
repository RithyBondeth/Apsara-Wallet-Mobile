import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:apsara_wallet_mobile/features/security/application/app_lock_controller.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

/// Security & Privacy. The authentication rows are now live: the app-lock
/// PIN and biometric unlock are backed by [AppLockController]; the remaining
/// rows (2FA, change password) are still placeholders.
@RoutePage()
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _twoFactor = false;
  bool _hideBalance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(appLockControllerProvider).isLoaded) {
        ref.read(appLockControllerProvider.notifier).load();
      }
    });
  }

  void _toast(String message) {
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

  void _comingSoon() => _toast(context.l10n.commonComingSoon);

  Future<void> _onAppLockChanged(bool wantOn) async {
    final notifier = ref.read(appLockControllerProvider.notifier);
    if (wantOn) {
      // Enabling app-lock == setting a PIN.
      await context.router.push(PinSetupRoute());
    } else {
      await notifier.disableLock();
      if (mounted) _toast(context.l10n.securityAppLockOff);
    }
  }

  Future<void> _onBiometricChanged(bool wantOn) async {
    final notifier = ref.read(appLockControllerProvider.notifier);
    final lock = ref.read(appLockControllerProvider);
    if (wantOn) {
      if (!lock.isPinSet) {
        _toast(context.l10n.securityNeedPinFirst);
        return;
      }
      if (!lock.isBiometricAvailable) {
        _toast(context.l10n.securityBiometricUnavailable);
        return;
      }
      final ok = await notifier
          .enableBiometric(context.l10n.securityEnableBiometricReason);
      if (!ok && mounted) _toast(context.l10n.securityBiometricUnavailable);
    } else {
      await notifier.disableBiometric();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lock = ref.watch(appLockControllerProvider);
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
              onTap: () => context.router.push(PinSetupRoute()),
            ),
            SettingsTile(
              icon: LucideIcons.fingerprint,
              title: l10n.securityBiometric,
              subtitle: l10n.securityBiometricSubtitle,
              iconColor: AppColors.income,
              showChevron: false,
              trailing: SettingsToggle(
                value: lock.isBiometricEnabled,
                onChanged: _onBiometricChanged,
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
                value: lock.isPinSet,
                onChanged: _onAppLockChanged,
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
