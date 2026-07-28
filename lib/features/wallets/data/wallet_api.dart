import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';

/// Wallet as returned by `GET /wallets`.
class ApiWallet {
  const ApiWallet({
    required this.id,
    required this.name,
    required this.kind,
    required this.balanceKhr,
    required this.balanceUsd,
    this.brandColor,
    this.accountLast4,
    this.shortCode,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String kind; // 'bank' | 'cash' | 'ewallet'
  final int balanceKhr;
  final double balanceUsd;
  final String? brandColor; // '#RRGGBB'
  final String? accountLast4;
  final String? shortCode;
  final bool isPrimary;

  factory ApiWallet.fromJson(Map<String, dynamic> json) => ApiWallet(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: json['kind'] as String,
        balanceKhr: (json['balanceKhr'] as num).toInt(),
        balanceUsd: (json['balanceUsd'] as num?)?.toDouble() ?? 0,
        brandColor: json['brandColor'] as String?,
        accountLast4: json['accountLast4'] as String?,
        shortCode: json['shortCode'] as String?,
        isPrimary: json['isPrimary'] as bool? ?? false,
      );

  /// Maps to the app's UI [Wallet] model.
  Wallet toWallet() => Wallet(
        id: id,
        name: name,
        kind: _kindFromString(kind),
        balanceKhr: balanceKhr,
        balanceUsd: balanceUsd,
        brandColor: parseHexColor(brandColor) ?? AppColors.primary,
        accountLast4: accountLast4,
        shortCode: shortCode,
        isPrimary: isPrimary,
      );
}

WalletKind _kindFromString(String kind) {
  return WalletKind.values.firstWhere(
    (k) => k.name == kind,
    orElse: () => WalletKind.bank,
  );
}

/// `'#F4511E'` → `Color(0xFFF4511E)`. Null / malformed → null.
Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  final cleaned = hex.replaceFirst('#', '').trim();
  if (cleaned.length != 6) return null;
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

/// `Color` → `'#RRGGBB'` for the backend's hex-color validation.
String colorToHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class WalletApi {
  WalletApi(this._api);

  final ApiClient _api;

  Future<List<ApiWallet>> list() async {
    final res = await _api.get<List<dynamic>>('/wallets');
    if (!res.success || res.data == null) return const [];
    return res.data!
        .map((e) => ApiWallet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> create(Wallet wallet) async {
    final res = await _api.post<Map<String, dynamic>>('/wallets', data: {
      'name': wallet.name,
      'kind': wallet.kind.name,
      'balanceKhr': wallet.balanceKhr,
      'balanceUsd': wallet.balanceUsd,
      'brandColor': colorToHex(wallet.brandColor),
      if (wallet.accountLast4 != null) 'accountLast4': wallet.accountLast4,
      if (wallet.shortCode != null) 'shortCode': wallet.shortCode,
      'isPrimary': wallet.isPrimary,
    });
    return res.success;
  }

  Future<bool> update(String id, Wallet wallet) async {
    final res = await _api.patch<Map<String, dynamic>>('/wallets/$id', data: {
      'name': wallet.name,
      'kind': wallet.kind.name,
      'balanceKhr': wallet.balanceKhr,
      'balanceUsd': wallet.balanceUsd,
      'brandColor': colorToHex(wallet.brandColor),
      'accountLast4': wallet.accountLast4,
      'shortCode': wallet.shortCode,
      'isPrimary': wallet.isPrimary,
    });
    return res.success;
  }

  /// Marks a wallet as the primary one (the backend clears the flag on the
  /// others in the same transaction).
  Future<bool> setPrimary(String id) async {
    final res = await _api.patch<Map<String, dynamic>>(
      '/wallets/$id',
      data: {'isPrimary': true},
    );
    return res.success;
  }

  /// Deletes a wallet. The backend returns 409 when the wallet still has
  /// transactions, which we surface as a distinct outcome so the UI can explain
  /// it rather than showing a generic failure.
  Future<WalletDeleteOutcome> delete(String id) async {
    final res = await _api.delete<Map<String, dynamic>>('/wallets/$id');
    if (res.success) return WalletDeleteOutcome.ok;
    if (res.statusCode == 409) return WalletDeleteOutcome.hasTransactions;
    return WalletDeleteOutcome.failed;
  }
}

/// Result of a wallet delete attempt.
enum WalletDeleteOutcome { ok, hasTransactions, failed }

final walletApiProvider = Provider<WalletApi>(
  (ref) => WalletApi(ref.watch(apiClientProvider)),
);
