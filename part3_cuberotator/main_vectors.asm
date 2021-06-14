	MODULE vectys
precalc:
	ld a, 6
	call paging.set_bank
	; this crappy routine i found on the internet requires zeroes in certain
	; places in memory for whatever reason and doesnt tell u !
	; so gotta clear it first
	xor a
	ld hl, $C000
	ld de, $C000+1
	ld bc, $400
	ld (hl), a
	ldir
	jp multi.make_tabs
	ret
main_loop:
	push hl
	halt
	call paging.toggle_screen

	call ScreenCheck
	ld hl, 0
	ld bc, (extrema_old.min)
	ld de, (extrema_old.max)
	call bounding_box_clear

	pop hl
	ld a, 6 ; mul table bank
	call paging.set_bank

	ld bc, MACHUCHURIX
	ld ix, TEMP_DATA_MATMUL_RESULT
.call_rotmatrix = $+1
	call RotationMatrix_X

	; matrix multiplication loop
	ld hl, (current.vertcount)
	ld b, (hl)
	ld iy, (current.vertices)
.matloop
	ld ix, MACHUCHURIX
	push bc
	push iy
	call MultiplyMatrices
	; copy data
	pop hl
	push hl
.smc_rotminusvert = $+1
	ld bc, vertices_rotated-cube.vertices ; ld bc, vertices_rotated-cube.vertices
	add hl, bc
	ex de, hl
	ld hl, TEMP_DATA_MATMUL_RESULT
	ldi
	ldi
	ldi
	; restore addr & add offset
	ld bc, 3
	pop iy
	add iy, bc
	;counter
	pop bc
	djnz .matloop


	;trans late x
.smc_translate_call = $+1
	call DUMMY


	; putting things into perspective
	ld hl, (current.vertcount)
	ld b, (hl)
	ld ix, vertices_rotated
.perspective_loop
	push bc
	ld a, (ix+2) ; z coord
	add a, 127
	srl a
	srl a
	srl a
.smc_scale = $+1
	add a, 24;49 ; HOW BIG CUBE IS, biggest for 160x160 = 28, biggest for 25fps is, ironically, probably 25
	ld h, a
	ex af, af' ; preserve
	; x axis
	ld l, (ix+0)
	call multi.multiply_signed
	ld a, 128 ; offset
	add a, d
	ld (ix+0), a
	ex af, af'
	ld h, a
	; y axis
	ld l, (ix+1)
	call multi.multiply_signed
	ld a, 96 ; offset
	add a, d
	ld (ix+1), a
	pop bc
	inc ix
	inc ix
	inc ix
	djnz .perspective_loop

	; Back Face Culling
	; using this simple method i found in a youtube comment
	; (v2.x - v1.x)*(v0.y - v1.y) - (v2.y - v1.y)*(v0.x - v1.x)
	; if result negative, dont draw the face
	ld ix, (current.face_indices)
	inc ix
	inc ix
	ld a, (ix-2)
	ld iyl, a ; loop iterations
	ld b, 0
	call backface_test

	; loop that sets line visibility
	ld ix, (current.face_indices)
	inc ix
	inc ix
	ld iy, (current.face_line_indices)
	ld hl, (current.line_indices)
	inc hl
	ld b, (ix-2)
	push hl
.line_visibility_loop
	xor a
.line_smc_or = $+2
	or (ix+0)
	; CHANGE THIS
	jp nz, .line_visibility_loop_no
	ld d, 0
	ld a, (current.vert_per_face)
	ld c, a
.vert_loop
	pop hl
	push hl
	ld e, (iy+0)
	add hl, de
	ld (hl), 0
	inc iy
	inc ix
	dec c
	jp nz, .vert_loop
	jp .past_vert_loop
.line_visibility_loop_no
	ld a, (current.vert_per_face)
	ld c, a
.ix_adjust_loop
	inc ix
	inc iy
	dec c
	jp nz, .ix_adjust_loop
.past_vert_loop
	inc ix
	djnz .line_visibility_loop
	pop hl
	

