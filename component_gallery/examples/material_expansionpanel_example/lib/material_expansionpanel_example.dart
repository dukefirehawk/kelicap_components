// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:kelicap/kelicap.dart';
//import 'package:ngforms/ngforms.dart';
import 'package:kelicap_components/focus/focus.dart';
import 'package:kelicap_components/focus/focus_list.dart';
import 'package:kelicap_components/laminate/components/modal/modal.dart';
import 'package:kelicap_components/laminate/overlay/module.dart';
import 'package:kelicap_components/material_button/material_button.dart';
import 'package:kelicap_components/material_dialog/material_dialog.dart';
import 'package:kelicap_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:kelicap_components/material_expansionpanel/material_expansionpanel_auto_dismiss.dart';
import 'package:kelicap_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:kelicap_components/material_icon/material_icon.dart';
import 'package:kelicap_components/material_input/material_input.dart';
import 'package:kelicap_components/material_yes_no_buttons/material_yes_no_buttons.dart';
import 'package:kelicap_components/model/action/async_action.dart';
import 'package:kelicap_gallery_section/annotation/gallery_section_config.dart';

@GallerySectionConfig(
  displayName: 'Material ExpansionPanel',
  docs: [
    MaterialExpansionPanel,
    MaterialExpansionPanelSet,
    MaterialExpansionPanelAutoDismiss,
  ],
  demos: [MaterialExpansionDemo],
)
class MaterialExpansionPanelGalleryConfig {}

@Component(
  selector: 'material-expansion-demo',
  providers: [overlayBindings],
  directives: [
    AutoFocusDirective,
    FocusListDirective,
    MaterialIconComponent,
    MaterialButtonComponent,
    MaterialExpansionPanel,
    MaterialExpansionPanelAutoDismiss,
    MaterialExpansionPanelSet,
    MaterialDialogComponent,
    MaterialInputComponent,
    materialInputDirectives,
    MaterialYesNoButtonsComponent,
    ModalComponent,
    NgModel,
  ],
  styleUrls: ['material_expansionpanel_example.scss.css'],
  templateUrl: 'material_expansionpanel_example.html',
  preserveWhitespace: true,
)
class MaterialExpansionDemo {
  String name = 'Test';
  bool isCustomToolBeltPanelExpanded = true;

  bool showConfirmation = false;
  Completer<bool>? dialogFutureCompleter;

  void showConfirmationDialog(AsyncAction event) {
    showConfirmation = true;
    dialogFutureCompleter = Completer();
    event.cancelIf(dialogFutureCompleter!.future);
  }

  void closeDialog(bool proceed) {
    showConfirmation = false;
    if (dialogFutureCompleter != null) {
      dialogFutureCompleter!.complete(!proceed);
    }
  }
}
