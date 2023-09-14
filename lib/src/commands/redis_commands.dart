part of resp_commands;

/// Implementation of redis commands WITH opinionated
/// parsing and typing. this is the recommended way to
/// interact given the usage and typing safety provided.
class RedisCommands {
  final RedisCommandMap cmd;

  final RedisCommandParser _parse = RedisCommandParser();

  RedisCommands(this.cmd);

  Future<int> ttl(String key) async => await cmd.ttl(key) as int;

  Future<String?> set(String key, String value) async =>
      await cmd.set(key, value) as String?;

  Future<Object?> get(String key) async => await cmd.get(key);

  Future<int> incr(String key) async => await cmd.incr(key) as int;

  /// https://redis.io/commands/hgetall/
  /// returns an empty map when the redis reply is empty
  Future<Map<String, String>> hgetall(String key) async =>
      _parse.asMap(await cmd.hgetall(key));

  /// https://redis.io/commands/geoadd/
  Future<int> geoadd(
    String key,
    List<({double longitude, double latitude, String member})> items, [
    String? elementOption,
    bool? CH,
  ]) async =>
      await cmd.geoadd(key, items, elementOption, CH) as int;

  /// https://redis.io/commands/exists/
  Future<int> exists(Iterable<String> keys) async =>
      await cmd.exists(keys) as int;

  /// https://redis.io/commands/hset/
  Future<int> hset(
    String key,
    Iterable<MapEntry<String, String>> entries,
  ) async =>
      await cmd.hset(key, entries) as int;

  /// https://redis.io/commands/expire/
  Future<int> pexpire(
    String key,
    Duration duration, [
    String? option,
  ]) async =>
      await cmd.pexpire(key, duration, option) as int;

  Future<Object?> scan(int cursor, {String? pattern, int? count}) =>
      cmd.scan(cursor, pattern: pattern, count: count);

  Transaction multi() => Transaction(cmd);

  Future<Object?> watch(List<String> keys) => cmd.watch(keys);

  Future<Object?> unwatch() => cmd.unwatch();
}
