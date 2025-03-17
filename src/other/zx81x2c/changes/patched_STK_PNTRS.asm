;
; ------------------------------------
; THE patched 'STACK POINTERS' ROUTINE
; ------------------------------------
;   Register DE is set to STKEND and HL, the result pointer, is set to five
;   locations below this - the 'last value'.
;   This routine is used when it is inconvenient to save these values at the
;   time the calculator stack is manipulated due to other activity on the
;   machine stack.
;   This routine is also used to terminate the VAL routine for
;   the same reason and to initialize the calculator stack at the start of
;   the CALCULATE routine.
;
STK_PNTRS
	LD HL,($401C)		; fetch STKEND value from system variable.
;;-	LD DE,$FFFB		; the value -5
;;-	PUSH HL			; push STKEND value.

	ex de,hl		; switch pointers: DE = STKEND
	ld hl,$FFFB		; the value -5

	ADD HL,DE		; HL = STKEND - 5
;;-
;	-----------------------------------------------------------------------
;;-	String comparisons join here to clear stack then return
;;-cmp_nequ
;;-	POP DE			; pop STKEND to DE.
	RET 			; return.
