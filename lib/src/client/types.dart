part of resp_client;

/// Implementation of a RESP error.
/// TODO make this a proper error type to return in the future..
/// since this is a runtime error, etc.. etc.. have
class RespError {
  final String message;
  const RespError(this.message);
}

/// Redis Bulk String
class BinaryString {
  final List<int> bytes;

  BinaryString(this.bytes);

  BinaryString.fromString(String string) : bytes = utf8.encode(string);

  @override
  String toString() => utf8.decode(bytes);

  /// Implicitly have binary string return its toString method when accessed
  String call() => toString();

  @override
  bool operator ==(Object other) =>
      other is BinaryString && ListEquality().equals(bytes, other.bytes);
}

Future<Object?> deserializeRespType(StreamReader streamReader) async {
  final typePrefix = await streamReader.takeOne();
  switch (typePrefix) {
    case _plus: // simple string
      final payload =
          utf8.decode(await streamReader.takeWhile((data) => data != _charCR));
      await streamReader.takeCount(2);
      return payload;
    case 0x2d: // error
      final payload =
          utf8.decode(await streamReader.takeWhile((data) => data != _charCR));
      await streamReader.takeCount(2);
      print(payload);
      return RespError(payload);
    case 0x3a: // integer
      final payload = int.parse(
          utf8.decode(await streamReader.takeWhile((data) => data != _charCR)));
      await streamReader.takeCount(2);
      return payload;
    case 0x24: // bulk string
      final length = int.parse(
          utf8.decode(await streamReader.takeWhile((data) => data != _charCR)));
      await streamReader.takeCount(2);
      if (length == -1) {
        return null; //null bulk string
      }
      final payload = BinaryString(await streamReader.takeCount(length));
      await streamReader.takeCount(2);
      return payload;
    case _asterisk: // array
      final count = int.parse(
          utf8.decode(await streamReader.takeWhile((data) => data != _charCR)));
      await streamReader.takeCount(2);
      if (count == -1) {
        return null; // null array https://redis.io/docs/reference/protocol-spec/#nulls
      }
      final elements = <dynamic>[];
      for (var i = 0; i < count; i++) {
        elements.add(await deserializeRespType(streamReader));
      }
      return elements;
    default:
      throw StateError('unexpected character: $typePrefix');
  }
}

final _respNullArray = utf8.encode(
    '\*-1$_CRLF'); // https://redis.io/docs/reference/protocol-spec/#nulls

const int _plus = 0x2b; // +
const int _asterisk = 0x2a; // *
const int _charCR = 0x0d; // \r
final _dollar = utf8.encode('\$');
final List<int> _CRLF = utf8.encode('\r\n');
final List<int> _colon = utf8.encode(':');
final _nullBulkString = utf8.encode('\$-1');

List<int> serializeObject(Object? object) {
  if (object is List<int>) {
    // It is binary data
    return [
      ..._dollar,
      ...utf8.encode(object.length.toString()),
      ..._CRLF,
      ...object,
      ..._CRLF
    ];
  } else if (object is String) {
    //serialize a string
    final encodedObject = utf8.encode(object);
    return [
      ..._dollar,
      ...utf8.encode(encodedObject.length.toString()),
      ..._CRLF,
      ...encodedObject,
      ..._CRLF
    ];
  } else if (object is int) {
    return [
      ..._colon,
      ...utf8.encode(object.toString()),
      ..._CRLF,
    ];
    // } else if (object is BinaryString) {
    // if (object.bytes == null) {
    //   // TODO see if this is actually a null impl
    //   return _respNullArray;
    // }
    // return [
    //   ..._dollar,
    //   ...utf8.encode(object.bytes!.length.toString()),
    //   ..._CRLF,
    //   ...object.bytes!,
    //   ..._CRLF
    // ];
  } else if (object is Iterable) {
    return [
      _asterisk,
      ...utf8.encode(object.length.toString()),
      ..._CRLF,
      ...object.expand((item) => serializeObject(item)),
      ..._CRLF,
    ];
  } else if (object == null) {
    return _nullBulkString;
  }
  throw 'cannot serialize type ${object.runtimeType}';
}
