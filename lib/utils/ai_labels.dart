// ─── AI display labels ───────────────────────────────────────────────────
// Shared by the AI hub and the Q&A chat so the same plan/subject always reads
// the same way on both surfaces.

/// Backend plan key → the label students see ("free" → "Free").
String planLabel(String planKey) {
  return switch (planKey) {
    'plus' => 'Plus',
    'pro' => 'Pro',
    _ => 'Free',
  };
}

/// Subject keys whose title case reads poorly for students.
///
/// Classes 9-10 split several subjects into separate books, so the vector DB
/// uses keys like `math_algebra` and `history_civics`. Those keys are the wire
/// contract with the backend retrieval filter and must be sent unchanged — this
/// map only affects what the student reads on screen.
const Map<String, String> _subjectLabels = {
  'math_algebra': 'Maths (Algebra)',
  'math_geometry': 'Maths (Geometry)',
  'physical_science': 'Physical Science',
  'life_science': 'Life Science',
  'history_civics': 'History & Civics',
  'geography_economics': 'Geography & Economics',
  'english_grammar': 'English Grammar',
  'hindi_grammar': 'Hindi Grammar',
  'odia_grammar': 'Odia Grammar',
  'sanskrit_grammar': 'Sanskrit Grammar',
};

/// Backend subject key → the label students see ("social_science" → "Social
/// Science", "history_civics" → "History & Civics").
///
/// Falls back to title case, so a newly ingested subject still reads sensibly
/// before it is added to [_subjectLabels].
String formatSubject(String subject) {
  final label = _subjectLabels[subject];
  if (label != null) return label;

  return subject
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
