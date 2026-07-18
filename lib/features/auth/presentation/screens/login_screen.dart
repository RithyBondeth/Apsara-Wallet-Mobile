import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/apsara_emblem.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/social_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // UI-only (Phase 1): jump straight to the dashboard with mock data.
    context.router.replace(const DashboardRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: context.hideKeyboard,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),

                // --- Brand -------------------------------------------------
                Center(child: const ApsaraEmblem(size: 64, glow: 0.6)),
                const SizedBox(height: AppSpacing.xxxl),

                Text('Welcome back', style: AppFont.headingMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sign in to continue to your ${AppConstants.appName}.',
                  style: AppFont.bodyMedium.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // --- Fields ------------------------------------------------
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailController,
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  prefixIcon: LucideIcons.lock,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                ),

                // --- Forgot password --------------------------------------
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.router.push(const ForgotPasswordRoute()),
                    child: Text(
                      'Forgot password?',
                      style: AppFont.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                PrimaryButton(
                  label: 'Log In',
                  trailingIcon: LucideIcons.arrowRight,
                  onPressed: _login,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // --- Divider ----------------------------------------------
                const _OrDivider(),
                const SizedBox(height: AppSpacing.xl),

                // --- Social ------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: SocialButton(
                        svg: BrandSvg.google,
                        label: 'Google',
                        onPressed: _login,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: SocialButton(
                        svg: BrandSvg.facebook,
                        label: 'Facebook',
                        onPressed: _login,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // --- Register ---------------------------------------------
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppFont.bodyMedium.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.router.push(const RegisterRoute()),
                        child: Text(
                          'Register',
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
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(
        color: context.colors.onSurfaceVariant.withValues(alpha: 0.25),
        thickness: 1,
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or continue with',
            style: AppFont.bodySmall.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        line,
      ],
    );
  }
}
