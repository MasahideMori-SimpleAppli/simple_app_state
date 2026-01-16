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

> State is global and explicit.  
> Widgets declare which state they depend on.

📘 Full documentation  
https://masahidemori-simpleappli.github.io/simple_app_state_docs/

---

## What makes it different?

SimpleAppState is built around three ideas:

- **Application state lives in one place** (`SimpleAppState`)
- **Widgets subscribe to state, but never own it**
- **Rebuilds are explicit and predictable**

There is no context-based lookup, no hidden dependency graph,
and no widget-owned application state.

---

## Tiny example

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
    final value = count.get();
    return Text('Count: $value');
  }
}
```

Widgets rebuild only when their declared slots change.

---

## Who is this for?

SimpleAppState is especially suited for:

- Medium to large Flutter apps
- Teams with multiple developers
- Projects that need undo/redo, persistence, or testing
- Codebases where **“why did this rebuild?” must always be answerable**

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

- “Dart” and “Flutter” are trademarks of Google LLC.  
  *This package is not developed or endorsed by Google LLC.*