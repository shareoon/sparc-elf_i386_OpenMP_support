	.file	"omp_twocore_test.c"
	.section	".text"
	.align 4
	.type	platform_core_id, #function
	.proc	016
platform_core_id:
	save	%sp, -104, %sp
! 10 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/sparcv8_tso.h" 1
	rd %asr29, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	srl	%g1, 8, %g1
	and	%g1, 255, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	platform_core_id, .-platform_core_id
	.align 4
	.type	state_load_acquire, #function
	.proc	016
state_load_acquire:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
! 24 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/sparcv8_tso.h" 1
	ld [%g1], %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	state_load_acquire, .-state_load_acquire
	.align 4
	.type	state_store_release, #function
	.proc	020
state_store_release:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	ld	[%fp+68], %g2
! 37 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/sparcv8_tso.h" 1
	st %g1, [%g2]
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	state_store_release, .-state_store_release
	.align 4
	.type	__ajit_store_word_mmu_bypass__, #function
	.proc	020
__ajit_store_word_mmu_bypass__:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	ld	[%fp+72], %g2
! 35 "/home/sharon/SparcV8_core/compiler/include/ajit_access_routines.h" 1
	sta %g1, [%g2] 32
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_store_word_mmu_bypass__, .-__ajit_store_word_mmu_bypass__
	.align 4
	.type	__ajit_load_word_mmu_bypass__, #function
	.proc	016
__ajit_load_word_mmu_bypass__:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
! 41 "/home/sharon/SparcV8_core/compiler/include/ajit_access_routines.h" 1
	lda [%g1] 32, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_load_word_mmu_bypass__, .-__ajit_load_word_mmu_bypass__
	.align 4
	.type	__ajit_read_core_thread_id_word__, #function
	.proc	016
__ajit_read_core_thread_id_word__:
	save	%sp, -104, %sp
! 66 "/home/sharon/SparcV8_core/compiler/include/ajit_access_routines.h" 1
	rd %asr29, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_read_core_thread_id_word__, .-__ajit_read_core_thread_id_word__
	.align 4
	.type	ajit_get_core_and_thread_id, #function
	.proc	020
ajit_get_core_and_thread_id:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	call	__ajit_read_core_thread_id_word__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	srl	%g1, 8, %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	stb	%g2, [%g1]
	ld	[%fp-4], %g1
	mov	%g1, %g2
	ld	[%fp+72], %g1
	stb	%g2, [%g1]
	restore
	jmp	%o7+8
	 nop
	.size	ajit_get_core_and_thread_id, .-ajit_get_core_and_thread_id
	.align 4
	.type	ajitInterruptControlRegisterAddress, #function
	.proc	016
ajitInterruptControlRegisterAddress:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ld	[%fp+72], %g1
	add	%g2, %g1, %g1
	mov	%g1, %g2
	sethi	%hi(1073728512), %g1
	add	%g2, %g1, %g1
	sll	%g1, 2, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ajitInterruptControlRegisterAddress, .-ajitInterruptControlRegisterAddress
	.align 4
	.type	readInterruptControlRegister, #function
	.proc	016
readInterruptControlRegister:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	ajitInterruptControlRegisterAddress, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	readInterruptControlRegister, .-readInterruptControlRegister
	.align 4
	.type	writeInterruptControlRegister, #function
	.proc	020
writeInterruptControlRegister:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	ajitInterruptControlRegisterAddress, 0
	 nop
	mov	%o0, %g1
	ld	[%fp+76], %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	writeInterruptControlRegister, .-writeInterruptControlRegister
	.align 4
	.type	ajitInterruptControlWritableBits, #function
	.proc	016
ajitInterruptControlWritableBits:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g2
	sethi	%hi(64512), %g1
	or	%g1, 1023, %g1
	and	%g2, %g1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ajitInterruptControlWritableBits, .-ajitInterruptControlWritableBits
	.align 4
	.type	enableInterruptController, #function
	.proc	020
enableInterruptController:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	readInterruptControlRegister, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	ajitInterruptControlWritableBits, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	or	%g1, 1, %g1
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	mov	%g1, %o2
	call	writeInterruptControlRegister, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	enableInterruptController, .-enableInterruptController
	.align 4
	.type	disableInterruptController, #function
	.proc	020
disableInterruptController:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	readInterruptControlRegister, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	ajitInterruptControlWritableBits, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	and	%g1, -2, %g1
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	mov	%g1, %o2
	call	writeInterruptControlRegister, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	disableInterruptController, .-disableInterruptController
	.common	ajit_global_interrupt_handlers,64,4
	.align 4
	.global ajit_initialize_interrupt_handlers_to_null
	.type	ajit_initialize_interrupt_handlers_to_null, #function
	.proc	020
ajit_initialize_interrupt_handlers_to_null:
	save	%sp, -104, %sp
	st	%g0, [%fp-4]
	b	.LL28
	 nop
.LL29:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL28:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL29
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	ajit_initialize_interrupt_handlers_to_null, .-ajit_initialize_interrupt_handlers_to_null
	.align 4
	.global ajit_set_interrupt_handler
	.type	ajit_set_interrupt_handler, #function
	.proc	020
ajit_set_interrupt_handler:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	cmp	%g1, 15
	bgu	.LL33
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL33:
	restore
	jmp	%o7+8
	 nop
	.size	ajit_set_interrupt_handler, .-ajit_set_interrupt_handler
	.align 4
	.global ajit_generic_interrupt_handler
	.type	ajit_generic_interrupt_handler, #function
	.proc	020
