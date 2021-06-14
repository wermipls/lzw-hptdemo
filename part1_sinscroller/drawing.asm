ScreenYEvenLineLUT:
	DW $4000
	DW $4200
	DW $4400
	DW $4600
	DW $4020
	DW $4220
	DW $4420
	DW $4620
	DW $4040
	DW $4240
	DW $4440
	DW $4640
	DW $4060
	DW $4260
	DW $4460
	DW $4660
	DW $4080
	DW $4280
	DW $4480
	DW $4680
	DW $40A0
	DW $42A0
	DW $44A0
	DW $46A0
	DW $40C0
	DW $42C0
	DW $44C0
	DW $46C0
	DW $40E0
	DW $42E0
	DW $44E0
	DW $46E0
	DW $4800
	DW $4200
	DW $4400
	DW $4600
	DW $4820
	DW $4220
	DW $4420
	DW $4620
	DW $4840
	DW $4240
	DW $4440
	DW $4640
	DW $4860
	DW $4260
	DW $4460
	DW $4660
	DW $4880
	DW $4280
	DW $4480
	DW $4680
	DW $48A0
	DW $42A0
	DW $44A0
	DW $46A0
	DW $48C0
	DW $42C0
	DW $44C0
	DW $46C0
	DW $48E0
	DW $42E0
	DW $44E0
	DW $46E0
	DW $5000
	DW $5200
	DW $5400
	DW $5600
	DW $5020
	DW $5220
	DW $5420
	DW $5620
	DW $5040
	DW $5240
	DW $5440
	DW $5640
	DW $5060
	DW $5260
	DW $5460
	DW $5660
	DW $5080
	DW $5280
	DW $5480
	DW $5680
	DW $50A0
	DW $52A0
	DW $54A0
	DW $56A0
	DW $50C0
	DW $52C0
	DW $54C0
	DW $56C0
	DW $50E0
	DW $52E0
	DW $54E0
	DW $56E0
	DW $4000
	DW $4200
	DW $4400
	DW $4600
	DW $4020
	DW $4220
	DW $4420
	DW $4620
	DW $4040
	DW $4240
	DW $4440
	DW $4640
	DW $4060
	DW $4260
	DW $4460
	DW $4660
	DW $4080
	DW $4280
	DW $4480
	DW $4680
	DW $40A0
	DW $42A0
	DW $44A0
	DW $46A0
	DW $40C0
	DW $42C0
	DW $44C0
	DW $46C0
	DW $40E0
	DW $42E0
	DW $44E0
	DW $46E0

ScreenYCharLUT:
	DW $4000
	DW $4020
	DW $4040
	DW $4060
	DW $4080
	DW $40A0
	DW $40C0
	DW $40E0
	DW $4800
	DW $4820
	DW $4840
	DW $4860
	DW $4880
	DW $48A0
	DW $48C0
	DW $48E0
	DW $5000
	DW $5020
	DW $5040
	DW $5060
	DW $5080
	DW $50A0
	DW $50C0
	DW $50E0
	DW $4000
	DW $4020
	DW $4040
	DW $4060
	DW $4080
	DW $40A0
	DW $40C0
	DW $40E0

saveSP equ $FFFE

; draws vertical stripes of 8x64px size.
; inputs:
; HL - grapics pointer,
; B - x position (characters),
; C - y position (pixels). 192-256 are clipping behind the screen
DrawVerticalStripe:
	; --- some initialization stuff here ---

	; we are going to use the POP instruction to fetch stripe contents later on
	; so we need to disable interrupts & preserve original SP somewhere
	di 
	ld (saveSP), sp
	; now the graphics pointer goes to SP 
	ld sp, hl

	; x position offset (B register) will be constant,
	; so i make it a part of an immediate load instruction later on to free one register
	; [this is the so-called self modifying code]
	ld a, b
	ld (.offsetX), a
	ld (.offsetX2+1), a
	; loading LUT pointer
	ld ix, ScreenYCharLUT
	; shifting and masking the Y position value to get appropriate lut offset,
	; since the LUT is simplified (only every 8th line).
	; the shift is happening only 2 times since table has 2 bytes per entry
	ld a, c
	rra
	rra
	and 00111110b
	ld ixl, a

	; --- end init stuff --

