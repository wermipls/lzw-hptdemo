	DEVICE ZXSPECTRUM128
	SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

	org $7000
DEMO_INIT:
	ei
	ld a, 01000000b ; attrib data
	ld ($5C8D), a 
	call 3503
	; set border color
	xor a ; ld a, 0 
	out (254), a

	; some initialization
	di
	ld sp, STACK_SPACE_END ; relocate SP to uncontended ram
	; set vector table high byte
	ld a, $80
	ld i, a
	; set 257 bytes to $81 starting at $5B00 for interrupt vector table 
	ld hl, $8000
	ld de, $8000+1
	ld a, $81
	ld (hl), a
	ld bc, 256
	ldir

	; plasma partial precalc
	call plasma.precalc_sine
	ld a, 3 ; 256*3
	ld (plasma.PrecalcScaledSine.smc_initial_increment), a
	ld (plasma.PrecalcScaledSine.smc_sp_increment), a
	ld a, 32
	ld (plasma.PrecalcScaledSine.smc_singen_offset), a
	call plasma.precalc_sine2
	ld a, 0
	call paging.set_bank
	
	
	; preparar
	call PART1_SINSCROLLER
	call UpdateTextScroller
	call DrawLogoStripes

	;halt
	ld a, 01000111b
	ld b, 64
	ld hl, $5800
	call FillAttribLine ;64
	call FillAttribLine ;320
	ld a, 01000111b
	call FillAttribLine ;576
	ld b, 256-64
	call FillAttribLine ;768

	; init audio
	CALL AUDIO_PLAYER
	; interrupt mode 2
	im 2
	ei	
;	jp DEMO_START


;DEMO_START:
	
.sinloop
	call PART1_SINSCROLLER.loop

	ld a, (GLOBAL_TIMER+1)
	cp 1 ;cp 3
	jr nz, .sinloop
	ld a, (GLOBAL_TIMER)
	cp 224-22+20
	jr nz, .sinloop	

	ld hl, FadeoutScroller
	ld (DEMO_ISR.extra_call_addr), hl

.sinloop_fade
	call PART1_SINSCROLLER.loop

	ld a, (GLOBAL_TIMER+1)
	cp 1 ;cp 3
	jr nz, .sinloop_fade
	ld a, (GLOBAL_TIMER)
	cp 224+28-22+22
	jr nz, .sinloop_fade

	ld hl, DUMMY
	ld (DEMO_ISR.extra_call_addr), hl


	; plasma goes here
	; clear screen
	; call paging.toggle_screen
	ld a, 7
	call paging.set_bank
	; clear
	ld hl, $C000
	ld de, $4000
	ld bc, $1800
	ldir
	; rest of precalc
	call screen_y_lut
	call plasma.precalc_other_fadein

	ld hl, plasma.CopyDither
	ld (DEMO_ISR.extra_call_addr), hl

	; plasma variant 2 

	call plasma.init
	halt
	ld (plasma.full_loop.ix), ix
	ld (plasma.full_loop.iy), iy
	ld a, 1
	;out (254), a
	ld d, 01000011b ;01001111b ; attrib data
	ld e, d
	ld hl, $5B00
	call fast_attrib_fill
	ld b, 170-32-3
.plasma_loop1
	push bc
	ld a, 4
	call paging.set_bank
	call plasma.full_loop
	pop bc
	djnz .plasma_loop1

	ld hl, plasma.ClearDither
	ld (DEMO_ISR.extra_call_addr), hl

	ld b, 32
.plasma_loop4
	push bc
	ld a, 4
	call paging.set_bank
	call plasma.full_loop
	pop bc
	djnz .plasma_loop4

	ld hl, DUMMY
	ld (DEMO_ISR.extra_call_addr), hl




	halt 
	ld d, 0 ; attrib data
	ld e, d
	ld hl, $5B00
	call fast_attrib_fill

	call plasma.precalc_other

	ld a, 3 ; 256*3
	ld (plasma.PrecalcScaledSine.smc_initial_increment), a
	ld a, 2
	ld (plasma.PrecalcScaledSine.smc_sp_increment), a
	ld a, 40
	ld (plasma.PrecalcScaledSine.smc_singen_offset), a
	ld hl, trig.sintable_craziest
	ld (plasma.PrecalcScaledSine.smc_sintable), hl
	call plasma.precalc_sine

	ld hl, plasma.loop_calc.ixiy_increment_four
	ld (plasma.loop_calc.smc_increment_call), hl

	ld hl, trig.sintable_crazy2
	ld (plasma.full_loop.iy), hl

	ld a, 6
	call paging.set_bank
	call plasma.full_loop
	halt
	ld a, 1
	out (254), a
	ld d, 01001111b ; attrib data
	ld e, d
	ld hl, $5B00
	call fast_attrib_fill

	;ld hl, DUMMY;plasma.ChangeColor
	;ld (DEMO_ISR.extra_call_addr), hl
	ld b, 170
