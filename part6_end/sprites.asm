DrawEndSprites:
	ld a, 4
	ld de, sprites
	ld ixl, 11
.loop
	push af
	call YesIAmWritingTheSameCodeForMillionthTime
	pop af
	inc a
	dec ixl
	jp nz, .loop
	call CopySpriteAttributes
	ret


; a - x position
; de - src
YesIAmWritingTheSameCodeForMillionthTime:
	ld hl, $C8A0 ; 13th char y
	add a, l
	ld l, a
	ld c, 7 ; chars amt
.charloop
	ld b, 8
.byteloop
	; fetch
	ld a, (de)
	ld (hl), a
	inc h
	inc de
	djnz .byteloop
	; next char pos calculation
	ld a, 32
	add a, l
	ld l, a
	jr c, .afteradj
	ld a, h
	sub 8
	ld h, a
.afteradj
	dec c
	jr nz, .charloop
	ret

CopySpriteAttributes:
	ld hl, $D800 + 13*32 + 4
	ld b, 0
	ld ixl, 7
.loop
	ex de, hl
	ld c, 11
	ldir
	ex de, hl
	ld c, 32-11
	add hl, bc
	dec ixl
	jp nz, .loop
	ret

sprites:
	INCBIN "sprites2.BIN"
