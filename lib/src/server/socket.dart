part of resp_server;

///
/// Creates a server connection using a socket.
///
Future<Socket> connectSocket(String host, {int port = 6379, Duration? timeout}) async {
  return await Socket.connect(host, port, timeout: timeout);
}
