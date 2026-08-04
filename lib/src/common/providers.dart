import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

/// Index of the currently selected tab (0=Notes, 1=Metronome, 2=Polyrhythms).
final activeTabProvider = StateProvider<int>((ref) => 0);

/// Ensures only one feature plays at a time.
final playbackCoordinatorProvider = Provider<PlaybackCoordinator>(
  (ref) => PlaybackCoordinator(),
);

class PlaybackCoordinator {
  Future<void> Function()? _stopCurrent;

  /// Call before starting playback. Stops whoever is currently playing.
  Future<void> requestPlayback(Future<void> Function() stop) async {
    await _stopCurrent?.call();
    _stopCurrent = stop;
  }

  /// Call when playback stops (user-initiated or programmatic).
  void release(Future<void> Function() stop) {
    if (_stopCurrent == stop) _stopCurrent = null;
  }
}
