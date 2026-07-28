import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/core/utils/logger.dart';
import 'package:apsara_wallet_mobile/core/utils/uuid_generator.dart';
import 'package:apsara_wallet_mobile/features/scan/data/receipt_scanner_service.dart';
import 'package:apsara_wallet_mobile/features/scan/data/receipt_transaction_mapper.dart';
import 'package:apsara_wallet_mobile/features/scan/data/scanned_receipt.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/receipt_review_sheet.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/scan_capture_controls.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/widgets/scan_frame.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Scan Receipt — a live camera viewfinder that captures a receipt, runs
/// on-device OCR (Google ML Kit) over the photo, parses the recognised text
/// into a structured expense and lets the user review/edit it before saving.
///
/// Images can also be imported from the gallery, and the whole flow degrades
/// gracefully when the camera is unavailable or permission is denied (import
/// from gallery / enter manually still work).
@RoutePage()
class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

enum _ScanPhase { capture, analyzing, review }

enum _CamStatus { initializing, ready, denied, unavailable }

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  /// Entrance cascade for the chrome (title, instruction, controls).
  late final AnimationController _intro;

  /// Endless loop driving the sweeping scan line.
  late final AnimationController _ambient;

  /// Slides the review sheet up and dims the viewfinder behind it.
  late final AnimationController _reveal;

  final ReceiptScannerService _scanner = ReceiptScannerService();
  final ImagePicker _picker = ImagePicker();

  CameraController? _camera;
  _CamStatus _camStatus = _CamStatus.initializing;

  _ScanPhase _phase = _ScanPhase.capture;
  bool _flashOn = false;
  ScannedReceipt _receipt = ScannedReceipt.empty();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _reveal = AnimationController(vsync: this, duration: AppDurations.slow);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intro.dispose();
    _ambient.dispose();
    _reveal.dispose();
    _camera?.dispose();
    _scanner.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    // Release the camera when backgrounded, re-acquire on resume.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      camera.dispose();
      _camera = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) setState(() => _camStatus = _CamStatus.denied);
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _camStatus = _CamStatus.unavailable);
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _camStatus = _CamStatus.ready;
      });
    } catch (e) {
      Logger.error('Camera init failed: $e');
      if (mounted) setState(() => _camStatus = _CamStatus.unavailable);
    }
  }

  Future<void> _capture() async {
    final camera = _camera;
    if (_phase != _ScanPhase.capture ||
        camera == null ||
        !camera.value.isInitialized ||
        camera.value.isTakingPicture) {
      return;
    }
    setState(() => _phase = _ScanPhase.analyzing);
    try {
      final shot = await camera.takePicture();
      await _processImage(shot.path);
    } catch (e) {
      Logger.error('Capture failed: $e');
      if (!mounted) return;
      _failScan(context.l10n.scanErrorCapture);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_phase == _ScanPhase.analyzing) return;
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return; // user cancelled
      setState(() => _phase = _ScanPhase.analyzing);
      await _processImage(file.path);
    } catch (e) {
      Logger.error('Gallery import failed: $e');
      if (!mounted) return;
      _failScan(context.l10n.scanErrorGallery);
    }
  }

  Future<void> _processImage(String path) async {
    try {
      final receipt = await _scanner.scanImage(path);
      if (!mounted) return;
      setState(() {
        _receipt = receipt;
        _phase = _ScanPhase.review;
      });
      _reveal.forward(from: 0);
    } catch (e) {
      Logger.error('OCR failed: $e');
      if (!mounted) return;
      _failScan(context.l10n.scanErrorOcr);
    }
  }

  /// Open the review sheet with a blank receipt for hand entry.
  void _manualEntry() {
    setState(() {
      _receipt = ScannedReceipt.empty();
      _phase = _ScanPhase.review;
    });
    _reveal.forward(from: 0);
  }

  void _failScan(String message) {
    if (!mounted) return;
    setState(() => _phase = _ScanPhase.capture);
    _showSnack(message, AppGradients.emeraldDeep, LucideIcons.circleAlert);
  }

  Future<void> _toggleFlash() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    final next = !_flashOn;
    try {
      await camera.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashOn = next);
    } catch (e) {
      Logger.error('Flash toggle failed: $e');
    }
  }

  void _retake() {
    _reveal.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() => _phase = _ScanPhase.capture);
    });
  }

  Future<void> _save(ScannedReceipt receipt) async {
    // Persist the reviewed receipt as an expense. The scanner has no wallet
    // picker, so the provider defaults it to the user's first wallet; the
    // placeholder name below is only used if a matching wallet exists.
    final record = ReceiptTransactionMapper.toTransaction(
      receipt,
      id: UuidGenerator.generate(),
      walletName: WalletsData.sample.wallets.first.name,
      date: DateTime.now(),
    );
    try {
      await ref.read(transactionsProvider.notifier).add(record);
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        context.l10n.addTxSaveFailed,
        AppColors.error,
        LucideIcons.circleAlert,
      );
      return;
    }
    if (!mounted) return;
    _showSnack(
      context.l10n.scanExpenseSaved,
      AppGradients.emeraldCore,
      LucideIcons.check,
    );
    context.router.maybePop();
  }

  void _showSnack(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppFont.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
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
            // --- Live camera feed (or a graceful fallback backdrop).
            _CameraLayer(controller: _camera, status: _camStatus),

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
                  if (_camStatus == _CamStatus.denied ||
                      _camStatus == _CamStatus.unavailable)
                    _CameraNotice(status: _camStatus),
                  SafeArea(
                    child: Column(
                      children: [
                        _TopBar(
                          flashOn: _flashOn,
                          flashEnabled: _camStatus == _CamStatus.ready,
                          onToggleFlash: _toggleFlash,
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
                              captureEnabled: _camStatus == _CamStatus.ready,
                              onCapture: _capture,
                              onGallery: _pickFromGallery,
                              onManual: _manualEntry,
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
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
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

/// Paints the live camera preview (cover-fit) when ready, otherwise a dim
/// emerald backdrop so the reticle still reads.
class _CameraLayer extends StatelessWidget {
  const _CameraLayer({required this.controller, required this.status});

  final CameraController? controller;
  final _CamStatus status;

  @override
  Widget build(BuildContext context) {
    final camera = controller;
    if (status == _CamStatus.ready &&
        camera != null &&
        camera.value.isInitialized) {
      final media = MediaQuery.of(context).size;
      var scale = media.aspectRatio * camera.value.aspectRatio;
      if (scale < 1) scale = 1 / scale;
      return ClipRect(
        child: Transform.scale(
          scale: scale,
          child: Center(child: CameraPreview(camera)),
        ),
      );
    }
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A2A1C), Color(0xFF041A11)],
        ),
      ),
    );
  }
}

