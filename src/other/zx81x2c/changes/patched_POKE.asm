;
; ----------------------------------
; THE patched 'POKE' COMMAND ROUTINE
; ----------------------------------
;
;; POKE
L0E92:
	call L0C02		; routine STK-TO-A (with overflow check)

;;-	CALL FP_TO_A		; routine FP-TO-A
;;-	JR C,L0EAD		; forward, with overflow, to REPORT-B

	JR Z,L0E9B		; forward, if positive, to POKE-SAVE

	NEG			; else negate
;
;; POKE-SAVE
L0E9B:	PUSH AF			; preserve value.
	CALL FIND_INT		; routine FIND-INT gets address in BC
				; invoking the error routine with overflow
				; or a negative number.
	POP AF			; restore value.

	LD (BC),A		; update the address contents.
	RET 			; return.
;;-
;;- Note. the next two instructions are legacy code from the ZX80 and
;;- inappropriate here.
;;-
;;-	BIT 7,(IY+$00)		; test ERR_NR - is it still $FF ?
;;-	RET Z			; return with error.

;;-	LD (BC),A		; update the address contents.
;;-	RET 			; return.
;
;	========================================================
;	called by the new 'PAUSE'
ffp_test
	bit 7,(iy+$3B)		; sv CDFLAG - test SLOW mode
	jp ffp_hook		; forward 
;
