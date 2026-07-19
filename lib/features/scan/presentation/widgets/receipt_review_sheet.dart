import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/scan/data/scanned_receipt.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Editable review of an OCR-scanned receipt. OCR is imperfect, so every
/// field — merchant, date, category, each line item and the total — can be
/// corrected before the expense is saved.
class ReceiptReviewSheet extends StatefulWidget {
  const ReceiptReviewSheet({
    super.key,
    required this.receipt,
    required this.onSave,
    required this.onRetake,
  });

  final ScannedReceipt receipt;
  final ValueChanged<ScannedReceipt> onSave;
  final VoidCallback onRetake;

  @override
  State<ReceiptReviewSheet> createState() => _ReceiptReviewSheetState();
}

class _ItemFields {
  _ItemFields({required this.name, required this.amount, this.quantity = 1});
  final TextEditingController name;
  final TextEditingController amount;
  int quantity;
}

class _Category {
  const _Category(this.label, this.icon);
  final String label;
  final IconData icon;
}

const List<_Category> _categories = [
  _Category('Groceries', LucideIcons.shoppingCart),
  _Category('Dining', LucideIcons.utensils),
  _Category('Shopping', LucideIcons.shoppingBag),
  _Category('Transport', LucideIcons.car),
  _Category('Fuel', LucideIcons.fuel),
  _Category('Health', LucideIcons.pill),
  _Category('Bills', LucideIcons.receiptText),
  _Category('Uncategorised', LucideIcons.receipt),
];

class _ReceiptReviewSheetState extends State<ReceiptReviewSheet> {
  late final TextEditingController _merchant;
  late final TextEditingController _date;
  late final TextEditingController _total;
  late final List<_ItemFields> _items;

  late String _categoryLabel;
  late IconData _categoryIcon;
  late ECurrencyType _currency;

  @override
  void initState() {
    super.initState();
    final r = widget.receipt;
    _merchant = TextEditingController(text: r.merchant);
    _date = TextEditingController(text: r.dateLabel);
    _total = TextEditingController(text: r.total == 0 ? '' : _fmt(r.total));
    _items = r.items
        .map(
          (i) => _ItemFields(
            name: TextEditingController(text: i.name),
            amount: TextEditingController(text: _fmt(i.amount)),
            quantity: i.quantity,
          ),
        )
        .toList();
    _categoryLabel = r.categoryLabel;
    _categoryIcon = r.categoryIcon;
    _currency = r.currency;
  }

  @override
  void dispose() {
    _merchant.dispose();
    _date.dispose();
    _total.dispose();
    for (final item in _items) {
      item.name.dispose();
      item.amount.dispose();
    }
    super.dispose();
  }

  String get _symbol => _currency == ECurrencyType.khr ? '៛' : '\$';

  String _fmt(double v) => _currency == ECurrencyType.khr
      ? v.round().toString()
      : v.toStringAsFixed(2);

