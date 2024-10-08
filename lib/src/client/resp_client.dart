part of resp_client;

///
/// The client for a RESP server.
///
class RespClient {
  final Socket _connection;
  final StreamReader _streamReader;
  final Queue<Completer> _pendingResponses = Queue();
  bool _isProccessingResponse = false;
  Queue sendQueue = Queue();

  RespClient(this._connection) : _streamReader = StreamReader(_connection);

  ///
  /// Writes a Object to the server using the
  /// [outputSink] of the underlying server connection and
  /// reads back the Object of the response using the
  /// [inputStream] of the underlying server connection.
  /// the type of the response will vary. see: types.dart
  ///
  Future<Object?> sendCommand(Object data) {
    final completer = Completer<Object?>();
    _pendingResponses.add(completer);
    _connection.add(serializeObject(data));
    _processResponse(false);
    return completer.future;
  }

  /// type wrapper for sendObject that ensures that only strings
  /// are sent to the redis connection (redis expects a list of bulk strings)
  Future<Object?> sendStringCommand(Iterable<String> data) => sendCommand(data);

  Stream<Object?> subscribe() {
    final controller = StreamController<Object?>();
    deserializeRespType(_streamReader).then((response) {
      controller.add(response);
    });
    return controller.stream;
  }

  Future close () => _connection.close();

  void _processResponse(bool selfCall) {
    if (_isProccessingResponse == false || selfCall) {
      if (_pendingResponses.isNotEmpty) {
        _isProccessingResponse = true;
        final c = _pendingResponses.removeFirst();
        deserializeRespType(_streamReader).then((response) {
          c.complete(response);
          _processResponse(true);
        });
      } else {
        _isProccessingResponse = false;
      }
    }
  }
}
