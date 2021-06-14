; bezier calculation fixed for 16 (17) steps
; adapted from https://github.com/maxharris9/bezier-forward-diff
; inputs:
; ix - input values (expected 4)
; de - destination (expected 17, 8b aligned)
CalculateBezier:
	;ld iy, .vars
	exx ; preserve de
	xor a ; may be useful later on
	ld h, a
	ld l, a
	; compute polynomial coefficients (whatever that means)
	; a
	ld d, a
	ld e, (ix+2)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld e, (ix+0)
	add hl, de
	call .negate
	ld e, (ix+1)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld e, (ix+3)
	add hl, de
	ld (.a), hl

	; b 
	ld hl, 0
	ld e, (ix+1)
	; times six
	ld l, e 
	add hl, de
	add hl, de
	ld d, h
	ld e, l
	add hl, de
	call .negate
	; clear d cuz of previous multiplication shenanigans
	ld d, 0
	ld e, (ix+0)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld e, (ix+2)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld (.b), hl

	; c
	ld hl, 0
	ld e, (ix+0)
	add hl, de ; times three
	add hl, de
	add hl, de
	call .negate
	ld e, (ix+1)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld (.c), hl

	; now we can calculate forward differences 
	; first
	ld hl, (.a)
	ld c, h
	bit 7, c
	jp z, .no_neg_1
	call .negate
.no_neg_1
	ld a, h
	rra ; divide by 16 -> shift 4 times
	rr l
	rra ; 2
	rr l
	rra ; 3
	rr l
	rra ; 4
	rr l
	and 00001111b ; mask
	bit 7, c
	jp z, .no_neg_2
	ld h, a
	call .negate
	jr .no_neg_2+1
.no_neg_2
	ld h, a
	ld (.fd1), hl

	; we didnt finish first but heres third 
	; yea weird order but its convenient
	; cuz we're multiplying the previous result by 6
	ld d, h
	ld e, l
	add hl, de
	add hl, de
	ld d, h
	ld e, l
	add hl, de
	ld (.fd3), hl

	; second
	ld de, (.b)
	bit 7, d
	jp z, .no_neg_5
	call .negate_de
	sla e
	rl d
	call .negate_de
	jp .yes_neg
.no_neg_5
	sla e ; multiply by 2
	rl d
.yes_neg
	add hl, de
	ld (.fd2), hl

	; first again
	ld hl, (.fd1)
	ld de, (.b)
	add hl, de
	ld de, (.c)
	ld b, d
	bit 7, d
	jp z, .no_neg_3
	call .negate_de
.no_neg_3
	ld a, e
	rla ; multiply by 16 -> shift 4 times
	rl d
	rla ; 2
	rl d
	rla ; 3
	rl d
	rla ; 4
	rl d
	and 11110000b ; mask
	ld e, a
	bit 7, b
	jp z, .no_neg_4
	call .negate_de
.no_neg_4
	add hl, de
	ld (.fd1), hl

	; BABE ITS 4PM TIME FOR THE INCREMENTAL LOOP
	; hl - point
	; de - 1st fd
	; iy - 2nd fd
	; sp - 3rd fd (we can steal this for a while)

	; some setup
	ld h, (ix+0)
	ld l, 0
	;ld l, 128 ; bias for more accuracy (?)
	ld de, (.fd1)
	ld iy, (.fd2)
	di
	ld (.saveSP), sp
	ld sp, (.fd3)
	ld a, h
	exx
	ld b, 16 ; loop iterations
	ld (de), a
	inc e
	inc e
.increment_loop
	exx
	add hl, de ; point += fd1
	ex de, hl
	ld b, iyh
	ld c, iyl
	add hl, bc ; fd1 += fd2
	ex de, hl
	add iy, sp
	ld a, h
	exx
	ld (de), a
	inc e
	inc e
	djnz .increment_loop
	;ld a, (ix+3)
	;ld (de), a
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

.negate
	ld a, l
	cpl
	ld l, a
	ld a, h
	cpl
	ld h, a
	inc hl
	ret
.negate_de
	ld a, e
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
	ret
.vars
.a	dw 0 
.b	dw 0
.c	dw 0
.fd1	dw 0
.fd2	dw 0
.fd3	dw 0

