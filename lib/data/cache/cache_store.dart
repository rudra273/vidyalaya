import 'dart:convert';

import 'package:hive_ce/hive.dart';

class CacheEntry<T> {
  final T value;
  final DateTime savedAt;

  const CacheEntry({required this.value, required this.savedAt});
}

const int kCacheSchemaVersion = 1;

class CacheStore {
  final Box<String> _box;

  CacheStore(this._box);

  static const boxName = 'app_cache';

  static String key({String? uid, required String name}) {
    return uid == null ? 'global:$name' : '$uid:$name';
  }

  T? read<T>(String key, T Function(Object json) fromJson) {
    return readWithMeta<T>(key, fromJson)?.value;
  }

  CacheEntry<T>? readWithMeta<T>(String key, T Function(Object json) fromJson) {
    final raw = _box.get(key);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['v'] != kCacheSchemaVersion) {
        _box.delete(key);
        return null;
      }

      return CacheEntry(
        value: fromJson(decoded['value'] as Object),
        savedAt: DateTime.parse(decoded['savedAt'] as String),
      );
    } catch (_) {
      _box.delete(key);
      return null;
    }
  }

  Future<void> write<T>(String key, T value, Object Function(T value) toJson) {
    return _box.put(
      key,
      jsonEncode({
        'v': kCacheSchemaVersion,
        'savedAt': DateTime.now().toIso8601String(),
        'value': toJson(value),
      }),
    );
  }

  Future<void> delete(String key) => _box.delete(key);

  Future<void> deleteNamespace(String uid) async {
    final prefix = '$uid:';
    final keys = _box.keys
        .whereType<String>()
        .where((key) => key.startsWith(prefix))
        .toList();
    await _box.deleteAll(keys);
  }
}
