import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/pin_pad.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';

@RoutePage()
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = '';

  void _onDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() => _pin += d);
    if (_pin.length == 4) {
      // UI-only (Phase 1): continue to biometric opt-in.
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) context.router.push(const BiometricRoute());
      });
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowScaffold(
      title: 'Set Your PIN',
      subtitle: 'A 4-digit PIN keeps your wallet extra safe.',
      showBack: true,
      scrollable: false,
      children: [
        const SizedBox(height: AppSpacing.xl),
        PinDots(filled: _pin.length),
        const SizedBox(height: AppSpacing.huge),
        PinPad(onDigit: _onDigit, onBackspace: _onBackspace),
      ],
    );
  }
}
