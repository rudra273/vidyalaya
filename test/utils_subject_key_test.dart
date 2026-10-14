import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/app/theme.dart';
import 'package:vidyalaya/widgets/calm_widgets.dart';

void main() {
  test('specific book subjects resolve to their subject family', () {
    expect(canonicalSubjectKey('hindi_malhar'), 'hindi');
    expect(canonicalSubjectKey('english_poorvi'), 'english');
    expect(canonicalSubjectKey('maths_part_1'), 'maths');
    expect(canonicalSubjectKey('math_algebra'), 'math');
    expect(canonicalSubjectKey('social_part_2'), 'social');
    expect(canonicalSubjectKey('history_civics'), 'social');
    expect(canonicalSubjectKey('life_science'), 'science');
    expect(canonicalSubjectKey('science'), 'science');
    expect(canonicalSubjectKey('evs'), 'evs');
  });

  test('subject meta shows the family icon for specific subjects', () {
    expect(subjectMeta('hindi_malhar').glyph, 'अ');
    expect(subjectMeta('maths_part_1').icon, subjectMeta('maths').icon);
    expect(subjectMeta('physical_science').icon, subjectMeta('science').icon);
  });
}
