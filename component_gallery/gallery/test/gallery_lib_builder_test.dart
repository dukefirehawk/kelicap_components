import 'package:kelicap_gallery/builder/gallery_lib_builder.dart';
import 'package:test/test.dart';

List<String> namesOf(List<String> displayNames) {
  final examples = [
    for (final displayName in displayNames)
      Example(displayName, '', 'package:a/a.dart', 'A', []),
  ];
  assignExampleNames(examples);
  return [for (final example in examples) example.name];
}

void main() {
  group('assignExampleNames', () {
    test('uses the snake case of the display name', () {
      expect(namesOf(['Material Button', 'materialTree']), [
        'material_button',
        'material_tree',
      ]);
    });

    test('drops characters that cannot be in an identifier', () {
      expect(namesOf(["Chip's Demo", 'Buttons & Icons']), [
        'chips_demo',
        'buttons_icons',
      ]);
    });

    test('names an example with no usable characters', () {
      expect(namesOf(['', '日本語', '🎉']), ['example', 'example_2', 'example_3']);
    });

    test('names an example that would start with a digit', () {
      expect(namesOf(['3D Card']), ['example_3d_card']);
    });

    test('names an example that would be a reserved word', () {
      expect(namesOf(['Switch', 'Home', 'Await']), [
        'switch_example',
        'home_example',
        'await_example',
      ]);
    });

    test('gives each example a different name', () {
      expect(namesOf(['Foo Bar', 'Foo-Bar', 'foo_bar']), [
        'foo_bar',
        'foo_bar_2',
        'foo_bar_3',
      ]);
    });

    test('gives an example a capitalized link name', () {
      final example = Example('Material Button', '', '', 'A', []);
      assignExampleNames([example]);
      expect(example.linkName, 'Material_button');
    });
  });

  group('dartStringContent', () {
    test('escapes what would end or interpolate a string', () {
      expect(dartStringContent("Chip's \$price \\ a"), r"Chip\'s \$price \\ a");
      expect(dartStringContent('a\nb'), r'a\nb');
    });

    test('keeps other text as it is', () {
      expect(dartStringContent('Buttons & Icons'), 'Buttons & Icons');
    });
  });

  group('Example.toJson', () {
    test('escapes the values put in Dart strings', () {
      final example = Example("Chip's", "Group's", 'package:a/a.dart', 'A', [
        "B's",
      ]);
      assignExampleNames([example]);
      final json = example.toJson();
      expect(json['displayName'], r"Chip\'s");
      expect(json['group'], r"Group\'s");
      expect(json['relatedComponents'], [r"B\'s"]);
      expect(json['name'], 'chips');
    });
  });
}
