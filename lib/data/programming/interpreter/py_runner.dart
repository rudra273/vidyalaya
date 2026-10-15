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
  final int maxLoopIterations; // times any single for/while loop may repeat

  const PyLimits({
    this.maxSteps = 200000,
    this.maxOutputChars = 20000,
    this.maxStringLength = 10000,
    this.maxListLength = 5000,
    this.maxCallDepth = 50,
    this.maxLoopIterations = 10000,
  });
}

class PyRunResult {
  final String output;
  final PyError? error;

  /// True when the run was interrupted by the user's Stop button (Ctrl+C).
  final bool stopped;

  const PyRunResult(this.output, {this.error, this.stopped = false});

  bool get ok => error == null;
}

/// A one-shot cancel flag the caller flips to interrupt a run, like Ctrl+C.
/// The interpreter periodically checks it (and yields to the event loop so the
/// flag can actually change mid-run) and stops cleanly when it's set.
class PyCancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class PyRunner {
  static Future<PyRunResult> run(
    String source, {
    PyInputProvider? onInput,
    List<String> presetInputs = const [],
    PyLimits limits = const PyLimits(),
    PyCancelToken? cancelToken,

    /// Seeds `random` so a run is repeatable. Left out, each run differs.
    int? randomSeed,
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
        cancelToken: cancelToken,
        randomSeed: randomSeed,
      );
      await interp.runProgram(program);
      return PyRunResult(out.toString());
    } on PyError catch (e) {
      return PyRunResult(out.toString(), error: e);
    } on _StopOutput {
      return PyRunResult(out.toString());
    } on _Cancelled {
      return PyRunResult(out.toString(), stopped: true);
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

/// Raised when the user's Stop button (cancel token) interrupts the run.
class _Cancelled implements Exception {
  const _Cancelled();
}

// ─── Tuples, dict views and random ────────────────────────────────────────────

/// An immutable sequence. Equal tuples compare and hash equal, so they work
/// as dictionary keys.
class _PyTuple {
  final List<Object?> items;
  const _PyTuple(this.items);

  @override
  bool operator ==(Object other) {
    if (other is! _PyTuple || other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);
}

/// What `d.keys()`, `d.values()` and `d.items()` return: a read-only snapshot
/// that prints like Python's `dict_keys([...])`.
class _PyView {
  final String name;
  final List<Object?> items;
  const _PyView(this.name, this.items);
}

/// CPython's Mersenne Twister, so a seeded run prints exactly what real
/// Python prints for the same `random.seed(n)`.
class _PyRandom {
  final List<int> _mt = List.filled(624, 0);
  int _index = 625;

  _PyRandom(int seed) {
    this.seed(seed);
  }

  void seed(int n) {
    var v = n.abs();
    final key = <int>[];
    if (v == 0) key.add(0);
    while (v > 0) {
      key.add(v & 0xffffffff);
      v >>= 32;
    }
    _initGenrand(19650218);
    var i = 1, j = 0;
    for (var k = key.length > 624 ? key.length : 624; k > 0; k--) {
      final prev = _mt[i - 1] ^ (_mt[i - 1] >> 30);
      _mt[i] =
          ((_mt[i] ^ ((1664525 * prev) & 0xffffffff)) + key[j] + j) &
          0xffffffff;
      i++;
      j++;
      if (i >= 624) {
        _mt[0] = _mt[623];
        i = 1;
      }
      if (j >= key.length) j = 0;
    }
    for (var k = 623; k > 0; k--) {
      final prev = _mt[i - 1] ^ (_mt[i - 1] >> 30);
      _mt[i] = ((_mt[i] ^ ((1566083941 * prev) & 0xffffffff)) - i) & 0xffffffff;
      i++;
      if (i >= 624) {
        _mt[0] = _mt[623];
        i = 1;
      }
    }
    _mt[0] = 0x80000000;
    _index = 624;
  }

  void _initGenrand(int s) {
    _mt[0] = s & 0xffffffff;
    for (var i = 1; i < 624; i++) {
      final prev = _mt[i - 1] ^ (_mt[i - 1] >> 30);
      _mt[i] = (1812433253 * prev + i) & 0xffffffff;
    }
  }

  int _next32() {
    if (_index >= 624) {
      for (var k = 0; k < 624; k++) {
        final y = (_mt[k] & 0x80000000) | (_mt[(k + 1) % 624] & 0x7fffffff);
        var v = _mt[(k + 397) % 624] ^ (y >> 1);
        if (y & 1 != 0) v ^= 0x9908b0df;
        _mt[k] = v;
      }
      _index = 0;
    }
    var y = _mt[_index++];
    y ^= y >> 11;
    y ^= (y << 7) & 0x9d2c5680;
    y ^= (y << 15) & 0xefc60000;
    y ^= y >> 18;
    return y & 0xffffffff;
  }

  /// A float in [0, 1), built the way CPython builds it.
  double random() {
    final a = _next32() >> 5, b = _next32() >> 6;
    return (a * 67108864.0 + b) / 9007199254740992.0;
  }

  /// An int in [0, n). Mirrors `Random._randbelow`.
  int below(int n) {
    if (n <= 1) return 0;
    final k = n.bitLength;
    int r;
    do {
      r = _next32() >> (32 - k);
    } while (r >= n);
    return r;
  }
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
  final PyCancelToken? cancelToken;
  final _PyRandom _rng;
  final Set<String> _imported = {};

  // Tracks wall-clock time so loops can hand the UI thread back roughly every
  // frame — that's what keeps the Stop button painted and tappable mid-run.
  final Stopwatch _clock = Stopwatch()..start();
  int _lastYieldMs = 0;

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
    required this.cancelToken,
    int? randomSeed,
  }) : _rng = _PyRandom(
         randomSeed ?? DateTime.now().microsecondsSinceEpoch & 0x7fffffff,
       );

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
      case PassStmt():
        break;
      case ImportStmt():
        _imported.add(s.module);
      case UnpackStmt():
        await _execUnpack(s);
      case TryStmt():
        await _execTry(s);
      case RaiseStmt():
        await _execRaise(s);
    }
  }

  Future<void> _execUnpack(UnpackStmt s) async {
    final value = await _eval(s.value);
    final items = _unpackItems(value, s.targets.length, s.line);
    for (var i = 0; i < s.targets.length; i++) {
      _current[s.targets[i]] = items[i];
    }
  }

  List<Object?> _unpackItems(Object? value, int count, int line) {
    final items = (value is _PyTuple || value is List || value is String)
        ? _iterate(value, line)
        : null;
    if (items == null) {
      throw PyError(
        "I can't split that into $count names.",
        line: line,
        kind: 'TypeError',
      );
    }
    if (items.length != count) {
      throw PyError(
        "There are ${items.length} values but $count names to put them in.",
        line: line,
        kind: 'ValueError',
        pyMessage: items.length > count
            ? 'too many values to unpack (expected $count)'
            : 'not enough values to unpack (expected $count, got '
                  '${items.length})',
      );
    }
    return items;
  }

  static const _errorNames = {
    'Exception',
    'ArithmeticError',
    'LookupError',
    'ZeroDivisionError',
    'ValueError',
    'TypeError',
    'NameError',
    'IndexError',
    'KeyError',
  };

  bool _matches(PyError e, List<String> types, int line) {
    if (e.kind == kLimitError) return false; // safety limits can't be caught
    if (types.isEmpty) return true;
    for (final t in types) {
      if (!_errorNames.contains(t)) {
        throw PyError(
          "I don't know an error called `$t`.",
          line: line,
          hint:
              "Try `ValueError`, `ZeroDivisionError`, `TypeError`, "
              "`IndexError`, `KeyError` or `Exception`.",
        );
      }
      if (t == 'Exception' || t == e.kind) return true;
      if (t == 'ArithmeticError' && e.kind == 'ZeroDivisionError') return true;
      if (t == 'LookupError' &&
          (e.kind == 'IndexError' || e.kind == 'KeyError')) {
        return true;
      }
    }
    return false;
  }

  Future<void> _execTry(TryStmt s) async {
    try {
      var handled = false;
      try {
        await _execBlock(s.body);
      } on PyError catch (e) {
        ExceptClause? chosen;
        for (final h in s.handlers) {
          if (_matches(e, h.types, h.line)) {
            chosen = h;
            break;
          }
        }
        if (chosen == null) rethrow;
        handled = true;
        if (chosen.asName != null) {
          _current[chosen.asName!] = e.pyMessage ?? e.message;
        }
        await _execBlock(chosen.body);
      }
      if (!handled && s.elseBody != null) await _execBlock(s.elseBody!);
    } finally {
      if (s.finallyBody != null) await _execBlock(s.finallyBody!);
    }
  }

  Future<void> _execRaise(RaiseStmt s) async {
    if (!_errorNames.contains(s.kind)) {
      throw PyError(
        "I don't know an error called `${s.kind}`.",
        line: s.line,
        hint:
            "Try `ValueError`, `ZeroDivisionError`, `TypeError` or "
            "`Exception`.",
      );
    }
    final text = s.message == null ? '' : _pyStr(await _eval(s.message!));
    throw PyError(
      text.isEmpty ? '${s.kind} was raised.' : text,
      line: s.line,
      kind: s.kind,
      pyMessage: text,
    );
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
      if (obj is Map) {
        _checkHashable(idx, s.line);
        if (s.op == '=') {
          if (!obj.containsKey(idx)) _guardListLength(obj.length + 1, s.line);
          obj[idx] = rhs;
        } else {
          if (!obj.containsKey(idx)) throw _keyError(idx, s.line);
          obj[idx] = _binaryOp(_augOp(s.op), obj[idx], rhs, s.line);
        }
        return;
      }
      if (obj is! List) {
        throw PyError(
          "You can only put things into a list or a dictionary using `[ ]`.",
          line: s.line,
          kind: 'TypeError',
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
    var iterations = 0;
    while (_truthy(await _eval(s.condition))) {
      _tick(s.line);
      _guardLoop(++iterations, s.line);
      await _pump(iterations);
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
    var iterations = 0;
    for (final item in items) {
      _tick(s.line);
      _guardLoop(++iterations, s.line);
      await _pump(iterations);
      if (s.targets.length == 1) {
        _current[s.targets.first] = item;
      } else {
        final parts = _unpackItems(item, s.targets.length, s.line);
        for (var i = 0; i < s.targets.length; i++) {
          _current[s.targets[i]] = parts[i];
        }
      }
      try {
        await _execBlock(s.body);
      } on _BreakSignal {
        break;
      } on _ContinueSignal {
        continue;
      }
    }
  }

  // Called once per loop iteration. Throws [_Cancelled] the moment the user
  // hits Stop, and hands the UI thread back roughly once per frame (~16ms) so a
  // Stop tap can actually be delivered mid-loop — otherwise a tight loop hogs
  // the thread, the button never even paints, and the flag can never flip.
  // Time-based (not iteration-based) so it stays responsive whether each
  // iteration is trivial or heavy.
  Future<void> _pump(int iterations) async {
    if (cancelToken?.isCancelled ?? false) throw const _Cancelled();
    // Yield when ~a frame has elapsed, with an iteration-count fallback so a
    // yield point is guaranteed even if the clock barely moves (keeps this
    // deterministically testable without depending on wall-clock timing).
    final now = _clock.elapsedMilliseconds;
    if (now - _lastYieldMs >= 16 || iterations % 2000 == 0) {
      _lastYieldMs = now;
      await Future<void>.delayed(Duration.zero);
      if (cancelToken?.isCancelled ?? false) throw const _Cancelled();
    }
  }

  List<Object?> _iterate(Object? value, int line) {
    if (value is List) return value;
    if (value is String) return value.split('').cast<Object?>();
    if (value is _PyTuple) return value.items;
    if (value is _PyView) return value.items;
    if (value is Map) return value.keys.toList();
    throw PyError(
      "You can only loop over a list, text, a dictionary or a range() "
      "with `for`.",
      kind: 'TypeError',
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
      case TupleExpr():
        final items = <Object?>[];
        for (final el in e.elements) {
          items.add(await _eval(el));
        }
        return _PyTuple(items);
      case DictExpr():
        final map = <Object?, Object?>{};
        for (final (k, v) in e.entries) {
          final key = await _eval(k);
          _checkHashable(key, e.line);
          map[key] = await _eval(v);
          _guardListLength(map.length, e.line);
        }
        return map;
      case SliceExpr():
        return _slice(
          await _eval(e.object),
          e.start == null ? null : await _eval(e.start!),
          e.stop == null ? null : await _eval(e.stop!),
          e.line,
        );
      case FStringExpr():
        final buf = StringBuffer();
        for (final part in e.parts) {
          if (part is String) {
            buf.write(part);
          } else if (part is FStringField) {
            buf.write(_formatValue(await _eval(part.expr), part.spec, e.line));
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
        return _binaryOp(
          e.op,
          await _eval(e.left),
          await _eval(e.right),
          e.line,
        );
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
    if (obj is _PyTuple) {
      return obj.items[_listIndex(obj.items, index, line)];
    }
    if (obj is Map) {
      _checkHashable(index, line);
      if (!obj.containsKey(index)) throw _keyError(index, line);
      return obj[index];
    }
    if (obj is String) {
      final i = _strIndex(obj, index, line);
      return obj[i];
    }
    throw PyError(
      "You can only use `[ ]` on a list, a tuple, a dictionary or some text.",
      line: line,
      kind: 'TypeError',
    );
  }

  Object? _slice(Object? obj, Object? start, Object? stop, int line) {
    final int length;
    if (obj is List) {
      length = obj.length;
    } else if (obj is String) {
      length = obj.length;
    } else if (obj is _PyTuple) {
      length = obj.items.length;
    } else {
      throw PyError(
        "You can only slice a list, a tuple or some text.",
        line: line,
        kind: 'TypeError',
      );
    }
    int bound(Object? v, int fallback) {
      if (v == null) return fallback;
      if (v is! int) {
        throw PyError(
          "Slice positions must be whole numbers.",
          line: line,
          kind: 'TypeError',
        );
      }
      var i = v < 0 ? v + length : v;
      if (i < 0) i = 0;
      if (i > length) i = length;
      return i;
    }

    final a = bound(start, 0), b = bound(stop, length);
    final hi = b < a ? a : b;
    if (obj is List) return obj.sublist(a, hi);
    if (obj is String) return obj.substring(a, hi);
    return _PyTuple((obj as _PyTuple).items.sublist(a, hi));
  }

  PyError _keyError(Object? key, int line) => PyError(
    "There's no key ${_pyRepr(key)} in this dictionary.",
    line: line,
    hint: "Check the spelling, or use `.get()` to avoid this error.",
    kind: 'KeyError',
    pyMessage: _pyRepr(key),
  );

  void _checkHashable(Object? key, int line) {
    if (key is List || key is Map) {
      throw PyError(
        "A list or dictionary can't be used as a dictionary key.",
        line: line,
        kind: 'TypeError',
        pyMessage: "unhashable type: '${key is List ? 'list' : 'dict'}'",
      );
    }
  }

  // ── calls & built-ins ───────────────────────────────────────────────────────

  Future<Object?> _evalCall(CallExpr call) async {
    final callee = call.callee;

    final kwargs = <String, Object?>{};
    for (final (name, expr) in call.kwargs) {
      kwargs[name] = await _eval(expr);
    }

    // Method calls: obj.method(args), or module calls like random.randint().
    if (callee is AttrExpr) {
      final obj = callee.object;
      if (obj is NameExpr &&
          obj.name == 'random' &&
          !_current.containsKey('random') &&
          !_globals.containsKey('random')) {
        final args = <Object?>[];
        for (final a in call.args) {
          args.add(await _eval(a));
        }
        return _randomCall(callee.name, args, call.line);
      }
      final target = await _eval(obj);
      final args = <Object?>[];
      for (final a in call.args) {
        args.add(await _eval(a));
      }
      return _callMethod(target, callee.name, args, call.line, kwargs);
    }

    if (callee is! NameExpr) {
      throw PyError(
        "This doesn't look like something I can call.",
        line: call.line,
      );
    }
    final name = callee.name;

    final args = <Object?>[];
    for (final a in call.args) {
      args.add(await _eval(a));
    }

    // User-defined functions take priority.
    final fn = _functions[name];
    if (fn != null) {
      if (kwargs.isNotEmpty) {
        throw PyError(
          "`${fn.name}` can't take `name=value` inputs in our course yet.",
          line: call.line,
        );
      }
      return await _callUser(fn, args, call.line);
    }

    // Built-ins.
    switch (name) {
      case 'print':
        return _builtinPrint(args, kwargs, call.line);
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
      case 'list':
        return _builtinList(args, call.line);
      case 'tuple':
        return _PyTuple([..._builtinList(args, call.line)]);
      case 'dict':
        return _builtinDict(args, call.line);
      case 'sorted':
        return _builtinSorted(args, kwargs, call.line);
      case 'enumerate':
        return _builtinEnumerate(args, call.line);
      case 'zip':
        return _builtinZip(args, call.line);
      case 'bool':
        _expectArgs('bool', args, 1, call.line);
        return _truthy(args.first);
      default:
        throw PyError(
          "I don't know a function called `$name`.",
          line: call.line,
          hint: _didYouMean(name, [
            ..._functions.keys,
            'print',
            'len',
            'range',
            'int',
            'float',
            'str',
            'input',
            'abs',
            'min',
            'max',
            'sum',
            'round',
            'list',
            'tuple',
            'dict',
            'sorted',
            'enumerate',
            'zip',
            'bool',
          ]),
        );
    }
  }

  Future<Object?> _callUser(
    _PyFunction fn,
    List<Object?> args,
    int line,
  ) async {
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
        "This function is calling itself too many times and I had to stop.",
        line: line,
        kind: kLimitError,
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
    Object? target,
    String method,
    List<Object?> args,
    int line, [
    Map<String, Object?> kwargs = const {},
  ]) {
    if (target is List) return _listMethod(target, method, args, line, kwargs);
    if (target is String) return _stringMethod(target, method, args, line);
    if (target is Map) return _dictMethod(target, method, args, line);
    if (target is _PyTuple) return _tupleMethod(target, method, args, line);
    throw PyError(
      "That kind of value has no `.$method()` in our course.",
      line: line,
      kind: 'TypeError',
    );
  }

  Never _noMethod(String kind, String method, int line, String options) {
    throw PyError(
      "`.$method()` isn't one of the $kind methods in our course yet.",
      line: line,
      hint: "You can use $options.",
      kind: 'TypeError',
    );
  }

  Object? _listMethod(
    List<Object?> list,
    String method,
    List<Object?> args,
    int line,
    Map<String, Object?> kwargs,
  ) {
    switch (method) {
      case 'append':
        _expectArgs('.append', args, 1, line);
        _guardListLength(list.length + 1, line);
        list.add(args.first);
        return null;
      case 'extend':
        _expectArgs('.extend', args, 1, line);
        final more = _iterate(args.first, line);
        _guardListLength(list.length + more.length, line);
        list.addAll(more);
        return null;
      case 'insert':
        _expectArgs('.insert', args, 2, line);
        final at = args[0];
        if (at is! int) {
          throw PyError(
            "The position for `.insert()` must be a whole number.",
            line: line,
            kind: 'TypeError',
          );
        }
        _guardListLength(list.length + 1, line);
        var i = at < 0 ? at + list.length : at;
        i = i.clamp(0, list.length);
        list.insert(i, args[1]);
        return null;
      case 'remove':
        _expectArgs('.remove', args, 1, line);
        final i = list.indexWhere((x) => _equals(x, args.first));
        if (i == -1) {
          throw PyError(
            "That item isn't in the list, so I can't remove it.",
            line: line,
            kind: 'ValueError',
            pyMessage: 'list.remove(x): x not in list',
          );
        }
        list.removeAt(i);
        return null;
      case 'pop':
        if (list.isEmpty) {
          throw PyError(
            "You can't pop from an empty list.",
            line: line,
            kind: 'IndexError',
            pyMessage: 'pop from empty list',
          );
        }
        if (args.isEmpty) return list.removeLast();
        _expectArgs('.pop', args, 1, line);
        return list.removeAt(_listIndex(list, args.first, line));
      case 'index':
        _expectArgs('.index', args, 1, line);
        final i = list.indexWhere((x) => _equals(x, args.first));
        if (i == -1) {
          throw PyError(
            "That item isn't in the list.",
            line: line,
            kind: 'ValueError',
          );
        }
        return i;
      case 'count':
        _expectArgs('.count', args, 1, line);
        return list.where((x) => _equals(x, args.first)).length;
      case 'reverse':
        _expectArgs('.reverse', args, 0, line);
        final r = list.reversed.toList();
        list.setAll(0, r);
        return null;
      case 'sort':
        _expectArgs('.sort', args, 0, line);
        final sorted = _sortedCopy(list, _truthy(kwargs['reverse']), line);
        list.setAll(0, sorted);
        return null;
      default:
        _noMethod(
          'list',
          method,
          line,
          '`.append()`, `.insert()`, `.remove()`, `.pop()`, `.sort()`, '
              '`.reverse()`, `.count()` or `.index()`',
        );
    }
  }

  Object? _stringMethod(
    String text,
    String method,
    List<Object?> args,
    int line,
  ) {
    String strArg(int i) {
      final v = args[i];
      if (v is! String) {
        throw PyError(
          "`.$method()` needs text here.",
          line: line,
          kind: 'TypeError',
        );
      }
      return v;
    }

    switch (method) {
      case 'upper':
        _expectArgs('.upper', args, 0, line);
        return text.toUpperCase();
      case 'lower':
        _expectArgs('.lower', args, 0, line);
        return text.toLowerCase();
      case 'capitalize':
        _expectArgs('.capitalize', args, 0, line);
        return text.isEmpty
            ? text
            : text[0].toUpperCase() + text.substring(1).toLowerCase();
      case 'title':
        _expectArgs('.title', args, 0, line);
        return text.replaceAllMapped(
          RegExp(r"[A-Za-z]+"),
          (m) => m[0]![0].toUpperCase() + m[0]!.substring(1).toLowerCase(),
        );
      case 'strip':
      case 'lstrip':
      case 'rstrip':
        final chars = args.isEmpty ? null : strArg(0);
        var start = 0, end = text.length;
        bool strippable(String c) =>
            chars == null ? c.trim().isEmpty : chars.contains(c);
        if (method != 'rstrip') {
          while (start < end && strippable(text[start])) {
            start++;
          }
        }
        if (method != 'lstrip') {
          while (end > start && strippable(text[end - 1])) {
            end--;
          }
        }
        return text.substring(start, end);
      case 'replace':
        _expectArgs('.replace', args, 2, line);
        final r = text.replaceAll(strArg(0), strArg(1));
        _guardStringLength(r.length, line);
        return r;
      case 'find':
        _expectArgs('.find', args, 1, line);
        return text.indexOf(strArg(0));
      case 'index':
        _expectArgs('.index', args, 1, line);
        final i = text.indexOf(strArg(0));
        if (i == -1) {
          throw PyError(
            "I couldn't find that text inside.",
            line: line,
            kind: 'ValueError',
            pyMessage: 'substring not found',
          );
        }
        return i;
      case 'count':
        _expectArgs('.count', args, 1, line);
        final sub = strArg(0);
        if (sub.isEmpty) return text.length + 1;
        return sub.allMatches(text).length;
      case 'startswith':
        _expectArgs('.startswith', args, 1, line);
        return text.startsWith(strArg(0));
      case 'endswith':
        _expectArgs('.endswith', args, 1, line);
        return text.endsWith(strArg(0));
      case 'isdigit':
        _expectArgs('.isdigit', args, 0, line);
        return text.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(text);
      case 'isalpha':
        _expectArgs('.isalpha', args, 0, line);
        return text.isNotEmpty && RegExp(r'^[A-Za-z]+$').hasMatch(text);
      case 'isupper':
        _expectArgs('.isupper', args, 0, line);
        return text != text.toLowerCase() && text == text.toUpperCase();
      case 'islower':
        _expectArgs('.islower', args, 0, line);
        return text != text.toUpperCase() && text == text.toLowerCase();
      case 'split':
        if (args.isEmpty) {
          final parts = text.trim().split(RegExp(r'\s+'));
          return text.trim().isEmpty ? <Object?>[] : parts.cast<Object?>();
        }
        _expectArgs('.split', args, 1, line);
        final sep = strArg(0);
        if (sep.isEmpty) {
          throw PyError(
            "The separator for `.split()` can't be empty.",
            line: line,
            kind: 'ValueError',
            pyMessage: 'empty separator',
          );
        }
        return text.split(sep).cast<Object?>();
      case 'join':
        _expectArgs('.join', args, 1, line);
        final items = _iterate(args.first, line);
        final strings = <String>[];
        for (final it in items) {
          if (it is! String) {
            throw PyError(
              "`.join()` only joins text. Turn numbers into text with str() first.",
              line: line,
              kind: 'TypeError',
            );
          }
          strings.add(it);
        }
        final r = strings.join(text);
        _guardStringLength(r.length, line);
        return r;
      default:
        _noMethod(
          'text',
          method,
          line,
          '`.upper()`, `.lower()`, `.title()`, `.strip()`, `.split()`, '
              '`.join()`, `.replace()`, `.find()`, `.count()`, '
              '`.startswith()` or `.isdigit()`',
        );
    }
  }

  Object? _dictMethod(
    Map<Object?, Object?> map,
    String method,
    List<Object?> args,
    int line,
  ) {
    switch (method) {
      case 'get':
        if (args.isEmpty || args.length > 2) {
          throw PyError(
            "`.get()` takes a key and an optional fallback.",
            line: line,
          );
        }
        _checkHashable(args.first, line);
        return map.containsKey(args.first)
            ? map[args.first]
            : (args.length == 2 ? args[1] : null);
      case 'keys':
        _expectArgs('.keys', args, 0, line);
        return _PyView('dict_keys', map.keys.toList());
      case 'values':
        _expectArgs('.values', args, 0, line);
        return _PyView('dict_values', map.values.toList());
      case 'items':
        _expectArgs('.items', args, 0, line);
        return _PyView('dict_items', [
          for (final e in map.entries) _PyTuple([e.key, e.value]),
        ]);
      case 'pop':
        if (args.isEmpty || args.length > 2) {
          throw PyError(
            "`.pop()` takes a key and an optional fallback.",
            line: line,
          );
        }
        _checkHashable(args.first, line);
        if (map.containsKey(args.first)) return map.remove(args.first);
        if (args.length == 2) return args[1];
        throw _keyError(args.first, line);
      case 'update':
        _expectArgs('.update', args, 1, line);
        final other = args.first;
        if (other is! Map) {
          throw PyError(
            "`.update()` needs another dictionary.",
            line: line,
            kind: 'TypeError',
          );
        }
        map.addAll(other);
        _guardListLength(map.length, line);
        return null;
      case 'clear':
        _expectArgs('.clear', args, 0, line);
        map.clear();
        return null;
      default:
        _noMethod(
          'dictionary',
          method,
          line,
          '`.get()`, `.keys()`, `.values()`, `.items()`, `.pop()` or '
              '`.update()`',
        );
    }
  }

  Object? _tupleMethod(
    _PyTuple tuple,
    String method,
    List<Object?> args,
    int line,
  ) {
    switch (method) {
      case 'count':
        _expectArgs('.count', args, 1, line);
        return tuple.items.where((x) => _equals(x, args.first)).length;
      case 'index':
        _expectArgs('.index', args, 1, line);
        final i = tuple.items.indexWhere((x) => _equals(x, args.first));
        if (i == -1) {
          throw PyError(
            "That item isn't in the tuple.",
            line: line,
            kind: 'ValueError',
          );
        }
        return i;
      default:
        _noMethod('tuple', method, line, '`.count()` or `.index()`');
    }
  }

  // ── random module ───────────────────────────────────────────────────────────

  Object? _randomCall(String fn, List<Object?> args, int line) {
    if (!_imported.contains('random')) {
      throw PyError(
        "To use `random`, start your program with `import random`.",
        line: line,
        kind: 'NameError',
        pyMessage: "name 'random' is not defined",
      );
    }
    int intArg(int i) {
      final v = args[i];
      if (v is! int) {
        throw PyError(
          "`random.$fn()` needs whole numbers.",
          line: line,
          kind: 'TypeError',
        );
      }
      return v;
    }

    switch (fn) {
      case 'seed':
        _expectArgs('random.seed', args, 1, line);
        _rng.seed(intArg(0));
        return null;
      case 'random':
        _expectArgs('random.random', args, 0, line);
        return _rng.random();
      case 'randint':
        _expectArgs('random.randint', args, 2, line);
        final lo = intArg(0), hi = intArg(1);
        if (hi < lo) {
          throw PyError(
            "`random.randint(a, b)` needs the first number to be smaller.",
            line: line,
            kind: 'ValueError',
            pyMessage: 'empty range in randrange($lo, ${hi + 1})',
          );
        }
        return lo + _rng.below(hi - lo + 1);
      case 'randrange':
        if (args.isEmpty || args.length > 2) {
          throw PyError(
            "`random.randrange()` takes 1 or 2 whole numbers.",
            line: line,
          );
        }
        final lo = args.length == 1 ? 0 : intArg(0);
        final hi = args.length == 1 ? intArg(0) : intArg(1);
        if (hi <= lo) {
          throw PyError(
            "`random.randrange()` has nothing to pick from.",
            line: line,
            kind: 'ValueError',
          );
        }
        return lo + _rng.below(hi - lo);
      case 'uniform':
        _expectArgs('random.uniform', args, 2, line);
        final a = args[0], b = args[1];
        if (a is! num || b is! num) {
          throw PyError(
            "`random.uniform()` needs two numbers.",
            line: line,
            kind: 'TypeError',
          );
        }
        return a + (b - a) * _rng.random();
      case 'choice':
        _expectArgs('random.choice', args, 1, line);
        final items = _iterate(args.first, line);
        if (items.isEmpty) {
          throw PyError(
            "You can't choose from an empty list.",
            line: line,
            kind: 'IndexError',
            pyMessage: 'Cannot choose from an empty sequence',
          );
        }
        return items[_rng.below(items.length)];
      case 'shuffle':
        _expectArgs('random.shuffle', args, 1, line);
        final list = args.first;
        if (list is! List) {
          throw PyError(
            "`random.shuffle()` needs a list.",
            line: line,
            kind: 'TypeError',
          );
        }
        for (var i = list.length - 1; i >= 1; i--) {
          final j = _rng.below(i + 1);
          final tmp = list[i];
          list[i] = list[j];
          list[j] = tmp;
        }
        return null;
      default:
        throw PyError(
          "`random.$fn()` isn't in our course yet.",
          line: line,
          hint:
              "Try `random.randint()`, `random.choice()`, "
              "`random.shuffle()` or `random.random()`.",
        );
    }
  }

  // ── built-in implementations ────────────────────────────────────────────────

  Object? _builtinPrint(
    List<Object?> args,
    Map<String, Object?> kwargs,
    int line,
  ) {
    for (final k in kwargs.keys) {
      if (k != 'sep' && k != 'end') {
        throw PyError(
          "`print()` doesn't have an input called `$k`.",
          line: line,
          hint: "You can use `sep=` and `end=`.",
        );
      }
    }
    final sep = kwargs['sep'] ?? ' ';
    final end = kwargs['end'] ?? '\n';
    if (sep is! String || end is! String) {
      throw PyError(
        "`sep=` and `end=` must be text.",
        line: line,
        kind: 'TypeError',
      );
    }
    _write('${args.map(_pyStr).join(sep)}$end');
    return null;
  }

  List<Object?> _builtinList(List<Object?> args, int line) {
    if (args.isEmpty) return <Object?>[];
    _expectArgs('list', args, 1, line);
    final items = [..._iterate(args.first, line)];
    _guardListLength(items.length, line);
    return items;
  }

  Map<Object?, Object?> _builtinDict(List<Object?> args, int line) {
    if (args.isEmpty) return <Object?, Object?>{};
    _expectArgs('dict', args, 1, line);
    final src = args.first;
    if (src is Map) return Map<Object?, Object?>.of(src);
    final map = <Object?, Object?>{};
    for (final pair in _iterate(src, line)) {
      final kv = _unpackItems(pair, 2, line);
      _checkHashable(kv[0], line);
      map[kv[0]] = kv[1];
    }
    return map;
  }

  List<Object?> _sortedCopy(List<Object?> items, bool reverse, int line) {
    final copy = [...items];
    final allNums = copy.every((x) => x is num);
    final allStrs = copy.every((x) => x is String);
    if (!allNums && !allStrs) {
      throw PyError(
        "I can only sort a list of all numbers or all text.",
        line: line,
        kind: 'TypeError',
      );
    }
    copy.sort(
      allNums
          ? (a, b) => (a as num).compareTo(b as num)
          : (a, b) => (a as String).compareTo(b as String),
    );
    return reverse ? copy.reversed.toList() : copy;
  }

  List<Object?> _builtinSorted(
    List<Object?> args,
    Map<String, Object?> kwargs,
    int line,
  ) {
    _expectArgs('sorted', args, 1, line);
    return _sortedCopy(
      _iterate(args.first, line),
      _truthy(kwargs['reverse']),
      line,
    );
  }

  List<Object?> _builtinEnumerate(List<Object?> args, int line) {
    _expectArgs('enumerate', args, 1, line);
    final items = _iterate(args.first, line);
    return [
      for (var i = 0; i < items.length; i++) _PyTuple([i, items[i]]),
    ];
  }

  List<Object?> _builtinZip(List<Object?> args, int line) {
    if (args.length < 2) {
      throw PyError("`zip()` needs at least two lists.", line: line);
    }
    final lists = [for (final a in args) _iterate(a, line)];
    final n = lists.map((l) => l.length).reduce((a, b) => a < b ? a : b);
    return [
      for (var i = 0; i < n; i++) _PyTuple([for (final l in lists) l[i]]),
    ];
  }

  Object? _builtinLen(List<Object?> args, int line) {
    _expectArgs('len', args, 1, line);
    final v = args.first;
    if (v is String) return v.length;
    if (v is List) return v.length;
    if (v is _PyTuple) return v.items.length;
    if (v is Map) return v.length;
    if (v is _PyView) return v.items.length;
    throw PyError(
      "`len()` works on text, lists, tuples and dictionaries.",
      line: line,
      kind: 'TypeError',
    );
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
          kind: 'ValueError',
          pyMessage: "invalid literal for int() with base 10: '$v'",
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
          kind: 'ValueError',
          pyMessage: "could not convert string to float: '$v'",
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
    if (args.length == 1 && args.first is! num) {
      items = _iterate(args.first, line);
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
      if (best == null || (isMin ? it < (best as num) : it > (best as num))) {
        best = it;
      }
    }
    return best;
  }

  num _builtinSum(List<Object?> args, int line) {
    _expectArgs('sum', args, 1, line);
    final v = args.first;
    if (v is! List && v is! _PyTuple && v is! _PyView) {
      throw PyError(
        "sum() needs a list of numbers.",
        line: line,
        kind: 'TypeError',
      );
    }
    num total = 0;
    for (final it in _iterate(v, line)) {
      if (it is! num) {
        throw PyError("sum() only adds up numbers.", line: line);
      }
      total += it;
    }
    return total;
  }

  Object _builtinRound(List<Object?> args, int line) {
    if (args.isEmpty || args.length > 2) {
      throw PyError(
        "round() takes a number (and an optional digit count).",
        line: line,
      );
    }
    final v = args.first;
    if (v is! num) {
      throw PyError("round() works on numbers.", line: line);
    }
    if (args.length == 1) return v.round();
    final digits = args[1];
    if (digits is! int) {
      throw PyError(
        "The second input to round() must be a whole number.",
        line: line,
      );
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
      case 'in':
        return _contains(b, a, line);
      case 'not in':
        return !_contains(b, a, line);
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

  bool _contains(Object? container, Object? item, int line) {
    if (container is String) {
      if (item is! String) {
        throw PyError(
          "`in` on text needs text on the left.",
          line: line,
          kind: 'TypeError',
        );
      }
      return container.contains(item);
    }
    if (container is Map) {
      _checkHashable(item, line);
      return container.containsKey(item);
    }
    if (container is List || container is _PyTuple || container is _PyView) {
      return _iterate(container, line).any((x) => _equals(x, item));
    }
    throw PyError(
      "`in` works on text, lists, tuples and dictionaries.",
      line: line,
      kind: 'TypeError',
    );
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
    if (a is _PyTuple && b is _PyTuple) {
      return _PyTuple([...a.items, ...b.items]);
    }
    if (a is String || b is String) {
      throw PyError(
        "You can't add words and numbers together directly.",
        line: line,
        kind: 'TypeError',
        hint:
            "Turn the number into text first with str(), like "
            "\"Age: \" + str(age).",
      );
    }
    throw PyError(
      "I can't add those two things together.",
      line: line,
      kind: 'TypeError',
    );
  }

  Object _multiply(Object? a, Object? b, int line) {
    if (a is num && b is num) return _numResult(a * b, a, b);
    // string * int (either order)
    if (a is String && b is int) return _repeat(a, b, line);
    if (a is int && b is String) return _repeat(b, a, line);
    if (a is List && b is int) return _repeatList(a, b, line);
    if (a is int && b is List) return _repeatList(b, a, line);
    throw PyError(
      "I can't multiply those two things.",
      line: line,
      kind: 'TypeError',
    );
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
      throw PyError(
        "`-` only works between two numbers.",
        line: line,
        kind: 'TypeError',
      );
    }
    return _numResult(a - b, a, b);
  }

  double _divide(Object? a, Object? b, int line) {
    if (a is! num || b is! num) {
      throw PyError(
        "`/` only works between two numbers.",
        line: line,
        kind: 'TypeError',
      );
    }
    if (b == 0) {
      throw PyError(
        "Dividing by zero breaks mathematics — and my brain!",
        line: line,
        kind: 'ZeroDivisionError',
        pyMessage: 'division by zero',
      );
    }
    return a / b;
  }

  Object _floorDiv(Object? a, Object? b, int line) {
    if (a is! num || b is! num) {
      throw PyError(
        "`//` only works between two numbers.",
        line: line,
        kind: 'TypeError',
      );
    }
    if (b == 0) {
      throw PyError(
        "You can't divide by zero.",
        line: line,
        kind: 'ZeroDivisionError',
        pyMessage: 'integer division or modulo by zero',
      );
    }
    final r = (a / b).floor();
    return (a is int && b is int) ? r : r.toDouble();
  }

  Object _modulo(Object? a, Object? b, int line) {
    if (a is! num || b is! num) {
      throw PyError(
        "`%` only works between two numbers.",
        line: line,
        kind: 'TypeError',
      );
    }
    if (b == 0) {
      throw PyError(
        "You can't find the remainder when dividing by zero.",
        line: line,
        kind: 'ZeroDivisionError',
        pyMessage: 'integer modulo by zero',
      );
    }
    final r = a % b;
    return _numResult(r, a, b);
  }

  Object _power(Object? a, Object? b, int line) {
    if (a is! num || b is! num) {
      throw PyError(
        "`**` only works between two numbers.",
        line: line,
        kind: 'TypeError',
      );
    }
    if (b is int && b > 200) {
      throw PyError("That power is too big for me to work out.", line: line);
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
      kind: 'TypeError',
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
    if (a is _PyTuple && b is _PyTuple) {
      return _equals(a.items, b.items);
    }
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final k in a.keys) {
        if (!b.containsKey(k) || !_equals(a[k], b[k])) return false;
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
    if (v is _PyTuple) return v.items.isNotEmpty;
    if (v is Map) return v.isNotEmpty;
    if (v is _PyView) return v.items.isNotEmpty;
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
    if (v is _PyTuple) {
      return v.items.length == 1
          ? '(${_pyRepr(v.items.first)},)'
          : '(${v.items.map(_pyRepr).join(', ')})';
    }
    if (v is Map) {
      return '{${v.entries.map((e) => '${_pyRepr(e.key)}: ${_pyRepr(e.value)}').join(', ')}}';
    }
    if (v is _PyView) {
      return '${v.name}([${v.items.map(_pyRepr).join(', ')}])';
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

  /// Applies an f-string format like `.2f`, `>8`, `05d` or `,`.
  String _formatValue(Object? value, String spec, int line) {
    final m = RegExp(
      r'^(?:(.)?([<>^]))?(0)?(\d+)?(,)?(?:\.(\d+))?([dfs%])?$',
    ).firstMatch(spec);
    if (m == null) {
      throw PyError(
        "I don't understand the format `$spec`.",
        line: line,
        hint: "Try something like `:.2f` (2 decimals) or `:>5` (width 5).",
        kind: 'ValueError',
      );
    }
    final fill = m[1], align = m[2], zero = m[3] != null;
    final width = m[4] == null ? 0 : int.parse(m[4]!);
    final comma = m[5] != null;
    final precision = m[6] == null ? null : int.parse(m[6]!);
    final type = m[7];

    String body;
    if (type == 'f' || type == '%' || (precision != null && value is num)) {
      if (value is! num) {
        throw PyError(
          "Only numbers can use `:.${precision ?? 2}f`.",
          line: line,
          kind: 'ValueError',
        );
      }
      final shown = type == '%' ? value * 100 : value;
      body = shown.toDouble().toStringAsFixed(precision ?? 6);
      if (type == '%') body += '%';
    } else if (type == 'd') {
      if (value is! int) {
        throw PyError(
          "`:d` only works on whole numbers.",
          line: line,
          kind: 'ValueError',
        );
      }
      body = value.toString();
    } else {
      body = _pyStr(value);
      if (precision != null && value is String && precision < body.length) {
        body = body.substring(0, precision);
      }
    }
    if (comma && value is num) {
      final negative = body.startsWith('-');
      final digits = negative ? body.substring(1) : body;
      final parts = digits.split('.');
      parts[0] = parts[0].replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
      body = (negative ? '-' : '') + parts.join('.');
    }
    if (body.length >= width) return body;
    final pad = width - body.length;
    final numeric = value is num;
    if (zero && numeric && align == null) {
      final negative = body.startsWith('-');
      final digits = negative ? body.substring(1) : body;
      return (negative ? '-' : '') + '0' * pad + digits;
    }
    final f = fill ?? (zero ? '0' : ' ');
    switch (align ?? (numeric ? '>' : '<')) {
      case '>':
        return f * pad + body;
      case '^':
        final left = pad ~/ 2;
        return f * left + body + f * (pad - left);
      default:
        return body + f * pad;
    }
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
        hint:
            "Positions start at 0, so a list of ${list.length} goes up to "
            "${list.length - 1}.",
        kind: 'IndexError',
        pyMessage: 'list index out of range',
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
        kind: 'IndexError',
        pyMessage: 'string index out of range',
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
      kind: 'NameError',
      pyMessage: "name '$name' is not defined",
      hint: _didYouMean(name, [
        ..._current.keys,
        ..._globals.keys,
        ..._functions.keys,
      ]),
    );
  }

  // ── limits ─────────────────────────────────────────────────────────────────

  void _tick(int line) {
    if (cancelToken?.isCancelled ?? false) throw const _Cancelled();
    if (++_steps > limits.maxSteps) {
      throw PyError(
        "Your program ran for too long, so I stopped it.",
        line: line,
        kind: kLimitError,
        hint:
            "Maybe a loop never ends? Check your `while` condition or "
            "make sure a counter changes.",
      );
    }
  }

  // Stops any single loop that spins past the allowed number of repeats — the
  // friendly guard against `while True:` and other never-ending loops.
  void _guardLoop(int iterations, int line) {
    if (iterations > limits.maxLoopIterations) {
      throw PyError(
        "This loop repeated more than ${limits.maxLoopIterations} times, "
        "so I stopped it.",
        line: line,
        kind: kLimitError,
        hint:
            "Does the loop have a way to stop? Check your `while` condition "
            "or that a counter is changing (like `n = n - 1`).",
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
        "That piece of text is too long for me to make.",
        line: line,
        kind: kLimitError,
      );
    }
  }

  void _guardListLength(int len, int line) {
    if (len > limits.maxListLength) {
      throw PyError(
        "That list is getting too big for me to hold.",
        line: line,
        kind: kLimitError,
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
