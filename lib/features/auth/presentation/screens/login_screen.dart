import 'dart:math' as math;

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
import 'package:apsara_wallet_mobile/shared/widgets/brand/aurora_background.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/social_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// One-shot entrance cascade.
  late final AnimationController _intro;

  /// Endless ambient loop: aurora drift + living emblem.
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // UI-only (Phase 1): jump straight to the dashboard with mock data.
    context.router.replace(const DashboardRoute());
  }

  /// Shorthand: each block enters on its own slice of the cascade.
  Widget _enter(double start, double end, Widget child,
      {Offset offset = const Offset(0, 28), double? scaleFrom}) {
    return FadeSlideIn(
      controller: _intro,
      start: start,
      end: end,
      offset: offset,
      scaleFrom: scaleFrom,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- Living backdrop: subtle aurora + rising gold motes --------
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) =>
                AuroraBackground(t: _ambient.value, moteCount: 14),
          ),

          SafeArea(
            child: GestureDetector(
              onTap: context.hideKeyboard,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // --- Brand: living emblem ------------------------------
                    _enter(
                      0.0,
                      0.4,
                      Center(child: _buildLivingEmblem()),
                      offset: const Offset(0, -20),
                      scaleFrom: 0.75,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    _enter(
                      0.10,
                      0.45,
                      Text('Welcome back', style: AppFont.headingMedium),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _enter(
                      0.16,
                      0.50,
                      Text(
                        'Sign in to continue to your ${AppConstants.appName}.',
                        style: AppFont.bodyMedium.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // --- Fields --------------------------------------------
                    _enter(
                      0.24,
                      0.58,
                      AppTextField(
                        label: 'Email',
                        hint: 'you@example.com',
                        controller: _emailController,
                        prefixIcon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _enter(
                      0.32,
                      0.66,
                      AppTextField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passwordController,
                        prefixIcon: LucideIcons.lock,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                      ),
                    ),

                    // --- Forgot password -----------------------------------
                    _enter(
                      0.40,
                      0.72,
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
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _enter(
                      0.46,
                      0.80,
                      PrimaryButton(
                        label: 'Log In',
                        trailingIcon: LucideIcons.arrowRight,
                        onPressed: _login,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // --- Divider -------------------------------------------
                    _enter(0.54, 0.85, const _OrDivider()),
                    const SizedBox(height: AppSpacing.xl),

                    // --- Social --------------------------------------------
                    _enter(
                      0.60,
                      0.90,
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
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // --- Register ------------------------------------------
                    _enter(
                      0.68,
                      1.0,
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
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The emblem breathes: its tick ring orbits slowly while the halo pulses,
  /// echoing the splash screen so the brand feels continuous across screens.
  Widget _buildLivingEmblem() {
    return AnimatedBuilder(
      animation: _ambient,
      builder: (context, _) {
        final t = _ambient.value;
        final glowPulse = 0.45 + 0.25 * math.sin(t * 2 * math.pi * 3);
        return ApsaraEmblem(size: 72, ringTurns: t, glow: glowPulse);
      },
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
