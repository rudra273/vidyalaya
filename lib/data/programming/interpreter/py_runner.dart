import 'py_ast.dart';
import 'py_error.dart';
import 'py_lexer.dart';
import 'py_parser.dart';

// ─── Public API ───────────────────────────────────────────────────────────────
//
// The only surface screens and tests import. [PyRunner.run] lexes, parses and
// evaluates a program, returning captured stdout plus an optional friendly
// error. Execution is async solely so `input()` can await the UI; every other
// step is synchronous, and hard limits keep it safe to run on the UI isolate.

typedef PyInputProvider = Future<String> Function(String prompt);

class PyLimits {
  final int maxSteps; // evaluator ticks before we assume an infinite loop
  final int maxOutputChars; // total printed characters
  final int maxStringLength; // guards `'x' * 1000000`
  final int maxListLength; // guards runaway list growth
  final int maxCallDepth; // guards runaway recursion

  const PyLimits({
    this.maxSteps = 200000,
    this.maxOutputChars = 20000,
    this.maxStringLength = 10000,
    this.maxListLength = 5000,
    this.maxCallDepth = 50,
  });
}

class PyRunResult {
  final String output;
  final PyError? error;
  const PyRunResult(this.output, {this.error});

  bool get ok => error == null;
}

class PyRunner {
  static Future<PyRunResult> run(
    String source, {
    PyInputProvider? onInput,
    List<String> presetInputs = const [],
    PyLimits limits = const PyLimits(),
  }) async {
    final out = StringBuffer();
    try {
      final tokens = Lexer(source).tokenize();
      final program = Parser(tokens).parse();
      final interp = _Interpreter(
        out: out,
        onInput: onInput,
        presetInputs: List.of(presetInputs),
        limits: limits,
      );
      await interp.runProgram(program);
      return PyRunResult(out.toString());
    } on PyError catch (e) {
      return PyRunResult(out.toString(), error: e);
    } on _StopOutput {
      return PyRunResult(out.toString());
    }
  }
}

// ─── Control-flow signals ─────────────────────────────────────────────────────

class _BreakSignal implements Exception {
  const _BreakSignal();
}

class _ContinueSignal implements Exception {
  const _ContinueSignal();
}

class _ReturnSignal implements Exception {
  final Object? value;
  const _ReturnSignal(this.value);
}

/// Raised when the output cap is hit; ends the run cleanly with a note appended.
class _StopOutput implements Exception {
  const _StopOutput();
}

// ─── User-defined function ─────────────────────────────────────────────────────

class _PyFunction {
  final String name;
  final List<String> params;
  final List<Stmt> body;
  const _PyFunction(this.name, this.params, this.body);
}

// ─── Interpreter ──────────────────────────────────────────────────────────────

class _Interpreter {
  final StringBuffer out;
  final PyInputProvider? onInput;
  final List<String> presetInputs;
  final PyLimits limits;

  int _steps = 0;
  int _depth = 0;

  // Scope stack: globals at [0], a new frame pushed per function call.
  final List<Map<String, Object?>> _scopes = [<String, Object?>{}];
  final Map<String, _PyFunction> _functions = {};

  _Interpreter({
    required this.out,
    required this.onInput,
    required this.presetInputs,
    required this.limits,
  });

  Map<String, Object?> get _globals => _scopes.first;
  Map<String, Object?> get _current => _scopes.last;

  Future<void> runProgram(List<Stmt> stmts) async {
    await _execBlock(stmts);
  }

  // ── statements ──────────────────────────────────────────────────────────────

  Future<void> _execBlock(List<Stmt> stmts) async {
    for (final s in stmts) {
      await _exec(s);
    }
  }

