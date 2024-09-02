import 'dart:async';
import 'dart:math';

import 'package:resp_client/resp_client.dart';
import 'package:resp_client/resp_commands.dart';
import 'package:resp_client/resp_server.dart';
import 'package:test/test.dart';

void main() {
  late RedisCommands commands;

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


  test('set get', () async {
    await commands.set('key1', 'value1');
    await commands.set('key2', 'value2');
    await commands.setBytes('key3', [0, 255]);
    final result = await commands.mget(['key1', 'key2', 'key3']);

    expect(result, equals('someValue'));
  });

  test('set get', () async {
    await commands.set('someKey', 'someValue');
    final result = await commands.get('someKey');
    expect(result, equals('someValue'));
  });

  test('get null string', () async {
    expect(await commands.get('null key'), equals(null));
  });

  // This test could be flakey with bad network conditions
  test('set px', () async {
    await commands.set('anotherkey', 'someValue',
        px: Duration(milliseconds: 500));
    expect(await commands.get('anotherkey'), equals('someValue'));
    await Future.delayed(Duration(seconds: 1));
    expect(await commands.get('anotherkey'), equals(null));
  });

  test('setBytes getBytes', () async {
    final bytes = <int>[
      for (int i = 0; i < 256; i++) i,
    ];
    await commands.setBytes('testBinary', bytes);
    expect(await commands.getBytes('testBinary'), equals(bytes));
  });

  test('setBytes return', () async {
    final bytes = <int>[
      for (int i = 0; i < 256; i++) i,
    ];
    final result = await commands.setBytes('testBinary', bytes, get: true);
    expect(result, equals(BinaryString(bytes)));
  });

  test('hset hgetall', () async {
    final testMap = {'a': '123', 'b': 'cows'};
    await commands.hset('map', testMap);
    final result = await commands.hgetall('map');
    expect(result, equals(testMap));
  });

  test('multi', () async {
    final tx = commands.multi();
    tx.set('cow', 'yes');
    tx.get('cow');
    final result = await tx.exec();
    expect(result[1], equals('yes'));
  });

  test('geosearch by index', () async {
    await commands
        .geoadd('locations', [(latitude: 0, longitude: 0, member: 'pig')]);
    final res = await commands.geosearchbylonlatbbox(
        'locations', -0.001, -0.001, 1000, 1000);
    expect(res.length, equals(1));
    expect(res[0], equals('pig'));
  });

  test('hset hmget', () async {
    final testMap = {'a': '123', 'b': 'cows'};
    final key = 'somecoolmap';
    await commands.hset(key, testMap);
    expect(await commands.hmget(key, testMap.keys.toList()),
        equals(testMap.values));
    expect(await commands.hmget(key, [testMap.keys.first]),
        equals([testMap.values.first]));
  });

  test('scan', () async {
    final keys = [for (var i = 0; i < 100; i++) 'biglistofkeys$i'];

    //Add the keys
    final tx = commands.multi();
    for (final key in keys) {
      tx.set(key, 'somevalue');
    }
    final result = await tx.exec();

    var cursor = 0;
    var results = <String>[];
    while (cursor != -1) {
      final result =
          await commands.scan(cursor, count: 10, pattern: 'biglistofkeys*');
      results.addAll(result.results);
      cursor = result.cursor;
      if (cursor == 0) {
        cursor = -1;
      }
    }
    // Return order is not guaranteed from scan, so we use sets
    expect(Set.from(results), equals(Set.from(keys)));
    // remove the keys
    final delResult = await commands.del(keys);
    expect(delResult, equals(keys.length));
  });
}
