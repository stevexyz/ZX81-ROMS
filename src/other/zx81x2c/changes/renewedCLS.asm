;
; --------------------------------------------
; THE renewed 'CLS' COMMAND ROUTINE (51 bytes)
; --------------------------------------------
;
;; CLS
L0A2A:	LD B,$18		; set line counter: 24 lines to clear
;
;; B-LINES
L0A2C:	RES 1,(IY+$01)		; sv FLAGS - Signal printer not in use

	push bc			; save line counter
	call loc_pos0		; ld c,$21 --> LOC-ADDR
	pop bc			; restore line counter
	ld c,b			; save counter

	bit 5,(IY+$3B)		; sv CDFLAG - test expanded D-FILE
	jr z,cls_frst		;

	ld de,33		; size of a line
cls_addr
	add hl,de		; set address
	djnz cls_addr		; until end of D-FILE
clr_next
	call clr_line		; clear a line - part of new CLEAR-PRB
	dec c			; set counter
	jr nz,clr_next		; done?
	
	ret
;
;	----------------------------------------
cls_frst
	inc b			; set line counter
	dec hl			; points the previous N/L
	ld a,(hl)		; fetch a N/L character
next_nl
	ld (hl),a		; then
	inc hl			; make a compressed
	djnz next_nl		; D-File
	
	ld de,($4010)		; sv VARS

	ld a,($4005)		; sv RAMTOP_hi
	cp $4D			; >3KB?
	jp nc,cls_chck		; yes, check room

	ex de,hl		; else return w. collapsed D-FILE via
;
; ----------------------------
; THE 'RECLAIMING' SUBROUTINES
; ----------------------------
;
;; RECLAIM-1
L0A5D:	CALL L0A17		; routine DIFFER

;; RECLAIM-2
L0A60:	PUSH BC			;
	LD A,B			;
	CPL			;
	LD B,A			;
	LD A,C			;
	CPL			;
	LD C,A			;
	INC BC			;
	CALL L09AD		; routine POINTERS
	EX DE,HL		;
	POP HL			;
	ADD HL,DE		;
	PUSH DE			;
	LDIR			; Copy Bytes
	POP HL			;
	RET 			;
;
;	==============================================================
;
;	...
;
;	============================================================== 36B
;	de: points sv VARS
;	hl: points the 1st free byte in D-FILE
cls_chck
	push bc			; save counter
	ld a,c			; test line counter (Y)
	cp $18			; clear whole screen?
	jr nz,cls_skip		; skip, if not

	set 5,(IY+$3B)		; sv CDFLAG - signal expanded D-FILE
cls_skip
	add a,a			;  2*Y (line counter)
	add a,a			;  4*Y
	add a,a			;  8*Y
	ld c,a			; BC = 8 * Y (line counter)

	add hl,bc		; + 8 * Y
	add hl,bc		; + 8 * Y
	add hl,bc		; + 8 * Y
	add hl,bc		; HL points the 
	dec hl			; end of D-FILE
	call L0A17		; routine DIFFER

;;;	AND A			; 
;;;	SBC HL,DE		; 
;;;	LD B,H			; 
;;;	LD C,L			; BC = nr. of the missing bytes
;;;	ADD HL,DE		; HL points the end of D-FILE
;;;	EX DE,HL		; 
;;;	RET 			; 

	inc bc			; set counter
	dec hl			; HL points the old end of D-FILE
	jr c,cls_cont		; if room is enough then return

	call L099E		; else routine MAKE-ROOM

	inc de			; position of the latest N/L in D-FILE
cls_cont
	ex de,hl		; 
	inc hl			; points the (expected) variables area
	pop bc			; restore counter
	jp clr_next		; back to renewed CLS routine
