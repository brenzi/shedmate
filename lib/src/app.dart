import 'package:flutter/material.dart';

import 'features/metronome/ui/metronome_screen.dart';
import 'features/note_generator/ui/note_generator_screen.dart';
import 'features/polyrhythms/ui/polyrhythms_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

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
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
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
