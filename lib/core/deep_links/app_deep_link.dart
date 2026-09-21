import 'package:auto_route/auto_route.dart';

import 'package:apsara_wallet_mobile/routes/app_routes.dart';

/// A link the app knows how to open, parsed from an incoming URI.
///
/// Two shapes are accepted for every destination:
///
/// * the custom scheme the API emails today —
///   `apsarawallet://reset-password?token=…` (the destination is the host);
/// * an HTTPS link on the marketing domain, for App Links / Universal Links
///   later — `https://apsarawallet.app/reset-password?token=…` (the
///   destination is the path).
///
/// Anything else parses to `null` and is ignored, so a stray or malformed
/// link can never navigate somewhere unexpected.
sealed class AppDeepLink {
  const AppDeepLink();

  static const String scheme = 'apsarawallet';
  static const String webHost = 'apsarawallet.app';

  /// The route this link opens; pushed on top of wherever the app is.
  PageRouteInfo get route;

  static AppDeepLink? parse(Uri uri) {
    final destination = _destinationOf(uri);
    switch (destination) {
      case 'reset-password':
        final token = uri.queryParameters['token']?.trim() ?? '';
        return token.isEmpty ? null : ResetPasswordDeepLink(token);
      default:
        return null;
    }
  }

  /// `reset-password` for both `apsarawallet://reset-password` and
  /// `https://apsarawallet.app/reset-password`; null for anything else.
  static String? _destinationOf(Uri uri) {
    if (uri.scheme == scheme) {
      return uri.host.isNotEmpty
          ? uri.host
          : uri.pathSegments.firstOrNull; // `apsarawallet:/reset-password`
    }
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == webHost) {
      return uri.pathSegments.firstOrNull;
    }
    return null;
  }
}

/// `…/reset-password?token=<token>` — from the password-reset email.
final class ResetPasswordDeepLink extends AppDeepLink {
  const ResetPasswordDeepLink(this.token);

  final String token;

  @override
  PageRouteInfo get route => ResetPasswordRoute(token: token);

  @override
  bool operator ==(Object other) =>
      other is ResetPasswordDeepLink && other.token == token;

  @override
  int get hashCode => token.hashCode;
}
