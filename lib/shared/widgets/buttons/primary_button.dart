import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';

/// The primary call-to-action for Apsara Wallet.
///
/// Filled emerald pill with a soft branded shadow and a tactile
/// press-scale micro-interaction. Reused across auth, payments and
/// dashboard flows.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.expanded = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final bool expanded;
  final bool loading;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: AppDurations.instant,
    lowerBound: 0.0,
    upperBound: 0.04,
  );

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedBuilder(
      animation: _press,
      builder: (context, inner) => Transform.scale(
        scale: 1 - _press.value,
        child: inner,
      ),
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
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: _enabled
                ? const [
                    BoxShadow(
                      color: Color(0x330B5B3D),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: AppFont.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (widget.trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(widget.trailingIcon, color: Colors.white, size: 20),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _enabled ? (_) => _press.forward() : null,
      onTapUp: _enabled ? (_) => _press.reverse() : null,
      onTapCancel: _enabled ? () => _press.reverse() : null,
      onTap: _enabled ? widget.onPressed : null,
      child: child,
    );
  }
}
