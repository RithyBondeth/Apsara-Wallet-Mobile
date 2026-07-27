import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/security/application/app_lock_controller.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/gold_medallion.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/secondary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';

/// Biometric opt-in, shown as the final step of post-signup enrolment (after a
/// PIN has been set). "Enable" runs a live scan to switch biometric unlock on;
/// either choice then lands on the dashboard.
@RoutePage()
class BiometricScreen extends ConsumerStatefulWidget {
  const BiometricScreen({super.key, this.isOnboarding = false});

  final bool isOnboarding;

  @override
  ConsumerState<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends ConsumerState<BiometricScreen> {
  bool _busy = false;

  void _toDashboard() {
    context.router.replaceAll([const DashboardRoute()]);
  }

  Future<void> _enable() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref
        .read(appLockControllerProvider.notifier)
        .enableBiometric(context.l10n.securityEnableBiometricReason);
    if (!mounted) return;
    // Whether or not the scan succeeded, the PIN is already set — move on.
    _toDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowScaffold(
      title: context.l10n.biometricTitle,
      subtitle: context.l10n.biometricSubtitle,
      showBack: !widget.isOnboarding,
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Center(child: GoldMedallion(icon: LucideIcons.fingerprint)),
        const SizedBox(height: AppSpacing.massive),
        PrimaryButton(
          label: context.l10n.biometricEnableCta,
          loading: _busy,
          onPressed: _busy ? null : _enable,
        ),
        const SizedBox(height: AppSpacing.lg),
        SecondaryButton(
          label: context.l10n.biometricLaterCta,
          onPressed: _busy ? () {} : _toDashboard,
        ),
      ],
    );
  }
}
