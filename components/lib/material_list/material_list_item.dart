// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:kelicap/kelicap.dart';
import 'package:kelicap_components/button_decorator/button_decorator.dart';
import 'package:kelicap_components/interfaces/has_disabled.dart';
import 'package:kelicap_components/mixins/material_dropdown_base.dart';
import 'package:kelicap_components/utils/disposer/disposer.dart';
import 'package:web/web.dart' as dom;

/// Material List Item is a block element intended for user interaction; it has
/// `:hover` styling and emits and `trigger` event when the user clicks or
/// presses `enter` or `space` keys.
///
/// See `MaterialListComponent` for item **grouping** and **labelling**.
///
/// Note: If the material-list-item has a [DropdownHandle] in its ancestry, the
/// dropdown will be closed on triggering (i.e. clicking or pressing enter/space
/// on) the list item if [closeOnActivate] is true.
// TODO(google): should activate/deactivate on mouse hover
@Component(
  selector: 'material-list-item',
  providers: [ExistingProvider(HasDisabled, MaterialListItemComponent)],
  styleUrls: ['material_list_item.scss.css'],
  template: '<ng-content></ng-content>',
  changeDetection: ChangeDetectionStrategy.onPush,
)
class MaterialListItemComponent extends ButtonDirective implements OnDestroy {
  @HostBinding('class')
  static const hostClass = 'item';

  final _disposer = Disposer.oneShot();
  final DropdownHandle? _dropdown;

  @override
  final String hostTabIndex;

  dom.HTMLElement element;

  MaterialListItemComponent(
    this.element,
    @Optional() this._dropdown,
    @Attribute('tabindex') String? tabIndex,
    @Attribute('role') String? role,
  ) : hostTabIndex = tabIndex ?? '0',
      super(element, role ?? 'listitem') {
    if (_dropdown != null) {
      _disposer.addDisposable(trigger.listen(handleActivate));
    }
  }

  @HostBinding('class.disabled')
  @override
  bool get disabled => super.disabled;

  /// Disables the trigger and gives item a disabled style.
  // Overridden just to give a better doc-comment;
  @override
  @Input()
  set disabled(bool? value) => super.disabled = value ?? false;

  /// Whether the encompassing dropdown should close on selection of
  /// this item.
  @Input()
  bool closeOnActivate = true;

  @override
  void ngOnDestroy() {
    _disposer.dispose();
  }

  void handleActivate(dom.UIEvent _) {
    if (closeOnActivate) _dropdown?.close();
  }
}
