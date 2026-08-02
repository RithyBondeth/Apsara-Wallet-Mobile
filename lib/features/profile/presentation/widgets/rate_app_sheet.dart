import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/data/feedback_api.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';

/// Opens the in-app "Rate Apsara Wallet" bottom sheet.
///
/// Two-step rating gate:
///  * 4–5 stars → thank the user and best-effort open the store listing.
///  * 1–3 stars → a comment step keeps the feedback in-app.
///
/// Every submission is recorded to the backend (`POST /feedback`) best-effort,
/// so a network failure never blocks the thank-you.
Future<void> showRateAppSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const RateAppSheet(),
  );
}

enum _Step { rate, comment }

class RateAppSheet extends ConsumerStatefulWidget {
  const RateAppSheet({super.key});

  @override
  ConsumerState<RateAppSheet> createState() => _RateAppSheetState();
}

class _RateAppSheetState extends ConsumerState<RateAppSheet> {
  int _rating = 0;
  _Step _step = _Step.rate;
  bool _sending = false;
  final TextEditingController _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  String get _platform => defaultTargetPlatform.name.toLowerCase();

  Future<void> _record(String? comment) async {
    try {
      await ref.read(feedbackApiProvider).submit(
            rating: _rating,
            comment: comment,
            appVersion: AppConstants.appVersion,
            platform: _platform,
          );
    } catch (_) {
      // Best-effort — never block the thank-you on a network hiccup.
    }
  }

  Future<void> _openStore() async {
    // Null on iOS until the App Store record exists — better to open nothing
    // than to drop the user on a "not available" store page.
    final url = defaultTargetPlatform == TargetPlatform.iOS
        ? AppConstants.appStoreUrlOrNull
        : AppConstants.playStoreUrl;
    if (url == null) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Store not reachable (e.g. unpublished build) — swallow.
    }
  }

  void _thankAndClose() {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
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
  }

  /// Rate-step primary action: high ratings finish immediately, low ratings
  /// advance to the comment step.
  Future<void> _onSubmitRating() async {
    if (_rating == 0) return;
    if (_rating <= 3) {
      setState(() => _step = _Step.comment);
      return;
    }
    setState(() => _sending = true);
    await _record(null);
    if (!mounted) return;
    _thankAndClose();
    await _openStore();
  }

  /// Comment-step action: send the low rating + optional comment.
  Future<void> _onSendComment() async {
    setState(() => _sending = true);
    final text = _comment.text.trim();
    await _record(text.isEmpty ? null : text);
    if (!mounted) return;
    _thankAndClose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
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
            if (_step == _Step.rate) _buildRate(context) else _buildComment(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRate(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(LucideIcons.star, color: AppColors.accent, size: 30),
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
                onTap: _sending ? null : () => setState(() => _rating = star),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: l10n.rateSubmit,
          loading: _sending,
          onPressed: _rating == 0 ? null : _onSubmitRating,
        ),
      ],
    );
  }

  Widget _buildComment(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.rateLowTitle,
          textAlign: TextAlign.center,
          style: AppFont.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.rateLowSubtitle,
          textAlign: TextAlign.center,
          style: AppFont.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _comment,
          minLines: 3,
          maxLines: 5,
          maxLength: 2000,
          textInputAction: TextInputAction.newline,
          style: AppFont.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.rateCommentHint,
            hintStyle: AppFont.bodyMedium.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          label: l10n.rateSend,
          loading: _sending,
          onPressed: _sending ? null : _onSendComment,
        ),
      ],
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback? onTap;

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
