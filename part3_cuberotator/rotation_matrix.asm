; inputs: 
; l - angle,
; ix - matrix pointer (9 bytes)
RotationMatrix_X:
	ld ixh, b
	ld ixl, c
	ld (ix+0), 64
	; sin(x)
	ld h, trig.sintable/256
	ld a, (hl)
	ld (ix+7), a
	neg
	ld (ix+5), a
	; cos(x)
	ld a, 64
	add l
	ld l, a
	ld a, (hl)
	ld (ix+4), a
	ld (ix+8), a
	ret

; prepares simplified 3d rotation matrix
; i.e. can rotate in 3 axis, but angles are all 1 variable
; inputs: 
; l - angle,
; ix - temp data pointer (8 bytes)
; bc - matrix pointer (9 bytes)
SimpleRotationMatrix:
	; preserve matrix pointer
	push bc
	; prepare some vals for recycling
	; angle value will be referred to as "x" from now on

	; sin(x)
	ld h, trig.sintable/256
	ld a, (hl)
	ld (ix+0), a
	; cos(x)
	ld a, 64
	add a, l
	ld l, a
	ld a, (hl)
	ld (ix+1), a
	; cos(x)*cos(x)
	ld l, a
	ld h, a
	call multi.multiply_signed
	ld (ix+3), d
	; sin(x)*sin(x)
	ld l, (ix+0) ; sin(x)
	ld h, l
	call multi.multiply_signed
	ld (ix+2), d
	; sin(x)*cos(x)
	ld h, (ix+0) ; sin(x)
	ld l, (ix+1) ; cos(x)
	call multi.multiply_signed
	ld (ix+4), d
	; sin(x)*sin(x)*sin(x)
	ld h, (ix+2) ; sin(x)*sin(x)
	ld l, (ix+0) ; sin(x)
	call multi.multiply_signed
	ld (ix+7), d
	; sin(x)*cos(x)*cos(x)
	ld h, (ix+3) ; cos(x)*cos(x)
	ld l, (ix+0) ; sin(x)
	call multi.multiply_signed
	ld (ix+6), d
	; cos(x)*sin(x)*sin(x)
	ld h, (ix+2) ; sin(x)*sin(x)
	ld l, (ix+1) ; cos(x)
	call multi.multiply_signed
	ld (ix+5), d

	; resulting data should look like this for ix offsets:
	; 0 - sin(x)
	; 1 - cos(x)
	; 2 - sin(x)*sin(x)
	; 3 - cos(x)*cos(x)
	; 4 - sin(x)*cos(x)
	; 5 - cos(x)*sin(x)*sin(x)
	; 6 - sin(x)*cos(x)*cos(x)
	; 7 - sin(x)*sin(x)*sin(x)
	
	; filling the actual matrix
	pop hl ; restore pointer
	; loading some vals ahead of time
	ld b, (ix+2)
	ld c, (ix+3)
	ld d, (ix+4)
	ld e, (ix+5)

	; 1st row
	ld (hl), c
	inc hl
	;
	ld a, e
	sub d
	ld (hl), a
	ld e, a ; preserve result
	inc hl
	;
	ld a, (ix+6)
	add b
	ld (hl), a
	inc hl
	; 2nd row
	ld (hl), d
	inc hl
	;
	ld a, (ix+7)
	add c
	ld (hl), a
	inc hl
	;
	ld (hl), e
	inc hl
	; 3rd row
	ld a, (ix+0)
	neg
	ld (hl), a
	inc hl
	;
	ld (hl), d
	inc hl
	;
	ld (hl), c

	; DONE
	ret
