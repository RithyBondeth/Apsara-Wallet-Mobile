import 'dart:convert';

/// The JWT pair returned by every auth endpoint (`register`, `login`,
/// `refresh`). The backend responds with exactly these two fields.
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}

/// The signed-in identity. The backend has no `/me` endpoint yet, so `id` and
/// `email` are decoded from the access token's payload; `fullName` is only
/// known at register time (or from a previously cached session).
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? phone;

  AuthUser copyWith({String? fullName, String? phone}) => AuthUser(
        id: id,
        email: email,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String?,
        phone: json['phone'] as String?,
      );

  /// Rebuilds a user from an access-token payload (`{ sub, email, ... }`).
  /// Returns null if the token is malformed or missing the expected claims.
  static AuthUser? fromAccessToken(String token) {
    final payload = decodeJwtPayload(token);
    final sub = payload?['sub'];
    final email = payload?['email'];
    if (sub is String && email is String) {
      return AuthUser(id: sub, email: email);
    }
    return null;
  }
}

/// Decodes a JWT's payload segment (no signature verification — that is the
/// server's job; here we only read claims we already trust because they came
/// from our own secure store). Returns null on any structural problem.
Map<String, dynamic>? decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(decoded);
    return map is Map<String, dynamic> ? map : null;
  } catch (_) {
    return null;
  }
}

/// Whether a JWT is already past (or within [leeway] of) its `exp` claim.
/// A token with no `exp` is treated as non-expiring.
bool isJwtExpired(String token, {Duration leeway = const Duration(seconds: 15)}) {
  final exp = decodeJwtPayload(token)?['exp'];
  if (exp is! int) return false;
  final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  return DateTime.now().add(leeway).isAfter(expiry);
}
