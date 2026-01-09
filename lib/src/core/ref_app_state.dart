part of 'app_state_impl.dart';

class RefAppState extends SimpleAppState {
  static const String className = "RefAppState";
  static const String version = "1";

  /// * [data]: The initial value of the managed state.
  /// This can usually be null.
  /// This value is assigned by the factory constructor when the data is
  /// restored.
  RefAppState({Map<String, dynamic>? data}) {
    if (data != null && data.isNotEmpty) {
      _data.addAll(data);
    }
  }

  /// (en)
  /// Returns a typed state slot associated with the given name.
  ///
  /// If the slot does not exist yet, a new slot is created and its type is
  /// fixed at creation time.
  /// Once fixed, the slot's type cannot be changed.
  /// Accessing the same slot name with a different type will throw an error.
  ///
  /// If [initial] is specified and a value does not already exist,
  /// [initial] is set as the initial value when the slot is
  /// created.
  ///
  /// If a value already exists [initial] is ignored.
  ///
  /// (ja)
  /// 指定された名前に対応する、型付きの状態スロットを取得します。
  /// このクラスではディープコピーによるガードがありませんが、
  /// 参照値をそのまま利用できるスロットが返されます。
  /// つまり、ディープコピーできないクラスも管理対象にすることができます。
  ///
  /// スロットがまだ存在しない場合は新しく作成され、
  /// その作成時点でスロットの型が確定します。
  /// 一度確定したスロットの型は変更できません。
  /// 同じ名前のスロットを異なる型で取得しようとするとエラーになります。
  ///
  /// [initial] が指定されており、かつ値がまだ存在しない場合のみ、
  /// スロット作成時に初期値として[initial]が設定されます。
  ///
  /// すでに値が存在する場合 [initial] は無視されます。
  ///
  /// * [name] : The slot name. This name will be thrown if an error occurs,
  /// so do not put any confidential information in it.
  /// * [initial] : Initial value of the slot.
  /// * [caster] : This value has no effect for this class.
  ///
  /// ---
  ///
  /// slot creation example:
  /// ```dart
  /// final refState = RefAppState();
  /// final a = state.slot<ClassA>('a', initial: ClassA());
  /// ```
  @override
  StateSlot<T> slot<T>(
    String name, {
    required T initial,
    T Function(dynamic value)? caster,
  }) {
    final existing = _slots[name];
    if (existing != null) {
      if (existing is! StateSlot<T>) {
        throw StateError(
          'Slot "$name" already bound to '
          '${existing.runtimeType}, not StateSlot<$T>',
        );
      }
      // 既に値があり、initial は無視
      return existing;
    }
    final slot = StateSlot<T>(name, this, caster: caster);
    _slots[name] = slot;
    // 初期値をセット
    if (!_data.containsKey(name)) {
      setInitial(slot, initial);
    }
    return slot;
  }

  /// (en) This method is not available for this class.
  ///
  /// (ja) このクラスではこのメソッドは使用できません。
  @override
  void setDebugListener(DebugListener? listener) {
    throw UnimplementedError();
  }

  /// (en) Retrieves the value associated with the specified key.
  /// The value that can be retrieved may be a reference value.
  ///
  /// (ja) 指定されたキーに紐づく値を取得します。
  /// 取得できる値は参照値である可能性があります。
  ///
  /// * [key] : target slot.
  @override
  T get<T>(StateSlot<T> key) {
    if (!_data.containsKey(key.name)) {
      throw StateError('StateSlot "${key.name}" is not initialized');
    }
    return _data[key.name];
  }

  /// (en) This is a set method dedicated to setting the initial value of
  /// the Slot. This method does not notify listeners.
  /// The data is set without copying.
  ///
  /// (ja) Slotの初期値設定専用のsetメソッドです。このメソッドはリスナに通知しません。
  /// データはコピーしないで設定されます。
  ///
  /// * [key] : Target slot.
  /// * [value] : The value to set.
  @override
  void setInitial<T>(StateSlot<T> key, T value) {
    _data[key.name] = value;
  }

  /// (en) Sets the value for the specified key.
  /// The data is set without copying.
  /// Any listeners associated with the key will also be notified.
  ///
  /// (ja) 指定されたキーに関して値をセットします。
  /// データはコピーしないで設定されます。
  /// キーと紐付いたリスナーにも通知されます。
  ///
  /// * [key] : Target slot.
  /// * [value] : The value to set.
  @override
  void set<T>(StateSlot<T> key, T value) {
    if (!_data.containsKey(key.name)) {
      throw StateError('StateSlot "${key.name}" is not initialized');
    }
    _data[key.name] = value;
    _notify(key);
  }

  /// (en) This method is not available for this class.
  ///
  /// (ja) このクラスではこのメソッドは使用できません。
  @override
  void loadFromDict(
    Map<String, dynamic> src,
    Map<String, CloneableFile Function(Map<String, dynamic>)> fromDictMap, {
    bool notifyListeners = true,
  }) {
    throw UnimplementedError();
  }

  /// (en) Returns a clone if all contents of this class are cloneable.
  /// Throws an error if any non-cloneable objects are included.
  ///
  /// (ja) このクラスの全ての内容がクローン可能な場合はクローンを返します。
  /// クローン可能でないオブジェクトが混ざっている場合はエラーをスローします。
  @override
  RefAppState clone() {
    final newState = RefAppState();
    newState._data.addAll(UtilCopy.deepCopyJsonableOrClonableFile(_data));
    // 状態フラグだけ引き継ぐ
    newState.isLoaded = isLoaded;
    return newState;
  }

  /// (en) This method is not available for this class.
  ///
  /// (ja) このクラスではこのメソッドは使用できません。
  @override
  Map<String, dynamic> toDict() {
    throw UnimplementedError();
  }

  @override
  bool operator ==(Object other) {
    // 1. 同一参照なら即座に終了
    if (identical(this, other)) return true;
    // 2. 基本的な型チェック
    if (other is! RefAppState) return false;
    final otherData = other._data;
    if (_data.length != otherData.length) return false;
    for (final entry in _data.entries) {
      if (!otherData.containsKey(entry.key)) return false;
      if (!_deepEquals(entry.value, otherData[entry.key])) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered(
      _data.entries.map(
        (e) => Object.hash(e.key.hashCode, _stateValueHash(e.value)),
      ),
    );
  }
}
