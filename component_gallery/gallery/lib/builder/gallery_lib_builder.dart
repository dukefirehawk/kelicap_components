// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:kelicap_components/utils/strings/string_utils.dart' as strings;

import '../src/template_util.dart';

/// Generates lib/gallery/gallery.dart, lib/gallery/gallery.html,
/// lib/gallery/gallery.scss, and lib/gallery/gallery_route_library.dart for the
/// ACX component gallery.
class GalleryLibBuilder extends Builder {
  final String _galleryTitle;
  final List<String> _styleUrls;
  final List<String> _examplePackages;

  GalleryLibBuilder(this._galleryTitle, this._styleUrls, this._examplePackages);

  @override
  Future<void> build(BuildStep buildStep) async {
    final examples = await loadSummaries(buildStep);
    await _generateGalleryDart(buildStep, examples);
    await _generateGalleryHtml(buildStep);
    await _generateGalleryScss(buildStep);
    await _generateGalleryRouteLibraryDart(buildStep, examples);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': [
      'gallery/gallery.dart',
      'gallery/gallery.html',
      'gallery/gallery.scss',
      'gallery/gallery_route_library.dart',
    ],
  };

  Future<void> _generateGalleryHtml(BuildStep buildStep) async {
    final mustacheContext = {'galleryTitle': _galleryTitle};
    final newAssetId = AssetId(
      buildStep.inputId.package,
      'lib/gallery/gallery.html',
    );
    await writeAsset(
      buildStep,
      'lib/builder/template/gallery.html.mustache',
      mustacheContext,
      newAssetId,
    );
  }

  Future<void> _generateGalleryDart(
    BuildStep buildStep,
    List<Example> examples,
  ) async {
    final Map<String, List<Object>> mustacheContext = {
      'styleUrls': _styleUrls.map(dartStringContent).toList(),
      'examples': examples.map((e) => e.toJson()).toList(),
    };

    final newAssetId = AssetId(
      buildStep.inputId.package,
      'lib/gallery/gallery.dart',
    );
    await writeAsset(
      buildStep,
      'lib/builder/template/gallery.dart.mustache',
      mustacheContext,
      newAssetId,
    );
  }

  Future<void> _generateGalleryScss(BuildStep buildStep) async {
    final newAssetId = AssetId(
      buildStep.inputId.package,
      'lib/gallery/gallery.scss',
    );
    await writeAsset(
      buildStep,
      'lib/builder/template/gallery.scss.mustache',
      {},
      newAssetId,
    );
  }

  Future<void> _generateGalleryRouteLibraryDart(
    BuildStep buildStep,
    List<Example> examples,
  ) async {
    final Map<String, List<Map<String, Object>>> mustacheContext = {
      'examples': examples.map((e) => e.toJson()).toList(),
    };

    //examples.forEach((element) {
    //  print('Example: name=${element.name} group=${element.group}');
    //});

    final newAssetId = AssetId(
      buildStep.inputId.package,
      'lib/gallery/gallery_route_library.dart',
    );
    await writeAsset(
      buildStep,
      'lib/builder/template/gallery_route_library.dart.mustache',
      mustacheContext,
      newAssetId,
    );
  }

  /// Reads gallery_section_summary.json files from all `_examplePackages`.
  Future<List<Example>> loadSummaries(BuildStep buildStep) async {
    final examples = <Example>[];

    for (var package in _examplePackages) {
      final gallerySectionSummaryId = AssetId(
        package,
        'lib/gallery_section_summary.json',
      );
      if (!await buildStep.canRead(gallerySectionSummaryId)) {
        log.warning(
          'Skipping the example package "$package": it has no '
          'lib/gallery_section_summary.json. Check its name in the "examples" '
          'option, and that it is a dependency with a @GallerySectionConfig.',
        );
        continue;
      }

      final summaryContents = await buildStep.readAsString(
        gallerySectionSummaryId,
      );
      final summaries = (jsonDecode(summaryContents) as Iterable).map(
        (m) => (m as Map).cast<String, dynamic>(),
      );
      examples.addAll(
        summaries.map(
          (summary) => Example(
            summary['displayName'] ?? '',
            summary['group'] ?? '',
            summary['dartImport'] ?? '',
            summary['componentClass'] ?? '',
            List<String>.from(summary['docs'] ?? const []),
          ),
        ),
      );
    }

    examples.sort(
      (Example a, Example b) => a.displayName.compareTo(b.displayName),
    );
    assignExampleNames(examples);
    return examples;
  }
}

