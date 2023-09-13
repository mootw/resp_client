part of resp_commands;

/// Implementation of redis commands WITH full 
/// 'language support'. basically errors will throw
/// and types will return as expected
class RedisCommands {
  final RedisCommandMap base;

  final RedisCommandParser _parser = RedisCommandParser();

  RedisCommands(this.base);

  Future<int> ttl(String key) async => _parser.asInt(await base.ttl(key));

  Future<String?> set(String key, String value) async =>
      await base.set(key, value) as String?;

  Future<Object?> get(String key) async => await base.get(key);

  Future<int> incr(String key) async => await base.incr(key) as int;

  /// https://redis.io/commands/hgetall/
  /// returns an empty map when the redis reply is empty
  Future<Map<String, String>> hgetall(String key) async {
    final list = await base.hgetall(key) as List;
    final entries = <MapEntry<String, String>>[];
    for (var i = 0; i < list.length; i += 2) {
      entries
          .add(MapEntry(await list[i] as String, await list[i + 1] as String));
    }
    return Map<String, String>.fromEntries(entries);
  }

  /// https://redis.io/commands/geoadd/
  Future<int> geoadd(
    String key,
    List<({double longitude, double latitude, String member})> items, [
    String? elementOption,
    bool? CH,
  ]) async =>
      await base.geoadd(key, items, elementOption, CH) as int;

  /// https://redis.io/commands/exists/
  Future<int> exists(Iterable<String> keys) async {
    return await base.exists(keys) as int;
  }

  /// https://redis.io/commands/hset/
  Future<int> hset(
    String key,
    Iterable<MapEntry<String, String>> entries,
  ) async {
    return await base.hset(key, entries) as int;
  }

  /// https://redis.io/commands/expire/
  Future<int> pexpire(
    String key,
    Duration duration, [
    String? option,
  ]) async =>
      await base.pexpire(key, duration, option) as int;

  Future<Object?> scan(int cursor, {String? pattern, int? count}) {
    return base.scan(cursor, pattern: pattern, count: count);
  }

  //Safety wrapper for transactions...
  Transaction multi() {
    return Transaction(base);
  }

  Future<Object?> watch(List<String> keys) {
    return base.watch(keys);
  }

  Future<Object?> unwatch() {
    return base.unwatch();
  }
}
