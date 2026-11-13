import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/models/ai_image_draft.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';
import 'package:vidyalaya/data/services/ai_image_recovery.dart';

class _Picker extends Fake implements ImagePicker {
  LostDataResponse response = LostDataResponse.empty();
  bool throws = false;
  int calls = 0;

  @override
  Future<LostDataResponse> retrieveLostData() async {
    calls++;
    if (throws) throw PlatformException(code: 'picker_error');
    return response;
  }
}

const draft = AiImageDraft(
  uid: 'student-a',
  board: 'scert_odisha',
  classNo: 8,
  channel: 'learn_assist',
  subject: 'Science',
  text: 'Explain this diagram',
  language: 'or',
  style: 'steps',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UserPrefsRepository prefs;
  late _Picker picker;

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    SharedPreferences.setMockInitialValues({});
    prefs = UserPrefsRepository(await SharedPreferences.getInstance());
    picker = _Picker();
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test(
    'restart restores the selected image, conversation and composer once',
    () async {
      await prefs.saveAiImageDraft(draft);
      picker.response = LostDataResponse(files: [XFile('/tmp/question.jpg')]);
      // A new service represents a new process, with only persisted state.
      final recovery = AiImageRecovery(prefs, picker: picker);
      await recovery.recover('student-a');
      final location = Uri.parse(recovery.initialLocation!);
      expect(location.path, '/learn/ai');
      expect(location.queryParameters, {
        'channel': 'learn_assist',
        'subject': 'Science',
        'resume': '1',
        'style': 'steps',
      });
      expect(location.queryParameters.containsKey('camera'), false);
      final result = recovery.takeRecovered()!;
      expect(result.file!.path, '/tmp/question.jpg');
      expect(result.draft.toJson(), draft.toJson());
      expect(result.failed, false);
      expect(recovery.takeRecovered(), isNull);
      expect(prefs.getAiImageDraft(), isNull);
      final nextLaunch = AiImageRecovery(prefs, picker: picker);
      await nextLaunch.recover('student-a');
      expect(nextLaunch.initialLocation, isNull);
    },
  );

  test('cancel after destruction still returns to the composer', () async {
    await prefs.saveAiImageDraft(draft);
    final recovery = AiImageRecovery(prefs, picker: picker);
    await recovery.recover('student-a');
    expect(recovery.initialLocation, isNotNull);
    final result = recovery.takeRecovered()!;
    expect(result.file, isNull);
    expect(result.draft.text, draft.text);
    expect(result.failed, false);
  });

  for (final throws in [false, true]) {
    test('picker failure preserves draft (throws=$throws)', () async {
      await prefs.saveAiImageDraft(draft);
      picker.throws = throws;
      picker.response = LostDataResponse(
        exception: PlatformException(code: 'camera_error'),
      );
      final recovery = AiImageRecovery(prefs, picker: picker);
      await recovery.recover('student-a');
      final result = recovery.takeRecovered()!;
      expect(result.failed, true);
      expect(result.draft.text, draft.text);
      expect(prefs.getAiImageDraft(), isNull);
    });
  }

  test('another account cannot recover the previous student draft', () async {
    await prefs.saveAiImageDraft(draft);
    picker.response = LostDataResponse(files: [XFile('/tmp/private.jpg')]);
    final recovery = AiImageRecovery(prefs, picker: picker);
    await recovery.recover('student-b');
    expect(recovery.initialLocation, isNull);
    expect(recovery.takeRecovered(), isNull);
    expect(prefs.getAiImageDraft(), isNull);
    expect(picker.calls, 1);
  });

  test('normal startup does not redirect or attach orphaned images', () async {
    picker.response = LostDataResponse(files: [XFile('/tmp/orphan.jpg')]);
    final recovery = AiImageRecovery(prefs, picker: picker);
    await recovery.recover('student-a');
    expect(recovery.initialLocation, isNull);
    expect(recovery.takeRecovered(), isNull);
  });

  test('iOS never calls the Android-only lost-data API', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final recovery = AiImageRecovery(prefs, picker: picker);
    await recovery.recover('student-a');
    expect(picker.calls, 0);
  });
}
