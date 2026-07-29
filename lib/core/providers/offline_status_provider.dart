import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which data sources are currently serving *stale cached* data because
/// the network was unreachable. A source marks itself stale when it falls back
/// to cache and fresh when a live fetch succeeds; the banner shows while any
/// source is stale.
class OfflineSourcesNotifier extends StateNotifier<Set<String>> {
  OfflineSourcesNotifier() : super(const {});

  void markStale(String source) {
    if (state.contains(source)) return;
    state = {...state, source};
  }

  void markFresh(String source) {
    if (!state.contains(source)) return;
    state = {...state}..remove(source);
  }
}

final offlineSourcesProvider =
    StateNotifierProvider<OfflineSourcesNotifier, Set<String>>(
  (ref) => OfflineSourcesNotifier(),
);

/// True when any data source is showing cached-but-stale data (drives the
/// offline banner).
final isOfflineProvider = Provider<bool>(
  (ref) => ref.watch(offlineSourcesProvider).isNotEmpty,
);
