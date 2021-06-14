BorderTransition:
	;ld a, (paging.port_backup)
	;ld (.portbackup), a
	ld a, 7
	call paging.set_bank
	call BorderTransitionHelper
	ld a, 5
	call paging.set_bank
	call BorderTransitionHelper


	ld hl, BorderTransitionHelper.line
	ld a, (hl)
	cp 24
	jp z, .noinc
	inc (hl)
.noinc
	;ld a, (.portbackup)
	;call paging.set_bank
	ret

;.portbackup
;	db 0


BorderTransitionHelper:
	; check if line bigger than 24, if so ignore
	ld a, (.line)
	cp 24
	jr z, .end
	cp 2 ; check for special case
	jr c, .full_clear
	cp 22
	jr nc, .full_clear
.twoside_clear
	ld c, a ; set y pos
	ld e, a
	ld b, 0
	ld d, 5
	push bc
	push de
	ld hl, 0
	call bounding_box_clear
	pop de
	pop bc
	ld b, 26
	ld d, 31
	ld hl, 0
	call bounding_box_clear
	jp .colorchange
.full_clear
	ld c, a ; set y pos
	ld e, a
	ld b, 0
	ld d, 31
	ld hl, 0
	call bounding_box_clear
.colorchange
	ld hl, .line
	;inc (hl)
	ld a, (hl)
	inc a
	ld b, 0
	rla ; rotate 5 times
	rl b
	rla 
	rl b
	rla 
	rl b
	rla 
	rl b
	rla 
	rl b
	ld c, a
	ld hl, $D800
	add hl, bc
	ld de, 0100001101000011b
	ld b, 2 ; 32 bytes
	call fast_attrib_fill_arbitrary_loopcount
.end
	ret
.line
	db 0