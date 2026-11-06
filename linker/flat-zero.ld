/* For an image loaded directly into contiguous writable memory at zero.
   The build driver links the startup object first. */
ENTRY(_start)
SECTIONS
{
    . = 0;
    .text : { *(.text .text.*) }
    ASSERT(_start == 0, "This layout requires _start at address zero")
    .rodata : { *(.rodata .rodata.*) }
    .data : { *(.data .data.* .sdata .sdata.*) }
    .bss : {
        __bss_start = .;
        *(.bss .bss.* .sbss .sbss.*)
        *(COMMON)
        __bss_end = .;
    }
    /DISCARD/ : { *(.comment) *(.note.GNU-stack) }
}
