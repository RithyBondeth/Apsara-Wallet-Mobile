/// UI-only mock data for the profile & settings screens. Phase 1 is
/// presentation only — no backend — so these fixtures stand in for the
/// signed-in user and their preferences.
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
  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  static const ProfileData sample = ProfileData(
    fullName: 'Sokunthea Chan',
    email: 'sokunthea.chan@gmail.com',
    phone: '+855 12 345 678',
    membership: 'Gold Member',
    memberSince: 'Member since 2023',
    walletCount: 4,
    transactionCount: 128,
    budgetCount: 6,
  );
}
