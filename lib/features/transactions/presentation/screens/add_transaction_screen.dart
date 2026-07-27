import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/core/utils/currency_converter.dart';
import 'package:apsara_wallet_mobile/core/utils/uuid_generator.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/add_tx_pickers.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/picker_row.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/tx_type_toggle.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Manual transaction entry: Expense / Income with amount, category, wallet,
/// date & time, note and a hook into the receipt scanner. "Save" writes the
/// record to the database (via [transactionsProvider]) and pops.
///
/// Opened from the dashboard quick actions with a preselected [initialType].
/// [initialDateTime] exists so tests (goldens) can pin the date readout.
///
/// When [initialRecord] is supplied the screen runs in **edit mode**: the form
/// is prefilled from that record and saving reuses its id, so the write
/// replaces the existing row instead of creating a duplicate.
@RoutePage()
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.initialType = ETransactionType.expense,
    this.initialDateTime,
    this.initialRecord,
  });

  final ETransactionType initialType;
  final DateTime? initialDateTime;
  final TransactionRecord? initialRecord;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  final TextEditingController _amount = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _note = TextEditingController();

  late ETransactionType _type = widget.initialType;
  ECurrencyType _currency = ECurrencyType.khr;
  late DateTime _dateTime = widget.initialDateTime ?? DateTime.now();

  TxCategory? _expenseCategory;
  TxCategory? _incomeCategory;

  /// The chosen wallet (null until one is picked or defaulted from the API
  /// list). [_initialWalletName] carries an edit-mode selection until the
  /// wallet list has loaded and it can be resolved.
  Wallet? _wallet;
  String? _initialWalletName;
  bool _saving = false;

  /// The id being edited, or null when creating a new transaction. Reusing it
  /// on save makes the DB write replace the existing row.
  String? _editingId;

  bool get _isEditing => _editingId != null;

  @override
  void initState() {
    super.initState();
    final record = widget.initialRecord;
    if (record != null) _prefillFrom(record);
  }

  /// Populates every field from an existing record for edit mode. Stored
  /// amounts are always in riel, so the amount is shown (and re-saved) as KHR.
  void _prefillFrom(TransactionRecord record) {
    _editingId = record.id;
    _type = record.type;
    _currency = ECurrencyType.khr;
    _dateTime = record.date;
    _amount.text = NumberFormat.decimalPattern('en_US').format(record.amountKhr);
    _title.text = record.title;
    _note.text = record.note ?? '';
    if (record.type == ETransactionType.income) {
      _incomeCategory = record.category;
    } else {
      _expenseCategory = record.category;
    }
    // Resolve against the live wallet list once it's loaded (see build()).
    _initialWalletName = record.walletName;
  }

  /// Picks the wallet to show: the explicit choice, else the edit-mode
  /// original, else the first available. Null when the user has no wallets.
  Wallet? _resolveWallet(List<Wallet> wallets) {
    if (wallets.isEmpty) return null;
    if (_wallet != null) {
      final match = wallets.where((w) => w.name == _wallet!.name);
      if (match.isNotEmpty) return match.first;
    }
    if (_initialWalletName != null) {
      final match = wallets.where((w) => w.name == _initialWalletName);
      if (match.isNotEmpty) return match.first;
    }
    return wallets.first;
  }

  @override
  void dispose() {
    _intro.dispose();
    _amount.dispose();
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  TxCategory get _category => _type == ETransactionType.income
      ? _incomeCategory ?? incomeCategories.first
      : _expenseCategory ?? expenseCategories.first;

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

  Future<void> _pickWallet(List<Wallet> wallets, Wallet? current) async {
    if (wallets.isEmpty) {
      _toast(context.l10n.addTxNoWallet);
      return;
    }
    final picked = await showWalletPicker(
      context,
      wallets: wallets,
      selected: current ?? wallets.first,
    );
    if (picked == null || !mounted) return;
    setState(() => _wallet = picked);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (!mounted) return;
    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _dateTime.hour,
        time?.minute ?? _dateTime.minute,
      );
    });
  }

  Future<void> _pickCurrency() async {
    final picked = await showCurrencyPicker(context, selected: _currency);
    if (picked == null || !mounted || picked == _currency) return;
    setState(() {
      _currency = picked;
      _amount.clear(); // KHR is integer-only, USD allows cents — start fresh.
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    // Resolve the wallet at save time (not from a build-captured value) so a
    // still-loading wallet list at first build can't strand the save.
    final wallet =
        _resolveWallet(ref.read(walletsProvider).valueOrNull ?? const []);
    if (wallet == null) {
      _toast(l10n.addTxNoWallet);
      return;
    }
    // Parse as a decimal (USD can have cents) and convert to the stored riel
    // unit. Previously this used int.tryParse, so any USD/decimal amount fell
    // through to 0 — silent data loss on every dollar entry.
    final entered = double.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
    final amountKhr = CurrencyConverter.toKhr(entered, _currency);
    final note = _note.text.trim();
    final category = _category;
    // Prefer the title field; fall back to the note, then the category name.
    final typed = _title.text.trim();
    final title = typed.isNotEmpty
        ? typed
        : (note.isNotEmpty ? note : category.labelOf(l10n));

    setState(() => _saving = true);
    try {
      // Deleting + re-adding keeps edit working against the API (no PATCH yet).
      if (_editingId != null) {
        await ref.read(transactionsProvider.notifier).remove(_editingId!);
      }
      await ref.read(transactionsProvider.notifier).add(
            TransactionRecord(
              id: _editingId ?? UuidGenerator.generate(),
              title: title,
              category: category,
              walletName: wallet.name,
              date: _dateTime,
              amountKhr: amountKhr,
              type: _type,
              note: note.isEmpty ? null : note,
            ),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast(l10n.addTxSaveFailed);
      return;
    }
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Row(
          children: [
            const Icon(LucideIcons.circleCheck, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              l10n.addTxSaved,
              style: AppFont.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    context.router.maybePop();
  }

  bool get _canSave => _amount.text.trim().isNotEmpty && !_saving;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(_dateTime);
    final timeLabel = TimeOfDay.fromDateTime(_dateTime).format(context);

    final wallets = ref.watch(walletsProvider).valueOrNull ?? const <Wallet>[];
    final wallet = _resolveWallet(wallets);

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
                child: _Header(
                  title: _isEditing ? l10n.addTxEditTitle : l10n.addTxTitle,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.sm,
                    AppSpacing.xxl,
                    bottomSafe + AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.06,
                        end: 0.45,
                        child: TxTypeToggle(
                          value: _type,
                          onChanged: (t) => setState(() => _type = t),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.14,
                        end: 0.55,
                        child: _amountCard(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.18,
                        end: 0.6,
                        child: _section(
                          l10n.addTxTitleLabel,
                          AppTextField(
                            label: '',
                            hint: l10n.addTxTitleHint,
                            controller: _title,
                            prefixIcon: LucideIcons.tag,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.24,
                        end: 0.68,
                        child: _categoryAndWalletRows(l10n, wallets, wallet),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.30,
                        end: 0.75,
                        child: _section(
                          l10n.addTxDateTime,
                          PickerRow(
                            leading: const PickerRowIconTile(
                              icon: LucideIcons.calendar,
                              color: AppColors.primary,
                            ),
                            label: '$dateLabel  ·  $timeLabel',
                            onTap: _pickDateTime,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.38,
                        end: 0.85,
                        child: _section(
                          l10n.addTxNote,
                          AppTextField(
                            label: '',
                            hint: l10n.addTxNoteHint,
                            controller: _note,
                            prefixIcon: LucideIcons.pencilLine,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.44,
                        end: 0.9,
                        child: _section(
                          l10n.addTxReceipt,
                          PickerRow(
                            leading: const PickerRowIconTile(
                              icon: LucideIcons.camera,
                              color: AppColors.textSecondary,
                            ),
                            label: l10n.addTxScanOrUpload,
                            onTap: () => context.router.push(
                              const ScanReceiptRoute(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.5,
                        end: 1.0,
                        offset: const Offset(0, 18),
                        child: ListenableBuilder(
                          listenable: _amount,
                          builder: (context, _) => PrimaryButton(
                            label: l10n.addTxSave,
                            loading: _saving,
                            onPressed: _canSave ? _save : null,
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

  /// Label + big amount input with the tappable currency chip.
  Widget _amountCard() {
    final l10n = context.l10n;
    return _section(
      l10n.addTxAmount,
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
            PressScale(
              onTap: _pickCurrency,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currency == ECurrencyType.khr ? 'KHR' : 'USD',
                      style: AppFont.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.chevronDown,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: _amount,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: _currency == ECurrencyType.usd,
                ),
                inputFormatters: [
                  GroupedAmountFormatter(
                    decimal: _currency == ECurrencyType.usd,
                  ),
                ],
                style: AppFont.headingMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: AppFont.headingMedium.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Category + source wallet (expense/income mode).
  Widget _categoryAndWalletRows(
    AppLocalizations l10n,
    List<Wallet> wallets,
    Wallet? wallet,
  ) {
    final displayWallet = wallet ??
        Wallet(
          name: l10n.addTxNoWalletShort,
          kind: WalletKind.cash,
          balanceKhr: 0,
          balanceUsd: 0,
          brandColor: AppColors.primary,
        );
    return Column(
      key: const ValueKey('category-mode'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(
          l10n.addTxCategory,
          PickerRow(
            leading: PickerRowIconTile(
              icon: _category.icon,
              color: _category.color,
            ),
            label: _category.labelOf(l10n),
            onTap: _pickCategory,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _section(
          l10n.addTxWallet,
          PickerRow(
            leading: WalletBrandTile(wallet: displayWallet),
            label: displayWallet.maskedAccount == null
                ? displayWallet.name
                : '${displayWallet.name} (${displayWallet.accountLast4})',
            onTap: () => _pickWallet(wallets, wallet),
          ),
        ),
      ],
    );
  }

  Widget _section(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFont.labelLarge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

/// X close + centered title, mirroring the mockup's modal header.
class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

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
                LucideIcons.x,
                size: 19,
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
          // Balance the close button so the title is optically centered.
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

/// Groups the integer part with commas as the user types; allows up to two
/// decimals when [decimal] is true (USD), digits only otherwise (KHR).
class GroupedAmountFormatter extends TextInputFormatter {
  GroupedAmountFormatter({required this.decimal});

  final bool decimal;

  static final NumberFormat _group = NumberFormat.decimalPattern('en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) return const TextEditingValue();

    final valid = decimal ? RegExp(r'^\d{0,12}(\.\d{0,2})?$') : RegExp(r'^\d{1,12}$');
    if (!valid.hasMatch(raw)) return oldValue;

    final dot = raw.indexOf('.');
    final intPart = dot < 0 ? raw : raw.substring(0, dot);
    final rest = dot < 0 ? '' : raw.substring(dot);
    final grouped = intPart.isEmpty ? '' : _group.format(int.parse(intPart));
    final text = '$grouped$rest';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
