import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/dashboard/data/dashboard_mock_data.dart'
    show formatKhr;
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// A single transaction's detail (Phase 1, UI-only), looked up by [id] from
/// the sample history. Edit re-opens Add Transaction; Delete confirms and pops.
@RoutePage()
class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final TransactionRecord _record = findTransaction(widget.id);

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Color get _amountColor => switch (_record.type) {
        ETransactionType.income => AppColors.income,
        ETransactionType.expense => AppColors.expense,
        ETransactionType.transfer => AppGradients.goldDeep,
      };

  String _typeLabel(BuildContext context) => switch (_record.type) {
        ETransactionType.income => context.l10n.dashboardIncome,
        ETransactionType.expense => context.l10n.dashboardExpense,
        ETransactionType.transfer => context.l10n.dashboardTransfer,
      };

  void _edit() => context.router.push(
        AddTransactionRoute(initialType: _record.type),
      );

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (sheetContext) => _DeleteSheet(
        title: l10n.txDeleteTitle,
        body: l10n.txDeleteBody,
        cancel: l10n.commonCancel,
        confirm: l10n.txDelete,
      ),
    );
    if (confirmed != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Text(
          l10n.txDeleted,
          style: AppFont.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
    );
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = Localizations.localeOf(context).toString();
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final dateText =
        DateFormat.yMMMMd(localeTag).add_jm().format(_record.date);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FadeSlideIn(
                controller: _intro,
                start: 0.0,
                end: 0.4,
                offset: const Offset(0, 10),
                child: _AppBar(title: l10n.txDetailTitle, onEdit: _edit),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.md,
                    AppSpacing.xxl,
                    bottomSafe + AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.08,
                        end: 0.5,
                        child: _AmountHero(
                          record: _record,
                          amountColor: _amountColor,
                          typeLabel: _typeLabel(context),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.18,
                        end: 0.6,
                        child: _DetailCard(
                          rows: [
                            (l10n.addTxCategory, _record.category.labelOf(l10n)),
                            (l10n.addTxWallet, _record.walletName),
                            (l10n.addTxDateTime, dateText),
                            (l10n.txDetailType, _typeLabel(context)),
                            (l10n.txDetailStatus, l10n.txStatusCompleted),
                          ],
                        ),
                      ),
                      if (_record.note != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        FadeSlideIn(
                          controller: _intro,
                          start: 0.28,
                          end: 0.7,
                          child: _NoteCard(
                            label: l10n.txDetailNote,
                            note: _record.note!,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.4,
                        end: 0.9,
                        child: PrimaryButton(
                          label: l10n.txEdit,
                          trailingIcon: LucideIcons.pencil,
                          onPressed: _edit,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.48,
                        end: 1.0,
                        child: PressScale(
                          onTap: _confirmDelete,
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.expense.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.trash2,
                                  size: 18,
                                  color: AppColors.expense,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  l10n.txDelete,
                                  style: AppFont.labelLarge.copyWith(
                                    color: AppColors.expense,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _AppBar extends StatelessWidget {
  const _AppBar({required this.title, required this.onEdit});

  final String title;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          PressScale(
            onTap: () => context.router.maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: const Icon(
                LucideIcons.chevronLeft,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PressScale(
            onTap: onEdit,
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: const Icon(
                LucideIcons.pencil,
                size: 19,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centred category icon, merchant title and the big signed amount.
class _AmountHero extends StatelessWidget {
  const _AmountHero({
    required this.record,
    required this.amountColor,
    required this.typeLabel,
  });

  final TransactionRecord record;
  final Color amountColor;
  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: record.category.color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(record.category.icon, size: 32,
              color: record.category.color),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          record.title,
          textAlign: TextAlign.center,
          style: AppFont.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${record.sign} KHR ${formatKhr(record.amountKhr)}',
          style: AppFont.headingLarge.copyWith(
            color: amountColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: amountColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            typeLabel,
            style: AppFont.labelMedium.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: AppColors.surfaceVariant),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Text(
                    rows[i].$1,
                    style: AppFont.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.right,
                      style: AppFont.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.label, required this.note});

  final String label;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFont.labelMedium.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: AppFont.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteSheet extends StatelessWidget {
  const _DeleteSheet({
    required this.title,
    required this.body,
    required this.cancel,
    required this.confirm,
  });

  final String title;
  final String body;
  final String cancel;
  final String confirm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.xxl,
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.trash2,
                color: AppColors.expense,
                size: 26,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppFont.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: PressScale(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Text(
                        cancel,
                        style: AppFont.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PressScale(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.expense,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Text(
                        confirm,
                        style: AppFont.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
