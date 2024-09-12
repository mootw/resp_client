part of resp_commands;

/// Implementation of redis commands WITH opinionated
/// parsing and typing. this is the recommended way to
/// interact given the usage and typing safety provided.
class RedisCommands {
  final RedisCommandMap cmd;

  final RedisCommandParser _parse = RedisCommandParser();

  RedisCommands(this.cmd);

  Future<int> ttl(String key) async => await cmd.ttl(key) as int;

  Future<String?> set(String key, String value,
          {bool? get, Duration? px}) async =>
      await cmd.set(key, value, get: get, px: px) as String?;

  /// Can return String, potentially BinaryString
  Future<Object?> setBytes(String key, List<int> value,
          {bool? get, Duration? px}) async =>
      await cmd.set(key, value, get: get, px: px);

  Future<String?> get(String key) async => (await cmd.get(key))?.toString();

  Future<List<int>?> getBytes(String key) async =>
      (await cmd.get(key) as BinaryString?)?.bytes;

  Future<int> incr(String key) async => await cmd.incr(key) as int;

  /// https://redis.io/commands/hgetall/
  /// returns an empty map when the redis reply is empty
  Future<Map<String, String>> hgetall(String key) async =>
      _parse.asMap(await cmd.hgetall(key));

  /// https://redis.io/commands/hmget/
  /// returns an empty map when the redis reply is empty
  Future<List<String>> hmget(String key, List<String> fields) async =>
      (await cmd.hmget(key, fields) as List).map((e) => e.toString()).toList();

  /// https://redis.io/commands/geoadd/
  Future<int> geoadd(
    String key,
    List<({double longitude, double latitude, String member})> items, [
    String? elementOption,
    bool? CH,
  ]) async =>
      await cmd.geoadd(key, items, elementOption, CH) as int;

  /// https://redis.io/commands/geoadd/
  ///
  Future<List> geosearchbylonlatbbox(
    String key,
    double lon,
    double lat,
    double widthM,
    double heightM,
  ) async =>
      (await cmd.geosearchlonlatbbox(key, lon, lat, widthM, heightM) as List)
          .map((e) => e.toString())
          .toList();

  /// https://redis.io/commands/exists/
  Future<int> exists(Iterable<String> keys) async =>
      await cmd.exists(keys) as int;

  /// https://redis.io/commands/smembers/
  Future<List<String>> smembers(String key) async =>
      (await cmd.smembers(key) as List).map((e) => e.toString()).toList();

  /// https://redis.io/commands/sadd/
  Future<int> sadd(String key, List<String> members) async =>
      await cmd.sadd(key, members) as int;

  /// https://redis.io/commands/del/
  Future<int> del(Iterable<String> keys) async => await cmd.del(keys) as int;

  /// https://redis.io/commands/mget/
  Future<List<String?>> mget(Iterable<String> keys) async =>
      (await cmd.mget(keys) as List).map((e) => e?.toString()).toList();

  /// https://redis.io/commands/hset/
  Future<int> hset(
    String key,
    Map<String, String> entries,
  ) async =>
      await cmd.hset(key, entries) as int;

  /// https://redis.io/commands/hdel/
  Future<int> hdel(
    String key,
    List<String> fields,
  ) async =>
      await cmd.hdel(key, fields) as int;

  /// https://redis.io/commands/expire/
  Future<int> pexpire(
    String key,
    Duration duration, [
    String? option,
  ]) async =>
      await cmd.pexpire(key, duration, option) as int;

  /// https://redis.io/commands/scan/
  Future<({int cursor, List<String> results})> scan(int cursor,
          {String? pattern, int? count}) async =>
      _parse.asScanResult(
          await cmd.scan(cursor, pattern: pattern, count: count) as List);

  Transaction multi() => Transaction(cmd);

  Future<Object?> watch(List<String> keys) => cmd.watch(keys);

  Future<Object?> unwatch() => cmd.unwatch();
}
