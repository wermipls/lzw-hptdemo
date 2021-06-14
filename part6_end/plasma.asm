	module plasma_alt
; bc - pointer to dither lut (odd or even)
; ix - pointer to screen lut
draw_loop:
	;init
	ld hl, plasma.RawPlasma
	ld iyh, 48 ; line count
.line_loop
	ld a, (ix+0) ; screen position
	add 20
	ld e, a
	ld d, (ix+1)
	ld iyl, 1
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
	; byte 9
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 10
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 11
	ld c, (hl) ; fetch lut position
	ld a, (bc) ; fetch byte
	ld (de), a ; save to destination
	inc e
	inc hl
	; byte 12
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

attrib_draw_loop:
	;init
	ld hl, plasma.RawPlasma
	ld iyh, 24 ; line count
	ld de, $D800
.line_loop
	ld a, 20 ; screen position
	add a, e
	ld e, a
	ld a, 0
	adc a, d
	ld d, a
	ld iyl, 12/2
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
	inc de
	inc hl
	dec iyl
	jp nz, .byte_loop
	ld a, 12
	add a, l
	ld l, a
	ld a, 0
	adc a, h
	ld h, a
	dec iyh
	jp nz, .line_loop
	ret


full_loop:
	ld iy, (.iy)
	ld ix, (.ix)
	call plasma.loop_calc
	ld (.ix), ix
	ld (.iy), iy

	;ld a, 5
	;call paging.set_bank
	call vectys.ScreenCheck
	call draw_helper
	ret
.ix
	dw 0
.iy
	dw 0

draw_helper:
	; attrib
	ld b, attrib_lut/256
	call attrib_draw_loop
	; rest of stuff
	ld b, plasma.DitherLookupEven/256
	ld ix, screen_y_lut.scradtab
	call draw_loop
	;ld ix, screen_y_lut.scradtab+8
	;call draw_loop
	inc b
	inc b
	ld ix, screen_y_lut.scradtab+4
	call draw_loop
	;ld ix, screen_y_lut.scradtab+12
	;call draw_loop
	ld b, plasma.DitherLookupOdd/256
	ld ix, screen_y_lut.scradtab+2
	call draw_loop
	;ld ix, screen_y_lut.scradtab+10
	;call draw_loop
	inc b
	inc b
	ld ix, screen_y_lut.scradtab+6
	call draw_loop
	;ld ix, screen_y_lut.scradtab+14
	;jp draw_loop

; hl - dither pointer
; de - destination
PrecalcDitherLUT:
	xor a
	ex af
	xor a
	ld ixl, 3
.total_loop
	ld b, 16
	ld a, (hl)
.loop
	ld (de), a
	inc de
	ex af
	add a, 96 ; error
	jp nc, .noinc
	inc hl : inc hl : inc hl : inc hl ; +=4
	ex af
	ld a, (hl)
	djnz .loop
	jp .doneinc
.noinc
	ex af
	jp .loop
.doneinc
	ld b, 16
	ld a, (hl)
.loop2
	ld (de), a
	inc de
	ex af
	add a, 96 ; error
	jp nc, .nodec
	dec hl : dec hl : dec hl : dec hl ; +=4
	ex af
	ld a, (hl)
	djnz .loop2
	jp .donedec
.nodec
	ex af
	jp .loop2
.donedec
	dec ixl
	jp nz, .total_loop
	ret

	align 256
attrib_lut:
	;block 43, 00011010b 
	;block 43, 00110010b 
	;block 42, 00110100b 
	;block 43, 00101100b 
	;block 43, 00101001b 
	;block 42, 00011001b 
	block 3,  00011011b 
	block 40, 00011010b 
	block 3,  00010010b 
	block 40, 00110010b 
	block 2,  00110110b
	block 40, 00110100b 
	block 3,  00100100b
	block 40, 00101100b 
	block 3,  00101101b
	block 40, 00101001b 
	block 2,  00001001b
	block 40, 00011001b 
dither:
	db 00000000b ;0 - darkest
	db 00000000b
	db 00000000b
	db 00000000b
	db 10001000b ;1
	db 00000000b
	db 00000000b
	db 00000000b
	db 10001000b ;2
	db 00000000b
	db 00100010b
	db 00000000b
	db 10001000b ;3
	db 00000000b
	db 10101010b
	db 00000000b
	db 10101010b ;4
	db 00000000b
	db 10101010b
	db 00000000b
	db 10101010b ;5
	db 00010001b
	db 10101010b
	db 00000000b
	db 10101010b ;6
	db 00010001b
	db 10101010b
	db 01000100b
	db 10101010b ;7
	db 00010001b
	db 10101010b
	db 01010101b
	db 10101010b ;8 - mid
	db 01010101b
	db 10101010b
	db 01010101b
	db 10101010b ;9
	db 11011101b
	db 10101010b
	db 01010101b
	db 10101010b ;10
	db 11011101b
	db 10101010b
	db 01110111b
	db 10101010b ;11
	db 11011101b
	db 10101010b
	db 11111111b
	db 10101010b ;12
	db 11111111b
	db 10101010b
	db 11111111b
	db 10111011b ;13
	db 11111111b
	db 10101010b
	db 11111111b
	db 10111011b ;14
	db 11111111b
	db 11101110b
	db 11111111b
	db 10111011b ;15
	db 11111111b
	db 11111111b
	db 11111111b
	db 11111111b ;16
	db 11111111b
	db 11111111b
	db 11111111b
	endmodule

