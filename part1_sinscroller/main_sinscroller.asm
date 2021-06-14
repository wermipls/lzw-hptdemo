PART1_SINSCROLLER:
	; precalculate shifted versions of font
	; shifted by two
	ld bc, 64*14
	ld de, assets_font_preshifted
	ld hl, assets_font
	call ShiftPrecalc

	ld bc, 64*14
	ld hl, assets_font
	; self modifying code
	; jump setup
	ld a, 2
	ld (ShiftPrecalc.jump), a
	; mask setup
	ld a, 00001111b
	ld (ShiftPrecalc.mask), a
	xor 11111111b ; invert
	ld (ShiftPrecalc.maskInverted), a
	call ShiftPrecalc

	ld bc, 64*14
	ld hl, assets_font
	; self modifying code
	; jump setup
	ld a, 0
	ld (ShiftPrecalc.jump), a
	; mask setup
	ld a, 00000011b
	ld (ShiftPrecalc.mask), a
	xor 11111111b ; invert
	ld (ShiftPrecalc.maskInverted), a
	call ShiftPrecalc


	; generate font LUT
	ld de, 28
	ld ix, font_lut+128+256
	ld hl, assets_font_preshifted
	call GenerateFontLUT
	ld ix, font_lut+128+256*2
	ld hl, assets_font_preshifted.two
	call GenerateFontLUT
	ld ix, font_lut+128+256*3
	ld hl, assets_font_preshifted.three
	call GenerateFontLUT
	ld ix, font_lut+128
	ld hl, assets_font
	ld e, 14
	call GenerateFontLUT

	ld ix, sintable
	ld iy, sintable2
	ld (DrawLogoStripes.sinIndex), ix
	ret

.loop:
	call UpdateTextScroller

	push iy
	call DrawLogoStripes
	pop iy

	ei
	halt
	ret

	ALIGN 256 ;org $8200
sintable:
	INCBIN "sintable.bin"
sintable2:
	INCBIN "sintable2.bin"
	INCLUDE "drawing.asm" ; some of the routines may be Use Full later on
PART1_SINSCROLLER_ASSETS:
	INCLUDE "fadeout.asm"
	INCLUDE "logo_thick_workaround2_NEW_ogcurves.ASM"
	INCLUDE "assets_font_new_new_new.ASM"
	INCLUDE "logoscroller.asm"
assets_scrollertext:
	INCBIN "scrollertext_encoded.txt"
PART1_SINSCROLLER_END:
	INCLUDE "scratch.asm"