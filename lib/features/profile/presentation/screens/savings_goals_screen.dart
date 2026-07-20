import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/dashboard/data/dashboard_mock_data.dart'
    show formatKhr;
import 'package:apsara_wallet_mobile/features/profile/data/savings_goals_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart'
    show GroupedAmountFormatter;
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/count_up_text.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Savings Goals (Phase 1, UI-only): set targets and track progress toward
/// them. Tapping a goal adds funds to it; "+ Add Goal" appends a new one.
/// Purely a tracker — no money is moved.
@RoutePage()
class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  late final Animation<double> _fill = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
  );

  final List<SavingsGoal> _goals = sampleSavingsGoals();

  int get _totalSaved => _goals.fold(0, (s, g) => s + g.savedKhr);
  int get _totalTarget => _goals.fold(0, (s, g) => s + g.targetKhr);

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
    setState(() {
      final i = _goals.indexWhere((g) => g.id == goal.id);
      if (i >= 0) {
        _goals[i] = _goals[i].copyWith(savedKhr: _goals[i].savedKhr + amount);
      }
    });
    _snack(context.l10n.savingsFundsAdded);
  }

  Future<void> _addGoal() async {
    final result = await _newGoalSheet();
    if (result == null || !mounted) return;
    setState(() => _goals.add(result));
    _snack(context.l10n.savingsGoalAdded);
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
                child: ListView(
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
                        targetLine: l10n.savingsTargetOf(formatKhr(_totalTarget)),
                        totalSaved: _totalSaved,
                        fraction: _totalTarget == 0
                            ? 0
                            : _totalSaved / _totalTarget,
                        fill: _fill,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    for (var i = 0; i < _goals.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.md),
                      FadeSlideIn(
                        controller: _intro,
                        start: (0.2 + i * 0.08).clamp(0.0, 0.6),
                        end: (0.6 + i * 0.08).clamp(0.0, 1.0),
                        child: _GoalCard(
                          goal: _goals[i],
                          fill: _fill,
                          onAddFunds: () => _addFunds(_goals[i]),
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

  Future<SavingsGoal?> _newGoalSheet() {
    return showModalBottomSheet<SavingsGoal>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (sheetContext) => const _NewGoalSheet(),
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
              Text(
                'KHR ',
                style: AppFont.titleMedium.copyWith(
                  color: AppGradients.goldLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CountUpText(
                value: totalSaved,
                formatter: (v) => formatKhr(v.round()),
                style: AppFont.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
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
  });

  final SavingsGoal goal;
  final Animation<double> fill;
  final VoidCallback onAddFunds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PressScale(
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
                      Text.rich(
                        TextSpan(
                          text: 'KHR ',
                          style: AppFont.labelMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                          children: [
                            TextSpan(
                              text: formatKhr(goal.savedKhr),
                              style: AppFont.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' / ${formatKhr(goal.targetKhr)}'),
                          ],
                        ),
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

/// New-goal sheet (name + target amount).
class _NewGoalSheet extends StatefulWidget {
  const _NewGoalSheet();

  @override
  State<_NewGoalSheet> createState() => _NewGoalSheetState();
}

class _NewGoalSheetState extends State<_NewGoalSheet> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _target = TextEditingController();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _grabber(),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                l10n.savingsAddGoal,
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
                            SavingsGoal(
                              id: 'custom-${_name.text.trim()}',
                              icon: LucideIcons.target,
                              color: AppColors.primary,
                              savedKhr: 0,
                              targetKhr: target,
                              customName: _name.text.trim(),
                            ),
                          ),
                );
              },
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