.plasma_loop3
	push bc
	ld a, 6
	call paging.set_bank
	call plasma.full_loop
	pop bc
	djnz .plasma_loop3

	ld hl, plasma.loop_calc.ixiy_increment_two
	ld (plasma.loop_calc.smc_increment_call), hl
	ld ix, plasma.ScaledSin+45
	ld iy, plasma.SineAdjusted
	halt
	ld (plasma.full_loop.ix), ix
	ld (plasma.full_loop.iy), iy
	ld a, 3
	out (254), a
	ld d, 01011110b ; attrib data
	ld e, d
	ld hl, $5B00
	call fast_attrib_fill
	ld b, 170-4
.plasma_loop2
	push bc
	ld a, 4
	call paging.set_bank
	call plasma.full_loop
	pop bc
	djnz .plasma_loop2

	ld hl, DUMMY
	ld (DEMO_ISR.extra_call_addr), hl


	halt
	xor a
	out (254), a
	call paging.toggle_screen

	; ANIM
	call screen_y_lut
	halt
	call CopyBorderPixels
	ei
	ld hl, 1111111111111111b
	call clear160x160_test
	; copy attribs to temp
	ld hl, $5800
	ld de, BorderAttrib
	ld bc, 768
	ldir

	; vectys precalc
	call vectys.precalc

	ld a, 7 ; shadow screen
	call paging.set_bank
	ld d, 00000000b ; attrib data
	ld e, d
	ld hl, $5B00
	call fast_attrib_fill	
	ld d, 00000000b ; attrib data
	ld e, d
	ld hl, $DB00
	call fast_attrib_fill	
	; copy pixel data to shadow screen
	ld hl, $4000
	ld de, $C000
	ld bc, 6144
	ldir
	

	; copy attrib data! (Normal)
	ld hl, BorderAttrib
	ld bc, 768
	ld de, $5800
	ldir

.lockup_preanim
	halt
	;timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 8 ;cp 3
	jr nz, .lockup_preanim
	ld a, (GLOBAL_TIMER)
	cp 256-72-32-3
	jr nz, .lockup_preanim


	; copy attrib data! (fadein)
	ld hl, BorderAttrib
	ld de, $D800
	ld ixl, 768/32
.anim_fadein
	ld bc, 32
	ldir
	halt
	halt
	halt
	dec ixl
	jr nz, .anim_fadein

	call paging.toggle_screen

	ld hl, DecrementDrawtime
	ld (DEMO_ISR.extra_call_addr), hl

	; ANIM
	; set up pointer to pointers
	ld ix, ANIM_DATA_POINTERS
	ld iy, ANIM_DATA_DELAYS
	;ld b, 47 
	ld b, ANIM_DATA_FRAME_COUNT ; loop iterations = anim frames
	call ANIM_PLAY_SEQUENCE
	call paging.toggle_screen
	; mandatory clear
	ld a, 7
	call paging.set_bank
	ld hl, 1111111111111111b
	call clear160x160_test

	
	; loop 2
	; set up pointer to pointers
	ld ix, ANIM_DATA_POINTERS
	ld iy, ANIM_DATA_DELAYS
	;ld b, 47 
	ld b, ANIM_DATA_FRAME_COUNT ; loop iterations = anim frames
	call ANIM_PLAY_SEQUENCE
	call paging.toggle_screen
	; mandatory clear
	ld a, 7
	call paging.set_bank
	ld hl, 1111111111111111b
	call clear160x160_test
	
	; set up pointer to pointers
	
	; loop 3 (or so i thought?)
	; set up pointer to pointers
	ld ix, ANIM_DATA_POINTERS
	ld iy, ANIM_DATA_DELAYS
	;ld b, 47 
	ld b, 7 ; loop iterations = anim frames
	call ANIM_PLAY_SEQUENCE
	call paging.toggle_screen
	; set up pointer to pointers
	ld a, 3
	ld (ANIM_PLAY_SEQUENCE.smc_page), a
	ld ix, ANIM_DATA_END_POINTERS
	ld iy, ANIM_DATA_END_DELAYS
	;ld b, 47 
	ld b, ANIM_DATA_END_FRAME_COUNT-7 ; loop iterations = anim frames
	call ANIM_PLAY_SEQUENCE


