import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/constants/asset_path_constant.dart';
import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/aurora_background.dart';
import 'package:apsara_wallet_mobile/shared/widgets/controls/language_switcher.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';

/// The house chrome for every auth-flow screen: living aurora backdrop,
/// optional circular back button, a title/subtitle heading and a
/// choreographed entrance cascade over the content blocks.
///
/// Keeping this in one widget is what makes the whole flow read as one
/// product — screens only declare their content, never their motion.
class AuthFlowScaffold extends StatefulWidget {
  const AuthFlowScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.showBack = false,
    this.scrollable = true,
  });

  final String title;
  final String? subtitle;

  /// Content blocks, entered in order on the cascade.
  final List<Widget> children;

  final bool showBack;

  /// Set false for screens that must pin content (e.g. number pads).
  final bool scrollable;

  @override
  State<AuthFlowScaffold> createState() => _AuthFlowScaffoldState();
}

class _AuthFlowScaffoldState extends State<AuthFlowScaffold>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  Widget _enter(double start, double end, Widget child,
      {Offset offset = const Offset(0, 28)}) {
    return FadeSlideIn(
      controller: _intro,
      start: start,
      end: end.clamp(0.0, 1.0),
      offset: offset,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[
      const SizedBox(height: AppSpacing.lg),
      // Top bar: optional back button on the left, language switcher always on
      // the right so every auth screen can change language.
      _enter(
        0.0,
        0.35,
        Row(
          children: [
            if (widget.showBack)
              _CircleBackButton(onTap: () => context.router.maybePop()),
            const Spacer(),
            const LanguageSwitcher(),
          ],
        ),
        offset: const Offset(0, -12),
      ),
      const SizedBox(height: AppSpacing.xl),
      _enter(
        0.04,
        0.42,
        Text(widget.title, style: AppFont.headingLarge),
        offset: const Offset(-24, 0),
      ),
      if (widget.subtitle != null) ...[
        const SizedBox(height: AppSpacing.sm),
        _enter(
          0.12,
          0.5,
          Text(
            widget.subtitle!,
            style: AppFont.bodyMedium.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.xxxl),
      // Content blocks join the cascade one after another.
      for (var i = 0; i < widget.children.length; i++)
        _enter(
          (0.2 + i * 0.07).clamp(0.0, 0.72),
          (0.54 + i * 0.07).clamp(0.0, 1.0),
          widget.children[i],
        ),
    ];

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Misty temple backdrop shared by the whole auth flow.
          const Image(
            image: AssetImage(AssetPathConstant.authBackground),
            fit: BoxFit.cover,
          ),
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) =>
                AuroraBackground(t: _ambient.value, moteCount: 14),
          ),
          SafeArea(
            child: GestureDetector(
              onTap: context.hideKeyboard,
              child: widget.scrollable
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: column,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: column,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.isDarkMode ? context.colors.surface : Colors.white,
          border: Border.all(
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.18),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140B5B3D),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          LucideIcons.arrowLeft,
          size: 20,
          color: context.colors.onSurface,
        ),
      ),
    );
  }
}
