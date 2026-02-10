import 'package:wakelock_plus/wakelock_plus.dart';

/// Service to manage wake lock state for keeping screen on while playing
class WakeLockService {
  WakeLockService._();
  static final instance = WakeLockService._();

  int _activeCount = 0;

  /// Enable wake lock (called when a feature starts playing)
  Future<void> enable() async {
    _activeCount++;
    if (_activeCount == 1) {
      await WakelockPlus.enable();
    }
  }

  /// Disable wake lock (called when a feature stops playing)
  Future<void> disable() async {
    if (_activeCount > 0) {
      _activeCount--;
    }
    if (_activeCount == 0) {
      await WakelockPlus.disable();
    }
  }

  /// For testing: reset the counter
  void reset() {
    _activeCount = 0;
  }
}
