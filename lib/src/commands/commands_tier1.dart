part of resp_commands;

///
/// The mode when to set a value for a key.
///
enum SetMode {
  onlyIfNotExists,
  onlyIfExists,
}

///
/// The mode how to handle expiration.
///
class ExpireMode {
  final DateTime? timestamp;
  final Duration? time;

  ExpireMode.timestamp(this.timestamp) : time = null;
  ExpireMode.time(this.time) : timestamp = null;
  ExpireMode.keepTtl()
      : timestamp = null,
        time = null;
}

///
/// Where to insert a value.
///
class InsertMode {
  static const before = InsertMode._('BEFORE');
  static const after = InsertMode._('AFTER');

  final String _value;

  const InsertMode._(this._value);
}

///
/// Type of a Redis client.
///
class ClientType {
  static const normal = ClientType._('normal');
  static const master = ClientType._('master');
  static const replica = ClientType._('replica');
  static const pubsub = ClientType._('pubsub');

  final String _value;

  const ClientType._(this._value);
}

///
/// Commands of tier 1 always return a [Object?]. It is up
/// to the consumer to convert the result correctly into the
/// concrete subtype.
///
class RespCommandsTier1 {

  final RespClient client;

  RespCommandsTier1(this.client);

  Future<Object?> info([String? section]) {
    return client.sendObject([
      'INFO',
      if (section != null) section,
    ]);
  }

  Future<Object?> clientList({ClientType? type, List<String> ids = const []}) {
    return client.sendObject([
      'CLIENT',
      'LIST',
      if (type != null) ...['TYPE', type._value],
      if (ids.isNotEmpty) ...['ID', ...ids],
    ]);
  }

  Future<Object?> select(int index) {
    return client.sendObject([
      'SELECT',
      index,
    ]);
  }

  Future<Object?> dbsize() {
    return client.sendObject([
      'DBSIZE',
    ]);
  }

  Future<Object?> auth(String password) {
    return client.sendObject([
      'AUTH',
      password,
    ]);
  }

  Future<Object?> flushDb({bool? doAsync}) {
    return client.sendObject([
      'FLUSHDB',
      if (doAsync != null) doAsync ? 'ASYNC' : 'SYNC',
    ]);
  }

  Future<Object?> flushAll({bool? doAsync}) {
    return client.sendObject([
      'FLUSHALL',
      if (doAsync != null) doAsync ? 'ASYNC' : 'SYNC',
    ]);
  }

  Future<Object?> set(String key, Object value, {ExpireMode? expire, SetMode? mode, bool get = false}) {
    final expireTime = expire?.time;
    final expireTimestamp = expire?.timestamp;
    return client.sendObject([
      'SET',
      key,
      value,
      if (expireTime != null) ...['PX', '${expireTime.inMilliseconds}'],
      if (expireTimestamp != null) ...['PXAT', '${expireTimestamp.millisecondsSinceEpoch}'],
      if (expire != null && expireTime == null && expireTimestamp == null) 'KEEPTTL',
      if (mode == SetMode.onlyIfNotExists) 'NX',
      if (mode == SetMode.onlyIfExists) 'XX',
      if (get) 'GET',
    ]);
  }

  Future<Object?> get(String key) {
    return client.sendObject([
      'GET',
      key,
    ]);
  }

  Future<Object?> del(List<String> keys) {
    return client.sendObject([
      'DEL',
      ...keys,
    ]);
  }

  Future<Object?> exists(List<String> keys) {
    return client.sendObject([
      'EXISTS',
      ...keys,
    ]);
  }

  Future<Object?> ttl(String key) {
    return client.sendObject([
      'TTL',
      key,
    ]);
  }

  Future<Object?> pexpire(String key, Duration timeout) {
    return client.sendObject([
      'PEXPIRE',
      key,
      timeout.inMilliseconds,
    ]);
  }

  Future<Object?> hset(String key, String field, Object value) {
    return client.sendObject([
      'HSET',
      key,
      field,
      value,
    ]);
  }

  Future<Object?> hsetnx(String key, String field, Object value) {
    return client.sendObject([
      'HSETNX',
      key,
      field,
      value,
    ]);
  }

  Future<Object?> hmset(String key, Map<String, String> keysAndValues) {
    return client.sendObject([
      'HMSET',
      key,
      ...keysAndValues.entries.expand((e) => [e.key, e.value]),
    ]);
  }

  Future<Object?> hget(String key, String field) {
    return client.sendObject([
      'HGET',
      key,
      field,
    ]);
  }

  Future<Object?> hgetall(String key) {
    return client.sendObject([
      'HGETALL',
      key,
    ]);
  }

  Future<Object?> hmget(String key, List<String> fields) {
    return client.sendObject([
      'HMGET',
      key,
      ...fields,
    ]);
  }

  Future<Object?> hdel(String key, List<String> fields) {
    return client.sendObject([
      'HDEL',
      key,
      ...fields,
    ]);
  }

