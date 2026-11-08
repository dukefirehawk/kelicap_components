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
- **Framework**: `kelicap`, `kelicap_forms` and `kelicap_observable` `^1.0.0`, from pub.dev, not from a local checkout of `kelicap`.
- **DOM interop**: `package:web`.
- **Styles**: Sass, through the package's own `scss_builder`. `sass_builder`'s builder is disabled in `components/build.yaml`.
- **Other dependencies**: `intl` (messages), `protobuf` (the date model of `material_datepicker`), `quiver`, `built_collection`, `fixnum`.

## Key Principles & Conventions

1. **`package:web` only**: DOM access uses `package:web` types (`Element`, `HTMLInputElement`, `UIEvent` and the like), not `dart:html`.
2. **No dynamic access to DOM objects**: `$event` is `dynamic` in the generated code, and a release build (dart2js) cannot read members of a JavaScript object dynamically. Never read a member of `$event` in a template or a `@HostListener` argument, such as `(click)="$event.stopPropagation()"`. Pass `$event` to a method that takes a typed `Event`, and read it there. The material input, drawer, date range editor and yes/no buttons example have a `stopEventPropagation(Event)` method for this. The `[stopPropagation]` directive (`lib/stop_propagation/`) stops `click`, and `keypress` of Enter or Space, only. `kelicap_compiler` 1.1.3 warns about these reads, including the event of an `@Output()` that is a `Stream` of a `package:web` type, such as `ButtonDirective.trigger` (`Stream<UIEvent>`).
3. **Typed callbacks**: Browser event and `requestAnimationFrame` callbacks are typed, not `dynamic`.
4. **Imports**: Code in `components/lib` imports the package's own libraries as `package:kelicap_components/...`.
5. **Lints**: `package:lints/recommended.yaml`. `uri_has_not_been_generated` and `todo` are ignored, since templates are generated at build time.

## Development Workflow

- **Branches**: Work on a topic branch, such as `feature/<name>` (e.g. `feature/fix_bugs`), and merge it into `main`.
- **Setup**: Run `dart pub get` at the root, which resolves the whole workspace into the root `pubspec.lock`. The `pubspec_overrides.yaml` files in `component_gallery/kelicap_components_example` and `component_gallery/examples/app_layout_example` only hold commented-out git overrides of the `kelicap` packages. Their `path:` values (`compiler`, `ast`, ...) predate the `packages/kelicap_*` layout of the `kelicap` repository.
- **Code generation**: Templates compile to `*.template.dart`, and `.scss` to `.scss.css`, in `.dart_tool/build`, not in the source tree. Don't commit generated files.
- **Checks**: In `components/`:

  ```bash
  dart format --output=none --set-exit-if-changed .
  dart analyze
  dart run build_runner build --delete-conflicting-outputs
  ```

  The build compiles every template and stylesheet, so it catches template errors that `dart analyze` does not, and shows the compiler's warnings. It takes about two minutes. There are no unit tests: `test/ensure_proto_build_test.dart` checks that the proto classes are up to date, is tagged `presubmit-only`, and is skipped by default.
- **Against a local Kelicap**: The build uses the `kelicap_compiler` from pub.dev. To check a change in a local checkout of `kelicap`, such as a new compiler warning, the workspace needs a `dependency_overrides` with `path:` to its packages, which changes `pubspec.lock`. Don't commit the override.
- **Gallery**: Build or serve the gallery from `component_gallery/kelicap_components_example`, as its `README.md` describes:

  ```bash
  dart run build_runner serve web            # development (DDC)
  dart run build_runner build -o <dir>       # add --release for dart2js
  ```

- **Release builds (dart2js)**: DDC tolerates dynamic access to JavaScript objects, and dart2js does not, so a component can work in the gallery under `serve` and fail in a release build. After changing anything that touches the DOM, build the gallery with `--release` and check the component in a browser.
- **Datepicker proto**: The date classes in `lib/material_datepicker/proto` are generated with `protoc`, by `components/tool/protoc.sh`. `components/tool/travis/install_protoc.sh` installs `protoc`.
- **CI**: None in the repository. Run the checks locally.
- **Versions**: `kelicap_components` is `1.1.1`. Bump `version` in `components/pubspec.yaml`, and add a `CHANGELOG.md` entry, for each release.
- **Changelog**: `components/CHANGELOG.md` lists each release's changes as Conventional Commit-style bullets (`- fix: ...`, `- chore: ...`). Commit messages use [Conventional Commits](https://www.conventionalcommits.org/) (`type(scope): description`).

## Current Focus

Recent work fixes JavaScript interop errors and removes dynamic access to DOM objects, so that the components work in release builds: typing browser event callbacks, and replacing `$event` member reads in templates with typed methods.
