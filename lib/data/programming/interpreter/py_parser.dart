import 'py_ast.dart';
import 'py_error.dart';
import 'py_lexer.dart';

// ─── Parser ───────────────────────────────────────────────────────────────────
//
// Recursive-descent parser over the token stream (with INDENT/DEDENT tokens).
// Grammar sketch:
//   program   := (NEWLINE | stmt)*
//   stmt      := simple NEWLINE | compound
//   simple    := assign | expr | 'break' | 'continue' | 'return' expr?
//   compound  := if | while | for | def
//   block     := NEWLINE INDENT stmt+ DEDENT
//   expr      := or_expr  (standard precedence down to atoms)

class Parser {
  final List<Token> _tokens;
  int _pos = 0;

  Parser(this._tokens);

  List<Stmt> parse() {
    final stmts = <Stmt>[];
    _skipNewlines();
    while (!_check(TokType.eof)) {
      stmts.add(_statement());
      _skipNewlines();
    }
    return stmts;
  }

  // ── statements ────────────────────────────────────────────────────────────

  Stmt _statement() {
    switch (_peek.type) {
      case TokType.kwIf:
        return _ifStmt();
      case TokType.kwWhile:
        return _whileStmt();
      case TokType.kwFor:
        return _forStmt();
      case TokType.kwDef:
        return _funcDef();
      case TokType.kwReturn:
        return _returnStmt();
      case TokType.kwBreak:
        final t = _advance();
        _endSimple();
        return BreakStmt(t.line);
      case TokType.kwContinue:
        final t = _advance();
        _endSimple();
        return ContinueStmt(t.line);
      case TokType.kwPass:
        final t = _advance();
        _endSimple();
        return PassStmt(t.line);
      case TokType.kwTry:
        return _tryStmt();
      case TokType.kwRaise:
        return _raiseStmt();
      case TokType.kwImport:
        return _importStmt();
      default:
        return _exprOrAssign();
    }
  }

  Stmt _exprOrAssign() {
    final line = _peek.line;
    final expr = _expression();

    // `a, b = ...` — several names on the left.
    if (_check(TokType.comma) && expr is NameExpr) {
      final targets = [expr.name];
      while (_match(TokType.comma)) {
        final t = _consume(
          TokType.name,
          "Each name before `=` must be a variable name.",
        );
        targets.add(t.lexeme);
      }
      _consume(
        TokType.assign,
        "Several names on the left need an `=` after them.",
      );
      final value = _expressionList();
      _endSimple();
      return UnpackStmt(targets, value, line);
    }

    final op = _peek.type;
    if (op == TokType.assign ||
        op == TokType.plusAssign ||
        op == TokType.minusAssign ||
        op == TokType.starAssign) {
      if (expr is! NameExpr && expr is! IndexExpr) {
        throw PyError(
          "The left side of `=` must be a variable name (or a list slot).",
          line: line,
        );
      }
      final opTok = _advance();
      final value = opTok.type == TokType.assign
          ? _expressionList()
          : _expression();
      _endSimple();
      return AssignStmt(expr, value, opTok.lexeme, line);
    }

    _endSimple();
    return ExprStmt(expr, line);
  }

  /// `a`, or `a, b, c` as a tuple (the way `x = 1, 2` and `return a, b` work).
  Expr _expressionList() {
    final line = _peek.line;
    final first = _expression();
    if (!_check(TokType.comma)) return first;
    final items = [first];
    while (_match(TokType.comma)) {
      if (_checkAny([TokType.newline, TokType.eof, TokType.assign])) break;
      items.add(_expression());
    }
    return TupleExpr(items, line);
  }

