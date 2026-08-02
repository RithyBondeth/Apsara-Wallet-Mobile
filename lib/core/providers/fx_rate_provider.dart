import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';
import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/core/storages/shared_prefs_service.dart';
import 'package:apsara_wallet_mobile/core/storages/storage_keys.dart';

/// USD→KHR exchange rate, with source provenance for display/debugging.
class FxRate {
  const FxRate({required this.khrPerUsd, this.fetchedAt, this.source = 'live'});

  final double khrPerUsd;
  final DateTime? fetchedAt;
  final String source; // 'live' | 'cache' | 'fallback'
}

/// Fetches the exchange rate from our backend (`GET /fx/rates`), which proxies
/// and caches a public provider.
class FxApi {
  FxApi(this._api);

  final ApiClient _api;

  Future<FxRate?> fetch() async {
    final res = await _api.get<Map<String, dynamic>>('/fx/rates');
    final data = res.data;
    if (!res.success || data == null) return null;
    final rate = (data['khrPerUsd'] as num?)?.toDouble();
    if (rate == null || rate <= 0) return null;
    return FxRate(
      khrPerUsd: rate,
      fetchedAt: DateTime.tryParse(data['fetchedAt'] as String? ?? ''),
      source: 'live',
    );
  }
}

final fxApiProvider = Provider<FxApi>((ref) => FxApi(ref.watch(apiClientProvider)));

/// Resolves the current rate: live from the backend when reachable (persisted
/// as last-good), else the persisted cache, else the pegged constant. Never
/// throws, so money display keeps working offline.
final fxRateProvider = FutureProvider<FxRate>((ref) async {
  final prefs = SharedPrefsService();

  final remote = await ref.watch(fxApiProvider).fetch();
  if (remote != null) {
    await prefs.setString(StorageKeys.fxKhrPerUsd, remote.khrPerUsd.toString());
    if (remote.fetchedAt != null) {
      await prefs.setString(
        StorageKeys.fxFetchedAt,
        remote.fetchedAt!.toIso8601String(),
      );
    }
    return remote;
  }

  final cached = await prefs.getString(StorageKeys.fxKhrPerUsd);
  final cachedRate = cached == null ? null : double.tryParse(cached);
  if (cachedRate != null && cachedRate > 0) {
    final at = await prefs.getString(StorageKeys.fxFetchedAt);
    return FxRate(
      khrPerUsd: cachedRate,
      fetchedAt: at == null ? null : DateTime.tryParse(at),
      source: 'cache',
    );
  }

  return const FxRate(
    khrPerUsd: AppConstants.defaultKhrPerUsd,
    source: 'fallback',
  );
});

/// Synchronous best-known rate for formatting — falls back to the constant
/// while the async fetch is still in flight. KHR display never needs this.
final khrPerUsdProvider = Provider<double>((ref) {
  return ref.watch(fxRateProvider).valueOrNull?.khrPerUsd ??
      AppConstants.defaultKhrPerUsd;
});
