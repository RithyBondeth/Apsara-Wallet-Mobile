import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';

/// A preset avatar the user can pick, Netflix-style — a gradient disc with a
/// friendly glyph. Phase 1 has no photo upload, so the account is represented
/// by one of these curated marks instead.
class ProfileAvatar {
  const ProfileAvatar({
    required this.id,
    required this.colors,
    required this.icon,
  });

  final String id;

  /// Top-left → bottom-right gradient stops for the disc.
  final List<Color> colors;
  final IconData icon;
}

/// The curated set shown in the picker. First entry is the default.
const List<ProfileAvatar> presetAvatars = [
  ProfileAvatar(
    id: 'emerald',
    colors: [AppGradients.emeraldGlow, AppGradients.emeraldDeep],
    icon: LucideIcons.smile,
  ),
  ProfileAvatar(
    id: 'gold',
    colors: [AppGradients.goldLight, AppGradients.goldDeep],
    icon: LucideIcons.crown,
  ),
  ProfileAvatar(
    id: 'teal',
    colors: [Color(0xFF7BDCD4), Color(0xFF27A79A)],
    icon: LucideIcons.cat,
  ),
  ProfileAvatar(
    id: 'indigo',
    colors: [Color(0xFF8B87E0), Color(0xFF5B54C4)],
    icon: LucideIcons.rocket,
  ),
  ProfileAvatar(
    id: 'rose',
    colors: [Color(0xFFF3A0BC), Color(0xFFE0507A)],
    icon: LucideIcons.heart,
  ),
  ProfileAvatar(
    id: 'amber',
    colors: [Color(0xFFF6C77A), Color(0xFFE08A2E)],
    icon: LucideIcons.sun,
  ),
  ProfileAvatar(
    id: 'sky',
    colors: [Color(0xFF8ECBF0), Color(0xFF3B82C4)],
    icon: LucideIcons.bird,
  ),
  ProfileAvatar(
    id: 'sprout',
    colors: [Color(0xFF86D98F), Color(0xFF2E9E52)],
    icon: LucideIcons.sprout,
  ),
];

/// Renders a [ProfileAvatar] as a gradient disc with a centred white glyph.
///
/// Reused by the Edit Profile hero (large) and the picker tiles (small).
class ProfileAvatarView extends StatelessWidget {
  const ProfileAvatarView({
    super.key,
    required this.avatar,
    this.size = 64,
  });

  final ProfileAvatar avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: avatar.colors,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(avatar.icon, size: size * 0.44, color: Colors.white),
    );
  }
}
