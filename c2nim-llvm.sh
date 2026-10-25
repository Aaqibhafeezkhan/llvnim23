#!/usr/bin/env bash
# Copyright (c) 2026 https://github.com/xlebore3o4ka

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "usage: $0 <input.h> <output.nim>" >&2
  exit 1
fi

IN="$1"
OUT="$2"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

TMPH="$TMP/$(basename "$IN")"

# 1. Strip LLVM_C_ABI and friends, inject C2NIM-friendly macro defs.
sed -E 's/\bLLVM_C_ABI[[:space:]]+//g' "$IN" > "$TMPH"

# 2. Prepend macro definitions inside a C2NIM guard so c2nim sees empty macros.
{
  echo '#ifdef C2NIM'
  echo '#  def LLVM_C_ABI'
  echo '#  def LLVM_C_EXTERN_C_BEGIN'
  echo '#  def LLVM_C_EXTERN_C_END'
  echo '#endif'
  cat "$TMPH"
} > "$TMPH.new"
mv "$TMPH.new" "$TMPH"

# 3. Run c2nim.
c2nim --skipinclude --cdecl --dynlib:libLLVM.so.23.1 --out:"$OUT" "$TMPH"

echo "ok: $OUT"