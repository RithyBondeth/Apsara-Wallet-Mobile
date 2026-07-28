import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:apsara_wallet_mobile/features/security/application/app_lock_controller.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/gold_medallion.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/pin_pad.dart';

/// Full-screen unlock surface shown by [AppLockGate] while the app is locked.
/// It is an overlay (not a route) so it can cover any screen and preserve the
/// navigation stack underneath.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Offer biometrics immediately when they're enabled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(appLockControllerProvider).canUseBiometric) {
        _tryBiometric();
      }
    });
  }

  Future<void> _tryBiometric() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await ref
        .read(appLockControllerProvider.notifier)
        .unlockWithBiometric(context.l10n.lockBiometricReason);
    if (!mounted) return;
    setState(() => _busy = false);
    // On success the gate hides this screen automatically; no navigation here.
    if (!ok) setState(() {});
  }

  Future<void> _onDigit(String d) async {
    if (_busy || _pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == 4) {
      final entered = _pin;
      setState(() => _busy = true);
      final result = await ref
          .read(appLockControllerProvider.notifier)
          .unlockWithPin(entered);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _pin = '';
        switch (result) {
          case PinUnlockResult.success:
            _error = null;
          case PinUnlockResult.wrong:
            _error = context.l10n.lockIncorrectPin;
          case PinUnlockResult.lockedOut:
            final secs =
                ref.read(appLockControllerProvider.notifier).lockoutSecondsLeft;
            _error = context.l10n.lockLockedOut(secs);
        }
      });
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _usePassword() async {
    // Escape hatch (e.g. forgotten PIN): sign out to the password login.
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(appLockControllerProvider);
    // Block the system back gesture — the app stays locked until unlocked.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const GoldMedallion(icon: LucideIcons.lockKeyhole),
                const SizedBox(height: AppSpacing.xl),
                Text(context.l10n.lockTitle, style: AppFont.headingMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.lockSubtitle,
                  style: AppFont.bodyMedium.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                PinDots(filled: _pin.length),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 20,
                  child: _error == null
                      ? null
                      : Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppFont.labelLarge
                              .copyWith(color: AppColors.error),
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
                PinPad(onDigit: _onDigit, onBackspace: _onBackspace),
                const SizedBox(height: AppSpacing.lg),
                if (lock.canUseBiometric)
                  TextButton.icon(
                    onPressed: _busy ? null : _tryBiometric,
                    icon: const Icon(LucideIcons.fingerprint,
                        color: AppColors.primary),
                    label: Text(
                      context.l10n.lockUseBiometric,
                      style: AppFont.labelLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: _usePassword,
                  child: Text(
                    context.l10n.lockUsePassword,
                    style: AppFont.labelLarge.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
