; variable width font rendering

; draws a 8x16 character, rotates the gfx on the fly
; as i am extremely smart, i am going to write a new routine
; from scratch instead of modifying the old one 
; b - x position (pixels)
; c - y position (chars). 0-23 plz
; hl - chara gfx pointer
DrawCharacter:
	push hl ; preserve
	; shift iterations
	ld a, 00000111b ; mask
	and b
	ld ixl, a ; store for later
	; char position 
	srl b ; divide by 8
	srl b
	srl b
	; get initial screen position
	ld hl, screen_y_lut.scradtab
	ld d, 0
	ld a, c
	rlca ; multiply 8 times
	rlca
	rlca
	ld e, a
	add hl, de ; 2 times cuz word
	add hl, de
	ld a, (hl) ; low byte
	add b ; x pos
	inc hl
	ld h, (hl) ; high byte
	ld l, a
	; restore chara pointer
	pop de
	ld iyl, 8 ; loop iterations (char lines)
	ld iyh, 2 ; loop iterations overall
	ex de, hl
.draw_loop
	; fetch gfx byte
	ld c, (hl)
	inc hl
	; rotation
	; check if 0 
	xor a
	or ixl
	jp z, .noshift
	ld b, a ; loop iterations
	xor a ; clear a
.shiftloop
	srl c
	rr a
	djnz .shiftloop
.noshift
	ex de, hl ; hl is screen now
	; 2nd byte 
	inc l
	or (hl)
	ld (hl), a
	; 1st byte
	dec l
	ld a, (hl)
	or c
	ld (hl), a
	; cool lets increment now
	inc h
	ex de, hl ; hl is gfx now
	dec iyl
	jp nz, .draw_loop
	ld iyl, 8
	; but wot if we have to adjust ???
	ld a, e
	add 32
	ld e, a
	jr c, .endadjust
	ld a, d
	sub 8
	ld d, a
.endadjust
	dec iyh
	jp nz, .draw_loop
	ret

; b - initial x position
; c - initial y position
; hl - font lut (256b aligned)
; ix - font charwidths (256b aligned)
; iy - text pointer
DrawText:
	push bc
.lineloop
	xor a
	or (iy+0)
	jr z, .end ; zero = string termination
	cp 2 ; bold
	jr z, .bold
	cp 3 ; unbold
	jr z, .unbold
	cp 10 ; newline
	jr z, .newline
	sub 32
	ld ixl, a
	sla a
	ld l, a
	; load font char addr
	ld e, (hl) ; low
	inc hl
	ld d, (hl) ; high
	push bc
	push hl
	push ix
	push iy
	ex de, hl
	call DrawCharacter
	pop iy
	pop ix
	pop hl
	pop bc
	ld a, b
	add (ix+0)
	ld b, a
	inc iy
	jp .lineloop
.newline
	pop bc
	inc c
	push bc
	inc iy
	jr .lineloop
.bold
	inc iy
	ld h, font_bold.lut/256
	ld ixh, font_bold.charwidth/256
	jr .lineloop
.unbold
	inc iy
	ld h, font_medium.lut/256
	ld ixh, font_medium.charwidth/256
	jr .lineloop
.end
	pop bc
	ret

; b - initial x position
; c - initial y position
; hl - font lut (256b aligned)
; ix - font charwidths (256b aligned)
; iy - text pointer
DrawTextLetterInit:
	ld (DrawTextLetter.screenpos_linestart), bc
DrawTextLetterSave:
	ld (DrawTextLetter.screenpos), bc
	ld (DrawTextLetter.textpos), iy
	ld (DrawTextLetter.charwidth), ix
	ld (DrawTextLetter.fontlut), hl
	ret

DrawTextLetter:
	;ld a, (GLOBAL_TIMER)
	;and 00000001b
	;jp nz, .end
	ld a, 5
	call paging.set_bank
	ld iy, (.textpos)
	ld bc, (.screenpos)
	ld ix, (.charwidth)
	ld hl, (.fontlut)
.lineloop
	xor a
	or (iy+0)
	jr z, .end ; zero = string termination
	cp 2 ; bold
	jr z, .bold
	cp 3 ; unbold
	jr z, .unbold
	cp 4 ; x offset
	jr z, .xoffset
	cp 5 ; delay
	jr z, .delay
	cp 10 ; newline
	jr z, .newline
	sub 32
	ld ixl, a
	sla a
	ld l, a
	; load font char addr
	ld e, (hl) ; low
	inc hl
	ld d, (hl) ; high
	push bc
	push hl
	push ix
	push iy
	push de
	ex de, hl
	call DrawCharacter
	ld a, 7
	call paging.set_bank
	pop hl
	pop iy
	pop ix
	pop de
	pop bc
	push bc
	push de
	push ix
	push iy
	call DrawCharacter
	pop iy
	pop ix
	pop hl
	pop bc
	ld a, b
	add (ix+0)
	ld b, a
	inc iy
	; done
	jp DrawTextLetterSave
.end
	ret
.xoffset
	inc iy
	inc iy
	ld b, (iy-1)
	jr .lineloop
.newline
	ld bc, (.screenpos_linestart)
	inc c
	ld (.screenpos_linestart), bc
	inc iy
	jr .lineloop
.bold
	inc iy
	ld h, font_bold.lut/256
	ld ixh, font_bold.charwidth/256
	jr .lineloop
.unbold
	inc iy
	ld h, font_medium.lut/256
	ld ixh, font_medium.charwidth/256
	jr .lineloop
.delay
	call DrawTextLetterSave
	ld a, (.delayval)
	cp (iy+1)
	jr z, .delaydone
	inc a
	ld (.delayval), a
	ret
.delaydone
	xor a
	ld (.delayval), a
	inc iy
	inc iy
	jp .lineloop
.delayval
	db 0
.screenpos
	dw 0
.screenpos_linestart
	dw 0
.textpos
	dw 0
.charwidth
	dw 0
.fontlut
	dw 0
; hl - initial font addr
; bc - increment
; de - destination
; ixl - loop iterations
GenerateFontLUT:
.loop
	ex de, hl
	ld (hl), e ; low byte
	inc hl
	ld (hl), d ; high byte
	inc hl
	ex de, hl
	add hl, bc ; offset
	dec ixl
	jp nz, .loop
	ret