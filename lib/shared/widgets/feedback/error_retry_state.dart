import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/shared/widgets/feedback/empty_state.dart';

/// Shown when a data fetch fails (e.g. the backend is unreachable) instead of
/// silently rendering a blank screen. A friendly message plus a Retry action
/// that re-runs the fetch. Reuses [EmptyState]'s medallion/CTA layout.
class ErrorRetryState extends StatelessWidget {
  const ErrorRetryState({
    super.key,
    required this.onRetry,
    this.compact = false,
  });

  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: LucideIcons.cloudOff,
      title: l10n.errorLoadTitle,
      message: l10n.errorLoadMessage,
      ctaLabel: l10n.commonRetry,
      onCta: onRetry,
      compact: compact,
    );
  }
}
