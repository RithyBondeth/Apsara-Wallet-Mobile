import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:apsara_wallet_mobile/shared/widgets/brand/gold_medallion.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/indicators/page_indicator.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

const _pages = <_OnboardingPageData>[
  _OnboardingPageData(
    icon: LucideIcons.walletMinimal,
    title: 'All your money,\nbeautifully in one place',
    body:
        'Track balances, cards and spending across USD and KHR — with the elegance Apsara brings to every detail.',
  ),
  _OnboardingPageData(
    icon: LucideIcons.arrowLeftRight,
    title: 'Send & receive\nin a few taps',
    body:
        'Instant transfers and QR payments across Cambodia. Fast, secure, and effortless — day or night.',
  ),
  _OnboardingPageData(
    icon: LucideIcons.chartPie,
    title: 'Insights that\ngrow your wealth',
    body:
        'Smart budgets and clear analytics turn everyday spending into confident financial decisions.',
  ),
];

@RoutePage()
class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  final PageController _controller = PageController();
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page.round() >= _pages.length - 1;

  void _finish() {
    context.router.replace(const LoginRoute());
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Skip -----------------------------------------------------
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                duration: AppDurations.fast,
                opacity: _isLast ? 0 : 1,
                child: TextButton(
                  onPressed: _isLast ? null : _finish,
                  child: Text(
                    'Skip',
                    style: AppFont.labelLarge.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),

            // --- Pages ----------------------------------------------------
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final delta = index - _page; // -1..1 near neighbours
                  return _OnboardingPageView(
                    data: _pages[index],
                    delta: delta,
                  );
                },
              ),
            ),

            // --- Controls -------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  PageIndicator(count: _pages.length, page: _page),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: _isLast ? 'Get Started' : 'Next',
                    trailingIcon: LucideIcons.arrowRight,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single onboarding page with layered parallax — the medallion, title
/// and body drift at different rates as the page is swiped.
class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.data, required this.delta});

  final _OnboardingPageData data;
  final double delta;

  @override
  Widget build(BuildContext context) {
    // Content fades/scales slightly as it leaves the viewport centre.
    final centred = (1 - delta.abs()).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(delta * -60, 0), // medallion drifts fastest
            child: Transform.scale(
              scale: 0.85 + 0.15 * centred,
              child: Opacity(
                opacity: centred,
                child: GoldMedallion(icon: data.icon),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.massive),
          Transform.translate(
            offset: Offset(delta * -32, 0),
            child: Opacity(
              opacity: centred,
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                style: AppFont.headingMedium.copyWith(
                  color: context.colors.onSurface,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Transform.translate(
            offset: Offset(delta * -16, 0), // body drifts slowest
            child: Opacity(
              opacity: centred,
              child: Text(
                data.body,
                textAlign: TextAlign.center,
                style: AppFont.bodyLarge.copyWith(
                  color: context.colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