  Future<void> _exec(Stmt s) async {
    _tick(s.line);
    switch (s) {
      case ExprStmt():
        await _eval(s.expr);
      case AssignStmt():
        await _execAssign(s);
      case IfStmt():
        await _execIf(s);
      case WhileStmt():
        await _execWhile(s);
      case ForStmt():
        await _execFor(s);
      case FuncDef():
        _functions[s.name] = _PyFunction(s.name, s.params, s.body);
      case ReturnStmt():
        final v = s.value == null ? null : await _eval(s.value!);
        throw _ReturnSignal(v);
      case BreakStmt():
        throw const _BreakSignal();
      case ContinueStmt():
        throw const _ContinueSignal();
    }
  }

  Future<void> _execAssign(AssignStmt s) async {
    final rhs = await _eval(s.value);
    final target = s.target;

    if (target is NameExpr) {
      if (s.op == '=') {
        _current[target.name] = rhs;
      } else {
        final cur = _lookup(target.name, target.line);
        _current[target.name] = _binaryOp(_augOp(s.op), cur, rhs, s.line);
      }
    } else if (target is IndexExpr) {
      final obj = await _eval(target.object);
      final idx = await _eval(target.index);
      if (obj is! List) {
        throw PyError(
          "You can only put things into a list using `[ ]`.",
          line: s.line,
        );
      }
      final i = _listIndex(obj, idx, s.line);
      if (s.op == '=') {
        obj[i] = rhs;
      } else {
        obj[i] = _binaryOp(_augOp(s.op), obj[i], rhs, s.line);
      }
    }
  }

  String _augOp(String op) => op.substring(0, 1); // '+=' -> '+'

  Future<void> _execIf(IfStmt s) async {
    for (final (cond, body) in s.branches) {
      if (_truthy(await _eval(cond))) {
        await _execBlock(body);
        return;
      }
    }
    if (s.elseBody != null) {
      await _execBlock(s.elseBody!);
    }
  }

  Future<void> _execWhile(WhileStmt s) async {
    while (_truthy(await _eval(s.condition))) {
      _tick(s.line);
      try {
        await _execBlock(s.body);
      } on _BreakSignal {
        break;
      } on _ContinueSignal {
        continue;
      }
    }
  }

  Future<void> _execFor(ForStmt s) async {
    final iterable = await _eval(s.iterable);
    final items = _iterate(iterable, s.line);
    for (final item in items) {
      _tick(s.line);
      _current[s.varName] = item;
      try {
        await _execBlock(s.body);
      } on _BreakSignal {
        break;
      } on _ContinueSignal {
        continue;
      }
    }
  }

  List<Object?> _iterate(Object? value, int line) {
    if (value is List) return value;
    if (value is String) return value.split('').cast<Object?>();
    throw PyError(
      "You can only loop over a list or a range() with `for`.",
      line: line,
      hint: "Try `for i in range(5):` or `for x in [1, 2, 3]:`.",
    );
  }

  // ── expressions ───────────────────────────────────────────────────────────

  Future<Object?> _eval(Expr e) async {
    _tick(e.line);
    switch (e) {
      case LiteralExpr():
        return e.value;
      case ListExpr():
        final list = <Object?>[];
        for (final el in e.elements) {
          list.add(await _eval(el));
          _guardListLength(list.length, e.line);
        }
        return list;
      case FStringExpr():
        final buf = StringBuffer();
        for (final part in e.parts) {
          if (part is String) {
            buf.write(part);
          } else {
            buf.write(_pyStr(await _eval(part as Expr)));
          }
        }
        return buf.toString();
      case NameExpr():
        return _lookup(e.name, e.line);
      case UnaryExpr():
        return _unaryOp(e.op, await _eval(e.operand), e.line);
      case LogicalExpr():
        final left = await _eval(e.left);
        if (e.op == 'and') {
          return _truthy(left) ? await _eval(e.right) : left;
        } else {
          return _truthy(left) ? left : await _eval(e.right);
        }
      case BinaryExpr():
        return _binaryOp(e.op, await _eval(e.left), await _eval(e.right),
            e.line);
      case IndexExpr():
        return _evalIndex(await _eval(e.object), await _eval(e.index), e.line);
      case CallExpr():
        return await _evalCall(e);
      case AttrExpr():
        // Attribute access is only meaningful as the callee of a method call.
        throw PyError(
          "`.${e.name}` can only be used to call a method, like "
          "`my_list.append(3)`.",
          line: e.line,
        );
    }
  }

