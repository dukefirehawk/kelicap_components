# Change Log

## 1.1.3

### Fixes in 1.1.3

* **Ruler:** `DomRuler` ignores an empty CSS class, and splits one that contains whitespace (`'a b'`) into its classes, where `classList` threw, so that `update` left the element half-updated, and could no longer update its classes
* **Ruler:** An update of the CSS classes of an element, as an overlay's `modal` and `visible`, removes only those the ruler added and the update no longer asks for. It removed every class it had added, including one the element already had, such as a class copied from the host of a `material-popup`, and removed and added again the classes it kept
* **Pubspec:** The package links to its documentation, on the [Kelicap GitBook site](https://dukefirehawk.gitbook.io/kelicap-docs), from pub.dev

## 1.1.2

### Breaking changes in 1.1.2

* **Breaking:** Requires `kelicap`, `kelicap_forms` and `kelicap_observable` 1.1.3, and so `kelicap_compiler` 1.1.3, which rejects some templates that compiled before, such as a two-way binding without an expression (`[(value)]`), and warns about a template or `@HostListener` that reads a member of `$event`. See the changelog of `kelicap_compiler`

### Fixes in 1.1.2

* **Menu:** `MenuItem` and `SelectableMenuItem` can be created without `itemSuffixes`, which threw a `TypeError` (`Null is not a subtype of Iterable`), so that every menu failed to show. An `itemSuffix` is their only suffix, where it threw as well
* **Material input:** The single-line and multiline inputs stop a `focus` event on their placeholder from propagating in a release build (dart2js), where it was read dynamically from `$event`. They do it with `stopEventPropagation`, a method of `BaseMaterialInput`
* **App layout:** The temporary and stackable drawers stop a `click` inside their content from propagating in a release build, with the `stopEventPropagation` method of `MaterialTemporaryDrawerComponent`
* **Date range editor:** The preset button and the day inputs stop their `click` and `keypress` events from propagating in a release build, with the `stopEventPropagation` method of `DateRangeEditorComponent`
* **Calendar picker:** The `requestAnimationFrame` callbacks that initialize the calendar and render its months on scroll take the frame's timestamp, a number, where they declared an `Event`
* **Focus indicator:** `FocusIndicatorController` removes its `focus` and `blur` listeners from `window` when it is disabled, where they stayed, and a pair more was added each time it was enabled again
* **Popup:** A popup that follows its source, and the focus indicator, no longer create a JavaScript function for each animation frame
* **DOM service:** `setupAcxRootDomRenderer` sets up the `DomService` to send layout change notifications only when Kelicap has changed the DOM, where it threw a `TypeError` on a `bool` assigned to a function
* **README:** The banner and the License badge link work on pub.dev, and the installation snippet asks for `^1.1.2`

## 1.1.1

- fix: JS interop errors
- docs: Update readme

## 1.1.0

- chore: Upgrade min sdk to 3.13.0 and other dependency upgrades

## 1.0.0

- chore: Initial release