ajit_generic_interrupt_handler:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -13, %g2
	add	%fp, -14, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	ajit_get_core_and_thread_id, 0
	 nop
	ldub	[%fp-13], %g1
	and	%g1, 0xff, %g2
	ldub	[%fp-14], %g1
	and	%g1, 0xff, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	disableInterruptController, 0
	 nop
	mov	1, %g1
	st	%g1, [%fp-12]
	ld	[%fp+68], %g1
	srl	%g1, 4, %g1
	and	%g1, 255, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, 16
	bleu	.LL35
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL35
	 nop
	ld	[%fp-8], %g1
	add	%g1, -16, %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 0
	be	.LL35
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL35:
	ldub	[%fp-13], %g1
	and	%g1, 0xff, %g2
	ldub	[%fp-14], %g1
	and	%g1, 0xff, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	enableInterruptController, 0
	 nop
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL37
	 nop
! 149 "/home/sharon/SparcV8_core/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL37:
	restore
	jmp	%o7+8
	 nop
	.size	ajit_generic_interrupt_handler, .-ajit_generic_interrupt_handler
	.local	runtime_ready
	.common	runtime_ready,4,4
	.local	observed_id
	.common	observed_id,8,4
	.local	observed_size
	.common	observed_size,8,4
	.local	counter
	.common	counter,4,4
	.align 4
	.type	run_test, #function
	.proc	016
run_test:
	save	%sp, -104, %sp
	sethi	%hi(observed_id), %g1
	or	%g1, %lo(observed_id), %g1
	mov	99, %g2
	st	%g2, [%g1]
	sethi	%hi(observed_id), %g1
	or	%g1, %lo(observed_id), %g1
	mov	99, %g2
	st	%g2, [%g1+4]
	sethi	%hi(observed_size), %g1
	or	%g1, %lo(observed_size), %g1
	st	%g0, [%g1]
	sethi	%hi(observed_size), %g1
	or	%g1, %lo(observed_size), %g1
	st	%g0, [%g1+4]
	sethi	%hi(counter), %g1
	or	%g1, %lo(counter), %g1
	st	%g0, [%g1]
	sethi	%hi(run_test.omp_fn.0), %g1
	or	%g1, %lo(run_test.omp_fn.0), %o0
	mov	0, %o1
	mov	2, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	run_test.omp_fn.0, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	sethi	%hi(observed_id), %g1
	or	%g1, %lo(observed_id), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	bne	.LL39
	 nop
	sethi	%hi(observed_id), %g1
	or	%g1, %lo(observed_id), %g1
	ld	[%g1+4], %g1
	cmp	%g1, 1
	bne	.LL39
	 nop
	sethi	%hi(observed_size), %g1
	or	%g1, %lo(observed_size), %g1
	ld	[%g1], %g1
	cmp	%g1, 2
	bne	.LL39
	 nop
	sethi	%hi(observed_size), %g1
	or	%g1, %lo(observed_size), %g1
	ld	[%g1+4], %g1
	cmp	%g1, 2
	bne	.LL39
	 nop
	sethi	%hi(counter), %g1
	or	%g1, %lo(counter), %g1
	ld	[%g1], %g1
	cmp	%g1, 200
	bne	.LL39
	 nop
	mov	1, %g1
	b	.LL40
	 nop
.LL39:
	mov	0, %g1
.LL40:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	run_test, .-run_test
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -104, %sp
	call	platform_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, 0
	bne	.LL43
	 nop
	call	parallel_runtime_init, 0
	 nop
	sethi	%hi(runtime_ready), %g1
	or	%g1, %lo(runtime_ready), %o0
	mov	1, %o1
	call	state_store_release, 0
	 nop
	call	run_test, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	call	parallel_runtime_shutdown, 0
	 nop
	ld	[%fp-4], %o0
	call	board_terminate, 0
	 nop
.LL43:
	ld	[%fp-8], %g1
	cmp	%g1, 1
	bne	.LL44
	 nop
.LL45:
	sethi	%hi(runtime_ready), %g1
	or	%g1, %lo(runtime_ready), %o0
	call	state_load_acquire, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL45
	 nop
	call	parallel_worker_loop, 0
	 nop
	mov	1, %o0
	call	board_terminate, 0
	 nop
.LL44:
	mov	0, %o0
	call	board_terminate, 0
	 nop
	nop
	.size	main, .-main
	.align 4
	.type	run_test.omp_fn.0, #function
	.proc	020
run_test.omp_fn.0:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, 0
	bge	.LL48
	 nop
.LL51:
	st	%g0, [%fp-4]
.LL50:
	ld	[%fp-4], %g1
	cmp	%g1, 99
	bg	.LL53
	 nop
.LL49:
	call	GOMP_atomic_start, 0
	 nop
	sethi	%hi(counter), %g1
	or	%g1, %lo(counter), %g1
	ld	[%g1], %g1
	add	%g1, 1, %g2
	sethi	%hi(counter), %g1
	or	%g1, %lo(counter), %g1
	st	%g2, [%g1]
	call	GOMP_atomic_end, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
	b	.LL50
	 nop
.LL48:
	ld	[%fp-8], %g1
	cmp	%g1, 1
	bg	.LL51
	 nop
	ld	[%fp-8], %g1
	ld	[%fp-8], %g3
	sethi	%hi(observed_id), %g2
	or	%g2, %lo(observed_id), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-8], %l0
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g3
	sethi	%hi(observed_size), %g1
	or	%g1, %lo(observed_size), %g2
	sll	%l0, 2, %g1
	st	%g3, [%g2+%g1]
	b	.LL51
	 nop
.LL53:
	restore
	jmp	%o7+8
	 nop
	.size	run_test.omp_fn.0, .-run_test.omp_fn.0
	.ident	"GCC: (GNU) 4.4.3"
