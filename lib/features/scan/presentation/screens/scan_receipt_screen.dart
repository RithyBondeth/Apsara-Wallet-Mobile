import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/scan/data/scan_receipt_mock_data.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/receipt_review_sheet.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/scan_capture_controls.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/scan_frame.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Scan Receipt — a camera-style viewfinder that (in Phase 1) simulates an
/// OCR scan: tap the shutter, watch the reticle read the page, then review the
/// extracted merchant, items and totals before saving as an expense.
///
/// UI only — no real camera or OCR is wired; the shutter reveals mock data.
@RoutePage()
class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

enum _ScanPhase { capture, analyzing, review }

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen>
    with TickerProviderStateMixin {
  /// Entrance cascade for the chrome (title, instruction, controls).
  late final AnimationController _intro;

  /// Endless loop driving the sweeping scan line.
  late final AnimationController _ambient;

  /// Slides the review sheet up and dims the viewfinder behind it.
  late final AnimationController _reveal;

  final ScannedReceipt _receipt = ScannedReceipt.sample;

  _ScanPhase _phase = _ScanPhase.capture;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _reveal = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    _reveal.dispose();
    super.dispose();
  }

  void _beginScan() {
    if (_phase != _ScanPhase.capture) return;
    setState(() => _phase = _ScanPhase.analyzing);
    // Simulate the OCR read, then reveal the extracted result.
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted || _phase != _ScanPhase.analyzing) return;
      setState(() => _phase = _ScanPhase.review);
      _reveal.forward();
    });
  }

  void _retake() {
    _reveal.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() => _phase = _ScanPhase.capture);
    });
  }

  void _save() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppGradients.emeraldCore,
          content: Row(
            children: [
              const Icon(LucideIcons.check, color: Colors.white, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Expense saved',
                style: AppFont.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final analyzing = _phase == _ScanPhase.analyzing;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF041A11),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // --- Camera "feed" (dim emerald gradient stands in for the lens).
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A2A1C), Color(0xFF041A11)],
                ),
              ),
            ),

            // --- Viewfinder + chrome, faded and locked out during review.
            AnimatedBuilder(
              animation: _reveal,
              builder: (context, child) => Opacity(
                opacity: 1 - _reveal.value,
                child: IgnorePointer(
                  ignoring: _phase == _ScanPhase.review,
                  child: child,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ScanFrame(ambient: _ambient, scanning: analyzing),
                  SafeArea(
                    child: Column(
                      children: [
                        _TopBar(
                          flashOn: _flashOn,
                          onToggleFlash: () =>
                              setState(() => _flashOn = !_flashOn),
                        ),
                        const Spacer(),
                        FadeSlideIn(
                          controller: _intro,
                          start: 0.2,
                          end: 0.9,
                          child: _InstructionPill(analyzing: analyzing),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        FadeSlideIn(
                          controller: _intro,
                          start: 0.35,
                          end: 1.0,
                          offset: const Offset(0, 20),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              0,
                              AppSpacing.lg,
                              AppSpacing.xl,
                            ),
                            child: ScanCaptureControls(
                              busy: analyzing,
                              onCapture: _beginScan,
                              onGallery: _beginScan,
                              onManual: () => context.router.maybePop(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Dim scrim behind the review sheet.
            if (_phase == _ScanPhase.review)
              AnimatedBuilder(
                animation: _reveal,
                builder: (context, _) => Container(
                  color: Colors.black.withValues(alpha: _reveal.value * 0.55),
                ),
              ),

            // --- Persistent back control (sits above the fading viewfinder).
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: _CircleIconButton(
                  icon: LucideIcons.arrowLeft,
                  onTap: () => context.router.maybePop(),
                ),
              ),
            ),

            // --- Review sheet, slid up from the bottom.
            if (_phase == _ScanPhase.review)
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedBuilder(
                  animation: _reveal,
                  builder: (context, child) => FractionalTranslation(
                    translation: Offset(0, 1 - _reveal.value),
                    child: child,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.86,
                    ),
                    child: ReceiptReviewSheet(
                      receipt: _receipt,
                      onSave: _save,
                      onRetake: _retake,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.flashOn, required this.onToggleFlash});

  final bool flashOn;
  final VoidCallback onToggleFlash;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Balances the trailing flash button so the title stays centred
          // (the real back control is a separate persistent overlay).
          const SizedBox(width: 56),
          Expanded(
            child: Text(
              'Scan Receipt',
              textAlign: TextAlign.center,
              style: AppFont.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _CircleIconButton(
            icon: flashOn ? LucideIcons.zap : LucideIcons.zapOff,
            active: flashOn,
            onTap: onToggleFlash,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: PressScale(
        onTap: onTap,
        pressedScale: 0.9,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active
                ? AppGradients.goldCore.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: active ? const Color(0xFF063D28) : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _InstructionPill extends StatelessWidget {
  const _InstructionPill({required this.analyzing});

  final bool analyzing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            analyzing ? LucideIcons.sparkles : LucideIcons.scanLine,
            size: 16,
            color: AppGradients.goldLight,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              analyzing
                  ? 'Reading your receipt…'
                  : 'Align the receipt within the frame',
              style: AppFont.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