.firstIteration:
	; fetching Y screen position (tile aligned) to HL
	; this is a bit horrible but idk how to do it better
	ld h, (ix+1)
	ld l, (ix+0)
	inc ix
	inc ix

	; adding X offset to screen position
	ld a, l		; screen position low byte
	add a, b	; add x offset
	ld l, a		; back into e

	; ok lets try..
	; we are interested in 3 bits in the Y position value

	; !!we need to add those 3 bits to the H register, 
	; then start a loop with adequate amount of iterations
	ld a, 00000111b
	and c
	jp z, .isZero	; if zero, we can skip this Bull Shit
	ld b, a ; storing the result
	add a, h
	ld h, a ; h is now offset

	; calculating number of iterations
	inc b ; compensate for odd posY code
	xor a
	rr b
	sub b
	ld b, 00000011b
	and b
	; right now, a is number of iterations, b is offset in pixels

	; before trashing b, lets find out parity
	; if Y position is even, we decrement sp to introduce a 1px offset
	; then fill 1st byte with zero and the next byte with image data as intended
	bit 0, c
	jr z, .isEvenNumber

.isOddNumber
	dec sp
	pop de
	ld (hl), d
	inc h

.isEvenNumber

	ld b, a
	or a ; check if loop iterations = 0
	jr nz, .copy_tile_stack
	jr .isZeroIterations
.isZero
	ld b, 4

	; this routine copies 8x8px worth of data
	; this one is theoretically fastest
	; problem: it will be only able to copy in 2 byte pieces
.copy_tile_stack:
	pop de
	ld (hl), e
	inc h
	ld (hl), d
	inc h
	djnz .copy_tile_stack

.isZeroIterations

	; before this loop is entered, c needs to be
	; initialized with a proper value, as its going
	; to be used as a counter.
	; original c (which will be useful later on)
	; will be stored in the shadow register
	ld a, c
	ex af, af'

	; number of iterations (change to alter stripe length). default = 7 which gives 64px
.stripeIterations = $+1
	ld b, 8
.loopedIteration:
	; fetching Y screen position (tile aligned) to HL
	; while adding the X offset
.offsetX = $+1
	ld a, $00 ; immediate value going to be modified
	add a, (ix+0)
	ld l, a
	ld h, (ix+1)
	inc ix
	inc ix

	; fixed number of iterations
	;ld b, 4

	; this routine copies 8x8px worth of data
	; this one is theoretically fastest
	; problem: it will be only able to copy in 2 byte pieces
.copy_tile_stack2:
	; unrolled loop
	; 1st iteration
	pop de
	ld (hl), e 
	inc h
	ld (hl), d 
	inc h
	; 2nd
	pop de
	ld (hl), e 
	inc h
	ld (hl), d 
	inc h
	; 3rd
	pop de
	ld (hl), e 
	inc h
	ld (hl), d 
	inc h
	; 4tn (final)
	pop de
	ld (hl), e 
	inc h
	ld (hl), d 
	inc h
	;djnz .copy_tile_stack2

	djnz .loopedIteration



.finalIteration:
	; fetching Y screen position (tile aligned) to HL
	; this is a bit horrible but idk how to do it better
	ld h, (ix+1)
	ld l, (ix+0)
	inc ix
	inc ix

	; adding X offset to screen position
	ld a, l		; screen position low byte
.offsetX2:
	add a, $00	; add x offset (self modifying code)
	ld l, a		; back into e

	; restoring the Y position stored in shadow register
	ex af, af'
	
	; atm a is pure Y position. it needs to be
	; 1) put into b (after shifting)
	; 2) tested for parity
	ld c, a ; preserve
	rra
	ld b, 00000011b
	and b

	;jr z, .notSureWhatThisIs
	; testing parity
	bit 0, c
	jr z, .isEvenNumber2

.isOddNumber2
	dec sp
	pop de
	ld (hl), d
	inc h

.isEvenNumber2

	ld b, a
	or a ; check if loop iterations = 0
	jr z, .notSureWhatThisIs

.copy_tile_stack3:
	pop de
	ld (hl), e
	inc h
	ld (hl), d 
	inc h
	djnz .copy_tile_stack3

.notSureWhatThisIs
	; restore sp
	ld sp, (saveSP)
	ret


