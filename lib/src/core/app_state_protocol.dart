import 'package:simple_app_state/src/core/state_slot.dart';

/// (en) This is an implementation of a protocol for connecting slots and widgets with multiple types of state.
///
/// (ja) Slotやウィジェットと複数種類のStateをつなぐためのプロトコルの実装です。
abstract class AppStateProtocol {
  /// (en) Retrieves the value associated with the specified slot.
  ///
  /// (ja) 指定されたスロットに紐づく値を取得します。
  ///
  /// * [key] : target slot.
  T get<T>(StateSlot<T> key);

  /// (en) Sets the value for the specified slot.
  /// Any listeners associated with the slot will be notified of the change.
  ///
  /// (ja) 指定されたスロットに関して値をセットします。
  /// スロットと紐付いたリスナーに変更が通知されます。
  ///
  /// * [key] : Target slot.
  /// * [value] : The value to set.
  void set<T>(StateSlot<T> key, T value);

  /// (en) Adds a listener for UI updates associated with the specified
  /// slot and ID.
  /// Normally, you should not use this directly. Instead, consider using
  /// a class that extends SlotStatefulWidget or StateSlotBuilder.
  ///
  /// (ja) 指定スロット、及びIDに紐付いたUI更新用のリスナを追加します。
  /// 通常はこれを直接使用せず、SlotStatefulWidgetを拡張したクラスか
  /// StateSlotBuilderの利用を検討してください。
  ///
  /// * [key]: A slot for manipulating the managed value.
  /// * [subscriberId]: An ID for identifying the subscriber to StateSlot
  /// change notifications.
  /// One is assigned per State (widget), and even if the same State subscribes
  /// to multiple slots,
  /// only one notification for screen updates will be sent.
  /// * [callback]: A callback that is triggered when the key value changes.
  void addUIListener(
    StateSlot key,
    String subscriberId,
    void Function() callback,
  );

  /// (en) Deletes the UI update listener associated with the specified
  /// slot and ID.
  /// Normally, you should not use this directly. Instead, consider using
  /// a class that extends SlotStatefulWidget or StateSlotBuilder.
  ///
  /// (ja) 指定スロット、及びIDに紐付いたUI更新用のリスナを削除します。
  /// 通常はこれを直接使用せず、SlotStatefulWidgetを拡張したクラスか
  /// StateSlotBuilderの利用を検討してください。
  ///
  /// * [subscriberId]: ID to identify the subscriber to StateSlot change
  /// notifications.
  /// * [key]: Slot for manipulating the managed value.
  /// If null, all listeners related to subscriberId will be deleted.
  /// If not null, only the listener associated with key will be deleted.
  void removeUIListener({required String subscriberId, StateSlot? key});
}
