import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';

/// Icon choices offered by the category editor. A user category persists its
/// icon as the INDEX into this list (a stable token), resolved back on display
/// via [iconFromToken] / [iconToken].
const List<IconData> categoryIconChoices = [
  LucideIcons.utensils,
  LucideIcons.car,
  LucideIcons.shoppingBag,
  LucideIcons.receipt,
  LucideIcons.heartPulse,
  LucideIcons.graduationCap,
  LucideIcons.clapperboard,
  LucideIcons.plane,
  LucideIcons.sparkles,
  LucideIcons.gift,
  LucideIcons.house,
  LucideIcons.banknote,
  LucideIcons.briefcaseBusiness,
  LucideIcons.trendingUp,
  LucideIcons.gamepad2,
  LucideIcons.ellipsis,
];

/// Color choices offered by the category editor.
const List<Color> categoryColorChoices = [
  AppColors.expense,
  AppColors.info,
  AppGradients.goldCore,
  AppColors.warning,
  Color(0xFFE0507A),
  Color(0xFF7C5CD6),
  Color(0xFF0EA5B7),
  AppColors.primary,
  Color(0xFFB0679B),
  Color(0xFFCD6A2E),
  AppColors.income,
  AppColors.textMuted,
];

/// A user category's icon token — its index in [categoryIconChoices].
String iconToken(IconData icon) {
  final i = categoryIconChoices.indexOf(icon);
  return (i >= 0 ? i : categoryIconChoices.length - 1).toString();
}

/// Resolves a stored icon token back to an [IconData] (falls back to the last
/// "others" glyph on anything unexpected).
IconData iconFromToken(String? token) {
  final i = int.tryParse(token ?? '');
  if (i != null && i >= 0 && i < categoryIconChoices.length) {
    return categoryIconChoices[i];
  }
  return categoryIconChoices.last;
}

/// `Color` → `'#RRGGBB'` for the backend's hex-color field.
String categoryColorHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// `'#RRGGBB'` → `Color`. Null / malformed → null.
Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  final cleaned = hex.replaceFirst('#', '').trim();
  if (cleaned.length != 6) return null;
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}
