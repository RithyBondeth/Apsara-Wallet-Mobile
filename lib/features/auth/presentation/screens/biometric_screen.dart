import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/gold_medallion.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/secondary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';

@RoutePage()
class BiometricScreen extends ConsumerWidget {
  const BiometricScreen({super.key});

  void _finish(BuildContext context) {
    // UI-only (Phase 1): either choice lands on the dashboard.
    context.router.replaceAll([const DashboardRoute()]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthFlowScaffold(
      title: 'Enable Biometric Login',
      subtitle:
          'Sign in with your fingerprint or face — fast, secure and effortless.',
      showBack: true,
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Center(child: GoldMedallion(icon: LucideIcons.fingerprint)),
        const SizedBox(height: AppSpacing.massive),
        PrimaryButton(
          label: 'Enable Biometric',
          onPressed: () => _finish(context),
        ),
        const SizedBox(height: AppSpacing.lg),
        SecondaryButton(
          label: 'Maybe Later',
          onPressed: () => _finish(context),
        ),
      ],
    );
  }
}
