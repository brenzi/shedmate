import 'package:flutter_test/flutter_test.dart';
import 'package:shedmate/src/common/click_sounds.dart';
import 'package:shedmate/src/features/metronome/services/metronome_sequencer_service.dart';

import '../../../common/mock_audio_service.dart';

void main() {
  late MockAudioService mockAudio;
  late MetronomeSequencerService sequencer;

  setUp(() {
    mockAudio = MockAudioService();
    sequencer = MetronomeSequencerService(audioService: mockAudio);
  });

  // Sounds now go through scheduleSound
  List<int> soundTicks() =>
      mockAudio.scheduledSounds.map((c) => c.tick).toList();
  List<int> soundKeys() =>
      mockAudio.scheduledSounds.map((c) => c.key).toList();
  List<int> soundVelocities() =>
      mockAudio.scheduledSounds.map((c) => c.velocity).toList();
  List<int> soundChannels() =>
      mockAudio.scheduledSounds.map((c) => c.channel).toList();

  group('basic scheduling', () {
    test('schedules sounds on start', () async {
      sequencer.bpm = 120;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.scheduledSounds, isNotEmpty);
    });

    test('schedules correct number of beats in lookahead', () async {
      sequencer.bpm = 600; // 100ms per beat
      sequencer.beatsPerBar = 4;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // 200ms lookahead, 100ms interval → ticks at 0, 100, 200
      expect(soundTicks(), equals([0, 100, 200]));
    });

    test('stop calls stopAllNotes', () async {
      mockAudio.currentTick = 0;
      await sequencer.start();
      await sequencer.stop();
      expect(mockAudio.stopAllCalled, isTrue);
    });
  });

  group('beat toggles', () {
    test('disabled beat produces no sound', () async {
      sequencer.bpm = 120; // 500ms → only 1 beat in lookahead
      sequencer.beatsPerBar = 4;
      sequencer.beatToggles = [false, true, true, true];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beat 0 is off → no sound
      expect(mockAudio.scheduledSounds, isEmpty);
    });

    test('toggled beats produce sounds selectively', () async {
      sequencer.bpm = 600; // 100ms per beat
      sequencer.beatsPerBar = 4;
      sequencer.beatToggles = [true, false, true, false];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beats at 0ms(on), 100ms(off), 200ms(on)
      expect(soundTicks(), equals([0, 200]));
    });
  });

  group('offbeats', () {
    test('offbeat adds sound at half interval', () async {
      sequencer.bpm = 120; // 500ms per beat
      sequencer.beatsPerBar = 4;
      sequencer.offbeatToggles = [true, false, false, false];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beat at 0, offbeat at 250
      expect(soundTicks(), equals([0, 250]));
    });

    test('offbeat has reduced velocity', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 4;
      sequencer.offbeatToggles = [true, false, false, false];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // First sound (beat) = 100 velocity, second (offbeat) = 70% of 100 = 70
      expect(soundVelocities(), equals([100, 70]));
    });
  });

  group('accents', () {
    test('accent on beat 1 uses bar key', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 4;
      sequencer.accentBeat1 = true;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(soundKeys().first, ClickSound.accent);
    });

    test('no accent uses regular key', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 4;
      sequencer.accentBeat1 = false;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(soundKeys().first, ClickSound.regular);
    });
  });

  group('section markers', () {
    test('section start uses drum channel with section key', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 1; // 1 beat per bar
      sequencer.barsPerSection = 4;
      sequencer.accentBeat1 = true;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beat 0 = bar 0, beat 0 → section marker on drums channel
      expect(mockAudio.scheduledSounds, isNotEmpty);
      expect(mockAudio.scheduledSounds.first.key, ClickSound.section);
      expect(mockAudio.scheduledSounds.first.channel, 2); // drums channel
    });

    test('section plays when beat 1 is toggled off', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 1;
      sequencer.barsPerSection = 4;
      sequencer.beatToggles = [false];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.scheduledSounds, isNotEmpty);
      expect(mockAudio.scheduledSounds.first.key, ClickSound.section);
    });

    test('no click at section start even when beat enabled', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 1;
      sequencer.barsPerSection = 4;
      sequencer.beatToggles = [true];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Section fires sound; only one sound at tick 0 (section, not beat)
      final atZero = mockAudio.scheduledSounds.where((s) => s.tick == 0);
      expect(atZero.length, 1);
      expect(atZero.first.key, ClickSound.section);
    });

    test('section overrides accent', () async {
      sequencer.bpm = 600; // 100ms per beat
      sequencer.beatsPerBar = 2;
      sequencer.barsPerSection = 2;
      sequencer.accentBeat1 = true;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beat 0 (bar 0, beat 0) = section → drums channel
      // Beat 1 (bar 0, beat 1) = regular click
      // Beat 2 (bar 1, beat 0) = accent click (not section start)
      expect(soundKeys()[0], ClickSound.section);
      expect(soundChannels()[0], 2);
      expect(soundKeys()[1], ClickSound.regular);
      expect(soundKeys()[2], ClickSound.accent);
    });
  });

  group('onBeat callback', () {
    test('fires with beat and bar indices', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerBar = 2;
      sequencer.barsPerSection = 2;
      mockAudio.currentTick = 0;

      final beats = <int>[];
      final bars = <int>[];
      sequencer.onBeat = (beat, bar) {
        beats.add(beat);
        bars.add(bar);
      };

      await sequencer.start();

      // Advance time past all scheduled beats so stop() flushes them
      mockAudio.currentTick = 200;
      await sequencer.stop();

      // 3 beats in 200ms lookahead at 100ms interval
      expect(beats, equals([0, 1, 0]));
      expect(bars, equals([0, 0, 1]));
    });
  });
}
