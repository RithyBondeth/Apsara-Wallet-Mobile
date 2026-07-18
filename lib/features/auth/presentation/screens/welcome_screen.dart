import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/aurora_background.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/secondary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';

/// First screen after the splash: the apsara welcomes the user and offers
/// the two paths in — Get Started (new user tour) or Login.
@RoutePage()
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  /// One-shot entrance cascade.
  late final AnimationController _intro;

  /// Endless ambient loop: aurora drift + floating apsara.
  late final AnimationController _ambient;

  /// UI-only (Phase 1): selected language chip state.
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- Misty temple backdrop + living aurora ----------------------
          const Image(
            image: AssetImage(AssetPathConstant.authBackground),
            fit: BoxFit.cover,
          ),
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) => AuroraBackground(t: _ambient.value),
          ),

          SafeArea(
            // Scroll-safe: Spacers breathe on tall screens, content scrolls
            // instead of overflowing on short ones.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                  const SizedBox(height: AppSpacing.md),

                  // --- Language chip ------------------------------------
                  FadeSlideIn(
                    controller: _intro,
                    start: 0.6,
                    end: 0.9,
                    offset: const Offset(0, -10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _LanguageChip(
                        language: _language,
                        onChanged: (value) =>
                            setState(() => _language = value),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // --- Floating apsara hero ------------------------------
                  FadeSlideIn(
                    controller: _intro,
                    start: 0.0,
                    end: 0.5,
                    offset: const Offset(0, 24),
                    scaleFrom: 0.88,
                    child: AnimatedBuilder(
                      animation: _ambient,
                      builder: (context, child) {
                        final phase = _ambient.value * 2 * math.pi;
                        return Transform.translate(
                          offset: Offset(
                            2.5 * math.sin(phase),
                            6 * math.sin(phase * 2),
                          ),
                          child: child,
                        );
                      },
                      child: _ApsaraHero(ambient: _ambient),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // --- Welcome wordmark ----------------------------------
                  FadeSlideIn(
                    controller: _intro,
                    start: 0.15,
                    end: 0.55,
                    child: Column(
                      children: [
                        Text(
                          'Welcome to',
                          textAlign: TextAlign.center,
                          style: AppFont.headingMedium.copyWith(
                            color: context.colors.onSurface,
                          ),
                        ),
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: AppFont.headingLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  FadeSlideIn(
                    controller: _intro,
                    start: 0.25,
                    end: 0.62,
                    child: Text(
                      'Your smart companion for\nbetter financial management.',
                      textAlign: TextAlign.center,
                      style: AppFont.bodyLarge.copyWith(
                        color: context.colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // --- Actions -------------------------------------------
                  FadeSlideIn(
                    controller: _intro,
                    start: 0.4,
                    end: 0.78,
                    child: PrimaryButton(
                      label: 'Get Started',
                      onPressed: () =>
                          context.router.push(const OnBoardingRoute()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeSlideIn(
                    controller: _intro,
                    start: 0.5,
                    end: 0.86,
                    child: SecondaryButton(
                      label: 'Login',
                      onPressed: () =>
                          context.router.push(const LoginRoute()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // --- Register footer -----------------------------------
                  FadeSlideIn(
                    controller: _intro,
                    start: 0.6,
                    end: 0.95,
                    child: Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'New here? ',
                            style: AppFont.bodyMedium.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                context.router.push(const RegisterRoute()),
                            child: Text(
                              'Create an account',
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
            ),
          ),
        ],
      ),
    );
  }
}

/// The apsara illustration over a soft breathing gold halo.
class _ApsaraHero extends StatelessWidget {
  const _ApsaraHero({required this.ambient});

  final AnimationController ambient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: ambient,
            builder: (context, _) {
              final pulse =
                  0.75 + 0.25 * math.sin(ambient.value * 2 * math.pi * 3);
              return Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppGradients.goldLight.withValues(alpha: 0.30 * pulse),
                      AppGradients.goldLight.withValues(alpha: 0),
                    ],
                  ),
                ),
              );
            },
          ),
          Image.asset(
            AssetPathConstant.apsaraFigure,
            height: 230,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

/// UI-only language selector chip (English / ខ្មែរ).
class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.language, required this.onChanged});

  final String language;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final border = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.textMuted.withValues(alpha: 0.35);

    return PopupMenuButton<String>(
      initialValue: language,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'English', child: Text('English')),
        PopupMenuItem(value: 'ខ្មែរ', child: Text('ខ្មែរ (Khmer)')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: context.isDarkMode ? context.colors.surface : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language,
              style: AppFont.labelLarge.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              LucideIcons.chevronDown,
              size: 16,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
