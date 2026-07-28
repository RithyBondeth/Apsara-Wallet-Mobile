import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';

/// Wraps any tappable surface in the house press-scale micro-interaction —
/// a subtle shrink on tap-down that springs back on release.
///
/// Extracted so cards, list rows and nav items share the exact tactile feel
/// of [PrimaryButton] instead of each re-implementing it.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Scale reached while held down (1.0 = no shrink).
  final double pressedScale;
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppDurations.instant,
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  bool get _active => widget.enabled && widget.onTap != null;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _active ? (_) => _c.forward() : null,
      onTapUp: _active ? (_) => _c.reverse() : null,
      onTapCancel: _active ? () => _c.reverse() : null,
      onTap: _active ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.scale(
          scale: 1 - (1 - widget.pressedScale) * _c.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
