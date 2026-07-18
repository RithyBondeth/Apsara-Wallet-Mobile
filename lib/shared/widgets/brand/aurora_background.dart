import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';

/// A living brand backdrop: soft emerald aurora washes drifting slowly,
/// with fine gold motes rising like incense sparks.
///
/// Drive [t] with a looping controller (0..1). Everything is derived
/// deterministically from [t], so the loop is seamless and repaints stay
/// cheap (single custom painter, no per-particle widgets).
///
/// [dark] selects the palette: `true` for emerald surfaces (splash-like),
/// `false` for light surfaces where the washes become whisper-subtle.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    required this.t,
    this.dark = false,
    this.moteCount = 18,
  });

  final double t;
  final bool dark;
  final int moteCount;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _AuroraPainter(t: t, dark: dark, moteCount: moteCount),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.t, required this.dark, required this.moteCount});

  final double t;
  final bool dark;
  final int moteCount;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = t * 2 * math.pi;

    // --- Aurora washes: three radial glows orbiting slow ellipses --------
    final washes = <(double, double, double, double, Color)>[
      // (orbit phase, cx factor, cy factor, radius factor, color)
      (0.0, 0.20, 0.12, 0.55, AppGradients.emeraldGlow),
      (2.1, 0.85, 0.30, 0.48, AppGradients.goldCore),
      (4.2, 0.50, 0.85, 0.60, AppGradients.emeraldCore),
    ];
    final washAlpha = dark ? 0.16 : 0.05;
    for (final (p, fx, fy, fr, color) in washes) {
      final cx = size.width * (fx + 0.06 * math.sin(phase + p));
      final cy = size.height * (fy + 0.05 * math.cos(phase * 0.7 + p));
      final r = size.shortestSide * fr;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: washAlpha), color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
          ..blendMode = dark ? BlendMode.plus : BlendMode.srcOver,
      );
    }

    // --- Rising gold motes ------------------------------------------------
    final motePaint = Paint();
    for (var i = 0; i < moteCount; i++) {
      // Deterministic pseudo-random layout per mote index.
      final h = _hash(i);
      final speed = 0.35 + 0.65 * h; // slow layers drift behind fast ones
      final progress = (t * speed + h * 7) % 1.0;
      final x = size.width *
          ((h * 13) % 1.0 + 0.04 * math.sin(phase * speed + i));
      final y = size.height * (1.08 - 1.16 * progress);
      final radius = 1.0 + 2.2 * ((h * 31) % 1.0);
      // Fade in near the bottom, out near the top.
      final fade = math.sin(progress * math.pi).clamp(0.0, 1.0);
      final alpha = (dark ? 0.35 : 0.20) * fade;
      motePaint.color = (dark ? AppGradients.goldLight : AppGradients.goldDeep)
          .withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, motePaint);
    }
  }

  /// Cheap deterministic hash -> 0..1 (stable across frames, no dart:math
  /// Random so the field is identical every run and loops seamlessly).
  double _hash(int i) {
    final n = math.sin(i * 127.1 + 311.7) * 43758.5453;
    return n - n.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.dark != dark || old.moteCount != moteCount;
}
