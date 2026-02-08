class MetronomeState {
  const MetronomeState({
    this.bpm = 120,
    this.beatsPerBar = 4,
    this.beatToggles = const [true, true, true, true],
    this.offbeatToggles = const [false, false, false, false],
    this.accentBeat1 = true,
    this.barsPerSection = 0,
    this.isPlaying = false,
    this.currentBeat = 0,
    this.currentBar = 0,
  });

  final int bpm;
  final int beatsPerBar;
  final List<bool> beatToggles;
  final List<bool> offbeatToggles;
  final bool accentBeat1;
  final int barsPerSection; // 0 = disabled
  final bool isPlaying;
  final int currentBeat;
  final int currentBar;

  MetronomeState copyWith({
    int? bpm,
    int? beatsPerBar,
    List<bool>? beatToggles,
    List<bool>? offbeatToggles,
    bool? accentBeat1,
    int? barsPerSection,
    bool? isPlaying,
    int? currentBeat,
    int? currentBar,
  }) {
    return MetronomeState(
      bpm: bpm ?? this.bpm,
      beatsPerBar: beatsPerBar ?? this.beatsPerBar,
      beatToggles: beatToggles ?? this.beatToggles,
      offbeatToggles: offbeatToggles ?? this.offbeatToggles,
      accentBeat1: accentBeat1 ?? this.accentBeat1,
      barsPerSection: barsPerSection ?? this.barsPerSection,
      isPlaying: isPlaying ?? this.isPlaying,
      currentBeat: currentBeat ?? this.currentBeat,
      currentBar: currentBar ?? this.currentBar,
    );
  }
}
