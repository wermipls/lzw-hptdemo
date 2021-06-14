; test
; c - loop iterations
; de - screen start address
; hl - source
;AnimationCopyFrame:
;	; init
;	di
;.loop
;	; 20 iterations
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	ldi
;	; adjust position
;	ld a, e
;	sub 20
;	ld e, a
;	inc d
;	; check if we crossed the boundary
;	ld a, d
;	and 00000111b
;	jr nz, .preloop ; if not, continue loop
;	; else adjust position
;	ld a, e
;	add a, 32
;	ld e, a
;	jr c, .preloop ; if past the last line in a char, adjust
;	ld a, d
;	sub 8
;	ld d, a
;	jr .preloop
;.preloop
;	ld a, b
;	or c
;	jr nz, .loop
;	ret
; hl - src
; de - destination
;AnimationCopyDiff:
;	; init
;	ld b, 20
;	;ld de, $4006
;.loop
;	; read command
;	ld a, (hl)
;	or a ; test
;	jr nz, .copy
;	; if zero
;	inc hl
;	inc e
;	jr .preloop
;.copy
;	; note: this is pretty slow
;	inc hl
;	; 1st
;	ld a, (hl)
;	ld (de), a
;	inc d
;	inc hl
;	; 2nd
;	ld a, (hl)
;	ld (de), a
;	inc d
;	inc hl
;	; 3rd
;	ld a, (hl)
;	ld (de), a
;	inc d
;	inc hl
;	; 4th
;	ld a, (hl)
;	ld (de), a
;	inc d
;	inc hl
;	; 5th
;	ld a, (hl)
;	ld (de), a
;	inc d
;	inc hl
;	; 6th
;	ld a, (hl)
;	ld (de), a
;	inc d
;	inc hl
;	; 7th
;	ld a, (hl)
;	ld (de), a
;	inc d
;	inc hl
;	; 8th
;	ld a, (hl)
;	ld (de), a
;	inc d
;	inc hl
;	; adjust
;	ld a, d
;	sub 8
;	ld d, a
;	inc e
;.preloop
;	; check if clipping
;	ld a, e
;	add a, 6
;	and 00011111b
;	jr nz, .loop ; if so, adjust
;	ld a, e
;	add a, 12
;	ld e, a
;	jr nc, .preloop2 ; if past the last line in a char, adjust
;	ld a, d
;	add a, 8
;	ld d, a
;.preloop2
;	djnz .loop
;	ret

; WARNING - redirects stack
; make sure interrupts are disabled or the interrupt handler redirects the stack itself
; hl - src
; de - destination
AnimationParseCopyData:
	; init
	push ix ; preserve
	ld (.saveSP), sp 

	ld bc, hl ; preserve original
	ld sp, 400 ; data offset
	add hl, sp ; add offset
	ld sp, hl ; into sp
	ld hl, bc ; restore 

	ld ixl, 20 ; loop iterations
.loop
	; read command
	ld a, (hl)
	inc hl
	or a ; test
	jr nz, .copy
	; if zero
	inc e
	jr .preloop
.copy
	ex de, hl
	; 1st iteration, copy 2 bytes
	pop bc
	ld (hl), c
	inc h
	ld (hl), b
	inc h
	; 2nd
	pop bc
	ld (hl), c
	inc h
	ld (hl), b
	inc h
	; 3rd
	pop bc
	ld (hl), c
	inc h
	ld (hl), b
	inc h
	; 4th
	pop bc
	ld (hl), c
	inc h
	ld (hl), b
	inc h

	ex de, hl
	; adjust
	ld a, d
	sub 8
	ld d, a
	inc e

.preloop
	; check if clipping
	ld a, e
	add a, 6
	and 00011111b
	jr nz, .loop ; if so, adjust
	ld a, e
	add a, 12
	ld e, a
	jr nc, .preloop2 ; if past the last line in a char, adjust
	ld a, d
	add a, 8
	ld d, a
.preloop2
	dec ixl
	jr nz, .loop
.saveSP = $+1
	ld sp, 0 ; restore sp
	pop ix ; restore ix
	ret
	