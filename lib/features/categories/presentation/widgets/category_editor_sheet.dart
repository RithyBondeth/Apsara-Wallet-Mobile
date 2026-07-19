import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// A category as edited on the Categories screen: starts from a [TxCategory]
/// (or blank for new ones) and can carry a custom name, icon and color.
/// Session-only — nothing is persisted in Phase 1.
class EditableCategory {
  EditableCategory({
    this.base,
    this.customName,
    required this.icon,
    required this.color,
  });

  EditableCategory.fromBase(TxCategory this.base)
      : customName = null,
        icon = base.icon,
        color = base.color;

  final TxCategory? base;
  final String? customName;
  final IconData icon;
  final Color color;

  String labelOf(AppLocalizations l10n) =>
      customName ?? base?.labelOf(l10n) ?? '';
}

/// Icon choices offered by the editor.
const List<IconData> categoryIconChoices = [
  LucideIcons.utensils,
  LucideIcons.car,
  LucideIcons.shoppingBag,
  LucideIcons.receipt,
  LucideIcons.heartPulse,
  LucideIcons.graduationCap,
  LucideIcons.clapperboard,
  LucideIcons.plane,
  LucideIcons.sparkles,
  LucideIcons.gift,
  LucideIcons.house,
  LucideIcons.banknote,
  LucideIcons.briefcaseBusiness,
  LucideIcons.trendingUp,
  LucideIcons.gamepad2,
  LucideIcons.ellipsis,
];

/// Color choices offered by the editor.
const List<Color> categoryColorChoices = [
  AppColors.expense,
  AppColors.info,
  AppGradients.goldCore,
  AppColors.warning,
  Color(0xFFE0507A),
  Color(0xFF7C5CD6),
  Color(0xFF0EA5B7),
  AppColors.primary,
  Color(0xFFB0679B),
  Color(0xFFCD6A2E),
  AppColors.income,
  AppColors.textMuted,
];

/// Opens the editor; resolves to the edited/new category, or null on dismiss.
Future<EditableCategory?> showCategoryEditorSheet(
  BuildContext context, {
  EditableCategory? category,
}) {
  return showModalBottomSheet<EditableCategory>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
    ),
    builder: (context) => _CategoryEditorSheet(category: category),
  );
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({this.category});

  final EditableCategory? category;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _name = TextEditingController();
  late IconData _icon = widget.category?.icon ?? categoryIconChoices.first;
  late Color _color = widget.category?.color ?? categoryColorChoices.first;

  /// The l10n-resolved name needs a context, so prefill happens once in
  /// [didChangeDependencies] instead of [initState].
  bool _nameFilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_nameFilled) {
      _nameFilled = true;
      final existing = widget.category;
      if (existing != null) _name.text = existing.labelOf(context.l10n);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      EditableCategory(
        base: widget.category?.base,
        customName: _name.text.trim(),
        icon: _icon,
        color: _color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final isNew = widget.category == null;

    return SafeArea(
      child: SingleChildScrollView(
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
                isNew ? l10n.categoriesNewTitle : l10n.categoriesEditTitle,
                style: AppFont.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Live preview of the tile being edited.
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _color, width: 1.6),
                ),
                child: Icon(_icon, size: 26, color: _color),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: l10n.categoriesNameLabel,
              controller: _name,
              prefixIcon: LucideIcons.tag,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.categoriesIconLabel),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final icon in categoryIconChoices)
                  PressScale(
                    onTap: () => setState(() => _icon = icon),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: icon == _icon
                            ? _color.withValues(alpha: 0.14)
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                        border: icon == _icon
                            ? Border.all(color: _color, width: 1.4)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        size: 19,
                        color: icon == _icon
                            ? _color
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _label(l10n.categoriesColorLabel),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in categoryColorChoices)
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
                          ? const Icon(
                              LucideIcons.check,
                              size: 16,
                              color: Colors.white,
                            )
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
                onPressed: _name.text.trim().isEmpty ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: AppFont.labelLarge.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