  Stmt _tryStmt() {
    final line = _advance().line; // 'try'
    _consume(TokType.colon, "A `try` line must end with a colon `:`.");
    final body = _block();

    final handlers = <ExceptClause>[];
    while (_check(TokType.kwExcept)) {
      final exLine = _advance().line;
      final types = <String>[];
      String? asName;
      if (!_check(TokType.colon)) {
        if (_match(TokType.lParen)) {
          do {
            types.add(_errorName());
          } while (_match(TokType.comma));
          _consume(TokType.rParen, "This is missing its closing `)`.");
        } else {
          types.add(_errorName());
        }
        if (_match(TokType.kwAs)) {
          asName = _consume(
            TokType.name,
            "After `as` I expected a name for the error.",
          ).lexeme;
        }
      }
      _consume(TokType.colon, "An `except` line must end with a colon `:`.");
      handlers.add(ExceptClause(types, asName, _block(), exLine));
    }

    List<Stmt>? elseBody;
    if (handlers.isNotEmpty && _check(TokType.kwElse)) {
      _advance();
      _consume(TokType.colon, "An `else` line must end with a colon `:`.");
      elseBody = _block();
    }

    List<Stmt>? finallyBody;
    if (_check(TokType.kwFinally)) {
      _advance();
      _consume(TokType.colon, "A `finally` line must end with a colon `:`.");
      finallyBody = _block();
    }

    if (handlers.isEmpty && finallyBody == null) {
      throw PyError(
        "A `try` needs an `except` (or `finally`) after its block.",
        line: line,
        hint: "Like `except ValueError:` on a new line, lined up with `try`.",
      );
    }
    return TryStmt(body, handlers, elseBody, finallyBody, line);
  }

  String _errorName() => _consume(
    TokType.name,
    "After `except` I expected an error name, like `ValueError`.",
  ).lexeme;

  Stmt _raiseStmt() {
    final line = _advance().line; // 'raise'
    final kind = _errorName();
    Expr? message;
    if (_match(TokType.lParen)) {
      if (!_check(TokType.rParen)) message = _expression();
      _consume(TokType.rParen, "This is missing its closing `)`.");
    }
    _endSimple();
    return RaiseStmt(kind, message, line);
  }

  Stmt _importStmt() {
    final line = _advance().line; // 'import'
    final name = _consume(TokType.name, "After `import` I expected a name.");
    if (name.lexeme != 'random') {
      throw PyError(
        "`import ${name.lexeme}` is real Python, but it's not part of our "
        "course yet.",
        line: line,
        hint: "In our classroom you can `import random`.",
      );
    }
    _endSimple();
    return ImportStmt(name.lexeme, line);
  }

  Stmt _ifStmt() {
    final line = _advance().line; // 'if'
    final branches = <(Expr, List<Stmt>)>[];
    final cond = _expression();
    _consume(TokType.colon, "An `if` line must end with a colon `:`.");
    branches.add((cond, _block()));

    while (_check(TokType.kwElif)) {
      _advance();
      final c = _expression();
      _consume(TokType.colon, "An `elif` line must end with a colon `:`.");
      branches.add((c, _block()));
    }

    List<Stmt>? elseBody;
    if (_check(TokType.kwElse)) {
      _advance();
      _consume(TokType.colon, "An `else` line must end with a colon `:`.");
      elseBody = _block();
    }
    return IfStmt(branches, elseBody, line);
  }

  Stmt _whileStmt() {
    final line = _advance().line;
    final cond = _expression();
    _consume(TokType.colon, "A `while` line must end with a colon `:`.");
    return WhileStmt(cond, _block(), line);
  }

  Stmt _forStmt() {
    final line = _advance().line;
    final targets = [
      _consume(TokType.name, "After `for` I expected a variable name.").lexeme,
    ];
    while (_match(TokType.comma)) {
      targets.add(
        _consume(
          TokType.name,
          "After `,` I expected another variable name.",
        ).lexeme,
      );
    }
    _consume(
      TokType.kwIn,
      "A `for` loop needs the word `in`, like "
      "`for i in range(5):`.",
    );
    final iterable = _expression();
    _consume(TokType.colon, "A `for` line must end with a colon `:`.");
    return ForStmt(targets, iterable, _block(), line);
  }

  Stmt _funcDef() {
    final line = _advance().line;
    final nameTok = _consume(
      TokType.name,
      "After `def` I expected a function name.",
    );
    _consume(TokType.lParen, "A function needs `(` after its name.");
    final params = <String>[];
    if (!_check(TokType.rParen)) {
      do {
        final p = _consume(TokType.name, "Each function input must be a name.");
        params.add(p.lexeme);
      } while (_match(TokType.comma));
    }
    _consume(TokType.rParen, "This function is missing its closing `)`.");
    _consume(TokType.colon, "A `def` line must end with a colon `:`.");
    return FuncDef(nameTok.lexeme, params, _block(), line);
  }

