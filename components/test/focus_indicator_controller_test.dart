@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:kelicap_components/model/a11y/focus_indicator_controller.dart';
import 'package:test/test.dart';

/// Wraps `window.addEventListener` and `removeEventListener` to count the
/// listeners that `window` has for each event type.
void _trackWindowListeners() {
  globalContext.callMethod(
    'eval'.toJS,
    '''
    if (!window.__listenerCount) {
      const listeners = new Map();
      const add = window.addEventListener.bind(window);
      const remove = window.removeEventListener.bind(window);
      window.addEventListener = (type, fn, options) => {
        if (!listeners.has(type)) listeners.set(type, new Set());
        listeners.get(type).add(fn);
        return add(type, fn, options);
      };
      window.removeEventListener = (type, fn, options) => {
        listeners.get(type)?.delete(fn);
        return remove(type, fn, options);
      };
      window.__listenerCount = (type) => listeners.get(type)?.size ?? 0;
    }
    '''
        .toJS,
  );
}

int _listenerCount(String type) => (globalContext.callMethod(
  '__listenerCount'.toJS,
  type.toJS,
) as JSNumber).toDartInt;

void main() {
  setUpAll(_trackWindowListeners);

  test('removes its window listeners when disabled', () {
    final focus = _listenerCount('focus');
    final blur = _listenerCount('blur');
    final controller = FocusIndicatorController()..enabled = true;
    expect(_listenerCount('focus'), focus + 1);
    expect(_listenerCount('blur'), blur + 1);

    controller.enabled = false;
    expect(_listenerCount('focus'), focus);
    expect(_listenerCount('blur'), blur);
  });

  test('has one pair of window listeners when enabled again', () {
    final focus = _listenerCount('focus');
    final controller = FocusIndicatorController()
      ..enabled = true
      ..enabled = false
      ..enabled = true;
    expect(_listenerCount('focus'), focus + 1);
    controller.enabled = false;
    expect(_listenerCount('focus'), focus);
  });
}
