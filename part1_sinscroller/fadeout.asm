FadeoutScroller:
	ld c, 20
	ld iy, FadeoutScroller.data
	ld de, 32
	ld hl, $5806
.column_loop
	push hl
	ld a, (iy+0)
	dec a
	cp 8
	jr nc, .no_change
	ld b, 10
.attrib_loop
	ld (hl), a
	add hl, de
	djnz .attrib_loop
.no_change
	ld (iy+0), a
	inc iy
	pop hl
	inc hl
	dec c
	jp nz, .column_loop
	ret
.data:
	db 28,27,26,25,24,23,22,21,20,19
	db 18,17,16,15,14,13,12,11,10,9