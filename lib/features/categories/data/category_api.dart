import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A system category as returned by the backend. The [slug] is the stable key
/// that lines up 1:1 with the app's local [TxCategory] catalog ids
/// (`food`, `transport`, `salary`, …), so it — not the UUID — is what the UI
/// maps against.
class ApiCategory {
  const ApiCategory({required this.id, required this.slug, required this.type});

  final String id; // UUID
  final String slug; // e.g. 'food', 'salary'
  final String type; // 'income' | 'expense'

  factory ApiCategory.fromJson(Map<String, dynamic> json) => ApiCategory(
        id: json['id'] as String,
        slug: json['slug'] as String,
        type: json['type'] as String,
      );
}

/// Two-way lookup between backend category UUIDs and app slugs.
class CategoryIndex {
  CategoryIndex(List<ApiCategory> categories)
      : _slugByUuid = {for (final c in categories) c.id: c.slug},
        _uuidBySlug = {for (final c in categories) c.slug: c.id};

  final Map<String, String> _slugByUuid;
  final Map<String, String> _uuidBySlug;

  /// Backend UUID → app slug (used when reading transactions).
  String? slugForUuid(String uuid) => _slugByUuid[uuid];

  /// App slug → backend UUID (used when creating transactions).
  String? uuidForSlug(String slug) => _uuidBySlug[slug];
}

class CategoryApi {
  CategoryApi(this._api);

  final ApiClient _api;

  Future<List<ApiCategory>> list() async {
    final res = await _api.get<List<dynamic>>('/categories');
    if (!res.success || res.data == null) return const [];
    return res.data!
        .map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final categoryApiProvider = Provider<CategoryApi>(
  (ref) => CategoryApi(ref.watch(apiClientProvider)),
);

/// Fetched once and cached for the session — the system categories are static.
final categoryIndexProvider = FutureProvider<CategoryIndex>((ref) async {
  final categories = await ref.watch(categoryApiProvider).list();
  return CategoryIndex(categories);
});
