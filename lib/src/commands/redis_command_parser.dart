part of resp_commands;

///Opinionated parsing/typing for redis command responses
class RedisCommandParser {
  int asInt(Object? response) => response as int;

  List<String>? asStringList(Object? response) =>
      (response as List?)?.map((e) => e.toString()).toList();

  String? asMaybeString(Object? response) => response?.toString();

  Map<String, String> asMap(Object? response) {
    final list = response as List;
    final entries = <MapEntry<String, String>>[];
    for (var i = 0; i < list.length; i += 2) {
      entries.add(MapEntry(list[i].toString(), list[i + 1].toString()));
    }
    return Map<String, String>.fromEntries(entries);
  }

  ({int cursor, List<String> results}) asScanResult(List list) => (
        cursor: int.parse(list[0].toString()),
        results:
            List<BinaryString>.from(list[1]).map((e) => e.toString()).toList(),
      );
}
