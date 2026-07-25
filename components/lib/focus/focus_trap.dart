// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:web/web.dart';

import 'package:kelicap/kelicap.dart';
import 'package:kelicap_components/focus/focus.dart';
import 'package:kelicap_components/utils/browser/dom_iterator/dom_iterator.dart';
import 'package:kelicap_components/utils/disposer/disposer.dart';

/// Focus trap designed for usage in popups and modals.
///
/// After focus enters components it ensures that focus will not leave it.
@Component(
  selector: 'focus-trap',
  templateUrl: 'focus_trap.html',
  styleUrls: ['focus_trap.scss.css'],
  directives: [FocusContentWrapper, AutoFocusDirective],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class FocusTrapComponent implements OnDestroy {
  final _disposer = Disposer.oneShot();

  AutoFocusDirective? _autoFocusDirective;
  @ContentChild(AutoFocusDirective)
  set autoFocus(AutoFocusDirective? value) {
    _autoFocusDirective = value;
  }

  FocusContentWrapper? _content;
  @ViewChild(FocusContentWrapper)
  set content(FocusContentWrapper? value) {
    _content = value;
    if (_content != null && _autoFocusDirective == null) {
      final element = _content!.element as HTMLElement;
      element.focus();
    }
  }

  @override
  void ngOnDestroy() {
    _disposer.dispose();
  }

  void focusFirst() {
    if (_content != null) {
      _focusFirstInOrder(
        DomTreeIterator(_content!.element, scope: _content!.element),
      );
    }
  }

  void focusLast() {
    _focusFirstInOrder(
      DomTreeIterator(
        _content!.element,
        scope: _content!.element,
        reverse: true,
        wraps: true,
      ),
    );
  }

  void _focusFirstInOrder(Iterator<Element> iterator) {
    while (iterator.moveNext()) {
      HTMLElement element = iterator.current as HTMLElement;
      if (element.tabIndex == 0 && _visible(element)) {
        element.focus();
        return;
      }
    }
    _focusDefault();
  }

  bool _visible(Element element) {
    final elem = element as HTMLElement;
    return (elem.offsetWidth != 0 && elem.offsetHeight != 0);
  }

  void _focusDefault() {
    if (_autoFocusDirective != null) {
      _autoFocusDirective!.focus();
    } else if (_content != null) {
      final element = _content!.element as HTMLElement;
      element.focus();
    }
  }
}

@Directive(selector: '[focusContentWrapper]')
class FocusContentWrapper extends FocusableDirective {
  Element _element;
  FocusContentWrapper(super.element) : _element = element;

  Element get element => _element;
}
