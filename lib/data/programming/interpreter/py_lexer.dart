import 'py_error.dart';

// ─── Token types ──────────────────────────────────────────────────────────────

enum TokType {
  // literals & names
  number,
  string,
  fstring,
  name,
  // keywords
  kwIf,
  kwElif,
  kwElse,
  kwWhile,
  kwFor,
  kwIn,
  kwBreak,
  kwContinue,
  kwDef,
  kwReturn,
  kwTrue,
  kwFalse,
  kwAnd,
  kwOr,
  kwNot,
  kwNone,
  // operators & punctuation
  plus,
  minus,
  star,
  slash,
  doubleSlash,
  percent,
  doubleStar,
  assign,
  plusAssign,
  minusAssign,
  starAssign,
  eq,
  ne,
  lt,
  le,
  gt,
  ge,
  lParen,
  rParen,
  lBracket,
  rBracket,
  comma,
  colon,
  dot,
  // structure
  newline,
  indent,
  dedent,
  eof,
}

class Token {
  final TokType type;
  final String lexeme; // raw text (for names/numbers) or decoded string value
  final Object? value; // parsed literal value for numbers / decoded strings
  final int line;

  /// For f-strings: the raw inner text between the quotes, parsed later.
  final String? raw;

  const Token(this.type, this.lexeme, this.line, {this.value, this.raw});

  @override
  String toString() => '$type($lexeme)';
}

// ─── Keyword table ────────────────────────────────────────────────────────────

const _keywords = <String, TokType>{
  'if': TokType.kwIf,
  'elif': TokType.kwElif,
  'else': TokType.kwElse,
  'while': TokType.kwWhile,
  'for': TokType.kwFor,
  'in': TokType.kwIn,
  'break': TokType.kwBreak,
  'continue': TokType.kwContinue,
  'def': TokType.kwDef,
  'return': TokType.kwReturn,
  'True': TokType.kwTrue,
  'False': TokType.kwFalse,
  'and': TokType.kwAnd,
  'or': TokType.kwOr,
  'not': TokType.kwNot,
  'None': TokType.kwNone,
};

// Real Python words that we deliberately don't teach yet. Hitting one gives a
// friendly "not in our classroom" message instead of a confusing parse error.
const _notYetKeywords = <String>{
  'import', 'from', 'class', 'try', 'except', 'finally', 'raise', 'with',
  'as', 'lambda', 'global', 'nonlocal', 'yield', 'assert', 'del', 'pass',
  'is',
};

// ─── Lexer ────────────────────────────────────────────────────────────────────
//
// Produces a flat token stream including synthetic INDENT/DEDENT tokens (like
// CPython's tokenizer) so the parser can treat blocks structurally. Only spaces
// are used for indentation; a literal tab is expanded to 4 spaces.

class Lexer {
  final String _src;
  int _pos = 0;
  int _line = 1;
  final List<Token> _tokens = [];
  final List<int> _indents = [0];

  // Parenthesis/bracket depth — newlines inside (...) or [...] are ignored,
  // so a list literal can span lines the way Python allows.
  int _bracketDepth = 0;

  Lexer(this._src);

  List<Token> tokenize() {
    while (!_atEnd) {
      _lexLine();
    }
    // Close any dangling indentation and finish the stream.
    if (_tokens.isNotEmpty && _tokens.last.type != TokType.newline) {
      _add(TokType.newline, '\n');
    }
    while (_indents.length > 1) {
      _indents.removeLast();
      _add(TokType.dedent, '');
    }
    _add(TokType.eof, '');
    return _tokens;
  }

  // ── one logical line ────────────────────────────────────────────────────

  void _lexLine() {
    // Measure indentation (spaces only) at the start of a physical line, but
    // only when we're not continuing inside brackets.
    if (_bracketDepth == 0) {
      final indent = _measureIndent();
      // Blank line or comment-only line: emit nothing structural.
      if (_atEnd || _peek == '\n' || _peek == '#') {
        _skipToLineEnd();
        return;
      }
      _applyIndent(indent);
    }

    while (!_atEnd) {
      final c = _peek;
      if (c == '\n') {
        _advance();
        if (_bracketDepth == 0) {
          _add(TokType.newline, '\n');
          _line++;
          return;
        }
        _line++;
        continue;
      }
      if (c == ' ' || c == '\t' || c == '\r') {
        _advance();
        continue;
      }
      if (c == '#') {
        _skipToLineEnd();
        continue;
      }
      _lexToken();
    }
  }

