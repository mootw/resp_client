part of resp_commands;

/// create a transaction that safely wraps
/// commands to ensure that 2 transactions
/// do not conflict, and that all the commands in the
/// transaction are as expected (no other commands get mixed in)
/// by NOT awaiting. think of it as await safety and includes
/// autoamtic parsing
class Transaction {
  final _parser = RedisCommandParser();
  final _cmds = <({Future<Object?> Function() cmd, Function(Object?) parse})>[];
  final RedisCommandMap _redisMap;

  Transaction(this._redisMap);

  /// queues all of the commands and runs them at once
  /// this prevents accidentally nesting multi calls
  /// or an awaited value in the builder to cause nested
  /// multi chaos
  Future<List<Object?>> exec() async {
    // this "way of doing things" by passing functions in functions
    // makes errors.. difficult.. to handle...
    // but it does provide good safety against accidentally nesting
    // multi calls by accidentially awaiting something
    unawaited(_redisMap.multi());
    for (final command in _cmds) {
      unawaited(command.cmd());
    }
    final result = await _redisMap.exec();
    if (result is RespError) {
      throw result;
    }
    return (result as List)
        .indexed
        .map((e) => _cmds[e.$1].parse(e.$2))
        .toList();
  }

  void incr(String key) => _cmds.add((
        cmd: () => _redisMap.incr(key),
        parse: _parser.asInt,
      ));

  void ttl(String key) => _cmds.add((
        cmd: () => _redisMap.ttl(key),
        parse: _parser.asInt,
      ));

  void get(String key) => _cmds.add((
        cmd: () => _redisMap.get(key),
        parse: _parser.asMaybeString,
      ));

  void set(String key, String value) => _cmds.add((
        cmd: () => _redisMap.set(key, value),
        parse: _parser.asMaybeString,
      ));

  void hgetall(String key) => _cmds.add((
        cmd: () => _redisMap.hgetall(key),
        parse: _parser.asMap,
      ));

  void exists(List<String> keys) => _cmds.add((
        cmd: () => _redisMap.exists(keys),
        parse: _parser.asInt,
      ));

  void pexpire(String key, Duration duration) => _cmds.add((
        cmd: () => _redisMap.pexpire(key, duration),
        parse: _parser.asInt,
      ));
}
