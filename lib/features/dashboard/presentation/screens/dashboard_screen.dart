import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/providers/now_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:apsara_wallet_mobile/features/auth/data/auth_models.dart';
import 'package:apsara_wallet_mobile/features/budget/data/budget_providers.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_providers.dart';
import 'package:apsara_wallet_mobile/features/dashboard/data/dashboard_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/widgets/add_wallet_sheet.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/widgets/month_overview_card.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/widgets/quick_actions_row.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/widgets/recent_transactions_section.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/feedback/empty_state.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_bottom_bar.dart';
import 'package:apsara_wallet_mobile/shared/widgets/navigation/app_side_menu.dart';

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

  /// Entrance easing for the budget bar (0→1); multiplied by the live fraction
  /// at paint so the bar fills to this month's real spend.
  late final Animation<double> _budget;

  /// Lets the header's menu button open the side drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    _budget = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.35, 0.9, curve: AppCurves.decelerate),
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

  /// First-run: open the add-wallet sheet and create the wallet via the API.
  Future<void> _addWallet() async {
    final wallet = await showAddWalletSheet(context);
    if (wallet == null || !mounted) return;
    try {
      await ref.read(walletsProvider.notifier).add(wallet);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          content: Text(context.l10n.walletAddFailed),
        ),
      );
    }
  }

  /// Greeting name for the header: the signed-in user's first name, falling
  /// back to the email handle, then empty (header shows just the wave).
  String _greetingName(AuthUser? user) {
    final full = user?.fullName?.trim();
    if (full != null && full.isNotEmpty) return full.split(' ').first;
    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    // Everything on screen is derived from the live ledger + wallet totals.
    final total = ref.watch(walletsTotalProvider);
    final ledger =
        ref.watch(transactionsProvider).valueOrNull ?? const [];
    final user = ref.watch(authControllerProvider).user;
    final hasWallet =
        (ref.watch(walletsProvider).valueOrNull ?? const []).isNotEmpty;
    // Post any due recurring entries once per session (fire-and-forget — the
    // result isn't rendered; posted entries flow in through the ledger). Gated
    // on having a wallet so brand-new accounts don't fire it during onboarding.
    if (hasWallet) ref.watch(recurringAutoPostProvider);
    final data = DashboardData.fromLedger(
      ledger: ledger,
      balanceKhr: total.khr,
      balanceUsd: total.usd,
      l10n: context.l10n,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
      now: ref.watch(nowProvider),
      budgetKhr: ref.watch(monthlyBudgetTotalProvider),
      userName: _greetingName(user),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppSideMenu(),
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
                            data: data,
                            ambient: _ambient,
                            balanceHidden: _balanceHidden,
                            onToggleBalance: () => setState(
                              () => _balanceHidden = !_balanceHidden,
                            ),
                            onTapBell: () => context.router.push(
                              const NotificationsRoute(),
                            ),
                            onOpenMenu: () =>
                                _scaffoldKey.currentState?.openDrawer(),
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
                    child: hasWallet
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FadeSlideIn(
                                controller: _intro,
                                start: 0.30,
                                end: 0.78,
                                child: PressScale(
                                  pressedScale: 0.98,
                                  onTap: () => context.router
                                      .push(const BudgetRoute()),
                                  child: AnimatedBuilder(
                                    animation: _budget,
                                    builder: (context, _) => MonthOverviewCard(
                                      data: data,
                                      progress: _budget.value *
                                          data.budgetUsedFraction,
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
                                  transactions: data.transactions,
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
                          )
                        : FadeSlideIn(
                            controller: _intro,
                            start: 0.30,
                            end: 0.82,
                            child: _OnboardingCard(
                              onCreateWallet: _addWallet,
                            ),
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

/// Shown on the dashboard when the account has no wallets yet — a white card
/// carrying the create-first-wallet empty state.
class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.onCreateWallet});

  final VoidCallback onCreateWallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: EmptyState(
        icon: LucideIcons.wallet,
        title: context.l10n.emptyWalletsTitle,
        message: context.l10n.emptyWalletsBody,
        ctaLabel: context.l10n.emptyWalletsCta,
        onCta: onCreateWallet,
      ),
    );
  }
}
