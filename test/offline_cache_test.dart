import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/core/providers/offline_status_provider.dart';
import 'package:apsara_wallet_mobile/features/categories/data/category_api.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_api.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';

/// A WalletApi whose `fetchRaw` is scripted per-call: a Map is returned as a
/// one-element raw list, an Object that is a Function throws.
class _ScriptedWalletApi extends WalletApi {
  _ScriptedWalletApi(this.behaviour) : super(ApiClient(Dio()));

  bool behaviour; // true = succeed, false = throw

  @override
  Future<List<dynamic>> fetchRaw() async {
    if (!behaviour) throw Exception('offline');
    return [
      {'id': 'w1', 'name': 'ABA', 'kind': 'bank', 'balanceKhr': 5000},
    ];
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  ProviderContainer makeContainer(_ScriptedWalletApi api) {
    final c = ProviderContainer(
      overrides: [walletApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('caches a live fetch, then serves it stale when offline', () async {
    final api = _ScriptedWalletApi(true);
    final c = makeContainer(api);

    final live = await c.read(walletsProvider.future);
    expect(live.single.name, 'ABA');
    // Give the deferred offline-marker microtask a chance to run.
    await Future<void>.delayed(Duration.zero);
    expect(c.read(isOfflineProvider), isFalse);

    // Now go offline and reload — should serve the cached snapshot.
    api.behaviour = false;
    c.invalidate(walletsProvider);
    final stale = await c.read(walletsProvider.future);
    expect(stale.single.name, 'ABA'); // same cached data
    await Future<void>.delayed(Duration.zero);
    expect(c.read(isOfflineProvider), isTrue);
  });

  test('with no cache, an offline fetch surfaces the error', () async {
    final api = _ScriptedWalletApi(false);
    final c = makeContainer(api);

    await expectLater(c.read(walletsProvider.future), throwsA(isA<Exception>()));
  });

  group('categories cache (supporting data — degrades to empty)', () {
    test('caches then serves the catalog offline', () async {
      final api = _ScriptedCategoryApi(true);
      final c = ProviderContainer(
        overrides: [categoryApiProvider.overrideWithValue(api)],
      );
      addTearDown(c.dispose);

      final live = await c.read(categoriesListProvider.future);
      expect(live.single.slug, 'food');

      api.behaviour = false;
      c.invalidate(categoriesListProvider);
      final cached = await c.read(categoriesListProvider.future);
      expect(cached.single.slug, 'food'); // from cache, not an error
    });

    test('offline with no cache returns empty (never throws)', () async {
      final api = _ScriptedCategoryApi(false);
      final c = ProviderContainer(
        overrides: [categoryApiProvider.overrideWithValue(api)],
      );
      addTearDown(c.dispose);

      final result = await c.read(categoriesListProvider.future);
      expect(result, isEmpty);
    });
  });
}

class _ScriptedCategoryApi extends CategoryApi {
  _ScriptedCategoryApi(this.behaviour) : super(ApiClient(Dio()));

  bool behaviour;

  @override
  Future<List<dynamic>> fetchRaw() async {
    if (!behaviour) throw Exception('offline');
    return [
      {'id': 'c1', 'slug': 'food', 'type': 'expense', 'name': 'Food'},
    ];
  }
}
