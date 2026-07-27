import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // One-shot controller that drives the staggered entrance.
  late final AnimationController _intro;
  // Looping controller for the "living" ambient motion (ring, glow, shimmer).
  late final AnimationController _ambient;

  late final Animation<double> _emblemOpacity;
  late final Animation<double> _emblemScale;
  late final Animation<double> _bgScale;
  late final Animation<double> _wordOpacity;
  late final Animation<double> _wordShift;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(vsync: this, duration: AppDurations.splashIntro);
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _bgScale = Tween<double>(begin: 1.08, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: Curves.easeOutSine),
    );
    _emblemOpacity = _fade(0.00, 0.42);
    _emblemScale = Tween<double>(begin: 0.62, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.00, 0.55, curve: AppCurves.emphasized),
      ),
    );
    _wordOpacity = _fade(0.30, 0.64);
    _wordShift = Tween<double>(begin: 22, end: 0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.30, 0.68, curve: AppCurves.entrance),
      ),
    );
    _taglineOpacity = _fade(0.50, 0.82);
    _loaderOpacity = _fade(0.70, 1.0);

    _intro.forward();
    _scheduleExit();
  }

  Animation<double> _fade(double start, double end) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(start, end, curve: AppCurves.decelerate),
    );
  }

  Future<void> _scheduleExit() async {
    // Restore any saved session while the branded intro plays, so there's no
    // extra wait: whichever takes longer (the animation or the token check)
    // gates the hand-off.
    await Future.wait([
      ref.read(authControllerProvider.notifier).restore(),
      Future<void>.delayed(
        AppDurations.splashIntro + AppDurations.splashHold,
      ),
    ]);
    if (!mounted) return;

    final isAuthenticated =
        ref.read(authControllerProvider).isAuthenticated;
    context.router.replace(
      isAuthenticated ? const DashboardRoute() : const WelcomeRoute(),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppGradients.emeraldDeep,
      ),
      child: Scaffold(
        backgroundColor: AppGradients.emeraldDeep,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // --- Angkor brand backdrop with a slow Ken-Burns push-in -----
            AnimatedBuilder(
              animation: _bgScale,
              builder: (context, child) =>
                  Transform.scale(scale: _bgScale.value, child: child),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.emerald,
                  image: DecorationImage(
                    image: AssetImage(AssetPathConstant.splashBackground),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // --- Legibility scrim ----------------------------------------
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.scrim),
            ),

            // --- Brand lockup (upper-centre, clear of the temple) --------
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  _buildEmblem(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildWordmark(),
                  const SizedBox(height: AppSpacing.md),
                  _buildTagline(),
                  const Spacer(flex: 6),
                  _buildLoader(),
                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmblem() {
    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _ambient]),
      builder: (context, child) {
        final t = _ambient.value;
        final glowPulse = 0.72 + 0.28 * math.sin(t * 2 * math.pi * 3);
        return Opacity(
          opacity: _emblemOpacity.value,
          child: Transform.scale(
            scale: _emblemScale.value,
            child: DecoratedBox(
              // Soft breathing gold halo behind the logo.
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppGradients.goldLight.withValues(alpha: 0.30 * glowPulse),
                    AppGradients.goldLight.withValues(alpha: 0),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Image.asset(
          AssetPathConstant.logo,
          width: 140,
          height: 140,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildWordmark() {
    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _ambient]),
      builder: (context, _) {
        final phase = (_ambient.value * 3) % 1.0;
        return Opacity(
          opacity: _wordOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _wordShift.value),
            child: ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (rect) => _sheen(phase).createShader(rect),
              child: Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  height: 1.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Travelling gold glint across the white wordmark.
  LinearGradient _sheen(double phase) {
    final x = -1.0 + 3.0 * phase;
    return LinearGradient(
      begin: Alignment(x - 0.35, 0),
      end: Alignment(x + 0.35, 0),
      colors: const [Colors.white, AppGradients.goldLight, Colors.white],
      stops: const [0.35, 0.5, 0.65],
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _taglineOpacity,
      child: Text(
        AppConstants.appTagline.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.82),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 3.0,
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return FadeTransition(
      opacity: _loaderOpacity,
      child: AnimatedBuilder(
        animation: _ambient,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              // Staggered breathing dots.
              final phase = (_ambient.value * 3 - i * 0.18) % 1.0;
              final wave = (math.sin(phase * 2 * math.pi) + 1) / 2;
              return Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppGradients.goldLight
                      .withValues(alpha: 0.35 + 0.55 * wave),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
