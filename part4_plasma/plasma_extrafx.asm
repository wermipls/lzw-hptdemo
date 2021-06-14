; put this in the interrupt handler
CopyDither:
	ld a, (.pos)
	ld d, DitherLookupEven/256
	ld h, DitherLookupEven/256+2
	ld e, a
	ld l, a
	ld a, (hl)
	ld (de), a
	inc l
	inc e
	ld a, (hl)
	ld (de), a	
	inc d
	inc h
	ld a, (hl)
	ld (de), a
	ld a, e
	inc a
	ld (.pos), a
	dec e
	dec l
	ld a, (hl)
	ld (de), a
	ret
.pos
	db 85*2;85

ClearDither:
	ld a, (.pos)
	; even
	ld d, DitherLookupEven/256
	ld h, d
	ld l, a
	inc a
	ld e, a
	xor a
	ld (hl), a
	ld bc, 3
	ldir
	ld a, (.pos)
	; odd
	ld d, DitherLookupOdd/256
	ld h, d
	ld l, a
	inc a
	ld e, a
	xor a
	ld (hl), a
	ld bc, 3
	ldir
	ld a, e
	ld (.pos), a
	ret
.pos
	db 0

ChangeColor:
	ld a, 7
	call paging.set_bank
	;ld a, (GLOBAL_TIMER)
	;inc a
	;and 00001111b
	;jr z, .alt

	;ld a, (GLOBAL_TIMER)
	;and 00001111b
	;jr nz, .end
	ld hl, (.pos)
	ld d, (hl)
	ld e, d
	inc hl
	ld a, l
	cp .attribdata_end%256
	jp nz, .noadjust
	ld hl, .attribdata
.noadjust
	ld (.pos), hl
	call .cgattrib_border
.end
	ret
.alt
	ld a, 0
	out (254), a
	ret
.cgattrib_border
	ld hl, $DB00
	call fast_attrib_fill
	;ld a, d
	;rra
	;rra
	;rra
	;and 00000111b
	;out (254), a
	ret
.pos
	dw .attribdata
.attribdata
	; all bright
	db 01000001b
	db 01000001b

	db 01000011b
	db 01000001b

	db 01000011b
	db 01000011b

	db 01000010b
	db 01000011b

	db 01000010b
	db 01000010b

	db 01000110b
	db 01000010b

	db 01000110b
	db 01000110b

	db 01000100b
	db 01000110b

	db 01000100b
	db 01000100b

	db 01000101b
	db 01000100b

	db 01000101b
	db 01000101b
	
	db 01000001b
	db 01000101b
	; 1 dark
	db 00000001b
	db 01000001b

	db 00000011b
	db 01000001b

	db 00000011b
	db 01000011b

	db 00000010b
	db 01000011b

	db 00000010b
	db 01000010b

	db 00000110b
	db 01000010b

	db 00000110b
	db 01000110b

	db 00000100b
	db 01000110b

	db 00000100b
	db 01000100b

	db 00000101b
	db 01000100b

	db 00000101b
	db 01000101b
	
	db 00000001b
	db 01000101b
	; all dark
	db 00000001b
	db 00000001b

	db 00000011b
	db 00000001b

	db 00000011b
	db 00000011b

	db 00000010b
	db 00000011b

	db 00000010b
	db 00000010b

	db 00000110b
	db 00000010b

	db 00000110b
	db 00000110b

	db 00000100b
	db 00000110b

	db 00000100b
	db 00000100b

	db 00000101b
	db 00000100b

	db 00000101b
	db 00000101b
	
	db 00000001b
	db 00000101b
	; 1 dark
	db 00000001b
	db 01000001b

	db 00000011b
	db 01000001b

	db 00000011b
	db 01000011b

	db 00000010b
	db 01000011b

	db 00000010b
	db 01000010b

	db 00000110b
	db 01000010b

	db 00000110b
	db 01000110b

	db 00000100b
	db 01000110b

	db 00000100b
	db 01000100b

	db 00000101b
	db 01000100b

	db 00000101b
	db 01000101b
	
	db 00000001b
	db 01000101b
.attribdata_end
	/*
	db 01000001b
	db 01000001b

	db 01000011b
	db 01000001b

	db 01000011b
	db 01000011b

	db 01000010b
	db 01000011b

	db 01000010b
	db 01000010b

	db 01000110b
	db 01000010b

	db 01000110b
	db 01000110b

	db 01000100b
	db 01000110b

	db 01000100b
	db 01000100b

	db 01000101b
	db 01000100b

	db 01000101b
	db 01000101b
	
	db 01000001b
	db 01000101b
	;


	db 01000011b
	;
	db 01011110b
	db 01011110b
	db 01011110b
	db 01011110b
	db 01011110b
	db 01011110b
	db 01011110b
	db 01011110b
	;
	db 00111001b
	db 00111001b
	db 00111001b
	db 00111001b
	db 00111001b
	db 00111001b
	db 00111001b
	db 00111001b

	db 01001111b
	db 01001101b
	db 01001100b
	db 01001110b
	db 01001010b
	db 01001111b
	db 01001111b
	db 01001111b






	db 01001111b
	db 00001110b
	db 01001101b
	db 00001110b
	db 01001100b
	db 00001010b
	db 01001000b
	db 00001000b
	;
	db 01001111b
	db 00001110b
	db 01001101b
	db 00001110b
	db 01001100b
	db 00001010b
	db 01001000b
	db 00001000b
	;
	db 01001111b
	db 00001110b
	db 01001101b
	db 00001110b
	db 01001100b
	db 00001010b
	db 01001000b
	db 00001000b
	;
	db 01001111b
	db 00001110b
	db 01001101b
	db 00001110b
	db 01001100b
	db 00001010b
	db 01001000b
	db 00001000b
	;
	*/