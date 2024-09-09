// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// All imports must be in all FFI patch files to not depend on the order
// the patches are applied.
import 'dart:_internal';
import 'dart:isolate';
import 'dart:typed_data';

@pragma("vm:external-name", "Ffi_dl_open")
external DynamicLibrary _open(String path);
@pragma("vm:external-name", "Ffi_dl_processLibrary")
external DynamicLibrary _processLibrary();
@pragma("vm:external-name", "Ffi_dl_executableLibrary")
external DynamicLibrary _executableLibrary();

@patch
@pragma("vm:entry-point")
class DynamicLibrary {
  @patch
  factory DynamicLibrary.open(String path) {
    return _open(path);
  }

  @patch
  factory DynamicLibrary.process() => _processLibrary();

  @patch
  factory DynamicLibrary.executable() => _executableLibrary();

  @patch
  @pragma("vm:external-name", "Ffi_dl_lookup")
  external Pointer<T> lookup<T extends NativeType>(String symbolName);

  @patch
  @pragma("vm:external-name", "Ffi_dl_providesSymbol")
  external bool providesSymbol(String symbolName);

  // TODO(dacoharkes): Expose this to users, or extend Pointer?
  // https://github.com/dart-lang/sdk/issues/35881
  @pragma("vm:external-name", "Ffi_dl_getHandle")
  external int getHandle();

  @patch
  bool operator ==(Object other) {
    if (other is! DynamicLibrary) return false;
    DynamicLibrary otherLib = other;
    return getHandle() == otherLib.getHandle();
  }

  @patch
  int get hashCode {
    return getHandle().hashCode;
  }

  @patch
  Pointer<Void> get handle => Pointer.fromAddress(getHandle());
}

extension DynamicLibraryExtension on DynamicLibrary {
  @patch
  DS lookupFunction<NS extends Function, DS extends Function>(String symbolName,
          {bool isLeaf: false}) =>
      throw UnsupportedError("The body is inlined in the frontend.");
}
