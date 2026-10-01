import 'package:flutter_test/flutter_test.dart';
import 'package:dystopia/core/utils/formatters.dart';

void main() {
  group('formatDuration', () {
    test('formatDuration with seconds only', () {
      expect(Formatters.formatDuration(const Duration(seconds: 45)), '00:45');
      expect(Formatters.formatDuration(const Duration(seconds: 9)), '00:09');
    });

    test('formatDuration with minutes and seconds', () {
      expect(Formatters.formatDuration(const Duration(minutes: 5, seconds: 30)), '05:30');
      expect(Formatters.formatDuration(const Duration(minutes: 12, seconds: 5)), '12:05');
    });

    test('formatDuration with hours', () {
      expect(Formatters.formatDuration(const Duration(hours: 1, minutes: 15, seconds: 30)), '1:15:30');
      expect(Formatters.formatDuration(const Duration(hours: 2, minutes: 5, seconds: 9)), '2:05:09');
    });
  });

  group('formatFileSize', () {
    test('formatFileSize with bytes', () {
      expect(Formatters.formatFileSize(0), '0 B');
      expect(Formatters.formatFileSize(500), '500.0 B');
    });

    test('formatFileSize with KB', () {
      expect(Formatters.formatFileSize(1024), '1.0 KB');
      expect(Formatters.formatFileSize(1500), '1.5 KB');
    });

    test('formatFileSize with MB', () {
      expect(Formatters.formatFileSize(1048576), '1.0 MB');
      expect(Formatters.formatFileSize(1572864), '1.5 MB');
    });

    test('formatFileSize with GB', () {
      expect(Formatters.formatFileSize(1073741824), '1.0 GB');
    });
  });

  group('getGreeting', () {
    test('getGreeting returns appropriate greeting for different times', () {
      final greeting = Formatters.getGreeting();
      expect(greeting, isA<String>());
      expect(greeting.isNotEmpty, true);
    });
  });
}
