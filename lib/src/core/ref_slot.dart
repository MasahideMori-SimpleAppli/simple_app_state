import 'package:simple_app_state/src/core/state_slot.dart';

class RefSlot<T> extends StateSlot<T> {
  static const String className = "RefSlot";
  static const String version = "1";

  /// (en) Do not call this constructor directly.
  /// It is designed to be called internally by RefAppState.
  ///
  /// (ja) このコンストラクタは直接呼ばないでください。
  /// RefAppStateから内部的に呼ばれるように設計されています。
  ///
  /// * [name] : The slot name. This name will be thrown if an error occurs,
  /// so do not put any confidential information in it.
  /// * [state] : The parent state class that manages this slot.
  RefSlot(super.name, super.state);

  /// (en) Returns this slot's current reference.
  /// The slot must be initialized before calling this method.
  ///
  /// (ja) このスロットの現在の参照を返します。
  /// 呼び出す前にスロットが初期化されている必要があります。
  @override
  T get() {
    return super.get();
  }

  /// (en) Set value to this slot.
  /// Any listeners associated with the slot will be notified of the change.
  ///
  /// (ja) このスロットに値を設定します。
  /// スロットと紐付いたリスナーに変更が通知されます。
  ///
  /// * [value] : The reference value to be retained.
  @override
  void set(T value) {
    super.set(value);
  }

  /// (en) Update the value using the reference value.
  /// Any listeners associated with the slot will be notified of the change.
  ///
  /// (ja) リファレンス値を使用して値を更新します。
  /// スロットと紐付いたリスナーに変更が通知されます。
  ///
  /// * [builder] : The ref argument is given a reference value.
  @override
  void update(T Function(T ref) builder) {
    super.update(builder);
  }

  @override
  bool operator ==(Object other) {
    // 1. 同一参照なら即座に終了
    if (identical(this, other)) return true;
    // 2. 基本的な型チェック
    if (other is! RefSlot) return false;
    return other.name == name && identical(other.state, state);
  }

  @override
  int get hashCode => Object.hash(name, identityHashCode(state));
}