  Object? _evalIndex(Object? obj, Object? index, int line) {
    if (obj is List) {
      return obj[_listIndex(obj, index, line)];
    }
    if (obj is String) {
      final i = _strIndex(obj, index, line);
      return obj[i];
    }
    throw PyError(
      "You can only use `[ ]` on a list or some text.",
      line: line,
    );
  }

  // ── calls & built-ins ───────────────────────────────────────────────────────

  Future<Object?> _evalCall(CallExpr call) async {
    final callee = call.callee;

    // Method calls: obj.method(args)  — only .append is supported.
    if (callee is AttrExpr) {
      final target = await _eval(callee.object);
      final args = <Object?>[];
      for (final a in call.args) {
        args.add(await _eval(a));
      }
      return _callMethod(target, callee.name, args, call.line);
    }

    if (callee is! NameExpr) {
      throw PyError("This doesn't look like something I can call.",
          line: call.line);
    }
    final name = callee.name;

    final args = <Object?>[];
    for (final a in call.args) {
      args.add(await _eval(a));
    }

    // User-defined functions take priority.
    final fn = _functions[name];
    if (fn != null) return await _callUser(fn, args, call.line);

    // Built-ins.
    switch (name) {
      case 'print':
        return _builtinPrint(args);
      case 'len':
        return _builtinLen(args, call.line);
      case 'range':
        return _builtinRange(args, call.line);
      case 'int':
        return _builtinInt(args, call.line);
      case 'float':
        return _builtinFloat(args, call.line);
      case 'str':
        return _builtinStr(args, call.line);
      case 'input':
        return await _builtinInput(args, call.line);
      case 'abs':
        return _builtinAbs(args, call.line);
      case 'min':
        return _builtinMinMax(args, call.line, isMin: true);
      case 'max':
        return _builtinMinMax(args, call.line, isMin: false);
      case 'sum':
        return _builtinSum(args, call.line);
      case 'round':
        return _builtinRound(args, call.line);
      default:
        throw PyError(
          "I don't know a function called `$name`.",
          line: call.line,
          hint: _didYouMean(name, [
            ..._functions.keys,
            'print', 'len', 'range', 'int', 'float', 'str', 'input',
            'abs', 'min', 'max', 'sum', 'round',
          ]),
        );
    }
  }

  Future<Object?> _callUser(
      _PyFunction fn, List<Object?> args, int line) async {
    if (args.length != fn.params.length) {
      throw PyError(
        "`${fn.name}` needs ${fn.params.length} input(s), but you gave "
        "${args.length}.",
        line: line,
      );
    }
    _depth++;
    if (_depth > limits.maxCallDepth) {
      _depth--;
      throw PyError(
        "This function is calling itself too many times and I had to stop. 🌀",
        line: line,
        hint: "Make sure a recursive function has a stopping point.",
      );
    }
    final frame = <String, Object?>{};
    for (var i = 0; i < fn.params.length; i++) {
      frame[fn.params[i]] = args[i];
    }
    _scopes.add(frame);
    try {
      await _execBlock(fn.body);
      return null;
    } on _ReturnSignal catch (r) {
      return r.value;
    } finally {
      _scopes.removeLast();
      _depth--;
    }
  }

  Object? _callMethod(
      Object? target, String method, List<Object?> args, int line) {
    if (method == 'append') {
      if (target is! List) {
        throw PyError("Only lists have `.append()`.", line: line);
      }
      if (args.length != 1) {
        throw PyError(".append() takes exactly one thing to add.",
            line: line);
      }
      _guardListLength(target.length + 1, line);
      target.add(args.first);
      return null;
    }
    throw PyError(
      "`.$method()` isn't one of the methods in our course yet.",
      line: line,
      hint: "You can use `.append()` on lists.",
    );
  }

