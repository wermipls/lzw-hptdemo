clear_2b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 2 bytes
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_4b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 4 bytes
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_6b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 6 bytes
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_8b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 8 bytes
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_10b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 10 bytes
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_12b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 12 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_14b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 14 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_16b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 16 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_18b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 18 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_20b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 20 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_22b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 22 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_24b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 24 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_26b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 26 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_28b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 28 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_30b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 30 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret

clear_32b:
	ld b, 8 ; loop iterations (8 lines)
	; save & redirect stack
	ld (.saveSP), sp
.loop
	ld sp, hl
	; clear 32 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	inc h
	djnz .loop
	; restore stack
.saveSP = $+1
	ld sp, 0 ; will get overwritten
	ret