/*
	; lets check if using shadow screen
	 ; normal variant
	ld a, (paging.port_backup)
	bit 3, a
	jr z, .screen_zero
	ld a, 7 ; normal screen
	call paging.set_bank
	jr .screen_done
.screen_zero
	ld a, 5 ; shadow screen
	call paging.set_bank
.screen_done
*/	
	/* ; DEBUG variant
	ld a, (paging.port_backup)
	bit 3, a
	jr z, .screen_zero
	ld a, 7 ; normal screen
	call paging.set_bank
	jr .screen_done
.screen_zero
	ld a, 5 ; shadow screen
	call paging.set_bank
.screen_done
	*/
	call ScreenCheck

	;halt
	;call paging.toggle_screen
	;  get extrema
	ld hl, vertices_rotated
	call GetExtrema

	; clear screen first
	/*
	ld bc, 6*256 + 2
	ld de, 25*256 + 2+19
	ld hl, 0
	call bounding_box_clear
	*/

	; loop thru lines
	ld ix, (current.line_indices)
	inc ix
	ld a, (ix-1) ; loop iterations
	ld iyl, a
.line_loop
	ld hl, vertices_rotated
	; fetch 1st line point
	; check if already drawn
	xor a
	or (ix+0)
	jp z, .line_loop_notdrawn
	inc ix
	inc ix
	inc ix
	dec iyl
	jp nz, .line_loop
	jr .line_loop_end
.line_loop_notdrawn
	ld (ix+0), 1
	inc ix
	; need to get index 1st
	ld b, 0
	ld c, (ix+0)
	push hl ; preserve og address
	add hl, bc
	;ld a, 0 ; offset
	ld c, (hl) ; x coord 
	;ld c, a
	inc hl 
	;ld a, 0 ; offset
	ld b, (hl) ; y coord 
	;ld b, a

	inc ix
	pop hl
	ld d, 0
	ld e, (ix+0)
	add hl, de
	;ld a, 0 ; offset
	ld e, (hl) ; x coord 
	;ld e, a
	inc hl 
	;ld a, 0 ; offset
	ld d, (hl) ; y coord 
	;ld d, a

	inc ix

	call bresenham_calc_pos

	dec iyl
	jp nz, .line_loop
.line_loop_end
	; restore original paging
	;call paging.restore_value
	ret

extrema:
.min:
	db 2,6
.max:	
	db 21,25
extrema_old:
.min:
	db 2,6
.max:	
	db 21,25


translatex_helper:
	; translate x
	ld a, (XTRANSLATE_ANGLE)
	ld l, a
	inc a
	ld (XTRANSLATE_ANGLE), a
	ld h, trig.sintable_crazy/256
	ld c, (hl)
	;ld c, 63
	ld hl, vertices_rotated
	jp TranslateX
	

XTRANSLATE_ANGLE:
	db 0

tetra:
.line_indices:
	dw tetrahedron.line_indices
.face_indices:
	dw tetrahedron.face_indices
.face_line_indices:
	dw tetrahedron.face_line_indices
.vertices:
	dw tetrahedron.vertices
.vertcount
	dw tetrahedron.vertcount
.vert_per_face
	db 3
.end

current:
.line_indices:
	dw cube.line_indices
.face_indices:
	dw cube.face_indices
.face_line_indices:
	dw cube.face_line_indices
.vertices:
	dw cube.vertices
.vertcount
	dw cube.vertcount
.vert_per_face
	db 4
.end
/*
icosa_pointers:
.line_indices:
	dw icosahedron.line_indices
.face_indices:
	dw icosahedron.face_indices
.face_line_indices:
	dw icosahedron.face_line_indices
.vertices:
	dw icosahedron.vertices
.vertcount
	dw icosahedron.vertcount
.vert_per_face
	db 3
.end*/

tetrahedron
.line_indices:
	db 6 ; line count
	; 1st val - should the drawing be skipped
	; 2 remaining vals r the indices
	; everything multiplied by 3 cuz each vert has 3 coords
	db 1,	0*3, 1*3
	db 1,	0*3, 2*3
	db 1,	0*3, 3*3
	db 1,	1*3, 2*3
	db 1,	2*3, 3*3
	db 1,	3*3, 1*3
