import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/metronome/providers/metronome_providers.dart';
import '../../features/note_generator/providers/note_generator_providers.dart';
import '../../features/polyrhythms/providers/polyrhythm_providers.dart';

/// Which tab is currently playing, or null if nothing is playing.
final activePlaybackProvider = Provider<int?>((ref) {
  if (ref.watch(noteGeneratorProvider.select((s) => s.isPlaying))) return 0;
  if (ref.watch(metronomeProvider.select((s) => s.isPlaying))) return 1;
  if (ref.watch(polyrhythmProvider.select((s) => s.isPlaying))) return 2;
  return null;
});
