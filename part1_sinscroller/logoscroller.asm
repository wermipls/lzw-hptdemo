; draws 20 logo stripes
; ix - sintable pointer (set in call)
; hl - stripesypos table pointer (set in call)
; de - logo pointer
; b - x position 
; c - y position (internal)
; iyl - iteration counter 
DrawLogoStripes:
	ld b, 6		; x position
	ld iyl, 20	; iteration counter
	ld de, logo_test
	ld hl, .stripesYpos
	ld ix, (.sinIndex)
.stripes:
	; getting sin table value
	ld a, 243
	add a, ixl
	ld ixl, a

	ld c, (ix+0)
	ld a, 1 ; y position offset
	add a, c
	cp (hl) ; check if value identical
	jr z, .noRedraw ; if so, skip

	ld c, a ; store y value
	ld (hl), a

	push bc
	push de
	push hl 
	push ix
	
	ex de, hl
	call DrawVerticalStripe
	;call YetAnotherSpriteRoutineAdjustedForStripes

	pop ix
	pop hl
	pop de
	pop bc
.noRedraw
	; increment x position
	inc b
	inc hl ; inc table pointer

	; add 64 to gfx pointer
	;ld a, 64 
	ld a, 72 ; HAHA NOT ANYMORE
	add a, e
	ld e, a
	ld a, 0
	adc a, d
	ld d, a

	; decrement counter
	dec iyl
	jr nz, .stripes

	ld (.sinIndex), ix ; preserve index
	ret
.sinIndex
	BLOCK 2
.stripesYpos
	BLOCK 20
; not sure yet
UpdateTextScroller:
	di
	; preserve those shits
	push ix
	; load vals
	ld hl, font_lut
	ld de, (.textPtr)
	ld ix, .counter
	ld c, (ix+0)
	; check if string termination
	ld a, (de)
	cp 1
	jr z, .terminator
	; decrement and check for overflow
	dec c
	ld a, c
	cp 255
	jr nz, .nc
	; adjust
	ld c, 3
	inc de
	; check if string termination
	ld a, (de)
	cp 1
	jr nz, .nc
	ld hl, $5040
	call FastClear
	jr nz, .terminator
.nc
	; save vals and do stuff
	ld (.textPtr), de
	ld (ix+0), c
	pop ix

	push ix
	push iy
	call DrawTextScroller
	pop iy
	pop ix

	; update sin table
	ld a, 249
	add a, iyl
	ld iyl, a

	ret
.terminator
	pop ix
	ret
.counter
	db 3
.textPtr
	dw assets_scrollertext+1
