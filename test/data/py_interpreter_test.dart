import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/programming/interpreter/py_runner.dart';

/// Runs [src] and returns stdout, failing the test if the program errored.
Future<String> run(String src, {List<String> inputs = const []}) async {
  final result = await PyRunner.run(src, presetInputs: inputs);
  if (!result.ok) {
    fail('Program errored unexpectedly: ${result.error}\n--- source ---\n$src');
  }
  return result.output;
}

/// Runs [src] expecting an error, returning it.
Future<PyRunResult> runExpectingError(String src,
    {List<String> inputs = const []}) async {
  final result = await PyRunner.run(src, presetInputs: inputs);
  expect(result.error, isNotNull,
      reason: 'Expected an error but program ran fine.\nsource:\n$src');
  return result;
}

void main() {
  group('print & strings', () {
    test('hello world', () async {
      expect(await run("print('Hello, World!')"), 'Hello, World!\n');
    });
    test('double quotes', () async {
      expect(await run('print("hi")'), 'hi\n');
    });
    test('multiple args space-joined', () async {
      expect(await run("print('a', 'b', 'c')"), 'a b c\n');
    });
    test('print numbers', () async {
      expect(await run('print(42)'), '42\n');
    });
    test('print with numbers and strings', () async {
      expect(await run("print('x', 1, True)"), 'x 1 True\n');
    });
    test('escape sequences', () async {
      expect(await run(r"print('a\nb')"), 'a\nb\n');
    });
    test('empty print', () async {
      expect(await run('print()'), '\n');
    });
    test('string concat', () async {
      expect(await run("print('foo' + 'bar')"), 'foobar\n');
    });
    test('string repeat', () async {
      expect(await run("print('ab' * 3)"), 'ababab\n');
    });
    test('star line', () async {
      expect(await run("print('*' * 5)"), '*****\n');
    });
    test('string indexing', () async {
      expect(await run("print('hello'[1])"), 'e\n');
    });
    test('negative string index', () async {
      expect(await run("print('hello'[-1])"), 'o\n');
    });
  });

  group('numbers & arithmetic', () {
    test('addition', () async {
      expect(await run('print(2 + 3)'), '5\n');
    });
    test('subtraction', () async {
      expect(await run('print(10 - 4)'), '6\n');
    });
    test('multiplication', () async {
      expect(await run('print(6 * 7)'), '42\n');
    });
    test('true division always float', () async {
      expect(await run('print(7 / 2)'), '3.5\n');
    });
    test('even division still float', () async {
      expect(await run('print(6 / 2)'), '3.0\n');
    });
    test('floor division', () async {
      expect(await run('print(7 // 2)'), '3\n');
    });
    test('modulo', () async {
      expect(await run('print(7 % 3)'), '1\n');
    });
    test('power', () async {
      expect(await run('print(2 ** 10)'), '1024\n');
    });
    test('precedence', () async {
      expect(await run('print(2 + 3 * 4)'), '14\n');
    });
    test('parentheses', () async {
      expect(await run('print((2 + 3) * 4)'), '20\n');
    });
    test('negative numbers', () async {
      expect(await run('print(-5 + 2)'), '-3\n');
    });
    test('float printing keeps .0', () async {
      expect(await run('print(2.0)'), '2.0\n');
    });
    test('float arithmetic', () async {
      expect(await run('print(1.5 + 2.5)'), '4.0\n');
    });
    test('mixed int float', () async {
      expect(await run('print(3 + 0.5)'), '3.5\n');
    });
  });

  group('variables & assignment', () {
    test('basic', () async {
      expect(await run('x = 5\nprint(x)'), '5\n');
    });
    test('reassignment', () async {
      expect(await run('x = 1\nx = 2\nprint(x)'), '2\n');
    });
    test('use in expression', () async {
      expect(await run('a = 3\nb = 4\nprint(a + b)'), '7\n');
    });
    test('augmented add', () async {
      expect(await run('x = 5\nx += 3\nprint(x)'), '8\n');
    });
    test('augmented subtract', () async {
      expect(await run('x = 10\nx -= 4\nprint(x)'), '6\n');
    });
    test('augmented multiply', () async {
      expect(await run('x = 2\nx *= 5\nprint(x)'), '10\n');
    });
    test('string variable', () async {
      expect(await run("name = 'Asha'\nprint('Hi ' + name)"), 'Hi Asha\n');
    });
  });

  group('comparisons & logic', () {
    test('equals', () async {
      expect(await run('print(3 == 3)'), 'True\n');
    });
    test('not equals', () async {
      expect(await run('print(3 != 4)'), 'True\n');
    });
    test('less than', () async {
      expect(await run('print(2 < 5)'), 'True\n');
    });
    test('greater equal', () async {
      expect(await run('print(5 >= 5)'), 'True\n');
    });
    test('and', () async {
      expect(await run('print(True and False)'), 'False\n');
    });
    test('or', () async {
      expect(await run('print(False or True)'), 'True\n');
    });
    test('not', () async {
      expect(await run('print(not False)'), 'True\n');
    });
    test('chained logic', () async {
      expect(await run('print(2 < 3 and 3 < 4)'), 'True\n');
    });
    test('string comparison', () async {
      expect(await run("print('apple' < 'banana')"), 'True\n');
    });
  });

  group('if / elif / else', () {
    test('if true', () async {
      expect(await run("if 5 > 3:\n    print('yes')"), 'yes\n');
    });
    test('if false skips', () async {
      expect(await run("if 1 > 3:\n    print('no')"), '');
    });
    test('if else', () async {
      expect(await run("if False:\n    print('a')\nelse:\n    print('b')"),
          'b\n');
    });
    test('elif chain', () async {
      const src = '''
score = 85
if score >= 90:
    print("A")
elif score >= 80:
    print("B")
else:
    print("C")
''';
      expect(await run(src), 'B\n');
    });
    test('nested if', () async {
      const src = '''
x = 10
if x > 5:
    if x > 8:
        print("big")
''';
      expect(await run(src), 'big\n');
    });
  });

  group('for loops & range', () {
    test('range(n)', () async {
      expect(await run('for i in range(3):\n    print(i)'), '0\n1\n2\n');
    });
    test('range(start, stop)', () async {
      expect(await run('for i in range(2, 5):\n    print(i)'), '2\n3\n4\n');
    });
    test('range(start, stop, step)', () async {
      expect(await run('for i in range(0, 10, 2):\n    print(i)'),
          '0\n2\n4\n6\n8\n');
    });
    test('range countdown', () async {
      expect(await run('for i in range(3, 0, -1):\n    print(i)'), '3\n2\n1\n');
    });
    test('empty range', () async {
      expect(await run('for i in range(5, 1):\n    print(i)'), '');
    });
    test('multiplication table', () async {
      const src = '''
for i in range(1, 4):
    print(7 * i)
''';
      expect(await run(src), '7\n14\n21\n');
    });
    test('star triangle', () async {
      const src = '''
for i in range(1, 4):
    print("*" * i)
''';
      expect(await run(src), '*\n**\n***\n');
    });
    test('loop over list', () async {
      expect(await run('for x in [10, 20, 30]:\n    print(x)'),
          '10\n20\n30\n');
    });
    test('accumulator', () async {
      const src = '''
total = 0
for i in range(1, 5):
    total += i
print(total)
''';
      expect(await run(src), '10\n');
    });
  });

  group('while / break / continue', () {
    test('basic while', () async {
      const src = '''
i = 0
while i < 3:
    print(i)
    i += 1
''';
      expect(await run(src), '0\n1\n2\n');
    });
    test('break', () async {
      const src = '''
i = 0
while True:
    if i == 2:
        break
    print(i)
    i += 1
''';
      expect(await run(src), '0\n1\n');
    });
    test('continue', () async {
      const src = '''
for i in range(5):
    if i % 2 == 0:
        continue
    print(i)
''';
      expect(await run(src), '1\n3\n');
    });
    test('countdown', () async {
      const src = '''
n = 3
while n > 0:
    print(n)
    n -= 1
print("Liftoff!")
''';
      expect(await run(src), '3\n2\n1\nLiftoff!\n');
    });
  });

  group('lists', () {
    test('literal & print', () async {
      expect(await run('print([1, 2, 3])'), '[1, 2, 3]\n');
    });
    test('string list repr', () async {
      expect(await run("print(['a', 'b'])"), "['a', 'b']\n");
    });
    test('indexing', () async {
      expect(await run('nums = [10, 20, 30]\nprint(nums[1])'), '20\n');
    });
    test('negative index', () async {
      expect(await run('nums = [10, 20, 30]\nprint(nums[-1])'), '30\n');
    });
    test('index assignment', () async {
      expect(await run('nums = [1, 2, 3]\nnums[0] = 99\nprint(nums)'),
          '[99, 2, 3]\n');
    });
    test('append', () async {
      const src = '''
nums = [1, 2]
nums.append(3)
print(nums)
''';
      expect(await run(src), '[1, 2, 3]\n');
    });
    test('len of list', () async {
      expect(await run('print(len([5, 6, 7]))'), '3\n');
    });
    test('build list in loop', () async {
      const src = '''
squares = []
for i in range(1, 4):
    squares.append(i * i)
print(squares)
''';
      expect(await run(src), '[1, 4, 9]\n');
    });
    test('sum of list', () async {
      expect(await run('print(sum([1, 2, 3, 4]))'), '10\n');
    });
  });

  group('functions', () {
    test('no return', () async {
      const src = '''
def greet():
    print("Hi!")
greet()
''';
      expect(await run(src), 'Hi!\n');
    });
    test('with params and return', () async {
      const src = '''
def add(a, b):
    return a + b
print(add(2, 3))
''';
      expect(await run(src), '5\n');
    });
    test('is_even', () async {
      const src = '''
def is_even(n):
    return n % 2 == 0
print(is_even(4))
print(is_even(7))
''';
      expect(await run(src), 'True\nFalse\n');
    });
    test('local scope does not leak', () async {
      const src = '''
def f():
    x = 5
    return x
print(f())
''';
      expect(await run(src), '5\n');
    });
    test('recursion (factorial)', () async {
      const src = '''
def fact(n):
    if n <= 1:
        return 1
    return n * fact(n - 1)
print(fact(5))
''';
      expect(await run(src), '120\n');
    });
    test('function calling function', () async {
      const src = '''
def square(x):
    return x * x
def sum_squares(a, b):
    return square(a) + square(b)
print(sum_squares(3, 4))
''';
      expect(await run(src), '25\n');
    });
  });

  group('f-strings', () {
    test('simple interpolation', () async {
      expect(await run("name = 'Ravi'\nprint(f'Hi {name}!')"), 'Hi Ravi!\n');
    });
    test('expression inside', () async {
      expect(await run("print(f'{2 + 3}')"), '5\n');
    });
    test('multiple fields', () async {
      const src = '''
a = 3
b = 4
print(f'{a} + {b} = {a + b}')
''';
      expect(await run(src), '3 + 4 = 7\n');
    });
    test('literal braces', () async {
      expect(await run(r"print(f'{{literal}}')"), '{literal}\n');
    });
  });

  group('built-ins', () {
    test('int() from string', () async {
      expect(await run("print(int('42') + 1)"), '43\n');
    });
    test('str() of number', () async {
      expect(await run("print('n=' + str(5))"), 'n=5\n');
    });
    test('float() from string', () async {
      expect(await run("print(float('2.5'))"), '2.5\n');
    });
    test('len of string', () async {
      expect(await run("print(len('hello'))"), '5\n');
    });
    test('abs', () async {
      expect(await run('print(abs(-7))'), '7\n');
    });
    test('max', () async {
      expect(await run('print(max(3, 9, 5))'), '9\n');
    });
    test('min of list', () async {
      expect(await run('print(min([4, 2, 8]))'), '2\n');
    });
    test('round', () async {
      expect(await run('print(round(3.7))'), '4\n');
    });
    test('round with digits', () async {
      expect(await run('print(round(3.14159, 2))'), '3.14\n');
    });
  });

  group('input()', () {
    test('single input', () async {
      // A supplied input is echoed to output (like typing at a terminal).
      expect(
        await run("name = input()\nprint('Hi ' + name)", inputs: ['Asha']),
        'Asha\nHi Asha\n',
      );
    });
    test('input with prompt echoes prompt', () async {
      final r = await PyRunner.run(
        "x = input('Name? ')\nprint(x)",
        presetInputs: ['Bob'],
      );
      expect(r.output, 'Name? Bob\nBob\n');
    });
    test('int(input())', () async {
      const src = '''
age = int(input())
print(age + 1)
''';
      expect(await run(src, inputs: ['12']), '12\n13\n');
    });
  });

  group('edge cases', () {
    test('empty program', () async {
      expect(await run(''), '');
    });
    test('comment only', () async {
      expect(await run('# just a comment'), '');
    });
    test('blank lines between statements', () async {
      expect(await run('print(1)\n\n\nprint(2)'), '1\n2\n');
    });
    test('trailing newline', () async {
      expect(await run('print(1)\n'), '1\n');
    });
    test('inline comment', () async {
      expect(await run("print(1)  # this prints one"), '1\n');
    });
    test('multi-line list literal', () async {
      const src = '''
nums = [
    1,
    2,
    3,
]
print(len(nums))
''';
      expect(await run(src), '3\n');
    });
  });

  group('friendly errors', () {
    test('missing colon on if', () async {
      final r = await runExpectingError("if True\n    print('x')");
      expect(r.error!.message.toLowerCase(), contains('colon'));
    });
    test('unknown variable with suggestion', () async {
      final r = await runExpectingError('name = 5\nprint(nmae)');
      expect(r.error!.hint, contains('name'));
    });
    test('division by zero', () async {
      final r = await runExpectingError('print(5 / 0)');
      expect(r.error!.message.toLowerCase(), contains('zero'));
    });
    test('string plus number', () async {
      final r = await runExpectingError("print('age: ' + 5)");
      expect(r.error!.hint, contains('str('));
    });
    test('unclosed string', () async {
      final r = await runExpectingError("print('hello)");
      expect(r.error!.message.toLowerCase(), contains('quote'));
    });
    test('unknown function', () async {
      final r = await runExpectingError('prnt(5)');
      expect(r.error, isNotNull);
    });
    test('not-yet keyword import', () async {
      final r = await runExpectingError('import math');
      expect(r.error!.message.toLowerCase(), contains('course'));
    });
    test('list index out of range', () async {
      final r = await runExpectingError('nums = [1, 2]\nprint(nums[5])');
      expect(r.error!.message.toLowerCase(), contains('position'));
    });
    test('error still keeps partial output', () async {
      final r = await PyRunner.run("print('before')\nprint(1 / 0)");
      expect(r.output, contains('before'));
      expect(r.error, isNotNull);
    });
    test('calling function without parens', () async {
      final r = await runExpectingError('def f():\n    return 1\nprint(f)');
      expect(r.error!.message, contains('()'));
    });
    test('empty indented block missing', () async {
      final r = await runExpectingError('if True:\nprint(1)');
      expect(r.error, isNotNull);
    });
  });

  group('safety limits', () {
    test('infinite loop is stopped', () async {
      final r = await PyRunner.run('while True:\n    x = 1');
      expect(r.error, isNotNull);
      expect(r.error!.message.toLowerCase(), contains('too long'));
    });
    test('infinite printing is stopped cleanly', () async {
      final r = await PyRunner.run("while True:\n    print('x')");
      // Either the output cap or step cap fires; both end without hanging.
      expect(r.output.length, greaterThan(0));
    });
    test('huge string repeat blocked', () async {
      final r = await PyRunner.run("print('x' * 9999999)");
      expect(r.error, isNotNull);
    });
    test('deep recursion blocked', () async {
      const src = '''
def f(n):
    return f(n + 1)
f(0)
''';
      final r = await PyRunner.run(src);
      expect(r.error, isNotNull);
    });
    test('normal program well under step limit', () async {
      const src = '''
total = 0
for i in range(100):
    total += i
print(total)
''';
      expect(await run(src), '4950\n');
    });
  });
}
