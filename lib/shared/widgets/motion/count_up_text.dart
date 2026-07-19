import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';

/// A number that counts up (or down) to its value instead of snapping —
/// the classic "balance ticker" moment on finance dashboards.
///
/// On first build it rolls from 0 to [value]; when [value] later changes it
/// rolls from the currently displayed number, so live updates feel continuous.
class CountUpText extends StatefulWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 1100),
    this.curve = AppCurves.decelerate,
  });

  final num value;

  /// Renders the in-flight number (e.g. `formatKhr(v.round())`).
  final String Function(num value) formatter;

  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late Animation<double> _anim = _tweenTo(from: 0);

  Animation<double> _tweenTo({required double from}) {
    return Tween<double>(begin: from, end: widget.value.toDouble()).animate(
      CurvedAnimation(parent: _c, curve: widget.curve),
    );
  }

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void didUpdateWidget(CountUpText old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = _tweenTo(from: _anim.value);
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) =>
          Text(widget.formatter(_anim.value), style: widget.style),
    );
  }
}