  // ── built-in implementations ────────────────────────────────────────────────

  Object? _builtinPrint(List<Object?> args) {
    final text = args.map(_pyStr).join(' ');
    _write('$text\n');
    return null;
  }

  Object? _builtinLen(List<Object?> args, int line) {
    _expectArgs('len', args, 1, line);
    final v = args.first;
    if (v is String) return v.length;
    if (v is List) return v.length;
    throw PyError("`len()` works on text and lists.", line: line);
  }

  List<Object?> _builtinRange(List<Object?> args, int line) {
    if (args.isEmpty || args.length > 3) {
      throw PyError("`range()` takes 1, 2, or 3 numbers.", line: line);
    }
    for (final a in args) {
      if (a is! int) {
        throw PyError("`range()` only works with whole numbers.", line: line);
      }
    }
    int start = 0, stop, step = 1;
    if (args.length == 1) {
      stop = args[0] as int;
    } else {
      start = args[0] as int;
      stop = args[1] as int;
      if (args.length == 3) step = args[2] as int;
    }
    if (step == 0) {
      throw PyError("`range()` step can't be 0.", line: line);
    }
    final result = <Object?>[];
    if (step > 0) {
      for (var i = start; i < stop; i += step) {
        result.add(i);
        _guardListLength(result.length, line);
      }
    } else {
      for (var i = start; i > stop; i += step) {
        result.add(i);
        _guardListLength(result.length, line);
      }
    }
    return result;
  }

  Object _builtinInt(List<Object?> args, int line) {
    _expectArgs('int', args, 1, line);
    final v = args.first;
    if (v is int) return v;
    if (v is double) return v.truncate();
    if (v is bool) return v ? 1 : 0;
    if (v is String) {
      final parsed = int.tryParse(v.trim());
      if (parsed == null) {
        throw PyError(
          "I couldn't turn \"$v\" into a whole number.",
          line: line,
          hint: "int() needs text that looks like a number, e.g. \"42\".",
        );
      }
      return parsed;
    }
    throw PyError("int() can't convert that.", line: line);
  }

  double _builtinFloat(List<Object?> args, int line) {
    _expectArgs('float', args, 1, line);
    final v = args.first;
    if (v is num) return v.toDouble();
    if (v is bool) return v ? 1.0 : 0.0;
    if (v is String) {
      final parsed = double.tryParse(v.trim());
      if (parsed == null) {
        throw PyError(
          "I couldn't turn \"$v\" into a number.",
          line: line,
        );
      }
      return parsed;
    }
    throw PyError("float() can't convert that.", line: line);
  }

  String _builtinStr(List<Object?> args, int line) {
    if (args.isEmpty) return '';
    _expectArgs('str', args, 1, line);
    return _pyStr(args.first);
  }

  Future<String> _builtinInput(List<Object?> args, int line) async {
    final prompt = args.isEmpty ? '' : _pyStr(args.first);
    if (prompt.isNotEmpty) _write(prompt);
    if (presetInputs.isNotEmpty) {
      final v = presetInputs.removeAt(0);
      _write('$v\n');
      return v;
    }
    if (onInput != null) {
      final v = await onInput!(prompt);
      _write('$v\n');
      return v;
    }
    throw PyError(
      "This program asked for input, but none was available.",
      line: line,
    );
  }

  num _builtinAbs(List<Object?> args, int line) {
    _expectArgs('abs', args, 1, line);
    final v = args.first;
    if (v is int) return v.abs();
    if (v is double) return v.abs();
    throw PyError("abs() works on numbers.", line: line);
  }

