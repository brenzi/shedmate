
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shedmate/src/app.dart';
import 'package:shedmate/src/common/providers.dart';

import 'src/common/fake_audio_service.dart';

late SharedPreferences _prefs;

Widget _buildTestApp() {
  return ProviderScope(
    overrides: [
      audioServiceProvider.overrideWithValue(FakeAudioService()),
      sharedPrefsProvider.overrideWithValue(_prefs),
    ],
    child: const App(),
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

  testWidgets('renders Note Generator tab by default', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Note Generator'), findsOneWidget);
  });

  testWidgets('shows initial note display', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('---'), findsOneWidget);
  });

  testWidgets('shows Play button', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Play'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('shows toggle buttons for Piano and Metro', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Piano'), findsOneWidget);
    expect(find.text('Metro'), findsOneWidget);
  });

  testWidgets('shows range section with presets', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Range'), findsOneWidget);
    expect(find.text('Grand Piano'), findsOneWidget);
    expect(find.text('Tenor Sax'), findsOneWidget);
    expect(find.text('Alto Flute'), findsOneWidget);
  });

  testWidgets('shows tempo section', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.textContaining('= 80'), findsOneWidget);
    expect(find.text('Beats'), findsOneWidget);
  });

  testWidgets('shows interval and scale controls', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Interval'), findsOneWidget);
    expect(find.text('Scale'), findsOneWidget);
    expect(find.text('chromatic'), findsOneWidget);
  });

  testWidgets('tap Play toggles to Stop and back', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    // Debug: check what we find
    final playFinder = find.text('Play');
    expect(playFinder, findsOneWidget);
    // Scroll to make it visible if needed
    await tester.scrollUntilVisible(playFinder, 100);
    await tester.tap(playFinder);
    await tester.pump();
    await tester.pump();
    expect(find.text('Stop'), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    await tester.tap(find.text('Stop'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('bottom nav shows three tabs', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Metronome'), findsOneWidget);
    expect(find.text('Polyrhythms'), findsOneWidget);
  });

  testWidgets('can navigate to Metronome tab', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.tap(find.text('Metronome'));
    await tester.pumpAndSettle();
    // Tab label + AppBar = 2
    expect(find.text('Metronome'), findsNWidgets(2));
  });

  testWidgets('can navigate to Polyrhythms tab', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.tap(find.text('Polyrhythms'));
    await tester.pumpAndSettle();
    // Tab label + AppBar = 2
    expect(find.text('Polyrhythms'), findsNWidgets(2));
  });
}
