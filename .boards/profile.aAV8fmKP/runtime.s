	.file	"parallel_runtime.c"
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
	.type	platform_lock_try, #function
	.proc	016
platform_lock_try:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
! 51 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/sparcv8_tso.h" 1
	ldstub [%g1], %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	platform_lock_try, .-platform_lock_try
	.align 4
	.type	platform_lock_acquire, #function
	.proc	020
platform_lock_acquire:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
.LL10:
	ld	[%fp+68], %o0
	call	platform_lock_try, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	platform_lock_acquire, .-platform_lock_acquire
	.align 4
	.type	platform_lock_release, #function
	.proc	020
platform_lock_release:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
! 72 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/sparcv8_tso.h" 1
	stb %g0, [%g1]
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	platform_lock_release, .-platform_lock_release
	.align 4
	.type	platform_runtime_fail, #function
	.proc	020
platform_runtime_fail:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	mov	0, %o0
	call	board_terminate, 0
	 nop
	nop
	.size	platform_runtime_fail, .-platform_runtime_fail
	.local	mailbox
	.common	mailbox,12,4
	.local	active_team_size
	.common	active_team_size,4,4
	.local	region_active
	.common	region_active,4,4
	.local	barrier_sense
	.common	barrier_sense,8,4
	.local	barrier_arrived
	.common	barrier_arrived,4,4
	.local	barrier_released
	.common	barrier_released,4,4
	.common	parallel_runtime_error,4,4
	.local	atomic_lock
	.common	atomic_lock,1,1
	.local	critical_lock
	.common	critical_lock,1,1
	.align 4
	.type	runtime_fail, #function
	.proc	020
runtime_fail:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	sethi	%hi(parallel_runtime_error), %g1
	or	%g1, %lo(parallel_runtime_error), %g1
	ld	[%fp+68], %g2
	st	%g2, [%g1]
	ld	[%fp+68], %o0
	call	platform_runtime_fail, 0
	 nop
.LL17:
	b	.LL17
	 nop
	.size	runtime_fail, .-runtime_fail
	.align 4
	.global parallel_runtime_init
	.type	parallel_runtime_init, #function
	.proc	020
parallel_runtime_init:
	save	%sp, -96, %sp
	call	platform_core_id, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL20
	 nop
	mov	1, %o0
	call	runtime_fail, 0
	 nop
.LL20:
	sethi	%hi(mailbox), %g1
	or	%g1, %lo(mailbox), %g1
	st	%g0, [%g1]
	sethi	%hi(mailbox), %g1
	or	%g1, %lo(mailbox), %g1
	st	%g0, [%g1+4]
	sethi	%hi(active_team_size), %g1
	or	%g1, %lo(active_team_size), %g1
	mov	1, %g2
	st	%g2, [%g1]
	sethi	%hi(region_active), %g1
	or	%g1, %lo(region_active), %g1
	st	%g0, [%g1]
	sethi	%hi(parallel_runtime_error), %g1
	or	%g1, %lo(parallel_runtime_error), %g1
	st	%g0, [%g1]
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	mov	0, %o1
	call	state_store_release, 0
	 nop
	sethi	%hi(barrier_sense), %g1
	or	%g1, %lo(barrier_sense), %g1
	st	%g0, [%g1]
	sethi	%hi(barrier_sense), %g1
	or	%g1, %lo(barrier_sense), %g1
	st	%g0, [%g1+4]
	sethi	%hi(barrier_arrived), %g1
	or	%g1, %lo(barrier_arrived), %g1
	st	%g0, [%g1]
	sethi	%hi(barrier_released), %g1
	or	%g1, %lo(barrier_released), %g1
	st	%g0, [%g1]
	sethi	%hi(atomic_lock), %g1
	or	%g1, %lo(atomic_lock), %g1
	stb	%g0, [%g1]
	sethi	%hi(critical_lock), %g1
	or	%g1, %lo(critical_lock), %g1
	stb	%g0, [%g1]
	restore
	jmp	%o7+8
	 nop
	.size	parallel_runtime_init, .-parallel_runtime_init
	.align 4
	.global GOMP_parallel_start
	.type	GOMP_parallel_start, #function
	.proc	020
GOMP_parallel_start:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	call	platform_core_id, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL23
	 nop
	mov	1, %o0
	call	runtime_fail, 0
	 nop
.LL23:
	sethi	%hi(region_active), %g1
	or	%g1, %lo(region_active), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	be	.LL24
	 nop
	mov	3, %o0
	call	runtime_fail, 0
	 nop
