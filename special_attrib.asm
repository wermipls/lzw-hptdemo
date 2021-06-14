AlternateAttributes:
	; test which value is toggled
	ld a, (.state)
	or a
	jr nz, .isTrue
	ld a, 1 ; set
	ld (.state), a
	ld a, (.fillData)
	jp .fillInit
.isTrue:
	xor a ; reset
	ld (.state), a
	ld a, (.fillData+1)
.fillInit:
	ld d, a
	ld e, a
	;push de
	; lets check if using shadow screen
	ld a, (paging.port_backup)
	bit 3, a
	jr z, .screen_zero
	ld a, 7 ; normal screen
	call paging.temp_set_bank
	jr .screen_done
.screen_zero
	ld a, 5 ; shadow screen
	call paging.temp_set_bank
.screen_done
	;pop de
	ld hl, $DB00
	call fast_attrib_fill
	call paging.restore_value
	ret
.fillData:
	db 01000110b
	db 01000100b
.state:
	db 0