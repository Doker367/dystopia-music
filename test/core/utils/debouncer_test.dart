import 'package:flutter_test/flutter_test.dart';
import 'package:dystopia/core/utils/debouncer.dart';

void main() {
  test('runs action after delay', () async {
    final debouncer = Debouncer(milliseconds: 100);
    bool didRun = false;
    
    debouncer.run(() {
      didRun = true;
    });
    
    expect(didRun, false);
    await Future.delayed(const Duration(milliseconds: 150));
    expect(didRun, true);
  });

  test('cancels previous action on new call', () async {
    final debouncer = Debouncer(milliseconds: 100);
    int runCount = 0;
    
    debouncer.run(() {
      runCount++;
    });
    
    debouncer.run(() {
      runCount++;
    });
    
    await Future.delayed(const Duration(milliseconds: 150));
    expect(runCount, 1);
  });

  test('dispose cancels pending action', () async {
    final debouncer = Debouncer(milliseconds: 100);
    bool didRun = false;
    
    debouncer.run(() {
      didRun = true;
    });
    
    debouncer.dispose();
    await Future.delayed(const Duration(milliseconds: 150));
    expect(didRun, false);
  });
}