/// Words that cannot be the name of an example, which is a deferred import
/// prefix and is used in an `async` function in gallery_route_library.dart.
///
/// The reserved words and built-in identifiers of Dart, `await` and `yield`,
/// and `home`, the prefix of the import of the home page.
const _unusableNames = {
  // Reserved words.
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
  'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
  'in', 'is', 'new', 'null', 'rethrow', 'return', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'var', 'void', 'while', 'with',
  // Built-in identifiers, which cannot be an import prefix.
  'abstract', 'as', 'covariant', 'deferred', 'dynamic', 'export', 'extension',
  'external', 'factory', 'function', 'get', 'implements', 'import',
  'interface', 'late', 'library', 'mixin', 'operator', 'part', 'required',
  'set', 'static', 'typedef',
  // Not allowed as an identifier in an `async` function.
  'await', 'yield',
  // Used by the generated libraries.
  'home',
};

/// Gives each of [examples] a [Example.name] that is a valid Dart identifier,
/// and different from the others.
///
/// The name is the snake case of the display name, without the characters
/// that cannot be in an identifier. It is `example` if nothing is left, starts
/// with `example_` if it would start with a digit, and ends with `_example` if
/// it would be a word that cannot be a name. A name already taken gets `_2`,
/// `_3`, and so on.
void assignExampleNames(Iterable<Example> examples) {
  final taken = <String>{};
  for (final example in examples) {
    var base = strings.underscore(
      example.displayName.replaceAll(RegExp(r'[^a-zA-Z0-9 _-]'), ''),
    );
    // `underscore` can leave `_` at either end, and more than one in a row.
    base = base.replaceAll(RegExp('_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    if (base.isEmpty) {
      base = 'example';
    } else if (base.startsWith(RegExp('[0-9]'))) {
      base = 'example_$base';
    } else if (_unusableNames.contains(base)) {
      base = '${base}_example';
    }
    var name = base;
    for (var i = 2; !taken.add(name); i++) {
      name = '${base}_$i';
    }
    example.name = name;
  }
}

/// Returns [value] escaped to be put between the single quotes of a Dart
/// string literal.
String dartStringContent(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$')
    .replaceAll('\n', r'\n')
    .replaceAll('\r', r'\r');

class Example {
  String displayName;
  String group;
  String dartImport;
  String component;
  List<String> relatedComponents = [];

  Example(
    this.displayName,
    this.group,
    this.dartImport,
    this.component,
    this.relatedComponents,
  );

  /// The identifier of the example, a deferred import prefix and the path of
  /// its route, set by [assignExampleNames].
  late String name;

  String get linkName => strings.capitalizeFirstLetter(name) ?? '';

  String get loader => 'load${name}Example';

  /// The context of the example in the mustache templates.
  ///
  /// [relatedComponents] stays a list, which the templates loop over. The
  /// values that the templates put in Dart string literals are escaped for
  /// them, so the templates insert them as they are, with `{{{ }}}`.
  Map<String, Object> toJson() {
    Map<String, Object> map = {};
    map["name"] = name;
    map["displayName"] = dartStringContent(displayName);
    map["group"] = dartStringContent(group);
    map["dartImport"] = dartStringContent(dartImport);
    map["component"] = component;
    map["linkName"] = linkName;
    map["loader"] = loader;
    map["relatedComponents"] = relatedComponents
        .map(dartStringContent)
        .toList();

    return map;
  }
}
