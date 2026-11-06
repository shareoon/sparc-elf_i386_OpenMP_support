#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die() { echo "Error: $*" >&2; exit 1; }
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: CRT0=... LDSCRIPT=... PLATFORM_HEADER=... OPENMP=1 bash $0 input.c [output_prefix]" >&2
    exit 1
fi
INPUT="$1"
PREFIX="${2:-${INPUT%.c}}"
OPENMP="${OPENMP:-0}"
DEFAULT_THREADS="${DEFAULT_THREADS:-1}"
case "$OPENMP" in 0|1) ;; *) die 'OPENMP must be 0 or 1';; esac
case "$DEFAULT_THREADS" in 1|2) ;; *) die 'DEFAULT_THREADS must be 1 or 2';; esac
: "${CRT0:?Set CRT0 to a startup assembly file}"
: "${LDSCRIPT:?Set LDSCRIPT to a target linker script}"
for path in "$INPUT" "$CRT0" "$LDSCRIPT"; do
    [ -f "$path" ] || die "File not found: $path"
done
# All caller-supplied relative paths resolve from the calling directory.
CROSS_COMPILE="${CROSS_COMPILE:-sparc-elf-}"
CC="${CROSS_COMPILE}gcc"
AS="${CROSS_COMPILE}as"
LD="${CROSS_COMPILE}ld"
READELF="${CROSS_COMPILE}readelf"
OBJDUMP="${CROSS_COMPILE}objdump"
for tool in "$CC" "$AS" "$LD" "$READELF" "$OBJDUMP"; do
    command -v "$tool" >/dev/null || die "Tool not found: $tool"
done

# Fixed: The include directory now matches the actual "Openmp" folder name
CFLAGS=(-O0 -Wall -mcpu=v8 -ffreestanding -I"$SCRIPT_DIR" -I"$SCRIPT_DIR/Openmp")

if [ -n "${INCLUDE_DIR:-}" ]; then CFLAGS+=(-I"$INCLUDE_DIR"); fi
if [ "$OPENMP" = 1 ]; then
    : "${PLATFORM_HEADER:?Set PLATFORM_HEADER to a platform adapter header}"
    [ -f "$PLATFORM_HEADER" ] || die "Adapter not found: $PLATFORM_HEADER"
    PLATFORM_HEADER="$(cd "$(dirname "$PLATFORM_HEADER")" && pwd)/$(basename "$PLATFORM_HEADER")"
    CFLAGS+=("-DPARALLEL_PLATFORM_HEADER=\"$PLATFORM_HEADER\"" "-DPARALLEL_DEFAULT_THREADS=$DEFAULT_THREADS")
fi
if [ -n "${SUPPORT_C:-}" ]; then
    [ -f "$SUPPORT_C" ] || die "Support source not found: $SUPPORT_C"
fi
if [ -n "${HEX_CONVERTER:-}" ]; then
    [ -f "$HEX_CONVERTER" ] || die "Hex converter not found: $HEX_CONVERTER"
    command -v "${PYTHON:-python3}" >/dev/null || die 'Python not found'
fi
mkdir -p "$(dirname "$PREFIX")"
OBJECTS=("$PREFIX.crt0.o" "$PREFIX.o")
"$AS" -Av8 "$CRT0" -o "$PREFIX.crt0.o"
if [ "$OPENMP" = 1 ]; then
    CC1_PATH="$("$CC" -print-prog-name=cc1)"
    # Preprocess with the driver separately. We do not pass -fopenmp to the driver, which injects unsupported -pthread in the tested GCC 4.4.3 toolchain.
    # GCC 4.4 advertises OpenMP 3.0 as _OPENMP=200805.
    "$CC" -E "${CFLAGS[@]}" -D_OPENMP=200805 "$INPUT" -o "$PREFIX.i"
    "$CC1_PATH" "${CFLAGS[@]}" -fpreprocessed -fopenmp "$PREFIX.i" -o "$PREFIX.s"
    
    # Fixed: Corrected intermediate output file paths to build in the target output prefix location, not inside the source file path
    "$CC" -S "${CFLAGS[@]}" "$SCRIPT_DIR/Openmp/parallel_runtime.c" -o "$PREFIX.runtime.s"
    "$AS" -Av8 "$PREFIX.runtime.s" -o "$PREFIX.runtime.o"
    OBJECTS+=("$PREFIX.runtime.o")
else
    "$CC" -S "${CFLAGS[@]}" "$INPUT" -o "$PREFIX.s"
fi
"$AS" -Av8 "$PREFIX.s" -o "$PREFIX.o"
if [ -n "${SUPPORT_C:-}" ]; then
    "$CC" -S "${CFLAGS[@]}" "$SUPPORT_C" -o "$PREFIX.support.s"
    "$AS" -Av8 "$PREFIX.support.s" -o "$PREFIX.support.o"
    OBJECTS+=("$PREFIX.support.o")
fi
"$LD" -T "$LDSCRIPT" -e "${ENTRY:-_start}" "${OBJECTS[@]}" -o "$PREFIX.elf"
"$OBJDUMP" -d "$PREFIX.elf" > "$PREFIX.objdump"
"$READELF" -s "$PREFIX.elf" >> "$PREFIX.objdump"
if [ -n "${HEX_CONVERTER:-}" ]; then
    "$READELF" --hex-dump=.text --hex-dump=.rodata --hex-dump=.data "$PREFIX.elf" |
        "${PYTHON:-python3}" "$HEX_CONVERTER" > "$PREFIX.hex"
    echo "Built $PREFIX.hex"
fi
echo "Built $PREFIX.elf and $PREFIX.objdump (OPENMP=$OPENMP)"
