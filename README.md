# SPARC V8 Bare-Metal OpenMP Runtime

Build freestanding C programs that use selected OpenMP constructs on SPARC V8. The repository bundles a GNU `sparc-elf` cross-toolchain and a small target-side runtime. GCC lowers a parallel region into a worker function and calls to `GOMP_*`. The runtime handles dispatch, synchronization, and join. The board support package (BSP) supplies startup code and the memory layout.

**Validation status:** Selected constructs have passed single-core target tests. The runtime supports teams of one or two logical cores. Two-core SPARC execution and cache visibility still need target validation.

## Quick start

Run these commands from the repository root on a compatible **x86-64 Linux host** with Bash. The supplied binaries target bare-metal SPARC V8. Python 3 is needed for the optional memory-image conversion.

Configure the runtime once for your board. Replace the path with your BSP directory and use the core-ID field from your processor documentation. This example assumes the core ID occupies bits 15 through 8 of ASR29:

```bash
bash build.sh /path/to/board/bsp --core-id=asr29:15:8
```

The field means **ASR29, high bit 15, low bit 8**, inclusive. Setup assembles the startup, builds the runtime and optional stubs, and selects the resulting profile under `.boards/`. The scripts use the compiler in this repository’s `bin/` directory. If an extracted archive lost its executable permissions, run `chmod +x bin/sparc-elf-* libexec/gcc/sparc-elf/4.4.3/cc1`.

Save this single-core example as `counter.c`:

```c
#include "parallel_runtime.h"

static unsigned int count;

int main(void)
{
    parallel_runtime_init();
    count = 0;

    #pragma omp parallel num_threads(1)
    {
        #pragma omp atomic
        count++;
    }

    return count == 1u ? 0 : 1;
}
```

Compile it with the active board profile:

```bash
bash omp_compile_c.sh counter.c
```

The script writes `counter.elf` and `counter.objdump` beside the source. Load the ELF with your board’s usual programming or debugging tools. The example returns zero when the counter equals one. Your BSP startup determines what happens after `main()` returns. If the BSP provides a memory-image converter, the script also generates `counter.hex`.

## Board setup

The folder passed to `build.sh` describes one target configuration. Keep it accessible after setup because application builds use its headers, libraries, and optional converter.

| BSP entry | How the scripts use it |
| --- | --- |
| `crt0.s` | Default startup. To select another, put its relative path on one line in `bsp.startup`. Supported inputs are assembly (`.s`), preprocessed assembly (`.S`), or a startup object (`.o`). |
| `sparc.ld` | Default linker script. To select another, put its relative path in `bsp.linker`. The linker entry symbol is `_start`. |
| `include/`, `lib/*.a` | Optional platform headers and matching static libraries. Only place compatible libraries for this target in `lib/`. |
| `freestanding_stubs.c` | Optional support routines compiled during setup. Supply any additional routines your application or startup references. |
| `hexdump_to_memimage.py` | Optional converter receiving hex dumps of `.text`, `.rodata`, and `.data`. Targets with other initialized sections need an image-generation step that includes them. |
| `board_terminate.s` | Optional implementation of `board_terminate(status)` for your board. The default passes status in `%o0` and executes `ta 0`. Supply an override if your board uses another convention. |

When a BSP has multiple startup variants, select the one matching the board configuration. Its linker script and libraries must supply the symbols that startup references. Re-run setup after changing boards, startup, linker layout, runtime, stubs, or ASR settings. Exclude the generated `.boards/` directory from version control.

## Runtime and porting requirements

The adapter in `Openmp/sparcv8_tso.h` extracts the configured ASR field. Its value must identify logical core 0 (primary) or 1 (worker). The synchronization code assumes coherent shared RAM, total store ordering (TSO), aligned 32-bit shared flags, and atomic byte locks using `ldstub`. Changing the ASR field only adapts core identification. A target with different memory-ordering or locking requirements needs corresponding changes to the adapter. Runtime failures record a diagnostic in `parallel_runtime_error` before calling the board termination hook with status zero.

For two cores, startup must give each core its own stack and initialize shared C data once. Core 0 calls `parallel_runtime_init()` once and publishes completion. Core 1 waits until initialization is visible, then enters `parallel_worker_loop()`. Core 0 runs the application. If both cores enter the same `main()`, arrange this handoff before core 0 starts its first parallel region.

The default team size is one. Set `DEFAULT_THREADS=2` when running **board setup** to change it. An explicit `num_threads(2)` requests two participants regardless of that default and requires a running worker. The worker loop runs indefinitely.

## Compiler and supported constructs

The bundled tools are GCC 4.4.3 and GNU Binutils 2.20.1. The build preprocesses with the GCC driver, then invokes `cc1 -fopenmp` directly because the legacy driver adds an unsupported `-pthread` option. Preprocessing defines `_OPENMP=200805` to match this GCC version. Runtime coverage is limited to the constructs below.

| Component | Coverage |
| --- | --- |
| `Openmp/omp.h` | `omp_get_thread_num()` and `omp_get_num_threads()` |
| `Openmp/parallel_runtime.c` and `.h` | Parallel region start/join, reusable barrier, atomic updates via one shared lock, and unnamed critical regions |
| GCC-generated code exercised in tests | Static vector-add loops and integer addition reductions, alongside repeated parallel regions and synchronization |

Tasks, nested parallelism, named critical regions, dynamic scheduling, and `threadprivate` are outside the validated feature set. Programs that require a C library or compiler support routines must supply the required libraries at link time.

For inspection, `.i`, `.s`, and `.o` show the application’s preprocessed source, assembly, and object code. Use `.objdump` to see the linked startup, application, and runtime together. An optional second argument selects an output prefix, for example `bash omp_compile_c.sh counter.c build/counter`.

## Validation

| Environment | Evidence |
| --- | --- |
| [SITAR SPARC V8 model](https://github.com/sitar-sim/SparcV8_core), single core | Tests passed for repeated parallel regions, static vector addition, integer addition reductions, unnamed critical regions, and atomic increments. One atomic test recorded ten atomic load-stores. The core-ID test returned ID 0 and halted through the configured termination routine. |
| Host runtime test | A separate host adapter exercised the runtime interfaces directly over 2,000 alternating one- and two-thread regions, including barriers and lock-protected updates. This checks runtime logic on the host. |
| Latest BSP build scripts | Generated a single-core SPARC ELF and hex image with the bundled compiler. A multicore ELF also linked using the multicore startup and an interrupt handler from a BSP archive. |

Two-core target validation remains open for distinct core IDs, worker dispatch, loop partitioning, repeated barriers, contended updates, and visibility through the target caches.

## Attribution and licensing

Developed by Sharon Shibu as part of the SPARC V8 bare-metal parallel-execution project. The runtime uses GCC’s existing OpenMP lowering and GNU runtime interfaces.

A license for the project’s own code is pending. The bundled GNU tools and any separately supplied BSP components retain their respective licenses.
