import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/auth/data/auth_repository.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/auth_ui_helpers.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';

@RoutePage()
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  /// The reset token from the forgot-password step.
  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _passwordError;
  String? _confirmError;
  bool _busy = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    setState(() {
      _passwordError = password.length < 8
          ? context.l10n.authErrorPasswordTooShort
          : null;
      _confirmError =
          confirm != password ? context.l10n.authErrorPasswordMismatch : null;
    });
    if (_passwordError != null || _confirmError != null) return;

    context.hideKeyboard();
    setState(() => _busy = true);
    final ok = await ref.read(authRepositoryProvider).resetPassword(
          token: widget.token,
          newPassword: password,
        );
    if (!mounted) return;
    setState(() => _busy = false);

    if (!ok) {
      showAuthSnackBar(context, context.l10n.resetPasswordFailed);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(context.l10n.resetPasswordSuccess),
      ),
    );
    context.router.replaceAll([const LoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowScaffold(
      title: context.l10n.resetPasswordTitle,
      subtitle: context.l10n.resetPasswordSubtitle,
      showBack: true,
      children: [
        AppTextField(
          label: context.l10n.resetPasswordNewLabel,
          hint: context.l10n.resetPasswordNewHint,
          controller: _passwordController,
          prefixIcon: LucideIcons.lock,
          obscure: true,
          textInputAction: TextInputAction.next,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: context.l10n.resetPasswordConfirmLabel,
          hint: context.l10n.resetPasswordConfirmHint,
          controller: _confirmController,
          prefixIcon: LucideIcons.lockKeyhole,
          obscure: true,
          textInputAction: TextInputAction.done,
          errorText: _confirmError,
          onChanged: (_) {
            if (_confirmError != null) setState(() => _confirmError = null);
          },
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: context.l10n.resetPasswordSaveCta,
          loading: _busy,
          onPressed: _busy ? null : _save,
        ),
      ],
    );
  }
}
