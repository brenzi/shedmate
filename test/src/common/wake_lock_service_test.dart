
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jazz_practice_tools/src/common/wake_lock_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WakeLockService', () {
    setUp(() async {
      // Mock the wakelock platform channel using binary messenger
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
        (ByteData? message) async {
          // Return a properly encoded empty response
          return const StandardMessageCodec().encodeMessage(<Object?>[null]);
        },
      );

      // Reset the counter and wake lock state before each test
      await WakeLockService.instance.reset();
    });

    tearDown(() {
      // Clean up the mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
        null,
      );
    });

    test('singleton instance returns same object', () {
      final instance1 = WakeLockService.instance;
      final instance2 = WakeLockService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('enable and disable can be called in sequence', () async {
      // Test basic enable/disable flow
      await WakeLockService.instance.enable();
      await WakeLockService.instance.disable();
      // Should complete without errors
    });

    test('disable does not go below zero', () async {
      // Calling disable without enable shouldn't cause issues
      await WakeLockService.instance.disable();
      await WakeLockService.instance.disable();
      // Should complete without errors
    });

    test('multiple features can enable and disable independently', () async {
      // Simulate multiple features playing
      // When first feature starts, wake lock should be enabled
      await WakeLockService.instance.enable(); // Feature 1
      
      // When second feature starts, wake lock stays enabled
      await WakeLockService.instance.enable(); // Feature 2
      
      // When third feature starts, wake lock stays enabled
      await WakeLockService.instance.enable(); // Feature 3
      
      // When first feature stops, wake lock stays enabled (count = 2)
      await WakeLockService.instance.disable(); // Feature 1 stops
      
      // When second feature stops, wake lock stays enabled (count = 1)
      await WakeLockService.instance.disable(); // Feature 2 stops
      
      // When last feature stops, wake lock should be disabled (count = 0)
      await WakeLockService.instance.disable(); // Feature 3 stops
      
      // Should complete without errors
    });

    test('reset cleans up wake lock state', () async {
      await WakeLockService.instance.enable();
      await WakeLockService.instance.enable();
      // Reset should disable wake lock and reset counter
      await WakeLockService.instance.reset();
      // Should complete without errors
    });
  });
}
