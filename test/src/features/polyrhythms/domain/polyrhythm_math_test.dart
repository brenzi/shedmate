import 'package:flutter_test/flutter_test.dart';
import 'package:shedmate/src/features/polyrhythms/domain/polyrhythm_math.dart';

void main() {
  group('gcd', () {
    test('gcd(3, 4) = 1', () => expect(gcd(3, 4), 1));
    test('gcd(6, 4) = 2', () => expect(gcd(6, 4), 2));
    test('gcd(12, 8) = 4', () => expect(gcd(12, 8), 4));
    test('gcd(7, 7) = 7', () => expect(gcd(7, 7), 7));
    test('gcd(1, 5) = 1', () => expect(gcd(1, 5), 1));
  });

  group('lcm', () {
    test('lcm(3, 4) = 12', () => expect(lcm(3, 4), 12));
    test('lcm(6, 4) = 12', () => expect(lcm(6, 4), 12));
    test('lcm(5, 3) = 15', () => expect(lcm(5, 3), 15));
    test('lcm(7, 7) = 7', () => expect(lcm(7, 7), 7));
    test('lcm(2, 3) = 6', () => expect(lcm(2, 3), 6));
  });

  group('beatPositions', () {
    test('3 beats', () {
      final pos = beatPositions(3);
      expect(pos.length, 3);
      expect(pos[0], closeTo(0.0, 0.001));
      expect(pos[1], closeTo(1 / 3, 0.001));
      expect(pos[2], closeTo(2 / 3, 0.001));
    });

    test('4 beats', () {
      final pos = beatPositions(4);
      expect(pos, [0.0, 0.25, 0.5, 0.75]);
    });

    test('1 beat', () {
      expect(beatPositions(1), [0.0]);
    });
  });
}
