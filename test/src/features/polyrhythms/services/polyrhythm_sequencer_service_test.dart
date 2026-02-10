import 'package:flutter_test/flutter_test.dart';
import 'package:jazz_practice_tools/src/common/click_sounds.dart';
import 'package:jazz_practice_tools/src/features/polyrhythms/services/polyrhythm_sequencer_service.dart';

import '../../../common/mock_audio_service.dart';

void main() {
  late MockAudioService mockAudio;
  late PolyrhythmSequencerService sequencer;

  setUp(() {
    mockAudio = MockAudioService();
    sequencer = PolyrhythmSequencerService(audioService: mockAudio);
  });

  List<int> soundTicks() =>
      mockAudio.scheduledSounds.map((c) => c.tick).toList();
  List<int> soundKeys() =>
      mockAudio.scheduledSounds.map((c) => c.key).toList();

  group('two-voice timing', () {
    test('3:4 at 600 BPM schedules correctly', () async {
      // A interval = 100ms, cycle = 300ms
      // B interval = 300/4 = 75ms
      sequencer.a = 3;
      sequencer.b = 4;
      sequencer.bpm = 600;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // In 200ms lookahead:
      // A: 0, 100, 200
      // B: 0, 75, 150
      // Combined sorted unique: 0, 75, 100, 150, 200
      expect(soundTicks(), equals([0, 0, 75, 100, 150, 200]));
    });

    test('voice A uses polyA key', () async {
      sequencer.a = 1;
      sequencer.b = 1;
      sequencer.bpm = 120;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Both hit at tick 0
      expect(soundKeys(), contains(ClickSound.polyA));
    });

    test('voice B uses polyB key', () async {
      sequencer.a = 1;
      sequencer.b = 1;
      sequencer.bpm = 120;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(soundKeys(), contains(ClickSound.polyB));
    });
  });

  group('subdivision', () {
    test('subdivision adds LCM ticks', () async {
      // 2:3, bpm=600 → A interval=100ms, cycle=200ms
      // B interval = 200/3 = 66.67ms
      // LCM(2,3)=6, sub interval = 200/6 = 33.33ms
      sequencer.a = 2;
      sequencer.b = 3;
      sequencer.bpm = 600;
      sequencer.showSubdivision = true;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Sub ticks that don't overlap A or B get polySub key
      final subSounds = mockAudio.scheduledSounds
          .where((c) => c.key == ClickSound.polySub)
          .toList();
      expect(subSounds, isNotEmpty);
    });

    test('subdivision not scheduled at A or B times', () async {
      sequencer.a = 2;
      sequencer.b = 3;
      sequencer.bpm = 600;
      sequencer.showSubdivision = true;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Get ticks where A or B was scheduled
      final abTicks = mockAudio.scheduledSounds
          .where(
              (c) => c.key == ClickSound.polyA || c.key == ClickSound.polyB)
          .map((c) => c.tick)
          .toSet();

      // Sub ticks should not overlap with A/B ticks
      final subTicks = mockAudio.scheduledSounds
          .where((c) => c.key == ClickSound.polySub)
          .map((c) => c.tick);

      for (final t in subTicks) {
        expect(abTicks.contains(t), isFalse);
      }
    });

    test('subdivision fills entire cycle', () async {
      // 3:2, bpm=600 → cycle=300ms, LCM=6, sub interval=50ms
      sequencer.a = 3;
      sequencer.b = 2;
      sequencer.bpm = 600;
      sequencer.showSubdivision = true;
      mockAudio.currentTick = 0;

      await sequencer.start();

      mockAudio.currentTick = 100;

      await sequencer.stop();

      final subTicks = mockAudio.scheduledSounds
          .where((c) => c.key == ClickSound.polySub)
          .map((c) => c.tick)
          .toList();
      // Sub at 50 is non-overlapping with A(0,100,200) or B(0,150)
      expect(subTicks, contains(50));
      // Verify no premature second-cycle A ticks (would be at 300)
      final aTicks = mockAudio.scheduledSounds
          .where((c) => c.key == ClickSound.polyA)
          .map((c) => c.tick)
          .toList();
      expect(aTicks, isNot(contains(300)));
    });

    test('no subdivision when disabled', () async {
      sequencer.a = 2;
      sequencer.b = 3;
      sequencer.bpm = 600;
      sequencer.showSubdivision = false;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      final subSounds = mockAudio.scheduledSounds
          .where((c) => c.key == ClickSound.polySub)
          .toList();
      expect(subSounds, isEmpty);
    });
  });

  group('callbacks', () {
    test('onBeat fires with indices', () async {
      sequencer.a = 2;
      sequencer.b = 2;
      sequencer.bpm = 600;
      mockAudio.currentTick = 0;

      final aIndices = <int>[];
      final bIndices = <int>[];
      sequencer.onBeat = (a, b) {
        aIndices.add(a);
        bIndices.add(b);
      };

      await sequencer.start();

      // Advance time so stop() flushes pending beat callbacks
      mockAudio.currentTick = 200;
      await sequencer.stop();

      expect(aIndices, isNotEmpty);
      expect(bIndices, isNotEmpty);
    });
  });

  group('stop', () {
    test('stop calls stopAllNotes', () async {
      mockAudio.currentTick = 0;
      await sequencer.start();
      await sequencer.stop();
      expect(mockAudio.stopAllCalled, isTrue);
    });
  });
}
