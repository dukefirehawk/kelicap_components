// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:web/web.dart';

import 'dart:js_interop';

import 'package:kelicap/di.dart';

const focusIndicatorProviders = [
  FactoryProvider(
    FocusIndicatorController,
    createFocusIndicatorControllerIfNotAvailable,
  ),
];

@Injectable()
FocusIndicatorController createFocusIndicatorControllerIfNotAvailable(
  @Optional() @SkipSelf() FocusIndicatorController? controller,
) => controller ?? FocusIndicatorController();

/// Utility that attaches an a focus indicator to the page when enabled.
///
/// Only used to improve a11y debugging experience. DO NOT USE IN PRODUCTION!
class FocusIndicatorController {
  Element? _focusIndicator;
  int? _repositionLoopId;

  Element? _activeElement;
  Element? get activeElement => _activeElement;

  bool _enabled = false;
  bool get enabled => _enabled;

  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (_enabled) {
      _turnOnKeyNavMode();
    } else {
      _turnOffKeyNavMode();
    }
  }

  void _turnOnKeyNavMode() {
    window.addEventListener('focus', _onFocus.toJS, true.toJS);
    window.addEventListener('blur', _onBlur.toJS, true.toJS);

    _activeElement = document.activeElement;

    _focusIndicator = document.createElement('div');

    final div = _focusIndicator! as HTMLElement;
    div.id = 'acx-focus-indicator';
    div.style.position = 'fixed';
    div.style.zIndex = '9999';
    div.style.outline = '2px solid #ff9800';
    div.style.pointerEvents = 'none';
    document.body!.append(div);

    _startRepositionLoop();
  }

  void _turnOffKeyNavMode() {
    window.removeEventListener('focus', _onFocus.toJS, true.toJS);
    window.removeEventListener('blur', _onBlur.toJS, true.toJS);

    _activeElement = null;

    if (_focusIndicator != null) {
      _focusIndicator!.remove();
      _focusIndicator = null;
    }

    _cancelRepositionLoop();
  }

  void _onFocus(Event event) {
    _updateActiveElement(event);
  }

  void _onBlur(Event event) {
    Timer.run(() {
      _updateActiveElement(event);
    });
  }

  void _updateActiveElement(Event event) {
    if (!_enabled || _activeElement == document.activeElement) return;

    if (_activeElement != null) {
      var elm = _activeElement as HTMLElement;
      elm.style.outline = '';
      if (elm.getAttribute('style')?.isEmpty == true) {
        elm.removeAttribute('style');
      }
    }

    _activeElement = document.activeElement;

    console.groupCollapsed(
      'Active element [${_activeElement!.tagName.toLowerCase()}] after "${event.type}"'
          .toJS,
    );
    console.log(_activeElement);
    console.log(event);
    console.groupEnd();

    (_activeElement as HTMLElement).style.outline = 'none';
  }

  void _startRepositionLoop() {
    _repositionLoopId = window.requestAnimationFrame(_reposition.toJS);
  }

  void _cancelRepositionLoop() {
    if (_repositionLoopId != null) {
      window.cancelAnimationFrame(_repositionLoopId!);
      _repositionLoopId = null;
    }
  }

  void _reposition(num _) {
    var rect = _activeElement!.getBoundingClientRect();
    var elm = _focusIndicator as HTMLElement;
    elm.style.top = '${rect.top}px';
    elm.style.left = '${rect.left}px';
    elm.style.width = '${rect.width}px';
    elm.style.height = '${rect.height}px';

    _startRepositionLoop();
  }
}