  Stmt _returnStmt() {
    final line = _advance().line;
    Expr? value;
    if (!_check(TokType.newline) && !_check(TokType.eof)) {
      value = _expressionList();
    }
    _endSimple();
    return ReturnStmt(value, line);
  }

  /// block := NEWLINE INDENT stmt+ DEDENT
  List<Stmt> _block() {
    _consume(
      TokType.newline,
      "After a `:` the next line should start the indented block.",
    );
    if (!_check(TokType.indent)) {
      throw PyError(
        "This block is empty — the lines under it need to be indented "
        "(pushed right with spaces).",
        line: _peek.line,
      );
    }
    _advance(); // INDENT
    final stmts = <Stmt>[];
    while (!_check(TokType.dedent) && !_check(TokType.eof)) {
      stmts.add(_statement());
      _skipNewlines();
    }
    _consume(TokType.dedent, "Something went wrong with the indentation here.");
    return stmts;
  }

  // ── expressions (precedence climbing) ───────────────────────────────────────

  Expr _expression() => _or();

  Expr _or() {
    var left = _and();
    while (_check(TokType.kwOr)) {
      final line = _advance().line;
      final right = _and();
      left = LogicalExpr(left, 'or', right, line);
    }
    return left;
  }

  Expr _and() {
    var left = _not();
    while (_check(TokType.kwAnd)) {
      final line = _advance().line;
      final right = _not();
      left = LogicalExpr(left, 'and', right, line);
    }
    return left;
  }

  Expr _not() {
    if (_check(TokType.kwNot)) {
      final line = _advance().line;
      return UnaryExpr('not', _not(), line);
    }
    return _comparison();
  }

  /// Comparisons, including chains (`1 < x < 10`), `in` and `not in`.
  Expr _comparison() {
    var left = _addition();
    Expr? chain;
    while (true) {
      String? op;
      int line = _peek.line;
      if (_checkAny([
        TokType.eq,
        TokType.ne,
        TokType.lt,
        TokType.le,
        TokType.gt,
        TokType.ge,
      ])) {
        final t = _advance();
        op = t.lexeme;
        line = t.line;
      } else if (_check(TokType.kwIn)) {
        line = _advance().line;
        op = 'in';
      } else if (_check(TokType.kwNot) && _peekNextIs(TokType.kwIn)) {
        line = _advance().line;
        _advance(); // 'in'
        op = 'not in';
      } else {
        break;
      }
      final right = _addition();
      final test = BinaryExpr(left, op, right, line);
      chain = chain == null ? test : LogicalExpr(chain, 'and', test, line);
      left = right;
    }
    return chain ?? left;
  }

  Expr _addition() {
    var left = _multiplication();
    while (_checkAny([TokType.plus, TokType.minus])) {
      final opTok = _advance();
      final right = _multiplication();
      left = BinaryExpr(left, opTok.lexeme, right, opTok.line);
    }
    return left;
  }

  Expr _multiplication() {
    var left = _unary();
    while (_checkAny([
      TokType.star,
      TokType.slash,
      TokType.doubleSlash,
      TokType.percent,
    ])) {
      final opTok = _advance();
      final right = _unary();
      left = BinaryExpr(left, opTok.lexeme, right, opTok.line);
    }
    return left;
  }

  Expr _unary() {
    if (_check(TokType.minus)) {
      final line = _advance().line;
      return UnaryExpr('-', _unary(), line);
    }
    return _power();
  }

  Expr _power() {
    final base = _postfix();
    if (_check(TokType.doubleStar)) {
      final line = _advance().line;
      final exp = _unary(); // right-associative
      return BinaryExpr(base, '**', exp, line);
    }
    return base;
  }

