import 'package:flutter/material.dart';
import 'package:simple_app_state/src/core/state_slot.dart';

/// (en) A stateful widget that is tied to state management and automatically
/// updates the screen.
/// Users can extend this class or use the builder.
///
/// (ja) 状態管理と紐付き、自動で画面更新されるステートフルウィジェット。
/// ユーザーはこのクラスをextendsして利用するか、ビルダーを使用できます。
abstract class SlotStatefulWidget extends StatefulWidget {
  const SlotStatefulWidget({super.key});

  /// (en) The screen will be automatically updated in association with
  /// the slot you set here.
  /// (ja) ここで設定したスロットと自動的に紐付いて画面が更新されます。
  List<StateSlot> get slots;

  @override
  SlotState<SlotStatefulWidget> createState();
}

abstract class SlotState<T extends SlotStatefulWidget> extends State<T> {
  late final String _subscriberId;

  @override
  void initState() {
    super.initState();
    _subscriberId = identityHashCode(this).toString();
    for (final slot in widget.slots) {
      slot.state.addUIListener(slot, _subscriberId, onStateChanged);
    }
  }

  /// (en) Requests a widget rebuild.
  /// Override if additional processing is required.
  /// Be sure to call super.onStateChanged() unless
  /// you intentionally want to suppress rebuilding.
  ///
  /// (ja) ウィジェットのリビルドをリクエストするメソッドです。
  /// 追加の処理が必要な場合はオーバーライドしてください。
  /// ただし、意図的に再構築を抑制したい場合を除き、
  /// 必ず super.onStateChanged() を呼び出してください。
  void onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final slot in widget.slots) {
      slot.state.removeUIListener(subscriberId: _subscriberId, key: slot);
    }
    super.dispose();
  }
}