; this routine is ridiculously stupid hack
CalculateBezierBackwards:
	dec e
	dec e
	dec e
	dec e
	;ld iy, .vars
	exx ; preserve de
	xor a ; may be useful later on
	ld h, a
	ld l, a
	; compute polynomial coefficients (whatever that means)
	; a
	ld d, a
	ld e, (ix+1)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld e, (ix+3)
	add hl, de
	call .negate
	ld e, (ix+2)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld e, (ix+0)
	add hl, de
	ld (.a), hl

	; b 
	ld hl, 0
	ld e, (ix+2)
	; times six
	ld l, e 
	add hl, de
	add hl, de
	ld d, h
	ld e, l
	add hl, de
	call .negate
	; clear d cuz of previous multiplication shenanigans
	ld d, 0
	ld e, (ix+3)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld e, (ix+1)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld (.b), hl

	; c
	ld hl, 0
	ld e, (ix+3)
	add hl, de ; times three
	add hl, de
	add hl, de
	call .negate
	ld e, (ix+2)
	add hl, de ; times three
	add hl, de
	add hl, de
	ld (.c), hl

	; now we can calculate forward differences 
	; first
	ld hl, (.a)
	ld c, h
	bit 7, c
	jp z, .no_neg_1
	call .negate
.no_neg_1
	ld a, h
	rra ; divide by 16 -> shift 4 times
	rr l
	rra ; 2
	rr l
	rra ; 3
	rr l
	rra ; 4
	rr l
	and 00001111b ; mask
	bit 7, c
	jp z, .no_neg_2
	ld h, a
	call .negate
	jr .no_neg_2+1
.no_neg_2
	ld h, a
	ld (.fd1), hl

	; we didnt finish first but heres third 
	; yea weird order but its convenient
	; cuz we're multiplying the previous result by 6
	ld d, h
	ld e, l
	add hl, de
	add hl, de
	ld d, h
	ld e, l
	add hl, de
	ld (.fd3), hl

	; second
	ld de, (.b)
	bit 7, d
	jp z, .no_neg_5
	call .negate_de
	sla e
	rl d
	call .negate_de
	jp .yes_neg
.no_neg_5
	sla e ; multiply by 2
	rl d
.yes_neg
	add hl, de
	ld (.fd2), hl

	; first again
	ld hl, (.fd1)
	ld de, (.b)
	add hl, de
	ld de, (.c)
	ld b, d
	bit 7, d
	jp z, .no_neg_3
	call .negate_de
.no_neg_3
	ld a, e
	rla ; multiply by 16 -> shift 4 times
	rl d
	rla ; 2
	rl d
	rla ; 3
	rl d
	rla ; 4
	rl d
	and 11110000b ; mask
	ld e, a
	bit 7, b
	jp z, .no_neg_4
	call .negate_de
.no_neg_4
	add hl, de
	ld (.fd1), hl

	; BABE ITS 4PM TIME FOR THE INCREMENTAL LOOP
	; hl - point
	; de - 1st fd
	; iy - 2nd fd
	; sp - 3rd fd (we can steal this for a while)

	; some setup
	ld h, (ix+3)
	ld l, 0
	;ld l, 128 ; bias for more accuracy (?)
	ld de, (.fd1)
	ld iy, (.fd2)
	di
	ld (.saveSP), sp
	ld sp, (.fd3)
	ld a, h
	exx
	ld b, 8 ; loop iterations
	ld (de), a
	dec e
	dec e
.increment_loop
	exx
	add hl, de ; point += fd1
	ex de, hl
	ld b, iyh
	ld c, iyl
	add hl, bc ; fd1 += fd2
	ex de, hl
	add iy, sp
	ld a, h
	exx
	ld (de), a
	dec e
	dec e
	djnz .increment_loop
	;ld a, (ix+3)
	;ld (de), a
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

.negate
	ld a, l
	cpl
	ld l, a
	ld a, h
	cpl
	ld h, a
	inc hl
	ret
.negate_de
	ld a, e
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
	ret
.vars
.a	dw 0 
.b	dw 0
.c	dw 0
.fd1	dw 0
.fd2	dw 0
.fd3	dw 0