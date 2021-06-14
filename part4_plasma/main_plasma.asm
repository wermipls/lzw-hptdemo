; reminder: plasma data is on bank 4

	MODULE plasma
ScaledSin equ $C000
RawPlasma equ ANIM_UNPACKED
SineAdjusted equ ((RawPlasma+32*48+256)/256)*256 ; 256b aligned
DitherLookupEven equ SineAdjusted+256
DitherLookupOdd equ DitherLookupEven+256


precalc_sine:
	ld a, 4
	call paging.set_bank
	jp PrecalcScaledSine
precalc_sine2:
	ld a, 6
	call paging.set_bank
	jp PrecalcScaledSine
precalc_other:
	ld hl, dither_unadjusted
	ld de, DitherLookupEven
	call PrecalcDitherLUT

	inc hl
	ld de, DitherLookupOdd
	call PrecalcDitherLUT
	jp PrecalcAdjustedSine
precalc_other_fadein:
	ld hl, dither_unadjusted
	ld de, DitherLookupEven+512
	call PrecalcDitherLUT

	inc hl
	ld de, DitherLookupOdd+512
	call PrecalcDitherLUT
	jp PrecalcAdjustedSine

init:
	ld ix, ScaledSin
	ld iy, SineAdjusted
	ret

loop_calc:
	; some setup
	push ix ; preserve original
	push iy
	ld de, RawPlasma ; destination
	push de
.smc_linecount = $+1
	ld a, 48 ; line count
	ex af ; a is free now
	; lets derive vertical table from global time
	; because. why not
	;ld de, SineAdjusted
	;ld hl, (GLOBAL_TIMER)
	;rr h
	;rr l
	;rr h
	;rr l
	;ld h, ScaledSin/256

	;add hl, de ; add table index
	; now hl = pointer to vertical sin
	;ex de, hl
	;ld iy, 0
	;add iy, de ; lets save for later
	ex af ; to compensate for the next one
.line_loop
	ex af
;.smc_bytecount = $+1
	ld a, (GLOBAL_TIMER)
	rla
	ld b, a
	;ld b, 32 ; byte loop count
	;inc iyl
	dec iyl
	dec iyl
	;dec iyl
	ld c, (iy+0) ; fetch vertical sin value
	; we are going to fetch sine val to use as index
	; to horz sine table
	ld a, (ix+0) ; sine val
	srl a
	;srl a
	ld hl, ScaledSin
	add a, h
	ld h, a
	;add hl, de ; add table index
	; now hl = pointer to horizontal sin
	pop de ; restore destination addr
.smc_bytecount_jp = $+1
	jp .byte_loop
.byte_loop:
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
.byte_loop_12b
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de
	ld a, c ; fetch y sin
	add a, b ; offset
	add a, (hl); add x sin
	ld (de), a
	inc hl
	inc de




	push de
	inc ixl
	ex af
	dec a
	jp nz, .line_loop
	pop af
	pop iy
	pop ix
.smc_increment_call = $+1
	jp .ixiy_increment_one
	; ret is done in function
.ixiy_increment_one:
	inc ixl
	inc iyl
	inc iyl
	inc iyl
	ret
.ixiy_increment_two:
	dec ixl
	dec ixl
	dec ixl
	dec iyl
	dec iyl
	ret
.ixiy_increment_four:
	inc iyl
	inc iyl
	;inc iyl
	;inc iyl
	;inc iyl
	;inc iyl
	dec ixl
	;dec ixl
	dec ixl
	;dec ixl
	;dec ixl
	;dec ixl
	ret
.ixiy_increment_three:
	dec iyl
	dec iyl
	;dec iyl
	ld hl, .threecount
	dec (hl)
	jp nz, .noinc_ixl
	dec ixl
	ld (hl), 2
.noinc_ixl
	ret
.threecount
	db 2

; bc - pointer to dither lut (odd or even)
; ix - pointer to screen lut
draw_loop:
	;init
	ld hl, RawPlasma
	ld iyh, 48 ; line count
.line_loop
	ld e, (ix+0) ; screen position
	ld d, (ix+1)
	ld iyl, 4
.byte_loop
	; partial unroll
	; byte 1
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 2
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 3
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 4
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 5
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 6
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 7
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 8
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	dec iyl
	jp nz, .byte_loop
	ld de, 8 ; line offset
	add ix, de
	dec iyh
	jp nz, .line_loop
	ret

full_loop:
	ld iy, (.iy)
	ld ix, (.ix)
	call plasma.loop_calc
	ld (.ix), ix
	ld (.iy), iy

	ld a, 5
	call paging.set_bank
	;di
	halt
	ld bc, plasma.DitherLookupEven
	ld ix, screen_y_lut.scradtab
	call plasma.draw_loop
	;halt
	ld bc, plasma.DitherLookupOdd
.smc_scanline_offset = $+2
	ld ix, screen_y_lut.scradtab+4
	jp plasma.draw_loop
	; ret is in function 
.ix
	dw 0
.iy
	dw 0

dither_unadjusted:
	db 00000000b ;0 - darkest
	db 00000000b
	db 00001000b ;1
	db 00000000b
	db 10001000b ;2
	db 00000000b
	db 10000010b ;3
	db 00010000b
	db 10001000b ;4
	db 00100010b
	db 01010101b ;5
	db 00100010b
	db 01010101b ;6 - mid
	db 10101010b
	db 01010101b ;7 
	db 10111011b
	db 11101110b ;8
	db 10111011b
	db 11111110b ;9
	db 10110111b
	db 11101110b ;10
	db 11111111b
	db 11101111b ;11
	db 11111111b
	db 11111111b ;12 - brightest
	db 11111111b

	INCLUDE "plasma_extrafx.asm"
	INCLUDE "plasma_precalc.asm"
	ENDMODULE