  int _measureIndent() {
    int spaces = 0;
    while (!_atEnd) {
      if (_peek == ' ') {
        spaces++;
        _advance();
      } else if (_peek == '\t') {
        spaces += 4;
        _advance();
      } else {
        break;
      }
    }
    return spaces;
  }

  void _applyIndent(int indent) {
    final current = _indents.last;
    if (indent > current) {
      _indents.add(indent);
      _add(TokType.indent, '');
    } else if (indent < current) {
      while (_indents.length > 1 && _indents.last > indent) {
        _indents.removeLast();
        _add(TokType.dedent, '');
      }
      if (_indents.last != indent) {
        throw PyError(
          "The spaces at the start of this line don't line up with the block "
          "above it.",
          line: _line,
          hint: "Lines inside the same block need the same number of spaces.",
        );
      }
    }
  }

  // ── one token ─────────────────────────────────────────────────────────────

  void _lexToken() {
    final c = _peek;
    if (_isDigit(c) || (c == '.' && _isDigit(_peekAt(1)))) {
      _lexNumber();
      return;
    }
    if (_isAlpha(c)) {
      _lexName();
      return;
    }
    if (c == '"' || c == "'") {
      _lexString();
      return;
    }
    _lexSymbol();
  }

  void _lexNumber() {
    final start = _pos;
    bool isFloat = false;
    while (!_atEnd && _isDigit(_peek)) {
      _advance();
    }
    if (!_atEnd && _peek == '.') {
      isFloat = true;
      _advance();
      while (!_atEnd && _isDigit(_peek)) {
        _advance();
      }
    }
    final text = _src.substring(start, _pos);
    final value = isFloat ? double.parse(text) : int.parse(text);
    _tokens.add(Token(TokType.number, text, _line, value: value));
  }

  void _lexName() {
    final start = _pos;
    while (!_atEnd && (_isAlpha(_peek) || _isDigit(_peek))) {
      _advance();
    }
    final text = _src.substring(start, _pos);

    // f-string prefix: f"..." or f'...'
    if ((text == 'f' || text == 'F') &&
        !_atEnd &&
        (_peek == '"' || _peek == "'")) {
      _lexFString();
      return;
    }

    if (_notYetKeywords.contains(text)) {
      throw PyError(
        "`$text` is a real Python word, but it's not part of our course yet.",
        line: _line,
        hint: "Stick to the tools you've learned in the lessons! 🧰",
      );
    }

    final kw = _keywords[text];
    if (kw != null) {
      _tokens.add(Token(kw, text, _line));
    } else {
      _tokens.add(Token(TokType.name, text, _line));
    }
  }

  void _lexString() {
    final quote = _peek;
    final startLine = _line;
    _advance(); // opening quote
    final buf = StringBuffer();
    while (!_atEnd && _peek != quote) {
      final c = _peek;
      if (c == '\n') {
        throw PyError(
          "This text (string) is missing its closing quote $quote.",
          line: startLine,
          hint: "Every opening quote needs a matching closing quote.",
        );
      }
      if (c == '\\') {
        _advance();
        buf.write(_escape());
      } else {
        buf.write(c);
        _advance();
      }
    }
    if (_atEnd) {
      throw PyError(
        "This text (string) is missing its closing quote $quote.",
        line: startLine,
        hint: "Every opening quote needs a matching closing quote.",
      );
    }
    _advance(); // closing quote
    _tokens.add(Token(TokType.string, buf.toString(), startLine,
        value: buf.toString()));
  }

