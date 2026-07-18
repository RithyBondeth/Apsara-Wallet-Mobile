import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/apsara_mark_geometry.dart';

/// The Apsara Wallet brand mark ("Gilded Poise"): three gold lotus spires —
/// the apsara's mokot crown — over a cupped-hands crescent holding a
/// coin-pearl, framed by a fine orbiting tick ring.
///
/// Painted from generated vector outlines (see apsara_mark_geometry.dart, the
/// same geometry as the exported logo PNGs) so it stays razor-sharp at any
/// size and can be reused for loaders, headers, empty states and the splash
/// screen.
///
/// * [size]     — square edge length in logical pixels.
/// * [ringTurns]— rotation of the outer tick ring (drive with an animation
///                for a slow, living shimmer).
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

    // --- Fine orbiting tick ring (quiet, systematic brand notation) ------
    final ringColor = AppGradients.goldCore.withValues(alpha: 0.45);
    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.005;
    canvas.drawCircle(center, r * 0.96, ringPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(ringTurns * 2 * math.pi);
    const ticks = 36;
    final tickPaint = Paint()
      ..color = ringColor
      ..strokeWidth = size.width * 0.005
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < ticks; i++) {
      final long = i % 9 == 0;
      final inner = r * (long ? 0.90 : 0.935);
      canvas.drawLine(Offset(0, -inner), Offset(0, -r * 0.96), tickPaint);
      canvas.rotate(2 * math.pi / ticks);
    }
    canvas.restore();

    // --- The mark: crown spires, crescent, coin ---------------------------
    // Geometry is normalized to a unit square; scale into the ring interior.
    final markSide = size.width * 0.70;
    final origin = Offset(
      center.dx - markSide / 2,
      center.dy - markSide / 2,
    );
    for (final element in apsaraMarkElements) {
      final path = Path()..fillType = PathFillType.evenOdd;
      for (final ring in element.rings) {
        path.moveTo(
          origin.dx + ring[0] * markSide,
          origin.dy + ring[1] * markSide,
        );
        for (var i = 2; i < ring.length; i += 2) {
          path.lineTo(
            origin.dx + ring[i] * markSide,
            origin.dy + ring[i + 1] * markSide,
          );
        }
        path.close();
      }
      canvas.drawPath(path, Paint()..shader = _elementShader(element, origin, markSide));
    }
  }

  /// Gradient per element, mapped over the element's own (uncarved) bounds —
  /// mirrors the gradients of the exported logo assets.
  Shader _elementShader(ApsaraMarkElement e, Offset origin, double side) {
    final rect = Rect.fromLTRB(
      origin.dx + e.bounds[0] * side,
      origin.dy + e.bounds[1] * side,
      origin.dx + e.bounds[2] * side,
      origin.dy + e.bounds[3] * side,
    );
    switch (e.kind) {
      case 'coin':
        return RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.1,
          colors: const [
            AppGradients.goldLight,
            AppGradients.goldCore,
            AppGradients.goldDeep,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(rect);
      case 'center':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppGradients.goldLight,
            AppGradients.goldCore,
            AppGradients.goldDeep,
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect);
      case 'crescent':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppGradients.goldLight, AppGradients.goldDeep],
        ).createShader(rect);
      default: // side petals
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppGradients.goldCore, AppGradients.goldDeep],
        ).createShader(rect);
    }
  }

  @override
  bool shouldRepaint(covariant _ApsaraEmblemPainter old) =>
      old.ringTurns != ringTurns || old.glow != glow;
}
