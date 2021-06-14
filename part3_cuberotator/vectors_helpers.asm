backface_test
	inc ix
.backface_test_loop
	ld b, 0
	; v2.x - v1.x
	ld hl, vertices_rotated
.smc_last_vert1 = $+2
	ld c, (ix+2) ; 2nd vertex
	add hl, bc
	ld a, (hl)
	ld hl, vertices_rotated
	ld c, (ix+1) ; 1st vertex
	add hl, bc
	ld c, (hl)
	srl a ; avoid overflow
	srl c
	sub c
	ld d, a ; store result
	; v0.y - v1.y
	ld hl, vertices_rotated
	ld c, (ix+0) ; 0th vertex
	inc c ; y coord
	add hl, bc
	ld a, (hl)
	ld hl, vertices_rotated
	ld c, (ix+1) ; 1st vertex
	inc c ; y coord
	add hl, bc
	ld c, (hl)
	srl a ; avoid overflow
	srl c
	sub c
	ld e, a ; store result
	ex de, hl
	call multi.multiply_signed
	; d = (v2.x - v1.x)*(v0.y - v1.y)
	; temporarily store the value
	ld (ix-1), d

	ld b, 0
	; v2.y - v1.y
	ld hl, vertices_rotated
.smc_last_vert2 = $+2
	ld c, (ix+2) ; 2nd vertex
	inc c ; y coord
	add hl, bc
	ld a, (hl)
	ld hl, vertices_rotated
	ld c, (ix+1) ; 1st vertex
	inc c ; y coord
	add hl, bc
	ld c, (hl)
	srl a ; avoid overflow
	srl c
	sub c
	ld d, a ; store result
	; v0.x - v1.x
	ld hl, vertices_rotated
	ld c, (ix+0) ; 0th vertex
	add hl, bc
	ld a, (hl)
	ld hl, vertices_rotated
	ld c, (ix+1) ; 1st vertex
	add hl, bc
	ld c, (hl)
	srl a ; avoid overflow
	srl c
	sub c
	ld e, a ; store result
	ex de, hl
	call multi.multiply_signed
	; d = (v2.y - v1.y)*(v0.x - v1.x)
	; lets perform subtraction
	ld a, (ix-1)
	sub d
	
	dec a
	
	and 10000000b
	ld (ix-1), a ; save real result

	inc ix
	ld a, (current.vert_per_face)
	ld c, a
.ix_adjust_loop
	inc ix
	dec c
	jp nz, .ix_adjust_loop
	dec iyl
	jp nz, .backface_test_loop
	ret

; hl - vertex pointer
; c - x coord
TranslateX:
	ld de, (current.vertcount)
	ld a, (de)
	ld b, a
	ld de, 3 ; offset
.loop
	ld a, (hl)
	add c
	ld (hl), a
	add hl, de
	djnz .loop
	ret

; hl - vertex pointer
GetExtrema:
	; old extrema
	ld bc, (extrema.min)
	ld de, (extrema.max)
	ld (extrema_old.min), bc
	ld (extrema_old.max), de
	ld de, (current.vertcount)
	ld a, (de)
	ld ixl, a
	dec ixl
	; bc - x1, y1
	; de - x2, y2
	; initial vals
	ld b, (hl)
	ld d, (hl)
	inc hl
	ld c, (hl)
	ld e, (hl)
	inc hl
	inc hl
.loop
	ld a, (hl) ; new x val
	cp b ; min val
	jp nc, .skipminx
	; val is smaller, lets update
	ld b, a
.skipminx
	cp d ; max val
	jp c, .skipmaxx
	; val is bigger, lets update
	ld d, a
.skipmaxx
	inc hl
	ld a, (hl) ; new y val
	cp c ; min val
	jp nc, .skipminy
	; val is smaller, lets update
	ld c, a
.skipminy
	cp e ; max val
	jp c, .skipmaxy
	; val is bigger, lets update
	ld e, a
.skipmaxy
	inc hl
	inc hl
	dec ixl
	jp nz, .loop
	; adjust for chars (bcuz thats what we need)
	; b
	ld a, b
	rra
	rra
	rra
	and 00011111b
	ld b, a
	; c
	ld a, c
	rra
	rra
	rra
	and 00011111b
	ld c, a
	; d
	ld a, d
	rra
	rra
	rra
	and 00011111b
	ld d, a
	; e
	ld a, e
	rra
	rra
	rra
	and 00011111b
	ld e, a
	ld (extrema.min), bc
	ld (extrema.max), de
	ret

ScreenCheck:
	; lets check if using shadow screen
	 ; normal variant
	ld a, (paging.port_backup)
	bit 3, a
	jr z, .screen_zero
	ld a, 5 ; normal screen
	call paging.set_bank
	jr .screen_done
.screen_zero
	ld a, 7 ; shadow screen
	call paging.set_bank
.screen_done
	ret