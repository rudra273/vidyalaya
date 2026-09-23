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

/// Identifies one book in the vector DB.
///
/// A subject key alone does NOT identify a book: it is reused across classes and
/// boards for entirely different books. SCERT uses `sanskrit` for four different
/// books across classes 7-10, and a second board may well use `maths` for a book
/// in another medium. Anything that describes a book must therefore be keyed on
/// the full triple, matching the backend's `_TOC_QUERIES`.
typedef BookKey = ({String board, int classNo, String subject});

/// Labels whose title case reads poorly for students, per book.
///
/// Classes 9-10 split several subjects into separate books, so the vector DB
/// uses keys like `math_algebra` and `history_civics`. Those keys are the wire
/// contract with the backend retrieval filter and must be sent unchanged — this
/// map only affects what the student reads on screen.
///
/// Only books whose title case is not already readable need an entry; the rest
/// fall through to [_titleCase]. Records compare structurally, so they work as
/// map keys directly.
const Map<BookKey, String> _subjectLabels = {
  // ─── SCERT Odisha, classes 9-10 — subjects split into separate books ──────
  (board: 'scert_odisha', classNo: 9, subject: 'math_algebra'): 'Maths (Algebra)',
  (board: 'scert_odisha', classNo: 9, subject: 'math_geometry'): 'Maths (Geometry)',
  (board: 'scert_odisha', classNo: 9, subject: 'history'): 'History & Civics',
  (board: 'scert_odisha', classNo: 9, subject: 'geography'): 'Geography & Economics',
  (board: 'scert_odisha', classNo: 10, subject: 'math_algebra'): 'Maths (Algebra)',
  (board: 'scert_odisha', classNo: 10, subject: 'math_geometry'): 'Maths (Geometry)',
  (board: 'scert_odisha', classNo: 10, subject: 'history_civics'): 'History & Civics',
  (board: 'scert_odisha', classNo: 10, subject: 'geography_economics'):
      'Geography & Economics',
};

/// Backend subject key → the label students see.
///
/// Pass the [board] and [classNo] the subject belongs to so the right book's
/// label is used. Falls back to title case ("social_science" → "Social
/// Science"), which is correct for most books and keeps a newly ingested subject
/// readable before anyone adds it to [_subjectLabels].
String formatSubject(String subject, {required String board, required int classNo}) {
  final key = (
    board: board.trim().toLowerCase(),
    classNo: classNo,
    subject: subject.trim().toLowerCase(),
  );
  return _subjectLabels[key] ?? _titleCase(subject);
}

String _titleCase(String subject) {
  return subject
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
