import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';

/// The secondary call-to-action: an outlined pill in brand emerald with
/// the same press-scale feel as [PrimaryButton]. Pairs under a primary
/// action (e.g. Get Started / Login on the welcome screen).
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: AppDurations.instant,
    lowerBound: 0.0,
    upperBound: 0.04,
  );

  bool get _enabled => widget.onPressed != null;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        context.isDarkMode ? context.colors.primary : AppColors.primary;

    return GestureDetector(
      onTapDown: _enabled ? (_) => _press.forward() : null,
      onTapUp: _enabled ? (_) => _press.reverse() : null,
      onTapCancel: _enabled ? () => _press.reverse() : null,
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) =>
            Transform.scale(scale: 1 - _press.value, child: child),
        child: AnimatedOpacity(
          duration: AppDurations.fast,
          opacity: _enabled ? 1 : 0.5,
          child: Container(
            height: 56,
            width: widget.expanded ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: widget.expanded ? 24 : 32,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: accent.withValues(alpha: 0.55),
                width: 1.4,
              ),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: AppFont.titleMedium.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
