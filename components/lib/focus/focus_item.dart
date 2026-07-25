// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:kelicap/kelicap.dart';
import 'package:kelicap_components/focus/focus.dart';
import 'package:web/web.dart';

/// `FocusItemDirective`, used in conjunction with [FocusListDirective],
/// provides a means to move focus between a list of components (or elements)
/// by way of keyboard interaction.
@Directive(
  selector: '[focusItem]',
  providers: [ExistingProvider(FocusableItem, FocusItemDirective)],
)
class FocusItemDirective extends RootFocusable implements FocusableItem {
  final ChangeDetectorRef _changeDetectorRef;

  @HostBinding('attr.role')
  final String role;

  FocusItemDirective(
    HTMLElement super.element,
    this._changeDetectorRef,
    @Attribute('role') String? role,
  ) : role = role ?? 'listitem';

  @HostBinding('attr.tabindex')
  String tabIndex = '0';

  final _focusMoveCtrl = StreamController<FocusMoveEvent>.broadcast(sync: true);
  @override
  Stream<FocusMoveEvent> get focusmove => _focusMoveCtrl.stream;

  @HostListener('keydown')
  void keydown(KeyboardEvent event) {
    var focusEvent = FocusMoveEvent.fromKeyboardEvent(this, event);
    //if (focusEvent != null) {
    _focusMoveCtrl.add(focusEvent);
    //}
  }

  @override
  set tabbable(bool value) {
    tabIndex = value ? '0' : '-1';
    _changeDetectorRef.markForCheck();
  }
}
