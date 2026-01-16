import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_app_state/simple_app_state.dart';

///////////////////////////////////////////////////////////////////////////////
///
/// Application State Definition (This is usually written in lib/ui/app_state.dart.)
///
/// - Widgets do NOT own application state.
/// - StateSlots are defined once and reused everywhere.
///
///////////////////////////////////////////////////////////////////////////////

/// A state container shared across the app
final appState = SimpleAppState();

/// counter value（`int`）
final countSlot = appState.slot<int>('count', initial: 0);

/// log（`List<String>`）
final logsSlot = appState.slot<List<String>>(
  'logs',
  initial: [],
  caster: (raw) => (raw as List).cast<String>(),
);

void main() {
  /// You can easily define a debugger to use only during development.
  if (kDebugMode) {
    appState.setDebugListener((slot, oldV, newV) {
      /// You can also use slot.name here to print only in a specific slot.
      debugPrint(
        "Changed Slot:${slot.name}, Value changed from:$oldV, to:$newV",
      );
    });
  }
  runApp(const MyApp());
}

///////////////////////////////////////////////////////////////////////////////
///
/// Flutter Application
///
///////////////////////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CounterPage());
  }
}

///////////////////////////////////////////////////////////////////////////////
///
/// UI Layer
///
/// Widgets subscribe to StateSlots.
/// They never store application state themselves.
///
///////////////////////////////////////////////////////////////////////////////

class CounterPage extends SlotStatefulWidget {
  const CounterPage({super.key});

  @override
  List<StateSlot> get slots => [countSlot, logsSlot];

  @override
  SlotState<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends SlotState<CounterPage> {
  @override
  Widget build(BuildContext context) {
    final count = countSlot.get();
    final logs = logsSlot.get();

    return Scaffold(
      appBar: AppBar(title: const Text('SimpleAppState Example')),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Count: $count',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              appState.batch(() {
                countSlot.update((v) => v + 1);
                logsSlot.update((oldCopy) {
                  oldCopy.add('Increment at ${DateTime.now()}');
                  return oldCopy;
                });
              });
            },
            child: const Text('Increment (batched)'),
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(logs[index]));
              },
            ),
          ),
        ],
      ),
    );
  }
}
