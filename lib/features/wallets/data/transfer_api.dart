import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';

/// A transfer between two of the user's wallets, as returned by `/transfers`.
class ApiTransfer {
  const ApiTransfer({
    required this.id,
    required this.fromWalletId,
    required this.toWalletId,
    required this.amountKhr,
    required this.date,
    this.note,
  });

  final String id;
  final String fromWalletId;
  final String toWalletId;
  final int amountKhr;
  final DateTime date;
  final String? note;

  factory ApiTransfer.fromJson(Map<String, dynamic> json) => ApiTransfer(
        id: json['id'] as String,
        fromWalletId: json['fromWalletId'] as String,
        toWalletId: json['toWalletId'] as String,
        amountKhr: (json['amountKhr'] as num).toInt(),
        date: DateTime.parse(json['date'] as String).toLocal(),
        note: json['note'] as String?,
      );
}

class TransferApi {
  TransferApi(this._api);

  final ApiClient _api;

  Future<List<ApiTransfer>> list({String? walletId}) async {
    final res = await _api.get<List<dynamic>>(
      '/transfers',
      query: {'walletId': ?walletId},
    );
    if (!res.success || res.data == null) return const [];
    return res.data!
        .map((e) => ApiTransfer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> create({
    required String fromWalletId,
    required String toWalletId,
    required int amountKhr,
    required DateTime date,
    String? note,
  }) async {
    final res = await _api.post<Map<String, dynamic>>('/transfers', data: {
      'fromWalletId': fromWalletId,
      'toWalletId': toWalletId,
      'amountKhr': amountKhr,
      'date': date.toUtc().toIso8601String(),
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return res.success;
  }
}

final transferApiProvider = Provider<TransferApi>(
  (ref) => TransferApi(ref.watch(apiClientProvider)),
);

/// Transfers involving a given wallet (either side), newest first.
final walletTransfersProvider =
    FutureProvider.family<List<ApiTransfer>, String>((ref, walletId) async {
  return ref.watch(transferApiProvider).list(walletId: walletId);
});
