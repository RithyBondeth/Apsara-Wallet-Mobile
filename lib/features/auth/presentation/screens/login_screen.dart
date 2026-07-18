import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/aurora_background.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/social_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/or_divider.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  /// One-shot entrance cascade.
  late final AnimationController _intro;

  /// Endless ambient loop: aurora drift.
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
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // UI-only (Phase 1): jump straight to the dashboard with mock data.
    context.router.replace(const DashboardRoute());
  }

  /// Shorthand: each block enters on its own slice of the cascade.
  Widget _enter(double start, double end, Widget child,
      {Offset offset = const Offset(0, 28)}) {
    return FadeSlideIn(
      controller: _intro,
      start: start,
      end: end,
      offset: offset,
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
                    const SizedBox(height: AppSpacing.xxxl),

                    // --- Heading -------------------------------------------
                    _enter(
                      0.0,
                      0.4,
                      Text('Login', style: AppFont.headingLarge),
                      offset: const Offset(-24, 0),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _enter(
                      0.08,
                      0.46,
                      Text(
                        'Welcome back! Please login to continue.',
                        style: AppFont.bodyMedium.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // --- Fields --------------------------------------------
                    _enter(
                      0.18,
                      0.54,
                      AppTextField(
                        label: 'Email or Phone Number',
                        hint: 'Enter email or phone number',
                        controller: _identifierController,
                        prefixIcon: LucideIcons.user,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _enter(
                      0.26,
                      0.62,
                      AppTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        prefixIcon: LucideIcons.lock,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                      ),
                    ),

                    // --- Forgot password -----------------------------------
                    _enter(
                      0.34,
                      0.68,
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              context.router.push(const ForgotPasswordRoute()),
                          child: Text(
                            'Forgot Password?',
                            style: AppFont.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _enter(
                      0.42,
                      0.76,
                      PrimaryButton(label: 'Login', onPressed: _login),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // --- Divider -------------------------------------------
                    _enter(0.50, 0.82, const OrDivider()),
                    const SizedBox(height: AppSpacing.xl),

                    // --- Social --------------------------------------------
                    _enter(
                      0.58,
                      0.88,
                      SocialButton(
                        svg: BrandSvg.google,
                        label: 'Continue with Google',
                        onPressed: _login,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _enter(
                      0.64,
                      0.93,
                      SocialButton(
                        svg: BrandSvg.facebook,
                        label: 'Continue with Facebook',
                        onPressed: _login,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // --- Sign up -------------------------------------------
                    _enter(
                      0.72,
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
                                'Sign up',
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
}
