; inputs:
; de - attrib data for fill
; hl - attrib end pointer
fast_attrib_fill:
	ld b, 768/16 ; bytes to copy
fast_attrib_fill_arbitrary_loopcount:
	ld (.saveSP), sp
	ld sp, hl
.loop
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	djnz .loop
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret