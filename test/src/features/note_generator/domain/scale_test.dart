import 'package:flutter_test/flutter_test.dart';
import 'package:shedmate/src/features/note_generator/domain/scale.dart';

void main() {
  test('C major pitch classes', () {
    expect(scalePitchClasses(0, ScaleType.major), {0, 2, 4, 5, 7, 9, 11});
  });

  test('D major wraps correctly', () {
    // D=2, intervals [0,2,4,5,7,9,11] → {2,4,6,7,9,11,1}
    expect(scalePitchClasses(2, ScaleType.major), {2, 4, 6, 7, 9, 11, 1});
  });

  test('all scale types have correct interval count', () {
    expect(ScaleType.major.intervals.length, 7);
    expect(ScaleType.minor.intervals.length, 7);
    expect(ScaleType.melodicMinor.intervals.length, 7);
    expect(ScaleType.harmonicMinor.intervals.length, 7);
    expect(ScaleType.wholeTone.intervals.length, 6);
    expect(ScaleType.halfWholeTone.intervals.length, 8);
  });
}