  /// Handles trailing calls, indexing, slicing and attribute access:
  /// `f(x)[0].append(y)`, `text[1:3]`.
  Expr _postfix() {
    var expr = _atom();
    while (true) {
      if (_check(TokType.lParen)) {
        final line = _advance().line;
        final args = <Expr>[];
        final kwargs = <(String, Expr)>[];
        if (!_check(TokType.rParen)) {
          do {
            if (_check(TokType.rParen)) break; // trailing comma
            if (_check(TokType.name) && _peekNextIs(TokType.assign)) {
              final name = _advance().lexeme;
              _advance(); // '='
              kwargs.add((name, _expression()));
            } else {
              if (kwargs.isNotEmpty) {
                throw PyError(
                  "Inputs like `name=value` must come after the plain ones.",
                  line: _peek.line,
                );
              }
              args.add(_expression());
            }
          } while (_match(TokType.comma));
        }
        _consume(TokType.rParen, "This call is missing its closing `)`.");
        expr = CallExpr(expr, args, line, kwargs);
      } else if (_check(TokType.lBracket)) {
        final line = _advance().line;
        Expr? start;
        if (!_check(TokType.colon)) start = _expression();
        if (_match(TokType.colon)) {
          Expr? stop;
          if (!_check(TokType.rBracket)) stop = _expression();
          _consume(TokType.rBracket, "This is missing its closing `]`.");
          expr = SliceExpr(expr, start, stop, line);
        } else {
          _consume(TokType.rBracket, "This is missing its closing `]`.");
          expr = IndexExpr(expr, start!, line);
        }
      } else if (_check(TokType.dot)) {
        final line = _advance().line;
        final nameTok = _consume(TokType.name, "After `.` I expected a name.");
        expr = AttrExpr(expr, nameTok.lexeme, line);
      } else {
        break;
      }
    }
    return expr;
  }

  Expr _atom() {
    final t = _peek;
    switch (t.type) {
      case TokType.number:
        _advance();
        return LiteralExpr(t.value, t.line);
      case TokType.string:
        _advance();
        return LiteralExpr(t.value, t.line);
      case TokType.fstring:
        _advance();
        return _parseFString(t);
      case TokType.kwTrue:
        _advance();
        return LiteralExpr(true, t.line);
      case TokType.kwFalse:
        _advance();
        return LiteralExpr(false, t.line);
      case TokType.kwNone:
        _advance();
        return LiteralExpr(null, t.line);
      case TokType.name:
        _advance();
        return NameExpr(t.lexeme, t.line);
      case TokType.lParen:
        _advance();
        if (_match(TokType.rParen)) return TupleExpr(const [], t.line);
        final e = _expression();
        if (_check(TokType.comma)) {
          final items = [e];
          while (_match(TokType.comma)) {
            if (_check(TokType.rParen)) break; // `(1,)`
            items.add(_expression());
          }
          _consume(TokType.rParen, "This tuple is missing its closing `)`.");
          return TupleExpr(items, t.line);
        }
        _consume(TokType.rParen, "This is missing its closing `)`.");
        return e;
      case TokType.lBracket:
        return _listLiteral();
      case TokType.lBrace:
        return _dictLiteral();
      default:
        throw PyError("I didn't expect `${_describe(t)}` here.", line: t.line);
    }
  }

  Expr _listLiteral() {
    final line = _advance().line; // '['
    final elements = <Expr>[];
    if (!_check(TokType.rBracket)) {
      do {
        if (_check(TokType.rBracket)) break; // trailing comma
        elements.add(_expression());
      } while (_match(TokType.comma));
    }
    _consume(TokType.rBracket, "This list is missing its closing `]`.");
    return ListExpr(elements, line);
  }

  Expr _dictLiteral() {
    final line = _advance().line; // '{'
    final entries = <(Expr, Expr)>[];
    if (!_check(TokType.rBrace)) {
      do {
        if (_check(TokType.rBrace)) break; // trailing comma
        final key = _expression();
        _consume(
          TokType.colon,
          "Each dictionary entry needs a colon between the key and value, "
          "like `\"name\": \"Asha\"`.",
        );
        entries.add((key, _expression()));
      } while (_match(TokType.comma));
    }
    _consume(TokType.rBrace, "This dictionary is missing its closing `}`.");
    return DictExpr(entries, line);
  }

