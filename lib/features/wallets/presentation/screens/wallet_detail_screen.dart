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
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/widgets/add_tx_pickers.dart'
    show WalletBrandTile, showWalletPicker;
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart'
    show GroupedAmountFormatter;
import 'package:apsara_wallet_mobile/features/wallets/data/transfer_api.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_api.dart'
    show WalletDeleteOutcome;
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/widgets/add_wallet_sheet.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// A single wallet/account: an emerald balance hero and the transactions
/// recorded against it (live from [transactionsProvider], matched by name).
@RoutePage()
class WalletDetailScreen extends ConsumerStatefulWidget {
  const WalletDetailScreen({super.key, required this.index});

  final int index;

  @override
  ConsumerState<WalletDetailScreen> createState() =>
      _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen>
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

  String _kindLabel(BuildContext context, WalletKind kind) => switch (kind) {
        WalletKind.bank => context.l10n.walletTypeBank,
        WalletKind.cash => context.l10n.walletTypeCash,
        WalletKind.ewallet => context.l10n.walletTypeEwallet,
      };

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.error : AppColors.primary,
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

  /// Bottom-sheet menu with Edit + Delete.
  Future<void> _openActions(Wallet wallet) async {
    final walletCount =
        (ref.read(walletsProvider).valueOrNull ?? const []).length;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (sheetContext) => _ActionsSheet(
        l10n: sheetContext.l10n,
        canSetPrimary: !wallet.isPrimary,
        canTransfer: walletCount >= 2,
      ),
    );
    if (action == 'transfer') {
      await _transfer(wallet);
    } else if (action == 'primary') {
      await _setPrimary(wallet);
    } else if (action == 'edit') {
      await _edit(wallet);
    } else if (action == 'delete') {
      await _delete(wallet);
    }
  }

  Future<void> _transfer(Wallet from) async {
    final fromId = from.id;
    if (fromId == null) return;
    final others = (ref.read(walletsProvider).valueOrNull ?? const [])
        .where((w) => w.id != null && w.id != fromId)
        .toList();
    if (others.isEmpty) return;
    final result = await showModalBottomSheet<_TransferResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (_) => _TransferSheet(from: from, others: others),
    );
    if (result == null || !mounted) return;
    try {
      final ok = await ref.read(transferApiProvider).create(
            fromWalletId: fromId,
            toWalletId: result.toWalletId,
            amountKhr: result.amountKhr,
            date: DateTime.now(),
            note: result.note,
          );
      if (!ok) throw StateError('transfer-failed');
      ref.invalidate(walletsProvider);
      ref.invalidate(walletTransfersProvider(fromId));
      ref.invalidate(walletTransfersProvider(result.toWalletId));
      if (mounted) _snack(context.l10n.transferDone);
    } catch (_) {
      if (mounted) _snack(context.l10n.transferFailed, error: true);
    }
  }

  Future<void> _setPrimary(Wallet wallet) async {
    final id = wallet.id;
    if (id == null) return;
    try {
      await ref.read(walletsProvider.notifier).setPrimary(id);
      if (mounted) _snack(context.l10n.walletSetPrimaryDone);
    } catch (_) {
      if (mounted) _snack(context.l10n.walletUpdateFailed, error: true);
    }
  }

  Future<void> _edit(Wallet wallet) async {
    final updated = await showEditWalletSheet(context, wallet);
    if (updated == null || !mounted) return;
    try {
      await ref.read(walletsProvider.notifier).edit(updated);
      if (mounted) _snack(context.l10n.walletUpdated);
    } catch (_) {
      if (mounted) _snack(context.l10n.walletUpdateFailed, error: true);
    }
  }

  Future<void> _delete(Wallet wallet) async {
    final id = wallet.id;
    if (id == null) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(l10n.walletDeleteConfirmTitle),
        content: Text(l10n.walletDeleteConfirmBody(wallet.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.walletDeleteAction,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final outcome = await ref.read(walletsProvider.notifier).remove(id);
    if (!mounted) return;
    switch (outcome) {
      case WalletDeleteOutcome.ok:
        _snack(context.l10n.walletDeleted);
        context.router.maybePop();
      case WalletDeleteOutcome.hasTransactions:
        _snack(context.l10n.walletDeleteHasTransactions, error: true);
      case WalletDeleteOutcome.failed:
        _snack(context.l10n.walletDeleteFailed, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = Localizations.localeOf(context).toString();
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    final wallets = ref.watch(walletsProvider).valueOrNull ?? const [];
    if (widget.index < 0 || widget.index >= wallets.length) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final wallet = wallets[widget.index];
    final balance = ref.watch(walletBalancesProvider)[wallet.name];

    final txs = (ref.watch(transactionsProvider).valueOrNull ?? [])
        .where((t) => t.walletName == wallet.name)
        .toList();

    // Merge this wallet's transfers into the activity feed, sorted by date.
    final transfers = wallet.id == null
        ? const <ApiTransfer>[]
        : (ref.watch(walletTransfersProvider(wallet.id!)).valueOrNull ??
            const []);
    final nameById = {
      for (final w in wallets)
        if (w.id != null) w.id!: w.name,
    };
    final activity = <({DateTime date, Widget tile})>[
      for (final t in txs)
        (
          date: t.date,
          tile: _ActivityTile(
            record: t,
            localeTag: localeTag,
            onTap: () =>
                context.router.push(TransactionDetailRoute(id: t.id)),
          ),
        ),
      for (final tr in transfers)
        (
          date: tr.date,
          tile: _TransferTile(
            transfer: tr,
            outgoing: tr.fromWalletId == wallet.id,
            counterparty: nameById[tr.fromWalletId == wallet.id
                    ? tr.toWalletId
                    : tr.fromWalletId] ??
                '',
            localeTag: localeTag,
          ),
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
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
                  title: wallet.name,
                  onMenu: () => _openActions(wallet),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.md,
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
                        child: _BalanceHero(
                          wallet: wallet,
                          balanceKhr: balance?.khr ?? wallet.balanceKhr,
                          balanceUsd: balance?.usd ?? wallet.balanceUsd,
                          kindLabel: _kindLabel(context, wallet.kind),
                          balanceLabel: l10n.walletBalanceLabel,
                          primaryLabel: l10n.walletCardPrimaryBadge,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.18,
                        end: 0.6,
                        child: Text(
                          l10n.walletRecentActivity,
                          style: AppFont.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (activity.isEmpty)
                        FadeSlideIn(
                          controller: _intro,
                          start: 0.24,
                          end: 0.7,
                          child: _EmptyActivity(label: l10n.walletNoActivity),
                        )
                      else
                        for (var i = 0; i < activity.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.md),
                          FadeSlideIn(
                            controller: _intro,
                            start: (0.24 + i * 0.06).clamp(0.0, 0.7),
                            end: (0.64 + i * 0.06).clamp(0.0, 1.0),
                            child: activity[i].tile,
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
  const _AppBar({required this.title, this.onMenu});

  final String title;
  final VoidCallback? onMenu;

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onMenu != null)
            PressScale(
              onTap: onMenu,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: const Icon(
                  LucideIcons.ellipsisVertical,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            )
          else
            const SizedBox(width: 42),
        ],
      ),
    );
  }
}

/// Transfer / Set-primary / Edit / Delete action sheet for a wallet.
class _ActionsSheet extends StatelessWidget {
  const _ActionsSheet({
    required this.l10n,
    required this.canSetPrimary,
    required this.canTransfer,
  });

  final AppLocalizations l10n;
  final bool canSetPrimary;
  final bool canTransfer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (canTransfer)
            ListTile(
              leading: const Icon(LucideIcons.arrowLeftRight,
                  color: AppColors.primary),
              title: Text(l10n.transferAction),
              onTap: () => Navigator.of(context).pop('transfer'),
            ),
          if (canSetPrimary)
            ListTile(
              leading: const Icon(LucideIcons.star, color: AppColors.primary),
              title: Text(l10n.walletSetPrimaryAction),
              onTap: () => Navigator.of(context).pop('primary'),
            ),
          ListTile(
            leading: const Icon(LucideIcons.pencil, color: AppColors.textPrimary),
            title: Text(l10n.walletEditAction),
            onTap: () => Navigator.of(context).pop('edit'),
          ),
          ListTile(
            leading: const Icon(LucideIcons.trash2, color: AppColors.error),
            title: Text(
              l10n.walletDeleteAction,
              style: const TextStyle(color: AppColors.error),
            ),
            onTap: () => Navigator.of(context).pop('delete'),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({
    required this.wallet,
    required this.balanceKhr,
    required this.balanceUsd,
    required this.kindLabel,
    required this.balanceLabel,
    required this.primaryLabel,
  });

  final Wallet wallet;
  final int balanceKhr;
  final double balanceUsd;
  final String kindLabel;
  final String balanceLabel;
  final String primaryLabel;

  static const Color _ivory = Color(0xFFF3F1E7);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppGradients.emerald,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
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
              WalletBrandTile(wallet: wallet, size: 46),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: AppFont.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      wallet.maskedAccount ?? kindLabel,
                      style: AppFont.bodySmall.copyWith(
                        color: _ivory.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (wallet.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.goldFoil,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    primaryLabel,
                    style: AppFont.labelSmall.copyWith(
                      color: const Color(0xFF5A420E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            balanceLabel,
            style: AppFont.labelMedium.copyWith(
              color: _ivory.withValues(alpha: 0.8),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
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
                builder: (context, ref, _) => Text(
                  ref.watch(moneyFormatterProvider).number(balanceKhr),
                  style: AppFont.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '≈ USD ${formatUsd(balanceUsd)}',
            style: AppFont.bodyMedium.copyWith(
              color: _ivory.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.record,
    required this.localeTag,
    required this.onTap,
  });

  final TransactionRecord record;
  final String localeTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = record;
    final amountColor =
        t.isIncome ? AppColors.income : AppColors.textPrimary;
    return PressScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(t.category.icon, color: t.category.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.category.labelOf(l10n)} · ${t.timeLabel(localeTag)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Consumer(
              builder: (context, ref, _) => Text(
                '${t.sign} ${ref.watch(moneyFormatterProvider).format(t.amountKhr)}',
                style: AppFont.titleSmall.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.receiptText,
            size: 30,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppFont.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// One transfer as an activity row: a paired-arrows tile, "Transfer to/from"
/// the counterparty, the time, and the signed amount (out spends, in receives).
class _TransferTile extends StatelessWidget {
  const _TransferTile({
    required this.transfer,
    required this.outgoing,
    required this.counterparty,
    required this.localeTag,
  });

  final ApiTransfer transfer;
  final bool outgoing;
  final String counterparty;
  final String localeTag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final amountColor = outgoing ? AppColors.textPrimary : AppColors.income;
    final sign = outgoing ? '-' : '+';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              LucideIcons.arrowLeftRight,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outgoing
                      ? l10n.transferToLabel(counterparty)
                      : l10n.transferFromLabel(counterparty),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.jm(localeTag).format(transfer.date),
                  style: AppFont.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Consumer(
            builder: (context, ref, _) => Text(
              '$sign ${ref.watch(moneyFormatterProvider).format(transfer.amountKhr)}',
              style: AppFont.titleSmall.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The chosen transfer: destination wallet + amount (+ optional note).
class _TransferResult {
  const _TransferResult({
    required this.toWalletId,
    required this.amountKhr,
    this.note,
  });

  final String toWalletId;
  final int amountKhr;
  final String? note;
}

/// Bottom sheet: move money from [from] to one of [others].
class _TransferSheet extends StatefulWidget {
  const _TransferSheet({required this.from, required this.others});

  final Wallet from;
  final List<Wallet> others;

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  late Wallet _to = widget.others.first;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _amountKhr => int.tryParse(_amount.text.replaceAll(',', '')) ?? 0;

  Future<void> _pickTo() async {
    final picked = await showWalletPicker(
      context,
      wallets: widget.others,
      selected: _to,
    );
    if (picked == null || !mounted) return;
    setState(() => _to = picked);
  }

  void _save() {
    Navigator.of(context).pop(
      _TransferResult(
        toWalletId: _to.id!,
        amountKhr: _amountKhr,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      ),
    );
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
                  l10n.transferTitle,
                  style: AppFont.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _label(l10n.transferFrom),
              const SizedBox(height: AppSpacing.sm),
              _walletRow(widget.from, onTap: null),
              const SizedBox(height: AppSpacing.lg),
              _label(l10n.transferTo),
              const SizedBox(height: AppSpacing.sm),
              _walletRow(_to, onTap: _pickTo),
              const SizedBox(height: AppSpacing.xl),
              _label(l10n.addTxAmount),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: l10n.transferAction,
                onPressed: _amountKhr > 0 ? _save : null,
              ),
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

  Widget _walletRow(Wallet w, {VoidCallback? onTap}) {
    final row = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          WalletBrandTile(wallet: w, size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              w.name,
              style: AppFont.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onTap != null)
            const Icon(LucideIcons.chevronDown,
                size: 18, color: AppColors.textMuted),
        ],
      ),
    );
    return onTap == null ? row : PressScale(onTap: onTap, child: row);
  }
}
