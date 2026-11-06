# SPARC V8 Bare-Metal OpenMP Runtime

A minimal runtime for selected GCC-generated OpenMP constructs, with explicit platform adapters and external startup/linker inputs. The compiler is an external dependency; GCC itself is not modified.

This package supports adaptation to other SPARC V8 platforms. It is not a complete OpenMP implementation or a validated port to arbitrary processors. Runtime team management is limited to one or two logical cores.

## Contents

| File | Role |
| --- | --- |
| `omp.h` | Thread-ID and team-size API declarations |
| `parallel_runtime.h/.c` | Dispatch, join, barriers, atomic updates, unnamed critical regions |
| `parallel_platform.h` | Adapter selection and required interface |
| `platforms/sparcv8_asr29_tso.h` | Original ASR29/TSO/LDSTUB implementation, with the original failure trap |
| `omp_compile_c.sh` | Configurable SPARC build, ELF/disassembly output, optional model hex output |
| `tests/host_platform.h` | Host-only adapter for runtime logic testing |
| `tests/host_runtime_test.c` | Manual runtime-interface concurrency test |

No model startup, linker script, freestanding stubs, memory-image converter, compiler binaries, or simulator is included.

## Requirements

The target build is intended for the existing GNU `sparc-elf` GCC 4.4.3 / Binutils 2.20.1 toolchain, Bash, and user-supplied startup assembly and linker script. Python is required only for optional hex conversion.

The tested legacy GCC driver injects unsupported `-pthread` with `-fopenmp`. This script preprocesses through the driver without that flag, then invokes `cc1` with `-fopenmp`. It defines `_OPENMP=200805` during preprocessing to match GCC 4.4. This value describes the compiler's advertised language support, not this runtime's completeness. Other compiler versions and their runtime ABI require separate review.

## Build

Use `bash build.sh --help` for the command-line interface. From the extracted
package, set the model path and run the following command, replacing the test
source path with your own. The model files and cross-compiler are supplied
externally.

```bash
MODEL_COMPILER=/actual/path/to/SparcV8_core/compiler
bash build.sh \
  --startup "$MODEL_COMPILER/crt0.s" \
  --linker "$MODEL_COMPILER/sparc.ld" \
  --platform platforms/sparcv8_asr29_tso.h \
  --stubs "$MODEL_COMPILER/freestanding_stubs.c" \
  --include "$MODEL_COMPILER/include" \
  --hex-converter "$MODEL_COMPILER/hexdump_to_memimage.py" \
  --toolchain-bin "$HOME/toolchains/sparc-elf-gcc443/bin" \
  -o build/omp_atomic_portable /actual/path/to/omp_atomic_test.c
```

For another compatible target, select its startup, linker script, and adapter.
Omit the stubs and converter when the target builds without them. The wrapper
passes these settings to the lower-level script described below.

From this package's root, with the toolchain on PATH:

```bash
CRT0=/path/to/startup.s \
LDSCRIPT=/path/to/target.ld \
PLATFORM_HEADER="$PWD/platforms/sparcv8_asr29_tso.h" \
OPENMP=1 \
bash ./omp_compile_c.sh /path/to/program.c build/program
```

Select the bundled adapter only if your platform satisfies its assumptions. Otherwise supply your own adapter header. All user-supplied relative paths resolve from the calling directory.

| Setting | Meaning / default |
| --- | --- |
| `CRT0` | Required external startup assembly |
| `LDSCRIPT` | Required external linker script |
| `OPENMP` | `0` by default; set `1` to compile OpenMP and link the runtime |
| `PLATFORM_HEADER` | Required adapter header when `OPENMP=1` |
| `DEFAULT_THREADS` | Team size when no explicit size is requested; defaults to `1`, accepts `1` or `2` |
| `CROSS_COMPILE` | Tool executable prefix, default `sparc-elf-` |
| `ENTRY` | Linker entry symbol, default `_start` |
| `INCLUDE_DIR` | Optional additional application/platform include directory |
| `SUPPORT_C` | Optional external freestanding-support C source |
| `HEX_CONVERTER` | Optional external Python converter accepting readelf hex dumps on stdin |
| `PYTHON` | Converter interpreter, default `python3` |

