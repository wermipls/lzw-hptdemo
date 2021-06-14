	MODULE bezier
bresen_remove:
	ld a, $a2 ; and d
	ld (bresenham_sub_fast_y.smc_or_xor), a
	ld (bresenham_sub_fast_x.smc_or_xor), a
	ld a, $ae ; xor (hl)
	ld (bresenham_sub_fast_y.smc_or_xor+1), a
	ld (bresenham_sub_fast_x.smc_or_xor+1), a
	ld a, $77 ; ld (hl), a
	ld (bresenham_sub_fast_x.smc_or_xor+2), a
	ret
bresen_draw:
	ld a, 0 ; nop
	ld (bresenham_sub_fast_y.smc_or_xor+1), a
	ld (bresenham_sub_fast_x.smc_or_xor+1), a
	ld a, $b2 ; or d
	ld (bresenham_sub_fast_y.smc_or_xor), a
	ld (bresenham_sub_fast_x.smc_or_xor), a
	ret
init:
	;ld a, 0 ; nop
	;ld (bresenham_sub_fast_y.smc_iteration_correction), a
	;ld (bresenham_sub_fast_x.smc_iteration_correction), a
	halt
	ld a, 7
	call paging.set_bank
	ld d, 01000010b ; attrib data
	ld e, d
	ld hl, $DB00
	call fast_attrib_fill
	ret


loop:
	call policz_sobie_matematycznie
	call policz_sobie_matematycznie
	call policz_sobie_matematycznie
	call policz_sobie_matematycznie
	call policz_sobie_matematycznie
	call policz_sobie_matematycznie
	call policz_sobie_matematycznie
	;call policz_sobie_matematycznie
	ld ix, (pointer_x)
	ld de, result+1
	call CalculateBezier
	;ld ix, (pointer_x)
	;ld de, result+1+16*2
	call CalculateBezierBackwards
	ld ix, (pointer_y)
	ld de, result
	call CalculateBezier
	;ld ix, (pointer_y)
	;ld de, result+16*2
	call CalculateBezierBackwards
	ld de, (pointer_y)
	inc e ; lazy
	inc e
	inc e
	inc e
	ld (pointer_x), de
	inc e ; lazy
	inc e
	inc e
	inc e
	ld (pointer_y), de

	ei
	halt
	call bresen_draw
.smc_drawcall = $+1
	call draw

	ld ix, (pointer_x_old)
	ld de, result+1
	call CalculateBezier
	call CalculateBezierBackwards
	ld ix, (pointer_y_old)
	ld de, result
	call CalculateBezier
	call CalculateBezierBackwards
	ld de, (pointer_y_old)
	inc e ; lazy
	inc e
	inc e
	inc e
	ld (pointer_x_old), de
	inc e ; lazy
	inc e
	inc e
	inc e
	ld (pointer_y_old), de

	call bresen_remove
	ei
	halt
	call draw

	/*
	ld ix, datax2
	ld de, result+1
	call CalculateBezier
	ld ix, datay2
	ld de, result
	call CalculateBezier

	ld a, 7
	call paging.set_bank
	call draw
	*/
	ret

draw:
	ld iyl, 15
	ld hl, result
	ld b, (hl)
	inc hl
	ld c, (hl)
	inc hl
.draw_loop
	ld d, (hl)
	inc hl
	ld e, (hl)
	inc hl
	push de
	ld a, d
	xor b
	jr z, .sus
.nvm
	push hl
	call bresenham_calc_pos
	pop hl
.amogus
	pop bc
	dec iyl
	jp nz, .draw_loop
	ret
.sus
	ld a, e
	xor c
	jr nz, .nvm
	; when the impostor is sus
	jp .amogus

/*policz_sobie_matematycznie:
	ld de, (pointer_x)
	ld b, 4
.loopx
	ld a, 64
	add a, (hl)
	srl a
	;srl a
	add 96
	add a, (hl)
	ld (de), a
	ld a, 64-8 ; adjust this
	add a, l
	ld l, a
	inc de
	djnz .loopx

	ld de, (pointer_y)
	ld b, 4
.loopy
	ld a, 96
	add a, (hl)
	ld (de), a
	ld a, 128+7 ; adjust this
	add a, l
	ld l, a
	inc de
	djnz .loopy
	ret*/

policz_sobie_matematycznie:
	ld de, (pointer_x)
	ld ix, sinpos
	ld h, sine_x/256
	ld b, 4
.loopx
	ld l, (ix+0) ; fetch sine pos
	ld a, (hl)
	ld (de), a
	; decrement
	dec (ix+16)
	jr nz, .nodecx
	inc l
	ld (ix+0), l
	ld a, (ix+8)
	ld (ix+16), a
.nodecx
	inc ix
	inc de
	djnz .loopx

	ld h, sine_y/256
	ld b, 4
.loopy
	ld l, (ix+0) ; fetch sine pos
	ld a, (hl)
	ld (de), a
	; decrement
	dec (ix+16)
	jr nz, .nodecy
	inc l
	ld (ix+0), l
	ld a, (ix+8)
	ld (ix+16), a
.nodecy
	inc ix
	inc de
	djnz .loopy
	ret



	align 256
sine_x:
	INCBIN "SiNTABLE.PROPER.bin"
sine_y:
	INCBIN "sintable_y_variant_cuz_i_dont_wanna_scale_in_code_For_Now.bin"
sinpos:
	;db 0
	;db 128-11
	;db 32-4
	;db 64-9
	;db 96-1
	;db 164+20
	;db 164
	;db 192+9

	;db 0, 5, 10, 15, 20, 25, 30, 35
	;db $F4, $73, $E6, $F7, $82, $3E, $8C, $0B
	db $EC, $67, $CE, $E7, $76, $9B, $80, $FB
sininc:
	;db 6
	;db 4
	;db 2
	;db 3
	;db 2
	;db 3
	;db 5
	;db 6

	db 6
	db 4
	db 2
	db 3
	db 4
	db 5
	db 4
	db 3
sin_before_dec:
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
pointer_x:
	dw data+192
pointer_y:
	dw data+192+4
pointer_x_old:
	dw data
pointer_y_old:
	dw data+4

	align 256
data
	block 256
result
	block 17*2

	INCLUDE "bezier_calc.asm"
	ENDMODULE