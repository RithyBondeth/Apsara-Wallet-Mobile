import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/dashboard/data/dashboard_mock_data.dart'
    show formatKhr;
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// The full transaction history reached from the dashboard "See All":
/// searchable, filterable by type, grouped by day, and backed by the live
/// [transactionsProvider] (SQLite). Tapping a row opens its detail.
@RoutePage()
class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState
    extends ConsumerState<TransactionsListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  final TextEditingController _search = TextEditingController();

  /// null = All; otherwise the single type shown.
  ETransactionType? _filter;

  @override
  void dispose() {
    _intro.dispose();
    _search.dispose();
    super.dispose();
  }

  List<TransactionRecord> _filtered(List<TransactionRecord> all) {
    final q = _search.text.trim().toLowerCase();
    return all.where((t) {
      if (_filter != null && t.type != _filter) return false;
      if (q.isEmpty) return true;
      return t.title.toLowerCase().contains(q) ||
          t.category.labelOf(context.l10n).toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = Localizations.localeOf(context).toString();
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final txAsync = ref.watch(transactionsProvider);
    final all = txAsync.valueOrNull ?? const <TransactionRecord>[];
    final loading = txAsync.isLoading && all.isEmpty;
    final items = _filtered(all);
    final now = ref.watch(nowProvider);

    // Build day-grouped rows with staggered entrances.
    final rows = <Widget>[];
    String? lastGroup;
    for (var i = 0; i < items.length; i++) {
      final t = items[i];
      final group = transactionGroupLabel(l10n, localeTag, t.date, now);
      if (group != lastGroup) {
        rows.add(_sectionHeader(group, topPad: lastGroup != null));
        lastGroup = group;
      }
      final step = (0.1 + i * 0.05).clamp(0.0, 0.55);
      rows.add(
        FadeSlideIn(
          controller: _intro,
          start: step,
          end: (step + 0.45).clamp(0.0, 1.0),
          offset: const Offset(0, 12),
          child: _TxTile(
            record: t,
            localeTag: localeTag,
            onTap: () => context.router.push(
              TransactionDetailRoute(id: t.id),
            ),
          ),
        ),
      );
    }

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
                child: _AppBar(title: l10n.txListTitle),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.06,
                      end: 0.45,
                      child: _SearchField(
                        controller: _search,
                        hint: l10n.txSearchHint,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.12,
                      end: 0.52,
                      child: _FilterRow(
                        selected: _filter,
                        onChanged: (f) => setState(() => _filter = f),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? _EmptyState(
                        title: l10n.txEmptyTitle,
                        body: l10n.txEmptyBody,
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.sm,
                          AppSpacing.xxl,
                          bottomSafe + AppSpacing.xxxl,
                        ),
                        children: rows,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String label, {required bool topPad}) {
    return Padding(
      padding: EdgeInsets.only(
        top: topPad ? AppSpacing.xl : AppSpacing.sm,
        bottom: AppSpacing.md,
        left: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppFont.labelMedium.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.title});

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
          const SizedBox(width: 42),
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

/// All / Income / Expense chips.
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onChanged});

  final ETransactionType? selected;
  final ValueChanged<ETransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = <(ETransactionType?, String)>[
      (null, l10n.txFilterAll),
      (ETransactionType.income, l10n.dashboardIncome),
      (ETransactionType.expense, l10n.dashboardExpense),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final (type, label) = options[i];
          final isSelected = type == selected;
          return PressScale(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppCurves.gentle,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                ),
              ),
              child: Text(
                label,
                style: AppFont.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One transaction row: category icon tile, merchant + category·wallet, and
/// the signed amount coloured by type.
class _TxTile extends StatelessWidget {
  const _TxTile({
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PressScale(
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: t.category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(t.category.icon, color: t.category.color, size: 21),
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
              Text(
                '${t.sign} KHR ${formatKhr(t.amountKhr)}',
                style: AppFont.titleSmall.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.receiptText,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppFont.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