Output includes `.elf`, `.objdump`, and intermediate compilation files. `.hex` is generated only when a converter is supplied. The optional converter input contains `.text`, `.rodata`, and `.data`; targets using other loadable sections need a suitable image-generation flow.

To reproduce the original model's build inputs, additionally set:

```bash
SUPPORT_C=/path/to/freestanding_stubs.c \
HEX_CONVERTER=/path/to/hexdump_to_memimage.py \
CRT0=/path/to/crt0.s \
LDSCRIPT=/path/to/sparc.ld \
PLATFORM_HEADER="$PWD/platforms/sparcv8_asr29_tso.h" \
OPENMP=1 DEFAULT_THREADS=1 \
bash ./omp_compile_c.sh /path/to/omp_test.c build/omp_test
```

The script does not automatically provide a C library, libgcc, or arbitrary additional objects. Programs requiring further support routines need explicit build integration.

## Porting contract

A platform header must supply the function signatures documented in `parallel_platform.h`. Implementations can be inline or backed by separately linked code. The provided script directly supports header implementations.

- Map hardware IDs to stable logical indices `0` and `1`.
- Implement atomic acquire loads and release stores for aligned unsigned-int flags.
- Implement acquire/release locking using the runtime's zero-initialized byte locks.
- Enforce both compiler and processor ordering of ordinary shared data.
- Implement a non-returning failure hook. `parallel_runtime_error` records the code before this hook runs.

The supplied SPARC adapter assumes ASR29 encodes `(core_id << 8) | thread_id`, coherent shared RAM, TSO ordering, atomic LDSTUB, and compatible `ta 0` behavior. These are explicit requirements, not universal SPARC V8 properties. On failure it places zero in `%o0` and traps; adapt this for other targets.

### Startup responsibilities

1. Establish valid execution state and a separate stack for each participating core.
2. Initialize C data/BSS once and make it visible to both cores.
3. Call `parallel_runtime_init()` once on logical core 0.
4. Publish completion of initialization using platform-appropriate synchronization.
5. Release logical core 1 into `parallel_worker_loop()` only after initialization is visible.
6. Run the application on core 0. Do not initialize the runtime again while the worker is active.

A single-core application may call initialization from `main`, as in the original tests. A two-core startup must coordinate it before releasing the worker. The runtime does not boot cores or provide a worker-shutdown protocol; platform termination is external.

Explicit `num_threads(2)` still requests two participants even when `DEFAULT_THREADS=1`. Do not request two without a running worker. The global atomic lock serializes all supported atomic updates regardless of address. Nested regions, tasks, named critical regions, dynamic scheduling, and environment-variable configuration are not implemented.

## Validation

Before this refactor, single-core model tests passed for basic/repeated parallel regions, static vector addition, integer addition reductions, unnamed critical regions, and atomic increments. The latter two each recorded ten atomic load-stores. Those runs used uncached accesses with MMU bypass; multicore SPARC behavior remains unverified.

After this refactor:

- Bash syntax validation passed.
- The host-adapter test compiled at `-O2` with warnings treated as errors and passed 2,000 alternating one-/two-thread regions, repeated barriers, and atomic/critical updates.
- The host test calls runtime interfaces manually. It does not validate SPARC instructions, compiler-generated OpenMP ABI behavior, startup, target coherence, or the target build pipeline.
- The revised script and SPARC adapter still require compilation and regression execution with the actual target toolchain/model.

Run the host test with a modern host GCC-compatible compiler and pthreads:

```bash
cc -std=c11 -O2 -Wall -Wextra -Werror -pthread -I. \
  '-DPARALLEL_PLATFORM_HEADER="tests/host_platform.h"' \
  parallel_runtime.c tests/host_runtime_test.c -o /tmp/omp-host-test
/tmp/omp-host-test
```

Next target checks: repeat the single-core regression suite; validate dual-core startup and IDs, dispatch, loop partitioning, repeated barriers, contended locks, reductions, cached visibility, and termination.

## Attribution and licensing

Developed by Sharon Shibu as part of SPARC V8 bare-metal parallel-execution work using GNU GCC's existing OpenMP lowering and runtime interfaces. Initial validation used the SPARC V8 model environment associated with SITAR.

A project license has not yet been selected. This package does not assign new licensing terms to supplied or adapted code. External dependencies retain their respective terms.
