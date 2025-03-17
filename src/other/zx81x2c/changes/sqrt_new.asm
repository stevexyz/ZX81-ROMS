;
; ------------
; THE REPORT_A
; ------------
;
REPORT_A

	RST 08H			; ERROR-1
	DEFB $09		; Error Report: Invalid argument
;
; ------------------------------
; THE new 'SQUARE ROOT' FUNCTION
; ------------------------------
; (Offset $25: 'sqr')
;   
;   This implementation of the Babylonian (or Heron's) square root method is
;   from the SAM Coupe ROM by Andy Wright.
;
;   see: https://en.wikipedia.org/wiki/Babylonian_method
;
;   First test for zero and return zero, if so, as the result.
;   If the argument is negative, then produce an error.
;
fn_sqr
	RST 28H		;; FP-CALC			n
	.db $C3		;; st-mem-3 (store in mem-3)	n
	.db $34		;; end_calc (exit calculator)	n

	ld a,(hl)		;  exponent to A
	and a			;  test against zero
	ret z			;  return if so

	add a,$80		;  set carry if greater or equal to 128
	rra			;  divide by two
	ld (hl),a		;  replace value

	inc hl			;  next location
	ld a,(hl)		;  get sign bit
	rla			;  rotate left
	jr c,REPORT_A		;  error with negative number

	ld (hl),127		;  mantissa starts at about one
	ld b,5			;  set counter
fn_sqr1
	RST 28H		;; FP-CALC			x
	.db $2D		;; duplicate			x, x
	.db $E3		;; get_mem_3			x, x, n
	.db $01		;; exchange			x, n, x
	.db $05		;; division			x, n / x
	.db $0F		;; addition			x + n / x
	.db $34		;; end_calc (exit calculator)

	dec (hl)		;  halve value
	djnz fn_sqr1		;  loop until found

	ret			;  return with square root on stack
;
;	========================================================
