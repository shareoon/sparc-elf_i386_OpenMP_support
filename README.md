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
#include <omp.h>

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

## Application header

Use `#include <omp.h>` in application code. The SDK compile script selects the board adapter and supplies the include path.

| Functions available through `omp.h` | Purpose |
| --- | --- |
| `omp_get_thread_num()`, `omp_get_num_threads()` | OpenMP thread index and team size |
| `parallel_runtime_init()`, `parallel_worker_loop()` | SDK startup and worker entry |
| `platform_core_id()`, `board_terminate(status)` | SDK board identification and explicit termination |

GCC recognizes OpenMP pragmas through the compile flags. Including the header makes the function declarations available. Core 0 must still initialize the runtime once before its first parallel region, either in startup code or in the application.

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

## Compiler

The bundled tools are GCC 4.4.3 and GNU Binutils 2.20.1. The build preprocesses with the GCC driver, then invokes `cc1 -fopenmp` directly because the legacy driver adds an unsupported `-pthread` option. Preprocessing defines `_OPENMP=200805` to match this GCC version.

Programs that require a C library or compiler support routines must supply the required libraries at link time.

For inspection, `.i`, `.s`, and `.o` show the application’s preprocessed source, assembly, and object code. Use `.objdump` to see the linked startup, application, and runtime together. An optional second argument selects an output prefix, for example `bash omp_compile_c.sh counter.c build/counter`.

## OpenMP pragmas and clauses available today

Use these directives in C files compiled with `omp_compile_c.sh`. The examples describe the subset exercised with the bundled GCC 4.4.3 toolchain.

| Directive or clause | Example | Current coverage |
| --- | --- | --- |
| Parallel region | `#pragma omp parallel num_threads(1)` | Runs a structured block with the requested team. Repeated one-thread regions passed on SPARC. A two-thread request requires core 1 to be running the worker loop. |
| Static work-sharing loop | `#pragma omp parallel for schedule(static)` | GCC generates the iteration bounds for each thread. The single-core vector-add test checked the output elements and the guards at both ends of the array. |
| Integer addition reduction | `#pragma omp parallel for schedule(static) reduction(+:sum)` | Each participant accumulates a private sum and combines it into the shared result. Integer addition has single-core target coverage. |
| Atomic update | `#pragma omp atomic` followed by `count++;` | Protects an increment through the runtime’s shared atomic lock. Other atomic forms need their own coverage. |
| Unnamed critical region | `#pragma omp critical` followed by a block | Serializes entry using the runtime’s critical-region lock. The single-core test exercised entry and exit. |
| Explicit barrier | `#pragma omp barrier` inside a parallel region | GCC emits `GOMP_barrier`. The directive compiles and links for SPARC. Repeated two-participant barriers have been exercised on the host. |

A one-thread target run checks the generated instructions and result. Demonstrating that two SPARC cores divide iterations, wait for each other, or exclude each other from a critical region requires a two-core run.

## Validation

| Environment | Evidence |
| --- | --- |
| [SITAR SPARC V8 model](https://github.com/sitar-sim/SparcV8_core), single core | Tests passed for repeated parallel regions, static vector addition, integer addition reductions, unnamed critical regions, and atomic increments. One atomic test recorded ten atomic load-stores. The core-ID test returned ID 0 and halted through the configured termination routine. |
| Host runtime test | A separate host adapter exercised the runtime interfaces directly over 2,000 alternating one- and two-thread regions, including barriers and lock-protected updates. This checks runtime logic on the host. |
| Latest BSP build scripts | Generated a single-core SPARC ELF and hex image with the bundled compiler. A multicore ELF also linked using the multicore startup and an interrupt handler from a BSP archive. |

## Roadmap

1. **Validate the existing subset on two SPARC cores.** Confirm distinct core IDs and worker dispatch. Run a static loop with an odd iteration count and check that every iteration executes exactly once. Exercise repeated barriers, contended atomic and critical updates, reductions, and visibility through both cores’ caches.
2. **Candidate additions after dual-core validation:** named critical regions (separate locks for distinct names) and dynamic loop scheduling (threads request another chunk as they finish). Each addition needs a compiler-generated example and a multicore correctness test before it moves into the supported table.

Tasks, nested parallelism, and `threadprivate` are outside the current scope. Future features listed here are proposals.

## Attribution

Developed by Sharon Shibu as part of the SPARC V8 bare-metal parallel-execution project. The runtime uses GCC’s existing OpenMP lowering and GNU runtime interfaces.
