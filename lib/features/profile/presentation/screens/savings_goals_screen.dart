import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/providers/money_format_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/data/savings_goals_mock_data.dart';
import 'package:apsara_wallet_mobile/features/profile/data/savings_goals_providers.dart';
import 'package:apsara_wallet_mobile/features/profile/data/savings_icon_choices.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart'
    show GroupedAmountFormatter;
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/feedback/empty_state.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/count_up_text.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Savings Goals: set targets and track progress toward them, API-backed.
/// Tapping a goal adds funds to it; "+ Add Goal" creates a new one. Purely a
/// tracker — no money is moved.
@RoutePage()
class SavingsGoalsScreen extends ConsumerStatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  ConsumerState<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends ConsumerState<SavingsGoalsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  late final Animation<double> _fill = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
  );

  void _snack(String message) {
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
      ),
    );
  }

  Future<void> _addFunds(SavingsGoal goal) async {
    final amount = await _amountSheet(
      title: goal.nameOf(context.l10n),
      cta: context.l10n.savingsAddFunds,
    );
    if (amount == null || amount <= 0 || !mounted) return;
    try {
      await ref.read(savingsGoalsProvider.notifier).addFunds(goal.id, amount);
      if (mounted) _snack(context.l10n.savingsFundsAdded);
    } catch (_) {
      if (mounted) _snack(context.l10n.savingsError);
    }
  }

  Future<void> _addGoal() async {
    final result = await _newGoalSheet();
    final goal = result?.goal;
    if (goal == null || !mounted) return;
    try {
      await ref.read(savingsGoalsProvider.notifier).addGoal(goal);
      if (mounted) _snack(context.l10n.savingsGoalAdded);
    } catch (_) {
      if (mounted) _snack(context.l10n.savingsError);
    }
  }

  /// Long-press a goal to edit its name / target / icon / colour, or delete it.
  Future<void> _editGoal(SavingsGoal goal) async {
    final result = await _newGoalSheet(initial: goal);
    if (result == null || !mounted) return;
    if (result.delete) {
      await _deleteGoal(goal);
      return;
    }
    final edited = result.goal;
    if (edited == null) return;
    try {
      await ref.read(savingsGoalsProvider.notifier).edit(edited);
      if (mounted) _snack(context.l10n.savingsGoalUpdated);
    } catch (_) {
      if (mounted) _snack(context.l10n.savingsError);
    }
  }

  Future<void> _deleteGoal(SavingsGoal goal) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(l10n.savingsDeleteConfirmTitle),
        content: Text(l10n.savingsDeleteConfirmBody(goal.nameOf(l10n))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.savingsDeleteGoal,
              style: const TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(savingsGoalsProvider.notifier).remove(goal.id);
      if (mounted) _snack(context.l10n.savingsGoalDeleted);
    } catch (_) {
      if (mounted) _snack(context.l10n.savingsError);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    final goalsAsync = ref.watch(savingsGoalsProvider);
    final goals = goalsAsync.valueOrNull ?? const <SavingsGoal>[];
    final loading = goalsAsync.isLoading && !goalsAsync.hasValue;
    final totalSaved = goals.fold<int>(0, (s, g) => s + g.savedKhr);
    final totalTarget = goals.fold<int>(0, (s, g) => s + g.targetKhr);

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
                child: _AppBar(
                  title: l10n.savingsTitle,
                  addLabel: l10n.savingsAddGoal,
                  onAdd: _addGoal,
                ),
              ),
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.md,
                          AppSpacing.xxl,
                          bottomSafe + AppSpacing.xxxl,
                        ),
                        children: [
                          FadeSlideIn(
                            controller: _intro,
                            start: 0.08,
                            end: 0.5,
                            child: _SummaryCard(
                              savedLabel: l10n.savingsTotalSaved,
                              targetLine: l10n.savingsTargetOf(
                                ref
                                    .watch(moneyFormatterProvider)
                                    .number(totalTarget),
                              ),
                              totalSaved: totalSaved,
                              fraction: totalTarget == 0
                                  ? 0
                                  : totalSaved / totalTarget,
                              fill: _fill,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (goals.isEmpty)
                            FadeSlideIn(
                              controller: _intro,
                              start: 0.2,
                              end: 0.7,
                              child: EmptyState(
                                icon: LucideIcons.piggyBank,
                                title: l10n.savingsEmptyTitle,
                                message: l10n.savingsEmptyBody,
                                ctaLabel: l10n.savingsAddGoal,
                                onCta: _addGoal,
                              ),
                            )
                          else
                            for (var i = 0; i < goals.length; i++) ...[
                              if (i > 0) const SizedBox(height: AppSpacing.md),
                              FadeSlideIn(
                                controller: _intro,
                                start: (0.2 + i * 0.08).clamp(0.0, 0.6),
                                end: (0.6 + i * 0.08).clamp(0.0, 1.0),
                                child: _GoalCard(
                                  goal: goals[i],
                                  fill: _fill,
                                  onAddFunds: () => _addFunds(goals[i]),
                                  onEdit: () => _editGoal(goals[i]),
                                ),
                              ),
                            ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sheets --------------------------------------------------------------

  Future<int?> _amountSheet({required String title, required String cta}) {
    final controller = TextEditingController();
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (sheetContext) => _AmountSheet(
        title: title,
        cta: cta,
        controller: controller,
      ),
    );
  }

  Future<_GoalSheetResult?> _newGoalSheet({SavingsGoal? initial}) {
    return showModalBottomSheet<_GoalSheetResult>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (sheetContext) => _NewGoalSheet(initial: initial),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.title,
    required this.addLabel,
    required this.onAdd,
  });

  final String title;
  final String addLabel;
  final VoidCallback onAdd;

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
            onTap: onAdd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
                const SizedBox(width: 2),
                Text(
                  addLabel,
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

/// Emerald total-saved hero with an overall progress bar.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.savedLabel,
    required this.targetLine,
    required this.totalSaved,
    required this.fraction,
    required this.fill,
  });

  final String savedLabel;
  final String targetLine;
  final int totalSaved;
  final double fraction;
  final Animation<double> fill;

  static const Color _ivory = Color(0xFFF3F1E7);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppGradients.emerald,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330B5B3D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                savedLabel,
                style: AppFont.labelLarge.copyWith(
                  color: _ivory.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              const Icon(LucideIcons.piggyBank, size: 20, color: _ivory),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Consumer(
                builder: (context, ref, _) => Text(
                  '${ref.watch(moneyFormatterProvider).code} ',
                  style: AppFont.titleMedium.copyWith(
                    color: AppGradients.goldLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final money = ref.watch(moneyFormatterProvider);
                  return CountUpText(
                    value: totalSaved,
                    formatter: (v) => money.number(v.round()),
                    style: AppFont.headingMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            targetLine,
            style: AppFont.bodyMedium.copyWith(
              color: _ivory.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LayoutBuilder(
              builder: (context, c) => AnimatedBuilder(
                animation: fill,
                builder: (context, _) => Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    Container(
                      height: 10,
                      width: c.maxWidth * (fraction * fill.value).clamp(0.0, 1.0),
                      decoration: const BoxDecoration(
                        gradient: AppGradients.goldFoil,
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
}

/// One goal: icon, name, saved/target, % and a gradient progress bar, with an
/// "Add Funds" affordance.
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.fill,
    required this.onAddFunds,
    required this.onEdit,
  });

  final SavingsGoal goal;
  final Animation<double> fill;
  final VoidCallback onAddFunds;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Tap adds funds; long-press edits the goal.
    return GestureDetector(
      onLongPress: onEdit,
      child: PressScale(
      onTap: onAddFunds,
      pressedScale: 0.99,
      child: Container(
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
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 21),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.nameOf(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
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
                                  text: money.number(goal.savedKhr),
                                  style: AppFont.labelMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / ${money.number(goal.targetKhr)}',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(goal.fraction * 100).round()}%',
                  style: AppFont.titleSmall.copyWith(
                    color: goal.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LayoutBuilder(
                builder: (context, c) => AnimatedBuilder(
                  animation: fill,
                  builder: (context, _) => Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        color: AppColors.surfaceVariant,
                      ),
                      Container(
                        height: 8,
                        width: c.maxWidth *
                            (goal.fraction * fill.value).clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              goal.color.withValues(alpha: 0.7),
                              goal.color,
                            ],
                          ),
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
    );
  }
}

/// Amount entry sheet (add funds to a goal).
class _AmountSheet extends StatelessWidget {
  const _AmountSheet({
    required this.title,
    required this.cta,
    required this.controller,
  });

  final String title;
  final String cta;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
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
            _grabber(),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                title,
                style: AppFont.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _KhrField(controller: controller),
            const SizedBox(height: AppSpacing.xxl),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final value =
                    int.tryParse(controller.text.replaceAll(',', '')) ?? 0;
                return PrimaryButton(
                  label: cta,
                  onPressed: value <= 0
                      ? null
                      : () => Navigator.of(context).pop(value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Colour choices for a savings goal's icon tile.
const List<Color> _savingsGoalColors = [
  AppColors.primary,
  AppColors.info,
  AppGradients.goldCore,
  Color(0xFF7C5CD6),
  Color(0xFFE0507A),
  Color(0xFF00A9E0),
  Color(0xFFCD6A2E),
  AppColors.income,
];

/// Result of the goal sheet: a goal to save/add, or a delete request (edit mode).
class _GoalSheetResult {
  const _GoalSheetResult.save(this.goal) : delete = false;
  const _GoalSheetResult.remove()
      : goal = null,
        delete = true;

  final SavingsGoal? goal;
  final bool delete;
}

/// New/edit-goal sheet (name, target, icon + colour). With [initial] it edits
/// that goal (prefilled, with a delete action), otherwise it creates a new one.
class _NewGoalSheet extends StatefulWidget {
  const _NewGoalSheet({this.initial});

  final SavingsGoal? initial;

  @override
  State<_NewGoalSheet> createState() => _NewGoalSheetState();
}

class _NewGoalSheetState extends State<_NewGoalSheet> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _target = TextEditingController();

  late IconData _icon = savingsIconChoices.values.first; // 'target'
  late Color _color = _savingsGoalColors.first;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final g = widget.initial;
    if (g != null) {
      _name.text = g.customName ?? '';
      _target.text =
          NumberFormat.decimalPattern('en_US').format(g.targetKhr);
      _icon = g.icon;
      _color = g.color;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _grabber(),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                _isEditing ? l10n.savingsEditGoal : l10n.savingsAddGoal,
                style: AppFont.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.savingsGoalName),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                style: AppFont.bodyLarge.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.savingsGoalTarget),
            const SizedBox(height: AppSpacing.sm),
            _KhrField(controller: _target, onChanged: () => setState(() {})),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.savingsGoalIcon),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final icon in savingsIconChoices.values)
                  PressScale(
                    onTap: () => setState(() => _icon = icon),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: icon == _icon
                            ? _color.withValues(alpha: 0.14)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: icon == _icon ? _color : Colors.transparent,
                          width: 1.6,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: icon == _icon ? _color : AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.savingsGoalColor),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in _savingsGoalColors)
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
            Builder(
              builder: (context) {
                final target =
                    int.tryParse(_target.text.replaceAll(',', '')) ?? 0;
                final valid = _name.text.trim().isNotEmpty && target > 0;
                return PrimaryButton(
                  label: l10n.commonSave,
                  onPressed: !valid
                      ? null
                      : () => Navigator.of(context).pop(
                            _GoalSheetResult.save(
                              SavingsGoal(
                                id: widget.initial?.id ??
                                    'custom-${_name.text.trim()}',
                                icon: _icon,
                                color: _color,
                                savedKhr: widget.initial?.savedKhr ?? 0,
                                targetKhr: target,
                                customName: _name.text.trim(),
                              ),
                            ),
                          ),
                );
              },
            ),
            if (_isEditing) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(const _GoalSheetResult.remove()),
                child: Text(
                  l10n.savingsDeleteGoal,
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
}

/// A KHR-prefixed integer amount field (comma-grouped).
class _KhrField extends StatelessWidget {
  const _KhrField({required this.controller, this.onChanged});

  final TextEditingController controller;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [GroupedAmountFormatter(decimal: false)],
              onChanged: (_) => onChanged?.call(),
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
    );
  }
}

Widget _grabber() => Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
