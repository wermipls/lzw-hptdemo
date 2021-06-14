; copied verbatim from https://chuntey.wordpress.com/2010/03/22/sprite-graphics-tutorial/
screen_y_lut:	
	ld de, $C000
	ld hl, .scradtab
	ld b, 192
.lineloop:
	ld (hl), e
	inc l
	ld (hl), d
	inc hl
	inc d
	ld a, d
	and 7
	jr nz, .nextline
	ld a, e
	add a, 32
	ld e, a
	jr c, .nextline
	ld a, d
	sub 8
	ld d, a
.nextline
	djnz .lineloop
	ret
.scradtab = $6000

; WARNING: ROUTINE WILL SHIT THE BED WHEN START = END
; bc - y1, x1
; de - y2, x2
bresenham_calc_pos:
	ld a, d ; y2
	sub b ; y1
	jr nc, .positive_y 
	; reverse coords and neg diff value
	push bc
	push de
	pop bc
	pop de
	neg
.positive_y
	; a - y diff
	; bc - origin coordinates
	; need to calculate screen pos from bc
	ex af, af' ; a is free now
	; fetching y coord from LUT
	push de ; preserve
	ld de, screen_y_lut.scradtab
	ld h, 0
	ld l, b ; y coord
	add hl, hl ; multiply by 2
	add hl, de ; add offset
	ld b, (hl) ; low addr byte
	inc hl
	ld h, (hl) ; high addr byte
	pop de ; restore
	; x is easy to calculate
	; char coordinate first
	ld a, c ; x1
	rra
	rra
	rra
	and 00011111b ; mask
	add b 
	ld l, a
	; byte position now
	; gonna do smc thing even tho idk if its gna be faster on avg
	xor a
	ld d, a ; clear d
	ld a, 00000111b
	and c ; x1
	xor 00000111b
	rla
	rla
	rla
	add $c2
	ld (.smc_bit), a
.smc_bit = $+1
	set 0, d
	; cool now we can go to x diff
	ld a, e ; x2
	sub c ; x1
	jr nc, .x_positive
	neg
	ld b, a
	; check which is bigger
	ex af, af'
	cp b
	jr c, .dec_fast_x ; x bigger
	; else reverse
	ld c, b
	ld b, a
	jr .dec_fast_y
.x_positive
	ld b, a
	; check which is bigger
	ex af, af'
	cp b
	jr c, .inc_fast_x ; x bigger
	; else reverse
	ld c, b
	ld b, a
	jr .inc_fast_y
	; smc attempt
	; inc l - $2c
	; dec l - $2d
	; srl d - $3a
	; sla d - $22
.dec_fast_x
	ld c, a
	push hl
	ld hl, bresenham_sub_fast_x.smc_x_incdec
	ld (hl), $2d ; dec l
	ld hl, bresenham_sub_fast_x.smc_pixel
	ld (hl), 00000001b
	ld hl, bresenham_sub_fast_x.smc_shift
	ld (hl), $22
	pop hl
	jr bresenham_sub_fast_x
.dec_fast_y
	push hl
	ld hl, bresenham_sub_fast_y.smc_x_incdec
	ld (hl), $2d ; dec l
	ld hl, bresenham_sub_fast_y.smc_pixel
	ld (hl), 00000001b
	ld hl, bresenham_sub_fast_y.smc_shift
	ld (hl), $22
	pop hl
	jr bresenham_sub_fast_y
.inc_fast_x
	ld c, a
	push hl
	ld hl, bresenham_sub_fast_x.smc_x_incdec
	ld (hl), $2c ; inc l
	ld hl, bresenham_sub_fast_x.smc_pixel
	ld (hl), 10000000b
	ld hl, bresenham_sub_fast_x.smc_shift
	ld (hl), $3a
	pop hl
	jr bresenham_sub_fast_x
.inc_fast_y
	push hl
	ld hl, bresenham_sub_fast_y.smc_x_incdec
	ld (hl), $2c ; inc l
	ld hl, bresenham_sub_fast_y.smc_pixel
	ld (hl), 10000000b
	ld hl, bresenham_sub_fast_y.smc_shift
	ld (hl), $3a
	pop hl
	jr bresenham_sub_fast_y

; hl - screen memory pointer
; bc - relative x, relative y
; d - pixel data (normally 10000000b for leftmost pixel)
bresenham_sub_fast_x:
	; calc error
	ld a, b ; x pos
	srl a ; divide by 2
	ex af, af'

	ld e, b ; preserve x for error calc
.smc_iteration_correction
	inc b ; to get correct iteration amount
	ld a, (hl) ; fetch screen data
