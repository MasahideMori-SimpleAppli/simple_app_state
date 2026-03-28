part of 'app_state_impl.dart';

/// (en) A class that groups multiple [SimpleAppState] and [RefAppState]
/// instances for coordinated batch processing.
///
/// When any member of the group calls [batch], all members are batched
/// together as a unit.
/// This ensures that UI listeners and state listeners fire only once across
/// the entire group, regardless of how many members are updated.
///
/// Members can be registered at construction time or later via [add].
/// A state can also join a group by calling [SimpleAppState.joinGroup].
///
/// (ja) 複数の [SimpleAppState] および [RefAppState] インスタンスをグループ化し、
/// バッチ処理を連動させるクラスです。
///
/// グループのいずれかのメンバーが [batch] を呼ぶと、
/// グループ全体がひとつの単位としてバッチ処理されます。
/// これにより、何件のメンバーを更新しても、UIリスナーおよびステートリスナーへの
/// 通知はグループ全体でそれぞれ1回だけ行われます。
///
/// メンバーはコンストラクタで登録するか、後から [add] で追加できます。
/// また [SimpleAppState.joinGroup] を呼ぶことでもグループに参加できます。
///
/// Usage example:
/// ```dart
/// final simpleState = SimpleAppState();
/// final refState = RefAppState();
/// final group = AppStateGroup([simpleState, refState]);
///
/// simpleState.batch(() {
///   simpleSlot.set(1);
///   refSlot.set(someObject);
/// });
/// ```
class AppStateGroup {
  final List<SimpleAppState> _states = [];

  /// (en) Creates a group, optionally with an initial list of states.
  ///
  /// (ja) グループを作成します。初期メンバーを指定することもできます。
  ///
  /// * [states] : Initial list of states to add to the group.
  AppStateGroup([List<SimpleAppState>? states]) {
    if (states != null) {
      for (final s in states) {
        add(s);
      }
    }
  }

  /// (en) Adds a state to this group.
  /// If the state is already a member, this call is ignored.
  /// The state's [SimpleAppState._group] is updated to point to this group.
  ///
  /// (ja) このグループにステートを追加します。
  /// すでにメンバーである場合は何もしません。
  /// ステートの [SimpleAppState._group] がこのグループを指すように更新されます。
  ///
  /// * [state] : The state to add.
  void add(SimpleAppState state) {
    if (_states.any((s) => identical(s, state))) return;
    _states.add(state);
    state._group = this;
  }

  /// (en) Removes a state from this group.
  /// If the state is not a member, this call is ignored.
  /// After removal, the state resumes independent batch processing.
  ///
  /// (ja) このグループからステートを削除します。
  /// メンバーでない場合は何もしません。
  /// 削除後、そのステートは独立したバッチ処理に戻ります。
  ///
  /// * [state] : The state to remove.
  void remove(SimpleAppState state) {
    final before = _states.length;
    _states.removeWhere((s) => identical(s, state));
    if (_states.length < before) {
      if (identical(state._group, this)) state._group = null;
    }
  }

  /// (en) Performs a batch update across all members of this group.
  /// All members are set to batch mode before [fn] executes.
  /// After [fn] completes, UI listeners and state listeners for all members
  /// are flushed once.
  /// Members that were already in batch mode before this call are not
  /// flushed, preserving any outer batch context.
  ///
  /// (ja) グループ全体に対してバッチ更新を行います。
  /// [fn] の実行前に全メンバーがバッチモードに入ります。
  /// [fn] の完了後、全メンバーのUIリスナーおよびステートリスナーが
  /// まとめて1回フラッシュされます。
  /// この呼び出し前からバッチモードだったメンバーはフラッシュされず、
  /// 外側のバッチコンテキストが保持されます。
  ///
  /// * [fn] : Multiple set etc. calls that you want to batch together.
  void batch(void Function() fn) {
    final wasBatching = [for (final s in _states) s._isBatch];
    for (final s in _states) {
      s._isBatch = true;
    }
    try {
      fn();
    } finally {
      final globalCalledIds = <String>{};
      for (int i = 0; i < _states.length; i++) {
        _states[i]._isBatch = wasBatching[i];
        if (!wasBatching[i]) {
          final allIds = Set.of(_states[i]._pendingSubscriberIds);
          _states[i]._pendingSubscriberIds.clear();
          final newIds = allIds.difference(globalCalledIds);
          globalCalledIds.addAll(allIds);
          _states[i]._flushUIListeners(newIds);
          _states[i]._flushStateListener();
        }
      }
    }
  }
}
