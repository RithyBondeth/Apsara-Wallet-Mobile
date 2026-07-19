import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/features/analytics/data/analytics_mock_data.dart';

/// A ring chart of expense categories with a centered summary. [progress]
/// (0..1) sweeps the arcs in on entrance.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.categories,
    required this.progress,
    required this.center,
    this.size = 150,
    this.thickness = 22,
  });

  final List<ExpenseCategory> categories;
  final double progress;
  final Widget center;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              categories: categories,
              progress: progress,
              thickness: thickness,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(thickness + 6),
            child: Center(child: center),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.categories,
    required this.progress,
    required this.thickness,
  });

  final List<ExpenseCategory> categories;
  final double progress;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      thickness / 2,
      thickness / 2,
      size.width - thickness,
      size.height - thickness,
    );
    const start = -math.pi / 2; // 12 o'clock
    const gap = 0.04; // radians between slices
    var angle = start;

    for (final c in categories) {
      final full = c.fraction * 2 * math.pi;
      final sweep = (full - gap).clamp(0.0, 2 * math.pi) * progress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = c.color;
      canvas.drawArc(rect, angle + gap / 2, sweep, false, paint);
      angle += full;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress ||
      old.categories != categories ||
      old.thickness != thickness;
}
