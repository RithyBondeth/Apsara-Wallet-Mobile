import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/aurora_background.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/gold_medallion.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/indicators/page_indicator.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

const _pages = <_OnboardingPageData>[
  _OnboardingPageData(
    icon: LucideIcons.walletMinimal,
    title: 'All your money,\nbeautifully in one place',
    body:
        'Track balances, cards and spending across USD and KHR — with the elegance Apsara brings to every detail.',
  ),
  _OnboardingPageData(
    icon: LucideIcons.arrowLeftRight,
    title: 'Send & receive\nin a few taps',
    body:
        'Instant transfers and QR payments across Cambodia. Fast, secure, and effortless — day or night.',
  ),
  _OnboardingPageData(
    icon: LucideIcons.chartPie,
    title: 'Insights that\ngrow your wealth',
    body:
        'Smart budgets and clear analytics turn everyday spending into confident financial decisions.',
  ),
];

@RoutePage()
class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  double _page = 0;

  /// One-shot entrance cascade for the first build.
  late final AnimationController _intro;

  /// Endless ambient loop: aurora drift, medallion float, orbit arcs.
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: AppDurations.splashIntro)
      ..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page.round() >= _pages.length - 1;

  void _finish() {
    // "Get Started" is the new-user path: the tour hands off to sign-up.
    context.router.replace(const RegisterRoute());
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: AppDurations.slow,
        curve: Curves.easeOutQuint,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- Living backdrop: aurora washes + rising gold motes --------
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) => AuroraBackground(t: _ambient.value),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- Skip ---------------------------------------------------
                FadeSlideIn(
                  controller: _intro,
                  start: 0.55,
                  end: 0.85,
                  offset: const Offset(0, -12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      duration: AppDurations.fast,
                      opacity: _isLast ? 0 : 1,
                      child: TextButton(
                        onPressed: _isLast ? null : _finish,
                        child: Text(
                          'Skip',
                          style: AppFont.labelLarge.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Pages --------------------------------------------------
                Expanded(
                  child: FadeSlideIn(
                    controller: _intro,
                    start: 0.0,
                    end: 0.6,
                    offset: const Offset(0, 36),
                    child: AnimatedBuilder(
                      animation: _ambient,
                      builder: (context, _) => PageView.builder(
                        controller: _controller,
                        itemCount: _pages.length,
                        itemBuilder: (context, index) {
                          final delta = index - _page; // -1..1 near neighbours
                          return _OnboardingPageView(
                            data: _pages[index],
                            delta: delta,
                            ambient: _ambient.value,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // --- Controls -----------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.45,
                        end: 0.8,
                        child: PageIndicator(count: _pages.length, page: _page),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.55,
                        end: 0.95,
                        child: AnimatedSwitcher(
                          duration: AppDurations.medium,
                          switchInCurve: AppCurves.entrance,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.35),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: PrimaryButton(
                            key: ValueKey(_isLast),
                            label: _isLast ? 'Get Started' : 'Next',
                            trailingIcon: _isLast
                                ? LucideIcons.sparkles
                                : LucideIcons.arrowRight,
                            onPressed: _next,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single onboarding page with layered depth:
/// * the medallion floats on an ambient bob, tilts in 3D while swiping and
///   is orbited by two slow counter-rotating gold arcs;
/// * title and body drift at different parallax rates and soften as the
///   page leaves centre.
class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.data,
    required this.delta,
    required this.ambient,
  });

  final _OnboardingPageData data;
  final double delta;

  /// 0..1 looping ambient phase.
  final double ambient;

  @override
  Widget build(BuildContext context) {
    // Content fades/scales slightly as it leaves the viewport centre.
    final centred = (1 - delta.abs()).clamp(0.0, 1.0);
    final phase = ambient * 2 * math.pi;
    final bob = math.sin(phase * 2) * 7;
    final breathe = 1 + 0.015 * math.sin(phase * 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- Medallion: 3D tilt + drift + float + orbit arcs ------------
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012) // perspective
              ..rotateY(delta * -0.9)
              ..translateByDouble(delta * -60, bob, 0, 1),
            child: Transform.scale(
              scale: (0.82 + 0.18 * centred) * breathe,
              child: Opacity(
                opacity: centred,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _OrbitArcs(phase: phase, size: 212),
                    GoldMedallion(icon: data.icon),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.massive),

          // --- Title: mid-rate parallax ------------------------------------
          Transform.translate(
            offset: Offset(delta * -32, (1 - centred) * 10),
            child: Opacity(
              opacity: centred,
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                style: AppFont.headingMedium.copyWith(
                  color: context.colors.onSurface,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // --- Body: slowest parallax --------------------------------------
          Transform.translate(
            offset: Offset(delta * -16, (1 - centred) * 18),
            child: Opacity(
              opacity: centred,
              child: Text(
                data.body,
                textAlign: TextAlign.center,
                style: AppFont.bodyLarge.copyWith(
                  color: context.colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two fine counter-rotating gold arcs orbiting the medallion — the same
/// "systematic notation" language as the brand mark's tick ring.
class _OrbitArcs extends StatelessWidget {
  const _OrbitArcs({required this.phase, required this.size});

  final double phase;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _OrbitArcsPainter(phase: phase)),
    );
  }
}

class _OrbitArcsPainter extends CustomPainter {
  _OrbitArcsPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Outer arc pair, clockwise.
    paint
      ..color = AppGradients.goldCore.withValues(alpha: 0.5)
      ..strokeWidth = 1.6;
    final rOuter = size.width * 0.485;
    for (final offset in [0.0, math.pi]) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: rOuter),
        phase * 0.6 + offset,
        math.pi * 0.42,
        false,
        paint,
      );
    }
    // Orbiting pearl on the outer ring.
    final pearlAngle = phase * 0.6 - 0.12;
    canvas.drawCircle(
      center +
          Offset(math.cos(pearlAngle) * rOuter, math.sin(pearlAngle) * rOuter),
      2.6,
      Paint()..color = AppGradients.goldCore,
    );

    // Inner arc pair, counter-clockwise, fainter.
    paint
      ..color = AppGradients.goldCore.withValues(alpha: 0.28)
      ..strokeWidth = 1.1;
    final rInner = size.width * 0.435;
    for (final offset in [math.pi * 0.5, math.pi * 1.5]) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: rInner),
        -phase * 0.9 + offset,
        math.pi * 0.3,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitArcsPainter old) => old.phase != phase;
}
