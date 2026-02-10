import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/providers.dart';
import 'features/metronome/ui/metronome_screen.dart';
import 'features/note_generator/ui/note_generator_screen.dart';
import 'features/polyrhythms/ui/polyrhythms_screen.dart';

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
    return MaterialApp(
      title: 'Jazz Practice Tools',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            NoteGeneratorScreen(),
            MetronomeScreen(),
            PolyrhythmsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.music_note), label: 'Notes'),
            NavigationDestination(icon: Icon(Icons.timer), label: 'Metronome'),
            NavigationDestination(
              icon: Icon(Icons.grid_on),
              label: 'Polyrhythms',
            ),
          ],
        ),
      ),
    );
  }
}
