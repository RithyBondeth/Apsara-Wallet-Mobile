import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';

/// Hairline divider with a quiet centred label — "or continue with".
///
/// When [label] is omitted, the localized default is used.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final resolvedLabel = label ?? context.l10n.authOrContinueWith;
    final line = Expanded(
      child: Divider(
        color: context.colors.onSurfaceVariant.withValues(alpha: 0.25),
        thickness: 1,
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            resolvedLabel,
            style: AppFont.bodySmall.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        line,
      ],
    );
  }
}
