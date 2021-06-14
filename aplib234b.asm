	MODULE APLIB
;
;  speed-optimized aplib decompressor (v.2 12/11/2018-06/08/2019, 234 bytes)
;
;  original decompressor was written by Dan Weiss (Dwedit),
;  tweaked by utopian, and optimized by Metalbrain
;
;  completely re-written for speed by spke
;  (it is 13 bytes shorter and 12% faster than the 247b version by Metalbrain)
;
;  the decompression is done in the standard way:
;
;  ld hl,CompressedData
;  ld de,WhereToDecompress
;  call Decompress
;
;  the decompressor modifies AF, AF', BC, DE, HL, IX
;
;  drop me an email if you have any comments/ideas/suggestions: zxintrospec@gmail.com
;


depack:      ld a,128 : jr LWM0.CASE0


;==================================================================================================================
;==================================================================================================================
;==================================================================================================================


LWM0:         ;LWM = 0 (LWM stands for "Last Was Match"; a flag that we did not have a match)


.ReloadByteC0      ld a,(hl) : inc hl : rla
         jr c,.Check2ndBit


;
;  case "0"+BYTE: copy a single literal


.CASE0:         ldi                  ; first byte is always copied as literal


;
;  main decompressor loop


.MainLoop:      add a : jr z,.ReloadByteC0 : jr nc,.CASE0   ; "0"+BYTE = copy literal
.Check2ndBit      add a : call z,ReloadByte : jr nc,.CASE10   ; "10"+gamma(offset/256)+BYTE+gamma(length) = the main matching mechanism
         add a : call z,ReloadByte : jp c,LWM1.CASE111   ; "110"+[oooooool] = matched 2-3 bytes with a small offset


;
;  branch "110"+[oooooool]: copy two or three bytes (bit "l") with the offset -1..-127 (bits "ooooooo"), or stop


.CASE110:      ; "use 7 bit offset, length = 2 or 3"
         ; "if a zero is found here, it's EOF"
         ld c,(hl) : rr c : ret z         ; process EOF
         inc hl
         ld b,0


         ld iyl,c : ld iyh,b            ; save offset for future LWMs


         push hl                  ; save src
         ld h,d : ld l,e               ; HL = dest
         jr c,.LengthIs3


.LengthIs2      sbc hl,bc
         ldi : ldi
         jr .PreMainLoop


.LengthIs3      or a : sbc hl,bc
         ldi : ldi : ldi
         jr .PreMainLoop


;
;  branch "10"+gamma(offset/256)+BYTE+gamma(length): the main matching mechanism


.CASE10:      ; "use a gamma code * 256 for offset, another gamma code for length"
         call GetGammaCoded


         ; the original decompressor contains
         ;
         ; if ((LWM == 0) && (offs == 2)) { ... }
         ; else {
         ;   if (LWM == 0) { offs -= 3; }
         ;   else { offs -= 2; }
         ; }
         ;
         ; so, the idea here is to use the fact that GetGammaCoded returns (offset/256)+2,
         ; and to split the first condition by noticing that C-1 can never be zero
         dec c : dec c : jr z,LWM1.KickInLWM


.AfterLWM      dec c : ld b,c : ld c,(hl) : inc hl   ; BC = offset


         ld iyl,c : ld iyh,b : push bc


         call GetGammaCoded         ; BC = len*


         ex (sp),hl


         ; interpretation of length value is offset-dependent:
         ; if (offs >= 32000) len++; if (offs >= 1280) len++; if (offs < 128) len+=2;
         ; in other words,
         ; (1 <= offs < 128) +=2
         ; (128 <= offs < 1280) +=0
         ; (1280 <= offs < 31999) +=1
         ; NB offsets over 32000 need one more check, but other Z80 decompressors seem to ignore it. is it not needed?
         exa : ld a,h : cp 5 : jr nc,.Add1
         or a : jr nz,.Add0
         bit 7,l : jr nz,.Add0
