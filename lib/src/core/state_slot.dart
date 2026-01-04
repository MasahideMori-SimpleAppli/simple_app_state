part of 'simple_app_state_core.dart';

class StateSlot<T> {
  static const String className = "StateSlot";
  static const String version = "2";
  final String name;
  final SimpleAppState state;
  final T? Function(dynamic value)? caster;

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

  T? get() => state._get<T>(this);

  /// (en) Set value to this slot.
  /// Returns this slot to allow method chaining.
  ///
  /// (ja) このスロットに値を設定します。
  /// メソッドチェーンを可能にするためにこのスロットを返します。
  ///
  /// * [value] : The value to set. Only primitive or JSON serializable values
  /// or classes that extend CloneableFile can be set.
  StateSlot<T> set(T? value) {
    return state._set<T>(this, value);
  }

  /// (en) Update value using previous value.
  /// Returns this slot to allow method chaining.
  ///
  /// (ja) 前の値を使用して値を更新します。
  /// メソッドチェーンを可能にするためにこのスロットを返します。
  ///
  /// * [builder] : Return value is Only primitive or JSON serializable values
  /// or classes that extend CloneableFile can be return.
  StateSlot<T> update(T? Function(T? old) builder) {
    final oldValue = state._get<T>(this);
    final newValue = builder(oldValue);
    return state._set<T>(this, newValue);
  }

  @override
  bool operator ==(Object other) {
    return other is StateSlot &&
        other.name == name &&
        identical(other.state, state);
  }

  @override
  int get hashCode => Object.hash(name, identityHashCode(state));
}
