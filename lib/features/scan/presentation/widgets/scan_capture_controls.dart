import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// The camera-style controls anchored to the bottom of the scan screen:
/// import-from-gallery · shutter · enter-manually.
class ScanCaptureControls extends StatelessWidget {
  const ScanCaptureControls({
    super.key,
    required this.onCapture,
    required this.onGallery,
    required this.onManual,
    this.busy = false,
    this.captureEnabled = true,
  });

  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onManual;

  /// Disables the shutter while a scan is being processed.
  final bool busy;

  /// Whether the camera is ready — dims the shutter when it isn't (the
  /// gallery / manual paths still work).
  final bool captureEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SideButton(
          icon: LucideIcons.images,
          label: 'Gallery',
          onTap: onGallery,
        ),
        _ShutterButton(
          onTap: (busy || !captureEnabled) ? null : onCapture,
          busy: busy,
          enabled: captureEnabled,
        ),
        _SideButton(
          icon: LucideIcons.pencilLine,
          label: 'Manual',
          onTap: onManual,
        ),
      ],
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({
    required this.onTap,
    required this.busy,
    this.enabled = true,
  });

  final VoidCallback? onTap;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: PressScale(
        onTap: onTap,
        pressedScale: 0.92,
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppGradients.goldCore, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppGradients.goldCore.withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.goldFoil,
            ),
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF063D28)),
                      ),
                    )
                  : const Icon(
                      LucideIcons.scanLine,
                      color: Color(0xFF063D28),
                      size: 30,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.9,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.92),
                size: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppFont.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
