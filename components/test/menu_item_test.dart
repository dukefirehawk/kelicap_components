import 'package:kelicap_components/model/menu/menu.dart';
import 'package:kelicap_components/model/menu/selectable_menu.dart';
import 'package:kelicap_observable/kelicap_observable.dart';
import 'package:test/test.dart';

void main() {
  group('MenuItem', () {
    test('has no suffixes without an itemSuffix', () {
      expect(MenuItem<Object>('label').itemSuffixes, isEmpty);
    });

    test('has the given itemSuffix as its only suffix', () {
      final suffix = _Suffix();
      expect(MenuItem<Object>('label', itemSuffix: suffix).itemSuffixes, [
        suffix,
      ]);
    });

    test('uses the given itemSuffixes', () {
      final suffixes = ObservableList<MenuItemAffix>.from([_Suffix()]);
      expect(
        MenuItem<Object>('label', itemSuffixes: suffixes).itemSuffixes,
        same(suffixes),
      );
    });
  });

  group('SelectableMenuItem', () {
    test('has no suffixes without an itemSuffix', () {
      expect(SelectableMenuItem<String>(value: 'a').itemSuffixes, isEmpty);
    });

    test('has the given itemSuffix as its only suffix', () {
      final suffix = _Suffix();
      expect(
        SelectableMenuItem<String>(value: 'a', itemSuffix: suffix).itemSuffixes,
        [suffix],
      );
    });
  });
}

class _Suffix extends MenuItemAffix<Object?> {
  @override
  IconVisibility get visibility => IconVisibility.visible;

  @override
  Object? get componentFactory => null;

  @override
  bool get shouldCloseMenuOnTrigger => false;

  @override
  bool hasShortcutKeyCode(int keyCode) => false;

  @override
  void triggerShortcutAction() {}

  @override
  String? get cssClass => null;
}
