import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// A savings goal the user is tracking toward (Phase 1, UI-only). Preset goals
/// resolve their name via l10n ([nameOf]); user-added goals carry a plain
/// [customName]. This is tracking only — the app never moves money.
class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.icon,
    required this.color,
    required this.savedKhr,
    required this.targetKhr,
    this.nameKey,
    this.customName,
  });

  final String id;
  final IconData icon;
  final Color color;
  final int savedKhr;
  final int targetKhr;

  /// Resolver for a preset goal's localized name.
  final String Function(AppLocalizations l10n)? nameKey;

  /// Plain name for a user-added goal.
  final String? customName;

  double get fraction =>
      targetKhr == 0 ? 0 : (savedKhr / targetKhr).clamp(0.0, 1.0);

  String nameOf(AppLocalizations l10n) =>
      customName ?? nameKey?.call(l10n) ?? '';

  SavingsGoal copyWith({int? savedKhr}) => SavingsGoal(
        id: id,
        icon: icon,
        color: color,
        savedKhr: savedKhr ?? this.savedKhr,
        targetKhr: targetKhr,
        nameKey: nameKey,
        customName: customName,
      );
}

/// The Phase-1 sample goals.
List<SavingsGoal> sampleSavingsGoals() => [
      SavingsGoal(
        id: 'motorbike',
        icon: LucideIcons.bike,
        color: AppColors.primary,
        savedKhr: 4500000,
        targetKhr: 6000000,
        nameKey: (l) => l.savingsGoalMotorbike,
      ),
      SavingsGoal(
        id: 'emergency',
        icon: LucideIcons.shieldCheck,
        color: AppColors.info,
        savedKhr: 2500000,
        targetKhr: 5000000,
        nameKey: (l) => l.savingsGoalEmergency,
      ),
      SavingsGoal(
        id: 'vacation',
        icon: LucideIcons.palmtree,
        color: AppGradients.goldCore,
        savedKhr: 1200000,
        targetKhr: 3000000,
        nameKey: (l) => l.savingsGoalVacation,
      ),
      SavingsGoal(
        id: 'laptop',
        icon: LucideIcons.laptop,
        color: Color(0xFF7C5CD6),
        savedKhr: 800000,
        targetKhr: 2000000,
        nameKey: (l) => l.savingsGoalLaptop,
      ),
    ];
