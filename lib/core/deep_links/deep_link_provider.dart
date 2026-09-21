import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/deep_links/app_deep_link.dart';

/// Where incoming links come from. The platform stream (which also replays
/// the link that cold-started the app) in production; tests override it with
/// a controlled stream.
final deepLinkSourceProvider = Provider<Stream<Uri>>(
  (ref) => AppLinks().uriLinkStream,
);

/// The link waiting to be opened, if any.
///
/// [MyApp] feeds parsed links in here. If the app is already past the splash
/// it opens them immediately; otherwise the splash consumes the pending link
/// when it hands off, so a cold start from an email lands on the right
/// screen instead of being wiped by the splash's own navigation.
final deepLinkProvider = NotifierProvider<DeepLinkNotifier, AppDeepLink?>(
  DeepLinkNotifier.new,
);

class DeepLinkNotifier extends Notifier<AppDeepLink?> {
  @override
  AppDeepLink? build() => null;

  void set(AppDeepLink link) => state = link;

  /// Returns the pending link and clears it.
  AppDeepLink? take() {
    final link = state;
    state = null;
    return link;
  }
}
