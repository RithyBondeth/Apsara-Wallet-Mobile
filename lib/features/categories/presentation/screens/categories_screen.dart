import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/core/utils/uuid_generator.dart';
import 'package:apsara_wallet_mobile/features/categories/data/category_api.dart';
import 'package:apsara_wallet_mobile/features/categories/data/category_choices.dart';
import 'package:apsara_wallet_mobile/features/categories/presentation/widgets/category_editor_sheet.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Category management (Phase 1, UI-only): search, an Expense/Income sliding
/// toggle and the icon grid from the design board. Tapping a category opens
/// an editor sheet (name, icon, color); "+" adds a new one. Edits live in
/// this screen's state only — no persistence yet.
@RoutePage()
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  final TextEditingController _search = TextEditingController();

  bool _showIncome = false;

  /// The current tab's categories: the static system catalog (read-only) plus
  /// the user's own categories (from the API), which are editable/deletable.
  List<EditableCategory> get _current {
    final system = [
      for (final c in (_showIncome ? incomeCategories : expenseCategories))
        EditableCategory.fromBase(c),
    ];
    final api = ref.watch(categoriesListProvider).valueOrNull ?? const [];
    final user = [
      for (final c in api.where((c) => !c.isSystem && c.isExpense != _showIncome))
        EditableCategory(
          customName: c.name,
          icon: iconFromToken(c.icon),
          color: parseHexColor(c.color) ?? categoryColorChoices.first,
          id: c.id,
        ),
    ];
    return [...system, ...user];
  }

  @override
  void dispose() {
    _intro.dispose();
    _search.dispose();
    super.dispose();
  }

  List<EditableCategory> _filtered(AppLocalizations l10n) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _current;
    return [
      for (final c in _current)
        if (c.labelOf(l10n).toLowerCase().contains(q)) c,
    ];
  }

  /// A unique-enough backend slug for a new user category.
  String _slugFor(String name) {
    final base = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'(^-+|-+$)'), '');
    final suffix = UuidGenerator.generate().replaceAll('-', '').substring(0, 6);
    final slug = '${base.isEmpty ? 'cat' : base}-$suffix';
    return slug.length > 40 ? slug.substring(0, 40) : slug;
  }

  Future<void> _edit(EditableCategory? category) async {
    // System categories are shared + read-only.
    if (category != null && category.isSystem) return;

    final result = await showCategoryEditorSheet(context, category: category);
    if (result == null || !mounted) return;
    final l10n = context.l10n;
    final api = ref.read(categoryApiProvider);
    final type =
        _showIncome ? ETransactionType.income : ETransactionType.expense;

    try {
      if (result.delete && category?.id != null) {
        await api.delete(category!.id!);
        ref.invalidate(categoriesListProvider);
        if (mounted) _snack(l10n.categoriesDeleted);
        return;
      }
      final edited = result.category;
      if (edited == null) return;
      final name = (edited.customName ?? '').trim();
      if (name.isEmpty) return;

      final ok = edited.id != null
          ? await api.update(
              id: edited.id!,
              name: name,
              icon: iconToken(edited.icon),
              color: categoryColorHex(edited.color),
            )
          : await api.create(
              slug: _slugFor(name),
              name: name,
              type: type,
              icon: iconToken(edited.icon),
              color: categoryColorHex(edited.color),
            );
      if (!ok) throw StateError('category-save-failed');
      ref.invalidate(categoriesListProvider);
      if (mounted) _snack(l10n.categoriesSaved);
    } catch (_) {
      if (mounted) _snack(l10n.categoriesSaveFailed);
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
    final l10n = context.l10n;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final items = _filtered(l10n);

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
                child: _AppBar(onAdd: () => _edit(null)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.08,
                      end: 0.45,
                      child: _SearchField(
                        controller: _search,
                        hint: l10n.categoriesSearchHint,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.16,
                      end: 0.55,
                      child: _ExpenseIncomeToggle(
                        showIncome: _showIncome,
                        expenseLabel: l10n.dashboardExpense,
                        incomeLabel: l10n.dashboardIncome,
                        onChanged: (v) => setState(() => _showIncome = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: FadeSlideIn(
                  controller: _intro,
                  start: 0.24,
                  end: 0.75,
                  child: GridView.count(
                    crossAxisCount: 4,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      AppSpacing.sm,
                      AppSpacing.xxl,
                      bottomSafe + AppSpacing.xxxl,
                    ),
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.82,
                    children: [
                      for (final c in items)
                        PressScale(
                          onTap: () => _edit(c),
                          child: Column(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: c.color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(c.icon, size: 23, color: c.color),
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
              context.l10n.categoriesTitle,
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
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.plus,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppFont.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 13,
          ),
          hintText: hint,
          hintStyle: AppFont.bodyMedium.copyWith(color: AppColors.textMuted),
          prefixIcon: const Icon(
            LucideIcons.search,
            size: 18,
            color: AppColors.textMuted,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
        ),
      ),
    );
  }
}

/// Two-segment control with an emerald thumb that slides between sides.
class _ExpenseIncomeToggle extends StatelessWidget {
  const _ExpenseIncomeToggle({
    required this.showIncome,
    required this.expenseLabel,
    required this.incomeLabel,
    required this.onChanged,
  });

  final bool showIncome;
  final String expenseLabel;
  final String incomeLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: AppDurations.medium,
            curve: AppCurves.emphasized,
            alignment:
                showIncome ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _segment(expenseLabel, !showIncome, () => onChanged(false)),
              _segment(incomeLabel, showIncome, () => onChanged(true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppDurations.fast,
            style: AppFont.labelLarge.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
