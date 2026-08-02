import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/core/providers/money_format_provider.dart';
import 'package:apsara_wallet_mobile/core/providers/notification_prefs_provider.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notification_mock_data.dart';
import 'package:apsara_wallet_mobile/features/notifications/data/notifications_providers.dart';

void main() {
  group('MoneyFormatter', () {
    test('KHR mode is unchanged: "KHR 12,000"', () {
      final m = MoneyFormatter(currency: ECurrencyType.khr, khrPerUsd: 4100);
      expect(m.format(12000), 'KHR 12,000');
      expect(m.number(12000), '12,000');
      expect(m.code, 'KHR');
    });

    test('USD mode converts with the rate', () {
      final m = MoneyFormatter(currency: ECurrencyType.usd, khrPerUsd: 4000);
      expect(m.format(4000), r'$1.00');
      expect(m.format(10000), r'$2.50');
      expect(m.number(8000), '2.00');
      expect(m.code, r'$');
    });
  });

  test('ECurrencyType.fromCode defaults to KHR', () {
    expect(ECurrencyType.fromCode('usd'), ECurrencyType.usd);
    expect(ECurrencyType.fromCode('khr'), ECurrencyType.khr);
    expect(ECurrencyType.fromCode(null), ECurrencyType.khr);
    expect(ECurrencyType.fromCode('garbage'), ECurrencyType.khr);
  });

  group('notification preference filtering', () {
    ProviderContainer containerWith(NotificationPrefs prefs) {
      final c = ProviderContainer(
        overrides: [
          notificationPrefsProvider.overrideWith(
            (ref) => NotificationPrefsNotifier(prefs),
          ),
          notificationsProvider.overrideWith(_SeedNotifier.new),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('category toggles hide their notifications; security always shows',
        () async {
      final c = containerWith(
        const NotificationPrefs(
          transactionAlerts: false,
          budgetWarnings: false,
          promotions: false,
        ),
      );
      // Realise the async notifier.
      await c.read(notificationsProvider.future);
      final visible = c.read(visibleNotificationsProvider).valueOrNull ?? [];
      final ids = visible.map((e) => e.id).toSet();
      // Only the security notification survives with all categories off.
      expect(ids, {'sec'});
    });

    test('all categories on shows everything', () async {
      final c = containerWith(const NotificationPrefs(promotions: true));
      await c.read(notificationsProvider.future);
      final visible = c.read(visibleNotificationsProvider).valueOrNull ?? [];
      expect(visible.length, 4);
    });

    test('promotions default off hides promo but keeps the rest', () async {
      final c = containerWith(const NotificationPrefs());
      await c.read(notificationsProvider.future);
      final ids =
          (c.read(visibleNotificationsProvider).valueOrNull ?? [])
              .map((e) => e.id)
              .toSet();
      expect(ids, {'act', 'bud', 'sec'});
    });

    test('push off zeroes the unread bell count but inbox still filters',
        () async {
      final c = containerWith(const NotificationPrefs(push: false));
      await c.read(notificationsProvider.future);
      expect(c.read(unreadNotificationsProvider), 0);
    });
  });
}

/// A notifications notifier seeded with one of each category (all unread).
class _SeedNotifier extends NotificationsNotifier {
  @override
  Future<List<AppNotification>> build() async => [
        _mk('act', ENotifCategory.activity),
        _mk('bud', ENotifCategory.budget),
        _mk('sec', ENotifCategory.security),
        _mk('promo', ENotifCategory.promotion),
      ];

  static AppNotification _mk(String id, ENotifCategory c) => AppNotification(
        id: id,
        icon: Icons.circle,
        color: const Color(0xFF000000),
        minutesAgo: 1,
        titleOf: (_) => id,
        bodyOf: (_) => id,
        category: c,
      );
}
