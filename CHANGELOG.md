## 0.1.0

### Breaking changes

* Removed the internal equality short-circuit from `SimpleAppState.set`.
  `set()` now always commits a logical state change and notifies listeners,
  even if the new value is equal to the previous value.

  This change removes inconsistent behavior between primitive and
  collection types and clarifies that `set()` represents a logical state
  update rather than a value-diff operation.

## 0.0.18

* Readme has been updated.
* No runtime behavior changes.

## 0.0.17

* The sample code has been updated to be more practical.
* Readme has been updated.
* No runtime behavior changes.

## 0.0.16

* Enforced the `SlotState` contract at the type level for `SlotStatefulWidget`.
  Widgets extending `SlotStatefulWidget` must now return a `SlotState` from
  `createState()`, preventing accidental use of incompatible `State` classes.
* Updated `StateSlotBuilder` to comply with the new `SlotStatefulWidget`
  type contract.
* No runtime behavior changes; this release only strengthens compile-time
  safety and API correctness.

## 0.0.15

* Separated UI listener notifications from state commit notifications.
  State listeners (used for Undo/Redo, persistence, etc.) are now guaranteed
  to be called exactly once per logical state change.
* UI-less state changes no longer trigger unnecessary UI notification flushes.
* Clarified the behavior and deep-copy requirements of `replaceDataFrom`
  in the documentation.
* Added `RefDebugListener` to `RefAppState`, allowing developers to observe
  reference value changes directly, without the old/new semantics used by
  `DebugListener`.

## 0.0.14

* `RefSlot` is now exported as a public API type (`simple_app_state.RefSlot`),
  so it appears in dartdoc and can be referenced by users.
* No runtime behavior changes.

## 0.0.12

* Clarified the memory semantics of `StateSlot` and `RefSlot` in documentation.
* `StateSlot` is now explicitly documented as returning deep-copied values.
* `RefSlot` is now explicitly documented as returning reference values.
* `RefAppState.slot()` now returns `RefSlot<T>` instead of `StateSlot<T>`.
* Clarified that `RefAppState.replaceDataFrom` and `clone` perform deep copies for snapshot and undo purposes.
* Minor documentation and wording fixes.

## 0.0.11

* Fixed the description of some methods in `StateSlot`, as the addition of `RefAppState` caused some inconsistencies.
* The readme has been improved.

## 0.0.10

* `SimpleAppState`'s `replaceDataFrom` now has a `notifyListeners` flag if you want to delay listener notification.
* Added `RefAppState` class. This class can handle reference values.
* Refactoring the project structure.
* Some documentation improvements.

## 0.0.9

* The `onStateChanged` method of `SlotStatefulWidget` is now exposed and can be overridden.
* `SimpleAppState`'s `loadFromDict` now has a `notifyListeners` flag if you want to delay listener notification.

## 0.0.8

* The `set` method has been changed to deep copy the value internally, making the app state less prone to corruption.
* Improved code documentation, example and readme.

## 0.0.7

* Fixed document of loadFromDict in `SimpleAppState`.

## 0.0.6

* Improved consistency of user-defined generic types in `SimpleAppState`.
* Made the `initial` parameter of `SimpleAppState.slot` mandatory.
* Removed method chaining from `set` and `update`, as it is no longer necessary.
* `debugListener` no longer reports the initial value.
* Improved identity and equality checks for `StateSlot`.
* Updated documentation to reflect the new type-safety and initialization rules.

## 0.0.5

* Improved code documentation.

## 0.0.4

* The README.md has been updated.

## 0.0.3

* Improved examples and code documentation.

## 0.0.2

* Fixed an issue where a type error would occur at runtime when using collections of certain types.
* Type checking has been improved.

## 0.0.1

* Initial release.
