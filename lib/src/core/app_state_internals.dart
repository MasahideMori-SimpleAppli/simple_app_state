part of 'app_state_impl.dart';

/// 参照が必要だが、外部に公開しない共通フィールド
mixin _AppStateInternals {
  // state data.
  final Map<String, dynamic> _data = {};

  // The following are temporary parameters that cannot be deep copied (cloned):
  final Map<String, StateSlot<dynamic>> _slots = {};
}
