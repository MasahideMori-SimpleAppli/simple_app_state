import 'package:file_state_manager/file_state_manager.dart';
import 'package:simple_app_state/src/core/util_copy.dart';

part 'state_slot.dart';

class _ListenerEntry {
  final String subscriberId;
  final void Function() callback;

  /// * [subscriberId]: An ID used to identify subscribers to StateSlot change
  /// notifications.
  /// One ID is assigned per State (widget).
  /// Even if the same State subscribes to multiple slots,
  /// the screen will only be updated once.
  /// * [callback]: A callback that is invoked when the value corresponding to
  /// the specified key changes.
  _ListenerEntry(this.subscriberId, this.callback);
}

/// A listener that returns the old and new values for a key for
/// debugging purposes.
typedef DebugListener =
    void Function(StateSlot key, dynamic oldValue, dynamic newValue);

/// A listener for file_state_manager management that returns once the state
/// has been determined.
/// In batch processing, it returns only once at the end of the processing.
typedef StateListener = void Function(SimpleAppState nowState);

class SimpleAppState extends CloneableFile {
  static const String className = "SimpleAppState";
  static const String version = "1";
  final Map<String, dynamic> _data = {};

  // The following are temporary parameters that cannot be deep copied (cloned):
  final Map<String, StateSlot<dynamic>> _slots = {};
  final Map<StateSlot, List<_ListenerEntry>> _uiListeners = {};
  DebugListener? _debugListener;
  StateListener? _stateListener;

  // Flag indicating whether a batch is currently being processed.
  bool _isBatch = false;

  // Already loaded flag for when using loadFromDict.
  bool isLoaded = false;

  // The subscriberId updated during the batch.
  final Set<String> _pendingSubscriberIds = {};

  /// * [data]: The initial value of the managed state.
  /// This can usually be null.
  /// This value is assigned by the factory constructor when the data is
  /// restored.
  SimpleAppState({Map<String, dynamic>? data}) {
    if (data != null && data.isNotEmpty) {
      _data.addAll(data);
    }
  }

  /// (en)
  /// Returns a typed state slot associated with the given name.
  ///
  /// If the slot does not exist yet, a new slot is created and its type is
  /// fixed on first access.
  ///
  /// If [initial] is provided and no value is currently stored for this slot,
  /// the initial value is stored at the time of slot creation.
  /// If a value already exists (for example, restored via fromDict),
  /// [initial] is ignored.
  ///
  /// (ja)
  /// 指定された名前に対応する、型付きの状態スロットを取得します。
  ///
  /// スロットがまだ存在しない場合は新しく作成され、
  /// その時点でスロットの型が確定します。
  ///
  /// [initial] が指定されており、かつこのスロットにまだ値が存在しない場合のみ、
  /// スロット作成時に初期値として設定されます。
  /// すでに値が存在する場合（fromDict によって復元された場合など）、
  /// [initial] は無視されます。
  ///
  /// * [name] : The slot name. This name will be thrown if an error occurs,
  /// so do not put any confidential information in it.
  /// * [initial] : Initial value of the slot, used only when no value exists yet.
  ///
  /// Example:
  /// ```dart
  /// final state = SimpleAppState(null);
  /// final count = state.slot<int>('count', initial: 0);
  /// ```
  StateSlot<T> slot<T>(String name, {T? initial}) {
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
    final slot = StateSlot<T>._(name, this);
    _slots[name] = slot;
    // 初回作成時のみ初期値をセット
    if (!_data.containsKey(name) && initial != null) {
      _set<T>(slot, initial);
    }
    return slot;
  }

  /// (en) Adds a debug listener for developers.
  /// This listener will notify you of any value changes whenever they are made.
  /// Please note that this means that any intermediate changes to values
  /// will be tracked during batch processing, etc.
  ///
  /// (ja) 開発者用のデバッグリスナを追加します。
  /// このリスナは、何らかの値が変更された際に常に値の変更を通知します。
  /// このため、バッチ処理などでは値の途中変更が全て追跡されることに注意してください。
  ///
  /// * [listener] : Listener for debug use.
  void setDebugListener(DebugListener? listener) {
    _debugListener = listener;
  }

