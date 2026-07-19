import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        floatingActionButton: AppBottomBarCenterButton(
          onTap: () => context.router.push(const ScanReceiptRoute()),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AppBottomBar(currentIndex: 1, onSelect: _onNavSelect),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _AppBar(onTapCalendar: () {}),
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
                          rangeLabel: _data.rangeLabel,
                          periodLabel: _data.periodLabel,
                          onTapRange: () {},
                          onTapPeriod: () {},
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
          // Balances the trailing button so the title stays centered.
          const SizedBox(width: 44),
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
              child: const Icon(
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
