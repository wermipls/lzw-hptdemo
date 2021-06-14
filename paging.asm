; some paging helper routines.
; input is a register,
; bc will get trashed in pretty much all cases.
	MODULE paging
;port_backup equ $5B5C

; toggles currently displayed screen
toggle_screen:
	ld a, (port_backup)
	xor 00001000b
	jr set_value
; sets bank (0-7) while keeping other bits
set_bank:
	ld c, a
	ld a, (port_backup)
	and 11111000b
	or c
; outputs arbitrary value to port
set_value:
	ld bc, $7FFD
	out (c), a
	ld (port_backup), a
	ret
; sets bank, able to restore previous val by restore routine
temp_set_bank:
	ld c, a
	ld a, (port_backup)
	ld (port_stored), a
	jr set_bank+4
; restores previous bank/screen setting
restore_value:
	ld a, (port_stored)
	jr set_value
port_backup:
	db 0
port_stored:
	db 0
	ENDMODULE
