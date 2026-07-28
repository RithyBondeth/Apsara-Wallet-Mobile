import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';

/// The camera-viewfinder overlay for the scan screen.
///
/// Paints a darkened surround with a rounded cut-out "window", gold corner
/// brackets around it and a scan line that sweeps across the window — driven
/// by the screen's looping [ambient] controller. A faint ghost receipt sits
/// inside the frame to hint at how to align the paper. Phase 1 UI only: there
/// is no live camera feed behind it.
class ScanFrame extends StatelessWidget {
  const ScanFrame({super.key, required this.ambient, this.scanning = false});

  /// Looping 0..1 value driving the sweeping scan line.
  final Animation<double> ambient;

  /// When true the reticle brightens to signal capture is in progress.
  final bool scanning;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Portrait receipt window, biased slightly above centre so the
        // instruction pill and controls have room below.
        final frameWidth = w * 0.78;
        final frameHeight = (frameWidth * 1.34).clamp(0.0, h * 0.72);
        final left = (w - frameWidth) / 2;
        final top = (h - frameHeight) / 2 - h * 0.04;
        final frame = Rect.fromLTWH(left, top, frameWidth, frameHeight);

        return AnimatedBuilder(
          animation: ambient,
          builder: (context, _) {
            // Triangle wave: sweep 0 -> 1 -> 0 for a continuous down/up scan.
            final phase = ambient.value;
            final sweep = 1 - (2 * phase - 1).abs();
            final lineY = frame.top + sweep * frame.height;

            return Stack(
              children: [
                // Darkened surround with the frame punched out.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SpotlightPainter(
                      frame: frame,
                      bracket: scanning
                          ? AppGradients.goldLight
                          : AppGradients.goldCore,
                    ),
                  ),
                ),
                // Ghost receipt hint inside the window.
                Positioned.fromRect(
                  rect: frame.deflate(frame.width * 0.13),
                  child: const _GhostReceipt(),
                ),
                // Sweeping scan line + soft glow band.
                Positioned(
                  left: frame.left,
                  top: lineY - 18,
                  width: frame.width,
                  height: 36,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppGradients.goldCore.withValues(alpha: 0.0),
                            AppGradients.goldCore.withValues(
                              alpha: scanning ? 0.28 : 0.16,
                            ),
                            AppGradients.goldCore.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppGradients.goldCore.withValues(alpha: 0.0),
                              AppGradients.goldLight.withValues(alpha: 0.9),
                              AppGradients.goldCore.withValues(alpha: 0.0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppGradients.goldCore.withValues(
                                alpha: 0.6,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Paints the translucent dark surround (everything outside [frame]) and the
/// four gold corner brackets that make up the reticle.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.frame, required this.bracket});

  final Rect frame;
  final Color bracket;

  static const double _radius = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      frame,
      const Radius.circular(_radius),
    );

    // Dim everything, then clear the window (even-odd difference).
    final scrim = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(scrim, Paint()..color = const Color(0xE6041A11));

    // Thin frame outline.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.14),
    );

    // Gold corner brackets.
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..color = bracket;

    const arm = 26.0;
    const inset = 3.0;
    final r = frame.deflate(inset);

    void corner(Offset o, Offset hDir, Offset vDir) {
      canvas.drawPath(
        Path()
          ..moveTo(o.dx + hDir.dx * arm, o.dy)
          ..lineTo(o.dx, o.dy)
          ..lineTo(o.dx, o.dy + vDir.dy * arm),
        paint,
      );
    }

    corner(r.topLeft, const Offset(1, 0), const Offset(0, 1));
    corner(r.topRight, const Offset(-1, 0), const Offset(0, 1));
    corner(r.bottomLeft, const Offset(1, 0), const Offset(0, -1));
    corner(r.bottomRight, const Offset(-1, 0), const Offset(0, -1));
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.frame != frame || old.bracket != bracket;
}

/// A faint paper receipt drawn inside the window as an alignment hint.
class _GhostReceipt extends StatelessWidget {
  const _GhostReceipt();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.12,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bar(widthFactor: 0.6, height: 10, center: true),
            const SizedBox(height: 14),
            for (var i = 0; i < 6; i++) ...[
              Row(
                children: [
                  Expanded(flex: 3, child: _bar(height: 6)),
                  const SizedBox(width: 12),
                  Expanded(flex: 1, child: _bar(height: 6)),
                ],
              ),
              const SizedBox(height: 10),
            ],
            const Spacer(),
            _bar(widthFactor: 0.45, height: 8),
          ],
        ),
      ),
    );
  }

  Widget _bar({
    double widthFactor = 1,
    double height = 6,
    bool center = false,
  }) {
    final bar = Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    if (widthFactor >= 1) return bar;
    return Align(
      alignment: center ? Alignment.center : Alignment.centerLeft,
      child: FractionallySizedBox(widthFactor: widthFactor, child: bar),
    );
  }
}
