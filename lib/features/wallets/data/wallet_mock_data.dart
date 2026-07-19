import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';

/// UI-only mock data for the Wallets screen (Phase 1). Latin-grouped KHR
/// formatting to match the design ("KHR 1,250,000"), not the ៛ symbol.

final NumberFormat _khr = NumberFormat.decimalPattern('en_US');
final NumberFormat _usd = NumberFormat('#,##0.00', 'en_US');

/// `1250000` -> `"1,250,000"`.
String formatKhr(num value) => _khr.format(value);

/// `312.1` -> `"312.10"`.
String formatUsd(num value) => _usd.format(value);

/// The kind of account a wallet represents — drives the small type label.
enum WalletKind {
  bank('Bank Account'),
  cash('Cash'),
  ewallet('E-Wallet');

  const WalletKind(this.label);

  final String label;
}

/// A single funding source shown in the wallets list.
class Wallet {
  const Wallet({
    required this.name,
    required this.kind,
    required this.balanceKhr,
    required this.balanceUsd,
    required this.brandColor,
    this.accountLast4,
    this.shortCode,
    this.icon,
    this.isPrimary = false,
  });

  final String name;
  final WalletKind kind;
  final int balanceKhr;
  final double balanceUsd;

  /// Accent used for the leading logo tile.
  final Color brandColor;

  /// Last 4 digits of the linked account, if any (masked in the UI).
  final String? accountLast4;

  /// Short brand code shown in the logo tile (e.g. "ABA"). Falls back to
  /// [icon] when null.
  final String? shortCode;

  /// Leading glyph used when the wallet has no [shortCode] (e.g. cash).
  final IconData? icon;

  /// The default wallet — gets a small badge.
  final bool isPrimary;

  /// Masked account line, e.g. "•••• 1234".
  String? get maskedAccount =>
      accountLast4 == null ? null : '•••• $accountLast4';
}

/// Everything the Wallets screen renders, gathered in one place.
class WalletsData {
  const WalletsData({
    required this.totalBalanceKhr,
    required this.totalBalanceUsd,
    required this.wallets,
  });

  final int totalBalanceKhr;
  final double totalBalanceUsd;
  final List<Wallet> wallets;

  int get walletCount => wallets.length;

  static const WalletsData sample = WalletsData(
    totalBalanceKhr: 2584300,
    totalBalanceUsd: 645.20,
    wallets: [
      Wallet(
        name: 'ABA Bank',
        kind: WalletKind.bank,
        balanceKhr: 1250000,
        balanceUsd: 312.08,
        brandColor: Color(0xFF1E4FA3),
        accountLast4: '1234',
        shortCode: 'ABA',
        isPrimary: true,
      ),
      Wallet(
        name: 'ACLEDA Bank',
        kind: WalletKind.bank,
        balanceKhr: 850000,
        balanceUsd: 212.22,
        brandColor: Color(0xFFC79A2E),
        accountLast4: '5678',
        shortCode: 'ACL',
      ),
      Wallet(
        name: 'Cash Wallet',
        kind: WalletKind.cash,
        balanceKhr: 320000,
        balanceUsd: 79.89,
        brandColor: AppColors.income,
        icon: LucideIcons.banknote,
      ),
      Wallet(
        name: 'Wing',
        kind: WalletKind.ewallet,
        balanceKhr: 164300,
        balanceUsd: 41.01,
        brandColor: Color(0xFF00A9E0),
        accountLast4: '9012',
        shortCode: 'Wing',
      ),
    ],
  );
}