; draws 8x16px (pre-shifted?) sprites
; hopefully this one won't be as overcomplicated as the other one
; inputs:
; HL - grapics pointer,
; B - x position (chars),
; C - y position (pixels). 192-256 are clipping behind the screen
YetAnotherSpriteRoutine:
	; we are going to use the POP instruction to fetch stripe contents later on
	; so we need to disable interrupts & preserve original SP somewhere
	di
	ld (saveSP), sp
	; now the graphics pointer goes to SP 
	; FIXME: BEFORE LOADING INTO SP, APPLY OFFSET TO RETRIEVE PRESHIFTED GFX
	ld sp, hl

	; set up LUT address in HL (assuming memory location is 256b aligned)
	ld h, ScreenYEvenLineLUT/256
	; low byte derived from Y pos value
	ld l, c
	res 0, l 

	; fetch screen position into HL while adding X offset
	ld e, (hl) ; low byte

	;ld a, 11111000b ; mask
	;and a, b ; x position
	;rrca ; rotate 3 times to transform into character position
	;rrca
	;rrca

	ld a, 00011111b ; mask
	and a, b ; x position

	add a, e 

	inc hl
	ld h, (hl) ; high byte
	ld l, a

	; clear a for cleraing a couple pixelz later on
	xor a
	; test parity, if even we can skip The Process
	bit 0, c
	jp z, .isEven
	; if odd, clear 2 lines
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	; setting up loop counter
	ld b, 8
	jr .boundsCheck
.isEven
	; loop counter
	ld b, 8
	; clearing first line & compensating for offset
	pop de;
	ld (hl), a
	inc h
	ld (hl), a
	inc h

	jr .boundsCheck
.copyLoop	; TODO FIX THIS ATROCITY
	pop de ; fetch data
	; 1st byte
	ld (hl), e
	; 2nd byte
	inc l
	ld a, d
	or (hl)
	ld (hl), a
	inc h
	; 2nd iteration (unrolled)
	pop de
	; 2nd byte
	ld a, d
	or (hl)
	ld (hl), a
	;1st byte
	dec l
	ld (hl), e
	inc h
.boundsCheck
	; check if we crossed the boundary
	ld a, h
	and 00000111b
	jr nz, .beforeLoop ; if not, continue loop
	; else adjust position
	ld a, l
	add a, 32
	ld l, a
	jr c, .beforeLoop ; if past the last line in a char, adjust
	ld a, h
	sub 8
	ld h, a

.beforeLoop
	djnz .copyLoop
	; if done, clear four next pixelz
	xor a
	ld (hl), a
	inc h
	ld (hl), a
.end
	; restore sp
	ld sp, (saveSP)
	ret
; draws 8x16px god knows what
; inputs:
; HL - grapics pointer,
; B - x position (chars),
; C - y position (pixels). 192-256 are clipping behind the screen
YetAnotherSpriteRoutineOnlyOR:
	; we are going to use the POP instruction to fetch stripe contents later on
	; so we need to disable interrupts & preserve original SP somewhere
	di
	ld (saveSP), sp
	; now the graphics pointer goes to SP 
	ld sp, hl

	; set up LUT address in HL (assuming memory location is 256b aligned)
	ld h, ScreenYEvenLineLUT/256
	; low byte derived from Y pos value
	ld l, c
	res 0, l 

	; fetch screen position into HL while adding X offset
	ld e, (hl) ; low byte

	ld a, 00011111b ; mask
	and a, b ; x position

	add a, e 

	inc hl
	ld h, (hl) ; high byte
	ld l, a

	; clear a for cleraing a couple pixelz later on
	xor a
	; test parity, if even we can skip The Process
	bit 0, c
	jp z, .isEven
	; if odd, skip 2 lines
	inc h
	inc h
	; setting up loop counter
	ld b, 8
	jr .boundsCheck
.isEven
	; loop counter
	ld b, 8
	; clearing first line & compensating for offset
	pop de;
	inc h
	inc h

	jr .boundsCheck
.copyLoop	; TODO FIX THIS ATROCITY
	pop de ; fetch data
	; 1st byte
	ld a, e
	or (hl)
	ld (hl), a
	inc h
	; 2nd iteration (unrolled)
	pop de
	; 1st byte
	ld a, e
	or (hl)
	ld (hl), a
	inc h
