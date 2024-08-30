import 'package:resp_client/resp_client.dart';
import 'package:resp_client/resp_commands.dart';
import 'package:resp_client/resp_server.dart';

void main(List<String> args) async {

  final commands = RedisCommands(
      RedisCommandMap(
        RespClient(
          await connectSocket('172.17.0.2', port: 6379),
        ),
      ),
    );

    await commands.set(
        'myKey',
        'THE VALUE OF MY KEY!',
        px: const Duration(hours: 8),
      );

  // execute a command
  final result = await commands.cmd.client.sendStringCommand(['GET', 'myKey']);

  print(result.toString());

  // close connection to the server
  await commands.cmd.client.close();
}
