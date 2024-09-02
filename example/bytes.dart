import 'dart:convert';

import 'package:resp_client/resp_client.dart';
import 'package:resp_client/resp_commands.dart';
import 'package:resp_client/resp_server.dart';

void main(List<String> args) async {

  final bytes = <int>[
    for(int i = 0; i < 256; i++)
    i,
  ];

  final commands = RedisCommands(
      RedisCommandMap(
        RespClient(
          await connectSocket('172.17.0.2', port: 6379),
        ),
      ),
    );

    await commands.setBytes('testBinary', bytes);

    final after = await commands.getBytes('testBinary');
    print(after);

    final b = await commands.getBytes('null key');
    print(b);

  // close connection to the server
  await commands.cmd.client.close();
}
