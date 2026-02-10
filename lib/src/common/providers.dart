import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

/// Index of the currently selected tab (0=Notes, 1=Metronome, 2=Polyrhythms).
final activeTabProvider = StateProvider<int>((ref) => 0);
