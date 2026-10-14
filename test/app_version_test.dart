import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/app/app_info.dart';

void main() {
  test('the version shown in the app matches pubspec.yaml', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    final name = line.split(':')[1].trim().split('+').first;

    expect(kAppVersionName, name);
  });
}
