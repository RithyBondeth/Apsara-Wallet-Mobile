import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';

/// A circular emerald "glass" medallion ringed in gold with a fine tick
/// bezel and a soft halo — used to frame feature icons (onboarding,
/// empty states, feature headers).
class GoldMedallion extends StatelessWidget {
  const GoldMedallion({
    super.key,
    required this.icon,
    this.size = 168,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft gold halo.
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.emblemGlow,
            ),
          ),
          // Emerald glass disc.
          Container(
            width: size * 0.74,
            height: size * 0.74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [AppGradients.emeraldGlow, AppGradients.emeraldDeep],
                center: Alignment(-0.3, -0.4),
                radius: 1.1,
              ),
              border: Border.all(
                color: AppGradients.goldCore.withValues(alpha: 0.9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppGradients.emeraldDeep.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          // Fine gold tick bezel.
          CustomPaint(size: Size.square(size), painter: _TickBezelPainter()),
          // Feature icon in gold.
          Icon(icon, size: size * 0.30, color: AppGradients.goldLight),
        ],
      ),
    );
  }
}

class _TickBezelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width * 0.44;
    final paint = Paint()
      ..color = AppGradients.goldCore.withValues(alpha: 0.55)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const ticks = 48;
    for (var i = 0; i < ticks; i++) {
      final a = (i / ticks) * 2 * math.pi;
      final long = i.isEven;
      final inner = r * (long ? 0.955 : 0.975);
      final outer = r * 1.0;
      canvas.drawLine(
        center + Offset(math.cos(a) * inner, math.sin(a) * inner),
        center + Offset(math.cos(a) * outer, math.sin(a) * outer),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
