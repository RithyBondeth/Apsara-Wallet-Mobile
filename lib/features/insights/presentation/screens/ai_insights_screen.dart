import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/insights/data/insights_mock_data.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/count_up_text.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// AI Insights (Phase 1, UI-only): today's insight with the friendly bot,
/// an animated Financial Health Score gauge and a list of further tips —
/// per the design board mockup. All copy is mock and localized.
@RoutePage()
class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  /// Gentle bob for the bot avatar.
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: AppDurations.pulseLoop,
  )..repeat();

  /// Gauge sweep, eased in mid-cascade.
  late final Animation<double> _gauge = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.3, 0.9, curve: AppCurves.decelerate),
  );

  final InsightsData _data = InsightsData.sample;

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FadeSlideIn(
                controller: _intro,
                start: 0.0,
                end: 0.35,
                offset: const Offset(0, 10),
                child: const _AppBar(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.sm,
                    AppSpacing.xxl,
                    bottomSafe + AppSpacing.xxxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.08,
                        end: 0.5,
                        scaleFrom: 0.97,
                        child: _TodayInsightCard(ambient: _ambient),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.22,
                        end: 0.65,
                        child: _HealthScoreCard(
                          score: _data.healthScore,
                          gauge: _gauge,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.36,
                        end: 0.8,
                        child: _MoreInsightsCard(tips: _data.tips),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.5,
                        end: 1.0,
                        child: Center(
                          child: Text(
                            l10n.insightsHealthBody2,
                            textAlign: TextAlign.center,
                            style: AppFont.labelMedium.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back chevron + "✦ AI Insights" centered title.
class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          PressScale(
            onTap: () => context.router.maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: const Icon(
                LucideIcons.chevronLeft,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  size: 18,
                  color: Color(0xFF6C63D2),
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.insightsTitle,
                  style: AppFont.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

/// Lavender "Today's Insight" card with the bobbing bot mascot.
class _TodayInsightCard extends StatelessWidget {
  const _TodayInsightCard({required this.ambient});

  final AnimationController ambient;

  static const Color _lavender = Color(0xFFEFF0FC);
  static const Color _indigo = Color(0xFF6C63D2);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: _lavender,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: _indigo.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.insightsToday,
                  style: AppFont.labelLarge.copyWith(
                    color: _indigo,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.insightsTodayBody1,
                  style: AppFont.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.insightsTodayBody2,
                  style: AppFont.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _BotAvatar(ambient: ambient),
        ],
      ),
    );
  }
}

/// Friendly bot mascot: teal gradient circle + bot glyph, gently bobbing and
/// breathing a gold halo (no raster asset — house style).
class _BotAvatar extends StatelessWidget {
  const _BotAvatar({required this.ambient});

  final AnimationController ambient;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (context, child) {
        final phase = ambient.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, 3 * math.sin(phase)),
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7BDCD4), Color(0xFF27A79A)],
              ),
              border: Border.all(
                color: AppGradients.goldLight.withValues(
                  alpha: 0.5 + 0.3 * math.sin(phase * 2),
                ),
                width: 1.6,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3327A79A),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: const Icon(LucideIcons.bot, size: 34, color: Colors.white),
    );
  }
}

/// Arc gauge + counted-up score + encouragement copy.
class _HealthScoreCard extends StatelessWidget {
  const _HealthScoreCard({required this.score, required this.gauge});

  final int score;
  final Animation<double> gauge;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.insightsHealthScore,
            style: AppFont.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              SizedBox(
                width: 128,
                height: 128,
                child: AnimatedBuilder(
                  animation: gauge,
                  builder: (context, _) => CustomPaint(
                    painter: _GaugePainter(
                      progress: (score / 100) * gauge.value,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CountUpText(
                            value: score,
                            formatter: (v) => '${v.round()}',
                            duration: const Duration(milliseconds: 1100),
                            style: AppFont.headingMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            l10n.insightsScoreGood,
                            style: AppFont.labelLarge.copyWith(
                              color: AppColors.income,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.insightsHealthBody1,
                      style: AppFont.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.insightsHealthBody2,
                      style: AppFont.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 270° arc: muted track + gradient sweep proportional to [progress].
class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress});

  final double progress;

  static const double _start = 3 * math.pi / 4; // 135°
  static const double _span = 3 * math.pi / 2; // 270°

  @override
  void paint(Canvas canvas, Size size) {
    const thickness = 12.0;
    final rect = Rect.fromLTWH(
      thickness / 2,
      thickness / 2,
      size.width - thickness,
      size.height - thickness,
    );

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = AppColors.surfaceVariant;
    canvas.drawArc(rect, _start, _span, false, track);

    final sweep = _span * progress.clamp(0.0, 1.0);
    if (sweep <= 0) return;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: _start,
        endAngle: _start + _span,
        colors: const [AppColors.primary, AppGradients.emeraldGlow],
        transform: const GradientRotation(-0.1),
      ).createShader(rect);
    canvas.drawArc(rect, _start, sweep, false, fill);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress;
}

/// Tip rows with icon tiles and dividers.
class _MoreInsightsCard extends StatelessWidget {
  const _MoreInsightsCard({required this.tips});

  final List<InsightTip> tips;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.insightsMore,
            style: AppFont.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final (i, tip) in tips.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: AppColors.surfaceVariant.withValues(alpha: 0.8),
              ),
            PressScale(
              onTap: () {},
              pressedScale: 0.99,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: tip.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(tip.icon, size: 17, color: tip.color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        tip.bodyOf(l10n),
                        style: AppFont.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
