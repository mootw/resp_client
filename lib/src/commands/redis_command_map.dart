part of resp_commands;

/// Implementation of redis commands with a tasteful
/// amount of added typing added to the input
/// the output is still untyped intentionally and will
/// vary depending on conditions, or even error if you send
/// an exec without a multi call for instance. there
/// is almost no safety here.
/// Bulk Strings are NOT decoded here!!!
class RedisCommandMap {
  RespClient client;

  RedisCommandMap(this.client);

  Future<Object?> incr(String key) => client.sendStringCommand(['INCR', key]);

  Future<Object?> ttl(String key) => client.sendStringCommand(['TTL', key]);

  /// Usually a String or List<int> type for bytes
  Future<Object?> set(String key, Object value, {bool? get, Duration? px}) =>
      client.sendCommand([
        'SET',
        key,
        value,
        if (get == true) 'GET',
        if (px != null) 'PX',
        if (px != null) px.inMilliseconds.toString()
      ]);

  Future<Object?> get(String key) => client.sendStringCommand(['GET', key]);

  /// https://redis.io/commands/hgetall/
  /// returns an empty map when the redis reply is empty
  Future<Object?> hgetall(String key) => client.sendStringCommand([
        'HGETALL',
        key,
      ]);

  /// https://redis.io/commands/hgetall/
  /// returns an empty map when the redis reply is empty
  Future<Object?> hmget(String key, Iterable<String> fields) => client.sendStringCommand([
        'HMGET',
        key,
        ...fields,
      ]);

  /// https://redis.io/commands/geoadd/
  Future<Object?> geoadd(
    String key,
    Iterable<({double longitude, double latitude, String member})> items, [
    String? elementOption,
    bool? CH,
  ]) =>
      client.sendStringCommand([
        'GEOADD',
        key,
        if (elementOption != null) elementOption,
        if (CH == true) 'CH',
        for (final item in items) ...[
          item.longitude.toString(),
          item.latitude.toString(),
          item.member,
        ],
      ]);

  /// TODO create generic implementation
  /// https://redis.io/commands/geoadd/
  Future<Object?> geosearchlonlatbbox(
          String key, double lon, double lat, double widthM, double heightM) =>
      client.sendStringCommand([
        'GEOSEARCH',
        key,
        'FROMLONLAT',
        lon.toString(),
        lat.toString(),
        'BYBOX',
        widthM.toString(),
        heightM.toString(),
        'm',
      ]);

  /// https://redis.io/commands/exists/
  Future<Object?> exists(Iterable<String> keys) {
    assert(keys.isNotEmpty);
    return client.sendStringCommand(['EXISTS', ...keys]);
  }

  /// https://redis.io/commands/del/
  Future<Object?> del(Iterable<String> keys) {
    assert(keys.isNotEmpty);
    return client.sendStringCommand(['DEL', ...keys]);
  }

  /// https://redis.io/commands/smembers/
  Future<Object?> smembers(String key) {
    return client.sendStringCommand(['SMEMBERS', key]);
  }

  /// https://redis.io/commands/mget/
  Future<Object?> mget(Iterable<String> keys) {
    assert(keys.isNotEmpty);
    return client.sendStringCommand(['MGET', ...keys]);
  }

  /// https://redis.io/commands/hset/
  Future<Object?> hset(
    String key,
    Map<String, Object> entries,
  ) {
    assert(entries.isNotEmpty);
    return client.sendCommand([
      'HSET',
      key,
      for (final item in entries.entries) ...[item.key, item.value],
    ]);
  }

  /// https://redis.io/commands/hdel/
  Future<Object?> hdel(
    String key,
    Iterable<String> fields,
  ) {
    assert(fields.isNotEmpty);
    return client.sendStringCommand([
      'HDEL',
      key,
      ...fields,
    ]);
  }

  /// https://redis.io/commands/srem/
  Future<Object?> sadd(
    String key,
    Iterable<String> members,
  ) {
    assert(members.isNotEmpty);
    return client.sendStringCommand([
      'SADD',
      key,
      ...members,
    ]);
  }

    /// https://redis.io/commands/srem/
  Future<Object?> srem(
    String key,
    Iterable<String> members,
  ) {
    assert(members.isNotEmpty);
    return client.sendStringCommand([
      'SREM',
      key,
      ...members,
    ]);
  }

  /// https://redis.io/commands/expire/
  Future<Object?> pexpire(
    String key,
    Duration duration, [
    String? option,
  ]) =>
      client.sendStringCommand([
        'PEXPIRE',
        key,
        duration.inMilliseconds.toString(),
        if (option != null) option
      ]);

  Future<Object?> scan(int cursor, {String? pattern, int? count}) {
    return client.sendStringCommand([
      'SCAN',
      cursor.toString(),
      if (pattern != null) ...['MATCH', pattern],
      if (count != null) ...['COUNT', count.toString()],
    ]);
  }

  Future<Object?> multi() => client.sendStringCommand([
        'MULTI',
      ]);

  Future<Object?> exec() => client.sendStringCommand([
        'EXEC',
      ]);

  Future<Object?> watch(Iterable<String> keys) => client.sendStringCommand([
        'WATCH',
        ...keys,
      ]);

  Future<Object?> unwatch() => client.sendStringCommand([
        'UNWATCH',
      ]);
}
