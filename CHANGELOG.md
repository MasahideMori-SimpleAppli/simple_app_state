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
