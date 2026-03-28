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

State-first, explicit state management for Flutter.

SimpleAppState is a Flutter state management library designed for teams
that value **explicit state ownership, predictable rebuilds,
and long-term maintainability**.

📘 Full documentation
https://masahidemori-simpleappli.github.io/simple_app_state_docs/

---

## The core idea: slot boundaries

The central concept of SimpleAppState is the **slot boundary**.

A slot boundary is the explicit declaration of which state a widget is allowed to depend on.
In SimpleAppState, every widget declares this boundary upfront:

```dart
class UserScreen extends SlotStatefulWidget {
  @override
  List<StateSlot> get slots => [
    userSlot,
    settingsSlot,
  ];

  @override
  SlotState<UserScreen> createState() => _UserScreenState();
}
```

This declaration answers three questions at a glance:

- **What state does this screen depend on?**
- **What will trigger a rebuild?**
- **What is this widget allowed to touch?**

Everything outside the declared slots is, by design, out of scope.

---

## What slot boundaries give you

**Predictable rebuilds**
Widgets only rebuild when their declared slots change.
There are no hidden subscriptions, no context lookups,
and no "why did this rebuild?" mysteries.

**Clear ownership**
Application state lives in `SimpleAppState`, not in widgets.
Widgets subscribe to state, but never own it.

**Safe task delegation**
When assigning a screen to a developer or an AI,
the slot boundary makes the allowed state surface explicit.
Implementers cannot accidentally couple a widget to unrelated state.

**Explicit dependencies**
All state dependencies appear in one place —
the `slots` getter.
No scattered `watch` calls, no implicit subscriptions.

---

## Quick example

```dart
final appState = SimpleAppState();
final count = appState.slot<int>('count', initial: 0);

class CounterView extends SlotStatefulWidget {
  @override
  List<StateSlot> get slots => [count];

  @override
  SlotState<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends SlotState<CounterView> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => count.update((v) => v + 1),
      child: Text('Count: ${count.get()}'),
    );
  }
}
```

---

## State models

**SimpleAppState** — the default state model.
Values are always deep-copied on get and set,
preventing accidental mutation.
Supports serialization, undo/redo, and persistence.

**RefAppState** — for large or non-serializable objects.
Values are stored and returned as references (no copying).
Designed for 3D/2D scene graphs, document trees, and other
performance-critical objects that are expensive to clone.

---

## Coordinating multiple states

When a single user action updates slots across multiple state instances,
use **AppStateGroup** to keep batch updates synchronized:

```dart
final appState = SimpleAppState();
final refState = RefAppState();
final group = AppStateGroup([appState, refState]);

appState.batch(() {
  valueSlot.set(42);
  refSlot.set(newObject);
});
// UI listeners across both states are notified exactly once.
```

States can also join a group individually:

```dart
appState.joinGroup(group);
refState.joinGroup(group);
```

Once grouped, calling `batch` on any member coordinates all members.

---

## Who is this for?

SimpleAppState is especially suited for:

- Medium to large Flutter apps
- Teams with multiple developers or mixed experience levels
- Projects that need undo/redo, persistence, or testing
- Codebases where **"why did this rebuild?" must always be answerable**

---

## Support

This package is developed and maintained by me personally as an open-source project.
For bug reports and feature requests, please use GitHub Issues.

If you need **paid support, consulting, or custom development**
(e.g. priority support, design advice, or implementation help),
please contact my company:

**SimpleAppli Inc.**
https://simpleappli.com/en/index_en.html

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

- "Dart" and "Flutter" are trademarks of Google LLC.
  *This package is not developed or endorsed by Google LLC.*

- GitHub and the GitHub logo are trademarks of GitHub, Inc.
  *This package is not affiliated with GitHub, Inc.*
