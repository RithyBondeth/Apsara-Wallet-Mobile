import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';

/// The Overview · Categories · Trends selector — a rounded track with an
/// emerald pill that glides to the active segment.
class AnalyticsSegmentedTabs extends StatelessWidget {
  const AnalyticsSegmentedTabs({
    super.key,
    required this.labels,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedAlign(
                duration: AppDurations.fast,
                curve: AppCurves.gentle,
                alignment: Alignment(
                  labels.length == 1
                      ? 0
                      : -1 + 2 * (currentIndex / (labels.length - 1)),
                  0,
                ),
                child: Container(
                  width: segmentWidth,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330B5B3D),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: SizedBox(
                          height: 40,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: AppDurations.fast,
                              style: AppFont.labelLarge.copyWith(
                                color: i == currentIndex
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: i == currentIndex
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              child: Text(labels[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
