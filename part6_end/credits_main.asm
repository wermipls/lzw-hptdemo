	MODULE credits
relocate
	org $E000, 7
start
	DISP CREDITS_RELOCATE
test:
	; precalc 

	call screen_y_lut

	ld hl, font_medium
	ld de, font_medium.lut
	ld bc, 16
	ld ixl, 96
	call GenerateFontLUT
	ld hl, font_bold
	ld de, font_bold.lut
	ld bc, 16
	ld ixl, 96
	call GenerateFontLUT

	; plasma
	xor a
	ld hl, plasma.DitherLookupEven-512
	ld (hl), a
	ld de, hl
	inc de
	ld bc, 1024
	ldir

	ld hl, plasma_alt.dither
	ld de, plasma.DitherLookupEven
	call plasma_alt.PrecalcDitherLUT
	ld hl, plasma_alt.dither+1
	ld de, plasma.DitherLookupOdd
	call plasma_alt.PrecalcDitherLUT
	
	ld hl, plasma_alt.dither+2
	ld de, plasma.DitherLookupEven+512
	call plasma_alt.PrecalcDitherLUT
	ld hl, plasma_alt.dither+3
	ld de, plasma.DitherLookupOdd+512
	call plasma_alt.PrecalcDitherLUT

	call plasma.PrecalcAdjustedSine
	
	;ld a, 2 ; 256
	ld a, 1
	ld (plasma.PrecalcScaledSine.smc_initial_increment), a
	ld a, 6
	ld (plasma.PrecalcScaledSine.smc_sp_increment), a
	ld a, 159
	ld (plasma.PrecalcScaledSine.smc_singen_offset), a
	ld hl, trig.sintable
	ld (plasma.PrecalcScaledSine.smc_sintable), hl
	call plasma.precalc_sine2

	ld hl, plasma.loop_calc.ixiy_increment_three
	ld (plasma.loop_calc.smc_increment_call), hl


	ld a, 48
	ld (plasma.loop_calc.smc_linecount), a
	ld hl, plasma.loop_calc.byte_loop_12b
	ld (plasma.loop_calc.smc_bytecount_jp), hl

	/*
	call paging.toggle_screen
	; clear screen
	ld a, 7
	call paging.set_bank
	ld hl, $C000
	ld de, $4000
	ld bc, 6144
	ldir
	call paging.toggle_screen
	*/
	ld a, 7
	call paging.set_bank
	; attribs
	ld d, 00111000b
	ld e, d
	ld hl, $DB00
	call fast_attrib_fill
	; border
	ei
	halt
	ld a, 7
	out (254), a
	call paging.toggle_screen
	ld hl, $5B00
	call fast_attrib_fill

	ld a, 5
	call paging.set_bank

	ld hl, font_medium.lut
	ld ix, font_medium.charwidth
	ld iy, text
	ld bc, 0
	call DrawTextLetterInit

	ld hl, DrawTextLetter
	ld (DEMO_ISR.extra_call_addr), hl


	ld hl, 0
	ld (GLOBAL_TIMER), HL


	ld iy, plasma.ScaledSin
	ld ix, plasma.SineAdjusted
	ld (plasma_alt.full_loop.ix), ix
	ld (plasma_alt.full_loop.iy), iy
.text1
	call plasma_helper
	; timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 3
	jp nz, .text1

	ld de, 0000011100000111b
	ld hl, text2
	call page_helper

.text2
	call plasma_helper
	; timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 6
	jp nz, .text2

	ld de, 0011100000111000b
	ld hl, text3
	call page_helper

.text3
	call plasma_helper
	; timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 9
	jp nz, .text3


	ld hl, DrawEndSprites
	ld (page_helper.smc_call1), hl
	ld (page_helper.smc_call2), hl

	ld de, 0000011100000111b
	ld hl, text4
	call page_helper

.text4
	call plasma_helper
	; timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 6
	jp nz, .text4




	di
	halt





	ret


	INCLUDE "font_rendering.asm"

font_medium
	INCBIN "./font/font_medium.BIN"
	align 256
.charwidth
	INCBIN "./font/font_medium_charwidths.bin"
	align 256
.lut
	BLOCK 256

font_bold
	INCBIN "./font/font_bold.BIN"
	align 256
.charwidth
	INCBIN "./font/font_bold_charwidths.bin"
	align 256
.lut
	BLOCK 256

text:
	INCBIN "./text.txt"
	db 0 ; string termination
text2:
	INCBIN "./text2.txt"
	db 0 ; string termination
text3:
	INCBIN "./text3.txt"
	db 0 ; string termination
text4:
	INCBIN "./text4.txt"
	db 0 ; string termination
	INCLUDE "plasma.asm"

plasma_helper:
	ld a, 6
	call paging.set_bank
	call plasma_alt.full_loop
	halt 
	jp paging.toggle_screen
	
; de - screen attrib
; hl - text pointer
page_helper:
	push hl
	;push de
	call vectys.ScreenCheck
	call .clear
	push de
.smc_call1 = $+1
	call DUMMY
	ld a, 6
	call paging.set_bank
	call plasma_alt.full_loop
	pop de
	call .border
	call paging.toggle_screen
	call vectys.ScreenCheck
	call .clear
.smc_call2 = $+1
	call DUMMY
	pop iy
	ld hl, font_medium.lut
	ld ix, font_medium.charwidth
	ld bc, 0
	jp DrawTextLetterInit
.clear
	push de
	ld bc, 0
	ld de, 19*256 + 23
	ld h, b
	ld l, b
	call bounding_box_clear
	pop de 
	ld hl, $DB00
	jp fast_attrib_fill
.border
	ld a, d
	rra
	rra
	rra
	and 00000111b
	halt
	out (254), a
	ret

	INCLUDE "sprites.asm"

	ENT
end
	org relocate
	ENDMODULE