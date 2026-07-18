import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';

/// Staggered entrance: fades a child in while sliding it from [offset],
/// driven by a slice ([start]..[end]) of a shared [controller].
///
/// Screens create one intro `AnimationController`, fire it once, and wrap
/// each block in a [FadeSlideIn] with increasing intervals — giving the
/// whole page a choreographed cascade instead of a single pop.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.controller,
    required this.child,
    this.start = 0.0,
    this.end = 1.0,
    this.offset = const Offset(0, 28),
    this.curve = AppCurves.entrance,
    this.scaleFrom,
  });

  final AnimationController controller;
  final Widget child;

  /// Interval on the parent controller (0..1).
  final double start;
  final double end;

  /// Where the child slides in from, in logical pixels.
  final Offset offset;

  final Curve curve;

  /// Optional entrance scale (e.g. 0.9 for a gentle grow-in).
  final double? scaleFrom;

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: curve),
    );
    return AnimatedBuilder(
      animation: t,
      builder: (context, inner) {
        final v = t.value;
        Widget w = Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - v), offset.dy * (1 - v)),
            child: inner,
          ),
        );
        if (scaleFrom != null) {
          w = Transform.scale(
            scale: scaleFrom! + (1 - scaleFrom!) * v,
            child: w,
          );
        }
        return w;
      },
      child: child,
    );
  }
}