  Future<Object?> hexists(String key, String field) {
    return client.sendObject([
      'HEXISTS',
      key,
      field,
    ]);
  }

  Future<Object?> hkeys(String key) {
    return client.sendObject([
      'HKEYS',
      key,
    ]);
  }

  Future<Object?> hvals(String key) {
    return client.sendObject([
      'HVALS',
      key,
    ]);
  }

  Future<Object?> blpop(List<String> keys, int timeout) {
    return client.sendObject([
      'BLPOP',
      ...keys,
      timeout,
    ]);
  }

  Future<Object?> brpop(List<String> keys, int timeout) {
    return client.sendObject([
      'BRPOP',
      ...keys,
      timeout,
    ]);
  }

  Future<Object?> brpoplpush(String source, String destination, int timeout) {
    return client.sendObject([
      'BRPOPLPUSH',
      source,
      destination,
      timeout,
    ]);
  }

  Future<Object?> lindex(String key, int index) {
    return client.sendObject([
      'LINDEX',
      key,
      index,
    ]);
  }

  Future<Object?> linsert(String key, InsertMode insertMode, Object pivot, Object value) {
    return client.sendObject([
      'LINSERT',
      key,
      insertMode._value,
      pivot,
      value,
    ]);
  }

  Future<Object?> llen(String key) {
    return client.sendObject([
      'LLEN',
      key,
    ]);
  }

  Future<Object?> lpop(String key) {
    return client.sendObject([
      'LPOP',
      key,
    ]);
  }

  Future<Object?> lpush(String key, List<Object> values) {
    return client.sendObject([
      'LPUSH',
      key,
      ...values,
    ]);
  }

  Future<Object?> lpushx(String key, List<Object> values) {
    return client.sendObject([
      'LPUSHX',
      key,
      ...values,
    ]);
  }

  Future<Object?> lrange(String key, int start, int stop) {
    return client.sendObject([
      'LRANGE',
      key,
      start,
      stop,
    ]);
  }

  Future<Object?> lrem(String key, int count, Object value) {
    return client.sendObject([
      'LREM',
      key,
      count,
      value,
    ]);
  }

  Future<Object?> lset(String key, int index, Object value) {
    return client.sendObject([
      'LSET',
      key,
      index,
      value,
    ]);
  }

  Future<Object?> ltrim(String key, int start, int stop) {
    return client.sendObject([
      'LTRIM',
      key,
      start,
      stop,
    ]);
  }

  Future<Object?> rpop(String key) {
    return client.sendObject([
      'RPOP',
      key,
    ]);
  }

  Future<Object?> rpoplpush(String source, String destination) {
    return client.sendObject([
      'RPOPLPUSH',
      source,
      destination,
    ]);
  }

  Future<Object?> rpush(String key, List<Object> values) {
    return client.sendObject([
      'RPUSH',
      key,
      ...values,
    ]);
  }

  Future<Object?> rpushx(String key, List<Object> values) {
    return client.sendObject([
      'RPUSHX',
      key,
      ...values,
    ]);
  }

  Future<Object?> incr(String key) {
    return client.sendObject([
      'INCR',
      key,
    ]);
  }

  Future<Object?> incrby(String key, int increment) {
    return client.sendObject([
      'INCRBY',
      key,
      '$increment',
    ]);
  }

  Future<Object?> decr(String key) {
    return client.sendObject([
      'DECR',
      key,
    ]);
  }

  Future<Object?> decrby(String key, int decrement) {
    return client.sendObject([
      'DECRBY',
      key,
      '$decrement',
    ]);
  }

  Future<Object?> scan(int cursor, {String? pattern, int? count}) {
    return client.sendObject([
      'SCAN',
      '$cursor',
      if (pattern != null) ...['MATCH', pattern],
      if (count != null) ...['COUNT', count],
    ]);
  }

  Future<Object?> publish(String channel, Object message) {
    return client.sendObject([
      'PUBLISH',
      channel,
      message,
    ]);
  }

  Future<Object?> subscribe(List<String> channels) {
    return client.sendObject([
      'SUBSCRIBE',
      ...channels,
    ]);
  }

  Future<Object?> unsubscribe(Iterable<String> channels) {
    return client.sendObject([
      'UNSUBSCRIBE',
      ...channels,
    ]);
  }

  Future<Object?> multi() {
    return client.sendObject([
      'MULTI',
    ]);
  }

  Future<Object?> exec() {
    return client.sendObject([
      'EXEC',
    ]);
  }

  Future<Object?> discard() {
    return client.sendObject([
      'DISCARD',
    ]);
  }

  Future<Object?> watch(List<String> keys) {
    return client.sendObject([
      'WATCH',
      ...keys,
    ]);
  }

  Future<Object?> unwatch() {
    return client.sendObject([
      'UNWATCH',
    ]);
  }
}
