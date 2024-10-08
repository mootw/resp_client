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

  final transaction = commands.multi();
  transaction.incr('someCoolKey');
  transaction.pexpire(
    'someCoolKey',
    const Duration(days: 2),
  );
  final result = await transaction.exec();
  final incrResult = result[0]! as int;

  print(incrResult);

  // close connection to the server
  await commands.cmd.client.close();
}
