#!/usr/bin/env bash
set -euo pipefail
die() { echo "Error: $*" >&2; exit 1; }
usage() { echo 'Usage: bash build.sh <bsp-directory> --core-id=asr29:15:8'; }
if [[ ${1:-} == --help ]]; then usage; exit; fi
(( $# == 2 )) || { usage >&2; exit 2; }
sdk=$(cd "$(dirname "$0")" && pwd)
board=$(cd -- "$1" && pwd) || die "Cannot open BSP directory: $1"
field='^--core-id=asr([0-9]|[12][0-9]|3[01]):([0-9]|[12][0-9]|3[01]):([0-9]|[12][0-9]|3[01])$'
[[ $2 =~ $field ]] || die 'Expected --core-id=asrREGISTER:HIGH:LOW (each 0..31)'
asr=${BASH_REMATCH[1]}
high=${BASH_REMATCH[2]}
shift_bits=${BASH_REMATCH[3]}
(( high >= shift_bits )) || die 'HIGH must be at least LOW'
width=$((high - shift_bits + 1))
# A board maintainer can select a named variant via a one-line file.
crt="$board/crt0.s"
if [[ -f $board/bsp.startup ]]; then
    crt="$board/$(cat "$board/bsp.startup")"
fi
[[ -f $crt && -r $crt ]] || die "Missing $crt. Set bsp.startup to the relative startup filename."
script="$board/sparc.ld"
if [[ -f $board/bsp.linker ]]; then
    script="$board/$(cat "$board/bsp.linker")"
fi
[[ -f $script && -r $script ]] || die "Missing $script. Set bsp.linker to the relative linker script filename."
threads=${DEFAULT_THREADS:-1}
[[ $threads == 1 || $threads == 2 ]] || die 'DEFAULT_THREADS must be 1 or 2'
profiles="$sdk/.boards"
mkdir -p "$profiles"
p=$(mktemp -d "$profiles/profile.XXXXXXXX")
trap 'rm -f "$p/activate"; if [[ ! -f $p/complete ]]; then rm -rf "$p"; fi' EXIT
cp "$script" "$p/board.ld"
printf '%s\n' "$board" > "$p/source-dir"
printf '#define BOARD_ASR "%s"\n#define BOARD_ID_SHIFT %s\n#define BOARD_ID_MASK 0x%xu\n' "$asr" "$shift_bits" "$(( (1 << width) - 1 ))" > "$p/board_config.h"
tools="$sdk/bin/sparc-elf-"
flags=(-O0 -Wall -mcpu=v8 -ffreestanding -I"$sdk/Openmp" -I"$p" -I"$board/include"
       '-DPARALLEL_PLATFORM_HEADER="sparcv8_tso.h"' "-DPARALLEL_DEFAULT_THREADS=$threads")
case $crt in
    *.o) cp "$crt" "$p/crt0.o" ;;
    *.S) "${tools}gcc" -E -P -x assembler-with-cpp -I"$board/include" "$crt" -o "$p/crt0.s"
         "${tools}as" -Av8 -I "$board" "$p/crt0.s" -o "$p/crt0.o" ;;
    *.s) "${tools}as" -Av8 -I "$board" "$crt" -o "$p/crt0.o" ;;
    *) die 'Expected startup ending in .s, .S or .o' ;;
esac
if [[ -f $board/board_terminate.s ]]; then
    "${tools}as" -Av8 -I "$board" "$board/board_terminate.s" -o "$p/terminate.o"
else
    printf '.text\n.align 4\n.global board_terminate\nboard_terminate:\n  ta 0\n  nop\n  nop\n1: ba 1b\n  nop\n' > "$p/terminate.s"
    "${tools}as" -Av8 "$p/terminate.s" -o "$p/terminate.o"
fi
compile_object() {
    "${tools}gcc" "${flags[@]}" -S "$1" -o "$p/$2.s"
    "${tools}as" -Av8 "$p/$2.s" -o "$p/$2.o"
}
compile_object "$sdk/Openmp/parallel_runtime.c" runtime
if [[ -f $board/freestanding_stubs.c ]]; then compile_object "$board/freestanding_stubs.c" support; fi
ln -s "$(basename "$p")" "$p/activate"
touch "$p/complete"
mv -Tf "$p/activate" "$profiles/active"
echo "Board ready: $crt, $script, ASR$asr bits $high:$shift_bits"