.boundsCheck
	; check if we crossed the boundary
	ld a, h
	and 00000111b
	jr nz, .beforeLoop ; if not, continue loop
	; else adjust position
	ld a, l
	add a, 32
	ld l, a
	jr c, .beforeLoop ; if past the last line in a char, adjust
	ld a, h
	sub 8
	ld h, a

.beforeLoop
	djnz .copyLoop
	; if done, clear four next pixelz
	xor a
	ld (hl), a
	inc h
	ld (hl), a
.end
	; restore sp
	ld sp, (saveSP)
	ret
; draws 8x16px sprites
; hopefully this one won't be as overcomplicated as the other one
; inputs:
; HL - grapics pointer,
; B - x position (chars),
; C - y position (pixels). 192-256 are clipping behind the screen
YetAnotherSpriteRoutineNoPreshift:
	; we are going to use the POP instruction to fetch stripe contents later on
	; so we need to disable interrupts & preserve original SP somewhere
	di
	ld (saveSP), sp
	; now the graphics pointer goes to SP 
	; FIXME: BEFORE LOADING INTO SP, APPLY OFFSET TO RETRIEVE PRESHIFTED GFX
	ld sp, hl

	; set up LUT address in HL (assuming memory location is 256b aligned)
	ld h, ScreenYEvenLineLUT/256
	; low byte derived from Y pos value
	ld l, c
	res 0, l 

	; fetch screen position into HL while adding X offset
	ld e, (hl) ; low byte

	;ld a, 11111000b ; mask
	;and a, b ; x position
	;rrca ; rotate 3 times to transform into character position
	;rrca
	;rrca

	ld a, 00011111b ; mask
	and a, b ; x position

	add a, e 

	inc hl
	ld h, (hl) ; high byte
	ld l, a

	; clear a for cleraing a couple pixelz later on
	xor a
	; test parity, if even we can skip The Process
	bit 0, c
	jp z, .isEven
	; if odd, clear 2 lines
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	; setting up loop counter
	ld b, 8
	jr .boundsCheck
.isEven
	; loop counter
	ld b, 8
	; clearing first line & compensating for offset
	inc sp;
	ld (hl), a
	inc h
	ld (hl), a
	inc h

	jr .boundsCheck
.copyLoop	; TODO FIX THIS ATROCITY
	pop de ; fetch data
	ld (hl), e
	inc h
	ld (hl), d
	inc h
.boundsCheck
	; check if we crossed the boundary
	ld a, h
	and 00000111b
	jr nz, .beforeLoop ; if not, continue loop
	; else adjust position
	ld a, l
	add a, 32
	ld l, a
	jr c, .beforeLoop ; if past the last line in a char, adjust
	ld a, h
	sub 8
	ld h, a

.beforeLoop
	djnz .copyLoop
	; if done, clear four next pixelz
	xor a
	ld (hl), a
	inc h
	ld (hl), a
.end
	; restore sp
	ld sp, (saveSP)
	ret



; generates interleaved, preshifted sprites of arbitrary amount of rotations
; inputs:
; bc - loop iterations
; de - desination
; hl - source
ShiftPrecalc:
	; byteswap the counter before loop
	ld a, b 
	ld b, c
	ld c, a
	inc c
.shiftLoop
	ld a, (hl) ; fetch byte
.jump = $+1
	jr $+2+4
	rrca ; rotate 6 times
	rrca
	rrca ; rotate 4 times
	rrca
	rrca ; rotate 2 times
	rrca
	ld ixl, a ; preserve to not shift again
.mask = $+1
	and 00111111b ; mask
	ld (de), a ; 1st rotated byte
	inc de ; On To The Next
.maskInverted = $+1
	ld a, 11000000b ; mask
	and ixl ; we already have the original byte shifted
	ld (de), a ; 2nd rotated byte
	inc hl ; increment both of those
	inc de
	djnz .shiftLoop ; gonna run for =< 256 iterations
	dec c
	jr nz, .shiftLoop
	ret

; this draws a string backwards (yes backwards, please do not ask)
; inputs:
; de - text pointer
; hl - font lut pointer
; c - x offset (0-3)
DrawTextScroller:
	ld b, 31 ; init counter
	di
	; calculate LUT address based on X offset
	xor a
	or c
	jr nz, .preshifted ; if not zero we dont care about this shit
	; smc to replace call address
	push hl
	ld hl, YetAnotherSpriteRoutineNoPreshift
	ld (.call), hl
	ld (.call2), hl
	pop hl
	jr .ok
