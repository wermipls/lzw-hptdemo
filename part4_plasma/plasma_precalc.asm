/*PrecalcScaledSine:
	halt
	di 
	ld (.saveSP), sp
.smc_initial_increment = $+2
	ld sp, 256*2 ; initial increment
.smc_singen_offset = $+1
	ld de, ScaledSin+96 ; singen offset
	ld ixh, 64 ; amount of tables
	exx
	ld d, 2 ; iterations b4 halt
	exx
.loop_tables
	ld hl, 128 ; initial error
	ld ixl, 0 ; loop iterations
	ld bc, trig.sintable
.loop_bytes:
	ld a, (bc) ; fetch
	add a, 64 ; offset
	cp 128
	jp nz, .no_adjust
	dec a
.no_adjust
	ld (de), a ; save
	inc e
	add hl, sp ; increment error
	ld c, h ; high byte -> sin index
	dec ixl ; loop counter
	jp nz, .loop_bytes
	exx
.smc_sp_increment = $+1
	ld hl, 2 ; sp increment
	add hl, sp ; add to sp
	; decrement counter
	dec d
	jr nz, .nohalt
	; halt to not pause the music
	ld sp, (.saveSP)
	ei
	halt
	di
	ld d, 2 ; iterations b4 halt
	;
.nohalt
	ld sp, hl
	exx
	inc d
	dec ixh ; loop counter
	jp nz, .loop_tables
	ld sp, (.saveSP) 
	ei
	ret
.saveSP
	dw 0*/
PrecalcScaledSine:
	ld ixh, 64 ; amount of tables
	ld ixl, 0 ; loop iterations
.smc_initial_increment = $+2
	ld de, 256*2 ; initial increment
.smc_singen_offset = $+1
	ld hl, ScaledSin+96 ; singen offset
.loop_tables
	ld iy, 128 ; initial error
.smc_sintable = $+1
	ld bc, trig.sintable
.loop_bytes:
	ld a, (bc) ; fetch
	add a, 64 ; offset
	cp 128
	jp nz, .no_adjust
	dec a
.no_adjust
	ld (hl), a ; save
	add iy, de
	ld c, iyh ; high byte -> sin index
	inc l
	dec ixl ; loop counter
	jp nz, .loop_bytes
	push hl
.smc_sp_increment = $+1
	ld hl, 2 ; error increment
	add hl, de
	ex de, hl
	pop hl
	inc h
	dec ixh ; loop counter
	jp nz, .loop_tables
	ret

PrecalcAdjustedSine:
	ld hl, trig.sintable
	ld de, SineAdjusted
	ld b, 0
.loop
	ld a, 64 ; offset
	add a, (hl)
	cp 128
	jp nz, .no_adjust
	dec a
.no_adjust
	;sra a
	ld (de), a
	inc de
	inc hl
	djnz .loop
	ret

; hl - source
; de - destination
PrecalcDitherLUT:
	ld ixl, 3
.total_loop
	ld c, 6
.inc_loop
	ld b, 4
	call .inc_frag
	ld b, 3
	call .inc_frag
	dec c
	jr nz, .inc_loop
	;dec
	ld c, 6
.dec_loop
	ld b, 4
	call .dec_frag
	ld b, 3
	call .dec_frag
	dec c
	jr nz, .dec_loop
	dec ixl
	jr nz, .total_loop
	xor a
	ld b, 3
	jr .copy_loop
	; ret in function

.dec_frag
	ld a, (hl)
	dec hl
	dec hl
	jr .copy_loop
.inc_frag
	ld a, (hl)
	inc hl
	inc hl
.copy_loop
	ld (de), a
	inc de
	djnz .copy_loop
	ret