  Object? _builtinMinMax(List<Object?> args, int line, {required bool isMin}) {
    final name = isMin ? 'min' : 'max';
    List<Object?> items;
    if (args.length == 1 && args.first is List) {
      items = args.first as List<Object?>;
    } else {
      items = args;
    }
    if (items.isEmpty) {
      throw PyError("$name() needs at least one number.", line: line);
    }
    Object? best;
    for (final it in items) {
      if (it is! num) {
        throw PyError("$name() works on numbers.", line: line);
      }
      if (best == null ||
          (isMin ? it < (best as num) : it > (best as num))) {
        best = it;
      }
    }
    return best;
  }

  num _builtinSum(List<Object?> args, int line) {
    _expectArgs('sum', args, 1, line);
    final v = args.first;
    if (v is! List) {
      throw PyError("sum() needs a list of numbers.", line: line);
    }
    num total = 0;
    for (final it in v) {
      if (it is! num) {
        throw PyError("sum() only adds up numbers.", line: line);
      }
      total += it;
    }
    return total;
  }

  Object _builtinRound(List<Object?> args, int line) {
    if (args.isEmpty || args.length > 2) {
      throw PyError("round() takes a number (and an optional digit count).",
          line: line);
    }
    final v = args.first;
    if (v is! num) {
      throw PyError("round() works on numbers.", line: line);
    }
    if (args.length == 1) return v.round();
    final digits = args[1];
    if (digits is! int) {
      throw PyError("The second input to round() must be a whole number.",
          line: line);
    }
    final factor = _pow(10, digits);
    return (v * factor).round() / factor;
  }

  // ── operators ────────────────────────────────────────────────────────────

  Object? _unaryOp(String op, Object? v, int line) {
    if (op == 'not') return !_truthy(v);
    // '-'
    if (v is int) return -v;
    if (v is double) return -v;
    throw PyError("You can only put `-` in front of a number.", line: line);
  }

  Object? _binaryOp(String op, Object? a, Object? b, int line) {
    switch (op) {
      case '==':
        return _equals(a, b);
      case '!=':
        return !_equals(a, b);
      case '<':
      case '<=':
      case '>':
      case '>=':
        return _compare(op, a, b, line);
      case '+':
        return _add(a, b, line);
      case '-':
        return _subtract(a, b, line);
      case '*':
        return _multiply(a, b, line);
      case '/':
        return _divide(a, b, line);
      case '//':
        return _floorDiv(a, b, line);
      case '%':
        return _modulo(a, b, line);
      case '**':
        return _power(a, b, line);
      default:
        throw PyError("I don't understand the operator `$op`.", line: line);
    }
  }

  Object _add(Object? a, Object? b, int line) {
    if (a is num && b is num) return _numResult(a + b, a, b);
    if (a is String && b is String) {
      final r = a + b;
      _guardStringLength(r.length, line);
      return r;
    }
    if (a is List && b is List) {
      final r = [...a, ...b];
      _guardListLength(r.length, line);
      return r;
    }
    if (a is String || b is String) {
      throw PyError(
        "You can't add words and numbers together directly.",
        line: line,
        hint: "Turn the number into text first with str(), like "
            "\"Age: \" + str(age).",
      );
    }
    throw PyError("I can't add those two things together.", line: line);
  }

  Object _multiply(Object? a, Object? b, int line) {
    if (a is num && b is num) return _numResult(a * b, a, b);
    // string * int (either order)
    if (a is String && b is int) return _repeat(a, b, line);
    if (a is int && b is String) return _repeat(b, a, line);
    if (a is List && b is int) return _repeatList(a, b, line);
    if (a is int && b is List) return _repeatList(b, a, line);
    throw PyError("I can't multiply those two things.", line: line);
  }

  String _repeat(String s, int n, int line) {
    if (n <= 0) return '';
    final total = s.length * n;
    _guardStringLength(total, line);
    return s * n;
  }

  List<Object?> _repeatList(List a, int n, int line) {
    if (n <= 0) return <Object?>[];
    _guardListLength(a.length * n, line);
    final r = <Object?>[];
    for (var i = 0; i < n; i++) {
      r.addAll(a);
    }
    return r;
  }

