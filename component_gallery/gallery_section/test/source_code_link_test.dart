import 'package:kelicap_gallery_section/components/gallery_component/source_code_link.dart';
import 'package:test/test.dart';

const repository =
    'https://github.com/dukefirehawk/kelicap_components/blob/main';

void main() {
  test('links a file of kelicap_components to components', () {
    expect(
      sourceCodeLink(
        repository,
        'kelicap_components/lib/material_button/material_button.dart',
      ),
      '$repository/components/lib/material_button/material_button.dart',
    );
  });

  test('links a file of an example to component_gallery/examples', () {
    expect(
      sourceCodeLink(repository, 'material_tree_example/lib/src/demo.dart'),
      '$repository/component_gallery/examples/material_tree_example/lib/src/demo.dart',
    );
  });

  test('links a file of the gallery packages to component_gallery', () {
    expect(
      sourceCodeLink(repository, 'kelicap_gallery/lib/builder.dart'),
      '$repository/component_gallery/gallery/lib/builder.dart',
    );
    expect(
      sourceCodeLink(repository, 'kelicap_gallery_section/lib/builder.dart'),
      '$repository/component_gallery/gallery_section/lib/builder.dart',
    );
    expect(
      sourceCodeLink(repository, 'kelicap_components_example/build.yaml'),
      '$repository/component_gallery/kelicap_components_example/build.yaml',
    );
  });

  test('links a file of another package to a directory of its name', () {
    expect(
      sourceCodeLink(repository, 'other/lib/other.dart'),
      '$repository/other/lib/other.dart',
    );
  });

  test('accepts a repository URL with a trailing slash', () {
    expect(
      sourceCodeLink('$repository/', 'other/lib/other.dart'),
      '$repository/other/lib/other.dart',
    );
  });

  test('links the repository for a path without a package', () {
    expect(sourceCodeLink(repository, ''), repository);
    expect(sourceCodeLink(repository, 'README'), repository);
  });
}
