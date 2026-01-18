import 'package:file_state_manager/file_state_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_app_state/simple_app_state.dart';

class TestFile extends CloneableFile {
  static const String className = 'TestFile';

  final int value;

  TestFile(this.value);

  factory TestFile.fromDict(Map<String, dynamic> src) {
    return TestFile(src['value'] as int);
  }

  @override
  TestFile clone() => TestFile(value);

  @override
  Map<String, dynamic> toDict() {
    return {'className': className, 'value': value};
  }

  @override
  bool operator ==(Object other) => other is TestFile && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final fromDictMap = <String, CloneableFile Function(Map<String, dynamic>)>{
  TestFile.className: (src) => TestFile.fromDict(src),
};

void main() {
  group('SimpleAppState.loadFromDict', () {
    test('loads primitive and CloneableFile values', () {
      final state = SimpleAppState();
      final countSlot = state.slot<int>('count', initial: 0);
      final fileSlot = state.slot<TestFile>('file', initial: TestFile(0));
      final src = {
        'data': {'count': 42, 'file': TestFile(7).toDict()},
      };
      state.loadFromDict(src, fromDictMap);
      expect(state.get(countSlot), 42);
      expect(state.get(fileSlot), TestFile(7));
      expect(state.isLoaded, isTrue);
    });

    test('throws if slot is not declared', () {
      final state = SimpleAppState();
      final src = {
        'data': {'unknown': 123},
      };
      expect(
        () => state.loadFromDict(src, fromDictMap),
        throwsA(isA<StateError>()),
      );
    });

    test('notifyListeners=false does not call listeners', () {
      final state = SimpleAppState();
      final slot = state.slot<int>('count', initial: 0);
      var notified = false;
      state.addUIListener(slot, 'test', () => notified = true);
      final src = {
        'data': {'count': 10},
      };
      state.loadFromDict(src, fromDictMap, notifyListeners: false);
      expect(state.get(slot), 10);
      expect(notified, isFalse);
    });
  });

  group('SimpleAppState.replaceDataFrom', () {
    test('replaces data with deep copy', () {
      final a = SimpleAppState();
      final b = SimpleAppState();
      final slot = a.slot<TestFile>('file', initial: TestFile(1));
      b.slot<TestFile>('file', initial: TestFile(1));
      b.set(slot, TestFile(99));
      a.replaceDataFrom(b, notifyListeners: false);
      final aValue = a.get(slot);
      final bValue = b.get(slot);
      expect(aValue, TestFile(99));
      expect(identical(aValue, bValue), isFalse); // deep copy
    });

    test('notifies listeners when notifyListeners=true', () {
      final a = SimpleAppState();
      final b = SimpleAppState();
      final slot = a.slot<int>('count', initial: 0);
      b.slot<int>('count', initial: 0);
      b.set(slot, 5);
      var notified = false;
      a.addUIListener(slot, 'ui', () => notified = true);
      a.replaceDataFrom(b);
      expect(a.get(slot), 5);
      expect(notified, isTrue);
    });

    test('does not notify listeners when notifyListeners=false', () {
      final a = SimpleAppState();
      final b = SimpleAppState();
      final slot = a.slot<int>('count', initial: 0);
      b.slot<int>('count', initial: 0);
      b.set(slot, 3);
      var notified = false;
      a.addUIListener(slot, 'ui', () => notified = true);
      a.replaceDataFrom(b, notifyListeners: false);
      expect(a.get(slot), 3);
      expect(notified, isFalse);
    });
  });

  test('loadFromDict batches UI and state notifications', () {
    final state = SimpleAppState();
    final a = state.slot<int>('a', initial: 0);
    final b = state.slot<int>('b', initial: 0);
    int uiCalls = 0;
    int stateCalls = 0;
    state.addUIListener(a, 'ui', () => uiCalls++);
    state.addUIListener(b, 'ui', () => uiCalls++);
    state.setStateListener((_) => stateCalls++);
    final src = {
      'data': {'a': 1, 'b': 2},
    };
    state.loadFromDict(src, const {});
    expect(state.get(a), 1);
    expect(state.get(b), 2);
    expect(uiCalls, 1);
    expect(stateCalls, 1);
  });
}
