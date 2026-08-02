import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A tiny last-good cache for raw API JSON list responses, keyed by a
/// [StorageKeys] string and stored in SharedPrefs. Lets data screens serve the
/// most recent successful fetch while the network is unreachable.
class JsonCache {
  Future<void> writeList(String key, List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<List<dynamic>?> readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded : null;
    } catch (_) {
      return null; // corrupt cache → treat as absent
    }
  }
}

final jsonCacheProvider = Provider<JsonCache>((ref) => JsonCache());
