# Kelicap Components

[![Kelicap Web Components](https://raw.githubusercontent.com/dukefirehawk/kelicap_components/main/assets/branding/kelicap_1_banner.jpeg)](https://github.com/dukefirehawk/kelicap_components)

[![Pub Version](https://img.shields.io/pub/v/kelicap_components)](https://pub.dev/packages/kelicap_components)
[![License](https://img.shields.io/github/license/dukefirehawk/kelicap_components)](https://github.com/dukefirehawk/kelicap_components/blob/main/LICENSE)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

Material Design 2 web components for the [Kelicap](https://pub.dev/packages/kelicap) web framework: buttons, inputs, selects, menus, dialogs, date pickers, tabs, trees and more.

This package is a fork of AngularDart Components (`angular_components`), updated for Dart 3.13 and [`package:web`](https://pub.dev/packages/web). It works in both development (DDC) and release (dart2js) builds.

## Getting started

### Requirements

- Dart SDK 3.13 or later
- [`kelicap`](https://pub.dev/packages/kelicap) 1.1.3 or later

### Installation

```yaml
dependencies:
  kelicap: ^1.1.3
  kelicap_components: ^1.1.2
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

## Available components

| Area | Components |
| --- | --- |
| Buttons | `MaterialButtonComponent`, `MaterialFabComponent`, `MaterialFabMenuComponent`, `MaterialYesNoButtonsComponent` |
| Inputs | `MaterialInputComponent`, `MaterialMultilineInputComponent`, `MaterialCheckboxComponent`, `MaterialRadioComponent`, `MaterialRadioGroupComponent`, `MaterialToggleComponent`, `MaterialSliderComponent` |
| Selection | `MaterialSelectComponent`, `MaterialDropdownSelectComponent`, `MaterialChipComponent`, `MaterialChipsComponent`, `MaterialTreeComponent`, `MaterialTreeDropdownComponent` |
| Dates | `MaterialDatepickerComponent`, `MaterialDateRangePickerComponent` |
| Popups | `MaterialPopupComponent`, `MaterialMenuComponent`, `MaterialDialogComponent`, `MaterialTooltipDirective`, `MaterialIconTooltipComponent`, `MaterialPaperTooltipComponent` |
| Layout | App layout (drawers and header), `MaterialExpansionPanel`, `MaterialExpansionPanelSet`, `MaterialStepperComponent`, `MaterialTabPanelComponent`, `MaterialTabComponent`, `MaterialListComponent`, `MaterialListItemComponent` |
| Display | `MaterialIconComponent`, `MaterialProgressComponent`, `MaterialSpinnerComponent`, `MaterialRippleComponent`, `ScorecardComponent`, `SimpleHtmlComponent` |

Each component's library is under `package:kelicap_components/<component>/`, such as `material_button/material_button.dart` or `material_datepicker/material_datepicker.dart`.

## More information

- [Component gallery source](https://github.com/dukefirehawk/kelicap_components/tree/main/component_gallery): a demo of every component, which you can run locally
- [Changelog](https://pub.dev/packages/kelicap_components/changelog)
- [Issue tracker](https://github.com/dukefirehawk/kelicap_components/issues)
