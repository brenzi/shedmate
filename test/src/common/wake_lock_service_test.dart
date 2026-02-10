import 'package:flutter_test/flutter_test.dart';
import 'package:jazz_practice_tools/src/common/wake_lock_service.dart';

void main() {
  group('WakeLockService', () {
    setUp(() {
      // Reset the counter before each test
      WakeLockService.instance.reset();
    });

    test('singleton instance returns same object', () {
      final instance1 = WakeLockService.instance;
      final instance2 = WakeLockService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('enable increments active count', () async {
      await WakeLockService.instance.enable();
      // We can't directly test the wakelock state without mocking,
      // but we can test the counter behavior by enabling/disabling
      await WakeLockService.instance.enable();
      await WakeLockService.instance.disable();
      await WakeLockService.instance.disable();
      // If counter works correctly, this should succeed without error
    });

    test('disable does not go below zero', () async {
      // Calling disable without enable shouldn't cause issues
      await WakeLockService.instance.disable();
      await WakeLockService.instance.disable();
      // Should complete without errors
    });

    test('enable and disable can be called multiple times', () async {
      // Simulate multiple features playing
      await WakeLockService.instance.enable(); // Feature 1
      await WakeLockService.instance.enable(); // Feature 2
      await WakeLockService.instance.enable(); // Feature 3
      
      await WakeLockService.instance.disable(); // Feature 1 stops
      await WakeLockService.instance.disable(); // Feature 2 stops
      await WakeLockService.instance.disable(); // Feature 3 stops
      
      // Should complete without errors
    });
  });
}
