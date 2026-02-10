class SoundPreset {
  const SoundPreset(this.name, this.channel, this.key);

  /// Display name, e.g. "High Woodblock", "Cowbell"
  final String name;

  /// MIDI channel: 1 = click.sf2 woodblock, 2 = drums.sf2 GM percussion
  final int channel;

  /// MIDI key number
  final int key;
}

/// All available percussion sounds.
///
/// Channel 1 = click.sf2 (woodblock pitches).
/// Channel 2 = drums.sf2 (GM Standard kit, keys 27–87).
const List<SoundPreset> soundCatalog = [
  // --- Woodblock (click.sf2, channel 1) ---
  SoundPreset('Woodblock C4', 1, 60),
  SoundPreset('Woodblock E4', 1, 64),
  SoundPreset('Woodblock G4', 1, 67),
  SoundPreset('Woodblock Bb4', 1, 70),
  SoundPreset('Woodblock C5', 1, 72),
  SoundPreset('Woodblock C#5', 1, 73),
  SoundPreset('Woodblock E5', 1, 76),
  SoundPreset('Woodblock F#5', 1, 78),
  SoundPreset('Woodblock Ab5', 1, 80),
  SoundPreset('Woodblock C6', 1, 84),

  // --- GM Standard Drums (drums.sf2, channel 2) ---
  SoundPreset('High Q', 2, 27),
  SoundPreset('Slap', 2, 28),
  SoundPreset('Scratch Push', 2, 29),
  SoundPreset('Scratch Pull', 2, 30),
  SoundPreset('Sticks', 2, 31),
  SoundPreset('Square Click', 2, 32),
  SoundPreset('Metronome Click', 2, 33),
  SoundPreset('Metronome Bell', 2, 34),
  SoundPreset('Bass Drum 2', 2, 35),
  SoundPreset('Bass Drum 1', 2, 36),
  SoundPreset('Side Stick', 2, 37),
  SoundPreset('Snare Drum 1', 2, 38),
  SoundPreset('Hand Clap', 2, 39),
  SoundPreset('Snare Drum 2', 2, 40),
  SoundPreset('Low Floor Tom', 2, 41),
  SoundPreset('Closed Hi-Hat', 2, 42),
  SoundPreset('High Floor Tom', 2, 43),
  SoundPreset('Pedal Hi-Hat', 2, 44),
  SoundPreset('Low Tom', 2, 45),
  SoundPreset('Open Hi-Hat', 2, 46),
  SoundPreset('Low-Mid Tom', 2, 47),
  SoundPreset('Hi-Mid Tom', 2, 48),
  SoundPreset('Crash Cymbal 1', 2, 49),
  SoundPreset('High Tom', 2, 50),
  SoundPreset('Ride Cymbal 1', 2, 51),
  SoundPreset('Chinese Cymbal', 2, 52),
  SoundPreset('Ride Bell', 2, 53),
  SoundPreset('Tambourine', 2, 54),
  SoundPreset('Splash Cymbal', 2, 55),
  SoundPreset('Cowbell', 2, 56),
  SoundPreset('Crash Cymbal 2', 2, 57),
  SoundPreset('Vibra Slap', 2, 58),
  SoundPreset('Ride Cymbal 2', 2, 59),
  SoundPreset('Hi Bongo', 2, 60),
  SoundPreset('Low Bongo', 2, 61),
  SoundPreset('Mute Hi Conga', 2, 62),
  SoundPreset('Open Hi Conga', 2, 63),
  SoundPreset('Low Conga', 2, 64),
  SoundPreset('High Timbale', 2, 65),
  SoundPreset('Low Timbale', 2, 66),
  SoundPreset('High Agogo', 2, 67),
  SoundPreset('Low Agogo', 2, 68),
  SoundPreset('Cabasa', 2, 69),
  SoundPreset('Maracas', 2, 70),
  SoundPreset('Short Whistle', 2, 71),
  SoundPreset('Long Whistle', 2, 72),
  SoundPreset('Short Guiro', 2, 73),
  SoundPreset('Long Guiro', 2, 74),
  SoundPreset('Claves', 2, 75),
  SoundPreset('Hi Wood Block', 2, 76),
  SoundPreset('Low Wood Block', 2, 77),
  SoundPreset('Mute Cuica', 2, 78),
  SoundPreset('Open Cuica', 2, 79),
  SoundPreset('Mute Triangle', 2, 80),
  SoundPreset('Open Triangle', 2, 81),
  SoundPreset('Shaker', 2, 82),
  SoundPreset('Jingle Bell', 2, 83),
  SoundPreset('Bell Tree', 2, 84),
  SoundPreset('Castanets', 2, 85),
  SoundPreset('Mute Surdo', 2, 86),
  SoundPreset('Open Surdo', 2, 87),
];

/// Index of a specific sound in [soundCatalog] by channel and key.
int soundIndexOf(int channel, int key) =>
    soundCatalog.indexWhere((s) => s.channel == channel && s.key == key);
