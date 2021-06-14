; 8bit unsigned multiplication using 16kb tables
; adapted from https://www.cpcwiki.eu/index.php/Programming:Integer_Multiplication
	MODULE multi
make_tabs:
	ld hl, hltab1
.makelp1:
	ld a, l
	rla
	and $1e
	add restab / 256
	ld (hl), a
	inc l
	jr nz, .makelp1
	inc h
.makelp2:
	ld a, l
	rra : rra : rra
	and $1e
	jr z, .usez
	add (restab2 - restab) / 256 - 2 ; original routine had a bug here due to wrong operation order
.usez:
	add restab / 256
	ld (hl), a
	inc l
	jr nz, .makelp2
	inc h ; restab
.makelp3:
	ld a, (hl)
	inc h
	ld d, (hl)
	inc h
	add l
	ld (hl), a
	inc h
	ld a, 0
	adc d
	ld (hl), a
	dec h : dec h : dec h
	inc l
	jr nz, .makelp3
	inc h
	inc h
	ld a, h
	cp restab2 / 256 - 2
	jr nz, .makelp3
	ld b, h
	ld c, l
	inc b
	inc b
	ld h, restab / 256 + 2
.makelp4:
	ld e, (hl)
	inc h
	ld d, (hl)
	dec h
	ex de, hl
	add hl, hl : add hl, hl : add hl, hl : add hl, hl
	ex de, hl
	ld a, e
	ld (bc), a
	inc b
	ld a, d
	ld (bc), a
	dec b
	inc l
	inc c
	jr nz, .makelp4
	inc h
	inc h
	inc b
	inc b
	ld a, h
	cp restab2 / 256
	jr nz, .makelp4
	ret
; unsigned mutiply
; inputs: 
; l - multiplier, 
; c - multiplicand.
; outputs:
; de - product.
; trashes af, bc, hl
multiply_unsigned:
	ld h, hltab1 / 256
	ld b, (hl)
	inc h
	ld h, (hl)
	ld l, c
	ld a, (bc)
	add (hl)
	ld e, a
	inc b
	inc h
	ld a, (bc)
	adc (hl)
	ld d, a
	ret
; hacked up 8bit signed mutiply with 6bit fixed point. proof of concept.
; inputs: 
; h - multiplier, 
; l - multiplicand.
; outputs:
; d - product.
; trashes af, bc, hl
multiply_signed:
	push hl
	ld a, h
	; handle negative numbers
	bit 7, a
	jr z, .positive1
	neg
.positive1
	sla a;rlca ; rotate so result iscorrect
	ld c, a
	; On To The Next
	ld a, l
	; handle negative numbers
	bit 7, a
	jr z, .positive2
	neg
.positive2
	sla a;rlca
	ld l, a
	; l/c need to be the multiplier/multiplicand for section here
	ld h, hltab1 / 256
	ld b, (hl)
	inc h
	ld h, (hl)
	ld l, c
	ld a, (bc)
	add (hl)
	;ld e, a
	inc b
	inc h
	ld a, (bc)
	adc (hl)
	ld d, a
	; adjust for negative
	pop hl
	ld a, l
	xor h
	and 10000000b
	jr z, .positive3
	ld a, d
	neg
	ld d, a
.positive3
	ret

multiply_signed_another:
	push hl
	ld a, h
	; handle negative numbers
	bit 7, a
	jr z, .positive1
	neg
.positive1
	;srl a; rlca ; rotate so result iscorrect
	ld c, a
	; On To The Next
	ld a, l
	; handle negative numbers
	bit 7, a
	jr z, .positive2
	neg
.positive2
	;srl a
	ld l, a
	; l/c need to be the multiplier/multiplicand for section here
	ld h, hltab1 / 256
	ld b, (hl)
	inc h
	ld h, (hl)
	ld l, c
	ld a, (bc)
	add (hl)
	;ld e, a
	inc b
	inc h
	ld a, (bc)
	adc (hl)
	ld d, a
	; adjust for negative
	pop hl
	ld a, l
	xor h
	and 10000000b
	jr z, .positive3
	ld a, d
	neg
	ld d, a
.positive3
	ret



PEPE:
	ORG $C000, 6
hltab1:
	BLOCK 256
hltab2:
	BLOCK 256
restab:
	BLOCK 512 * 16
restab2:
	BLOCK 512 * 15
restab_end:
	ORG PEPE, 0
	ENDMODULE