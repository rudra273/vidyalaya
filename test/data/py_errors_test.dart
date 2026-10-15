import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/programming/interpreter/py_runner.dart';

void main() {
  test('safety limits cannot be swallowed by try/except', () async {
    final r = await PyRunner.run(
      'try:\n    while True:\n        pass\nexcept:\n    print("caught")',
    );
    expect(r.error, isNotNull);
    expect(r.output, isNot(contains('caught')));
  });

  test('an unmatched except lets the error through', () async {
    final r = await PyRunner.run(
      'try:\n    print(1 / 0)\nexcept ValueError:\n    print("wrong handler")',
    );
    expect(r.error?.kind, 'ZeroDivisionError');
  });

  test('unknown error names get a friendly message', () async {
    final r = await PyRunner.run('try:\n    x = 1\nexcept Oops:\n    pass');
    // Only checked when an error actually has to be matched.
    expect(r.error, isNull);
    final r2 = await PyRunner.run('try:\n    1 / 0\nexcept Oops:\n    pass');
    expect(r2.error?.message, contains('Oops'));
  });

  test('random needs an import first', () async {
    final r = await PyRunner.run('print(random.randint(1, 6))');
    expect(r.error?.message, contains('import random'));
  });

  test('other imports are still not in the course', () async {
    final r = await PyRunner.run('import math');
    expect(r.error?.message.toLowerCase(), contains('course'));
  });

  test('a seed makes runs repeat', () async {
    const src = 'import random\nrandom.seed(5)\nprint(random.randint(1, 100))';
    final a = await PyRunner.run(src);
    final b = await PyRunner.run(src);
    expect(a.output, b.output);
  });

  test('missing key and bad index errors explain themselves', () async {
    final k = await PyRunner.run('d = {"a": 1}\nprint(d["b"])');
    expect(k.error?.kind, 'KeyError');
    final i = await PyRunner.run('print([1][3])');
    expect(i.error?.kind, 'IndexError');
  });
}
