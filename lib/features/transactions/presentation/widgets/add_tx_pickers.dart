import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Bottom-sheet pickers for the Add Transaction form (category grid, wallet
/// list). All UI-only: they resolve to the chosen value via [Navigator.pop].

Future<T?> _showSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: child,
      ),
    ),
  );
}

Widget _grabberAndTitle(String title) {
  return Column(
    children: [
      Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text(
        title,
        style: AppFont.titleMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
    ],
  );
}

/// Grid of categories (4 per row, like the design board's Category screen).
Future<TxCategory?> showCategoryPicker(
  BuildContext context, {
  required List<TxCategory> categories,
  TxCategory? selected,
}) {
  final l10n = context.l10n;
  return _showSheet<TxCategory>(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _grabberAndTitle(l10n.addTxChooseCategory),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.86,
          children: [
            for (final c in categories)
              PressScale(
                onTap: () => Navigator.of(context).pop(c),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: c.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: c.id == selected?.id
                            ? Border.all(color: c.color, width: 1.6)
                            : null,
                      ),
                      child: Icon(c.icon, size: 21, color: c.color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.labelOf(l10n),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

/// List of wallets from the Phase-1 sample data.
Future<Wallet?> showWalletPicker(
  BuildContext context, {
  required List<Wallet> wallets,
  Wallet? selected,
  String? title,
}) {
  final l10n = context.l10n;
  return _showSheet<Wallet>(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _grabberAndTitle(title ?? l10n.addTxChooseWallet),
        for (final w in wallets)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PressScale(
              onTap: () => Navigator.of(context).pop(w),
              pressedScale: 0.98,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: w.name == selected?.name
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    width: w.name == selected?.name ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    WalletBrandTile(wallet: w),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        w.maskedAccount == null
                            ? w.name
                            : '${w.name} (${w.accountLast4})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'KHR ${formatKhr(w.balanceKhr)}',
                      style: AppFont.labelMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// KHR / USD choice for the amount field's currency chip.
Future<ECurrencyType?> showCurrencyPicker(
  BuildContext context, {
  required ECurrencyType selected,
}) {
  final l10n = context.l10n;
  return _showSheet<ECurrencyType>(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _grabberAndTitle(l10n.addTxChooseCurrency),
        for (final (c, code, name) in [
          (ECurrencyType.khr, 'KHR', 'Cambodian Riel'),
          (ECurrencyType.usd, 'USD', 'US Dollar'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PressScale(
              onTap: () => Navigator.of(context).pop(c),
              pressedScale: 0.98,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: c == selected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    width: c == selected ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        c == ECurrencyType.khr ? '៛' : r'$',
                        style: AppFont.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        code,
                        style: AppFont.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      name,
                      style: AppFont.labelMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Small rounded brand square for a wallet (short code or fallback icon).
class WalletBrandTile extends StatelessWidget {
  const WalletBrandTile({super.key, required this.wallet, this.size = 40});

  final Wallet wallet;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: wallet.brandColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: wallet.shortCode != null
          ? Text(
              wallet.shortCode!,
              style: AppFont.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            )
          : Icon(
              wallet.icon ?? LucideIcons.wallet,
              size: 18,
              color: Colors.white,
            ),
    );
  }
}
