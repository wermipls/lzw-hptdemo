; since part 1 is done we can overwrite the data it used
;BorderLogo equ PART1_SINSCROLLER_ASSETS
BorderLogo equ ANIM_UNPACKED
BorderLogoAttrib equ BorderLogo+1152
BorderText equ BorderLogoAttrib+144
BorderAttrib equ BorderText+320

CopyBorderPixels:
	; init screen
	ld d, 01000111b ; attrib data
	ld e, d
	ld hl, $DB00-$8000
	call fast_attrib_fill

	; switch page
	ld a, 1
	call paging.set_bank
	; decompress data
	ld hl, BorderCompressed
	ld de, BorderLogo
	call APLIB.depack

	; change stripe height
	ld a, 23 ; 192/8-1
	ld (DrawVerticalStripe.stripeIterations), a

	ld iyl, 6 ; iterations
	ld bc, 0 ; position (0,0)
	ld hl, BorderLogo
	halt
	call StripeLoop
	ei
	; text
	; change stripe height
	ld a, 1 ; 16/8-1
	ld (DrawVerticalStripe.stripeIterations), a
	; change offset
	ld a, 16
	ld (StripeLoop.smc_offset), a

	ld iyl, 20 ; iterations
	ld bc, 256*6 ; position (48,0)
	ld hl, BorderText
	halt
	call StripeLoop
	ei

	; reverse part of the border TEST
	call CopyInverseFirst
	call CopyInverseSecond

	; attribs
	ld hl, $5800
	ld de, BorderLogoAttrib
	ld iyh, 6
.attribloop
	ld iyl, 24
	push hl
	call CopyAttribColumn
	pop hl
	inc hl
	dec iyh
	jr nz, .attribloop

	; REVERSE attrib
	; smc setup
	ld a, $1b ; dec de
	ld (CopyAttribColumn.smc_incdec), a
	;
	ld hl, $5800+26
	ld de, BorderLogoAttrib+144-1
	ld iyh, 6
.attribloop2
	ld iyl, 24
	push hl
	call CopyAttribColumn
	pop hl
	inc hl
	dec iyh
	jr nz, .attribloop2

	ld a, 00000110b
	ld hl, $5806
	ld b, 20
	call FillAttribLine
	ld hl, $5826
	ld b, 20
	call FillAttribLine
	ld hl, $5AE6
	ld b, 20
	call FillAttribLine
	ld hl, $5AC6
	ld b, 20
	call FillAttribLine
	ret

; hl - destination
; de - source
; iyl - iteration count
CopyAttribColumn:
	ld a, (de)
	ld (hl), a
	ld bc, 32 ; offset
	add hl, bc 
.smc_incdec
	inc de
	dec iyl
	jr nz, CopyAttribColumn
	ret

; b - iterations
; a - fill
; hl - destination
FillAttribLine:
	ld (hl), a
	inc hl
	djnz FillAttribLine
	ret

; hl - source
; bc - x/y position
; iyl - iteration count
StripeLoop:
	push bc
	push hl
	call DrawVerticalStripe

	pop hl
.smc_offset = $+1
	ld bc, 192 ; offset
	add hl, bc
	pop bc
.smc_incdec
	inc b

	dec iyl
	jr nz, StripeLoop
	ret

; copies/reverses 1st part of the border (text + part of logo)
CopyInverseFirst:
	ld hl, $4000
	ld de, $57FF
	ld iyh, 8
	call .loop
	ld hl, $4020
	ld de, $57E0-1
	ld iyh, 8
	call .loop
	ret
.loop
	push hl
	push de
	ld iyl, 26
	call ReverseBitOrder
	pop de
	pop hl
	inc h
	dec d
	dec iyh
	jp nz, .loop
	ret

; copies/reverses 2nd part of the border (rest of logo)
CopyInverseSecond:
	; init
	ld a, 5 ;1st screen
	call paging.temp_set_bank
	ld ix, .src_cnt
	; iterations = 192-16 = 176
	ld b, 176
.loop
	push bc
	ld b, 0
	; destination first
	ld hl, screen_y_lut.scradtab
	; load offset
	ld c, (ix+1)
	add hl, bc
	add hl, bc ; twice cuz addresses are 2bytes
	ld a, (hl) ; lowbyte
	inc hl
	ld h, (hl)
	ld l, a
	; make the address point to rightmost screen byte
	ld c, 31
	add hl, bc
	; done, put it in correct registers
	ex de, hl 
	; decrement the offset
	dec (ix+1)
	; source now
	ld hl, screen_y_lut.scradtab
	; load offset
	ld c, (ix+0)
	add hl, bc
	add hl, bc ; twice cuz addresses are 2bytes
	ld a, (hl) ; lowbyte
	inc hl
	ld h, (hl)
	ld l, a
	; increment the offset
	inc (ix+0)
	; call the func
	ld iyl, 6 ; bit amount
	call ReverseBitOrder
	; handle loop
	pop bc
	djnz .loop
	ret

.src_cnt
	db 16
.dest_cnt
	db 191-16

; simple but slow routine
; copies reversed bits but also reverses byte order
; iyl - bytes amount (max 256)
; hl - source
; de - destination
ReverseBitOrder:
.init
	ld b, 8
	ld c, (hl)
.bitloop
	rl c
	rra
	djnz .bitloop
	ld (de), a
	inc hl
	dec de
	dec iyl
	jp nz, .init
	ret
