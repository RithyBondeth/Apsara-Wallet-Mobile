import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/auth_ui_helpers.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/social_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/or_divider.dart';

@RoutePage()
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _nameError;
  String? _identifierError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _identifierController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _nameError = name.isEmpty ? context.l10n.authErrorNameRequired : null;
      _identifierError = email.isEmpty
          ? context.l10n.authErrorEmailRequired
          : (!isValidEmail(email) ? context.l10n.authErrorEmailInvalid : null);
      _passwordError = password.isEmpty
          ? context.l10n.authErrorPasswordRequired
          : (password.length < 8
              ? context.l10n.authErrorPasswordTooShort
              : null);
      _confirmError =
          confirm != password ? context.l10n.authErrorPasswordMismatch : null;
    });
    if (_nameError != null ||
        _identifierError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    context.hideKeyboard();
    final ok = await ref.read(authControllerProvider.notifier).register(
          email: email,
          fullName: name,
          password: password,
        );
    if (!mounted) return;

    if (ok) {
      // Account created and a session issued — go straight into the app.
      context.router.replaceAll([const DashboardRoute()]);
    } else {
      showAuthSnackBar(
        context,
        ref.read(authControllerProvider).errorMessage ??
            context.l10n.authSessionExpired,
      );
    }
  }

  void _socialUnavailable() =>
      showAuthSnackBar(context, context.l10n.authSocialComingSoon);

  @override
  Widget build(BuildContext context) {
    final submitting =
        ref.watch(authControllerProvider.select((s) => s.isSubmitting));
    return AuthFlowScaffold(
      title: context.l10n.registerTitle,
      subtitle: context.l10n.registerSubtitle,
      showBack: true,
      children: [
        AppTextField(
          label: context.l10n.registerNameLabel,
          hint: context.l10n.registerNameHint,
          controller: _nameController,
          prefixIcon: LucideIcons.userRound,
          textInputAction: TextInputAction.next,
          errorText: _nameError,
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: context.l10n.authIdentifierLabel,
          hint: context.l10n.authIdentifierHint,
          controller: _identifierController,
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: _identifierError,
          onChanged: (_) {
            if (_identifierError != null) {
              setState(() => _identifierError = null);
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: context.l10n.registerPasswordLabel,
          hint: context.l10n.registerPasswordHint,
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
          label: context.l10n.registerConfirmPasswordLabel,
          hint: context.l10n.registerConfirmPasswordHint,
          controller: _confirmController,
          prefixIcon: LucideIcons.lockKeyhole,
          obscure: true,
          textInputAction: TextInputAction.done,
          errorText: _confirmError,
          onChanged: (_) {
            if (_confirmError != null) setState(() => _confirmError = null);
          },
          onSubmitted: (_) => _register(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: context.l10n.registerTitle,
          loading: submitting,
          onPressed: submitting ? null : _register,
        ),
        const SizedBox(height: AppSpacing.xxl),
        const OrDivider(),
        const SizedBox(height: AppSpacing.xl),
        SocialButton(
          svg: BrandSvg.google,
          label: context.l10n.authContinueWithGoogle,
          onPressed: _socialUnavailable,
        ),
        const SizedBox(height: AppSpacing.lg),
        SocialButton(
          svg: BrandSvg.facebook,
          label: context.l10n.authContinueWithFacebook,
          onPressed: _socialUnavailable,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                context.l10n.registerHasAccountPrompt,
                style: AppFont.bodyMedium.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: () => context.router.replace(const LoginRoute()),
                child: Text(
                  context.l10n.commonLogin,
                  style: AppFont.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
