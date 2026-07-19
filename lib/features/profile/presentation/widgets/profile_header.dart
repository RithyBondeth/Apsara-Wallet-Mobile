import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/data/profile_mock_data.dart';

/// The emerald hero at the top of the profile screen: a top bar (back +
/// settings), a gold-ringed avatar, the user's name, email and a membership
/// badge. The stats strip that straddles its lower edge is a separate widget.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.data,
    required this.onBack,
    required this.onSettings,
  });

  final ProfileData data;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  static const Color _ivory = Color(0xFFF3F1E7);

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
      child: Padding(
        // Extra bottom room so the avatar clears the stats card that floats
        // up over the header's lower edge.
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          topInset + AppSpacing.sm,
          AppSpacing.xxl,
          AppSpacing.huge + AppSpacing.xxl,
        ),
        child: Column(
          children: [
            _topBar(context),
            const SizedBox(height: AppSpacing.lg),
            _Avatar(initials: data.initials),
            const SizedBox(height: AppSpacing.md),
            Text(
              data.fullName,
              style: AppFont.headingSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.email,
              style: AppFont.bodyMedium.copyWith(
                color: _ivory.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _membershipBadge(),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(icon: LucideIcons.arrowLeft, onTap: onBack),
        const Spacer(),
        Text(
          context.l10n.profileTitle,
          style: AppFont.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        _CircleIconButton(icon: LucideIcons.settings, onTap: onSettings),
      ],
    );
  }

  Widget _membershipBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.goldFoil,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.crown, size: 14, color: Color(0xFF5A420E)),
          const SizedBox(width: 6),
          Text(
            data.membership,
            style: AppFont.labelMedium.copyWith(
              color: const Color(0xFF5A420E),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gold-ringed circular avatar showing the user's initials.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.goldFoil,
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppGradients.emeraldGlow, AppGradients.emeraldDeep],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: AppFont.headingSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Translucent circular icon button used in the header's top bar.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
