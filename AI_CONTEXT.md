# Kelicap Components AI Context

## Overview

Kelicap Components is a library of Material Design 2 web components for the [Kelicap](https://github.com/dukefirehawk/kelicap) framework. It is a derivative fork of AngularDart Components (`angular_components`), whose copyright headers it keeps, modernized for Dart 3.13 and `package:web`. The components are Kelicap `@Component`s and `@Directive`s, with templates in `.html` files and styles in `.scss` files.

## Project Structure

The repository is a Dart workspace (`workspace:` in the root `pubspec.yaml`), with Melos configured in `melos.yaml`:

- `components/` (`kelicap_components`): The published library. Each component or utility has its own directory under `lib/`, such as `material_button/`, `material_input/`, `material_datepicker/`, `app_layout/`, `focus/`, `utils/` and `mixins/`. `lib/kelicap_components.dart` exports the library. `lib/builder.dart` is the `scss_builder`, which compiles `.scss` to `.scss.css`.
- `component_gallery/`: The gallery app that shows the components, which is not published.
  - `gallery/` (`kelicap_gallery`): The builders that generate the gallery app (`index.html`, `main.dart`, `style.scss` under `web/`) and its syntax highlighting.
  - `gallery_section/`: The annotation and builder for the gallery section of each example.
  - `kelicap_components_example/`: The `build.yaml` that selects the examples for the gallery, from whose directory the gallery is built.
  - `examples/<component>_example/`: One package per component, such as `material_button_example`, with its demos under `lib/`.
  - `output/`: Not in the workspace.

## Tech Stack

- **Language**: Dart `>=3.13.0 <4.0.0`
- **Framework**: `kelicap`, `kelicap_forms` and `kelicap_observable` `^1.1.3`, from pub.dev, not from a local checkout of `kelicap`. 1.1.3 is the first `kelicap_compiler` that builds the gallery, and that warns about `$event` member reads.
- **DOM interop**: `package:web`.
- **Styles**: Sass, through the package's own `scss_builder`. `sass_builder`'s builder is disabled in `components/build.yaml`.
- **Other dependencies**: `intl` (messages), `protobuf` (the date model of `material_datepicker`), `quiver`, `built_collection`, `fixnum`.

## Key Principles & Conventions

1. **`package:web` only**: DOM access uses `package:web` types (`Element`, `HTMLInputElement`, `UIEvent` and the like), not `dart:html`.
2. **No dynamic access to DOM objects**: `$event` is `dynamic` in the generated code, and a release build (dart2js) cannot read members of a JavaScript object dynamically. Never read a member of `$event` in a template or a `@HostListener` argument, such as `(click)="$event.stopPropagation()"`. Pass `$event` to a method that takes a typed `Event`, and read it there. `BaseMaterialInput` (and so both material inputs), the temporary and stackable drawers, the date range editor and the yes/no buttons example have a `stopEventPropagation(Event)` method for this. A template can only call a method of its own component or one it inherits, so add the method where the component's class hierarchy will reach it. The `[stopPropagation]` directive (`lib/stop_propagation/`) stops `click`, and `keypress` of Enter or Space, only. `kelicap_compiler` 1.1.3 warns about these reads, including the event of an `@Output()` that is a `Stream` of a `package:web` type, such as `ButtonDirective.trigger` (`Stream<UIEvent>`).
3. **Typed callbacks**: Browser event and `requestAnimationFrame` callbacks are typed, not `dynamic`. A `requestAnimationFrame` callback takes the frame's timestamp, a `num`. Each `.toJS` makes a new JavaScript function, and `removeEventListener` removes a listener only when given the same function as `addEventListener`, so wrap a callback that is added and removed, or scheduled again each frame, once, in a field such as `late final JSFunction _onFocusCallback = _onFocus.toJS;`, and use that field each time.
4. **Imports**: Code in `components/lib` imports the package's own libraries as `package:kelicap_components/...`.
5. **Lints**: `package:lints/recommended.yaml`. `uri_has_not_been_generated` and `todo` are ignored, since templates are generated at build time.
6. **JS interop signatures**: An `external` member takes and returns JS or `package:web` types, or `void`, never `dynamic`: DDC rejects `dynamic` there, and so does dart2js (`External JS interop member contains invalid types`), as in `external void highlightBlock(Element block)` in the gallery.
7. **Generic components in templates**: A generic component used without `directiveTypes`, such as `MaterialTreeComponent`, is created with `dynamic` type arguments, so a callback bound to one of its inputs takes `dynamic` or `Object?`, not the item type: `String? itemRenderer(Object? item)`, not `String? itemRenderer(String item)`, which does not compile in the generated code.

## Development Workflow

- **Branches**: Work on a topic branch, such as `feature/<name>` (e.g. `feature/fix_bugs`), and merge it into `main`.
- **Setup**: Run `dart pub get` at the root, which resolves the whole workspace into the root `pubspec.lock`. The `pubspec_overrides.yaml` files in `component_gallery/kelicap_components_example` and `component_gallery/examples/app_layout_example` only hold commented-out git overrides of the `kelicap` packages. Their `path:` values (`compiler`, `ast`, ...) predate the `packages/kelicap_*` layout of the `kelicap` repository.
- **Code generation**: Templates compile to `*.template.dart`, and `.scss` to `.scss.css`, in `.dart_tool/build`, not in the source tree. Don't commit generated files.
- **Checks**: In `components/`:

  ```bash
  dart format --output=none --set-exit-if-changed .
  dart analyze
  dart run build_runner build
  ```

  The build generates every `.template.dart` and stylesheet, and shows the template compiler's errors and warnings, such as a binding to an unknown input. It takes about two minutes. (`build_runner` 2.16 ignores `--delete-conflicting-outputs`.) It does not compile the generated Dart, as `components` has no entrypoint, so it passes when a template calls a method that the component does not have, such as `(focus)="stopEventPropagation($event)"` on a component that does not inherit it: `dart analyze` does not see the generated code either. To catch those, build into a directory outside the repository, give it a package config, and analyze it, generated code included:

  ```bash
  out=/tmp/components_out
  rm -rf $out && dart run build_runner build -o $out
  mkdir -p $out/.dart_tool && (cd $out/packages && ls | grep -v '^\$' |
    sed 's|.*|{"name":"&","rootUri":"../packages/&","packageUri":"."}|' |
    paste -sd, | sed 's|.*|{"configVersion":2,"packages":[&]}|') \
    > $out/.dart_tool/package_config.json
  cd $out/packages/kelicap_components && dart analyze . | grep 'error -'
  ```

  `packages/<name>` in the output holds each package's `lib`, generated files beside their sources. An error in a `.template.dart`, such as `The getter 'stopEventPropagation' isn't defined for the type 'MaterialMultilineInputComponent'`, is a template that calls a member its component does not have.

  Tests of code that imports no generated `.template.dart`, such as `test/focus_indicator_controller_test.dart`, run in Chrome with `dart test -p chrome test/<name>_test.dart`, which compiles them with dart2js, so they check a release build as well. `test/ensure_proto_build_test.dart` checks that the proto classes are up to date, is tagged `presubmit-only`, and is skipped by default. As it imports `dart:io`, the build warns that it skips compiling it with DDC, which is expected.
- **Against a local Kelicap**: The build uses the `kelicap` packages from pub.dev. To build against a local checkout of `kelicap` next to this repository, such as for a compiler change that is not released yet, override all seven of its packages, as overriding only `kelicap_compiler` fails to resolve (it needs the unreleased `kelicap_common` of the same version), and a newer compiler can generate code that needs the runtime of the same version. Back up `pubspec.lock` first, since the override rewrites it:

  ```bash
  cp pubspec.lock /tmp/pubspec.lock.bak
  { echo 'dependency_overrides:'
    for p in kelicap kelicap_ast kelicap_common kelicap_compiler kelicap_forms kelicap_observable kelicap_router; do
      printf '  %s:\n    path: ../kelicap/packages/%s\n' $p $p
    done; } > pubspec_overrides.yaml
  dart pub get
  ```

  Afterwards, delete the root `pubspec_overrides.yaml`, restore `pubspec.lock`, and run `dart pub get`. Don't commit the override.
- **`build_runner`**: `components` needs `build_runner` ^2.16.2. 2.16.0 does not compile against analyzer 14.7 (`The setter 'contextFeatures' isn't defined for the type 'AnalysisOptionsImpl'`).
- **Gallery**: Build or serve the gallery from `component_gallery/kelicap_components_example`, as its `README.md` describes. A build compiles the generated templates of every component and example it uses, so it is the end-to-end check for template errors, alongside the analysis above. A plain build or `serve` compiles with DDC; `--release` compiles with dart2js (`-O4 --minify --dump-info`, set under `release_options` of `build_web_compilers|entrypoint` in its `build.yaml`). Each takes one and a half to three minutes.

  It needs `kelicap_compiler` 1.1.3 or later: 1.1.2 does not find an unnamed constructor declared after another one, such as the `factory` of `MaterialMenuDemoComponent` after `MaterialMenuDemoComponent._`, as analyzer 14 names it `new`, and fails with `No constructors found`. If the build fails that way, run `dart pub upgrade` at the root. The Sass deprecation warnings (`W kelicap_components:scss_builder`) of the build are expected.

  ```bash
  dart run build_runner serve web            # development (DDC)
  dart run build_runner build -o <dir>       # add --release for dart2js
  ```

- **Release builds (dart2js)**: DDC tolerates dynamic access to JavaScript objects, and dart2js does not, so a component can work in the gallery under `serve` and fail in a release build. After changing anything that touches the DOM, build the gallery with `--release` and check the component in a browser.
- **Datepicker proto**: The date classes in `lib/material_datepicker/proto` are generated with `protoc`, by `components/tool/protoc.sh`. `components/tool/travis/install_protoc.sh` installs `protoc`.
- **CI**: None in the repository. Run the checks locally.
- **Versions**: `kelicap_components` is `1.1.2`. Bump `version` in `components/pubspec.yaml`, and add a `CHANGELOG.md` entry, for each release.
- **Changelog**: Every user-facing change gets an entry in the affected package's `CHANGELOG.md`, written as plain-English statements about the package (not commit messages). Group a release's entries under `### Breaking changes in X.Y.Z` (each entry prefixed `**Breaking:**`), `### New in X.Y.Z` and `### Fixes in X.Y.Z`, in that order, omitting empty sections.

## Current Focus

Recent work fixes JavaScript interop errors and removes dynamic access to DOM objects, so that the components work in release builds: typing browser event callbacks, and replacing `$event` member reads in templates with typed methods. The gallery's builders (`gallery_section`) were ported to the analyzer 14 element model, where a library's names are looked up in `firstFragment.scope` and a class's members are in `body.members`, so that the gallery builds again.
