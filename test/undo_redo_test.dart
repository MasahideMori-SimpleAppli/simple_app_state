import 'package:file_state_manager/file_state_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_app_state/simple_app_state.dart';

void main() {
  group('SimpleAppState / Undo, Redo', () {
    test('undo', () {
      final state = SimpleAppState();
      final intSlot = state.slot<int>('count', initial: 1);
      final fsm = FileStateManager(state, stackSize: 20);
      // 状態確定時のみ履歴に push
      state.setStateListener((SimpleAppState mState) {
        fsm.push(mState);
      });
      expect(intSlot.get(), 1);
      // 状態変更①
      intSlot.set(2);
      expect(intSlot.get(), 2);
      // 状態変更②
      intSlot.set(3);
      expect(intSlot.get(), 3);
      // undo 実行
      final previous = fsm.undo();
      expect(previous, isNotNull);
      // 次のsetStateListenerによるpushを無効化してから実行する。
      fsm.skipNextPush();
      state.replaceDataFrom(previous as SimpleAppState);
      expect(intSlot.get(), 2);
      // さらに undo
      final previous2 = fsm.undo();
      expect(previous2, isNotNull);
      // 次のsetStateListenerによるpushを無効化してから実行する。
      fsm.skipNextPush();
      state.replaceDataFrom(previous2 as SimpleAppState);
      expect(intSlot.get(), 1);
    });

    test('redo', () {
      final state = SimpleAppState();
      final intSlot = state.slot<int>('count', initial: 1);
      final fsm = FileStateManager(state, stackSize: 20);
      // 状態確定時のみ履歴に push
      state.setStateListener((SimpleAppState mState) {
        fsm.push(mState);
      });
      expect(intSlot.get(), 1);
      // 状態変更
      intSlot.set(2);
      intSlot.set(3);
      expect(intSlot.get(), 3);
      // undo
      final prev = fsm.undo();
      // 次のsetStateListenerによるpushを無効化してから実行する。
      fsm.skipNextPush();
      state.replaceDataFrom(prev as SimpleAppState);
      expect(intSlot.get(), 2);
      // redo
      final next = fsm.redo();
      expect(next, isNotNull);
      // 次のsetStateListenerによるpushを無効化してから実行する。
      fsm.skipNextPush();
      state.replaceDataFrom(next as SimpleAppState);
      expect(intSlot.get(), 3);
    });

    test('undo and redo', () {
      final state = SimpleAppState();
      final intSlot = state.slot<int>('count', initial: 1);
      final fsm = FileStateManager(state, stackSize: 20);
      state.setStateListener((SimpleAppState mState) {
        fsm.push(mState);
      });
      intSlot.set(2);
      intSlot.set(3);
      // undo
      final prev = fsm.undo();
      fsm.skipNextPush();
      state.replaceDataFrom(prev as SimpleAppState);
      expect(intSlot.get(), 2);
      // redo
      final next = fsm.redo();
      fsm.skipNextPush();
      state.replaceDataFrom(next as SimpleAppState);
      expect(intSlot.get(), 3);
    });
  });
}
