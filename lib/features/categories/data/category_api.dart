import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/features/categories/data/category_choices.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A category as returned by the backend. System categories line up 1:1 with
/// the app's static [TxCategory] catalog via [slug]; user categories carry
/// their own name/icon/color.
class ApiCategory {
  const ApiCategory({
    required this.id,
    required this.slug,
    required this.type,
    required this.name,
    required this.isSystem,
    this.icon,
    this.color,
  });

  final String id; // UUID
  final String slug;
  final String type; // 'income' | 'expense'
  final String name;
  final bool isSystem;
  final String? icon; // icon token (index into categoryIconChoices)
  final String? color; // '#RRGGBB'

  bool get isExpense => type == 'expense';

  factory ApiCategory.fromJson(Map<String, dynamic> json) => ApiCategory(
        id: json['id'] as String,
        slug: json['slug'] as String,
        type: json['type'] as String,
        name: (json['name'] as String?) ?? (json['slug'] as String),
        isSystem: json['isSystem'] as bool? ?? (json['userId'] == null),
        icon: json['icon'] as String?,
        color: json['color'] as String?,
      );

  /// Maps a user category to a [TxCategory] whose label is its plain name and
  /// whose icon/color come from the stored tokens.
  TxCategory toTxCategory() => TxCategory(
        id: slug,
        icon: iconFromToken(icon),
        color: parseHexColor(color) ?? categoryColorChoices.first,
        labelOf: (_) => name,
      );
}

/// Two-way lookup between backend category UUIDs and app slugs.
class CategoryIndex {
  CategoryIndex(List<ApiCategory> categories)
      : _slugByUuid = {for (final c in categories) c.id: c.slug},
        _uuidBySlug = {for (final c in categories) c.slug: c.id};

  final Map<String, String> _slugByUuid;
  final Map<String, String> _uuidBySlug;

  String? slugForUuid(String uuid) => _slugByUuid[uuid];
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

  Future<bool> create({
    required String slug,
    required String name,
    required ETransactionType type,
    required String icon,
    required String color,
  }) async {
    final res = await _api.post<Map<String, dynamic>>('/categories', data: {
      'slug': slug,
      'name': name,
      'type': type.name,
      'icon': icon,
      'color': color,
    });
    return res.success;
  }

  Future<bool> update({
    required String id,
    required String name,
    required String icon,
    required String color,
  }) async {
    final res = await _api.patch<Map<String, dynamic>>('/categories/$id', data: {
      'name': name,
      'icon': icon,
      'color': color,
    });
    return res.success;
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete<Map<String, dynamic>>('/categories/$id');
    return res.success;
  }
}

final categoryApiProvider = Provider<CategoryApi>(
  (ref) => CategoryApi(ref.watch(apiClientProvider)),
);

/// Raw category list (system + the user's own), fetched once for the session.
final categoriesListProvider = FutureProvider<List<ApiCategory>>((ref) async {
  return ref.watch(categoryApiProvider).list();
});

final categoryIndexProvider = FutureProvider<CategoryIndex>((ref) async {
  final categories = await ref.watch(categoriesListProvider.future);
  return CategoryIndex(categories);
});

/// The user's own categories mapped to [TxCategory], split by type. Empty when
/// the user hasn't created any (or offline / in tests).
final userCategoriesProvider =
    FutureProvider<({List<TxCategory> expense, List<TxCategory> income})>(
        (ref) async {
  final categories = await ref.watch(categoriesListProvider.future);
  final user = categories.where((c) => !c.isSystem).toList();
  return (
    expense: [for (final c in user.where((c) => c.isExpense)) c.toTxCategory()],
    income: [for (final c in user.where((c) => !c.isExpense)) c.toTxCategory()],
  );
});
