// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS()
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Function provided by a framework to register an [IsStableCallback] that is
/// invoked by the framework when it reaches a stable state.
typedef FrameworkStabilizer = void Function(IsStableCallback callback);

/// Function invoked by a framework when it has reached a stable state. The
/// `didWork` parameter indicates, if the framework did any work between
/// callback registration and callback invocation.
typedef IsStableCallback = void Function(bool didWork, String name);

// frameworkStabilizers is a property of the window object.
@JS('frameworkStabilizers')
// ignore: unused_element
external JSArray? get _frameworkStabilizersJs;

@JS('frameworkStabilizers')
// ignore: unused_element
external set _frameworkStabilizersJs(JSArray? values);

extension type _FrameworkStabilizersArray(JSArray _) implements JSArray {
  @JS('push')
  external void add(JSFunction fn);

  @JS('splice')
  external void splice(int index, int deleteCount);

  @JS('length')
  external int get length;

  @JS('length')
  external set length(int value);
}

/// Provides a set of helper functions for frameworks to register and deregister
/// stabilizing functions. These functions will be called by tests, whenever
/// they require the page to be stable before they can perform the next action.
class FrameworkStabilizers {
  static final Map<int, JSFunction> _idToFrameworkStabilizer = {};
  static int _nextId = 0;

  static _FrameworkStabilizersArray get _frameworkStabilizers {
    var stabilizers = _frameworkStabilizersJs;
    if (stabilizers == null) {
      stabilizers = JSArray();
      _frameworkStabilizersJs = stabilizers;
    }
    return stabilizers as _FrameworkStabilizersArray;
  }

  /// Add a stabilize function for a framework.
  ///
  /// This function will be called
  /// whenever a test needs to wait for the framework to stabilize. When the
  /// framework is stable, it needs to call the [IsStableCallback] provided
  /// as an argument to the [FrameworkStabilizer].
  /// Rules for calling the callback by the framework:
  ///   - If a framework is already stable at the time of callback
  ///     registration, the callback should be called in the next event loop
  ///     iteration with the `didWork` parameter set to false.
  ///   - Otherwise, the callback should be called as soon as the framework is
  ///     stable with `didWork` set to true.
  ///   - A registered callback should never be called more than once.
  ///
  /// The id returned by [add] can be used to remove the [FrameworkStabilizer]
  /// with [remove].
  static int add(FrameworkStabilizer fn) {
    var wrappedFn = ((JSFunction jsCallback) {
      void dartCallback(bool didWork, String name) {
        jsCallback.callAsFunction(null, didWork.toJS, name.toJS);
      }

      fn(dartCallback);
    }).toJS;
    var id = _nextId++;
    _idToFrameworkStabilizer[id] = wrappedFn;
    _frameworkStabilizers.add(wrappedFn);
    return id;
  }

  /// Removes the [FrameworkStabilizer] identified by [id].
  static bool remove(int id) {
    var wrappedFn = _idToFrameworkStabilizer.remove(id);
    if (wrappedFn == null) return false;

    var stabilizers = _frameworkStabilizers;
    for (var i = 0; i < stabilizers.length; i++) {
      if (stabilizers.getProperty(i.toJS) == wrappedFn) {
        stabilizers.splice(i, 1);
        return true;
      }
    }
    return false;
  }

  static void removeAll() {
    _idToFrameworkStabilizer.clear();
    _frameworkStabilizers.length = 0;
  }
}
