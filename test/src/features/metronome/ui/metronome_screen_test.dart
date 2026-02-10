
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jazz_practice_tools/src/common/providers.dart';
import 'package:jazz_practice_tools/src/features/metronome/ui/metronome_screen.dart';

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
      home: const MetronomeScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Mock the wakelock platform channel using binary messenger
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
      (ByteData? message) async {
        return const StandardMessageCodec().encodeMessage(<Object?>[null]);
      },
    );

    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  tearDown(() {
    // Clean up the mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
      null,
    );
  });

  testWidgets('renders metronome screen', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Metronome'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('shows tempo display', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    // Inline wheel renders BPM as '120' text
    expect(find.text('120'), findsOneWidget);
  });

  testWidgets('shows beats selector', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Beats'), findsOneWidget);
  });

  testWidgets('shows accent and section controls', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Accent 1'), findsOneWidget);
    expect(find.text('Section'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // section count
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

  testWidgets('section increment and decrement', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    // Initially no bar counter
    expect(find.textContaining('Bar'), findsNothing);
    // Increment to 1
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('Bar 1 / 1'), findsOneWidget);
    // Decrement back to 0
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.textContaining('Bar'), findsNothing);
  });
}
