/* sparc.ld
 *
 * Minimal linker script for standalone SPARC V8 test programs.
 *
 * Places .text at address 0 -- matching the SPARC V8 reset convention
 * (PC=0, nPC=4 after reset) -- with .rodata/.data/.bss following
 * immediately after, in the single flat address space modeled by MemCore.
 *
 * __bss_start/__bss_end mark .bss, for startup code that clears it
 * (crt0_multicore.s). Defining them does not move anything.
 *
 * .tdata and .tbss hold thread-local variables, which only OpenMP's threadprivate
 * uses. Their symbols let the OpenMP runtime set up each core's copy (Ref
 * sparc_common_routines/omp.h). A program with no such variables has both empty.
 */

ENTRY(main)

SECTIONS
{
	. = 0x00000000;
	.text   : { *(.text) *(.text.*) }
	.rodata : { *(.rodata) *(.rodata.*) }
	.data   : { *(.data) *(.data.*) }
	.tdata  : { __tdata_start = .; *(.tdata) *(.tdata.*) __tdata_end = .; }
	.tbss   : { __tbss_start = .; *(.tbss) *(.tbss.*) *(.tcommon) __tbss_end = .; }
	__tls_align = MAX(ALIGNOF(.tdata), ALIGNOF(.tbss));
	.bss    : { __bss_start = .; *(.bss) *(.bss.*) *(COMMON) __bss_end = .; }

	/DISCARD/ : { *(.comment) *(.note.*) }
}