  Object _subtract(Object? a, Object? b, int line) {
    if (a is! num || b is! num) {
      throw PyError("`-` only works between two numbers.", line: line);
    }
    return _numResult(a - b, a, b);
  }

  double _divide(Object? a, Object? b, int line) {
    if (a is! num || b is! num) {
      throw PyError("`/` only works between two numbers.", line: line);
    }
    if (b == 0) {
      throw PyError("Dividing by zero breaks mathematics — and my brain! 🤯",
          line: line);
    }
    return a / b;
  }

  Object _floorDiv(Object? a, Object? b, int line) {
    if (a is! num || b is! num) {
      throw PyError("`//` only works between two numbers.", line: line);
    }
    if (b == 0) {
      throw PyError("You can't divide by zero.", line: line);
    }
    final r = (a / b).floor();
    return (a is int && b is int) ? r : r.toDouble();
  }

  Object _modulo(Object? a, Object? b, int line) {
    if (a is! num || b is! num) {
      throw PyError("`%` only works between two numbers.", line: line);
    }
    if (b == 0) {
      throw PyError("You can't find the remainder when dividing by zero.",
          line: line);
    }
    final r = a % b;
    return _numResult(r, a, b);
  }

  Object _power(Object? a, Object? b, int line) {
    if (a is! num || b is! num) {
      throw PyError("`**` only works between two numbers.", line: line);
    }
    if (b is int && b > 200) {
      throw PyError("That power is too big for me to work out. 💥", line: line);
    }
    final r = _pow(a, b);
    return (a is int && b is int && b >= 0) ? r.toInt() : r;
  }

  bool _compare(String op, Object? a, Object? b, int line) {
    if (a is num && b is num) {
      switch (op) {
        case '<':
          return a < b;
        case '<=':
          return a <= b;
        case '>':
          return a > b;
        case '>=':
          return a >= b;
      }
    }
    if (a is String && b is String) {
      final c = a.compareTo(b);
      switch (op) {
        case '<':
          return c < 0;
        case '<=':
          return c <= 0;
        case '>':
          return c > 0;
        case '>=':
          return c >= 0;
      }
    }
    throw PyError(
      "I can only compare numbers with numbers, or text with text.",
      line: line,
    );
  }