; inputs: 
; l - angle,
; ix - temp data pointer (8 bytes)
; bc - matrix pointer (9 bytes)
/*
AnotherRotationMatrix:
	; preserve matrix pointer
	push bc
	; prepare some vals for recycling
	; angle value will be referred to as "x" from now on
	; the other angle (y) will be derived from global time
	; sin(x)
	ld h, trig.sintable/256
	ld a, (hl)
	ld (ix+0), a
	; cos(x)
	ld a, 64
	add a, l
	ld l, a
	ld a, (hl)
	ld (ix+1), a
	; sin(y)
	ld a, (GLOBAL_TIMER)
	add a, 15
	and 11111110b ; mask
	ld l, a
	ld a, (hl)
	ld (ix+2), a
	; cos(y)
	ld a, 64
	add a, l
	ld l, a
	ld a, (hl)
	ld (ix+3), a
	; sin(y)*sin(y)
	ld l, (ix+2) ; sin(y)
	ld h, l
	call multi.multiply_signed
	ld (ix+4), d
	; cos(y)*sin(y)
	ld l, (ix+2) ; sin(y)
	ld h, (ix+3) ; cos(y)
	call multi.multiply_signed
	ld (ix+5), d
	; cos(y)*cos(x)
	ld l, (ix+1) ; cos(x)
	ld h, (ix+3) ; cos(y)
	call multi.multiply_signed
	ld (ix+6), d
	; cos(y)*sin(x)
	ld l, (ix+0) ; sin(x)
	ld h, (ix+3) ; cos(y)
	call multi.multiply_signed
	ld (ix+7), d
	; cos(y)*cos(y)
	ld l, (ix+3) ; cos(y)
	ld h, l
	call multi.multiply_signed
	ld (ix+8), d
	; sin(y)*cos(x)
	ld l, (ix+1) ; cos(x)
	ld h, (ix+2) ; sin(y)
	call multi.multiply_signed
	ld (ix+9), d
	; sin(y)*sin(x)
	ld l, (ix+0) ; sin(x)
	ld h, (ix+2) ; sin(y)
	call multi.multiply_signed
	ld (ix+10), d
	; ix[5]*ix[0]
	ld l, (ix+5)
	ld h, (ix+0)
	call multi.multiply_signed
	ld (ix+11), d	
	; ix[5]*ix[1]
	ld l, (ix+5)
	ld h, (ix+1)
	call multi.multiply_signed
	ld (ix+12), d	
	; ix[4]*ix[0]
	ld l, (ix+4)
	ld h, (ix+0)
	call multi.multiply_signed
	ld (ix+13), d	
	; ix[4]*ix[1]
	ld l, (ix+4)
	ld h, (ix+1)
	call multi.multiply_signed
	ld (ix+14), d	


	; resulting data should look like this for ix offsets:
	; ix[0] = sin(x)
	; ix[1] = cos(x)
	; ix[2] = sin(y)
	; ix[3] = cos(y)
	; 
	; ix[4] = sin(y)*sin(y)
	; ix[5] = cos(y)*sin(y)
	; ix[6] = cos(y)*cos(x)
	; ix[7] = cos(y)*sin(x)
	; 
	; ix[8] = cos(y)*cos(y)
	; ix[9] = sin(y)*cos(x)
	; ix[10] = sin(y)*sin(x)

	; ix[11] = ix[5]*ix[0]
	; ix[12] = ix[5]*ix[1]
	; ix[13] = ix[4]*ix[0]
	; ix[14] = ix[4]*ix[1]

	; filling in the actual matrix
	pop hl ; restore pointer
	; loading some common vals
	ld b, (ix+0)
	ld c, (ix+1)
	ld d, (ix+6)
	ld e, (ix+7)

	; 1st row
	ld a, (ix+8)
	ld (hl), a
	inc hl

	ld a, (ix+11)
	sub (ix+9)
	ld (hl), a
	inc hl

	ld a, (ix+12)
	add a, (ix+10)
	ld (hl), a
	inc hl

	; 2nd row
	ld a, (ix+5)
	ld (hl), a
	inc hl

	ld a, (ix+13)
	add a, d
	ld (hl), a
	inc hl

	ld a, (ix+14)
	sub e
	ld (hl), a
	inc hl

	; 3rd row
	ld a, (ix+2)
	neg
	ld (hl), a
	inc hl

	ld (hl), e
	inc hl

	ld (hl), d
	
	; .done
	ret
*/


; multiplies 8bit 3x3 matrix by a 8bit 1x3 matrix.
; inputs:
; ix - 1st matrix pointer,
; ix+9 - temp (8 bytes)
; iy - 2nd matrix pointer.
; outputs:
; ix+9 - result (3 bytes)
MultiplyMatrices:
	; row 1
	; 1
	ld h, (ix+0)
	ld l, (iy+0)
	call multi.multiply_signed
	ld (ix+9), d
	; 2
	ld h, (ix+1)
	ld l, (iy+1)
	call multi.multiply_signed
	ld (ix+10), d
	; 3
	ld h, (ix+2)
	ld l, (iy+2)
	call multi.multiply_signed
	; sum it all
	ld a, (ix+9)
	add a, d
	add a, (ix+10)
	; save
	ld (ix+9), a
	; row 2
	; 1
	ld h, (ix+3)
	ld l, (iy+0)
	call multi.multiply_signed
	ld (ix+12), d
	; 2
	ld h, (ix+4)
	ld l, (iy+1)
	call multi.multiply_signed
	ld (ix+13), d
	; 3
	ld h, (ix+5)
	ld l, (iy+2)
	call multi.multiply_signed
	; sum it all
	ld a, (ix+12)
	add a, d
	add a, (ix+13)
	; save
	ld (ix+10), a
	; row 3
	; 1
	ld h, (ix+6)
	ld l, (iy+0)
	call multi.multiply_signed
	ld (ix+15), d
	; 2
	ld h, (ix+7)
	ld l, (iy+1)
	call multi.multiply_signed
	ld (ix+16), d
	; 3
	ld h, (ix+8)
	ld l, (iy+2)
	call multi.multiply_signed
	; sum it all
	ld a, (ix+15)
	add a, d
	add a, (ix+16)
	; save
	ld (ix+11), a
	ret

