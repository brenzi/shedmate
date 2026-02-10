import 'sound_catalog.dart';

class TrackConfig {
  const TrackConfig({required this.soundIndex, this.volume = 0.79});

  /// Index into [soundCatalog].
  final int soundIndex;

  /// 0.0–1.0, mapped to MIDI velocity 0–127.
  final double volume;

  int get velocity => (volume * 127).round().clamp(0, 127);
  int get channel => soundCatalog[soundIndex].channel;
  int get key => soundCatalog[soundIndex].key;

  Map<String, dynamic> toJson() => {'soundIndex': soundIndex, 'volume': volume};

  factory TrackConfig.fromJson(Map<String, dynamic> j, TrackConfig fallback) {
    return TrackConfig(
      soundIndex: j['soundIndex'] as int? ?? fallback.soundIndex,
      volume: (j['volume'] as num?)?.toDouble() ?? fallback.volume,
    );
  }

  TrackConfig copyWith({int? soundIndex, double? volume}) => TrackConfig(
    soundIndex: soundIndex ?? this.soundIndex,
    volume: volume ?? this.volume,
  );
}

class MixerState {
  const MixerState({
    this.noteGenPianoVolume = 0.95,
    this.noteGenClick = _defaultClick,
    this.metronomeBeat = _defaultBeat,
    this.metronomeBar = _defaultBar,
    this.metronomeSection = _defaultSection,
    this.polyA = _defaultPolyA,
    this.polyB = _defaultPolyB,
    this.polySub = _defaultPolySub,
  });

  // Note Generator
  final double noteGenPianoVolume; // piano has no sound choice
  final TrackConfig noteGenClick;

  // Metronome
  final TrackConfig metronomeBeat;
  final TrackConfig metronomeBar;
  final TrackConfig metronomeSection;

  // Polyrhythms
  final TrackConfig polyA;
  final TrackConfig polyB;
  final TrackConfig polySub;

  static const _defaultVolume = 0.79; // velocity 100/127

  // Woodblock E5 (key 76, channel 1) — matches ClickSound.regular
  static const _defaultClick = TrackConfig(
    soundIndex: 6, // Woodblock E5
    volume: 0.50,
  );

  // Metronome beat
  static const _defaultBeat = TrackConfig(
    soundIndex: 6, // Woodblock E5
    volume: 0.80,
  );

  // Woodblock F#5 (key 78, channel 1) — matches ClickSound.accent
  static const _defaultBar = TrackConfig(
    soundIndex: 7, // Woodblock F#5
    volume: 0.90,
  );

  // Vibra Slap (key 58, channel 2)
  static const _defaultSection = TrackConfig(
    soundIndex: 41, // Vibra Slap
    volume: 1.0,
  );

  // Woodblock E5 (key 76) — matches ClickSound.polyA
  static const _defaultPolyA = TrackConfig(
    soundIndex: 6, // Woodblock E5
    volume: _defaultVolume,
  );

  // Woodblock C#5 (key 73) — matches ClickSound.polyB
  static const _defaultPolyB = TrackConfig(
    soundIndex: 5, // Woodblock C#5
    volume: 0.63, // velocity ~80
  );

  // Woodblock Bb4 (key 70) — matches ClickSound.polySub
  static const _defaultPolySub = TrackConfig(
    soundIndex: 3, // Woodblock Bb4
    volume: 0.31, // velocity ~40
  );

  Map<String, dynamic> toJson() => {
    'noteGenPianoVolume': noteGenPianoVolume,
    'noteGenClick': noteGenClick.toJson(),
    'metronomeBeat': metronomeBeat.toJson(),
    'metronomeBar': metronomeBar.toJson(),
    'metronomeSection': metronomeSection.toJson(),
    'polyA': polyA.toJson(),
    'polyB': polyB.toJson(),
    'polySub': polySub.toJson(),
  };

  factory MixerState.fromJson(Map<String, dynamic> j) {
    const d = MixerState();
    return MixerState(
      noteGenPianoVolume:
          (j['noteGenPianoVolume'] as num?)?.toDouble() ?? d.noteGenPianoVolume,
      noteGenClick: j['noteGenClick'] is Map<String, dynamic>
          ? TrackConfig.fromJson(
              j['noteGenClick'] as Map<String, dynamic>,
              d.noteGenClick,
            )
          : d.noteGenClick,
      metronomeBeat: j['metronomeBeat'] is Map<String, dynamic>
          ? TrackConfig.fromJson(
              j['metronomeBeat'] as Map<String, dynamic>,
              d.metronomeBeat,
            )
          : d.metronomeBeat,
      metronomeBar: j['metronomeBar'] is Map<String, dynamic>
          ? TrackConfig.fromJson(
              j['metronomeBar'] as Map<String, dynamic>,
              d.metronomeBar,
            )
          : d.metronomeBar,
      metronomeSection: j['metronomeSection'] is Map<String, dynamic>
          ? TrackConfig.fromJson(
              j['metronomeSection'] as Map<String, dynamic>,
              d.metronomeSection,
            )
          : d.metronomeSection,
      polyA: j['polyA'] is Map<String, dynamic>
          ? TrackConfig.fromJson(j['polyA'] as Map<String, dynamic>, d.polyA)
          : d.polyA,
      polyB: j['polyB'] is Map<String, dynamic>
          ? TrackConfig.fromJson(j['polyB'] as Map<String, dynamic>, d.polyB)
          : d.polyB,
      polySub: j['polySub'] is Map<String, dynamic>
          ? TrackConfig.fromJson(
              j['polySub'] as Map<String, dynamic>,
              d.polySub,
            )
          : d.polySub,
    );
  }

  MixerState copyWith({
    double? noteGenPianoVolume,
    TrackConfig? noteGenClick,
    TrackConfig? metronomeBeat,
    TrackConfig? metronomeBar,
    TrackConfig? metronomeSection,
    TrackConfig? polyA,
    TrackConfig? polyB,
    TrackConfig? polySub,
  }) {
    return MixerState(
      noteGenPianoVolume: noteGenPianoVolume ?? this.noteGenPianoVolume,
      noteGenClick: noteGenClick ?? this.noteGenClick,
      metronomeBeat: metronomeBeat ?? this.metronomeBeat,
      metronomeBar: metronomeBar ?? this.metronomeBar,
      metronomeSection: metronomeSection ?? this.metronomeSection,
      polyA: polyA ?? this.polyA,
      polyB: polyB ?? this.polyB,
      polySub: polySub ?? this.polySub,
    );
  }
}
