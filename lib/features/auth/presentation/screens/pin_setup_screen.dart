import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/security/biometric_service.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/security/application/app_lock_controller.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/pin_pad.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';

/// Enrol / change the app-lock PIN: enter four digits, then confirm them, and
/// the salted hash is stored via [AppLockController].
///
/// Two entry points:
/// * from **Security** ([isOnboarding] = false) — saving pops back.
/// * right after **signup** ([isOnboarding] = true) — offers a Skip, and on
///   save continues to the biometric opt-in (or straight to the dashboard if
///   the device has no biometrics).
@RoutePage()
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key, this.isOnboarding = false});

  final bool isOnboarding;

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = '';
  String? _firstEntry;
  String? _error;
  bool _saving = false;

  bool get _confirming => _firstEntry != null;

  Future<void> _onDigit(String d) async {
    if (_saving || _pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length < 4) return;

    if (!_confirming) {
      // First pass captured — ask for confirmation.
      setState(() {
        _firstEntry = _pin;
        _pin = '';
      });
      return;
    }

    // Confirmation pass.
    if (_pin != _firstEntry) {
      setState(() {
        _error = context.l10n.pinMismatch;
        _pin = '';
        _firstEntry = null;
      });
      return;
    }

    setState(() => _saving = true);
    await ref.read(appLockControllerProvider.notifier).setPin(_pin);
    if (!mounted) return;

    if (widget.isOnboarding) {
      // Continue enrolment: offer biometrics if the device supports them.
      final canBiometric = await ref.read(biometricServiceProvider).isAvailable();
      if (!mounted) return;
      context.router.replaceAll([
        if (canBiometric)
          BiometricRoute(isOnboarding: true)
        else
          const DashboardRoute(),
      ]);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(context.l10n.pinUpdated),
      ),
    );
    context.router.maybePop();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowScaffold(
      title: _confirming
          ? context.l10n.pinConfirmTitle
          : context.l10n.pinSetupTitle,
      subtitle: _confirming
          ? context.l10n.pinConfirmSubtitle
          : context.l10n.pinSetupSubtitle,
      showBack: !widget.isOnboarding,
      scrollable: false,
      children: [
        const SizedBox(height: AppSpacing.xl),
        PinDots(filled: _pin.length),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 20,
          child: _error == null
              ? null
              : Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppFont.labelLarge.copyWith(color: AppColors.error),
                ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PinPad(onDigit: _onDigit, onBackspace: _onBackspace),
        if (widget.isOnboarding) ...[
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: _saving
                  ? null
                  : () => context.router.replaceAll([const DashboardRoute()]),
              child: Text(
                context.l10n.commonSkip,
                style: AppFont.labelLarge.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
