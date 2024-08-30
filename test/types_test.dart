import 'dart:async';

import 'package:resp_client/resp_client.dart';
import 'package:resp_client/resp_commands.dart';
import 'package:resp_client/resp_server.dart';
import 'package:test/test.dart';

void main() {
  late final RedisCommands commands;

  setUp(() async {
    commands = RedisCommands(
      RedisCommandMap(
        RespClient(
          await connectSocket('172.17.0.2', port: 6379),
        ),
      ),
    );
  });

  tearDown(() {
    commands.cmd.client.close();
  });

  test('set get string', () async {
    await commands.set('someKey', 'someValue');
    final result = await commands.get('someKey');
    expect(result, equals('someValue'));
  });

  test('get null string', () async {
    expect(await commands.get('null key'), equals(null));
  });

  // This test could be flakey with bad network conditions
  test('test Expires', () async {
    await commands.set('anotherkey', 'someValue',
        px: Duration(milliseconds: 500));
    expect(await commands.get('anotherkey'), equals('someValue'));
    await Future.delayed(Duration(seconds: 1));
    expect(await commands.get('anotherkey'), equals(null));
  });

  test('set bytes', () async {
    final bytes = <int>[
      for (int i = 0; i < 256; i++) i,
    ];
    await commands.setBytes('testBinary', bytes);
    expect(await commands.getBytes('testBinary'), equals(bytes));
  });

  test('set bytes return', () async {
    final bytes = <int>[
      for (int i = 0; i < 256; i++) i,
    ];
    final result = await commands.setBytes('testBinary', bytes, get: true);
    expect(result, equals(bytes));
  });

  test('set bytes return', () async {
    final bytes = <int>[
      for (int i = 0; i < 256; i++) i,
    ];
    final result = await commands.setBytes('testBinary', bytes, get: true);
    expect(result, equals(bytes));
  });

  test('set get maps', () async {
    final testMap = {'a': '123', 'b': 'cows'};
    await commands.hset('map', testMap);
    final result = await commands.hgetall('map');
    expect(result, equals(testMap));
  });
}
