import 'package:flutter/material.dart';
import 'package:simple_app_state/simple_app_state.dart';
import 'package:simple_app_state/src/core/state_slot.dart';

/// (en) A builder that can be used when you want to update a widget depending
/// on the value of a slot.
///
/// (ja) スロットの値依存でウィジェットを更新したい時に使用できるビルダー。
class StateSlotBuilder extends SlotStatefulWidget {
  final List<StateSlot> slotList;
  final Widget Function(BuildContext context) builder;

  const StateSlotBuilder({
    required this.slotList,
    required this.builder,
    super.key,
  });

  @override
  List<StateSlot> get slots => slotList;

  @override
  State<StateSlotBuilder> createState() => _StateSlotBuilderState();
}

class _StateSlotBuilderState extends SlotState<StateSlotBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
