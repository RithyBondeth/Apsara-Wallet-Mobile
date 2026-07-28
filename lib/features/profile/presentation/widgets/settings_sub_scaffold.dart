import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Shared chrome for the profile sub-pages (Security, Rewards, Help, About):
/// an emerald rounded-bottom header with a back button and centred title,
/// then a scrolling body whose [children] cascade in one after another.
///
/// Screens supply only their content [children] (typically [SettingsSection]s
/// or cards) — the header, entrance motion and safe-area padding are handled
/// here so every sub-page reads as one product.
class SettingsSubScaffold extends StatefulWidget {
  const SettingsSubScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  State<SettingsSubScaffold> createState() => _SettingsSubScaffoldState();
}

class _SettingsSubScaffoldState extends State<SettingsSubScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final n = widget.children.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            FadeSlideIn(
              controller: _intro,
              start: 0.0,
              end: 0.45,
              offset: const Offset(0, 10),
              child: _Header(
                title: widget.title,
                onBack: () => context.router.maybePop(),
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  bottomSafe + AppSpacing.xxxl,
                ),
                children: [
                  for (var i = 0; i < n; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      controller: _intro,
                      start: (0.14 + i * 0.1).clamp(0.0, 0.55),
                      end: (0.54 + i * 0.1).clamp(0.0, 1.0),
                      child: widget.children[i],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        topInset + AppSpacing.sm,
        AppSpacing.xxl,
        AppSpacing.xl,
      ),
      child: Row(
        children: [
          PressScale(
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
            title,
            style: AppFont.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 42), // balances the back button
        ],
      ),
    );
  }
}
