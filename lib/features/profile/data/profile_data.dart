/// What the profile header and stats card render for the signed-in user,
/// assembled by the profile screen from the auth session and the live
/// wallet/transaction/budget providers.
class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.membership,
    required this.memberSince,
    required this.walletCount,
    required this.transactionCount,
    required this.budgetCount,
  });

  final String fullName;
  final String email;
  final String phone;

  /// e.g. "Gold Member" — shown on the badge under the avatar.
  final String membership;
  final String memberSince;

  final int walletCount;
  final int transactionCount;
  final int budgetCount;

  /// Uppercase initials for the fallback avatar (e.g. "Sokunthea Chan" → "SC").
  String get initials => initialsOf(fullName);
}

/// Uppercase initials for a fallback avatar: first letter of the first and
/// last words ("Sokunthea Chan" → "SC"), or one letter for a single word.
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
