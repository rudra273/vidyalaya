import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/progress_provider.dart';
import 'package:vidyalaya/widgets/calm_widgets.dart';

Future<ProviderContainer> _container(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('My Learning subject pages', () {
    test('shows pages saved under the subject keys books actually use', () async {
      final container = await _container({
        'subject_progress_maths': 12,
        'subject_progress_science': 5,
        'subject_progress_odia': 3,
      });

      expect(container.read(progressProvider).subjectPages, {
        'Maths': 12,
        'Science': 5,
        'Odia': 3,
      });
    });

    test('merges variants of one subject into a single entry', () async {
      final container = await _container({
        'subject_progress_maths': 5,
        'subject_progress_math': 2,
        'subject_progress_math_algebra': 3,
        'subject_progress_social_science': 4,
        'subject_progress_history_civics': 2,
        'subject_progress_hindi_malhar': 1,
        'subject_progress_hindi': 6,
      });

      expect(container.read(progressProvider).subjectPages, {
        'Maths': 10,
        'Social': 6,
        'Hindi': 7,
      });
    });

    test('keeps subjects with no family and skips empty ones', () async {
      final container = await _container({
        'subject_progress_evs': 4,
        'subject_progress_art': 2,
        'subject_progress_physical_education': 1,
        'subject_progress_science': 0,
      });

      expect(container.read(progressProvider).subjectPages, {
        'EVS': 4,
        'Art': 2,
        'Physical Education': 1,
      });
    });

    test('ignores other stored values and reads a page just recorded', () async {
      final container = await _container({
        'total_pages_read': 40,
        'ai_sessions_total': 3,
      });
      expect(container.read(progressProvider).subjectPages, isEmpty);

      await UserPrefsRepository(
        container.read(sharedPreferencesProvider),
      ).addPagesRead(7, 'english');
      container.read(progressProvider.notifier).refresh();

      expect(container.read(progressProvider).subjectPages, {'English': 7});
    });
  });

  group('subjectDisplayLabel', () {
    test('uses one label per subject family', () {
      expect(subjectDisplayLabel('maths'), 'Maths');
      expect(subjectDisplayLabel('math'), 'Maths');
      expect(subjectDisplayLabel('maths_part_2'), 'Maths');
      expect(subjectDisplayLabel('life_science'), 'Science');
      expect(subjectDisplayLabel('geography_economics'), 'Social');
      expect(subjectDisplayLabel('english_poorvi'), 'English');
    });

    test('is case-insensitive and title-cases unknown keys', () {
      expect(subjectDisplayLabel('Maths'), 'Maths');
      expect(subjectDisplayLabel('pe'), 'PE');
      expect(subjectDisplayLabel('yoga'), 'Yoga');
    });
  });
}