  bool _equals(Object? a, Object? b) {
    if (a is num && b is num) return a == b;
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_equals(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }

  // ── value helpers ────────────────────────────────────────────────────────

  bool _truthy(Object? v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.isNotEmpty;
    if (v is List) return v.isNotEmpty;
    return true;
  }

  /// Python-style display: True/False, no ".0" stripping (2.0 stays "2.0"),
  /// lists shown with repr-style elements.
  String _pyStr(Object? v) {
    if (v == null) return 'None';
    if (v is bool) return v ? 'True' : 'False';
    if (v is double) return _formatDouble(v);
    if (v is String) return v;
    if (v is List) {
      return '[${v.map(_pyRepr).join(', ')}]';
    }
    return v.toString();
  }

  String _pyRepr(Object? v) {
    if (v is String) return "'$v'";
    return _pyStr(v);
  }

  String _formatDouble(double d) {
    if (d.isInfinite) return d.isNegative ? '-inf' : 'inf';
    if (d.isNaN) return 'nan';
    if (d == d.truncateToDouble() && d.abs() < 1e16) {
      return '${d.toInt()}.0';
    }
    return d.toString();
  }

  Object _numResult(num r, num a, num b) {
    if (a is int && b is int && r is int) return r;
    if (a is int && b is int) return r.toInt();
    return r.toDouble();
  }

  int _listIndex(List list, Object? index, int line) {
    if (index is! int) {
      throw PyError("List positions must be whole numbers.", line: line);
    }
    var i = index;
    if (i < 0) i += list.length;
    if (i < 0 || i >= list.length) {
      throw PyError(
        "There's nothing at position $index in this list "
        "(it has ${list.length} item(s)).",
        line: line,
        hint: "Positions start at 0, so a list of ${list.length} goes up to "
            "${list.length - 1}.",
      );
    }
    return i;
  }

  int _strIndex(String s, Object? index, int line) {
    if (index is! int) {
      throw PyError("Text positions must be whole numbers.", line: line);
    }
    var i = index;
    if (i < 0) i += s.length;
    if (i < 0 || i >= s.length) {
      throw PyError(
        "There's no letter at position $index (the text has ${s.length}).",
        line: line,
      );
    }
    return i;
  }

  Object? _lookup(String name, int line) {
    if (_current.containsKey(name)) return _current[name];
    if (_globals.containsKey(name)) return _globals[name];
    if (_functions.containsKey(name)) {
      throw PyError(
        "`$name` is a function — did you forget the `()` to call it?",
        line: line,
      );
    }
    throw PyError(
      "I've never seen `$name` before.",
      line: line,
      hint: _didYouMean(name, [
        ..._current.keys,
        ..._globals.keys,
        ..._functions.keys,
      ]),
    );
  }

  // ── limits ─────────────────────────────────────────────────────────────────

  void _tick(int line) {
    if (++_steps > limits.maxSteps) {
      throw PyError(
        "Your program ran for too long, so I stopped it. 🛑",
        line: line,
        hint: "Maybe a loop never ends? Check your `while` condition or "
            "make sure a counter changes.",
      );
    }
  }

  void _write(String text) {
    out.write(text);
    if (out.length > limits.maxOutputChars) {
      out.write('\n… (that\'s a lot of printing — I stopped here!)');
      throw const _StopOutput();
    }
  }

  void _guardStringLength(int len, int line) {
    if (len > limits.maxStringLength) {
      throw PyError(
        "That piece of text is too long for me to make. ✂️",
        line: line,
      );
    }
  }

  void _guardListLength(int len, int line) {
    if (len > limits.maxListLength) {
      throw PyError(
        "That list is getting too big for me to hold. 📦",
        line: line,
      );
    }
  }

  void _expectArgs(String name, List<Object?> args, int n, int line) {
    if (args.length != n) {
      throw PyError(
        "`$name()` takes $n input(s), but you gave ${args.length}.",
        line: line,
      );
    }
  }

  // ── small utilities ──────────────────────────────────────────────────────

  num _pow(num base, num exp) {
    // Integer fast path keeps small powers exact.
    if (base is int && exp is int && exp >= 0) {
      int r = 1;
      for (var i = 0; i < exp; i++) {
        r *= base;
      }
      return r;
    }
    double r = 1;
    final e = exp.toInt();
    final b = base.toDouble();
    if (e >= 0) {
      for (var i = 0; i < e; i++) {
        r *= b;
      }
    } else {
      for (var i = 0; i < -e; i++) {
        r *= b;
      }
      r = 1 / r;
    }
    return r;
  }

  /// Levenshtein-based "did you mean" for typo'd names. The environment is tiny
  /// so this is cheap and delights kids ("Did you mean `name`?").
  String? _didYouMean(String name, Iterable<String> candidates) {
    String? best;
    int bestDist = 3; // only suggest within edit distance 2
    for (final c in candidates.toSet()) {
      if (c == name) continue;
      final d = _editDistance(name, c);
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    return best == null ? null : "Did you mean `$best`?";
  }

  int _editDistance(String a, String b) {
    final m = a.length, n = b.length;
    final prev = List<int>.generate(n + 1, (i) => i);
    final cur = List<int>.filled(n + 1, 0);
    for (var i = 1; i <= m; i++) {
      cur[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        cur[j] = [
          cur[j - 1] + 1,
          prev[j] + 1,
          prev[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      for (var j = 0; j <= n; j++) {
        prev[j] = cur[j];
      }
    }
    return prev[n];
  }
}
