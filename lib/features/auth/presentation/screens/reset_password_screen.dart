import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';

@RoutePage()
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _save() {
    // UI-only (Phase 1): back to login with the new password.
    context.router.replaceAll([const LoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowScaffold(
      title: 'Reset Password',
      subtitle: 'Choose a new password for your account.',
      showBack: true,
      children: [
        AppTextField(
          label: 'New Password',
          hint: 'Enter new password',
          controller: _passwordController,
          prefixIcon: LucideIcons.lock,
          obscure: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Confirm New Password',
          hint: 'Re-enter new password',
          controller: _confirmController,
          prefixIcon: LucideIcons.lockKeyhole,
          obscure: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(label: 'Save New Password', onPressed: _save),
      ],
    );
  }
}
