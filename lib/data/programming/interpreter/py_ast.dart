// ─── AST ──────────────────────────────────────────────────────────────────────
//
// Two sealed hierarchies — statements and expressions — produced by the parser
// and walked by the evaluator. Every node carries the source line it came from,
// so runtime errors can point the student at the right place.

sealed class Stmt {
  final int line;
  const Stmt(this.line);
}

sealed class Expr {
  final int line;
  const Expr(this.line);
}

// ── Statements ──────────────────────────────────────────────────────────────

class ExprStmt extends Stmt {
  final Expr expr;
  const ExprStmt(this.expr, int line) : super(line);
}

/// `name = expr`, `name[index] = expr`, and augmented forms (`+=` etc.).
class AssignStmt extends Stmt {
  final Expr target; // NameExpr or IndexExpr
  final Expr value;
  final String op; // '=', '+=', '-=', '*='
  const AssignStmt(this.target, this.value, this.op, int line) : super(line);
}

class IfStmt extends Stmt {
  final List<(Expr, List<Stmt>)> branches; // if / elif conditions + bodies
  final List<Stmt>? elseBody;
  const IfStmt(this.branches, this.elseBody, int line) : super(line);
}

class WhileStmt extends Stmt {
  final Expr condition;
  final List<Stmt> body;
  const WhileStmt(this.condition, this.body, int line) : super(line);
}

/// `for x in items:` or, unpacking, `for key, value in d.items():`.
class ForStmt extends Stmt {
  final List<String> targets;
  final Expr iterable;
  final List<Stmt> body;
  const ForStmt(this.targets, this.iterable, this.body, int line) : super(line);
}

/// `a, b = b, a` — assigns the items of a tuple/list to several names.
class UnpackStmt extends Stmt {
  final List<String> targets;
  final Expr value;
  const UnpackStmt(this.targets, this.value, int line) : super(line);
}

/// One `except` clause. An empty [types] list catches every error.
class ExceptClause {
  final List<String> types;
  final String? asName;
  final List<Stmt> body;
  final int line;
  const ExceptClause(this.types, this.asName, this.body, this.line);
}

class TryStmt extends Stmt {
  final List<Stmt> body;
  final List<ExceptClause> handlers;
  final List<Stmt>? elseBody;
  final List<Stmt>? finallyBody;
  const TryStmt(
    this.body,
    this.handlers,
    this.elseBody,
    this.finallyBody,
    int line,
  ) : super(line);
}

/// `raise ValueError("message")`.
class RaiseStmt extends Stmt {
  final String kind;
  final Expr? message;
  const RaiseStmt(this.kind, this.message, int line) : super(line);
}

/// `import random` — the only module in the course.
class ImportStmt extends Stmt {
  final String module;
  const ImportStmt(this.module, int line) : super(line);
}

class PassStmt extends Stmt {
  const PassStmt(super.line);
}

class FuncDef extends Stmt {
  final String name;
  final List<String> params;
  final List<Stmt> body;
  const FuncDef(this.name, this.params, this.body, int line) : super(line);
}

class ReturnStmt extends Stmt {
  final Expr? value;
  const ReturnStmt(this.value, int line) : super(line);
}

class BreakStmt extends Stmt {
  const BreakStmt(super.line);
}

class ContinueStmt extends Stmt {
  const ContinueStmt(super.line);
}

// ── Expressions ─────────────────────────────────────────────────────────────

class LiteralExpr extends Expr {
  final Object? value; // int, double, String, bool, or null
  const LiteralExpr(this.value, int line) : super(line);
}

class ListExpr extends Expr {
  final List<Expr> elements;
  const ListExpr(this.elements, int line) : super(line);
}

class TupleExpr extends Expr {
  final List<Expr> elements;
  const TupleExpr(this.elements, int line) : super(line);
}

/// `{key: value, ...}`.
class DictExpr extends Expr {
  final List<(Expr, Expr)> entries;
  const DictExpr(this.entries, int line) : super(line);
}

/// `obj[start:stop]` — either end may be left out.
class SliceExpr extends Expr {
  final Expr object;
  final Expr? start;
  final Expr? stop;
  const SliceExpr(this.object, this.start, this.stop, int line) : super(line);
}

/// An interpolated `{expr:spec}` piece of an f-string.
class FStringField {
  final Expr expr;
  final String spec;
  const FStringField(this.expr, this.spec);
}

/// f"...{expr}...": alternating literal chunks and embedded expressions.
class FStringExpr extends Expr {
  /// String (literal), Expr (interpolated), or FStringField (with a format).
  final List<Object> parts;
  const FStringExpr(this.parts, int line) : super(line);
}

class NameExpr extends Expr {
  final String name;
  const NameExpr(this.name, int line) : super(line);
}

class BinaryExpr extends Expr {
  final Expr left;
  final String op;
  final Expr right;
  const BinaryExpr(this.left, this.op, this.right, int line) : super(line);
}

class UnaryExpr extends Expr {
  final String op; // '-' or 'not'
  final Expr operand;
  const UnaryExpr(this.op, this.operand, int line) : super(line);
}

class LogicalExpr extends Expr {
  final Expr left;
  final String op; // 'and' or 'or'
  final Expr right;
  const LogicalExpr(this.left, this.op, this.right, int line) : super(line);
}

class CallExpr extends Expr {
  final Expr callee; // NameExpr for a plain call, or AttrExpr for method call
  final List<Expr> args;

  /// Keyword arguments like `sep=""` — only a few built-ins accept them.
  final List<(String, Expr)> kwargs;
  const CallExpr(this.callee, this.args, int line, [this.kwargs = const []])
    : super(line);
}

/// Attribute access, used only for method calls like `.append()` and for
/// module functions like `random.randint()`.
class AttrExpr extends Expr {
  final Expr object;
  final String name;
  const AttrExpr(this.object, this.name, int line) : super(line);
}

class IndexExpr extends Expr {
  final Expr object;
  final Expr index;
  const IndexExpr(this.object, this.index, int line) : super(line);
}
