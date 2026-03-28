import 'package:flutter_test/flutter_test.dart';
import 'package:simple_app_state/simple_app_state.dart';

void main() {
  group('AppStateGroup / joinGroup / leaveGroup', () {
    test('joinGroup registers state to group', () {
      final group = AppStateGroup();
      final state = SimpleAppState();
      state.joinGroup(group);

      var called = 0;
      final slot = state.slot<int>('count', initial: 0);
      state.addUIListener(slot, 'a', () => called++);

      group.batch(() => slot.set(1));
      expect(called, 1);
    });

    test('leaveGroup unregisters state from group', () {
      final group = AppStateGroup();
      final state = SimpleAppState();
      state.joinGroup(group);
      state.leaveGroup();

      var groupCalled = 0;
      var selfCalled = 0;
      final slot = state.slot<int>('count', initial: 0);
      state.addUIListener(slot, 'a', () => selfCalled++);

      group.batch(() => groupCalled++);
      slot.set(1);

      expect(groupCalled, 1);
      expect(selfCalled, 1);
    });

    test('AppStateGroup constructor accepts initial states', () {
      final stateA = SimpleAppState();
      final stateB = SimpleAppState();
      AppStateGroup([stateA, stateB]);

      var calledA = 0;
      var calledB = 0;
      final slotA = stateA.slot<int>('a', initial: 0);
      final slotB = stateB.slot<int>('b', initial: 0);
      stateA.addUIListener(slotA, 'x', () => calledA++);
      stateB.addUIListener(slotB, 'y', () => calledB++);

      stateA.batch(() {
        slotA.set(1);
        slotB.set(1);
      });

      expect(calledA, 1);
      expect(calledB, 1);
    });

    test('add same state twice has no effect', () {
      final group = AppStateGroup();
      final state = SimpleAppState();
      group.add(state);
      group.add(state);

      var called = 0;
      final slot = state.slot<int>('count', initial: 0);
      state.addUIListener(slot, 'a', () => called++);

      group.batch(() => slot.set(1));
      expect(called, 1);
    });
  });

  group('AppStateGroup batch coalescing', () {
    test('batch from one member flushes all members at once', () {
      final stateA = SimpleAppState();
      final stateB = SimpleAppState();
      AppStateGroup([stateA, stateB]);

      var calledA = 0;
      var calledB = 0;
      final slotA = stateA.slot<int>('a', initial: 0);
      final slotB = stateB.slot<int>('b', initial: 0);
      stateA.addUIListener(slotA, 'x', () => calledA++);
      stateB.addUIListener(slotB, 'y', () => calledB++);

      stateA.batch(() {
        slotA.set(1);
        slotB.set(1);
      });

      expect(calledA, 1);
      expect(calledB, 1);
    });

    test('batch from second member also coordinates all members', () {
      final stateA = SimpleAppState();
      final stateB = SimpleAppState();
      AppStateGroup([stateA, stateB]);

      var calledA = 0;
      var calledB = 0;
      final slotA = stateA.slot<int>('a', initial: 0);
      final slotB = stateB.slot<int>('b', initial: 0);
      stateA.addUIListener(slotA, 'x', () => calledA++);
      stateB.addUIListener(slotB, 'y', () => calledB++);

      stateB.batch(() {
        slotA.set(1);
        slotB.set(1);
      });

      expect(calledA, 1);
      expect(calledB, 1);
    });

    test('StateListener is called once per member after group batch', () {
      final stateA = SimpleAppState();
      final stateB = SimpleAppState();
      AppStateGroup([stateA, stateB]);

      var commitA = 0;
      var commitB = 0;
      stateA.setStateListener((_) => commitA++);
      stateB.setStateListener((_) => commitB++);

      final slotA = stateA.slot<int>('a', initial: 0);
      final slotB = stateB.slot<int>('b', initial: 0);

      stateA.batch(() {
        slotA.set(1);
        slotB.set(1);
      });

      expect(commitA, 1);
      expect(commitB, 1);
    });

    test('multiple sets within group batch notify subscriber only once', () {
      final stateA = SimpleAppState();
      final stateB = SimpleAppState();
      AppStateGroup([stateA, stateB]);

      var calledA = 0;
      final slotA = stateA.slot<int>('a', initial: 0);
      stateA.addUIListener(slotA, 'x', () => calledA++);

      stateA.batch(() {
        slotA.set(1);
        slotA.set(2);
        slotA.set(3);
      });

      expect(calledA, 1);
      expect(slotA.get(), 3);
    });

    test('group.batch directly also coalesces all members', () {
      final stateA = SimpleAppState();
      final stateB = SimpleAppState();
      final group = AppStateGroup([stateA, stateB]);

      var calledA = 0;
      var calledB = 0;
      final slotA = stateA.slot<int>('a', initial: 0);
      final slotB = stateB.slot<int>('b', initial: 0);
      stateA.addUIListener(slotA, 'x', () => calledA++);
      stateB.addUIListener(slotB, 'y', () => calledB++);

      group.batch(() {
        slotA.set(1);
        slotB.set(1);
      });

      expect(calledA, 1);
      expect(calledB, 1);
    });
  });

  group('AppStateGroup with mixed SimpleAppState and RefAppState', () {
    test('SimpleAppState and RefAppState can join the same group', () {
      final simpleState = SimpleAppState();
      final refState = RefAppState();
      AppStateGroup([simpleState, refState]);

      var calledSimple = 0;
      var calledRef = 0;
      final simpleSlot = simpleState.slot<int>('value', initial: 0);
      final refSlot = refState.slot<Object>('obj', initial: Object());
      simpleState.addUIListener(simpleSlot, 'a', () => calledSimple++);
      refState.addUIListener(refSlot, 'b', () => calledRef++);

      final newObj = Object();
      simpleState.batch(() {
        simpleSlot.set(1);
        refSlot.set(newObj);
      });

      expect(calledSimple, 1);
      expect(calledRef, 1);
      expect(simpleSlot.get(), 1);
      expect(refSlot.get(), newObj);
    });

    test('StateListener fires for both types after group batch', () {
      final simpleState = SimpleAppState();
      final refState = RefAppState();
      AppStateGroup([simpleState, refState]);

      var commitSimple = 0;
      var commitRef = 0;
      simpleState.setStateListener((_) => commitSimple++);
      refState.setStateListener((_) => commitRef++);

      final simpleSlot = simpleState.slot<int>('value', initial: 0);
      final refSlot = refState.slot<String>('name', initial: '');

      refState.batch(() {
        simpleSlot.set(42);
        refSlot.set('hello');
      });

      expect(commitSimple, 1);
      expect(commitRef, 1);
    });
  });

  group('AppStateGroup shared subscriberId across states', () {
    test(
      'same subscriberId registered in multiple states is called only once',
      () {
        final stateA = SimpleAppState();
        final stateB = SimpleAppState();
        AppStateGroup([stateA, stateB]);

        var called = 0;
        final slotA = stateA.slot<int>('a', initial: 0);
        final slotB = stateB.slot<int>('b', initial: 0);
        stateA.addUIListener(slotA, 'widget_1', () => called++);
        stateB.addUIListener(slotB, 'widget_1', () => called++);

        stateA.batch(() {
          slotA.set(1);
          slotB.set(1);
        });

        expect(called, 1);
      },
    );

    test(
      'same subscriberId with slots in three states is called only once',
      () {
        final stateA = SimpleAppState();
        final stateB = SimpleAppState();
        final stateC = SimpleAppState();
        AppStateGroup([stateA, stateB, stateC]);

        var called = 0;
        final slotA = stateA.slot<int>('a', initial: 0);
        final slotB = stateB.slot<int>('b', initial: 0);
        final slotC = stateC.slot<int>('c', initial: 0);
        stateA.addUIListener(slotA, 'widget_1', () => called++);
        stateB.addUIListener(slotB, 'widget_1', () => called++);
        stateC.addUIListener(slotC, 'widget_1', () => called++);

        stateA.batch(() {
          slotA.set(1);
          slotB.set(1);
          slotC.set(1);
        });

        expect(called, 1);
      },
    );

    test('different subscriberIds are each called once', () {
      final stateA = SimpleAppState();
      final stateB = SimpleAppState();
      AppStateGroup([stateA, stateB]);

      var calledWidget1 = 0;
      var calledWidget2 = 0;
      final slotA = stateA.slot<int>('a', initial: 0);
      final slotB = stateB.slot<int>('b', initial: 0);
      stateA.addUIListener(slotA, 'widget_1', () => calledWidget1++);
      stateB.addUIListener(slotB, 'widget_2', () => calledWidget2++);

      stateA.batch(() {
        slotA.set(1);
        slotB.set(1);
      });

      expect(calledWidget1, 1);
      expect(calledWidget2, 1);
    });
  });

  group('AppStateGroup nested batch', () {
    test('nested group.batch does not double-flush', () {
      final stateA = SimpleAppState();
      final stateB = SimpleAppState();
      final group = AppStateGroup([stateA, stateB]);

      var calledA = 0;
      var calledB = 0;
      final slotA = stateA.slot<int>('a', initial: 0);
      final slotB = stateB.slot<int>('b', initial: 0);
      stateA.addUIListener(slotA, 'x', () => calledA++);
      stateB.addUIListener(slotB, 'y', () => calledB++);

      group.batch(() {
        group.batch(() {
          slotA.set(1);
          slotB.set(1);
        });
        slotA.set(2);
      });

      expect(calledA, 1);
      expect(calledB, 1);
      expect(slotA.get(), 2);
    });
  });
}
