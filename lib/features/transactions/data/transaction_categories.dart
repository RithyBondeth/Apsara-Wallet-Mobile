import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// A pickable transaction category (Phase 1: static catalog, no backend).
///
/// Labels are l10n keys resolved at render time via [labelOf], so the picker
/// follows the app language without this catalog holding BuildContexts.
class TxCategory {
  const TxCategory({
    required this.id,
    required this.icon,
    required this.color,
    required this.labelOf,
  });

  final String id;
  final IconData icon;
  final Color color;
  final String Function(AppLocalizations l10n) labelOf;
}

/// Expense categories, mirroring the design board's Category screen.
final List<TxCategory> expenseCategories = [
  TxCategory(
    id: 'food',
    icon: LucideIcons.utensils,
    color: AppColors.expense,
    labelOf: (l) => l.categoryFoodDining,
  ),
  TxCategory(
    id: 'transport',
    icon: LucideIcons.car,
    color: AppColors.info,
    labelOf: (l) => l.categoryTransport,
  ),
  TxCategory(
    id: 'shopping',
    icon: LucideIcons.shoppingBag,
    color: AppGradients.goldCore,
    labelOf: (l) => l.categoryShopping,
  ),
  TxCategory(
    id: 'bills',
    icon: LucideIcons.receipt,
    color: AppColors.warning,
    labelOf: (l) => l.categoryBills,
  ),
  TxCategory(
    id: 'health',
    icon: LucideIcons.heartPulse,
    color: Color(0xFFE0507A),
    labelOf: (l) => l.categoryHealth,
  ),
  TxCategory(
    id: 'education',
    icon: LucideIcons.graduationCap,
    color: Color(0xFF7C5CD6),
    labelOf: (l) => l.categoryEducation,
  ),
  TxCategory(
    id: 'entertainment',
    icon: LucideIcons.clapperboard,
    color: Color(0xFF0EA5B7),
    labelOf: (l) => l.categoryEntertainment,
  ),
  TxCategory(
    id: 'travel',
    icon: LucideIcons.plane,
    color: AppColors.primary,
    labelOf: (l) => l.categoryTravel,
  ),
  TxCategory(
    id: 'personalCare',
    icon: LucideIcons.sparkles,
    color: Color(0xFFB0679B),
    labelOf: (l) => l.categoryPersonalCare,
  ),
  TxCategory(
    id: 'gifts',
    icon: LucideIcons.gift,
    color: Color(0xFFCD6A2E),
    labelOf: (l) => l.categoryGifts,
  ),
  TxCategory(
    id: 'othersExpense',
    icon: LucideIcons.ellipsis,
    color: AppColors.textMuted,
    labelOf: (l) => l.categoryOthers,
  ),
];

/// Income categories.
final List<TxCategory> incomeCategories = [
  TxCategory(
    id: 'salary',
    icon: LucideIcons.banknote,
    color: AppColors.income,
    labelOf: (l) => l.categorySalary,
  ),
  TxCategory(
    id: 'business',
    icon: LucideIcons.briefcaseBusiness,
    color: AppColors.info,
    labelOf: (l) => l.categoryBusiness,
  ),
  TxCategory(
    id: 'investment',
    icon: LucideIcons.trendingUp,
    color: AppGradients.goldCore,
    labelOf: (l) => l.categoryInvestment,
  ),
  TxCategory(
    id: 'giftsIncome',
    icon: LucideIcons.gift,
    color: Color(0xFFCD6A2E),
    labelOf: (l) => l.categoryGifts,
  ),
  TxCategory(
    id: 'othersIncome',
    icon: LucideIcons.ellipsis,
    color: AppColors.textMuted,
    labelOf: (l) => l.categoryOthers,
  ),
];
