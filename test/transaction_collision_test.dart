  () async {
    //Collision attempt
    final transcation = connection.multi();
    transcation.set('cows', 'multi');
    transcation.get('cows');
    transcation.incr('number');
    print("in tx 1");
    transcation.hgetall('testhm');
    transcation.ttl('number');
    final result = await transcation.exec();
    print(result);
  }();

  () async {
    //Collision attempt
    final transcation = connection.multi();
    transcation.set('cows', await Future(() => "multi4"));
    transcation.get('cows');
    transcation.incr('number');
    transcation.ttl('number');
    transcation.hgetall('testhm');
    final result = await transcation.exec();
    print(result);
  }();

  () async {
    //Collision attempt
    final transcation = connection.multi();
    transcation.set('cows', 'multi2');
    transcation.get('cows');
    transcation.incr('number');
    transcation.ttl('number');
    transcation.hgetall('testhm');
    final result = await transcation.exec();
    print(result);
  }();

  final transcation = connection.multi();
  transcation.set('cows', 'multi3');
  transcation.get('cows');
  transcation.hgetall('testhm');
  transcation.incr('number');
  transcation.ttl('number');
  final result = await transcation.exec();

  print(result);
  result.forEach((element) {
    print(element.runtimeType);
  });

  print(
    await connection.hset(
      'testhm',
      {
        "a": "b",
        "b": 23.toString(),
      }.entries,
    ),
  );

  print(
    await connection.hgetall(
      'testhm',
    ),
  );

  print(await connection.set('cows', '🐸'));
  print(await connection.get('cows'));