import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/otp_code_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/layout/auth_flow_scaffold.dart';

@RoutePage()
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  bool _complete = false;

  void _verify() {
    // UI-only (Phase 1): continue to PIN setup.
    context.router.push(PinSetupRoute());
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowScaffold(
      title: context.l10n.otpTitle,
      subtitle: context.l10n.otpSubtitle,
      showBack: true,
      children: [
        OtpCodeField(
          onCompleted: (_) => setState(() => _complete = true),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                context.l10n.otpResendPrompt,
                style: AppFont.bodyMedium.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: () {}, // UI-only
                child: Text(
                  context.l10n.otpResendCta,
                  style: AppFont.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: context.l10n.otpVerifyCta,
          onPressed: _complete ? _verify : null,
        ),
      ],
    );
  }
}