.vertcount
	db 4
.vertices:
	db 0, -96, 0
	db 78, 32, 45
	db -78, 32, 45
	db 0, 32, -90
.face_indices
	db 4 ; face count
	db 3 ; triangles or quads
	; everything multiplied by 3 cuz each vert has 3 coords
	; first number = is displayed / partial cross product
	db 0, 	0*3, 1*3, 2*3
	db 0, 	0*3, 2*3, 3*3
	db 0, 	0*3, 3*3, 1*3
	db 0, 	1*3, 3*3, 2*3
.face_line_indices
	; everything multiplied by 3 cuz each line has 3 bytes
	db 0*3, 1*3, 3*3
	db 1*3, 2*3, 4*3
	db 2*3, 0*3, 5*3
	db 3*3, 4*3, 5*3


cube
.line_indices:
	db 12 ; line count
	; everything multiplied by 3 cuz each vert has 3 coords
	/*db 1,	0*3, 1*3
	db 1,	1*3, 3*3
	db 1,	3*3, 2*3
	db 1,	2*3, 0*3
	db 1,	3*3, 7*3
	db 1,	7*3, 6*3
	db 1,	6*3, 2*3
	db 1,	7*3, 5*3
	db 1,	5*3, 4*3
	db 1,	4*3, 6*3
	db 1,	5*3, 1*3
	db 1,	0*3, 4*3
	*/
	db 1,	0*3, 1*3
	db 1,	1*3, 2*3
	db 1,	2*3, 3*3
	db 1,	3*3, 0*3
	db 1,	2*3, 4*3
	db 1,	4*3, 5*3
	db 1,	5*3, 3*3
	db 1,	4*3, 6*3
	db 1,	6*3, 7*3
	db 1,	7*3, 5*3
	db 1,	6*3, 1*3
	db 1,	0*3, 7*3
.vertcount
	db 8
.vertices:
	
	db  64,  64,  64
	db  64, -64,  64
	db  64, -64, -64
	db  64,  64, -64
	db -64, -64, -64
	db -64,  64, -64
	db -64, -64,  64 
	db -64,  64,  64
	
	/*
	db  32,  32,  32
	db  32, -32,  32
	db  32, -32, -32
	db  32,  32, -32
	db -32, -32, -32
	db -32,  32, -32
	db -32, -32,  32 
	db -32,  32,  32
	*/
.face_indices
	db 6 ; face count
	db 4 ; triangles or quads
	; everything multiplied by 3 cuz each vert has 3 coords
	; last number = is displayed / partial cross product
	/*db 0,	2*3, 3*3, 7*3, 6*3
	db 0,	0*3, 1*3, 3*3, 2*3
	db 0,	6*3, 7*3, 5*3, 4*3
	db 0,	4*3, 5*3, 1*3, 0*3
	db 0,	2*3, 6*3, 4*3, 0*3
	db 0,	7*3, 3*3, 1*3, 5*3
	*/
	db 0,	0*3, 1*3, 2*3, 3*3
	db 0,	3*3, 2*3, 4*3, 5*3
	db 0,	5*3, 4*3, 6*3, 7*3
	db 0,	7*3, 6*3, 1*3, 0*3
	db 0,	3*3, 5*3, 7*3, 0*3
	db 0,	4*3, 2*3, 1*3, 6*3

.face_line_indices
	/*db 0*3, 1*3, 2*3, 3*3
	db 2*3, 4*3, 5*3, 6*3
	db 5*3, 7*3, 8*3, 9*3
	db 8*3, 10*3, 0*3, 11*3
	db 6*3, 9*3, 11*3, 3*3
	db 4*3, 1*3, 10*3, 7*3
	*/
	db 0*3, 1*3, 2*3, 3*3
	db 2*3, 4*3, 5*3, 6*3
	db 5*3, 7*3, 8*3, 9*3
	db 8*3, 10*3, 0*3, 11*3
	db 6*3, 9*3, 11*3, 3*3
	db 4*3, 1*3, 10*3, 7*3
