import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';

/// Four-dot PIN indicator — dots fill gold as digits are entered.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled, this.length = 4});

  final int filled;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final on = i < filled;
        return AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          width: on ? 18 : 14,
          height: on ? 18 : 14,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? AppColors.accent : Colors.transparent,
            border: Border.all(
              color: on
                  ? AppColors.accent
                  : context.colors.onSurfaceVariant.withValues(alpha: 0.4),
              width: 1.6,
            ),
          ),
        );
      }),
    );
  }
}

/// Brand number pad: 1-9, 0 and backspace, with a tactile press ripple.
class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, VoidCallback? onTap) {
      return Expanded(
        child: AspectRatio(
          aspectRatio: 1.45,
          child: onTap == null
              ? const SizedBox()
              : Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: AppColors.primary.withValues(alpha: 0.12),
                    highlightColor:
                        AppColors.primary.withValues(alpha: 0.06),
                    child: Center(child: child),
                  ),
                ),
        ),
      );
    }

    Widget digit(String d) => key(
          Text(
            d,
            style: AppFont.headingMedium.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          () => onDigit(d),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [digit('1'), digit('2'), digit('3')]),
        Row(children: [digit('4'), digit('5'), digit('6')]),
        Row(children: [digit('7'), digit('8'), digit('9')]),
        Row(children: [
          key(const SizedBox(), null),
          digit('0'),
          key(
            Icon(
              LucideIcons.delete,
              size: 26,
              color: context.colors.onSurfaceVariant,
            ),
            onBackspace,
          ),
        ]),
      ],
    );
  }
}
