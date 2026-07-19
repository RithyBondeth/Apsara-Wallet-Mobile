import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/analytics/data/analytics_mock_data.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/widgets/analytics_segmented_tabs.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/widgets/category_breakdown_list.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/widgets/daily_trend_card.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/widgets/expense_breakdown_card.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/widgets/period_selector_row.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/widgets/trend_summary_row.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_bottom_bar.dart';

/// Analytics — expense breakdown, category ranking and spend trends across
/// three tabs. Phase 1 UI with mock data and hand-painted charts.
@RoutePage()
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with TickerProviderStateMixin {
  /// Drives chart reveals + the entrance cascade; replayed on tab change so
  /// each tab's charts animate in.
  late final AnimationController _intro;
  late final Animation<double> _chart;

  final AnalyticsData _data = AnalyticsData.sample;
  int _tabIndex = 0;

  /// Filter state (UI-only: changing it relabels the row; the mock series
  /// stay the same). Anchored to the mock data's month, not "now", so
  /// goldens don't drift with the test date.
  _RangeFilter _range = _RangeFilter.month;
  DateTime _period = DateTime(2024, 5);

  String _rangeLabel(BuildContext context) => switch (_range) {
        _RangeFilter.week => context.l10n.analyticsRangeWeek,
        _RangeFilter.month => context.l10n.analyticsRangeMonth,
        _RangeFilter.year => context.l10n.analyticsRangeYear,
      };

  String _periodLabel(BuildContext context) => DateFormat.yMMMM(
        Localizations.localeOf(context).toString(),
      ).format(_period);

  /// Localized calendar picker — backs both the app-bar calendar button and
  /// the "May 2024 ›" period stepper.
  Future<void> _pickPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _period,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null || !mounted) return;
    setState(() => _period = picked);
  }

  Future<void> _pickRange() async {
    final picked = await showModalBottomSheet<_RangeFilter>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _RangeSheet(selected: _range),
    );
    if (picked == null || !mounted) return;
    setState(() => _range = picked);
  }

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _chart = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.25, 1.0, curve: AppCurves.decelerate),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _onTab(int index) {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
    _intro
      ..reset()
      ..forward();
  }

  void _onNavSelect(int index) {
    if (index == 1) return; // already on Analytics
    switch (index) {
      case 0:
        // Home is the stack root — pop back to it rather than stacking.
        context.router.maybePop();
      case 2:
        // Sibling tab: swap in place so the stack stays [Dashboard, tab].
        context.router.replace(const WalletsRoute());
      case 3:
        context.router.push(const ProfileRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final tabs = [
      context.l10n.analyticsTabOverview,
      context.l10n.analyticsTabCategories,
      context.l10n.analyticsTabTrends,
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        // Body flows under the floating nav capsule so its blur has content.
        extendBody: true,
        floatingActionButton: AppBottomBarCenterButton(
          onTap: () => context.router.push(const ScanReceiptRoute()),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AppBottomBar(currentIndex: 1, onSelect: _onNavSelect),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _AppBar(onTapCalendar: _pickPeriod),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.sm,
                    AppSpacing.xxl,
                    bottomSafe + AppBottomBar.clearance + AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.0,
                        end: 0.5,
                        offset: const Offset(0, 10),
                        child: AnalyticsSegmentedTabs(
                          labels: tabs,
                          currentIndex: _tabIndex,
                          onChanged: _onTab,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeSlideIn(
                        controller: _intro,
                        start: 0.1,
                        end: 0.6,
                        child: PeriodSelectorRow(
                          rangeLabel: _rangeLabel(context),
                          periodLabel: _periodLabel(context),
                          onTapRange: _pickRange,
                          onTapPeriod: _pickPeriod,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Rebuilds the active tab each animation tick so the
                      // hand-painted charts receive the live reveal value.
                      AnimatedBuilder(
                        animation: _chart,
                        builder: (context, _) => _buildTab(context),
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

  Widget _buildTab(BuildContext context) {
    switch (_tabIndex) {
      case 1:
        return _cascade([
          CategoryBreakdownList(data: _data, progress: _chart.value),
        ]);
      case 2:
        return _cascade([
          DailyTrendCard(
            data: _data,
            progress: _chart.value,
            title: context.l10n.analyticsMonthlyTrend,
          ),
          TrendSummaryRow(data: _data),
        ]);
      case 0:
      default:
        return _cascade([
          ExpenseBreakdownCard(data: _data, progress: _chart.value),
          DailyTrendCard(data: _data, progress: _chart.value),
        ]);
    }
  }

  /// Stacks each block with a staggered [FadeSlideIn]. Called from inside an
  /// [AnimatedBuilder] on [_chart], so the chart children rebuild with a live
  /// reveal value every tick.
  Widget _cascade(List<Widget> blocks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xl),
          FadeSlideIn(
            controller: _intro,
            start: (0.2 + i * 0.15).clamp(0.0, 0.8),
            end: (0.7 + i * 0.15).clamp(0.0, 1.0),
            child: blocks[i],
          ),
        ],
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.onTapCalendar});

  final VoidCallback onTapCalendar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // AI Insights entry — balances the trailing calendar button.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.router.push(const AiInsightsRoute()),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: const Icon(
                LucideIcons.sparkles,
                size: 21,
                color: Color(0xFF6C63D2),
              ),
            ),
          ),
          Expanded(
            child: Text(
              context.l10n.analyticsTitle,
              textAlign: TextAlign.center,
              style: AppFont.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapCalendar,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                LucideIcons.calendar,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The relative window shown by the filter row's left dropdown.
enum _RangeFilter { week, month, year }

/// Bottom sheet listing the three range options with a check on the current.
class _RangeSheet extends StatelessWidget {
  const _RangeSheet({required this.selected});

  final _RangeFilter selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      (_RangeFilter.week, l10n.analyticsRangeWeek),
      (_RangeFilter.month, l10n.analyticsRangeMonth),
      (_RangeFilter.year, l10n.analyticsRangeYear),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.xxl,
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
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                l10n.analyticsSelectRange,
                style: AppFont.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final (value, label) in options)
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.of(context).pop(value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppFont.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: value == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (value == selected)
                        const Icon(
                          LucideIcons.check,
                          size: 18,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