/*
icosahedron:
.line_indices:
	db 30 ; line count
	db 1,	0*3, 1*3
	db 1,	1*3, 2*3
	db 1,	2*3, 0*3
	db 1,	0*3, 3*3
	db 1,	3*3, 4*3
	db 1,	4*3, 0*3
	db 1,	5*3, 2*3
	db 1,	2*3, 6*3
	db 1,	6*3, 5*3
	db 1,	5*3, 7*3
	db 1,	7*3, 3*3
	db 1,	3*3, 5*3
	db 1,	8*3, 9*3
	db 1,	9*3, 1*3
	db 1,	1*3, 8*3
	db 1,	8*3, 4*3
	db 1,	4*3, 10*3
	db 1,	10*3, 8*3
	db 1,	11*3, 6*3
	db 1,	6*3, 9*3
	db 1,	9*3, 11*3
	db 1,	11*3, 10*3
	db 1,	10*3, 7*3
	db 1,	7*3, 11*3
	db 1,	4*3, 1*3
	db 1,	6*3, 7*3
	db 1,	5*3, 0*3
	db 1,	8*3, 11*3
	db 1,	9*3, 2*3
	db 1,	3*3, 10*3
.vertcount
	db 12
.vertices
	db 80, 0, -50
	db 0, 50, -80
	db 50, 80, -0
	db 50, -80, 0
	db 0, -50, -80
	db 80, 0, 50
	db 0, 50, 80
	db 0, -50, 80
	db -80, 0, -50
	db -50, 80, -0
	db -50, -80, 0
	db -80, 0, 50
.face_indices
	db 20 ; face count
	db 3 ; triangles or quads
	db 0,	0*3, 1*3, 2*3
	db 0,	0*3, 3*3, 4*3
	db 0,	5*3, 2*3, 6*3
	db 0,	5*3, 7*3, 3*3
	db 0,	8*3, 9*3, 1*3
	db 0,	8*3, 4*3, 10*3
	db 0,	11*3, 6*3, 9*3
	db 0,	11*3, 10*3, 7*3
	db 0,	0*3, 4*3, 1*3
	db 0,	8*3, 1*3, 4*3
	db 0,	5*3, 6*3, 7*3
	db 0,	11*3, 7*3, 6*3
	db 0,	2*3, 5*3, 0*3
	db 0,	3*3, 0*3, 5*3
	db 0,	9*3, 8*3, 11*3
	db 0,	10*3, 11*3, 8*3
	db 0,	1*3, 9*3, 2*3
	db 0,	6*3, 2*3, 9*3
	db 0,	4*3, 3*3, 10*3
	db 0,	7*3, 10*3, 3*3
.face_line_indices
	db 0*3, 1*3, 2*3
	db 3*3, 4*3, 5*3
	db 6*3, 7*3, 8*3
	db 9*3, 10*3, 11*3
	db 12*3, 13*3, 14*3
	db 15*3, 16*3, 17*3
	db 18*3, 19*3, 20*3
	db 21*3, 22*3, 23*3
	db 5*3, 24*3, 0*3
	db 14*3, 24*3, 15*3
	db 8*3, 25*3, 9*3
	db 23*3, 25*3, 18*3
	db 6*3, 26*3, 2*3
	db 3*3, 26*3, 11*3
	db 12*3, 27*3, 20*3
	db 21*3, 27*3, 17*3
	db 13*3, 28*3, 1*3
	db 7*3, 28*3, 19*3
	db 4*3, 29*3, 16*3
	db 22*3, 29*3, 10*3
*/
vertices_rotated:
	BLOCK 8*3 
MACHUCHURIX:
	BLOCK 9
TEMP_DATA_MATMUL_RESULT:
	BLOCK 15

	INCLUDE "vectors_helpers.asm"
	ENDMODULE
	INCLUDE "drawing.asm"
	INCLUDE "trig.asm"
CREDITS_RELOCATE
	INCLUDE "border_transition.asm"
	INCLUDE "rotation_matrix.asm"
	INCLUDE "multiplication.asm"