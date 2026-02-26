import 'package:shedmate/src/common/audio_service.dart';

class MockAudioService extends AudioService {
  MockAudioService() : super(midiPro: null);

  int currentTick = 0;
  final scheduledNotes = <({int tick, int midiNote, int durationMs})>[];
  final scheduledClicks = <({int tick, int key, int velocity})>[];
  final scheduledDrumHits = <({int tick, int key, int velocity})>[];
  bool stopAllCalled = false;

  @override
  Future<void> init() async {}

  @override
  Future<int> getCurrentTick() async => currentTick;

  final scheduledSounds = <({int tick, int channel, int key, int velocity})>[];

  @override
  Future<void> scheduleNote(
    int tick,
    int midiNote,
    int durationMs, {
    int velocity = 100,
  }) async {
    scheduledNotes.add((
      tick: tick,
      midiNote: midiNote,
      durationMs: durationMs,
    ));
  }

  @override
  Future<void> scheduleSound(
    int tick, {
    required int channel,
    required int key,
    required int velocity,
  }) async {
    scheduledSounds.add((
      tick: tick,
      channel: channel,
      key: key,
      velocity: velocity,
    ));
  }

  @override
  Future<void> scheduleClick(
    int tick, {
    int key = 76,
    int velocity = 100,
  }) async {
    scheduledClicks.add((tick: tick, key: key, velocity: velocity));
  }

  @override
  Future<void> scheduleDrumHit(
    int tick, {
    int key = 49,
    int velocity = 100,
  }) async {
    scheduledDrumHits.add((tick: tick, key: key, velocity: velocity));
  }

  @override
  Future<void> stopAllNotes() async {
    stopAllCalled = true;
  }

  @override
  Future<void> dispose() async {}
}
