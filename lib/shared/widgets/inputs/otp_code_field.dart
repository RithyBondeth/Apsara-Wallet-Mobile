import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';

/// Six-digit verification code input: one hidden text field driving a row
/// of styled digit boxes, with the emerald focus ring on the active box.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    this.length = 6,
    this.onCompleted,
  });

  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  String _code = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _code = _controller.text);
      if (_code.length == widget.length) {
        widget.onCompleted?.call(_code);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fill = context.isDarkMode
        ? context.colors.surface
        : AppColors.surfaceVariant;

    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Stack(
        children: [
          // Hidden driver field.
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                autofocus: true,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (i) {
              final filled = i < _code.length;
              final active = _focus.hasFocus && i == _code.length;
              return AnimatedContainer(
                duration: AppDurations.fast,
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: active ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: active
                      ? const [
                          BoxShadow(
                            color: Color(0x1A0B5B3D),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    filled ? _code[i] : '',
                    style: AppFont.headingSmall.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