.Add2         inc bc
.Add1         inc bc
.Add0         ; for offs<128 : 4+4+7+7 + 4+7 + 8+7 + 6+6 = 60t
         ; for offs>=1280 : 4+4+7+12 + 6 = 33t
         ; for 128<=offs<1280 : 4+4+7+7 + 4+12 = 38t OR 4+4+7+7 + 4+7+8+12 = 53t


.CopyMatch:      ; this assumes that BC = len, DE = offset, HL = dest
         ; and also that (SP) = src, while having NC
         ld a,e : sub l : ld l,a
         ld a,d : sbc h
.CopyMatchLDH      ld h,a : ldir : exa
.PreMainLoop      pop hl               ; recover src


;==================================================================================================================
;==================================================================================================================
;==================================================================================================================


LWM1:         ; LWM = 1


;
;  main decompressor loop


.MainLoop:      add a : jr z,.ReloadByteC0 : jr nc,LWM0.CASE0      ; "0"+BYTE = copy literal
.Check2ndBit      add a : call z,ReloadByte : jr nc,.CASE10      ; "10"+gamma(offset/256)+BYTE+gamma(length) = the main matching mechanism
         add a : call z,ReloadByte : jr nc,LWM0.CASE110      ; "110"+[oooooool] = matched 2-3 bytes with a small offset


;
;  case "111"+"oooo": copy a byte with offset -1..-15, or write zero to dest


.CASE111:      ld bc,%11100000
         DUP 4
         add a : call z,ReloadByte : rl c      ; read short offset (4 bits)
         EDUP
         ex de,hl : jr z,.WriteZero      ; zero offset means "write zero" (NB: B is zero here)


         ; "write a previous byte (1-15 away from dest)"
         push hl               ; BC = offset, DE = src, HL = dest
         sbc hl,bc            ; HL = dest-offset (SBC works because branching above ensured NC)
         ld b,(hl)
         pop hl


.WriteZero      ld (hl),b : ex de,hl
         inc de : jp LWM0.MainLoop            ; 10+4*(4+10+8)+4+7 + 11+15+7+10 + 7+4+6+10 = 179t


.ReloadByteC0      ld a,(hl) : inc hl : rla
         jp nc,LWM0.CASE0
         jr .Check2ndBit


;
;  branch "10"+gamma(offset/256)+BYTE+gamma(length): the main matching mechanism


.CASE10:      ; "use a gamma code * 256 for offset, another gamma code for length"
         call GetGammaCoded


         ; the original decompressor contains
         ;
         ; if ((LWM == 0) && (offs == 2)) { ... }
         ; else {
         ;   if (LWM == 0) { offs -= 3; }
         ;   else { offs -= 2; }
         ; }
         ;
         ; so, the idea here is to use the fact that GetGammaCoded returns (offset/256)+2,
         ; and to split the first condition by noticing that C-1 can never be zero
         dec c : jp LWM0.AfterLWM


;
;  the re-use of the previous offset (LWM magic)


.KickInLWM:      ; "and a new gamma code for length"
         call GetGammaCoded         ; BC = len
         push hl
         exa : ld a,e : sub iyl : ld l,a
         ld a,d : sbc iyh
         jp LWM0.CopyMatchLDH


;==================================================================================================================
;==================================================================================================================
;==================================================================================================================


;
;  interlaced gamma code reader
;  x0 -> 1x
;  x1y0 -> 1xy
;  x1y1z0 -> 1xyz etc
;  (technically, this is a 2-based variation of Exp-Golomb-1)


GetGammaCoded:      ld bc,1
ReadGamma      add a : jr z,ReloadByteRG1
         rl c : rl b
         add a : jr z,ReloadByteRG2
         jr c,ReadGamma : ret


ReloadByteRG1      ld a,(hl) : inc hl : rla
         rl c : rl b
         add a : jr c,ReadGamma : ret


ReloadByteRG2      ld a,(hl) : inc hl : rla
         jr c,ReadGamma : ret


;
;  pretty usual getbit for mixed datastreams


ReloadByte:      ld a,(hl) : inc hl : rla : ret
	ENDMODULE