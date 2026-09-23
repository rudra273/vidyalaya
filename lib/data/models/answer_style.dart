// ─── Answer style ─────────────────────────────────────────────────────────
// How the student wants the next answer pitched. Chosen on the AI tab's hero
// switch and carried into the chat as a `style` query parameter.
//
// The hint is appended to the *first* message of a session only: after that the
// conversation already carries its tone, so repeating the instruction every
// turn would only burn context.

enum AnswerStyle {
  ask('ask', 'Ask', null),
  simple(
    'simple',
    'Explain simply',
    'Explain in very simple words, as if to a school student.',
  ),
  steps('steps', 'Step by step', 'Answer as clear numbered steps.');

  const AnswerStyle(this.key, this.label, this.hint);

  /// Value used in the `/learn/ai?style=` deep link.
  final String key;

  /// Label shown on the hero's switch.
  final String label;

  /// Instruction appended to the first message, or null for a plain ask.
  final String? hint;

  static AnswerStyle fromKey(String? key) {
    if (key == null) return AnswerStyle.ask;
    for (final style in values) {
      if (style.key == key) return style;
    }
    return AnswerStyle.ask;
  }
}