.lockup_post_anim
	halt
	ld a, (GLOBAL_TIMER+1)
	cp 11 ;cp 3
	jr nz, .lockup_post_anim
	ld a, (GLOBAL_TIMER)
	cp 256-15
	jr nz, .lockup_post_anim



	ld l, 188

.cube_loop
	push hl
	
	ld h, trig.sintable/256 ;bezier.sine_x/256 :;
	ld a, 128
	add a, (hl)
	sla a
	ld l, a
	
	call vectys.main_loop
	pop hl
	inc l
	inc l
	;inc l
	; angle check
	ld a, l
	cp 188
	jr nz, .cube_loop

	push hl
	ld hl, BorderTransition
	ld (DEMO_ISR.extra_call_addr), hl

	ld hl, vectys.translatex_helper
	ld (vectys.main_loop.smc_translate_call), hl
	pop hl
	


.cube_loop2
	push hl
	
	ld h, trig.sintable/256 ;bezier.sine_x/256 :;
	ld a, 128
	add a, (hl)
	sla a
	ld l, a
	
	call vectys.main_loop
	pop hl
	inc l
	inc l
	;inc l
	; angle check
	ld a, l
	cp 188
	jr nz, .cube_loop2
	;push hl

	ld hl, DUMMY
	ld (DEMO_ISR.extra_call_addr), hl
	ld (vectys.main_loop.smc_translate_call), hl
	ld hl, SimpleRotationMatrix
	ld (vectys.main_loop.call_rotmatrix), hl
	ld l, 64
	push hl
	call vectys.main_loop
	pop hl
	push hl
	call vectys.main_loop
	pop hl
	
	halt
	halt
	halt
	halt

	;pop hl
.cube_loop3
	push hl
	call vectys.main_loop
	pop hl
	dec l
	dec l
	;inc l
	; timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 15
	jr nz, .cube_loop3
	ld a, (GLOBAL_TIMER)
	and 11111110b
	cp 256-6
	jr nz, .cube_loop3


	; not cube
	ld hl, vectys.tetra
	ld de, vectys.current
	ld bc, vectys.current.end-vectys.current
	ldir

	ld hl, vectys.vertices_rotated-vectys.tetrahedron.vertices
	ld (vectys.main_loop.smc_rotminusvert), hl	
	ld a, 46;24 ; 24
	ld (vectys.main_loop.smc_scale), a

	;gracefully handle color change
	ld l, 0
	call vectys.main_loop

	call vectys.ScreenCheck
	; change color
	ld d, 01000110b ; attrib data
	ld e, d
	ld hl, $DB00
	call fast_attrib_fill

	;gracefully handle color change
	ld l, -2
	call vectys.main_loop

	call vectys.ScreenCheck
	; change color
	ld d, 01000110b ; attrib data
	ld e, d
	ld hl, $DB00
	call fast_attrib_fill


 ; VECTYS LOOP
	ld l, -4
.tetra
	push hl
	call vectys.main_loop
	pop hl
	dec l
	dec l
	; timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 17 ;19 ;6
	jr nz, .tetra
	ld a, (GLOBAL_TIMER)
	and 11111110b
	cp 256-4
	jr nz, .tetra
	



	ld a, 5 ; normal screen
	call paging.set_bank
	ld bc, 0
	ld de, 30*256 + 23
	ld hl, 0
	halt
	call bounding_box_clear
	ld a, 7 ; shadow screen
	call paging.set_bank
	ld bc, 0
	ld de, 30*256 + 23
	ld hl, 0
	halt
	call bounding_box_clear
.screen_done_endvectys


	
	;call screen_y_lut
	; shadow screen
	;call paging.toggle_screen
	ld a, 7
	call paging.set_bank
	 ;attrib reset 
	ld d, 01000110b ; attrib data
	ld e, d
	ld hl, $DB00
	call fast_attrib_fill
	ld hl, $5B00
	call fast_attrib_fill

	ld hl, plasma.ChangeColor
	ld (DEMO_ISR.extra_call_addr), hl


	call bezier.init
.bezier_loop2
	call bezier.loop
	ld a, (GLOBAL_TIMER+1)
	cp 20
	jr nz, .bezier_loop2

	ld hl, DUMMY
	ld (DEMO_ISR.extra_call_addr), hl

	call bezier.init
