# SimpleAppState

```text
Application State Flow (SimpleAppState)

┌──────────────────────────┐
│      SimpleAppState      │
│  (global, explicit)      │
│                          │
│  - Batch updates         │
│  - Undo / Redo           │
│  - Persistence           │
└───────────┬──────────────┘
            │ owns
     ┌──────▼──────┐
     │ StateSlot<T>│
     │ (typed)     │
     └──────┬──────┘
            │ subscribe
   ┌────────▼────────┐
   │   Widgets       │
   │ (no ownership)  │
   └─────────────────┘
```

SimpleAppState is a **state-first** state management library for Flutter.

It is designed to help teams build applications where:

- application state is **defined in one place**
- widgets **subscribe to state**, but never own it
- rebuild behavior is **explicit, minimal, and predictable**

This package is used in production and documented at a level suitable for
new employee onboarding and long-term maintenance.

📘 **Documentation**  
https://masahidemori-simpleappli.github.io/simple_app_state_docs/index.html

---

## Core idea (one minute overview)

> **State is global and explicit.  
> Widgets declare which state they depend on.**

- All application state lives in `SimpleAppState`
- State is accessed via typed `StateSlot<T>`
- Widgets rebuild **only** when their declared slots change

There is no implicit context lookup, no magic dependency tracking,
and no widget-owned application state.

---

## Recommended project structure

A minimal but realistic structure looks like this:

```text
lib/
├── ui/
│   ├── app_state.dart
│   └── pages/
│       └── counter_view.dart
└── main.dart
```

- `ui/app_state.dart` defines **all application state**
- UI widgets live under `ui/pages/`
- Widgets import state, but **state never imports widgets**

This makes it easy to answer:

- “Where is this state defined?”
- “Which widgets depend on it?”

---

## Quick Start (minimal & realistic)

### 1. Define application state (`ui/app_state.dart`)

Create a single `SimpleAppState` instance.
In most apps, this object lives for the entire app lifetime.

```dart
final appState = SimpleAppState();
```

Define all state slots in the same file:

```dart
final count = appState.slot<int>('count', initial: 0);
```

- Slot types are fixed on first access
- Slot names must be unique within the same state
- State is explicit and visible at a glance

---

### 2. Update state

Use `set` or `update`:

```text
count.set(1);
```

```text
count.update((old) => old + 1);
```

- Updates are applied immediately
- Subscribed widgets rebuild automatically
- Values follow **value semantics** (no accidental mutation)

---

### 3. Bind state to a widget

Widgets declare which slots they depend on.

```dart
class CounterView extends SlotStatefulWidget {
  const CounterView({super.key});

  @override
  List<StateSlot> get slots => [count];

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends SlotState<CounterView> {
  @override
  Widget build(BuildContext context) {
    final value = count.get();

    return Column(
      children: [
        Text('Count: $value'),
        ElevatedButton(
          onPressed: () {
            count.update((v) => v + 1);
          },
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

- Widgets do not own application state
- Dependencies are explicit
- Rebuilds are deterministic and minimal

---

### 4. Builder style (for small widgets)

For simple cases, use `StateSlotBuilder`:

```text
StateSlotBuilder<int>(
  slot: [count],
  builder: (context) {
    final value = count.get();
    return Text('Count: $value');
  },
);
```

---

## Common mistakes (short version)

### ❌ Treating state as widget-owned

```dart
class MyWidget extends StatelessWidget {
  final appState = SimpleAppState(); // ❌
}
```

Widgets are ephemeral.  
Application state must live outside widgets.

✅ **Correct**

```dart
final appState = SimpleAppState();
final count = appState.slot<int>('count', initial: 0);
```

---

### ❌ Mutating values returned from `get()`

```text
final list = logs.get();
list?.add('new entry'); // ❌ has no effect
```

Values are always deep-copied.

✅ **Correct**

```text
logs.update((old){
  final next = List<String>.from(old);
  next.add('new entry');
  return next;
});

```

---

### ❌ Forgetting to declare slot dependencies

If a widget does not list a slot, it will **not rebuild**.

```dart
@override
List<StateSlot> get slots => [count]; // ✅
```

---

## Philosophy (summary)

- **State-first, not widget-first**
- **Explicit over implicit**
- **Simplicity over magic**

SimpleAppState avoids:

- context-based lookups
- hidden dependency graphs
- implicit lifetimes

If a widget rebuilds, you can always explain **why**.

--- 

### Why there is no "unsafe" API

SimpleAppState does not provide an unsafe escape hatch.

This is a deliberate design choice.

Experience shows that unsafe state access is rarely used "just once" —
it quickly spreads and breaks assumptions required for
undo / redo, persistence, and predictable rebuilds.

If some data cannot be safely stored in SimpleAppState,
it is usually a sign that the data belongs to a widget,
not to the application state.

---

## Designed beyond Flutter

The core state model does not depend on Flutter.

The same state can be used for:

- persistence and restore
- undo / redo
- background logic
- unit testing without widgets

Flutter integration is a thin subscription layer.

---

## Undo / Redo support (design-level)

SimpleAppState makes undo and redo **surprisingly simple**.

Because application state is:

- centralized
- immutable-by-snapshot
- independent of widget lifetimes

undo / redo can be implemented by storing **state snapshots**.

SimpleAppState integrates naturally with
[`file_state_manager`](https://pub.dev/packages/file_state_manager)
to provide history management.

```text
final state = SimpleAppState();
final fsm = FileStateManager(state, stackSize: 20);

state.setStateListener((s) {
  fsm.push(s);
});
```

Each finalized state change is recorded as a snapshot.
Batch updates produce a single undo step.

Undo and redo simply restore previous snapshots:

```text
final prev = fsm.undo();
fsm.skipNextPush();
state.replaceDataFrom(prev as SimpleAppState);
```

### Why this works so well

- Undo history reflects **logical state changes**
- Widgets do not need special handling
- Slot references remain valid across undo / redo
- No widget rebuilds are triggered accidentally

Undo / redo is not a special feature —
it is a natural consequence of SimpleAppState’s design.

📘 For full details, see the [
`Undo and Redo`](https://masahidemori-simpleappli.github.io/simple_app_state_docs/advanced/undo_redo.html)
section in the documentation.

---

## Support

There is no support for this package, but if you find any bugs please report them.  
This package will be fixed with high priority.

---

## About version control

The C part will be changed at the time of version upgrade.

- Changes such as adding variables, structure change that cause problems when reading previous
  files.
    - C.X.X
- Adding methods, etc.
    - X.C.X
- Minor changes and bug fixes.
    - X.X.C

---

## License

This software is released under the Apache-2.0 License, see LICENSE file.

Copyright 2026 Masahide Mori

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

---

## Trademarks

- “Dart” and “Flutter” are trademarks of Google LLC.  
  *This package is not developed or endorsed by Google LLC.*