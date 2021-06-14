	ORG $C000, 1
	INCLUDE "animation_data.asm"
BorderCompressed:
	INCBIN "border_full.aplib"

	ORG $C000, 3
	INCLUDE "animation_data_end.asm"

	ORG MAIN_ANIM

ANIM_PLAY_SEQUENCE:
	; calculate target frame
	halt
	;ld a, (GLOBAL_TIMER)
	;add a, (iy+0)
	ld a, (iy+0)
	dec a
	ld (ANIM_DRAWTIME), a ; save
.loop
	push bc ; preserve

	; set up page with compressed frames data
.smc_page = $+1
	ld a, 1
	call paging.set_bank
	; depack
	ld h, (ix+1)
	ld l, (ix+0)
	ld de, ANIM_UNPACKED
	push iy
	push ix
	CALL APLIB.depack
	pop ix
	pop iy

	; lets check if using shadow screen
	ld a, (paging.port_backup)
	bit 3, a
	jr z, .screen_zero
	ld a, 5 ; normal screen
	call paging.set_bank
	jr .screen_done
.screen_zero
	ld a, 7 ; shadow screen
	call paging.set_bank
.screen_done
	; copy data
	ld de, $C046
	ld hl, ANIM_UNPACKED
	CALL AnimationParseCopyData


	; check if target frame
.wait_target
	halt
	;ld a, (GLOBAL_TIMER)
	ld hl, ANIM_DRAWTIME
	bit 7, (hl)
	jr z, .wait_target

	pop bc
	push bc
	dec b
	jp z, .skiptoggle
	call paging.toggle_screen

	; calculate target frame 
	inc iy
	;ld a, (GLOBAL_TIMER)
	;add a, (iy+0)
	ld a, (iy+0)
	dec a
	ld (ANIM_DRAWTIME), a ; save

.skiptoggle
	pop bc
	; increment
	inc ix
	inc ix

	djnz .loop
	;di
	halt
	ret

DecrementDrawtime:
	ld a, (ANIM_DRAWTIME)
	dec a
	ld (ANIM_DRAWTIME), a
	ret

	INCLUDE "animation_funcs.asm"
	INCLUDE "./animation_metadata.asm"
	INCLUDE "./animation_metadata_end.asm"
	INCLUDE "animation_border.asm"
ANIM_DRAWTIME:
	BLOCK 1
ANIM_UNPACKED:
	BLOCK(3600)