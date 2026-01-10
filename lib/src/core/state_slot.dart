import 'package:simple_app_state/src/core/app_state_protocol.dart';

class StateSlot<T> {
  static const String className = "StateSlot";
  static const String version = "6";
  final String name;
  final AppStateProtocol state;
  final T Function(dynamic value)? caster;

  /// (en) Do not call this constructor directly.
  /// It is designed to be called internally by SimpleAppState.
  ///
  /// (ja) このコンストラクタは直接呼ばないでください。
  /// SimpleAppStateから内部的に呼ばれるように設計されています。
  ///
  /// * [name] : The slot name. This name will be thrown if an error occurs,
  /// so do not put any confidential information in it.
  /// * [state] : The parent state class that manages this slot.
  /// * [caster] : Optional function to convert a raw value retrieved from
  /// storage to the expected type `T`. This is required for typed collections.
  StateSlot(this.name, this.state, {this.caster});

  /// (en) Returns this slot's current value.
  /// If this slot was created from SimpleAppState,
  /// it will always return a deep copy.
  /// If this slot was created from RefAppState,
  /// it will basically return a reference.
  /// The slot must be initialized before calling this method.
  ///
  /// (ja) このスロットの現在の値を返します。
  /// このスロットがSimpleAppStateから作られている場合は常にディープコピーを返します。
  /// このスロットがRefAppStateから作られている場合は基本的に参照を返します。
  /// 呼び出す前にスロットが初期化されている必要があります。
  T get() => state.get<T>(this);

  /// (en) Set value to this slot.
  /// If this slot was created from SimpleAppState,
  /// the value you set will be deep-copied internally.
  /// If this slot was created from RefAppState,
  /// the value you set will be set as is.
  /// Any listeners associated with the slot will be notified of the change.
  ///
  /// (ja) このスロットに値を設定します。
  /// このスロットがSimpleAppStateから作られている場合、
  /// セットする値は内部的にディープコピーされます。
  /// このスロットがRefAppStateから作られている場合、
  /// セットする値はそのまま設定されます。
  /// スロットと紐付いたリスナーに変更が通知されます。
  ///
  /// * [value] : The value to set. Only primitive or JSON serializable values
  /// or classes that extend CloneableFile can be set.
  void set(T value) {
    state.set<T>(this, value);
  }

  /// (en) Update value using previous value.
  /// If this slot is created from SimpleAppState,
  /// [builder] is passed an internally deep-copied value.
  /// If this slot is created from RefAppState,
  /// [builder] is passed the value as is.
  /// Any listeners associated with the slot will be notified of the change.
  ///
  /// (ja) 前の値を使用して値を更新します。
  /// このスロットがSimpleAppStateから作られている場合、
  /// [builder]には内部的にディープコピーされた値が渡されます。
  /// このスロットがRefAppStateから作られている場合、
  /// [builder]には値はそのまま渡されます。
  /// スロットと紐付いたリスナーに変更が通知されます。
  ///
  /// * [builder] : Return value is Only primitive or JSON serializable values
  /// or classes that extend CloneableFile can be return.
  void update(T Function(T oldCopy) builder) {
    final oldCopy = state.get<T>(this);
    final newValue = builder(oldCopy);
    state.set<T>(this, newValue);
  }

  @override
  bool operator ==(Object other) {
    // 1. 同一参照なら即座に終了
    if (identical(this, other)) return true;
    // 2. 基本的な型チェック
    if (other is! StateSlot) return false;
    return other.name == name && identical(other.state, state);
  }

  @override
  int get hashCode => Object.hash(name, identityHashCode(state));
}
