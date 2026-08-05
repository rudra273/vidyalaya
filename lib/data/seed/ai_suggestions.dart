// ─── AI starter questions ────────────────────────────────────────────────
// Subject-specific starters shown on the AI hub and on the fresh chat screen.
// Both surfaces read from here so they never drift apart. Subjects without
// their own list fall back to the mixed set (one per covered subject).

const Map<String, List<String>> kAiSubjectSuggestions = {
  'maths': [
    'How do I find the area of a triangle?',
    'Explain fractions with a simple example',
    'What is the difference between LCM and HCF?',
  ],
  'science': [
    'Why does the moon change shape?',
    'How does the water cycle work?',
    'What is photosynthesis in simple words?',
  ],
  'english': [
    'What is the difference between a noun and a verb?',
    'Help me write a paragraph about my school',
    'When do I use "a", "an" and "the"?',
  ],
};

const List<String> kAiMixedSuggestions = [
  'How do I find the area of a triangle?',
  'Why does the moon change shape?',
  'Help me write a paragraph about my school',
];

/// Starter questions for [subject], or the mixed set for a cross-subject
/// conversation (null) or a subject with no list of its own.
List<String> aiSuggestionsFor(String? subject) {
  if (subject == null) return kAiMixedSuggestions;
  return kAiSubjectSuggestions[subject.toLowerCase()] ?? kAiMixedSuggestions;
}
