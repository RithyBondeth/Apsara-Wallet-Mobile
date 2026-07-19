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
  });

  final List<double> values;
  final double maxValue;
  final List<String> axisLabels;
  final double progress;

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
      final y = chart.bottom -
          chart.height * (values[i] / maxValue).clamp(0.0, 1.0);
      pts.add(Offset(x, y));
    }

    final linePath = _smoothPath(pts);

    // Reveal left-to-right by clipping the drawable width.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(
      0,
      0,
      chart.left + chart.width * progress.clamp(0.0, 1.0),
      size.height,
    ));

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
      ..color = AppColors.surface;
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

  /// Catmull-Rom spline through [pts], emitted as cubic Béziers.
  Path _smoothPath(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i == 0 ? 0 : i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = pts[i + 2 >= pts.length ? pts.length - 1 : i + 2];
      final c1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final c2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
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
