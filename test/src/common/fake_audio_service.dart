import 'package:shedmate/src/common/audio_service.dart';

class FakeAudioService extends AudioService {
  FakeAudioService() : super(midiPro: null);

  @override
  Future<void> init() async {}
  @override
  Future<int> getCurrentTick() async => 0;
  @override
  Future<void> scheduleNote(
    int tick,
    int midiNote,
    int durationMs, {
    int velocity = 100,
  }) async {}
  @override
  Future<void> scheduleClick(
    int tick, {
    int key = 76,
    int velocity = 100,
  }) async {}
  @override
  Future<void> scheduleDrumHit(
    int tick, {
    int key = 49,
    int velocity = 100,
  }) async {}
  @override
  Future<void> scheduleSound(
    int tick, {
    required int channel,
    required int key,
    required int velocity,
  }) async {}
  @override
  Future<void> stopAllNotes() async {}
  @override
  Future<void> dispose() async {}
}