.preshifted
	push hl
	ld hl, YetAnotherSpriteRoutine
	ld (.call), hl
	ld (.call2), hl
	pop hl
	; draw one stripe differently
	add a, h
	ld h, a
	ld ix, hl ; gna be fetching pointers thru this methinks
	;clear 1st
	ld hl, $505F
	push bc
	call FastClear
	pop bc
	;fetch letter
	ld a, (de)
	;some checks
	cp 0 ; 0 = terminate
	jp z, .isZero
	cp '@' ; space = idc
	jr z, .after_draw

	rlca
	ld ixl, a
	; loading letter gfx pointer
	ld h, (ix+1)
	ld l, (ix+0)
	; cool
	push bc
	push de
	ld a, 144 ; y position
	add a, (iy+0) ; sin table
	;add a, (iy+0)
	ld c, a
	call YetAnotherSpriteRoutineOnlyOR
	pop de
	pop bc
	dec de
	djnz .loop
.ok
	add a, h
	ld h, a
	ld ix, hl ; gna be fetching pointers thru this methinks
.loop
	;fetch letter
	ld a, (de)
	;some checks
	cp 0 ; 0 = terminate
	jp z, .isZero
	cp '@' ; space = different routine
	jr nz, .no_spacebar
.spacebar
	ld h, $50
	ld a, $40 ; 2 char offset
	add a, b
	ld l, a
	push bc
	call FastClear
	pop bc
	jr .after_draw
.no_spacebar
	rlca
	ld ixl, a
	; loading letter gfx pointer
	ld h, (ix+1)
	ld l, (ix+0)
	; cool
	push bc
	push de
	ld a, 144 ; y position
	add a, (iy+0) ; sin table
	;add a, (iy+0)
	ld c, a
.call = $+1
	call YetAnotherSpriteRoutine
	pop de
	pop bc
.after_draw
	dec de
	; add to sin table pointer
	ld a, 7
	add a, iyl
	ld iyl, a
	djnz .loop
.post_loop
	;fetch letter
	ld a, (de)
	;some checks
	cp 0 ; 0 = terminate
	jr z, .isZero
	cp '@' ; space = different routine
	jr nz, .no_spacebar2
	ld h, $50
	ld a, $40 ; 2 char offset
	add a, b
	ld l, a
	push bc
	call FastClear
	pop bc
	jr .after_draw2
.no_spacebar2
	rlca
	ld ixl, a
	; loading letter gfx pointer
	ld h, (ix+1)
	ld l, (ix+0)
	; cool
	push bc
	push de
	ld a, 144 ; y position
	add a, (iy+0) ; sin table
	;add a, (iy+0)
	ld c, a
.call2 = $+1
	call YetAnotherSpriteRoutine
	pop de
	pop bc
.after_draw2
	dec de
	; add to sin table pointer
	ld a, 7
	add a, iyl
	ld iyl, a
.finalOR
	xor a
	or c
	jr z, .isZero
	;fetch letter
	ld a, (de)
	;some checks
	cp 0 ; 0 = terminate
	jr z, .isZero
	cp '@' ; space = different routine
	jr z, .isZero
	rlca
	ld ixl, a
	; loading letter gfx pointer
	ld h, (ix+1)
	ld l, (ix+0)
	inc hl
	; cool
	ld a, 144 ; y position
	add a, (iy+0) ; sin table
	;add a, (iy+0)
	ld c, a	
	call YetAnotherSpriteRoutineOnlyOR
.isZero
	ret
; fast clear
; hl - address
FastClear:
	ld b, 4
	xor a
.loop
	xor a
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	;adjust	
	ld h, $50
	ld a, 32
	add a, l
	ld l, a
	djnz .loop
	ret
; generates 2*128b font LUT
;inputs:
; ix - destination (offset by 64bytes)
; hl - base address
; de - address increment
GenerateFontLUT:
	;setup
	;ld b, 96 ; counter
	ld b, 64
.loop
	ld (ix+1), h
	ld (ix+0), l
	; increment everything
	add hl, de
	inc ix
	inc ix
	djnz .loop
	ret