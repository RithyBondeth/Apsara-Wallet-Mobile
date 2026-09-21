import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';

/// A smooth area+line chart with labelled axes, hand-painted (no chart
/// dependency). [progress] (0..1) reveals the line left-to-right.
class LineChart extends StatelessWidget {
  const LineChart({
    super.key,
    required this.values,
    required this.maxValue,
    required this.axisLabels,
    required this.progress,
    this.height = 190,
  });

  final List<double> values;
  final double maxValue;
  final List<String> axisLabels;
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LinePainter(
          values: values,
          maxValue: maxValue,
          axisLabels: axisLabels,
          progress: progress,
          gridColor: AppColors.surfaceVariant,
          labelColor: AppColors.textMuted,
          dotRingColor: AppColors.surface,
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.values,
    required this.maxValue,
    required this.axisLabels,
    required this.progress,
    required this.gridColor,
    required this.labelColor,
    required this.dotRingColor,
  });

  final List<double> values;
  final double maxValue;
  final List<String> axisLabels;
  final double progress;
  final Color gridColor;
  final Color labelColor;
  final Color dotRingColor;

  static const double _leftPad = 38;
  static const double _rightPad = 10;
  static const double _topPad = 10;
  static const double _bottomPad = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(
      _leftPad,
      _topPad,
      size.width - _rightPad,
      size.height - _bottomPad,
    );

    _paintGridAndYLabels(canvas, chart);
    _paintXLabels(canvas, chart);

    if (values.length < 2) return;

    final pts = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = chart.left + chart.width * (i / (values.length - 1));
      final y =
          chart.bottom - chart.height * (values[i] / maxValue).clamp(0.0, 1.0);
      pts.add(Offset(x, y));
    }

    final linePath = _smoothPath(pts);

    // Reveal left-to-right by clipping the drawable width.
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        0,
        0,
        chart.left + chart.width * progress.clamp(0.0, 1.0),
        size.height,
      ),
    );

    // Area fill under the curve.
    final areaPath = Path.from(linePath)
      ..lineTo(pts.last.dx, chart.bottom)
      ..lineTo(pts.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.22),
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ).createShader(chart),
    );

    // The line itself.
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.primary,
    );

    // Data-point dots.
    final dotFill = Paint()..color = AppColors.primary;
    final dotRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = dotRingColor;
    for (final p in pts) {
      canvas.drawCircle(p, 3.5, dotFill);
      canvas.drawCircle(p, 3.5, dotRing);
    }

    canvas.restore();
  }

  void _paintGridAndYLabels(Canvas canvas, Rect chart) {
    const ticks = 3; // -> 0, 50K, 100K, 150K when maxValue = 150K
    final grid = Paint()
      ..color = AppColors.surfaceVariant
      ..strokeWidth = 1;
    for (var i = 0; i <= ticks; i++) {
      final t = i / ticks;
      final y = chart.bottom - chart.height * t;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      _text(
        canvas,
        _shortK(maxValue * t),
        Offset(0, y - 6),
        width: _leftPad - 6,
        align: TextAlign.right,
      );
    }
  }

  void _paintXLabels(Canvas canvas, Rect chart) {
    if (axisLabels.isEmpty) return;
    for (var i = 0; i < axisLabels.length; i++) {
      final t = axisLabels.length == 1 ? 0.0 : i / (axisLabels.length - 1);
      final cx = chart.left + chart.width * t;
      _text(
        canvas,
        axisLabels[i],
        Offset(cx - 30, chart.bottom + 8),
        width: 60,
        align: TextAlign.center,
      );
    }
  }

  /// Monotone cubic (Fritsch–Carlson) through [pts], emitted as Béziers.
  ///
  /// A plain Catmull-Rom spline overshoots: one spike between two flat days
  /// makes the curve dip *below* zero on either side, which reads as a
  /// negative spend. Clamping each tangent to the neighbouring slopes keeps
  /// the curve inside the data — flat stays flat, and it never crosses the
  /// axis on its own.
  Path _smoothPath(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    final n = pts.length;
    if (n < 2) return path;

    // Secant slopes between consecutive points.
    final d = List<double>.generate(n - 1, (i) {
      final dx = pts[i + 1].dx - pts[i].dx;
      return dx == 0 ? 0.0 : (pts[i + 1].dy - pts[i].dy) / dx;
    });
    // Tangents: average of neighbouring secants, zeroed at local extrema so
    // the curve cannot overshoot them.
    final m = List<double>.filled(n, 0);
    m[0] = d[0];
    m[n - 1] = d[n - 2];
    for (var i = 1; i < n - 1; i++) {
      m[i] = d[i - 1] * d[i] <= 0 ? 0.0 : (d[i - 1] + d[i]) / 2;
    }
    for (var i = 0; i < n - 1; i++) {
      if (d[i] == 0) {
        m[i] = 0;
        m[i + 1] = 0;
        continue;
      }
      final a = m[i] / d[i];
      final b = m[i + 1] / d[i];
      final h = a * a + b * b;
      if (h > 9) {
        final t = 3 / math.sqrt(h);
        m[i] = t * a * d[i];
        m[i + 1] = t * b * d[i];
      }
    }

    for (var i = 0; i < n - 1; i++) {
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final dx = (p2.dx - p1.dx) / 3;
      path.cubicTo(
        p1.dx + dx,
        p1.dy + m[i] * dx,
        p2.dx - dx,
        p2.dy - m[i + 1] * dx,
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  String _shortK(double v) {
    if (v <= 0) return '0';
    final k = v / 1000;
    return '${k.round()}K';
  }

  void _text(
    Canvas canvas,
    String text,
    Offset offset, {
    required double width,
    required TextAlign align,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppFont.labelSmall.copyWith(color: AppColors.textMuted),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.progress != progress ||
      old.values != values ||
      old.maxValue != maxValue;
}
