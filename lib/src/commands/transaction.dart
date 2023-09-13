part of resp_commands;

/// useb by RedisCommands to
/// create a transaction that safely wraps
/// commands to ensure that 2 transactions
/// do not conflict, and that all the commands in the
/// transaction are as expected (no other commands get mixed in)
/// by NOT awaiting. think of it as await safety...
class Transaction {
  final _parser = RedisCommandParser();

  final RedisCommandMap _commands;

  Transaction(this._commands);

  final items = <({Function caller, Function(Object?) parse})>[];

  final parsers = <Function>[];

  /// queues all of the commands and runs them at once
  /// this prevents accidentally nesting multi calls
  Future<List<Object?>> exec() async {
    // TODO this "way of doing things" explicitly makes errors..
    // difficult.. to handle...
    unawaited(_commands.multi());
    for (final command in items) {
      command.caller();
    }
    final result = await _commands.exec();
    if (result is RespError) {
      throw result;
    }
    return (result as List)
        .indexed
        .map((e) => items[e.$1].parse(e.$2))
        .toList();
  }

  //This is potentially a more "builder" method of doing it
  //would need to call multi before starting the transaction though
  //which is fine! Potentially this can allow for override behavior
  //too like a generic "call redis command thing.."
  //another upside is there is stronger typing here, we arent caling
  //2 functions as parameters, just 1!
  //TODO LOOK AT THIS PLEASE!!!!
  void incrALTERNATE(String key) {
    parsers.add(_parser.asInt);
    _commands.incr(key);
  }

  void incr(String key) => items.add((
        caller: () => _commands.incr(key),
        parse: _parser.asInt,
      ));

  void ttl(String key) => items.add((
        caller: () => _commands.ttl(key),
        parse: _parser.asInt,
      ));

  void get(String key) => items.add((
        caller: () => _commands.get(key),
        parse: _parser.asMaybeString,
      ));

  void set(String key, String value) => items.add((
        caller: () => _commands.set(key, value),
        parse: _parser.asMaybeString,
      ));

  void hgetall(String key) => items.add((
        caller: () => _commands.hgetall(key),
        parse: _parser.asMap,
      ));
}
