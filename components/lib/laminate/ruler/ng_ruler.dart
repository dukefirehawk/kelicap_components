// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:kelicap/kelicap.dart' hide Visibility;
import 'package:kelicap_components/laminate/enums/position.dart';
import 'package:kelicap_components/laminate/enums/visibility.dart';
import 'package:kelicap_components/laminate/ruler/dom_ruler.dart';
import 'package:kelicap_components/src/laminate/ruler/ruler_interface.dart';
import 'package:web/web.dart';

/// An implementation of ruler that works on Kelicap [ElementRef] objects.
@Deprecated('Use DomRuler instead. ElementRef is deprecated.')
@Injectable()
class NgRuler implements Ruler<Element> {
  // TODO(google): Deprecate doing this when web workers introduced.
  final DomRuler _domRuler;

  NgRuler(this._domRuler);

  @override
  Future<Rectangle> measure(Element element, {bool offset = false}) {
    return _domRuler.measure(element, offset: offset);
  }

  @override
  Stream<Rectangle> track(Element element) {
    return _domRuler.track(element);
  }

  @override
  Future<void> update(
    Element element, {
    List<String>? cssClasses,
    Visibility? visibility,
    Position? position,
    num? width,
    num? height,
    num? left,
    num? top,
    num? right,
    num? bottom,
    num? zIndex,
    bool useCssTransform = true,
  }) {
    return _domRuler.update(
      element,
      cssClasses: cssClasses,
      visibility: visibility,
      position: position,
      width: width,
      height: height,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      zIndex: zIndex,
      useCssTransform: useCssTransform,
    );
  }

  @override
  void updateSync(
    Element element, {
    List<String>? cssClasses,
    Visibility? visibility,
    Position? position,
    num? width,
    num? height,
    num? left,
    num? top,
    num? right,
    num? bottom,
    num? zIndex,
    bool useCssTransform = true,
  }) {
    return _domRuler.updateSync(
      element,
      cssClasses: cssClasses,
      visibility: visibility,
      position: position,
      width: width,
      height: height,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      zIndex: zIndex,
      useCssTransform: useCssTransform,
    );
  }

  @override
  Rectangle measureSync(Element element, {bool offset = false}) {
    return _domRuler.measureSync(element, offset: offset);
  }
}
