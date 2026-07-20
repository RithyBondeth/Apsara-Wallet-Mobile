import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/data/profile_avatars.dart';
import 'package:apsara_wallet_mobile/features/profile/data/profile_mock_data.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Edit the signed-in user's avatar, name, email and phone (Phase 1, UI-only).
///
/// The avatar is chosen Netflix-style from a curated preset set
/// ([presetAvatars]) rather than uploaded; the selection updates the emerald
/// hero live. "Save" validates and pops with a confirmation — nothing is
/// persisted yet.
@RoutePage()
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  static const ProfileData _data = ProfileData.sample;

  late final TextEditingController _name =
      TextEditingController(text: _data.fullName);
  late final TextEditingController _email =
      TextEditingController(text: _data.email);
  late final TextEditingController _phone =
      TextEditingController(text: _data.phone);

  ProfileAvatar _avatar = presetAvatars.first;

  String? _nameError;
  String? _emailError;
  String? _phoneError;

  @override
  void dispose() {
    _intro.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool _validate() {
    final l10n = context.l10n;
    final email = _email.text.trim();
    final phoneDigits = _phone.text.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      _nameError =
          _name.text.trim().isEmpty ? l10n.editProfileNameRequired : null;
      _emailError = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
          ? null
          : l10n.editProfileEmailInvalid;
      _phoneError =
          phoneDigits.length < 8 ? l10n.editProfilePhoneInvalid : null;
    });
    return _nameError == null && _emailError == null && _phoneError == null;
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Row(
          children: [
            const Icon(LucideIcons.circleCheck, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              context.l10n.editProfileSaved,
              style: AppFont.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                child: _Hero(
                  avatar: _avatar,
                  title: l10n.editProfileTitle,
                  onBack: () => context.router.maybePop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.16,
                      end: 0.62,
                      child: _AvatarPicker(
                        label: l10n.editProfileChooseAvatar,
                        selected: _avatar,
                        onSelected: (a) => setState(() => _avatar = a),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.26,
                      end: 0.72,
                      child: AppTextField(
                        label: l10n.editProfileNameLabel,
                        controller: _name,
                        prefixIcon: LucideIcons.user,
                        textInputAction: TextInputAction.next,
                        errorText: _nameError,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.34,
                      end: 0.8,
                      child: AppTextField(
                        label: l10n.editProfileEmailLabel,
                        controller: _email,
                        prefixIcon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        errorText: _emailError,
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.42,
                      end: 0.88,
                      child: AppTextField(
                        label: l10n.editProfilePhoneLabel,
                        controller: _phone,
                        prefixIcon: LucideIcons.phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        errorText: _phoneError,
                        onSubmitted: (_) => _save(),
                        onChanged: (_) {
                          if (_phoneError != null) {
                            setState(() => _phoneError = null);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    FadeSlideIn(
                      controller: _intro,
                      start: 0.52,
                      end: 1.0,
                      offset: const Offset(0, 16),
                      child: PrimaryButton(
                        label: l10n.editProfileSave,
                        trailingIcon: LucideIcons.check,
                        onPressed: _save,
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

/// Emerald gradient hero showing the currently-selected avatar in a gold ring.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.avatar,
    required this.title,
    required this.onBack,
  });

  final ProfileAvatar avatar;
  final String title;
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
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          topInset + AppSpacing.sm,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          children: [
            Row(
              children: [
                _CircleIconButton(icon: LucideIcons.arrowLeft, onTap: onBack),
                const Spacer(),
                Text(
                  title,
                  style: AppFont.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 42), // balance the back button
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            // Gold-ringed selected avatar.
            Container(
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
              child: ProfileAvatarView(avatar: avatar, size: 96),
            ),
          ],
        ),
      ),
    );
  }
}

/// Netflix-style horizontal picker: a labelled row of preset avatar discs;
/// the chosen one gets a gold ring, a scale bump and a check badge.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final ProfileAvatar selected;
  final ValueChanged<ProfileAvatar> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFont.labelMedium.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: presetAvatars.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) {
              final avatar = presetAvatars[i];
              final isSelected = avatar.id == selected.id;
              return PressScale(
                onTap: () => onSelected(avatar),
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.9,
                  duration: AppDurations.fast,
                  curve: AppCurves.emphasized,
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          isSelected ? AppGradients.goldFoil : null,
                      color: isSelected ? null : Colors.transparent,
                    ),
                    child: Stack(
                      children: [
                        ProfileAvatarView(avatar: avatar, size: 58),
                        if (isSelected)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.check,
                                size: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Translucent circular icon button used in the hero's top bar.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
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