.pixel_loop
.smc_or_xor
	or d	; and d
	nop	; xor (hl)
	nop	; ld (hl), a
	ex af, af' ; a <- error
	; recalc error
	sub c ; relative y 
	jr nc, .skip_y_adjust
	; adjust screen pos
	add e ; relative x
	ex af, af' ; a <- pixel data
	ld (hl), a ; a is free now
	inc h ; next line 
	ld a, 00000111b ; mask
	and h ; check if crossed char boundary
	jr nz, .post_y_adjust
	; adjust position
	ld a, l
	add a, 32
	ld l, a
	jr c, .post_y_adjust
	ld a, h
	sub 8
	ld h, a
.post_y_adjust
	ld a, (hl) ; fetch new byte data
	ex af, af' ; a <- error
.skip_y_adjust
.smc_shift = $+1
	srl d ; move pixel to right
	jr z, .x_adjust ; if zero, move to next byte
	ex af, af' ; a <- pixel data
	djnz .pixel_loop
	ld (hl), a 
	jr .end
.x_adjust
.smc_pixel = $+1
	ld d, 10000000b ; new pixel 
	ex af, af' ; a <- pixel data
	ld (hl), a 
.smc_x_incdec
	inc l
	ld a, (hl) ; fetch new byte data
	djnz .pixel_loop
.end
	ret

; hl - screen memory pointer
; bc - relative y, relative x
; d - pixel data (normally 10000000b for leftmost pixel)
bresenham_sub_fast_y:
	; calc error
	ld a, b ; y pos
	srl a ; divide by 2
	ex af, af'

	ld e, b ; preserve y for error calc
.smc_iteration_correction
	inc b ; to get correct iteration amount
.pixel_loop
	ld a, (hl) ; fetch new byte data
.smc_or_xor
	or d	; and d
	nop	; xor (hl)
	ld (hl), a ; a is free now
	ex af, af' ; a <- error
	; recalc error
	sub c ; relative x
	jr nc, .skip_x_adjust
	add e ; relative y
.smc_shift = $+1
	srl d ; move pixel to right
	jr nz, .skip_x_adjust ; if zero, adjust
	; adjust x
.smc_pixel = $+1
	ld d, 10000000b ; new pixel 
.smc_x_incdec
	inc l
.skip_x_adjust
	ex af, af' ; a is free now
	inc h ; next line 
	ld a, 00000111b ; mask
	and h ; check if crossed char boundary
	jr nz, .post_y_adjust
	; adjust position
	ld a, l
	add a, 32
	ld l, a
	jr c, .post_y_adjust
	ld a, h
	sub 8
	ld h, a
.post_y_adjust
	djnz .pixel_loop
	ret

; clears char line (16b width)
fast_char_line_clear:
	ld b, 8 ; loop iterations
	;ld de, $0000 ; de - screen fill
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 20 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
	ld sp, (.saveSP)
	ret

.saveSP
	dw $0000

; hl - screen fill
clear160x160_test:
	; screen clear test
	; clear screen first
	ld bc, 6*256 + 2
	ld de, 25*256 + 2+19
	jp bounding_box_clear
	ret

	INCLUDE "clears.asm"
; hl - fill
; bc - x1, y1 (chars)
; de - x2, y2 (chars)
; de HAS to be bigger than bc
; horizontal precision only up to 2 chars
; the routine has a bug where it will skip a char line
; when the x2 is exactly 31.
bounding_box_clear:
	push hl
	; x2 - x1
	ld a, d
	sub b
	;dec a ; adjust
	and 00011110b ; mask
	ld (.smc_tablepos), a
.smc_tablepos = $+1
	ld hl, (.table)
	ld (.smc_clear), hl
	; y2 - y1
	ld a, e
	sub c
	inc a
	ld ixl, a ; loop iterations
	ld a, c ; y1
	ld c, d ; preserve x2
	ld d, 0
	rla ; multiply by 16
	rl d
	rla
	rl d
	rla
	rl d
	rla
	rl d
	and 11111000b ; mask
	ld e, a
	ld hl, screen_y_lut.scradtab
	add hl, de
	ld a, c ; x2
	;inc a
	add a, (hl) ; low byte
	inc hl
	ld h, (hl) ; high byte
	ld l, a
	inc hl

	pop de ; fill
.clear_loop
	push hl
.smc_clear = $+1
	call clear_2b
	pop hl
	ld a, l
	add 32
	ld l, a
	jr nc, .loopend
	ld a, h
	add 8
	ld h, a
.loopend
	dec ixl
	jp nz, .clear_loop
	ret

	align 256
.table:
	dw clear_2b
	dw clear_4b
	dw clear_6b
	dw clear_8b
	dw clear_10b
	dw clear_12b
	dw clear_14b
	dw clear_16b
	dw clear_18b
	dw clear_20b
	dw clear_22b
	dw clear_24b
	dw clear_26b
	dw clear_28b
	dw clear_30b
	dw clear_32b
