import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jazz_practice_tools/src/common/providers.dart';
import 'package:jazz_practice_tools/src/features/polyrhythms/ui/polyrhythms_screen.dart';

import '../../../common/fake_audio_service.dart';

late SharedPreferences _prefs;

Widget _buildTestApp() {
  return ProviderScope(
    overrides: [
      audioServiceProvider.overrideWithValue(FakeAudioService()),
      sharedPrefsProvider.overrideWithValue(_prefs),
    ],
    child: MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const PolyrhythmsScreen(),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  testWidgets('renders polyrhythms screen', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Polyrhythms'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('shows tempo display', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.textContaining('= 120'), findsOneWidget);
  });

  testWidgets('shows A:B selector with default 3:4', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('3'), findsOneWidget);
    expect(find.text(':'), findsOneWidget);
    // '4' may appear multiple times due to LED count
    expect(find.text('4'), findsAtLeast(1));
  });

  testWidgets('shows subdivision button', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Subdivision'), findsOneWidget);
  });

  testWidgets('play toggles to stop', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Stop'), findsOneWidget);
    await tester.tap(find.text('Stop'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Play'), findsOneWidget);
  });
}
