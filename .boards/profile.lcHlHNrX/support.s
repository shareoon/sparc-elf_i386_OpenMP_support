	.file	"freestanding_stubs.c"
	.section	".text"
	.align 4
	.global memcpy
	.type	memcpy, #function
	.proc	0120
memcpy:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+68], %g1
	st	%g1, [%fp-12]
	ld	[%fp+72], %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-4]
	b	.LL2
	 nop
.LL3:
	ld	[%fp-12], %g2
	ld	[%fp-4], %g1
	add	%g2, %g1, %g1
	ld	[%fp-8], %g3
	ld	[%fp-4], %g2
	add	%g3, %g2, %g2
	ldub	[%g2], %g2
	stb	%g2, [%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL2:
	ld	[%fp-4], %g2
	ld	[%fp+76], %g1
	cmp	%g2, %g1
	blu	.LL3
	 nop
	ld	[%fp+68], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	memcpy, .-memcpy
	.ident	"GCC: (GNU) 4.4.3"
