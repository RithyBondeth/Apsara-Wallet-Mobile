//Used for: walletBalance, selectedCurrency, cachedTransactions, lastSyncTime

class CacheStorage {
  CacheStorage._();

  static final Map<String, dynamic> _cache = {};

  static void write(String key, dynamic value) {
    _cache[key] = value;
  }

  static T? read<T>(String key) {
    return _cache[key] as T?;
  }

  static void remove(String key) {
    _cache.remove(key);
  }

  static void clear() {
    _cache.clear();
  }
}
