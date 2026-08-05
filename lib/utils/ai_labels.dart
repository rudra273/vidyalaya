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

/// Backend subject key → title case ("social_science" → "Social Science").
String formatSubject(String subject) {
  return subject
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
