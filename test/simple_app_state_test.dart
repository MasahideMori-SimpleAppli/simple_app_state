import 'package:flutter_test/flutter_test.dart';
import 'package:simple_app_state/simple_app_state.dart';

void main() {
  group('SimpleAppState / StateSlot basic behavior', () {
    test('fixes its type on first access', () {
      final state = SimpleAppState();

      final intSlot = state.slot<int>('count', initial: 1);
      expect(intSlot.get(), 1);

      expect(() => state.slot<String>('count'), throwsA(isA<StateError>()));
    });

    test('set and get value', () {
      final state = SimpleAppState();
      final slot = state.slot<int>('count');

      slot.set(10);
      expect(slot.get(), 10);
    });

    test('update uses previous value', () {
      final state = SimpleAppState();
      final slot = state.slot<int>('count', initial: 1);

      slot.update((v) => (v ?? 0) + 1);
      expect(slot.get(), 2);
    });
  });

  group('DebugListener', () {
    test('reports every mutation immediately outside batch', () {
      final state = SimpleAppState();
      final log = <String>[];

      state.setDebugListener((key, oldValue, newValue) {
        log.add('${key.name}: $oldValue -> $newValue');
      });

      final slot = state.slot<int>('count');
      slot.set(1);
      slot.set(2);

      expect(log, ['count: null -> 1', 'count: 1 -> 2']);
    });

    test('reports intermediate mutations during batch', () {
      final state = SimpleAppState();
      final log = <int?>[];

      state.setDebugListener((_, _, newValue) {
        log.add(newValue as int?);
      });

      final slot = state.slot<int>('count');

      state.batch(() {
        slot.set(1);
        slot.set(2);
        slot.set(3);
      });

      expect(log, [1, 2, 3]);
    });
  });

  group('Batch listener coalescing', () {
    test('calls listener immediately outside batch', () {
      final state = SimpleAppState();
      final slot = state.slot<int>('count');

      var called = 0;
      state.addUIListener(slot, 'a', () => called++);

      slot.set(1);
      expect(called, 1);

      slot.set(2);
      expect(called, 2);
    });

    test('calls each subscriber only once per batch', () {
      final state = SimpleAppState();
      final slot = state.slot<int>('count');
      var called = 0;
      state.addUIListener(slot, 'a', () => called++);
      state.batch(() {
        slot.set(1);
        slot.set(2);
        slot.set(3);
      });
      expect(called, 1);
    });

    test('coalesces notifications across multiple slots per subscriber', () {
      final state = SimpleAppState();
      final a = state.slot<int>('a');
      final b = state.slot<int>('b');

      var called = 0;
      state.addUIListener(a, 'x', () => called++);
      state.addUIListener(b, 'x', () => called++);

      state.batch(() {
        a.set(1);
        b.set(2);
      });

      expect(called, 1);
    });
  });

  group('StateListener (commit notification)', () {
    test('is called once after non-batch state update', () {
      final state = SimpleAppState();
      final slot = state.slot<int>('count');

      var commitCount = 0;
      state.setStateListener((_) => commitCount++);

      slot.set(1);
      expect(commitCount, 1);

      slot.set(2);
      expect(commitCount, 2);
    });

    test('is called once after batch completes', () {
      final state = SimpleAppState();
      final slot = state.slot<int>('count');

      var commitCount = 0;
      state.setStateListener((_) => commitCount++);

      state.batch(() {
        slot.set(1);
        slot.set(2);
      });

      expect(commitCount, 1);
    });
  });

  group('clone / equality / serialization', () {
    test('clone produces equal but independent state', () {
      final state = SimpleAppState();
      state.slot<int>('count').set(1);

      final cloned = state.clone();

      expect(cloned, state);
      expect(identical(cloned, state), isFalse);

      cloned.slot<int>('count').set(2);
      expect(state.slot<int>('count').get(), 1);
    });

    test('toDict and fromDict perform round-trip serialization', () {
      final state = SimpleAppState();
      state.slot<int>('count').set(42);

      final dict = state.toDict();
      final restored = SimpleAppState.fromDict(dict, {});

      expect(restored.slot<int>('count').get(), 42);
      expect(restored, state);
    });
  });
}
