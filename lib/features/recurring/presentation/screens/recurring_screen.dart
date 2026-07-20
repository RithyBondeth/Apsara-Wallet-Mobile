import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/core/utils/uuid_generator.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_providers.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_rule.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart'
    show GroupedAmountFormatter;
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/add_tx_pickers.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/picker_row.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/tx_type_toggle.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

String _khr(num value) => 'KHR ${NumberFormat.decimalPattern('en_US').format(value)}';

/// Recurring entries — the repeating income/expense the user tracks (salary,
/// rent, subscriptions). Lists them with an estimated monthly-expense summary
/// and an add flow. Data comes from [recurringProvider] (in-memory sample).
@RoutePage()
class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  /// Opens the add/edit sheet. With [initial] it edits (and can delete) that
  /// rule; without it, it creates a new one.
  Future<void> _openSheet([RecurringRule? initial]) async {
    final result = await showModalBottomSheet<_SheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (_) => _AddRecurringSheet(initial: initial),
    );
    if (result == null || !mounted) return;
    final notifier = ref.read(recurringProvider.notifier);
    final l10n = context.l10n;
    if (result.delete && initial != null) {
      notifier.remove(initial.id);
      _snack(l10n.recurringDeleted, undo: () => notifier.add(initial));
    } else if (result.rule != null) {
      if (initial != null) {
        notifier.update(result.rule!);
        _snack(l10n.recurringUpdated);
      } else {
        notifier.add(result.rule!);
        _snack(l10n.recurringSaved);
      }
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
  Widget build(BuildContext context) {
    final rules = ref.watch(recurringProvider);
    final monthlyExpense = ref.watch(recurringMonthlyExpenseProvider);
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
                child: _AppBar(onAdd: () => _openSheet()),
              ),
              Expanded(
                child: SingleChildScrollView(
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
                        scaleFrom: 0.97,
                        child: _SummaryCard(
                          count: rules.length,
                          monthlyExpense: monthlyExpense,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (rules.isEmpty)
                        FadeSlideIn(
                          controller: _intro,
                          start: 0.2,
                          end: 0.7,
                          child: const _EmptyState(),
                        )
                      else
                        for (final (i, rule) in rules.indexed)
                          FadeSlideIn(
                            controller: _intro,
                            start: (0.2 + i * 0.08).clamp(0.0, 0.8),
                            end: (0.55 + i * 0.08).clamp(0.0, 1.0),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _RuleCard(
                                rule: rule,
                                onTap: () => _openSheet(rule),
                              ),
                            ),
                          ),
                      if (rules.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        FadeSlideIn(
                          controller: _intro,
                          start: 0.6,
                          end: 1.0,
                          child: PressScale(
                            onTap: () => _openSheet(),
                            child: _AddButton(label: context.l10n.recurringAdd),
                          ),
                        ),
                      ],
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
  const _AppBar({required this.onAdd});

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
              context.l10n.recurringTitle,
              textAlign: TextAlign.center,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PressScale(
            onTap: onAdd,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                gradient: AppGradients.emerald,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.plus, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Count of entries + estimated monthly expense commitment.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.count, required this.monthlyExpense});

  final int count;
  final double monthlyExpense;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppGradients.emerald,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3327A79A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.repeat, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recurringActiveCount(count),
                  style: AppFont.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.recurringMonthlyEstimate(_khr(monthlyExpense.round())),
                  style: AppFont.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
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

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule, required this.onTap});

  final RecurringRule rule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = Localizations.localeOf(context).toString();
    final amountColor = rule.isIncome ? AppColors.income : AppColors.expense;
    final dueLabel = DateFormat.MMMd(localeTag).format(rule.nextDue);
    return PressScale(
      onTap: onTap,
      pressedScale: 0.99,
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          PickerRowIconTile(icon: rule.category.icon, color: rule.category.color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${recurrenceFrequencyLabel(l10n, rule.frequency)}  ·  ${l10n.recurringDue(dueLabel)}',
                  style: AppFont.labelMedium.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${rule.sign} ${_khr(rule.amountKhr)}',
            style: AppFont.bodyLarge.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Result of the add/edit sheet: a rule to save/add, or a delete request.
class _SheetResult {
  const _SheetResult.save(this.rule) : delete = false;
  const _SheetResult.remove()
      : rule = null,
        delete = true;

  final RecurringRule? rule;
  final bool delete;
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.plus, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppFont.labelLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.calendarClock,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.recurringEmptyTitle,
            textAlign: TextAlign.center,
            style: AppFont.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.recurringEmptyBody,
            textAlign: TextAlign.center,
            style: AppFont.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet to add a recurring entry: type, amount, title, category,
/// wallet, frequency and start date.
class _AddRecurringSheet extends StatefulWidget {
  const _AddRecurringSheet({this.initial});

  /// When non-null the sheet edits this rule (prefilled, with a delete action).
  final RecurringRule? initial;

  @override
  State<_AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends State<_AddRecurringSheet> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _title = TextEditingController();

  ETransactionType _type = ETransactionType.expense;
  ERecurrenceFrequency _frequency = ERecurrenceFrequency.monthly;
  DateTime _startDate = DateTime.now();
  TxCategory? _expenseCategory;
  TxCategory? _incomeCategory;
  Wallet _wallet = WalletsData.sample.wallets.first;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    if (r != null) {
      _type = r.type;
      _frequency = r.frequency;
      _startDate = r.nextDue;
      _amount.text = NumberFormat.decimalPattern('en_US').format(r.amountKhr);
      _title.text = r.title;
      if (r.isIncome) {
        _incomeCategory = r.category;
      } else {
        _expenseCategory = r.category;
      }
      _wallet = WalletsData.sample.wallets.firstWhere(
        (w) => w.name == r.walletName,
        orElse: () => _wallet,
      );
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    super.dispose();
  }

  TxCategory get _category => _type == ETransactionType.income
      ? _incomeCategory ?? incomeCategories.first
      : _expenseCategory ?? expenseCategories.first;

  bool get _canSave =>
      (int.tryParse(_amount.text.replaceAll(',', '')) ?? 0) > 0;

  Future<void> _pickCategory() async {
    final picked = await showCategoryPicker(
      context,
      categories: _type == ETransactionType.income
          ? incomeCategories
          : expenseCategories,
      selected: _category,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (_type == ETransactionType.income) {
        _incomeCategory = picked;
      } else {
        _expenseCategory = picked;
      }
    });
  }

  Future<void> _pickWallet() async {
    final picked = await showWalletPicker(
      context,
      wallets: WalletsData.sample.wallets,
      selected: _wallet,
    );
    if (picked == null || !mounted) return;
    setState(() => _wallet = picked);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;
    setState(() => _startDate = date);
  }

  void _save() {
    final l10n = context.l10n;
    final amountKhr = int.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
    final typed = _title.text.trim();
    final title = typed.isNotEmpty ? typed : _category.labelOf(l10n);
    Navigator.of(context).pop(
      _SheetResult.save(
        RecurringRule(
          id: widget.initial?.id ?? UuidGenerator.generate(),
          title: title,
          category: _category,
          walletName: _wallet.name,
          amountKhr: amountKhr,
          type: _type,
          frequency: _frequency,
          nextDue: _startDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(_startDate);
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
              Center(child: _grabber()),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  _isEditing ? l10n.recurringEditTitle : l10n.recurringAdd,
                  style: AppFont.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TxTypeToggle(
                value: _type,
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: AppSpacing.xl),
              _label(l10n.addTxAmount),
              const SizedBox(height: AppSpacing.sm),
              _amountField(),
              const SizedBox(height: AppSpacing.xl),
              _label(l10n.addTxTitleLabel),
              const SizedBox(height: AppSpacing.sm),
              _plainField(_title, l10n.addTxTitleHint),
              const SizedBox(height: AppSpacing.xl),
              _label(l10n.addTxCategory),
              const SizedBox(height: AppSpacing.sm),
              PickerRow(
                leading: PickerRowIconTile(
                  icon: _category.icon,
                  color: _category.color,
                ),
                label: _category.labelOf(l10n),
                onTap: _pickCategory,
              ),
              const SizedBox(height: AppSpacing.xl),
              _label(l10n.addTxWallet),
              const SizedBox(height: AppSpacing.sm),
              PickerRow(
                leading: WalletBrandTile(wallet: _wallet),
                label: _wallet.name,
                onTap: _pickWallet,
              ),
              const SizedBox(height: AppSpacing.xl),
              _label(l10n.recurringFrequency),
              const SizedBox(height: AppSpacing.sm),
              _FrequencyToggle(
                value: _frequency,
                onChanged: (f) => setState(() => _frequency = f),
              ),
              const SizedBox(height: AppSpacing.xl),
              _label(l10n.recurringStarts),
              const SizedBox(height: AppSpacing.sm),
              PickerRow(
                leading: const PickerRowIconTile(
                  icon: LucideIcons.calendar,
                  color: AppColors.primary,
                ),
                label: dateLabel,
                onTap: _pickDate,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ListenableBuilder(
                listenable: _amount,
                builder: (context, _) => PrimaryButton(
                  label: l10n.commonSave,
                  onPressed: _canSave ? _save : null,
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(const _SheetResult.remove()),
                  child: Text(
                    l10n.recurringDelete,
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

  Widget _amountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [GroupedAmountFormatter(decimal: false)],
              onChanged: (_) => setState(() {}),
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '0',
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: TextField(
        controller: controller,
        style: AppFont.bodyLarge.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Widget _grabber() => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

/// Weekly / Monthly selector, styled like [TxTypeToggle].
class _FrequencyToggle extends StatelessWidget {
  const _FrequencyToggle({required this.value, required this.onChanged});

  final ERecurrenceFrequency value;
  final ValueChanged<ERecurrenceFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (ERecurrenceFrequency.weekly, l10n.recurringWeekly),
      (ERecurrenceFrequency.monthly, l10n.recurringMonthly),
    ];
    return Row(
      children: [
        for (final (i, (freq, label)) in items.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: PressScale(
              onTap: () => onChanged(freq),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: freq == value
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: freq == value
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    width: freq == value ? 1.4 : 1,
                  ),
                ),
                child: Text(
                  label,
                  style: AppFont.labelLarge.copyWith(
                    color: freq == value
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
    );
  }
}
