// ─── PyError ────────────────────────────────────────────────────────────────
//
// A single error type shared by the lexer, parser and evaluator. Messages are
// written for a 12-year-old: plain language, a line number, and — where we can
// guess — a gentle hint. This is thrown internally and surfaced to the UI via
// [PyRunResult.error].

class PyError implements Exception {
  /// Kid-friendly, one-or-two sentence description of what went wrong.
  final String message;

  /// 1-based source line the error points at, when we know it.
  final int? line;

  /// Optional nudge toward the fix (e.g. a did-you-mean suggestion).
  final String? hint;

  const PyError(this.message, {this.line, this.hint});

  @override
  String toString() {
    final where = line != null ? 'Line $line: ' : '';
    final tip = hint != null ? '\n💡 $hint' : '';
    return '$where$message$tip';
  }
}
