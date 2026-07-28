import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/categories/data/category_choices.dart';
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
    this.id,
    this.isSystem = false,
  });

  EditableCategory.fromBase(TxCategory this.base)
      : customName = null,
        icon = base.icon,
        color = base.color,
        id = null,
        isSystem = true;

  final TxCategory? base;
  final String? customName;
  final IconData icon;
  final Color color;

  /// Backend UUID for a user category (null for system categories and for a
  /// brand-new category being created).
  final String? id;

  /// System categories are shared + read-only (can't be edited/deleted).
  final bool isSystem;

  String labelOf(AppLocalizations l10n) =>
      customName ?? base?.labelOf(l10n) ?? '';
}

/// Result of the editor: a category to save/add, or a request to delete it.
class CategoryEditorResult {
  const CategoryEditorResult.save(this.category) : delete = false;
  const CategoryEditorResult.delete()
      : category = null,
        delete = true;

  final EditableCategory? category;
  final bool delete;
}

/// Opens the editor; resolves to the edit result, or null on dismiss.
Future<CategoryEditorResult?> showCategoryEditorSheet(
  BuildContext context, {
  EditableCategory? category,
}) {
  return showModalBottomSheet<CategoryEditorResult>(
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
      CategoryEditorResult.save(
        EditableCategory(
          base: widget.category?.base,
          customName: _name.text.trim(),
          icon: _icon,
          color: _color,
          id: widget.category?.id,
          isSystem: widget.category?.isSystem ?? false,
        ),
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
            if (!isNew) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pop(const CategoryEditorResult.delete()),
                child: Text(
                  l10n.categoriesDelete,
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
