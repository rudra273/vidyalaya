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

class ForStmt extends Stmt {
  final String varName;
  final Expr iterable;
  final List<Stmt> body;
  const ForStmt(this.varName, this.iterable, this.body, int line)
      : super(line);
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

/// f"...{expr}...": alternating literal chunks and embedded expressions.
class FStringExpr extends Expr {
  final List<Object> parts; // String (literal) or Expr (interpolated)
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
  const CallExpr(this.callee, this.args, int line) : super(line);
}

/// Attribute access, used only for the handful of methods we support (.append).
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
