// Renders every screen to a PNG under build/screenshots/ with no emulator and
// no display: flutter_tester rasterises the widget tree in-process.
//
//   flutter test test/app_screenshots_test.dart
//
// The test fails if any screen throws while rendering (overflow, assertion),
// so it doubles as a layout guard at real phone width.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shedmate/src/app.dart';
import 'package:shedmate/src/common/providers.dart';

import 'src/common/fake_audio_service.dart';

/// 360x760 logical, the narrowest widely used Android phone. Rendering at the
/// tightest real width is what makes the render-error gate worth having.
const _physicalSize = Size(1080, 2280);
const _devicePixelRatio = 3.0;

final _outputDir = Directory('build/screenshots');
final _rootKey = GlobalKey();

late SharedPreferences _prefs;

/// flutter_tester ships no fonts, so text and icons render as hollow boxes
/// unless the real ones are loaded from the Flutter cache.
Future<void> _loadFonts() async {
  final fonts = Directory(
    '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts',
  );
  final roboto = FontLoader('Roboto');
  for (final name in const [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]) {
    roboto.addFont(_bytes(File('${fonts.path}/$name')));
  }
  await roboto.load();

  await (FontLoader(
    'MaterialIcons',
  )..addFont(_bytes(File('${fonts.path}/MaterialIcons-Regular.otf')))).load();
}

Future<ByteData> _bytes(File file) async =>
    file.readAsBytesSync().buffer.asByteData();

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = _physicalSize;
  tester.view.devicePixelRatio = _devicePixelRatio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _rootKey,
      child: ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(FakeAudioService()),
          sharedPrefsProvider.overrideWithValue(_prefs),
        ],
        child: const App(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _shoot(WidgetTester tester, String name) async {
  final boundary =
      _rootKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _devicePixelRatio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File(
      '${_outputDir.path}/$name.png',
    ).writeAsBytesSync(png!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Keep the debug banner out of the corner of every screenshot.
    WidgetsApp.debugAllowBannerOverride = false;
    _outputDir.createSync(recursive: true);
    await _loadFonts();
  });

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
          (ByteData? message) async =>
              const StandardMessageCodec().encodeMessage(<Object?>[null]),
        );
    PackageInfo.setMockInitialValues(
      appName: 'ShedMate',
      packageName: 'ch.brenzi.shedmate',
      version: '0.3.3',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  testWidgets('note generator', (tester) async {
    await _pumpApp(tester);
    await _shoot(tester, '01-note-generator');
  });

  testWidgets('metronome', (tester) async {
    await _pumpApp(tester);
    await _openTab(tester, 'Metronome');
    await _shoot(tester, '02-metronome');
  });

  testWidgets('metronome with section', (tester) async {
    await _pumpApp(tester);
    await _openTab(tester, 'Metronome');
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
    }
    await _shoot(tester, '03-metronome-section');
  });

  testWidgets('metronome playing', (tester) async {
    await _pumpApp(tester);
    await _openTab(tester, 'Metronome');
    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await _shoot(tester, '04-metronome-playing');
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
  });

  testWidgets('polyrhythms', (tester) async {
    await _pumpApp(tester);
    await _openTab(tester, 'Polyrhythms');
    await _shoot(tester, '05-polyrhythms');
  });

  testWidgets('practice log', (tester) async {
    await _pumpApp(tester);
    await _openTab(tester, 'Log');
    await _shoot(tester, '06-practice-log');
  });

  testWidgets('mixer sheet', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await _shoot(tester, '07-mixer');
  });
}
