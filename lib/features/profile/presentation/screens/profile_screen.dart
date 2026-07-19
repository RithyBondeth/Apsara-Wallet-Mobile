import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/data/profile_mock_data.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/profile_stats_card.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_section.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_tile.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';

/// The account hub: emerald hero with avatar & membership, a stats strip, and
/// grouped account / preference / support menus — all mock data for the
/// Phase 1 UI build.
@RoutePage()
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  /// One-shot entrance cascade.
  late final AnimationController _intro;

  final ProfileData _data = ProfileData.sample;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _openSettings() => context.router.push(const SettingsRoute());

  void _confirmSignOut() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SignOutSheet(
        onConfirm: () {
          Navigator.of(context).pop();
          context.router.replaceAll([const WelcomeRoute()]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottomSafe + AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header with floating stats strip ---------------------
              Stack(
                clipBehavior: Clip.none,
                children: [
                  FadeSlideIn(
                    controller: _intro,
                    start: 0.0,
                    end: 0.5,
                    offset: const Offset(0, 14),
                    child: ProfileHeader(
                      data: _data,
                      onBack: () => context.router.maybePop(),
                      onSettings: _openSettings,
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.xxl,
                    right: AppSpacing.xxl,
                    bottom: -40,
                    child: FadeSlideIn(
                      controller: _intro,
                      start: 0.18,
                      end: 0.62,
                      offset: const Offset(0, 24),
                      scaleFrom: 0.94,
                      child: ProfileStatsCard(data: _data),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40 + AppSpacing.xl),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.30,
                      end: 0.78,
                      child: SettingsSection(
                        title: context.l10n.profileSectionAccount,
                        children: [
                          SettingsTile(
                            icon: LucideIcons.user,
                            title: context.l10n.profilePersonalInfo,
                            subtitle: context.l10n.profilePersonalInfoSubtitle,
                            onTap: () {},
                          ),
                          SettingsTile(
                            icon: LucideIcons.wallet,
                            title: context.l10n.profileMyWallets,
                            subtitle: context.l10n.profileLinkedAccounts(
                              _data.walletCount,
                            ),
                            iconColor: AppColors.info,
                            onTap: () {},
                          ),
                          SettingsTile(
                            icon: LucideIcons.shieldCheck,
                            title: context.l10n.profileSecurityPrivacy,
                            subtitle: context.l10n.profileSecuritySubtitle,
                            iconColor: AppColors.income,
                            onTap: () {},
                          ),
                          SettingsTile(
                            icon: LucideIcons.bell,
                            title: context.l10n.profileNotifications,
                            iconColor: AppColors.warning,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.40,
                      end: 0.86,
                      child: SettingsSection(
                        title: context.l10n.profileSectionPreferences,
                        children: [
                          SettingsTile(
                            icon: LucideIcons.settings,
                            title: context.l10n.profileSettings,
                            subtitle: context.l10n.profileSettingsSubtitle,
                            onTap: _openSettings,
                          ),
                          SettingsTile(
                            icon: LucideIcons.shapes,
                            title: context.l10n.profileCategories,
                            subtitle: context.l10n.profileCategoriesSubtitle,
                            onTap: () => context.router.push(
                              const CategoriesRoute(),
                            ),
                          ),
                          SettingsTile(
                            icon: LucideIcons.gift,
                            title: context.l10n.profileRewardsOffers,
                            iconColor: AppColors.accent,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.50,
                      end: 0.94,
                      child: SettingsSection(
                        title: context.l10n.profileSectionSupport,
                        children: [
                          SettingsTile(
                            icon: LucideIcons.circleHelp,
                            title: context.l10n.profileHelpSupport,
                            onTap: () {},
                          ),
                          SettingsTile(
                            icon: LucideIcons.info,
                            title: context.l10n.profileAboutApp,
                            iconColor: AppColors.info,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.58,
                      end: 1.0,
                      child: SettingsSection(
                        children: [
                          SettingsTile(
                            icon: LucideIcons.logOut,
                            title: context.l10n.profileSignOut,
                            destructive: true,
                            showChevron: false,
                            onTap: _confirmSignOut,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Text(
                        'Apsara Wallet · v1.0.0',
                        style: AppFont.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirmation sheet shown before signing out.
class _SignOutSheet extends StatelessWidget {
  const _SignOutSheet({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        bottomSafe + AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.expense.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.logOut,
              color: AppColors.expense,
              size: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.profileSignOutConfirmTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.profileSignOutConfirmBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(
                      color: AppColors.textMuted.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: Text(context.l10n.commonCancel),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.expense,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(context.l10n.profileSignOut),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
