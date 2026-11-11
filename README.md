# Kelicap Web Components

[![Kelicap Web Components](assets/branding/kelicap_1_banner.jpeg)](https://github.com/dukefirehawk/kelicap_components)

[![Pub Version](https://img.shields.io/pub/v/kelicap_components)](https://pub.dev/packages/kelicap_components)
[![License](https://img.shields.io/github/license/dukefirehawk/kelicap_components)](https://github.com/dukefirehawk/kelicap_components/blob/main/LICENSE)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

A library of Material Design 2 web components for the [Kelicap](https://github.com/dukefirehawk/kelicap) web framework: buttons, inputs, selects, menus, dialogs, date pickers, tabs, trees and more.

Kelicap Components is a fork of AngularDart Components (`angular_components`), updated for Dart 3.13 and [`package:web`](https://pub.dev/packages/web). The components are Kelicap `@Component`s and `@Directive`s, and they work in both development (DDC) and release (dart2js) builds.

## Packages

| Package | Description |
| --- | --- |
| [`kelicap_components`](components/) | The component library, published on [pub.dev](https://pub.dev/packages/kelicap_components) |
| [`component_gallery/`](component_gallery/) | A gallery app that demonstrates every component (not published) |

## Getting started

### Requirements

- Dart SDK 3.13 or later
- [`kelicap`](https://pub.dev/packages/kelicap) 1.1.3 or later

### Installation

Add the package to your app's `pubspec.yaml`:

```yaml
dependencies:
  kelicap: ^1.1.3
  kelicap_components: ^1.1.3
```

The components use the Roboto font and the Material Icons font. Load them in your app's `web/index.html`:

```html
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700">
<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
```

### Usage

Import a component's library and list the component in the `directives` of your own component:

```dart
import 'package:kelicap/kelicap.dart';
import 'package:kelicap_components/material_button/material_button.dart';
import 'package:kelicap_components/material_icon/material_icon.dart';

@Component(
  selector: 'my-app',
  template: '''
    <material-button raised (trigger)="count = count + 1">
      <material-icon icon="add"></material-icon>
      Clicked {{count}} times
    </material-button>
  ''',
  directives: [MaterialButtonComponent, MaterialIconComponent],
)
class AppComponent {
  int count = 0;
}
```

To bring in all the components at once, import `package:kelicap_components/kelicap_components.dart` and use `materialDirectives` and `materialProviders`.

Components that open popups or overlays, such as menus, selects, tooltips, dialogs and date pickers, need the overlay services. Provide them in your app's root injector:

```dart
import 'package:kelicap/kelicap.dart';
import 'package:kelicap_components/laminate/popup/module.dart';

import 'main.template.dart' as ng;

@GenerateInjector([popupBindings])
final InjectorFactory rootInjector = ng.rootInjector$Injector;

void main() {
  runApp(ng.AppComponentNgFactory, createInjector: rootInjector);
}
```

## Components

| Area | Components |
| --- | --- |
| Buttons | `MaterialButtonComponent`, `MaterialFabComponent`, `MaterialYesNoButtonsComponent` |
| Inputs | `MaterialInputComponent`, `MaterialMultilineInputComponent`, `MaterialCheckboxComponent`, `MaterialRadioComponent`, `MaterialToggleComponent`, `MaterialSliderComponent` |
| Selection | `MaterialSelectComponent`, `MaterialDropdownSelectComponent`, `MaterialChipsComponent`, `MaterialTreeComponent` |
| Dates | `MaterialDatepickerComponent`, `MaterialDateRangePickerComponent` |
| Popups | `MaterialPopupComponent`, `MaterialMenuComponent`, `MaterialDialogComponent`, `MaterialTooltipDirective` |
| Layout | App layout (drawers and header), `MaterialExpansionPanel`, `MaterialStepperComponent`, `MaterialTabPanelComponent`, `MaterialListComponent` |
| Display | `MaterialIconComponent`, `MaterialProgressComponent`, `MaterialSpinnerComponent`, `MaterialRippleComponent`, `ScorecardComponent`, `SimpleHtmlComponent` |

Each component lives in its own directory under [`components/lib/`](components/lib/), such as `material_button/` or `material_datepicker/`.

## Component gallery

The gallery shows a demo and the API docs of each component. To run it locally:

```bash
dart pub get
cd component_gallery/kelicap_components_example
dart run build_runner serve web
```

Then open <http://localhost:8080>. See [its README](component_gallery/kelicap_components_example/README.md) for release builds and known issues.

## Development

This repository is a Dart workspace. Run `dart pub get` at the root to resolve every package.

Before sending a change, run these checks in `components/`:

```bash
dart format --output=none --set-exit-if-changed .
dart analyze
dart run build_runner build
```

Some code works in a development build and fails in a release build, such as reading a member of a JavaScript object dynamically. After changing anything that touches the DOM, build the gallery with `--release` and check the component in a browser.

[AGENTS.md](AGENTS.md) describes the conventions, checks and build details in full.

## License

BSD 3-Clause. See [LICENSE](LICENSE). Maintainers are listed in [AUTHORS.md](AUTHORS.md).
