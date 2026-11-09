// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:build/build.dart';
import 'package:kelicap_gallery/builder/gallery_app_builder.dart';
import 'package:kelicap_gallery/builder/gallery_lib_builder.dart';
import 'package:kelicap_gallery/builder/syntax_highlight_builder.dart';

/// Builders used to generate files in the gallery app target.
Builder galleryAppBuilder(BuilderOptions options) => MergedBuilder([
  GalleryWebBuilder(
    options.config['direction'] ?? 'ltr',
    options.config['galleryTitle'] ?? 'Example Gallery',
    options.config['galleryBindingName'],
    options.config['galleryBindingImport'],
    options.config['bugUrl'] ?? '',
    options.config['sourcecodeUrl'] ?? '',
  ),
  HomeDartBuilder(),
]);

/// Builder used to generate files in the gallery library target.
Builder galleryLibBuilder(BuilderOptions options) => GalleryLibBuilder(
  options.config['galleryTitle'] ?? 'Example Gallery',
  (options.config['styleUrls'] as List?)?.cast<String>() ?? [],
  [
    for (final example
        in (options.config['examples'] as String?)?.split(',') ?? <String>[])
      if (example.trim().isNotEmpty) example.trim(),
  ],
);

/// Builder to generate the Sass styles for syntax highlighting with
/// highlight.js.
Builder syntaxHighlightBuilder(BuilderOptions _) => SyntaxHighlightBuilder();

class MergedBuilder implements Builder {
  final List<Builder> builders;

  MergedBuilder(this.builders);

  @override
  Future<void> build(BuildStep buildStep) async {
    for (var builder in builders) {
      // Only run a builder on the inputs that its extensions match.
      if (builder.buildExtensions.keys.any(
        (input) => _matches(input, buildStep.inputId.path),
      )) {
        await builder.build(buildStep);
      }
    }
  }

  /// Whether an input [path] matches [input], a key of `buildExtensions`.
  ///
  /// A key that starts with `^` is a path from the package root. Any other
  /// key, such as `.html` or the synthetic `$web$`, is an ending of the path.
  static bool _matches(String input, String path) =>
      input.startsWith('^') ? path == input.substring(1) : path.endsWith(input);

  @override
  Map<String, List<String>> get buildExtensions {
    final extensions = <String, List<String>>{};
    for (var builder in builders) {
      builder.buildExtensions.forEach((input, outputs) {
        extensions.putIfAbsent(input, () => []).addAll(outputs);
      });
    }
    return extensions;
  }
}
