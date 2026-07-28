import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/auth/data/auth_repository.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/auth_ui_helpers.dart';
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
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _identifierController.text.trim();
    setState(() {
      _error = email.isEmpty
          ? context.l10n.authErrorEmailRequired
          : (!isValidEmail(email) ? context.l10n.authErrorEmailInvalid : null);
    });
    if (_error != null) return;

    context.hideKeyboard();
    setState(() => _busy = true);
    String? token;
    try {
      token =
          await ref.read(authRepositoryProvider).requestPasswordReset(email);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      showAuthSnackBar(context, context.l10n.forgotPasswordFailed);
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);

    if (token != null) {
      // Dev builds hand back the reset token (no email service) — continue.
      context.router.push(ResetPasswordRoute(token: token));
    } else {
      // No account (or production) — show the non-enumerating message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(context.l10n.forgotPasswordSent),
        ),
      );
    }
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
          errorText: _error,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _sendCode(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: context.l10n.forgotPasswordSendCta,
          loading: _busy,
          onPressed: _busy ? null : _sendCode,
        ),
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
