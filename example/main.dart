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
  caster: (raw) => raw != null ? (raw as List).cast<String>() : null,
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

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SimpleAppState Example')),
      body: Column(
        children: [
          const SizedBox(height: 32),

          /// Minimal example of a single slot dependency
          StateSlotBuilder(
            slotList: [countSlot],
            builder: (context) {
              final count = countSlot.get();
              return Text(
                'Count: $count',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            },
          ),
          const SizedBox(height: 24),

          /// Batch multiple slot updates
          ElevatedButton(
            onPressed: () {
              appState.batch(() {
                countSlot.update((v) => (v ?? 0) + 1);

                logsSlot.update((list) {
                  final next = List<String>.from(list ?? const []);
                  next.add('Increment at ${DateTime.now()}');
                  return next;
                });
              });
            },
            child: const Text('Increment (batched)'),
          ),
          const Divider(height: 32),

          /// Read-only UI based on deep copy
          Expanded(
            child: StateSlotBuilder(
              slotList: [logsSlot],
              builder: (context) {
                final items = logsSlot.get() ?? [];
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(items[index]));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