/// Message shown inside the frame when the camera can't be used, pointing the
/// user at the still-working Gallery / Manual options.
class _CameraNotice extends StatelessWidget {
  const _CameraNotice({required this.status});

  final _CamStatus status;

  @override
  Widget build(BuildContext context) {
    final denied = status == _CamStatus.denied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              denied ? LucideIcons.cameraOff : LucideIcons.circleAlert,
              color: AppGradients.goldLight,
              size: 34,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              denied
                  ? context.l10n.scanCameraAccessNeeded
                  : context.l10n.scanCameraUnavailable,
              textAlign: TextAlign.center,
              style: AppFont.titleSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              denied
                  ? context.l10n.scanCameraDeniedBody
                  : context.l10n.scanCameraUnavailableBody,
              textAlign: TextAlign.center,
              style: AppFont.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            if (denied) ...[
              const SizedBox(height: AppSpacing.md),
              PressScale(
                onTap: openAppSettings,
                pressedScale: 0.95,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    context.l10n.scanOpenSettings,
                    style: AppFont.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.flashOn,
    required this.flashEnabled,
    required this.onToggleFlash,
  });

  final bool flashOn;
  final bool flashEnabled;
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
              context.l10n.scanReceiptTitle,
              textAlign: TextAlign.center,
              style: AppFont.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Opacity(
            opacity: flashEnabled ? 1 : 0.4,
            child: _CircleIconButton(
              icon: flashOn ? LucideIcons.zap : LucideIcons.zapOff,
              active: flashOn,
              onTap: flashEnabled ? onToggleFlash : () {},
            ),
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
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
                  ? context.l10n.scanReadingReceipt
                  : context.l10n.scanAlignReceipt,
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
