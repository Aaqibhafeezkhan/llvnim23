# Package

version       = "0.1.0"
author        = "xlebore3o4ka"
description   = "Nim bindings for the LLVM-C API, version 23.1.1"
license       = "AGPL-3.0"
srcDir        = "src"

# Dependencies

requires "nim >= 2.2.10"

task testall, "Run tests with debug flags":
  exec "nimble --debugger:native --stacktrace:on --linetrace:on -d:debug --passC:-D_GNU_SOURCE -d:nimNoLentIterators test"