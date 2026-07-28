import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_mock_data.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notifications_providers.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/fade_slide_in.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// The notifications inbox, API-backed: grouped Today / Earlier lists of real
/// activity (recurring posted, savings milestones, budget alerts). Tapping a
/// row marks it read; "Mark all read" clears every unread. Reached from the
/// dashboard header's bell.
@RoutePage()
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
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

  void _markRead(String id) {
    ref.read(notificationsProvider.notifier).markRead(id);
  }

  void _markAllRead() {
    final unread = ref.read(unreadNotificationsProvider);
    if (unread == 0) return;
    ref.read(notificationsProvider.notifier).markAllRead();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Text(
          context.l10n.notifAllRead,
          style: AppFont.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final notifsAsync = ref.watch(notificationsProvider);
    final items = notifsAsync.valueOrNull ?? const <AppNotification>[];
    final loading = notifsAsync.isLoading && !notifsAsync.hasValue;
    final unread = items.where((n) => !n.read).length;
    final today = items.where((n) => n.isToday).toList();
    final earlier = items.where((n) => !n.isToday).toList();

    // Flatten into rows so each gets its own staggered entrance interval.
    final rows = <Widget>[];
    var order = 0;
    void addSection(String label, List<AppNotification> items) {
      if (items.isEmpty) return;
      rows.add(_sectionHeader(label, topPad: order > 0));
      for (final n in items) {
        final step = (0.12 + order * 0.06).clamp(0.0, 0.55);
        rows.add(
          FadeSlideIn(
            controller: _intro,
            start: step,
            end: (step + 0.45).clamp(0.0, 1.0),
            offset: const Offset(0, 12),
            child: _NotificationTile(
              notification: n,
              onTap: () => _markRead(n.id),
            ),
          ),
        );
        order++;
      }
    }

    addSection(l10n.notifToday, today);
    addSection(l10n.notifEarlier, earlier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FadeSlideIn(
                controller: _intro,
                start: 0.0,
                end: 0.4,
                offset: const Offset(0, 10),
                child: _AppBar(
                  title: l10n.notifTitle,
                  unread: unread,
                  markAllLabel: l10n.notifMarkAllRead,
                  onBack: () => context.router.maybePop(),
                  onMarkAll: _markAllRead,
                ),
              ),
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : items.isEmpty
                        ? _EmptyState(
                            title: l10n.notifEmptyTitle,
                            body: l10n.notifEmptyBody,
                          )
                        : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.sm,
                          AppSpacing.xxl,
                          bottomSafe + AppSpacing.xxxl,
                        ),
                        children: rows,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String label, {required bool topPad}) {
    return Padding(
      padding: EdgeInsets.only(
        top: topPad ? AppSpacing.xl : AppSpacing.sm,
        bottom: AppSpacing.md,
        left: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppFont.labelMedium.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Back button + title (with an unread count pill) + "Mark all read" action.
class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.title,
    required this.unread,
    required this.markAllLabel,
    required this.onBack,
    required this.onMarkAll,
  });

  final String title;
  final int unread;
  final String markAllLabel;
  final VoidCallback onBack;
  final VoidCallback onMarkAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          PressScale(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: AppFont.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (unread > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '$unread',
                style: AppFont.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (unread > 0)
            PressScale(
              onTap: onMarkAll,
              pressedScale: 0.94,
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.checkCheck,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    markAllLabel,
                    style: AppFont.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A single notification row: tinted icon tile, title + body + relative time,
/// and an unread accent (soft emerald wash + a dot) until it is read.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final n = notification;
    final unread = !n.read;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PressScale(
        onTap: onTap,
        pressedScale: 0.98,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: unread
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: unread
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.surfaceVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: n.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(n.icon, color: n.color, size: 21),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.titleOf(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFont.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            margin: const EdgeInsets.only(left: 6, top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.bodyOf(l10n),
                      style: AppFont.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n.relativeLabel(l10n),
                      style: AppFont.labelSmall.copyWith(
                        color: AppColors.textMuted,
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

/// Shown when the inbox is empty.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.bellOff,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppFont.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppFont.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
