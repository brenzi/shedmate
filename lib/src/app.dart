import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/mixer/mixer_sheet.dart';
import 'common/practice_timer/playback_provider.dart';
import 'common/practice_timer/practice_timer_display.dart';
import 'common/practice_timer/practice_timer_notifier.dart';
import 'common/providers.dart';
import 'features/metronome/ui/metronome_screen.dart';
import 'features/note_generator/ui/note_generator_screen.dart';
import 'features/polyrhythms/ui/polyrhythms_screen.dart';
import 'features/practice_log/ui/practice_log_screen.dart'
    show PracticeLogScreen, PracticeLogVersion;

const _tabTitles = ['Note Generator', 'Metronome', 'Polyrhythms', 'Log'];

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _currentIndex = 0;

  void _onTabSelected(int i) {
    setState(() => _currentIndex = i);
    ref.read(activeTabProvider.notifier).state = i;
  }

  @override
  Widget build(BuildContext context) {
    // Drive practice timer from playback state changes.
    ref.listen(activePlaybackProvider, (_, next) {
      ref.read(practiceTimerProvider.notifier).onPlaybackChanged(next);
    });

    return MaterialApp(
      title: 'ShedMate',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(_tabTitles[_currentIndex]),
              const Expanded(child: Center(child: PracticeTimerDisplay())),
            ],
          ),
          actions: [
            if (_currentIndex < 3)
              Builder(
                builder: (navContext) => IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => showMixerSheet(navContext),
                ),
              )
            else
              const PracticeLogVersion(),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            NoteGeneratorScreen(),
            MetronomeScreen(),
            PolyrhythmsScreen(),
            PracticeLogScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.music_note), label: 'Notes'),
            NavigationDestination(icon: Icon(Icons.timer), label: 'Metronome'),
            NavigationDestination(
                icon: Icon(Icons.grid_on), label: 'Polyrhythms'),
            NavigationDestination(
                icon: Icon(Icons.bar_chart), label: 'Log'),
          ],
        ),
      ),
    );
  }
}
