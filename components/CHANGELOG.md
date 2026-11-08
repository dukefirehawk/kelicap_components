# Change Log

## 1.1.2

### Breaking changes in 1.1.2

* **Breaking:** Requires `kelicap`, `kelicap_forms` and `kelicap_observable` 1.1.3, and so `kelicap_compiler` 1.1.3, which rejects some templates that compiled before, such as a two-way binding without an expression (`[(value)]`), and warns about a template or `@HostListener` that reads a member of `$event`. See the changelog of `kelicap_compiler`

### Fixes in 1.1.2

* **Material input:** The single-line and multiline inputs stop a `focus` event on their placeholder from propagating in a release build (dart2js), where it was read dynamically from `$event`. They do it with `stopEventPropagation`, a method of `BaseMaterialInput`
* **App layout:** The temporary and stackable drawers stop a `click` inside their content from propagating in a release build, with the `stopEventPropagation` method of `MaterialTemporaryDrawerComponent`
* **Date range editor:** The preset button and the day inputs stop their `click` and `keypress` events from propagating in a release build, with the `stopEventPropagation` method of `DateRangeEditorComponent`
* **Calendar picker:** The `requestAnimationFrame` callbacks that initialize the calendar and render its months on scroll take the frame's timestamp, a number, where they declared an `Event`
* **DOM service:** `setupAcxRootDomRenderer` sets up the `DomService` to send layout change notifications only when Kelicap has changed the DOM, where it threw a `TypeError` on a `bool` assigned to a function

## 1.1.1

- fix: JS interop errors
- docs: Update readme

## 1.1.0

- chore: Upgrade min sdk to 3.13.0 and other dependency upgrades

## 1.0.0

- chore: Initial release
