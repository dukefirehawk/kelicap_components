@TestOn('browser')
library;

import 'package:kelicap_components/laminate/ruler/dom_ruler.dart';
import 'package:kelicap_components/utils/browser/dom_service/dom_service.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

/// The ruler's class methods don't use its `DomService`.
class _NoDomService implements DomService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late DomRulerImpl ruler;
  late HTMLElement element;

  setUp(() {
    ruler = DomRulerImpl(document, _NoDomService());
    element = document.createElement('div') as HTMLElement;
  });

  group('addCssClassesSync', () {
    test('adds each class', () {
      ruler.addCssClassesSync(element, ['a', 'b']);
      expect(element.className, 'a b');
    });

    test('ignores empty classes', () {
      ruler.addCssClassesSync(element, ['', 'a', '  ']);
      expect(element.className, 'a');
    });

    test('splits classes on whitespace', () {
      ruler.addCssClassesSync(element, ['a b', ' c\td ']);
      expect(element.className, 'a b c d');
    });
  });

  group('removeCssClassesSync', () {
    setUp(() => element.className = 'a b c d');

    test('removes each class', () {
      ruler.removeCssClassesSync(element, ['a', 'c']);
      expect(element.className, 'b d');
    });

    test('ignores empty classes, and splits them on whitespace', () {
      ruler.removeCssClassesSync(element, ['', 'a b', ' c ']);
      expect(element.className, 'd');
    });
  });
}
