import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/enums/language_enum.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/providers/locale_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_section.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_tile.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';

/// App preferences: language, currency, appearance, notifications, security and
/// about. Toggles hold local UI state only — Phase 1 is presentation-only —
/// except the language control, which drives the real [localeProvider].
@RoutePage()
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  // --- Local UI state (mock; no persistence in Phase 1) ------------------
  String _currency = 'KHR';
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _transactionAlerts = true;
  bool _budgetWarnings = true;
  bool _promotions = false;
  bool _biometricLogin = true;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _pickLanguage() {
    final current = ref.read(localeProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionSheet<ELanguage>(
        title: context.l10n.settingsLanguageLabel,
        options: [
          for (final language in ELanguage.values)
            _Option(value: language, label: language.nativeName),
        ],
        selected: current,
        onSelected: (language) {
          ref.read(localeProvider.notifier).setLanguage(language);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _pickCurrency() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionSheet<String>(
        title: context.l10n.settingsPrimaryCurrency,
        options: [
          _Option(value: 'KHR', label: context.l10n.settingsCurrencyKhr),
          _Option(value: 'USD', label: context.l10n.settingsCurrencyUsd),
        ],
        selected: _currency,
        onSelected: (value) {
          setState(() => _currency = value);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider);
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
              FadeSlideIn(
                controller: _intro,
                start: 0.0,
                end: 0.5,
                offset: const Offset(0, 12),
                child: _SettingsHeader(
                  onBack: () => context.router.maybePop(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.14,
                      end: 0.6,
                      child: SettingsSection(
                        title: context.l10n.profileSectionPreferences,
                        children: [
                          SettingsTile(
                            icon: LucideIcons.globe,
                            title: context.l10n.settingsLanguageLabel,
                            value: language.nativeName,
                            onTap: _pickLanguage,
                          ),
                          SettingsTile(
                            icon: LucideIcons.banknote,
                            title: context.l10n.settingsPrimaryCurrency,
                            iconColor: AppColors.income,
                            value: _currency,
                            onTap: _pickCurrency,
                          ),
                          SettingsTile(
                            icon: LucideIcons.moon,
                            title: context.l10n.settingsDarkMode,
                            iconColor: AppColors.info,
                            showChevron: false,
                            trailing: _Toggle(
                              value: _darkMode,
                              onChanged: (v) => setState(() => _darkMode = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.26,
                      end: 0.72,
                      child: SettingsSection(
                        title: context.l10n.settingsSectionNotifications,
                        children: [
                          SettingsTile(
                            icon: LucideIcons.bell,
                            title: context.l10n.settingsPushNotifications,
                            iconColor: AppColors.warning,
                            showChevron: false,
                            trailing: _Toggle(
                              value: _pushNotifications,
                              onChanged: (v) =>
                                  setState(() => _pushNotifications = v),
                            ),
                          ),
                          SettingsTile(
                            icon: LucideIcons.arrowRightLeft,
                            title: context.l10n.settingsTransactionAlerts,
                            showChevron: false,
                            trailing: _Toggle(
                              value: _transactionAlerts,
                              onChanged: (v) =>
                                  setState(() => _transactionAlerts = v),
                            ),
                          ),
                          SettingsTile(
                            icon: LucideIcons.chartPie,
                            title: context.l10n.settingsBudgetWarnings,
                            iconColor: AppColors.expense,
                            showChevron: false,
                            trailing: _Toggle(
                              value: _budgetWarnings,
                              onChanged: (v) =>
                                  setState(() => _budgetWarnings = v),
                            ),
                          ),
                          SettingsTile(
                            icon: LucideIcons.tag,
                            title: context.l10n.settingsPromotions,
                            iconColor: AppColors.accent,
                            showChevron: false,
                            trailing: _Toggle(
                              value: _promotions,
                              onChanged: (v) => setState(() => _promotions = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.38,
                      end: 0.84,
                      child: SettingsSection(
                        title: context.l10n.settingsSectionSecurity,
                        children: [
                          SettingsTile(
                            icon: LucideIcons.fingerprint,
                            title: context.l10n.settingsBiometricLogin,
                            subtitle: context.l10n.settingsBiometricSubtitle,
                            iconColor: AppColors.income,
                            showChevron: false,
                            trailing: _Toggle(
                              value: _biometricLogin,
                              onChanged: (v) =>
                                  setState(() => _biometricLogin = v),
                            ),
                          ),
                          SettingsTile(
                            icon: LucideIcons.lockKeyhole,
                            title: context.l10n.settingsChangePin,
                            onTap: () {},
                          ),
                          SettingsTile(
                            icon: LucideIcons.keyRound,
                            title: context.l10n.settingsChangePassword,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.50,
                      end: 0.96,
                      child: SettingsSection(
                        title: context.l10n.settingsSectionAbout,
                        children: [
                          SettingsTile(
                            icon: LucideIcons.fileText,
                            title: context.l10n.settingsTermsOfService,
                            onTap: () {},
                          ),
                          SettingsTile(
                            icon: LucideIcons.shield,
                            title: context.l10n.settingsPrivacyPolicy,
                            iconColor: AppColors.info,
                            onTap: () {},
                          ),
                          SettingsTile(
                            icon: LucideIcons.star,
                            title: context.l10n.settingsRateApp,
                            iconColor: AppColors.accent,
                            onTap: () {},
                          ),
                          SettingsTile(
                            icon: LucideIcons.info,
                            title: context.l10n.settingsAppVersion,
                            value: 'v1.0.0',
                            showChevron: false,
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
      ),
    );
  }
}

/// Compact emerald app bar with a back button and centred title.
class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.emerald,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xxl),
          bottomRight: Radius.circular(AppRadius.xxl),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x330B5B3D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        topInset + AppSpacing.sm,
        AppSpacing.xxl,
        AppSpacing.xl,
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Text(
            context.l10n.settingsTitle,
            style: AppFont.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Balances the back button so the title stays centred.
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

/// Brand-tinted [Switch] used for every settings toggle.
class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primary,
      activeThumbColor: Colors.white,
    );
  }
}

/// A selectable option for [_OptionSheet].
class _Option<T> {
  const _Option({required this.value, required this.label});

  final T value;
  final String label;
}

/// Bottom sheet listing radio-style options (language, currency, …).
class _OptionSheet<T> extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<_Option<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomSafe + AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.sm,
            ),
            child: Text(
              title,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (final option in options)
            InkWell(
              onTap: () => onSelected(option.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: AppFont.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: option.value == selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (option.value == selected)
                      const Icon(
                        LucideIcons.check,
                        size: 20,
                        color: AppColors.primary,
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