  void _lexFString() {
    final quote = _peek;
    final startLine = _line;
    _advance(); // opening quote
    final buf = StringBuffer();
    while (!_atEnd && _peek != quote) {
      final c = _peek;
      if (c == '\n') {
        throw PyError(
          "This f-string is missing its closing quote $quote.",
          line: startLine,
          hint: "Every opening quote needs a matching closing quote.",
        );
      }
      if (c == '\\') {
        _advance();
        buf.write(_escape());
      } else {
        buf.write(c);
        _advance();
      }
    }
    if (_atEnd) {
      throw PyError(
        "This f-string is missing its closing quote $quote.",
        line: startLine,
        hint: "Every opening quote needs a matching closing quote.",
      );
    }
    _advance(); // closing quote
    // Keep the raw inner text; the parser turns {expr} pieces into real exprs.
    _tokens.add(Token(TokType.fstring, buf.toString(), startLine,
        raw: buf.toString()));
  }

  String _escape() {
    if (_atEnd) return '';
    final c = _peek;
    _advance();
    switch (c) {
      case 'n':
        return '\n';
      case 't':
        return '\t';
      case '\\':
        return '\\';
      case "'":
        return "'";
      case '"':
        return '"';
      case 'r':
        return '\r';
      case '0':
        return ' ';
      default:
        return '\\$c';
    }
  }

  void _lexSymbol() {
    final c = _peek;
    switch (c) {
      case '+':
        _advance();
        if (_match('=')) return _add(TokType.plusAssign, '+=');
        return _add(TokType.plus, '+');
      case '-':
        _advance();
        if (_match('=')) return _add(TokType.minusAssign, '-=');
        return _add(TokType.minus, '-');
      case '*':
        _advance();
        if (_match('*')) return _add(TokType.doubleStar, '**');
        if (_match('=')) return _add(TokType.starAssign, '*=');
        return _add(TokType.star, '*');
      case '/':
        _advance();
        if (_match('/')) return _add(TokType.doubleSlash, '//');
        return _add(TokType.slash, '/');
      case '%':
        _advance();
        return _add(TokType.percent, '%');
      case '=':
        _advance();
        if (_match('=')) return _add(TokType.eq, '==');
        return _add(TokType.assign, '=');
      case '!':
        _advance();
        if (_match('=')) return _add(TokType.ne, '!=');
        throw PyError("I don't understand `!` on its own.",
            line: _line, hint: "Did you mean `!=` (not equal)?");
      case '<':
        _advance();
        if (_match('=')) return _add(TokType.le, '<=');
        return _add(TokType.lt, '<');
      case '>':
        _advance();
        if (_match('=')) return _add(TokType.ge, '>=');
        return _add(TokType.gt, '>');
      case '(':
        _advance();
        _bracketDepth++;
        return _add(TokType.lParen, '(');
      case ')':
        _advance();
        if (_bracketDepth > 0) _bracketDepth--;
        return _add(TokType.rParen, ')');
      case '[':
        _advance();
        _bracketDepth++;
        return _add(TokType.lBracket, '[');
      case ']':
        _advance();
        if (_bracketDepth > 0) _bracketDepth--;
        return _add(TokType.rBracket, ']');
      case ',':
        _advance();
        return _add(TokType.comma, ',');
      case ':':
        _advance();
        return _add(TokType.colon, ':');
      case '.':
        _advance();
        return _add(TokType.dot, '.');
      default:
        throw PyError(
          "I don't understand the symbol `$c` here.",
          line: _line,
        );
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  void _skipToLineEnd() {
    while (!_atEnd && _peek != '\n') {
      _advance();
    }
    if (!_atEnd) {
      _advance(); // consume newline
      _line++;
    }
  }

  void _add(TokType type, String lexeme) {
    _tokens.add(Token(type, lexeme, _line));
  }

  bool get _atEnd => _pos >= _src.length;
  String get _peek => _src[_pos];
  String _peekAt(int n) =>
      (_pos + n) < _src.length ? _src[_pos + n] : ' ';
  void _advance() => _pos++;

  bool _match(String expected) {
    if (_atEnd || _peek != expected) return false;
    _advance();
    return true;
  }

  static bool _isDigit(String c) {
    final u = c.codeUnitAt(0);
    return u >= 48 && u <= 57;
  }
  static bool _isAlpha(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 65 && u <= 90) || (u >= 97 && u <= 122) || u == 95;
  }
}
