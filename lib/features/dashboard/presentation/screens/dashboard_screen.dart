import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/dashboard/data/dashboard_mock_data.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/widgets/month_overview_card.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/widgets/quick_actions_row.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/widgets/recent_transactions_section.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_bottom_bar.dart';

/// The home dashboard: emerald hero balance, quick actions, this-month
/// overview and recent activity — all mock data for the Phase 1 UI build.
@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  /// One-shot entrance cascade.
  late final AnimationController _intro;

  /// Endless ambient loop: aurora-style breathing behind the brand mark.
  late final AnimationController _ambient;

  /// Budget bar fill, eased in on first paint.
  late final Animation<double> _budget;

  final DashboardData _data = DashboardData.sample;

  bool _balanceHidden = false;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();
    _budget = Tween<double>(begin: 0, end: _data.budgetUsedFraction).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.35, 0.9, curve: AppCurves.decelerate),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _onNavSelect(int index) {
    if (index == _navIndex) return;
    if (index == 1) {
      context.router.push(const AnalyticsRoute());
      return;
    }
    if (index == 2) {
      context.router.push(const WalletsRoute());
      return;
    }
    if (index == 3) {
      context.router.push(const ProfileRoute());
      return;
    }
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Body flows under the floating nav capsule so its blur has content.
        extendBody: true,
        floatingActionButton: AppBottomBarCenterButton(
          onTap: () => context.router.push(const ScanReceiptRoute()),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AppBottomBar(
          currentIndex: _navIndex,
          onSelect: _onNavSelect,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Soft misty temple backdrop behind the scrolling content.
            const Image(
              image: AssetImage(AssetPathConstant.dashboardBackground),
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: bottomSafe + AppBottomBar.clearance + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header with floating quick actions -----------------
                  // The action cards straddle the header's lower edge. The
                  // 46px overhang is reserved INSIDE the stack (bottom
                  // padding) so the cards stay hit-testable — Positioned
                  // children outside a Stack's bounds never receive taps.
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 46),
                        child: FadeSlideIn(
                          controller: _intro,
                          start: 0.0,
                          end: 0.5,
                          offset: const Offset(0, 14),
                          child: DashboardHeader(
                            data: _data,
                            ambient: _ambient,
                            balanceHidden: _balanceHidden,
                            onToggleBalance: () => setState(
                              () => _balanceHidden = !_balanceHidden,
                            ),
                            onTapBell: () => context.router.push(
                              const NotificationsRoute(),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppSpacing.xxl,
                        right: AppSpacing.xxl,
                        bottom: 0,
                        child: FadeSlideIn(
                          controller: _intro,
                          start: 0.18,
                          end: 0.62,
                          offset: const Offset(0, 24),
                          scaleFrom: 0.94,
                          child: QuickActionsRow(
                            onAddIncome: () => context.router.push(
                              AddTransactionRoute(
                                initialType: ETransactionType.income,
                              ),
                            ),
                            onAddExpense: () => context.router.push(
                              AddTransactionRoute(
                                initialType: ETransactionType.expense,
                              ),
                            ),
                            onScan: () => context.router.push(
                              const ScanReceiptRoute(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FadeSlideIn(
                          controller: _intro,
                          start: 0.30,
                          end: 0.78,
                          child: PressScale(
                            pressedScale: 0.98,
                            onTap: () =>
                                context.router.push(const BudgetRoute()),
                            child: AnimatedBuilder(
                              animation: _budget,
                              builder: (context, _) => MonthOverviewCard(
                                data: _data,
                                progress: _budget.value,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        FadeSlideIn(
                          controller: _intro,
                          start: 0.42,
                          end: 0.92,
                          child: RecentTransactionsSection(
                            transactions: _data.transactions,
                            onSeeAll: () => context.router.push(
                              const TransactionsListRoute(),
                            ),
                            onTapTransaction: (tx) {
                              if (tx.id != null) {
                                context.router.push(
                                  TransactionDetailRoute(id: tx.id!),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
