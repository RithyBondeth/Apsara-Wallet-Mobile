import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/pin_pad.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';

@RoutePage()
class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _pin = '';

  void _onDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() => _pin += d);
    if (_pin.length == 4) {
      // UI-only (Phase 1): unlock straight into the dashboard.
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) context.router.replaceAll([const DashboardRoute()]);
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
      title: 'Enter Your PIN',
      subtitle: 'Welcome back — unlock your wallet.',
      scrollable: false,
      children: [
        const SizedBox(height: AppSpacing.xl),
        PinDots(filled: _pin.length),
        const SizedBox(height: AppSpacing.huge),
        PinPad(onDigit: _onDigit, onBackspace: _onBackspace),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: GestureDetector(
            onTap: () => context.router.replace(const LoginRoute()),
            child: Text(
              'Use password instead',
              style: AppFont.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
