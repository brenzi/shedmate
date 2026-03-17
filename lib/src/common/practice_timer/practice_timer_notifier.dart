import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers.dart';
import 'practice_timer_state.dart';

final practiceTimerProvider =
    NotifierProvider<PracticeTimerNotifier, PracticeTimerState>(
      PracticeTimerNotifier.new,
    );

class PracticeTimerNotifier extends Notifier<PracticeTimerState> {
  late final SharedPreferences _prefs;
  Timer? _timer;
  int? _activeTab;

  static const _todayKey = 'practiceTimerToday';
  static const _logKey = 'practiceLog';

  @override
  PracticeTimerState build() {
    _prefs = ref.read(sharedPrefsProvider);
    ref.onDispose(() => _timer?.cancel());
    return _load();
  }

  PracticeTimerState _load() {
    final json = _prefs.getString(_todayKey);
    if (json == null) return PracticeTimerState(date: _todayStr());

    final loaded = PracticeTimerState.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );

    if (loaded.date != _todayStr()) {
      _archiveDay(loaded);
      return PracticeTimerState(date: _todayStr());
    }
    return loaded;
  }

  void onPlaybackChanged(int? tab) {
    if (tab == _activeTab) return;

    if (tab != null) {
      _activeTab = tab;
      _recordPracticeStart();
      _startTimer();
    } else {
      _activeTab = null;
      _stopTimer();
    }
  }

  void _recordPracticeStart() {
    if (state.practiceStart != null) return;
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    state = state.copyWith(practiceStart: '$hh:$mm');
    _save();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    _checkDateRollover();

    final tab = _activeTab;
    if (tab == null) return;

    state = switch (tab) {
      0 => state.copyWith(noteSeconds: state.noteSeconds + 1),
      1 => state.copyWith(metronomeSeconds: state.metronomeSeconds + 1),
      2 => state.copyWith(polyrhythmSeconds: state.polyrhythmSeconds + 1),
      _ => state,
    };
    _save();
  }

  void _checkDateRollover() {
    final today = _todayStr();
    if (state.date == today) return;
    _archiveDay(state);
    state = PracticeTimerState(date: today);
    _save();
  }

  void _archiveDay(PracticeTimerState day) {
    if (day.totalSeconds == 0) return;
    final log = getLog();
    log.add(day);
    _prefs.setString(_logKey, jsonEncode(log.map((e) => e.toJson()).toList()));
  }

  void _save() {
    _prefs.setString(_todayKey, jsonEncode(state.toJson()));
  }

  List<PracticeTimerState> getLog() {
    final json = _prefs.getString(_logKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => PracticeTimerState.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