  /// Splits an f-string's raw text into literal chunks and `{expr}` pieces,
  /// re-parsing each embedded expression with a fresh parser.
  Expr _parseFString(Token t) {
    final raw = t.raw ?? '';
    final parts = <Object>[];
    final buf = StringBuffer();
    int i = 0;
    while (i < raw.length) {
      final c = raw[i];
      if (c == '{') {
        if (i + 1 < raw.length && raw[i + 1] == '{') {
          buf.write('{');
          i += 2;
          continue;
        }
        if (buf.isNotEmpty) {
          parts.add(buf.toString());
          buf.clear();
        }
        final close = raw.indexOf('}', i + 1);
        if (close == -1) {
          throw PyError(
            "This f-string has a `{` with no matching `}`.",
            line: t.line,
          );
        }
        var exprSrc = raw.substring(i + 1, close).trim();
        if (exprSrc.isEmpty) {
          throw PyError(
            "There's an empty `{}` in this f-string.",
            line: t.line,
          );
        }
        // `{value:.2f}` — split off the format after a top-level colon.
        var spec = '';
        final colon = _formatColon(exprSrc);
        if (colon != -1) {
          spec = exprSrc.substring(colon + 1).trim();
          exprSrc = exprSrc.substring(0, colon).trim();
        }
        final expr = _subExpression(exprSrc, t.line);
        parts.add(spec.isEmpty ? expr : FStringField(expr, spec));
        i = close + 1;
      } else if (c == '}') {
        if (i + 1 < raw.length && raw[i + 1] == '}') {
          buf.write('}');
          i += 2;
          continue;
        }
        throw PyError(
          "This f-string has a `}` with no matching `{`.",
          line: t.line,
        );
      } else {
        buf.write(c);
        i++;
      }
    }
    if (buf.isNotEmpty) parts.add(buf.toString());
    return FStringExpr(parts, t.line);
  }

  /// Index of the `:` that starts a format spec, ignoring colons inside
  /// quotes or brackets (like `d["a:b"]` or `x[1:2]`); -1 if there is none.
  int _formatColon(String src) {
    var depth = 0;
    String? quote;
    for (var i = 0; i < src.length; i++) {
      final c = src[i];
      if (quote != null) {
        if (c == quote) quote = null;
      } else if (c == '"' || c == "'") {
        quote = c;
      } else if (c == '(' || c == '[' || c == '{') {
        depth++;
      } else if (c == ')' || c == ']' || c == '}') {
        depth--;
      } else if (c == ':' && depth == 0) {
        return i;
      }
    }
    return -1;
  }

  Expr _subExpression(String src, int line) {
    try {
      final tokens = Lexer(src).tokenize();
      final p = Parser(tokens);
      final expr = p._expression();
      return expr;
    } on PyError catch (e) {
      throw PyError(
        "I couldn't understand `{$src}` inside the f-string: ${e.message}",
        line: line,
      );
    }
  }

  // ── token helpers ───────────────────────────────────────────────────────────

  void _endSimple() {
    if (_check(TokType.newline) || _check(TokType.eof)) {
      if (_check(TokType.newline)) _advance();
      return;
    }
    throw PyError(
      "I didn't expect `${_describe(_peek)}` at the end of this line.",
      line: _peek.line,
    );
  }

  void _skipNewlines() {
    while (_check(TokType.newline)) {
      _advance();
    }
  }

  Token get _peek => _tokens[_pos];
  bool _peekNextIs(TokType type) =>
      _pos + 1 < _tokens.length && _tokens[_pos + 1].type == type;
  Token _advance() => _tokens[_pos++];
  bool _check(TokType type) => _peek.type == type;
  bool _checkAny(List<TokType> types) => types.contains(_peek.type);

  bool _match(TokType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  Token _consume(TokType type, String message) {
    if (_check(type)) return _advance();
    throw PyError(message, line: _peek.line);
  }

  String _describe(Token t) {
    switch (t.type) {
      case TokType.newline:
        return 'end of line';
      case TokType.eof:
        return 'end of program';
      case TokType.indent:
      case TokType.dedent:
        return 'indentation';
      default:
        return t.lexeme;
    }
  }
}