.LL24:
	ld	[%fp+68], %g1
	cmp	%g1, 0
	bne	.LL25
	 nop
	mov	5, %o0
	call	runtime_fail, 0
	 nop
.LL25:
	ld	[%fp+76], %g1
	cmp	%g1, 0
	be	.LL26
	 nop
	ld	[%fp+76], %g1
	b	.LL27
	 nop
.LL26:
	mov	1, %g1
.LL27:
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 2
	bleu	.LL28
	 nop
	mov	2, %o0
	call	runtime_fail, 0
	 nop
.LL28:
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	call	state_load_acquire, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL29
	 nop
	mov	4, %o0
	call	runtime_fail, 0
	 nop
.LL29:
	sethi	%hi(active_team_size), %g1
	or	%g1, %lo(active_team_size), %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1]
	sethi	%hi(region_active), %g1
	or	%g1, %lo(region_active), %g1
	mov	1, %g2
	st	%g2, [%g1]
	ld	[%fp-4], %g1
	cmp	%g1, 1
	be	.LL33
	 nop
.LL30:
	sethi	%hi(mailbox), %g1
	or	%g1, %lo(mailbox), %g1
	ld	[%fp+68], %g2
	st	%g2, [%g1]
	sethi	%hi(mailbox), %g1
	or	%g1, %lo(mailbox), %g1
	ld	[%fp+72], %g2
	st	%g2, [%g1+4]
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	mov	1, %o1
	call	state_store_release, 0
	 nop
	b	.LL32
	 nop
.LL33:
	nop
.LL32:
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_parallel_start, .-GOMP_parallel_start
	.align 4
	.global GOMP_parallel_end
	.type	GOMP_parallel_end, #function
	.proc	020
GOMP_parallel_end:
	save	%sp, -96, %sp
	call	platform_core_id, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL35
	 nop
	mov	1, %o0
	call	runtime_fail, 0
	 nop
.LL35:
	sethi	%hi(region_active), %g1
	or	%g1, %lo(region_active), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	bne	.LL36
	 nop
	mov	4, %o0
	call	runtime_fail, 0
	 nop
.LL36:
	sethi	%hi(active_team_size), %g1
	or	%g1, %lo(active_team_size), %g1
	ld	[%g1], %g1
	cmp	%g1, 2
	bne	.LL37
	 nop
.LL38:
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	call	state_load_acquire, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 2
	bne	.LL38
	 nop
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	mov	0, %o1
	call	state_store_release, 0
	 nop
.LL37:
	sethi	%hi(active_team_size), %g1
	or	%g1, %lo(active_team_size), %g1
	mov	1, %g2
	st	%g2, [%g1]
	sethi	%hi(region_active), %g1
	or	%g1, %lo(region_active), %g1
	st	%g0, [%g1]
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_parallel_end, .-GOMP_parallel_end
	.align 4
	.global parallel_worker_loop
	.type	parallel_worker_loop, #function
	.proc	020
parallel_worker_loop:
	save	%sp, -112, %sp
	call	platform_core_id, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	be	.LL41
	 nop
	mov	1, %o0
	call	runtime_fail, 0
	 nop
.LL41:
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	call	state_load_acquire, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 1
	be	.LL42
	 nop
	ld	[%fp-4], %g1
	cmp	%g1, 3
	bne	.LL41
	 nop
.LL42:
	ld	[%fp-4], %g1
	cmp	%g1, 3
	bne	.LL43
	 nop
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	mov	4, %o1
	call	state_store_release, 0
	 nop
	restore
	jmp	%o7+8
	 nop
.LL43:
	sethi	%hi(mailbox), %g1
	or	%g1, %lo(mailbox), %g1
	ld	[%g1], %g1
	st	%g1, [%fp-12]
	sethi	%hi(mailbox), %g1
	or	%g1, %lo(mailbox), %g1
	ld	[%g1+4], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %g1
	ld	[%fp-8], %o0
	call	%g1, 0
	 nop
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	mov	2, %o1
	call	state_store_release, 0
	 nop
	b	.LL41
	 nop
	.size	parallel_worker_loop, .-parallel_worker_loop
	.align 4
	.global omp_get_thread_num
	.type	omp_get_thread_num, #function
	.proc	04
omp_get_thread_num:
	save	%sp, -104, %sp
	call	platform_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 1
	bleu	.LL46
	 nop
	mov	1, %o0
	call	runtime_fail, 0
	 nop
.LL46:
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_thread_num, .-omp_get_thread_num
	.align 4
	.global omp_get_num_threads
	.type	omp_get_num_threads, #function
	.proc	04
