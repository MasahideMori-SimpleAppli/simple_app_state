part of 'simple_app_state_core.dart';

class StateSlot<T> {
  static const String className = "StateSlot";
  static const String version = "3";
  final String name;
  final SimpleAppState state;
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
  StateSlot._(this.name, this.state, {this.caster});

  /// (en) Returns the current value of this slot.
  /// The slot must be initialized before calling this method.
  ///
  /// (ja) このスロットの現在の値を返します。
  /// 呼び出す前にスロットが初期化されている必要があります。
  T get() => state._get<T>(this);

  /// (en) Set value to this slot.
  ///
  /// (ja) このスロットに値を設定します。
  ///
  /// * [value] : The value to set. Only primitive or JSON serializable values
  /// or classes that extend CloneableFile can be set.
  void set(T value) {
    state._set<T>(this, value);
  }

  /// (en) Update value using previous value.
  ///
  /// (ja) 前の値を使用して値を更新します。
  ///
  /// * [builder] : Return value is Only primitive or JSON serializable values
  /// or classes that extend CloneableFile can be return.
  void update(T Function(T old) builder) {
    final oldValue = state._get<T>(this);
    final newValue = builder(oldValue);
    state._set<T>(this, newValue);
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
