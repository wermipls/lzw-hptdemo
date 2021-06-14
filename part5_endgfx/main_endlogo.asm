	MODULE endgfx
endok
	org ANIM_DATA_END.end, 3
display:
	; depack data
	ld hl, gfx_packed
	ld de, gfx_unpacked
	call APLIB.depack

	;stripe loop
	halt
	ld a, 23
	ld (DrawVerticalStripe.stripeIterations), a
	ld b, 31
	ld hl, gfx_unpacked+31*192
	ld de, -192
.stripeloop
	push bc
	push hl
	push de
	call DrawVerticalStripe
	pop de
	pop hl
	pop bc
	add hl, de ; offset
	ld a, b
	and 00000111b
	jr z, .halt
	djnz .stripeloop

	ld de, 0;0100011101000111b
	ld hl, $5b00
	call fast_attrib_fill
	
	ei
	ret
.halt
	ei
	halt
	djnz .stripeloop
gfx_packed:
	INCBIN "endlogo_correct.aplib"
gfx_unpacked:
	;INCLUDE "endlogo.ASM"
	;SAVEBIN "endlogo_correct.bin", gfx_unpacked, 6144
	org endok, 0


	ENDMODULE
