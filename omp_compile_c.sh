#!/usr/bin/env bash
set -euo pipefail
if (( $# < 1 || $# > 2 )); then echo 'Usage: bash omp_compile_c.sh program.c [output_prefix]' >&2; exit 2; fi
sdk=$(cd "$(dirname "$0")" && pwd)
p=$(readlink -f "$sdk/.boards/active") || p=''
[[ -f $p/complete && -n $p ]] || { echo 'Run build.sh for your board first.' >&2; exit 1; }
input=$1
[[ $input == *.c && -f $input ]] || { echo "Expected C source: $input" >&2; exit 1; }
prefix=${2:-${input%.c}}
mkdir -p "$(dirname "$prefix")"
board=$(cat "$p/source-dir")
tools="$sdk/bin/sparc-elf-"
flags=(-O0 -Wall -mcpu=v8 -ffreestanding -I"$sdk" -I"$sdk/Openmp" -I"$board/include"
       -I"$p" '-DPARALLEL_PLATFORM_HEADER="sparcv8_tso.h"')
cc1=$("${tools}gcc" -print-prog-name=cc1)
"${tools}gcc" -E "${flags[@]}" -D_OPENMP=200805 "$input" -o "$prefix.i"
"$cc1" -quiet "${flags[@]}" -fpreprocessed -fopenmp "$prefix.i" -o "$prefix.s"
"${tools}as" -Av8 "$prefix.s" -o "$prefix.o"
objects=("$p/crt0.o" "$prefix.o" "$p/runtime.o" "$p/terminate.o")
if [[ -f $p/support.o ]]; then objects+=("$p/support.o"); fi
"${tools}ld" -T "$p/board.ld" -e _start "${objects[@]}" -o "$prefix.elf"
"${tools}objdump" -d "$prefix.elf" > "$prefix.objdump"
"${tools}readelf" -s "$prefix.elf" >> "$prefix.objdump"
echo "Built $prefix.elf"
if [[ -f $board/hexdump_to_memimage.py ]]; then
    "${tools}readelf" -x .text -x .rodata -x .data "$prefix.elf" |
        python3 "$board/hexdump_to_memimage.py" > "$prefix.hex"
    echo "Built $prefix.hex"
fi
