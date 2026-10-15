// ─── PyError ────────────────────────────────────────────────────────────────
//
// A single error type shared by the lexer, parser and evaluator. Messages are
// written for a 12-year-old: plain language, a line number, and — where we can
// guess — a gentle hint. This is thrown internally and surfaced to the UI via
// [PyRunResult.error].

/// Kind of the errors raised by the interpreter's safety limits.
const kLimitError = 'Limit';

class PyError implements Exception {
  /// Kid-friendly, one-or-two sentence description of what went wrong.
  final String message;

  /// 1-based source line the error points at, when we know it.
  final int? line;

  /// Optional nudge toward the fix (e.g. a did-you-mean suggestion).
  final String? hint;

  /// The Python error name (`ZeroDivisionError`, `ValueError`, …) that a
  /// `try`/`except` matches against. [kLimitError] marks the safety limits,
  /// which a program can never catch.
  final String kind;

  /// What `str(e)` shows in `except … as e` — the real Python wording, where
  /// it differs from the friendlier [message].
  final String? pyMessage;

  const PyError(
    this.message, {
    this.line,
    this.hint,
    this.kind = 'Exception',
    this.pyMessage,
  });

  @override
  String toString() {
    final where = line != null ? 'Line $line: ' : '';
    final tip = hint != null ? '\n💡 $hint' : '';
    return '$where$message$tip';
  }
}
