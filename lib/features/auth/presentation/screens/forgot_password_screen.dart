import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';

@RoutePage()
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _sendCode() {
    // UI-only (Phase 1): continue straight to the reset screen.
    context.router.push(const ResetPasswordRoute());
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowScaffold(
      title: context.l10n.commonForgotPassword,
      subtitle: context.l10n.forgotPasswordSubtitle,
      showBack: true,
      children: [
        AppTextField(
          label: context.l10n.authIdentifierLabel,
          hint: context.l10n.authIdentifierHint,
          controller: _identifierController,
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _sendCode(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
            label: context.l10n.forgotPasswordSendCta, onPressed: _sendCode),
        const SizedBox(height: AppSpacing.xxl),
        Center(
          child: GestureDetector(
            onTap: () => context.router.maybePop(),
            child: Text(
              context.l10n.forgotPasswordBackToLogin,
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
