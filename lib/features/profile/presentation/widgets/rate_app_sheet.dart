import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';

/// Opens the in-app "Rate Apsara Wallet" bottom sheet.
///
/// The sheet is self-contained and works before the app is published: it
/// captures a 1–5 star rating in-app. A high rating (4–5) additionally offers
/// to open the platform store listing (best-effort — see [AppConstants]
/// store URLs), while lower ratings simply thank the user and point them at
/// support so we hear the feedback privately.
Future<void> showRateAppSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const RateAppSheet(),
  );
}

class RateAppSheet extends StatefulWidget {
  const RateAppSheet({super.key});

  @override
  State<RateAppSheet> createState() => _RateAppSheetState();
}

class _RateAppSheetState extends State<RateAppSheet> {
  int _rating = 0;

  Future<void> _openStore() async {
    final url = defaultTargetPlatform == TargetPlatform.iOS
        ? AppConstants.appStoreUrl
        : AppConstants.playStoreUrl;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Store not reachable (e.g. unpublished build) — swallow; the caller
      // already showed a thank-you message.
    }
  }

  Future<void> _submit() async {
    final rating = _rating;
    Navigator.of(context).pop();

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Text(
          context.l10n.rateThankYou,
          style: AppFont.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
    );

    if (rating >= 4) {
      await _openStore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        bottomSafe + AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                LucideIcons.star,
                color: AppColors.accent,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.rateTitle,
            textAlign: TextAlign.center,
            style: AppFont.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.rateSubtitle,
            textAlign: TextAlign.center,
            style: AppFont.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var star = 1; star <= 5; star++)
                _StarButton(
                  filled: star <= _rating,
                  onTap: () => setState(() => _rating = star),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: l10n.rateSubmit,
            onPressed: _rating == 0 ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      iconSize: 40,
      splashRadius: 28,
      icon: Icon(
        filled ? Icons.star_rounded : Icons.star_outline_rounded,
        color: filled ? AppColors.accent : AppColors.textMuted,
      ),
    );
  }
}