omp_get_num_threads:
	save	%sp, -96, %sp
	sethi	%hi(active_team_size), %g1
	or	%g1, %lo(active_team_size), %g1
	ld	[%g1], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_num_threads, .-omp_get_num_threads
	.align 4
	.global GOMP_barrier
	.type	GOMP_barrier, #function
	.proc	020
GOMP_barrier:
	save	%sp, -104, %sp
	call	platform_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, 1
	bleu	.LL51
	 nop
	mov	1, %o0
	call	runtime_fail, 0
	 nop
.LL51:
	sethi	%hi(active_team_size), %g1
	or	%g1, %lo(active_team_size), %g1
	ld	[%g1], %g1
	cmp	%g1, 1
	be	.LL58
	 nop
.LL52:
	ld	[%fp-8], %g1
	sethi	%hi(barrier_sense), %g2
	or	%g2, %lo(barrier_sense), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	xor	%g1, 1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	sethi	%hi(barrier_sense), %g2
	or	%g2, %lo(barrier_sense), %g2
	sll	%g1, 2, %g1
	ld	[%fp-4], %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-8], %g1
	cmp	%g1, 0
	bne	.LL54
	 nop
.LL55:
	sethi	%hi(barrier_arrived), %g1
	or	%g1, %lo(barrier_arrived), %o0
	call	state_load_acquire, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	bne	.LL55
	 nop
	sethi	%hi(barrier_released), %g1
	or	%g1, %lo(barrier_released), %o0
	ld	[%fp-4], %o1
	call	state_store_release, 0
	 nop
	b	.LL57
	 nop
.LL54:
	sethi	%hi(barrier_arrived), %g1
	or	%g1, %lo(barrier_arrived), %o0
	ld	[%fp-4], %o1
	call	state_store_release, 0
	 nop
.LL56:
	sethi	%hi(barrier_released), %g1
	or	%g1, %lo(barrier_released), %o0
	call	state_load_acquire, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	bne	.LL56
	 nop
	b	.LL57
	 nop
.LL58:
	nop
.LL57:
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_barrier, .-GOMP_barrier
	.align 4
	.global parallel_runtime_shutdown
	.type	parallel_runtime_shutdown, #function
	.proc	020
parallel_runtime_shutdown:
	save	%sp, -96, %sp
	call	platform_core_id, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL60
	 nop
	mov	1, %o0
	call	runtime_fail, 0
	 nop
.LL60:
	sethi	%hi(region_active), %g1
	or	%g1, %lo(region_active), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	be	.LL61
	 nop
	mov	4, %o0
	call	runtime_fail, 0
	 nop
.LL61:
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	call	state_load_acquire, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL62
	 nop
	mov	4, %o0
	call	runtime_fail, 0
	 nop
.LL62:
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	mov	3, %o1
	call	state_store_release, 0
	 nop
.LL63:
	sethi	%hi(mailbox+8), %g1
	or	%g1, %lo(mailbox+8), %o0
	call	state_load_acquire, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 4
	bne	.LL63
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	parallel_runtime_shutdown, .-parallel_runtime_shutdown
	.align 4
	.global GOMP_atomic_start
	.type	GOMP_atomic_start, #function
	.proc	020
GOMP_atomic_start:
	save	%sp, -96, %sp
	sethi	%hi(atomic_lock), %g1
	or	%g1, %lo(atomic_lock), %o0
	call	platform_lock_acquire, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_atomic_start, .-GOMP_atomic_start
	.align 4
	.global GOMP_atomic_end
	.type	GOMP_atomic_end, #function
	.proc	020
GOMP_atomic_end:
	save	%sp, -96, %sp
	sethi	%hi(atomic_lock), %g1
	or	%g1, %lo(atomic_lock), %o0
	call	platform_lock_release, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_atomic_end, .-GOMP_atomic_end
	.align 4
	.global GOMP_critical_start
	.type	GOMP_critical_start, #function
	.proc	020
GOMP_critical_start:
	save	%sp, -96, %sp
	sethi	%hi(critical_lock), %g1
	or	%g1, %lo(critical_lock), %o0
	call	platform_lock_acquire, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_critical_start, .-GOMP_critical_start
	.align 4
	.global GOMP_critical_end
	.type	GOMP_critical_end, #function
	.proc	020
GOMP_critical_end:
	save	%sp, -96, %sp
	sethi	%hi(critical_lock), %g1
	or	%g1, %lo(critical_lock), %o0
	call	platform_lock_release, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_critical_end, .-GOMP_critical_end
	.ident	"GCC: (GNU) 4.4.3"
