import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';

/// Animated page indicator — the active page reads as a gold pill,
/// inactive pages as muted dots. Smoothly interpolates as [page] scrolls.
///
/// [page] is the fractional page value (e.g. from a [PageController]),
/// so the pill grows/shrinks continuously during a swipe.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.page,
    this.activeColor = AppColors.accent,
  });

  final int count;
  final double page;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        // 1.0 when fully active, 0.0 when inactive.
        final t = (1 - (page - i).abs()).clamp(0.0, 1.0);
        return AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          width: 8 + 18 * t,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Color.lerp(
              activeColor.withValues(alpha: 0.28),
              activeColor,
              t,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
