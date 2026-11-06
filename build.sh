#!/usr/bin/env bash
set -euo pipefail

usage() { echo "Usage: bash build.sh <platform/compiler> <test.c>"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

if [[ $# == 1 && $1 == --help ]]; then usage; exit 0; fi
if [[ $# != 2 ]]; then usage >&2; exit 2; fi

sdk=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
platform=$(cd -- "$1" && pwd) || die "Cannot open platform directory: $1"
test_c=$2
[[ $test_c == *.c && -f $test_c && -r $test_c ]] || die "Expected a readable C source: $test_c"

export CROSS_COMPILE="$sdk/bin/sparc-elf-"
export CRT0="$platform/crt0.s"
export LDSCRIPT="$platform/sparc.ld"
export PLATFORM_HEADER="$platform/sparcv8_asr29_tso.h"
for input in "$CRT0" "$LDSCRIPT" "$PLATFORM_HEADER"; do
    [[ -f $input && -r $input ]] || die "Missing or unreadable platform file: $input"
done
export SUPPORT_C='' INCLUDE_DIR='' HEX_CONVERTER=''
if [[ -f $platform/freestanding_stubs.c ]]; then SUPPORT_C="$platform/freestanding_stubs.c"; fi
if [[ -d $platform/include ]]; then INCLUDE_DIR="$platform/include"; fi
if [[ -f $platform/hexdump_to_memimage.py ]]; then HEX_CONVERTER="$platform/hexdump_to_memimage.py"; fi

export OPENMP=1 DEFAULT_THREADS=1 ENTRY=_start
name=${test_c##*/}
exec bash "$sdk/omp_compile_c.sh" "$test_c" "${test_c%.c}"
