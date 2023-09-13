part of resp_commands;

///Opinionated typing for redis commands
class RedisCommandParser {

  int asInt(Object? response) => response as int;
  
  String? asMaybeString(Object? response) => response as String?;

  Map<String, String> asMap (Object? response) {
    final list = response as List;
    final entries = <MapEntry<String, String>>[];
    for (var i = 0; i < list.length; i += 2) {
      entries
          .add(MapEntry(list[i] as String, list[i + 1] as String));
    }
    return Map<String, String>.fromEntries(entries);
  }

}