  double _parse(String s) =>
      double.tryParse(s.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  void _addItem() {
    setState(() {
      _items.add(
        _ItemFields(
          name: TextEditingController(),
          amount: TextEditingController(),
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      final removed = _items.removeAt(index);
      removed.name.dispose();
      removed.amount.dispose();
    });
  }

  void _sumItemsIntoTotal() {
    final sum = _items.fold<double>(0, (t, i) => t + _parse(i.amount.text));
    setState(() => _total.text = _fmt(sum));
  }

  void _save() {
    final r = widget.receipt
      ..merchant = _merchant.text.trim()
      ..dateLabel = _date.text.trim()
      ..categoryLabel = _categoryLabel
      ..categoryIcon = _categoryIcon
      ..currency = _currency
      ..total = _parse(_total.text)
      ..items = [
        for (final item in _items)
          if (item.name.text.trim().isNotEmpty || _parse(item.amount.text) > 0)
            ReceiptLineItem(
              name: item.name.text.trim(),
              amount: _parse(item.amount.text),
              quantity: item.quantity,
            ),
      ];
    FocusScope.of(context).unfocus();
    widget.onSave(r);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomSafe + AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.lg + keyboard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(currency: _currency, onCurrency: _setCurrency),
                  const SizedBox(height: AppSpacing.xl),
                  _fieldLabel('Merchant'),
                  _TextField(
                    controller: _merchant,
                    hint: 'Merchant name',
                    icon: LucideIcons.store,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _fieldLabel('Date'),
                  _TextField(
                    controller: _date,
                    hint: 'e.g. 19 Jul 2026',
                    icon: LucideIcons.calendar,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _fieldLabel('Category'),
                  _CategoryPicker(
                    selected: _categoryLabel,
                    onSelect: (c) => setState(() {
                      _categoryLabel = c.label;
                      _categoryIcon = c.icon;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _ItemsEditor(
                    items: _items,
                    symbol: _symbol,
                    onAdd: _addItem,
                    onRemove: _removeItem,
                    onSumItems: _sumItemsIntoTotal,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _TotalField(controller: _total, symbol: _symbol),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Save Expense',
                  trailingIcon: LucideIcons.check,
                  onPressed: _save,
                ),
                const SizedBox(height: AppSpacing.md),
                PressScale(
                  onTap: widget.onRetake,
                  pressedScale: 0.96,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.rotateCcw,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Retake',
                          style: AppFont.titleSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setCurrency(ECurrencyType currency) {
    if (currency == _currency) return;
    setState(() {
      // Reformat existing values for the new currency's precision.
      final total = _parse(_total.text);
      _currency = currency;
      _total.text = total == 0 ? '' : _fmt(total);
      for (final item in _items) {
        final amt = _parse(item.amount.text);
        item.amount.text = amt == 0 ? '' : _fmt(amt);
      }
    });
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.sm),
    child: Text(
      text,
      style: AppFont.labelMedium.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.currency, required this.onCurrency});

  final ECurrencyType currency;
  final ValueChanged<ECurrencyType> onCurrency;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.income.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.circleCheckBig,
            color: AppColors.income,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review receipt',
                style: AppFont.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Check the details, edit anything, then save',
                style: AppFont.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _CurrencyToggle(currency: currency, onCurrency: onCurrency),
      ],
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({required this.currency, required this.onCurrency});

  final ECurrencyType currency;
  final ValueChanged<ECurrencyType> onCurrency;

  @override
  Widget build(BuildContext context) {
    Widget pill(String label, ECurrencyType value) {
      final selected = value == currency;
      return PressScale(
        onTap: () => onCurrency(value),
        pressedScale: 0.92,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            label,
            style: AppFont.labelMedium.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pill('USD', ECurrencyType.usd),
          pill('KHR', ECurrencyType.khr),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<_Category> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final c = _categories[i];
          final isSelected = c.label == selected;
          return PressScale(
            onTap: () => onSelect(c),
            pressedScale: 0.94,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    c.icon,
                    size: 15,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    c.label,
                    style: AppFont.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ItemsEditor extends StatelessWidget {
  const _ItemsEditor({
    required this.items,
    required this.symbol,
    required this.onAdd,
    required this.onRemove,
    required this.onSumItems,
  });

  final List<_ItemFields> items;
  final String symbol;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onSumItems;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Items',
                style: AppFont.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${items.length}',
                style: AppFont.titleSmall.copyWith(color: AppColors.textMuted),
              ),
              const Spacer(),
              if (items.isNotEmpty)
                PressScale(
                  onTap: onSumItems,
                  pressedScale: 0.92,
                  child: Text(
                    'Sum → Total',
                    style: AppFont.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'No items detected — add them manually if needed.',
                style: AppFont.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: _BareField(
                      controller: items[i].name,
                      hint: 'Item name',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 92,
                    child: _BareField(
                      controller: items[i].amount,
                      hint: '0.00',
                      prefix: symbol,
                      numeric: true,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  PressScale(
                    onTap: () => onRemove(i),
                    pressedScale: 0.85,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        LucideIcons.trash2,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          PressScale(
            onTap: onAdd,
            pressedScale: 0.96,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.plus,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Add item',
                    style: AppFont.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalField extends StatelessWidget {
  const _TotalField({required this.controller, required this.symbol});

  final TextEditingController controller;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Text(
            'Total',
            style: AppFont.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            symbol,
            style: AppFont.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          IntrinsicWidth(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              textAlign: TextAlign.right,
              style: AppFont.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: '0.00',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled, boxed text field matching the light review surface.
class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppFont.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppFont.bodyMedium.copyWith(color: AppColors.textMuted),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.surfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

/// A minimal underline field used inside the items list.
class _BareField extends StatelessWidget {
  const _BareField({
    required this.controller,
    required this.hint,
    this.prefix,
    this.numeric = false,
    this.textAlign = TextAlign.left,
  });

  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final bool numeric;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: textAlign,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: numeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : null,
      style: AppFont.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppFont.bodyMedium.copyWith(color: AppColors.textMuted),
        prefixText: prefix == null ? null : '$prefix ',
        prefixStyle: AppFont.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.surfaceVariant),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
