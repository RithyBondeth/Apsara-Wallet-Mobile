import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';

/// Client for the in-app rating capture endpoint (`POST /feedback`).
///
/// Every rating is recorded; a [comment] is sent for low ratings (the rating
/// gate keeps unhappy feedback in-app instead of a public store review).
class FeedbackApi {
  FeedbackApi(this._api);

  final ApiClient _api;

  Future<bool> submit({
    required int rating,
    String? comment,
    String? appVersion,
    String? platform,
  }) async {
    final res = await _api.post<Map<String, dynamic>>('/feedback', data: {
      'rating': rating,
      'comment': ?comment,
      'appVersion': ?appVersion,
      'platform': ?platform,
    });
    return res.success;
  }
}

final feedbackApiProvider = Provider<FeedbackApi>(
  (ref) => FeedbackApi(ref.watch(apiClientProvider)),
);
