import 'package:flutter_midi_pro/flutter_midi_pro.dart';

class AudioService {
  AudioService({MidiPro? midiPro}) : _midi = midiPro ?? MidiPro();

  final MidiPro _midi;
  late int _sfId;
  late int _clickFluidSfId;
  late int _drumsFluidSfId;

  static const _pianoChannel = 0;
  static const _clickChannel = 1;
  static const _drumsChannel = 2;
  static const _clickDurationMs = 50;

  Future<void> init() async {
    _sfId = await _midi.loadSoundfontAsset(
      assetPath: 'assets/sf2/SalamanderC5Light.sf2',
    );

    _clickFluidSfId = await _midi.loadSoundfontAssetIntoSynth(
      existingSfId: _sfId,
      assetPath: 'assets/sf2/click.sf2',
    );

    await _midi.selectInstrumentBySfontId(
      sfId: _sfId,
      channel: _clickChannel,
      fluidSfontId: _clickFluidSfId,
      bank: 0,
      program: 0,
    );

    _drumsFluidSfId = await _midi.loadSoundfontAssetIntoSynth(
      existingSfId: _sfId,
      assetPath: 'assets/sf2/drums.sf2',
    );

    await _midi.selectInstrumentBySfontId(
      sfId: _sfId,
      channel: _drumsChannel,
      fluidSfontId: _drumsFluidSfId,
      bank: 128,
      program: 0,
    );

    await _midi.createSequencer(sfId: _sfId);
  }

  Future<int> getCurrentTick() => _midi.getSequencerTick(sfId: _sfId);

  Future<void> scheduleNote(int tick, int midiNote, int durationMs) async {
    await _midi.scheduleNoteOn(
      sfId: _sfId,
      tick: tick,
      channel: _pianoChannel,
      key: midiNote,
      velocity: 100,
    );
    await _midi.scheduleNoteOff(
      sfId: _sfId,
      tick: tick + durationMs,
      channel: _pianoChannel,
      key: midiNote,
    );
  }

  Future<void> scheduleClick(
    int tick, {
    int key = 76,
    int velocity = 100,
  }) async {
    await _midi.scheduleNoteOn(
      sfId: _sfId,
      tick: tick,
      channel: _clickChannel,
      key: key,
      velocity: velocity,
    );
    await _midi.scheduleNoteOff(
      sfId: _sfId,
      tick: tick + _clickDurationMs,
      channel: _clickChannel,
      key: key,
    );
  }

  Future<void> scheduleDrumHit(
    int tick, {
    int key = 49,
    int velocity = 100,
  }) async {
    await _midi.scheduleNoteOn(
      sfId: _sfId,
      tick: tick,
      channel: _drumsChannel,
      key: key,
      velocity: velocity,
    );
    await _midi.scheduleNoteOff(
      sfId: _sfId,
      tick: tick + _clickDurationMs,
      channel: _drumsChannel,
      key: key,
    );
  }

  Future<void> stopAllNotes() => _midi.stopAllNotes(sfId: _sfId);

  Future<void> dispose() async {
    await _midi.deleteSequencer(sfId: _sfId);
    await _midi.dispose();
  }
}
