import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart'
    show GroupedAmountFormatter;
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Colour choices for a new wallet's brand tile.
const List<Color> _walletColors = [
  Color(0xFF1E4FA3),
  Color(0xFFC79A2E),
  AppColors.income,
  Color(0xFF00A9E0),
  Color(0xFF7C5CD6),
  Color(0xFFE0507A),
  AppColors.primary,
  Color(0xFFCD6A2E),
];

/// Rough KHR→USD divisor for the mock secondary balance.
const double _khrPerUsd = 4100;

/// Bottom sheet to add a wallet/account (UI-only): name, type, initial
/// balance and a brand colour. Pops the built [Wallet].
Future<Wallet?> showAddWalletSheet(BuildContext context) {
  return showModalBottomSheet<Wallet>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
    ),
    builder: (context) => const _AddWalletSheet(),
  );
}

class _AddWalletSheet extends StatefulWidget {
  const _AddWalletSheet();

  @override
  State<_AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<_AddWalletSheet> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _balance = TextEditingController();

  WalletKind _kind = WalletKind.bank;
  Color _color = _walletColors.first;

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  int get _balanceKhr => int.tryParse(_balance.text.replaceAll(',', '')) ?? 0;
  bool get _valid => _name.text.trim().isNotEmpty;

  void _save() {
    final name = _name.text.trim();
    final isCash = _kind == WalletKind.cash;
    Navigator.of(context).pop(
      Wallet(
        name: name,
        kind: _kind,
        balanceKhr: _balanceKhr,
        balanceUsd: _balanceKhr / _khrPerUsd,
        brandColor: _color,
        // Cash gets a banknote glyph; others a short code from the name.
        icon: isCash ? LucideIcons.banknote : null,
        shortCode: isCash
            ? null
            : name.replaceAll(RegExp(r'\s+'), '').substring(
                  0,
                  name.replaceAll(RegExp(r'\s+'), '').length.clamp(0, 3),
                ).toUpperCase(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final types = [
      (WalletKind.bank, l10n.walletTypeBank),
      (WalletKind.cash, l10n.walletTypeCash),
      (WalletKind.ewallet, l10n.walletTypeEwallet),
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.xxl + keyboard,
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
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                l10n.walletsAddWallet,
                style: AppFont.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.walletNameLabel),
            const SizedBox(height: AppSpacing.sm),
            _filledField(
              child: TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                style: AppFont.bodyLarge.copyWith(color: AppColors.textPrimary),
                decoration: _inputDecoration(l10n.walletNameHint),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.walletTypeLabel),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final (i, (kind, label)) in types.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: PressScale(
                      onTap: () => setState(() => _kind = kind),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _kind == kind
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: _kind == kind
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.4,
                          ),
                        ),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.labelMedium.copyWith(
                            color: _kind == kind
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.walletInitialBalance),
            const SizedBox(height: AppSpacing.sm),
            _filledField(
              child: Row(
                children: [
                  Text(
                    'KHR',
                    style: AppFont.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _balance,
                      keyboardType: TextInputType.number,
                      inputFormatters: [GroupedAmountFormatter(decimal: false)],
                      style: AppFont.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _inputDecoration('0'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.walletColorLabel),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in _walletColors)
                  PressScale(
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: color == _color
                            ? Border.all(color: AppColors.textPrimary, width: 2)
                            : null,
                      ),
                      child: color == _color
                          ? const Icon(LucideIcons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            ListenableBuilder(
              listenable: _name,
              builder: (context, _) => PrimaryButton(
                label: l10n.commonSave,
                onPressed: _valid ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppFont.labelLarge.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _filledField({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: child,
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        hintText: hint,
        hintStyle: AppFont.bodyLarge.copyWith(color: AppColors.textMuted),
      );
}
