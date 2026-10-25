# Package

version       = "0.2.0"
author        = "xlebore3o4ka"
description   = "Nim bindings for the LLVM-C API, version 23.1.x"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.2.10"

task testall, "Run tests with debug flags":
  exec "nimble --debugger:native --stacktrace:on --linetrace:on -d:debug --passC:-D_GNU_SOURCE -d:nimNoLentIterators test"