.bezier_loop3
	call bezier.loop

	; timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 22 ;6
	jr nz, .bezier_loop3
	ld a, (GLOBAL_TIMER)
	and 11111100b
	cp 256-4-8-64
	jr nz, .bezier_loop3

	ld hl, DUMMY
	ld (bezier.loop.smc_drawcall), hl

	;call screen_y_lut
	;call bezier.init
.bezier_loop
	call bezier.loop

	; timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 22 ;6
	jr nz, .bezier_loop
	ld a, (GLOBAL_TIMER)
	and 11111100b
	cp 256-4-12
	jr nz, .bezier_loop

	halt
	halt
	; set up correct bank
	ld a, 3
	call paging.set_bank
	call endgfx.display
	halt
	call paging.toggle_screen

	; copy attrib data! (fadein)
	ld hl, $5800
	ld (hl), 01000111b
	ld de, $5800+1
	ld ixl, 768/96
.endgfx_fadein2
	ld bc, 96
	ldir
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	dec ixl
	jr nz, .endgfx_fadein2



.endgfx
	halt
	; timercheck
	ld a, (GLOBAL_TIMER+1)
	cp 24 ;19 ;6
	jr nz, .endgfx

	ld a, 7 ; shadow screen
	call paging.set_bank
	; clear the other screen
	ld hl, $C000
	ld de, $C000+1
	xor a
	ld (hl), a
	ld bc, $1800-1+768
	ldir
	halt
	call paging.toggle_screen
	ld hl, $4000
	ld de, $4000+1
	xor a
	ld (hl), a
	ld bc, $1800-1+768
	ldir
	halt
	call paging.toggle_screen

.post_endgfx
	ld a, (GLOBAL_TIMER)
	cp 64 ;19 ;6
	jr nz, .post_endgfx

	call load_credits
.lockup
	jr .lockup




	org $8100
STACK_SPACE:
	defw 0 ; WPMEM, 2
	block $81-4
	org $8181-2
STACK_SPACE_END:
	defw 0 ; WPMEM, 2
	org $8181
DEMO_ISR:
	ld (DEMO_ISR.saveSP), sp
	ld sp, $6000-2

	push af
	push bc
	push de
	push hl
	exx
	ex af
	push af
	push bc
	push de
	push hl	
	push ix
	push iy
	
	ld hl, (GLOBAL_TIMER)
	inc hl
	ld (GLOBAL_TIMER), hl


	; audio driver is stored in bank 0
	; so we need to temporarily switch the banks
	ld a, 0
	call paging.temp_set_bank
	CALL AUDIO_PLAYER+5
.extra_call_addr = $+1:
	call DUMMY
	call paging.restore_value

	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	exx
	ex af
	pop hl
	pop de
	pop bc
	pop af

.saveSP = $+1
	ld sp, 0 ; will be overwritten
	ei
	ret
GLOBAL_TIMER:
	dw $0000

DUMMY:
	ret

APLIB_START
	INCLUDE "aplib234b.asm"
APLIB_END
	INCLUDE "paging.asm"
	INCLUDE "drawing_general.asm"
load_credits:
	ld a, 7
	call paging.set_bank
	; relocate code
	ld hl, credits.start
	ld de, CREDITS_RELOCATE

	ld bc, credits.end-credits.start
	ldir
	
	call credits.test


MAIN_ANIM:
	INCLUDE "./part2_anim/main_anim.asm"
ANIM_END
	INCLUDE "./part4_plasma/main_plasma.asm"
	INCLUDE "./part3_cuberotator/main_vectors.asm"
CUBE_END:
BEZIER:
	INCLUDE "./part5_bezier/main_bezier.asm"
	INCLUDE "./part5_endgfx/main_endlogo.asm"
	INCLUDE "./part6_end/credits_main.asm"
	INCLUDE "./part1_sinscroller/main_sinscroller.asm"

	; muzyka
	ASSERT SINSCROLLER_SCRATCH_END < AUDIO_PLAYER
	org $DA00, 0
AUDIO_PLAYER:
	INCLUDE "VTII10bG.asm"
muzykatest:
	INCBIN "./kurwaaaa_oldpitchbend.pt3"
AUDIO_PLAYER_END:

	SAVETAP "./build/output.tap", DEMO_INIT
	SAVESNA "./build/output.sna", DEMO_INIT