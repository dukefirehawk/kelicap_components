// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:build/build.dart';
import 'package:angular_gallery/builder/gallery_app_builder.dart';
import 'package:angular_gallery/builder/gallery_lib_builder.dart';
import 'package:angular_gallery/builder/syntax_highlight_builder.dart';

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
  (options.config['examples'] as String?)?.split(',') ?? [],
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
      // Replicate the multiplex logic: only run if the input matches the builder's extensions
      if (builder.buildExtensions.keys.any(
        (ext) => buildStep.inputId.path.endsWith(ext),
      )) {
        await builder.build(buildStep);
      }
    }
  }

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
