import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/providers/money_format_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/budget/data/budget_mock_data.dart';
import 'package:apsara_wallet_mobile/features/budget/data/budget_providers.dart';
import 'package:apsara_wallet_mobile/features/categories/data/category_api.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart'
    show GroupedAmountFormatter;
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/add_tx_pickers.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/picker_row.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/feedback/empty_state.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/count_up_text.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Monthly budget overview (Phase 1, UI-only): the month's total progress and
/// per-category budgets, per the design board's Budget mockup. "+ Add Budget"
/// opens a sheet that appends a category budget to the local list only.
@RoutePage()
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  /// Bars fill during the middle of the cascade.
  late final Animation<double> _fill = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.25, 0.85, curve: AppCurves.decelerate),
  );

  /// Opens the add/edit sheet. With [initial] it edits (and can delete) that
  /// category's budget; without it, it adds a new one. Saves flow through the
  /// API-backed [budgetDataProvider].
  Future<void> _openSheet([CategoryBudget? initial]) async {
    final result = await showModalBottomSheet<_BudgetSheetResult>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => _AddBudgetSheet(
        initial: initial,
        categories: [
          ...expenseCategories,
          ...(ref.read(userCategoriesProvider).valueOrNull?.expense ??
              const []),
        ],
      ),
    );
    if (result == null || !mounted) return;
    final l10n = context.l10n;
    final notifier = ref.read(budgetDataProvider.notifier);

    try {
      if (result.delete && initial != null) {
        await notifier.removeBudget(initial.category);
        if (mounted) _snack(l10n.budgetDeleted);
      } else if (result.budget != null) {
        final budget = result.budget!;
        final wasSet = initial != null;
        await notifier.setBudget(budget.category, budget.limitKhr);
        if (mounted) _snack(wasSet ? l10n.budgetUpdated : l10n.budgetAdded);
      }
    } catch (_) {
      if (mounted) _snack(l10n.addTxSaveFailed);
    }
  }

  void _snack(String message, {VoidCallback? undo}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Text(
          message,
          style: AppFont.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        action: undo == null
            ? null
            : SnackBarAction(
                label: context.l10n.commonUndo,
                textColor: Colors.white,
                onPressed: undo,
              ),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(budgetDataProvider);
    final bottomSafe = MediaQuery.of(context).padding.bottom;

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
                end: 0.35,
                offset: const Offset(0, 10),
                child: _AppBar(onAddBudget: () => _openSheet()),
              ),
              Expanded(
                child: async.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: Text(
                      context.l10n.addTxSaveFailed,
                      style: AppFont.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  data: (data) => _body(context, data, bottomSafe),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, BudgetData data, double bottomSafe) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.sm,
        AppSpacing.xxl,
        bottomSafe + AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            controller: _intro,
            start: 0.08,
            end: 0.5,
            child: _MonthCard(data: data, fill: _fill),
          ),
          const SizedBox(height: AppSpacing.xxl),
          FadeSlideIn(
            controller: _intro,
            start: 0.2,
            end: 0.6,
            child: Text(
              l10n.budgetByCategory,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.categories.isEmpty)
            EmptyState(
              compact: true,
              icon: LucideIcons.target,
              title: l10n.budgetEmptyTitle,
              message: l10n.budgetEmptyBody,
              ctaLabel: l10n.budgetAdd,
              onCta: () => _openSheet(),
            )
          else
            for (final (i, cb) in data.categories.indexed) ...[
              FadeSlideIn(
                controller: _intro,
                start: (0.26 + 0.08 * i).clamp(0.0, 0.6),
                end: (0.66 + 0.08 * i).clamp(0.0, 1.0),
                child: _CategoryBudgetRow(
                  budget: cb,
                  fill: _fill,
                  onTap: () => _openSheet(cb),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}

/// Back chevron + centered title + "+ Add Budget" text action.
class _AppBar extends StatelessWidget {
  const _AppBar({required this.onAddBudget});

  final VoidCallback onAddBudget;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
              l10n.budgetTitle,
              textAlign: TextAlign.center,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PressScale(
            onTap: onAddBudget,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.plus,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 2),
                Text(
                  l10n.budgetAdd,
                  style: AppFont.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The month summary: big animated percentage, gradient progress bar,
/// spent vs budget readouts.
class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.data, required this.fill});

  final BudgetData data;
  final Animation<double> fill;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.monthLabel,
            style: AppFont.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  l10n.budgetProgress,
                  style: AppFont.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              CountUpText(
                value: (data.fraction * 100).roundToDouble(),
                formatter: (v) => '${v.round()}%',
                duration: const Duration(milliseconds: 900),
                style: AppFont.headingMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _GradientBar(fraction: data.fraction, fill: fill, height: 12),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MoneyReadout(
                  label: l10n.budgetSpent,
                  amountKhr: data.spentKhr,
                  alignEnd: false,
                ),
              ),
              _MoneyReadout(
                label: l10n.dashboardBudget,
                amountKhr: data.totalBudgetKhr,
                alignEnd: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyReadout extends StatelessWidget {
  const _MoneyReadout({
    required this.label,
    required this.amountKhr,
    required this.alignEnd,
  });

  final String label;
  final int amountKhr;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFont.labelMedium.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Consumer(
          builder: (context, ref, _) => Text(
            ref.watch(moneyFormatterProvider).format(amountKhr),
            style: AppFont.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// One category budget: icon tile, name, spent/limit, % and a gradient bar.
class _CategoryBudgetRow extends StatelessWidget {
  const _CategoryBudgetRow({
    required this.budget,
    required this.fill,
    required this.onTap,
  });

  final CategoryBudget budget;
  final Animation<double> fill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = budget.category;
    return PressScale(
      onTap: onTap,
      pressedScale: 0.99,
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(c.icon, size: 20, color: c.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.labelOf(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${(budget.fraction * 100).round()}%',
                      style: AppFont.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Consumer(
                  builder: (context, ref, _) {
                    final money = ref.watch(moneyFormatterProvider);
                    return Text.rich(
                      TextSpan(
                        text: '${money.code} ',
                        style: AppFont.labelMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                        children: [
                          TextSpan(
                            text: money.number(budget.spentKhr),
                            style: AppFont.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${money.number(budget.limitKhr)}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _GradientBar(
                  fraction: budget.fraction,
                  fill: fill,
                  height: 8,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Rounded track whose gradient fill animates in with [fill] × [fraction].
class _GradientBar extends StatelessWidget {
  const _GradientBar({
    required this.fraction,
    required this.fill,
    required this.height,
  });

  final double fraction;
  final Animation<double> fill;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedBuilder(
          animation: fill,
          builder: (context, _) => Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                color: AppColors.surfaceVariant,
              ),
              Container(
                height: height,
                width: constraints.maxWidth *
                    (fraction * fill.value).clamp(0.0, 1.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppGradients.emeraldGlow, AppColors.primary],
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

/// Result of the budget add/edit sheet: a budget to save, or a delete request.
class _BudgetSheetResult {
  const _BudgetSheetResult.save(this.budget) : delete = false;
  const _BudgetSheetResult.remove()
      : budget = null,
        delete = true;

  final CategoryBudget? budget;
  final bool delete;
}

/// Pick a category and a monthly limit. With [initial] it edits that budget
/// (category locked, limit prefilled, delete available); pops a
/// [_BudgetSheetResult].
class _AddBudgetSheet extends StatefulWidget {
  const _AddBudgetSheet({this.initial, required this.categories});

  final CategoryBudget? initial;

  /// Expense categories to choose from (system + the user's own).
  final List<TxCategory> categories;

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final TextEditingController _amount = TextEditingController();
  late TxCategory _category = widget.initial?.category ??
      (widget.categories.isNotEmpty
          ? widget.categories.first
          : expenseCategories.first);

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _amount.text =
          NumberFormat.decimalPattern('en_US').format(initial.limitKhr);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  int get _limit => int.tryParse(_amount.text.replaceAll(',', '')) ?? 0;

  Future<void> _pickCategory() async {
    final picked = await showCategoryPicker(
      context,
      categories: widget.categories,
      selected: _category,
    );
    if (picked == null || !mounted) return;
    setState(() => _category = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
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
                _isEditing ? l10n.budgetEditTitle : l10n.budgetAdd,
                style: AppFont.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.addTxCategory,
              style: AppFont.labelLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            PickerRow(
              leading: PickerRowIconTile(
                icon: _category.icon,
                color: _category.color,
              ),
              label: _category.labelOf(l10n),
              // Category is the budget's identity, so it's locked when editing.
              onTap: _isEditing ? null : _pickCategory,
              trailing: _isEditing ? const SizedBox.shrink() : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.budgetMonthlyLimit,
              style: AppFont.labelLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
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
                      controller: _amount,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [GroupedAmountFormatter(decimal: false)],
                      style: AppFont.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: AppFont.titleLarge.copyWith(
                          color: AppColors.textMuted.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ListenableBuilder(
              listenable: _amount,
              builder: (context, _) => PrimaryButton(
                label: l10n.commonSave,
                onPressed: _limit <= 0
                    ? null
                    : () => Navigator.of(context).pop(
                          _BudgetSheetResult.save(
                            CategoryBudget(
                              category: _category,
                              limitKhr: _limit,
                              spentKhr: widget.initial?.spentKhr ?? 0,
                            ),
                          ),
                        ),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pop(const _BudgetSheetResult.remove()),
                child: Text(
                  l10n.budgetDelete,
                  style: AppFont.labelLarge.copyWith(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
