import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/data/profile_mock_data.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// The app's side navigation drawer — a deep-emerald apsara panel
/// ([AssetPathConstant.sideMenuBackground]) with a user summary, shortcuts to
/// every major area, and sign-out. Opened from the dashboard header's menu
/// button. Each item closes the drawer and pushes its route.
class AppSideMenu extends StatelessWidget {
  const AppSideMenu({super.key});

  static const Color _ivory = Color(0xFFF3F1E7);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = ProfileData.sample;

    void go(PageRouteInfo route) {
      Navigator.of(context).pop(); // close the drawer
      context.router.push(route);
    }

    return Drawer(
      width: 300,
      backgroundColor: AppGradients.emeraldDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Apsara artwork backdrop.
          const Positioned.fill(
            child: Image(
              image: AssetImage(AssetPathConstant.sideMenuBackground),
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppGradients.emeraldDeep.withValues(alpha: 0.78),
                    AppGradients.emeraldDeep.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                _Header(data: data),
                const SizedBox(height: AppSpacing.lg),
                Divider(
                  color: Colors.white.withValues(alpha: 0.12),
                  indent: AppSpacing.xxl,
                  endIndent: AppSpacing.xxl,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    children: [
                      _MenuItem(
                        icon: LucideIcons.house,
                        label: l10n.navHome,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _MenuItem(
                        icon: LucideIcons.chartColumn,
                        label: l10n.navAnalytics,
                        onTap: () => go(const AnalyticsRoute()),
                      ),
                      _MenuItem(
                        icon: LucideIcons.wallet,
                        label: l10n.navWallets,
                        onTap: () => go(const WalletsRoute()),
                      ),
                      _MenuItem(
                        icon: LucideIcons.chartPie,
                        label: l10n.budgetTitle,
                        onTap: () => go(const BudgetRoute()),
                      ),
                      _MenuItem(
                        icon: LucideIcons.target,
                        label: l10n.savingsTitle,
                        onTap: () => go(const SavingsGoalsRoute()),
                      ),
                      _MenuItem(
                        icon: LucideIcons.shapes,
                        label: l10n.categoriesTitle,
                        onTap: () => go(const CategoriesRoute()),
                      ),
                      _MenuItem(
                        icon: LucideIcons.bell,
                        label: l10n.notifTitle,
                        onTap: () => go(const NotificationsRoute()),
                      ),
                      _MenuItem(
                        icon: LucideIcons.settings,
                        label: l10n.settingsTitle,
                        onTap: () => go(const SettingsRoute()),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white.withValues(alpha: 0.12),
                  indent: AppSpacing.xxl,
                  endIndent: AppSpacing.xxl,
                ),
                _MenuItem(
                  icon: LucideIcons.logOut,
                  label: l10n.profileSignOut,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.router.replaceAll([const WelcomeRoute()]);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.data});

  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.goldFoil,
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppGradients.emeraldGlow,
                    AppGradients.emeraldDeep,
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                data.initials,
                style: AppFont.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  data.membership,
                  style: AppFont.labelSmall.copyWith(
                    color: AppSideMenu._ivory.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Icon(icon, size: 20, color: AppGradients.goldLight),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppFont.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
