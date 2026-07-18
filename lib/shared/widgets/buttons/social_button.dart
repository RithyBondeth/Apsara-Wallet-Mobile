import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';

/// Inline brand logos (pixel-perfect, theme-independent) rendered via
/// flutter_svg so no raster assets are needed.
class BrandSvg {
  BrandSvg._();

  static const String google = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
<path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
<path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
<path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>''';

  static const String facebook = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36 36">
<path fill="#1877F2" d="M36 18C36 8.06 27.94 0 18 0S0 8.06 0 18c0 8.98 6.58 16.43 15.19 17.78V23.2h-4.57V18h4.57v-3.96c0-4.51 2.69-7 6.8-7 1.97 0 4.03.35 4.03.35v4.43h-2.27c-2.24 0-2.94 1.39-2.94 2.82V18h5l-.8 5.2h-4.2v12.58C29.42 34.43 36 26.98 36 18z"/>
<path fill="#fff" d="M25.03 23.2l.8-5.2h-5v-3.36c0-1.42.7-2.82 2.94-2.82h2.27V7.39s-2.06-.35-4.03-.35c-4.11 0-6.8 2.49-6.8 7V18h-4.57v5.2h4.57v12.58a18.1 18.1 0 0 0 5.62 0V23.2h4.2z"/>
</svg>''';
}

/// An outlined social sign-in button with a brand logo and label,
/// featuring the same press-scale feel as [PrimaryButton].
class SocialButton extends StatefulWidget {
  const SocialButton({
    super.key,
    required this.svg,
    required this.label,
    required this.onPressed,
  });

  final String svg;
  final String label;
  final VoidCallback onPressed;

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: AppDurations.instant,
    lowerBound: 0.0,
    upperBound: 0.04,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.textMuted.withValues(alpha: 0.35);

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) =>
            Transform.scale(scale: 1 - _press.value, child: child),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: context.isDarkMode ? context.colors.surface : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.string(widget.svg, width: 20, height: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.titleSmall.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
