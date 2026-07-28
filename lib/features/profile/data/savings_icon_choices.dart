import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Named icon tokens persisted with a savings goal (`icon` column). Named (not
/// index-based) so reordering this map never remaps existing goals. Unknown /
/// null tokens fall back to [LucideIcons.target].
const Map<String, IconData> savingsIconChoices = {
  'target': LucideIcons.target,
  'piggyBank': LucideIcons.piggyBank,
  'bike': LucideIcons.bike,
  'shield': LucideIcons.shieldCheck,
  'palmtree': LucideIcons.palmtree,
  'laptop': LucideIcons.laptop,
  'home': LucideIcons.house,
  'plane': LucideIcons.plane,
  'car': LucideIcons.car,
  'graduation': LucideIcons.graduationCap,
  'gift': LucideIcons.gift,
  'heart': LucideIcons.heart,
};

/// Token → icon, defaulting to a generic target.
IconData savingsIconFromToken(String? token) =>
    savingsIconChoices[token] ?? LucideIcons.target;

/// Icon → token, defaulting to `'target'` for anything not in the catalog.
String savingsIconToken(IconData icon) {
  for (final entry in savingsIconChoices.entries) {
    if (entry.value == icon) return entry.key;
  }
  return 'target';
}
