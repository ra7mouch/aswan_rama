import 'dart:async';

/// {@template cache_client}
/// An in-memory cache client.
/// {@endtemplate}
class CacheClient<T> {
  /// {@macro cache_client}
  CacheClient() : _cache = <String, Object>{};
  final StreamController<Object> _userStreamController =
      StreamController<Object>.broadcast();
  void changeUserElement<T extends Object>(
      {required String key, required T value}) {
    if (key == '__user_cache_key__') {
      _userStreamController.add(value);
    }
  }

  Stream<Object> get cacheStream => _userStreamController.stream;

  final Map<String, Object> _cache;

  /// Writes the provide [key], [value] pair to the in-memory cache.
  void write<T extends Object>({required String key, required T value}) {
    _cache[key] = value;
    changeUserElement(key: key, value: value);
  }

  /// Looks up the value for the provided [key].
  /// Defaults to `null` if no value exists for the provided key.
  T? read<T extends Object>({required String key}) {
    final value = _cache[key];
    if (value is T) return value;
    return null;
  }

  void dispose() async {
    await _userStreamController.close();
  }
}
