import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Expense / Income selector — outlined pills that tint to their semantic
/// color when active (red spend, green earn).
class TxTypeToggle extends StatelessWidget {
  const TxTypeToggle({super.key, required this.value, required this.onChanged});

  final ETransactionType value;
  final ValueChanged<ETransactionType> onChanged;

  static Color colorOf(ETransactionType type) => switch (type) {
        ETransactionType.expense => AppColors.expense,
        ETransactionType.income => AppColors.income,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (ETransactionType.expense, l10n.dashboardExpense),
      (ETransactionType.income, l10n.dashboardIncome),
    ];
    return Row(
      children: [
        for (final (i, (type, label)) in items.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _pill(context, type, label)),
        ],
      ],
    );
  }

  Widget _pill(BuildContext context, ETransactionType type, String label) {
    final selected = type == value;
    final color = colorOf(type);
    return PressScale(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.gentle,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? color : AppColors.surfaceVariant,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: AppDurations.fast,
          style: AppFont.labelLarge.copyWith(
            color: selected ? color : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
