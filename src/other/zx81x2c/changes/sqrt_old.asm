;
; ------------
; THE REPORT_A
; ------------
;
REPORT_A

	RST 08H			; ERROR-1
	.db $09		; Error Report: Invalid argument

; ----------------------------------
; THE patched 'SQUARE ROOT' FUNCTION
; ----------------------------------
; (Offset $25: 'sqr')
;   "If I have seen further, it is by standing on the shoulders of giants" -
;   Sir Isaac Newton, Cambridge 1676.
;   The sqr function has been re-written to use the Newton-Raphson method.
;   Joseph Raphson was a student of Sir Isaac Newton at Cambridge University
;   and helped publicize his work.
;   Although Newton's method is centuries old, this routine, appropriately, is 
;   based on a FORTH word written by Steven Vickers in the Jupiter Ace manual.
;   Whereas that method uses an initial guess of one, this one manipulates 
;   the exponent byte to obtain a better starting guess. 
;   First test for zero and return zero, if so, as the result.
;   If the argument is negative, then produce an error.
;
fn_sqr
	RST 28H		;; FP-CALC		x
	.db $C3		;;st-mem-3		x.   (seed for guess)
	.db $34		;;end-calc		x.
;
;   HL now points to exponent of argument on calculator stack.
;
;   Test for a positive argument
;
	INC HL			; Address byte with sign bit.
	BIT 7,(HL)		; Test the bit.

	JR NZ,REPORT_A		; back to REPORT_A: 'Invalid argument'
;
;   This guess is based on a Usenet discussion.
;   Halve the exponent to achieve a good guess.(accurate with .25 16 64 etc.)
;
	ld hl,$406C		; Address first byte of mem-3
	LD A,(HL)		; fetch exponent of mem-3

	and a			; Test for zero argument
	ret z			; Return with zero on the calculator stack.

	sub $80			; remove the offset
	sra a			; halve the exponent
	add a,$81		; then set the offset again

	LD (HL),A		; and put back 'halved' exponent.
;
;   Now re-enter the calculator.
;
	RST   28H	;; FP-CALC		x
SLOOP
	.db $2D		;;duplicate		x,x.
	.db $E3		;;get-mem-3		x,x,guess
	.db $C4		;;st-mem-4		x,x,guess
	.db $05		;;div			x,x/guess.
	.db $E3		;;get-mem-3		x,x/guess,guess
	.db $0F		;;addition		x,x/guess+guess
	.db $A2		;;stk-half		x,x/guess+guess,.5
	.db $04		;;multiply		x,(x/guess+guess)*.5
	.db $C3		;;st-mem-3		x,newguess
	.db $E4		;;get-mem-4		x,newguess,oldguess
	.db $03		;;subtract		x,newguess-oldguess
	.db $27		;;abs			x,difference.

	.db $33		;;greater-0		x,(0/1).
	.db $00		;;jump-true		x.
	.db SLOOP-$	;;to sloop		x.

	.db $02	;;delete		.
	.db $E3	;;get-mem-3		retrieve final guess.
	.db $34	;;end-calc		sqr x.

	RET			; return with square root on stack
