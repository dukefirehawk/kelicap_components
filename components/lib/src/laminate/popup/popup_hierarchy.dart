// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:web/web.dart';
import 'dart:js_interop';

import 'package:kelicap/kelicap.dart';
import 'package:kelicap_components/laminate/overlay/constants.dart';
import 'package:kelicap_components/utils/browser/events/events.dart' as events;

/// Tracks a hierarchy of visible popup and provides it closing logic.
@Injectable()
class PopupHierarchy {
  final _visiblePopupStack = <PopupHierarchyElement>[];

  /// Parent pane of the first popup hierarchy element.
  Element? _rootPane;

  StreamSubscription<Event>? _triggerListener;
  StreamSubscription<Event>? _keyUpListener;

  Event? _lastTriggerEvent;

  /// Whether last trigger event is a keyboard event or focus event.
  bool get islastTriggerWithKeyboard =>
      (_lastTriggerEvent?.isA<KeyboardEvent>() ?? false) ||
      (_lastTriggerEvent?.isA<FocusEvent>() ?? false);

  /// Closes every popup element present in the hierarchy.
  void closeHierarchy() {
    for (var popup in _visiblePopupStack) {
      popup.onDismiss();
    }

    _visiblePopupStack.clear();
    _disposeListeners();
  }

  void _attach(PopupHierarchyElement? child) {
    assert(child != null);
    if (_visiblePopupStack.isEmpty) {
      _rootPane = events.closestWithClass(child?.elementRef, 'pane');
    }
    _visiblePopupStack.add(child!);

    _triggerListener ??= events
        .triggersOutsideAny((node) => false)
        .listen(_onTrigger);
    _keyUpListener ??= EventStreamProvider<KeyboardEvent>(
      'keyup',
    ).forTarget(document).listen(_onKeyUp);
  }

  void _disposeListeners() {
    _triggerListener!.cancel();
    _keyUpListener!.cancel();
    _triggerListener = null;
    _keyUpListener = null;
  }

  void _detach(PopupHierarchyElement child) {
    if (_visiblePopupStack.remove(child) && _visiblePopupStack.isEmpty) {
      _rootPane = null;
      _disposeListeners();
    }
  }

  bool _isInHiddenModal() {
    // Find parent pane if any, done dynamically as the modal pane can be
    // created by another app using ACX.
    // TODO(google): Find a way to compute it only when needed and make it
    // globally accessible.
    var modalPanes = document.querySelectorAll(
      '.$overlayContainerClassName .pane.modal.visible',
    );
    if (modalPanes.length > 0) {
      // Only close popups that belong to the currently visible modal or whose
      // modal is no longer visible. Note that since the modal may already
      // have closed prior to this event being processed, it's possible in
      // some situations that the popups of the level below will be closed as
      // well.
      bool containsRoot = false;
      for (var i = 0; i < modalPanes.length; i++) {
        if (modalPanes.item(i) == _rootPane) {
          containsRoot = true;
          break;
        }
      }
      if (_rootPane == null ||
          (_rootPane != modalPanes.item(modalPanes.length - 1) &&
              containsRoot)) {
        return true;
      }
    }
    return false;
  }

  void _onTrigger(Event event) {
    // Some weird event, ignore it.
    if (event.target == null) return;

    _lastTriggerEvent = event;

    if (_isInHiddenModal()) return;

    for (int i = _visiblePopupStack.length - 1; i >= 0; i--) {
      final current = _visiblePopupStack[i];
      if (current.container == null) continue;

      if (events.isParentOf(current.container, event.target as Node?)) return;

      for (var blockerElement in current.autoDismissBlockers) {
        if (events.isParentOf(blockerElement, event.target as Node?)) return;
      }

      if (current.autoDismiss!) current.onAutoDismiss(event);
    }
  }

  void _onKeyUp(KeyboardEvent event) {
    // Some weird event, ignore it.
    if (event.target == null) return;

    _lastTriggerEvent = event;

    if (_isInHiddenModal()) return;

    if (event.keyCode == KeyCode.ESC) {
      for (int i = _visiblePopupStack.length - 1; i >= 0; i--) {
        final current = _visiblePopupStack[i];
        if (current.container == null) continue;

        if (events.isParentOf(current.container, event.target as Node?)) {
          event.stopPropagation();
          current.onDismiss();
          return;
        }

        for (var blockerElement in current.autoDismissBlockers) {
          if (events.isParentOf(blockerElement, event.target as Node?)) {
            event.stopPropagation();
            current.onDismiss();
            return;
          }
        }
      }
    }
  }
}

/// An electable element for the [PopupHierarchy].
abstract mixin class PopupHierarchyElement {
  PopupHierarchy get hierarchy;
  bool? get autoDismiss;

  /// The html element corresponding to the popup.
  Element? get container;

  Element? get elementRef => null;

  /// The outer element which should prevent the auto dismiss logic.
  List<Element> get autoDismissBlockers;

  /// Attach this element to the hierarchy.
  ///
  /// This should only be done when the element is getting visibility.
  void attachToVisibleHierarchy() {
    hierarchy._attach(this);
  }

  void detachFromVisibleHierarchy() {
    hierarchy._detach(this);
  }

  void onAutoDismiss(Event event) {
    onDismiss();
  }

  void onDismiss();
}
