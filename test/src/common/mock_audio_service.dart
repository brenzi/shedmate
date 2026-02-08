import 'package:jazz_practice_tools/src/common/audio_service.dart';

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

  @override
  Future<void> scheduleNote(int tick, int midiNote, int durationMs) async {
    scheduledNotes.add((
      tick: tick,
      midiNote: midiNote,
      durationMs: durationMs,
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
