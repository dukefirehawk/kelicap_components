// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'package:web/web.dart';

import 'package:kelicap/kelicap.dart';
import 'package:kelicap_components/src/laminate/ruler/ruler_interface.dart';
import 'package:kelicap_components/utils/browser/dom_service/dom_service.dart';

/// Measures and tracks size changes for HTML elements in Dart web applications.
@Injectable()
abstract class DomRuler implements Ruler<Element> {
  Stream<Rectangle> track(Element element, {bool aways = false});

  factory DomRuler(Document document, DomService domService) = DomRulerImpl;
}

/// Actual implementation.
@Injectable()
class DomRulerImpl extends RulerBase<Element> implements DomRuler {
  final Document _document;
  final DomService _domService;

  DomRulerImpl(this._document, this._domService);

  @override
  bool canSyncWrite(Element element) {
    return !_document.body!.contains(element);
  }

  @override
  Stream<DomService>? get onLayoutChanged => _domService.onLayoutChanged;

  @override
  Future<void> onRead() => _domService.onRead();

  @override
  Future<void> onWrite() => _domService.onWrite();

  @override
  Future<Rectangle> measure(Element element, {bool offset = false}) {
    if (canSyncWrite(element)) {
      // It is not possible to measure something not in the live DOM.
      // throw new StateError('Element is not in the live DOM document.');
      return Future<Rectangle>.value(const Rectangle(0, 0, 0, 0));
    }
    return super.measure(element, offset: offset);
  }

  @override
  Rectangle measureSync(Element element, {bool offset = false}) {
    // Purposefully don't use a 'canSyncWrite' here because some places in the
    // code will want a synchronous write regardless (e.g. overlays).

    final elm = element as HTMLElement;
    if (offset) {
      return Rectangle(
        elm.offsetLeft,
        elm.offsetTop,
        elm.offsetWidth,
        elm.offsetHeight,
      );
    }
    final DOMRect rect = element.getBoundingClientRect();

    return Rectangle(rect.left, rect.top, rect.width, rect.height);
  }

  @override
  Stream<Rectangle> track(Element element, {bool aways = false}) {
    if (canSyncWrite(element) && !aways) {
      // It is not possible to measure something not in the live DOM.
      // throw new StateError('Element is not in the live DOM document.');
      return Stream<Rectangle>.fromIterable(const [Rectangle(0, 0, 0, 0)]);
    }
    return super.track(element);
  }

  @override
  void removeCssClassesSync(Element element, List<String> classes) {
    classes.forEach(element.classList.remove);
  }

  @override
  void addCssClassesSync(Element element, List<String> classes) {
    classes.forEach(element.classList.add);
  }

  @override
  void clearCssPropertiesSync(Element element) {
    (element as HTMLElement).style.cssText = '';
  }

  @override
  void setCssPropertySync(
    Element element,
    String? propertyName,
    String? propertyValue,
  ) {
    if (propertyName!.isEmpty) return;

    (element as HTMLElement).style.setProperty(
      propertyName,
      propertyValue ?? '',
    );
  }
}
