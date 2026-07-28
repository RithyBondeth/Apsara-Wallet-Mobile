import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';

/// Sweeps a soft diagonal sheen across its child on a loop — used to give
/// hero numbers and gold accents a precious, catch-the-light quality.
///
/// The sweep occupies the first ~55% of each [period]; the rest is a rest
/// beat so the effect reads as an occasional glint, not a strobe.
class ShimmerSweep extends StatefulWidget {
  const ShimmerSweep({
    super.key,
    required this.child,
    this.period = AppDurations.shimmerLoop,
    this.highlight = const Color(0x59FFE9AE),
    this.enabled = true,
  });

  final Widget child;
  final Duration period;

  /// Color of the passing glint (translucent warm gold by default).
  final Color highlight;

  final bool enabled;

  @override
  State<ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends State<ShimmerSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _c.repeat();
  }

  @override
  void didUpdateWidget(ShimmerSweep old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !_c.isAnimating) _c.repeat();
    if (!widget.enabled && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Sweep during the first 55% of the loop, then rest off-screen.
        final t = (_c.value / 0.55).clamp(0.0, 1.0);
        final dx = -1.5 + 3.0 * t;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(dx - 1, -0.4),
            end: Alignment(dx + 1, 0.4),
            colors: [
              widget.highlight.withValues(alpha: 0),
              widget.highlight,
              widget.highlight.withValues(alpha: 0),
            ],
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
