import 'dart:math';

import 'package:web/web.dart';

Rectangle toRectangle(DOMRect rect) {
  return Rectangle(rect.left, rect.top, rect.width, rect.height);
}

Point<num> toPoint(Touch touch) {
  return Point(touch.clientX, touch.clientY);
}
