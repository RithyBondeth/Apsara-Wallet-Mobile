import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';

/// The Apsara Wallet brand mark: a gold lotus-bud spire framed by a
/// radiant ring of Khmer-inspired petals.
///
/// Fully hand-painted with [CustomPainter] (no raster asset) so it stays
/// razor-sharp at any size and can be reused for loaders, headers, empty
/// states and the splash screen.
///
/// * [size]     — square edge length in logical pixels.
/// * [ringTurns]— rotation of the petal ring (drive with an animation for
///                a slow, living shimmer).
/// * [glow]     — 0..1 intensity of the soft gold halo behind the mark.
class ApsaraEmblem extends StatelessWidget {
  const ApsaraEmblem({
    super.key,
    this.size = 96,
    this.ringTurns = 0,
    this.glow = 1,
  });

  final double size;
  final double ringTurns;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ApsaraEmblemPainter(ringTurns: ringTurns, glow: glow),
      ),
    );
  }
}

class _ApsaraEmblemPainter extends CustomPainter {
  _ApsaraEmblemPainter({required this.ringTurns, required this.glow});

  final double ringTurns;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    final goldShader = AppGradients.goldFoil.createShader(
      Rect.fromCircle(center: center, radius: r),
    );

    // --- Soft radial halo -------------------------------------------------
    if (glow > 0) {
      final haloPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppGradients.goldLight.withValues(alpha: 0.28 * glow),
            AppGradients.goldLight.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r))
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(center, r, haloPaint);
    }

    final stroke = Paint()
      ..shader = goldShader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // --- Outer + inner guide rings ---------------------------------------
    stroke.strokeWidth = size.width * 0.012;
    canvas.drawCircle(center, r * 0.92, stroke);
    stroke.strokeWidth = size.width * 0.010;
    canvas.drawCircle(center, r * 0.50, stroke);

    // --- Radiant petal ring (alternating long / short rays) --------------
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(ringTurns * 2 * math.pi);
    const petals = 24;
    for (var i = 0; i < petals; i++) {
      final long = i.isEven;
      final inner = r * 0.56;
      final outer = r * (long ? 0.86 : 0.72);
      final halfW = size.width * (long ? 0.022 : 0.013);

      final petal = Path()
        ..moveTo(0, -inner)
        ..quadraticBezierTo(halfW, -(inner + outer) / 2, 0, -outer)
        ..quadraticBezierTo(-halfW, -(inner + outer) / 2, 0, -inner)
        ..close();
      canvas.drawPath(
        petal,
        Paint()
          ..shader = goldShader
          ..style = PaintingStyle.fill,
      );
      canvas.rotate(2 * math.pi / petals);
    }
    canvas.restore();

    // --- Central lotus-bud spire -----------------------------------------
    final h = r * 0.70;
    final w = r * 0.52;
    final tipY = center.dy - h * 0.5;
    final baseY = center.dy + h * 0.45;
    final spire = Path()
      ..moveTo(center.dx, tipY)
      ..cubicTo(
        center.dx - w * 0.55, center.dy - h * 0.12,
        center.dx - w * 0.42, center.dy + h * 0.22,
        center.dx - w * 0.16, baseY,
      )
      ..quadraticBezierTo(center.dx, baseY + h * 0.16, center.dx + w * 0.16, baseY)
      ..cubicTo(
        center.dx + w * 0.42, center.dy + h * 0.22,
        center.dx + w * 0.55, center.dy - h * 0.12,
        center.dx, tipY,
      )
      ..close();
    canvas.drawPath(spire, Paint()..shader = goldShader);

    // Central seam highlight for a chiselled, foil-like read.
    canvas.drawLine(
      Offset(center.dx, tipY + h * 0.14),
      Offset(center.dx, baseY - h * 0.10),
      Paint()
        ..color = AppGradients.emeraldDeep.withValues(alpha: 0.35)
        ..strokeWidth = size.width * 0.008
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ApsaraEmblemPainter old) =>
      old.ringTurns != ringTurns || old.glow != glow;
}