  /// (en) Adds a listener suitable for managing Undo and Redo.
  /// This listener will only notify when the value change is confirmed.
  /// For this reason, in batch processing, etc.,
  /// notification will only be sent once at the end of the processing.
  ///
  /// (ja) Undo, Redoの管理に適したリスナを追加します。
  /// このリスナは、値の変更が確定した時のみ通知します。
  /// このため、バッチ処理などでは処理の最後で１回だけ通知が行われます。
  ///
  /// * [listener] : A listener that is notified when the value changes.
  void setStateListener(StateListener? listener) {
    _stateListener = listener;
  }

  /// (en) Remove StateListener.
  ///
  /// (ja) StateListenerを削除します。
  void removeStateListener() {
    _stateListener = null;
  }

  /// (en) Adds a listener for UI updates associated with the specified
  /// key and ID.
  /// Normally, you should not use this directly. Instead, consider using
  /// a class that extends SlotStatefulWidget or StateSlotBuilder.
  ///
  /// (ja) 指定キー、及びIDに紐付いたUI更新用のリスナを追加します。
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
  ) {
    final list = _uiListeners.putIfAbsent(key, () => []);
    list.add(_ListenerEntry(subscriberId, callback));
  }

  /// (ja) Deletes the UI update listener associated with the specified
  /// key and ID.
  /// Normally, you should not use this directly. Instead, consider using
  /// a class that extends SlotStatefulWidget or StateSlotBuilder.
  ///
  /// (ja) 指定キー、及びIDに紐付いたUI更新用のリスナを削除します。
  /// 通常はこれを直接使用せず、SlotStatefulWidgetを拡張したクラスか
  /// StateSlotBuilderの利用を検討してください。
  ///
  /// * [subscriberId]: ID to identify the subscriber to StateSlot change
  /// notifications.
  /// * [key]: Slot for manipulating the managed value.
  /// If null, all listeners related to subscriberId will be deleted.
  /// If not null, only the listener associated with key will be deleted.
  void removeUIListener({required String subscriberId, StateSlot? key}) {
    if (key != null) {
      // 単一 key の listener 削除
      final list = _uiListeners[key];
      if (list != null) {
        list.removeWhere((entry) => entry.subscriberId == subscriberId);
        if (list.isEmpty) _uiListeners.remove(key);
      }
      return;
    }
    // 全 key の subscriberId を削除
    for (final k in _uiListeners.keys.toList()) {
      final list = _uiListeners[k]!;
      list.removeWhere((entry) => entry.subscriberId == subscriberId);
      if (list.isEmpty) _uiListeners.remove(k);
    }
  }

  /// (en) Retrieves the value associated with the specified key.
  /// The retrieved value is always a deep copy of the registered object.
  /// Therefore, directly editing the retrieved value does not affect the state
  /// of the app.
  ///
  /// (ja) 指定されたキーに紐づく値を取得します。
  /// 取得できる値は常に登録されたオブジェクトのディープコピーです。
  /// このため、取得した値を直接編集してもアプリの状態に影響はありません。
  ///
  /// * [key] : target slot.
  T? _get<T>(StateSlot<T> key) {
    final raw = _data[key.name];
    if (raw == null) return null;
    return UtilCopy.deepCopyJsonableOrClonableFile(raw) as T?;
  }

  /// (en) Sets the value for the specified key.
  /// Any listeners associated with the key will also be notified.
  /// This method returns the StateSlot provided as an argument for
  /// method chaining.
  ///
  /// (ja) 指定されたキーに関して値をセットします。
  /// キーと紐付いたリスナーにも通知されます。
  /// このメソッドは、メソッドチェーンのために引数で与えたStateSlotを返します。
  StateSlot<T> _set<T>(StateSlot<T> key, T? value) {
    final oldValue = _data[key.name] as T?;
    if (oldValue == value) return key;
    _data[key.name] = value;
    _debugListener?.call(
      key,
      UtilCopy.deepCopyJsonableOrClonableFile(oldValue) as T?,
      UtilCopy.deepCopyJsonableOrClonableFile(value) as T?,
    );
    _notify(key);
    return key;
  }

  /// (en) Performs a batch update.
  /// The given fn will execute its processes in order as usual, but
  /// only the callbacks to the listener will be consolidated at the end of
  /// the process.
  /// The consolidated callback will be called only once for each
  /// ListenerEntry.subscriberId.
  ///
  /// (ja) Batch更新を行います。
  /// 与えたfnの内部では通常通り順番に処理が実行されますが、
  /// リスナへのコールバックのみが、処理の最後に統合されます。
  /// 統合されたコールバックでは、ListenerEntry.subscriberId毎に1回だけ
  /// コールバックされます。
  ///
  /// * [fn] : Multiple set etc. calls that you want to batch together.
  void batch(void Function() fn) {
    final wasBatching = _isBatch;
    _isBatch = true;
    try {
      fn();
    } finally {
      _isBatch = wasBatching;
      if (!wasBatching) {
        final ids = Set.of(_pendingSubscriberIds);
        _pendingSubscriberIds.clear();
        _flushSubscriberIds(ids);
      }
    }
  }

  /// (en) Notifies registered listeners of a state change.
  ///
  /// (ja) 登録されているリスナーに状態の変更を通知します。
  ///
  /// * [key] : The StateSlot involved in this change.
  void _notify<T>(StateSlot<T> key) {
    final targets = _uiListeners.containsKey(key) ? _uiListeners[key] : null;
    if (targets == null) {
      _requestNotify(null);
    } else {
      for (final listener in targets) {
        _requestNotify(listener.subscriberId);
      }
    }
  }

  /// (en) A method that determines whether to send a direct notification
  /// depending on whether the processing is batch or not.
  /// subscriberId == null indicates that there is no UI listener corresponding
  /// to this change.
  /// Even in non-batch mode, a commit notification is sent as a logical
  /// state change.
  ///
  /// (ja) バッチ処理かどうかによって直接通知するかどうかを切り分けるメソッド。
  /// subscriberId == null は、
  /// この変更に対応する UI リスナが存在しないことを表します。
  /// non-batch の場合でも、論理的な状態変更として commit 通知は行われます。
  ///
  /// * [subscriberId] : The ID of the subscriber you want to call back.
  void _requestNotify(String? subscriberId) {
    if (subscriberId == null) {
      if (!_isBatch) {
        _flushSubscriberIds({});
      }
    } else {
      if (_isBatch) {
        _pendingSubscriberIds.add(subscriberId);
      } else {
        _flushSubscriberIds({subscriberId});
      }
    }
  }

  /// (en) A method that starts all listeners for the specified set of
  /// IDs at once.
  ///
  /// (ja) 指定されたIDセットに関するリスナーをまとめて起動するメソッド。
  ///
  /// * [subscriberIds]: A set of subscriber IDs you want to call back.
  /// If no listeners exist, an empty set is passed.
  void _flushSubscriberIds(Set<String> subscriberIds) {
    final calledSubscriberIds = <String>{};
    for (final entry in _uiListeners.entries) {
      for (final listener in entry.value) {
        final id = listener.subscriberId;
        if (subscriberIds.contains(id) && calledSubscriberIds.add(id)) {
          listener.callback();
        }
      }
    }
    // 変更確定後に最新の状態を通知する。
    // これはサブスクライバーの有無に関わらず、
    // 論理的な状態変更があれば必ず呼ばれる。
    _stateListener?.call(this);
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  /// * [fromDictMap] : A map of restoration methods per object.
  /// The key is the object name, and must correspond to the name defined
  /// in each object's serialization method as {"className": className}.
  /// If a dictionary with the same key name and "className" field is found,
  /// the object will be restored using the function corresponding to the key.
  factory SimpleAppState.fromDict(
    Map<String, dynamic> src,
    Map<String, CloneableFile Function(Map<String, dynamic>)> fromDictMap,
  ) {
    final rawData = src["data"];
    final restoredData = UtilCopy.fromDictJsonableOrClonableFile(
      rawData,
      fromDictMap,
    );
    return SimpleAppState(data: restoredData as Map<String, dynamic>?);
  }

  /// (en) Loads state data from a dictionary after creation.
  ///
  /// Existing values are replaced.
  /// Slots that do not yet exist are created during loading.
  ///
  /// This method is intended for delayed loading (e.g. from cloud storage).
  /// It follows the same type-safety rules as [slot]:
  /// if a slot already exists, the loaded value must match its type.
  ///
  /// Listener notifications are batched and flushed once after loading.
  ///
  /// (ja) 作成後に辞書から状態データを読み込みます。
  ///
  /// 既存の値は置き換えられます。
  /// まだ存在しないスロットは読み込み中に作成されます。
  ///
  /// このメソッドは、遅延読み込み（例: クラウドストレージから）を目的としています。
  /// [slot] と同じ型安全性のルールに従います。
  /// スロットが既に存在する場合、読み込まれた値はその型と一致する必要があります。
  ///
  /// リスナー通知はバッチ処理され、読み込み後に一度フラッシュされます。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  /// * [fromDictMap] : A map of restoration methods per object.
  /// The key is the object name, and must correspond to the name defined
  /// in each object's serialization method as {"className": className}.
  /// If a dictionary with the same key name and "className" field is found,
  /// the object will be restored using the function corresponding to the key.
  void loadFromDict(
    Map<String, dynamic> src,
    Map<String, CloneableFile Function(Map<String, dynamic>)> fromDictMap,
  ) {
    final data = src['data'];
    if (data == null) return;
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid state data format');
    }
    batch(() {
      for (final entry in data.entries) {
        final key = entry.key;
        final rawValue = entry.value;
        final restoredValue = UtilCopy.fromDictJsonableOrClonableFile(
          rawValue,
          fromDictMap,
        );
        final slot = _slots[key];
        if (slot == null) {
          throw StateError(
            'Unknown state slot "$key". '
            'All slots must be declared via slot<T>() before loading.',
          );
        }
        _set(slot, restoredValue);
      }
    });
    isLoaded = true;
  }

  /// (en) For operations such as Undo, the current listeners are retained and
  /// only the data is replaced.
  /// After that, notifications are sent to all UI listeners in a batch process
  /// to update.
  /// In other words, the screen the user currently has open is automatically
  /// updated.
  ///
  /// (ja) Undo操作などで、現在のリスナを保持したままデータだけを入れ替えます。
  /// その後、更新のために全てのUIリスナにバッチ処理で通知が送られます。
  /// つまり、ユーザーが現在開いている画面に関して自動更新が行われます。
  ///
  /// * [other] : Source data to copy.
  void replaceDataFrom(SimpleAppState other) {
    _data
      ..clear()
      ..addAll(UtilCopy.deepCopyJsonableOrClonableFile(other._data));
    notifyAll(); // 今いる listener に通知
  }

  /// (en) It will batch notifications to all UI listeners immediately.
  ///
  /// (ja) 全てのUIリスナにバッチ処理で即時に通知を送ります。
  void notifyAll() {
    batch(() {
      for (final i in _uiListeners.keys) {
        _notify(i);
      }
    });
  }

  @override
  SimpleAppState clone() {
    final newState = SimpleAppState();
    newState._data.addAll(UtilCopy.deepCopyJsonableOrClonableFile(_data));
    // 状態フラグだけ引き継ぐ
    newState.isLoaded = isLoaded;
    return newState;
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "data": UtilCopy.toDictJsonableOrClonableFile(_data),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SimpleAppState) return false;
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

  /// (en) Hash calc function.
  ///
  /// (ja) オブジェクトのハッシュ計算を行います。
  int _stateValueHash(dynamic value) {
    if (value == null) return 0;
    if (value is CloneableFile) {
      return value.hashCode;
    }
    if (value is Map) {
      return UtilObjectHash.calcMap(value);
    }
    if (value is List) {
      return UtilObjectHash.calcList(value);
    }
    if (value is Set) {
      return UtilObjectHash.calcSet(value);
    }
    // int, double, String, bool など
    return value.hashCode;
  }

  /// (en) Compares objects for equality.
  /// For CloneableFiles, it is assumed that each object overrides ==.
  ///
  /// (ja) オブジェクトの等価性の比較を行います。
  /// CloneableFileに関しては、各オブジェクトで == がオーバーライドされているもの
  /// として扱います。
  bool _deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a is CloneableFile && b is CloneableFile) {
      return a == b; // CloneableFile 側で == を定義する前提
    }
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key)) return false;
        if (!_deepEquals(a[key], b[key])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }
}
