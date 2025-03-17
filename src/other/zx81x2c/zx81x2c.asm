; ===============================================================================
;		        An Assembly Listing of the ZX81x2 ROM
; ===============================================================================
;
; -------------------------
; Last updated: 26-NOV-2020
; -------------------------
;
;	Based on the "Shoulders of Giants" ZX81 ROM (Geoff Wearmouth).
;
;  SG81.ROM ---------------------------------------------------------------------
;
;	The main feature is the inclusion of Newton Raphson square roots.
;	The square roots are executed 3 times faster than those in the 
;	standard ROM. They are more accurate also and
;
;	PRINT SQR 100 = INT SQR 100 gives the result 1 (true) not 0 (false)
;
;	The input and storage of fractional numbers is improved
;
;	PRINT 1/2 = .5 gives the result 1 (true) and not 0 (false) 
;
;	The output of fractional numbers to the ZX Printer is corrected
;
;	LPRINT .00001 gives the output .00001 and not .0XYZ1
;
;	Other alterations have been made to create the space required by the
;	new square root routine and some are obscure and would not otherwise have 
;	been made.
;	Using uncompressed constants rectifies a logic error and improves speed.
;
;  SG81_A.ROM -------------------------------------------------------------------
;
;	T3 (NMI) patch - faster NMI-service:  the user application gets +3TS/NMI
;
;  SG81_B.ROM -------------------------------------------------------------------
;
;	QCOM1 patch by Ludwig Röck (faster FOR/NEXT, GOSUB/RETURN)
;
;  SG81_C.ROM ===============================================================(GZS)
;
;	improved LOC-ADDR routine -> faster printing
;
;  SG81_D1.ROM --------------------------------------------------------------(GZS)
;
;	modified routine 'POINTERS' and a patch to use 24 lines 'SCROLL'
;	(the POKE 16418,0 is a cheat code, which enables 24 lines printing)
;
;	improved 'E-TO-FP' routine - a (1B shorter) ZX Spectrum-like solution
;
;  SG81E_MT.ROM -------------------------------------------------------------(GZS)
;
;	improved 'FP-TO-BC' routine - no longer returns value "-0"
;	new 'E-TO-FP' routine with a tricky 'Multiply by Ten' subroutine
;	new (much faster) 'PRINT-FP' routine to printing the numbers
;
;  SG81F_MT.ROM -------------------------------------------------------------(GZS)
;
;	renewed arithmetic routines - the 4 basic operations are faster
;	the patched 'NEXT' command routine calls directly the new 'ADDITION'
;
;  SG81_G2.ROM --------------------------------------------------------------(GZS)
;
;	improved exponent correction in 'MULTIPLICATION' and 'DIVISION' routines
;
;	rewritten functions: INT, SGN, COS
;	improved routines: ASIN, ATAN, EXP, FP-CALC, FP2BC, INT2FP, LN, NXTDGT1,
;			   RND, SER-GEN, SIN, TO-POWER, TRUNCATE
;
;	the 'get-argt' literal from now does nothing (points to a simple RET) 
;	the improved 'GETARGT' function is part of the improved 'SINE' function.
;
;	new macros (calculator literals): sub-one, mul-by-2, mul-by-10, stk-square
;
;	the patched routines: PRINTING, LINE-ENDS, SCROLL, IF, SQR, 'JUMP ON TRUE'	
;				    
;
;  ZX81x2.ROM ----------------------------------------------------- (the big bang)
;
;	the renewed comparison operations from now have two entry points:
;	one for "=,<,>", and an other for "<>,>=,<="
;
;	the improved INT function and the renewed NEXT-LOOP routine are calling
;	directly the new and quick numeric comparison instead of subtraction
;
;	the system variable CDFLAG from now includes two new status bits:
;
;	- bit 5 signs the noncollapsed (expanded) display file
;	  its status is checked by the renewed screen manipulating routines
;
;	- bit 4 is the plot48 flag - if it is set, then the PLOT origin will be
;	  moved to the left bottom corner and the Y coordinate can be 0..47
;
;	the ending part of the new 'CLEAR PRINTER BUFFER' routine is used by
;	the new 'CLS' and 'SCROLL' routines
;
;	the new CLS routine is much faster than the original and sets the new
;	status bit of the CDFLAG (bit 5) depending on the available memory
;	(dramatically reduces also the time required for booting)
;
;	the 'SCROLL', the 'LOCATE ADDRESS' and the 'PLOT AND UNPLOT' routines
;	were enhanced to work in two ways depending on bit 5 of CDFLAG:
;
;	(1) as before (bit 5 = 0): eg. the 'SCROLL' damages the display file
;
;	(2) or quick (bit 5 = 1): making use of the direct writing possibility
;	                          of the linear display file
;
;	the old 'Handle string AND number' routine was completely removed
;	its function is provided by the 'Handle number AND number' routine
;
;	the 'Absolute magnitude' and the 'Handle PEEK' functions have been moved
;
;	the patched routines: 'PRINT A CHARACTER','RUBOUT','ED-EDGE','RND'
;
;	the "POINTERS" routine is again in its original (unpatched) format
;
;  ZX81x2aaa.ROM -----------------------------------------------------------------
;
;	the 'MODULUS', the 'TEST 5 SPACES', the 'COPY A FLOATING POINT NUMBER'
;	and the 'STR$' subroutines have been moved to their original location
;
;  ZX81x2b.ROM -------------------------------------------------------------------
;
;	improved (faster) series generator
;
;  ZX81x2c.ROM -------------------------------------------------------------------
;
;	new square root method by Andy Wright (from the SAM Coupe ROM)
;	it is ~2x faster than the previous Newton-Raphson iteration
;
;	a "flickerfree", new 'PAUSE' command routine
;
;	the patched routines:  'POINTERS','POKE', 'STACK POINTERS'
;
;	the 'CLS' command routine is renewed
;
;	==================================================================== (GZS)

#define	DEFB .BYTE		; TASM cross-assembler definitions
#define	DEFW .WORD
#define	EQU .EQU
#define	ORG .ORG

; ------------------------------------------------------------------------------

;#define zxmore			; if this line is uncommented, then the 3T-patch
				; will be disabled (ClckFreq result is ~3% less)

; -------------------------------------------------------------------------------

;*****************************************
;** Part 1. RESTART ROUTINES AND TABLES **
;*****************************************

	ORG $0000

; -----------
; THE 'START'
; -----------
; All Z80 chips start at location zero.
; At start-up the Interrupt Mode is 0, ZX computers use Interrupt Mode 1.
; Interrupts are disabled .

;; START
L0000:
	OUT ($FD),A		; Turn off the NMI generator if this ROM is 
				; running in ZX81 hardware. This does nothing 
				; if this ROM is running within an upgraded ZX80.
	LD BC,$7FFF		; Set BC to the top of possible RAM.
				; The higher unpopulated addresses are used for
				; video generation.
	JP L03CB		; Jump forward to RAM-CHECK.

; -------------------
; THE 'ERROR' RESTART
; -------------------
; The error restart deals immediately with an error. ZX computers execute the 
; same code in runtime as when checking syntax. If the error occurred while 
; running a program then a brief report is produced. If the error occurred
; while entering a BASIC line or in input etc., then the error marker indicates
; the exact point at which the error lies.

;; ERROR-1
L0008:	LD HL,($4016)		; fetch character address from CH_ADD.
	LD ($4018),HL		; and set the error pointer X_PTR.
	JR L0056		; forward to continue at ERROR-2.

; ---------------------------------------
; THE patched 'PRINT A CHARACTER' RESTART
; ---------------------------------------
; This restart prints the character in the accumulator using the alternate
; register set so there is no requirement to save the main registers.
; There is sufficient room available to separate a space (zero) from other
; characters as leading spaces need not be considered with a space.

;; PRINT-A
L0010:
	jp L07EE		; routine OUT-CH
;
;	==============================================================
;
; -----------------------
; Absolute magnitude (27)
; -----------------------
; This calculator literal finds the absolute value of the last value,
; floating point, on calculator stack.
;
fn_abs
	INC HL			; point to byte with sign bit.
	RES 7,(HL)		; make the sign positive.
	DEC HL			; point to last value again.
	RET			; return.
;
;	==============================================================
;
; ---------------------------------
; THE 'COLLECT A CHARACTER' RESTART
; ---------------------------------
; The character addressed by the system variable CH_ADD is fetched and if it
; is a non-space, non-cursor character it is returned else CH_ADD is 
; incremented and the new addressed character tested until it is not a space.

;; GET-CHAR
L0018:	LD HL,($4016)		; set HL to character address CH_ADD.
	LD A,(HL)		; fetch addressed character to A.

;; TEST-SP
L001C:	AND A			; test for space.
	RET NZ			; return if not a space

	NOP			; else trickle through
	NOP			; to the next routine.

; ------------------------------------
; THE 'COLLECT NEXT CHARACTER' RESTART
; ------------------------------------
; The character address in incremented and the new addressed character is 
; returned if not a space, or cursor, else the process is repeated.

;; NEXT-CHAR
L0020:	CALL L0049		; routine CH-ADD+1 gets next immediate
				; character.
	JR L001C		; back to TEST-SP.
;
;	==============================================================
;
	.db $26,$10,$20		; unused locations - FW_ID: 26.10.2020 
;
;	==============================================================
;
; ---------------------------------------
; THE 'FLOATING POINT CALCULATOR' RESTART
; ---------------------------------------
; this restart jumps to the recursive floating-point calculator.
; the ZX81's internal, FORTH-like, stack-based language.
;
; In the five remaining bytes there is, appropriately, enough room for the
; end-calc literal - the instruction which exits the calculator.

;; FP-CALC
L0028:	JP CALCULATE		;+ jump to the NEW calculate routine address.

end_calc			; (L002B)
	POP AF			; drop the calculator return address RE-ENTRY
	EXX			; switch to the other set.

	EX (SP),HL		; transfer H'L' to machine stack for the
				; return address.
				; when exiting recursion then the previous
				; pointer is transferred to H'L'.

	EXX			; back to main set.
	RET 			; return.

; -----------------------------
; THE 'MAKE BC SPACES'  RESTART
; -----------------------------
; This restart is used eight times to create, in workspace, the number of
; spaces passed in the BC register.

;; BC-SPACES
L0030:
	PUSH BC			; push number of spaces on stack.
	LD HL,($4014)		; fetch edit line location from E_LINE.
	PUSH HL			; save this value on stack.
	JP L1488		; jump forward to continue at RESERVE.

; -----------------------
; THE 'INTERRUPT' RESTART
; -----------------------
;   The Mode 1 Interrupt routine is concerned solely with generating the central
;   television picture.
;   On the ZX81 interrupts are enabled only during the interrupt routine, 
;   although the interrupt 
;   This Interrupt Service Routine automatically disables interrupts at the 
;   outset and the last interrupt in a cascade exits before the interrupts are
;   enabled.
;   There is no DI instruction in the ZX81 ROM.
;   An maskable interrupt is triggered when bit 6 of the Z80's Refresh register
;   changes from set to reset.
;   The Z80 will always be executing a HALT (NEWLINE) when the interrupt occurs.
;   A HALT instruction repeatedly executes NOPS but the seven lower bits
;   of the Refresh register are incremented each time as they are when any 
;   simple instruction is executed. (The lower 7 bits are incremented twice for
;   a prefixed instruction)
;   This is controlled by the Sinclair Computer Logic Chip - manufactured from 
;   a Ferranti Uncommitted Logic Array.
;
;   When a Mode 1 Interrupt occurs the Program Counter, which is the address in
;   the upper echo display following the NEWLINE/HALT instruction, goes on the 
;   machine stack.  193 interrupts are required to generate the last part of
;   the 56th border line and then the 192 lines of the central TV picture and, 
;   although each interrupt interrupts the previous one, there are no stack 
;   problems as the 'return address' is discarded each time.
;
;   The scan line counter in C counts down from 8 to 1 within the generation of
;   each text line. For the first interrupt in a cascade the initial value of 
;   C is set to 1 for the last border line.
;   Timing is of the utmost importance as the RH border, horizontal retrace
;   and LH border are mostly generated in the 58 clock cycles this routine 
;   takes .

;; INTERRUPT
L0038:
	DEC C			; (4)  decrement C - the scan line counter.
	JP NZ,L0045		; (10/10) JUMP forward if not zero to SCAN-LINE

	POP HL			; (10) point to start of next row in display file.

	DEC B			; (4)  decrement the row counter. (4)
	RET Z			; (11/5) return when picture complete to L028B
				; with interrupts disabled.

	SET 3,C			; (8)  Load the scan line counter with eight.  
				; Note. LD C,$08 is 7 clock cycles which 
				; is way too fast.
; ->

;; WAIT-INT
L0041:
	LD R,A			; (9) Load R with initial rising value $DD.

	EI			; (4) Enable Interrupts.  [ R is now $DE ].

	JP (HL)			; (4) jump to the echo display file in upper
				;	memory and execute characters $00 - $3F 
				;	as NOP instructions.  The video hardware 
				;	is able to read these characters and, 
				;	with the I register is able to convert 
				;	the character bitmaps in this ROM into a 
				;	line of bytes. Eventually the NEWLINE/HALT
				;	will be encountered before R reaches $FF. 
				;	It is however the transition from $FF to 
				;	$80 that triggers the next interrupt.
				;	[ The Refresh register is now $DF ]
; ---

;; SCAN-LINE
L0045:
	POP DE			; (10) discard the address after NEWLINE as the 
				; same text line has to be done again
				; eight times. 

	RET Z			; (5)  Harmless Nonsensical Timing.
				; (condition never met)

	JR L0041		; (12) back to WAIT-INT

;   Note. that a computer with less than 4K or RAM will have a collapsed
;   display file and the above mechanism deals with both types of display.
;
;   With a full display, the 32 characters in the line are treated as NOPS
;   and the Refresh register rises from $E0 to $FF and, at the next instruction 
;   - HALT, the interrupt occurs.
;   With a collapsed display and an initial NEWLINE/HALT, it is the NOPs 
;   generated by the HALT that cause the Refresh value to rise from $E0 to $FF,
;   triggering an Interrupt on the next transition.
;   This works happily for all display lines between these extremes and the 
;   generation of the 32 character, 1 pixel high, line will always take 128 
;   clock cycles.

; ---------------------------------
; THE 'INCREMENT CH-ADD' SUBROUTINE
; ---------------------------------
; This is the subroutine that increments the character address system variable
; and returns if it is not the cursor character. The ZX81 has an actual 
; character at the cursor position rather than a pointer system variable
; as is the case with prior and subsequent ZX computers.

;; CH-ADD+1
L0049:
	LD HL,($4016)		; fetch character address to CH_ADD.

;; TEMP-PTR1
L004C:
	INC HL			; address next immediate location.

;; TEMP-PTR2
L004D:
	LD ($4016),HL		; update system variable CH_ADD.

	LD A,(HL)		; fetch the character.
	CP $7F			; compare to cursor character.
	RET NZ			; return if not the cursor.

	JR L004C		; back for next character to TEMP-PTR1.

; --------------------
; THE 'ERROR-2' BRANCH
; --------------------
; This is a continuation of the error restart.
; If the error occurred in runtime then the error stack pointer will probably
; lead to an error report being printed unless it occurred during input.
; If the error occurred when checking syntax then the error stack pointer
; will be an editing routine and the position of the error will be shown
; when the lower screen is reprinted.

;; ERROR-2
L0056:
	POP HL			; pop the return address which points to the
				; DEFB, error code, after the RST 08.
	LD L,(HL)		; load L with the error code. HL is not needed
				; anymore.
;; ERROR-3
L0058:
	LD (IY+$00),L		; place error code in system variable ERR_NR
	LD SP,($4002)		; set the stack pointer from ERR_SP
	CALL L0207		; routine SLOW/FAST selects slow mode.

	JP L14BC		; exit to address on stack via routine SET-MIN.
; ---
	DEFB $FF		; unused.

; ------------------------------------
; THE 'NON MASKABLE INTERRUPT' ROUTINE
; ------------------------------------
;   Jim Westwood's technical dodge using Non-Maskable Interrupts solved the
;   flicker problem of the ZX80 and gave the ZX81 a multi-tasking SLOW mode 
;   with a steady display.  Note that the AF' register is reserved for this 
;   function and its interaction with the display routines.  When counting 
;   TV lines, the NMI makes no use of the main registers.
;   The circuitry for the NMI generator is contained within the SCL (Sinclair 
;   Computer Logic) chip. 
;   ( It takes 29 clock cycles while incrementing towards zero - it was 32TS). 

;; NMI
L0066:
	EX AF,AF'		; (4) switch in the NMI's copy of the 
				;	accumulator.
	INC A			; (4) increment.

#ifdef zxmore

	JP M,NMI_RET		; (10/10) jump, if minus, to NMI-RET as this is
				;	part of a test to see if the NMI 
				;	generation is working or an intermediate 
				;	value for the ascending negated blank 
				;	line counter.
#endif
	JR Z,NMI_CONT		; (12) forward to NMI-CONT
				; when line count has incremented to zero.
;; NMI-RET
;
NMI_RET
	EX AF,AF'		; (4)  switch out the incremented line counter
				; or test result $80
	RET 			; (10) return to User application for a while.
; ---
;   This branch is taken when the 55 (or 31) lines have been drawn.

;; NMI-CONT
NMI_CONT
	EX AF,AF'		; (4) restore the main accumulator.

	PUSH AF			; (11) *  Save Main Registers
	PUSH BC			; (11) **
	PUSH DE			; (11) ***
	PUSH HL			; (11) ****

;   the next set-up procedure is only really applicable when the top set of 
;   blank lines have been generated.

	LD HL,($400C)		; (16) fetch start of Display File from D_FILE
				; points to the HALT at beginning.
	SET 7,H			; (8) point to upper 32K 'echo display file'

	HALT			; (1) HALT synchronizes with NMI.  
				; Used with special hardware connected to the
				; Z80 HALT and WAIT lines to take 1 clock cycle.

; ----------------------------------------------------------------------------
;   the NMI has been generated - start counting.
;
;   The cathode ray is at the RH side of the TV.
;   First the NMI servicing, similar to CALL		=  17 clock cycles.
;   Then the time taken by the NMI for zero-to-one path =  29 cycles.(it was 32)
;   The HALT above					=  01 cycles.
;   The 3 (previously 2) instructions below		=  29 cycles.(it was 19)
;   The code at L0281 up to and including the CALL	=  43 cycles.
;   The Called routine at L02B5				=  24 cycles.
;   --------------------------------------		  ---
;   Total Z80 instructions				= 143 cycles.
;
;   Meanwhile in TV world,
;   Horizontal retrace					=  15 cycles.
;   Left blanking border 8 character positions		=  32 cycles
;   Generation of 75% scanline from the first NEWLINE   =  96 cycles
;   ---------------------------------------		   ---
;							   143 cycles
;
;   Since at the time the first JP (HL) is encountered to execute the echo
;   display another 8 character positions have to be put out, then the
;   Refresh register need to hold $F8. Working back and counteracting 
;   the fact that every instruction increments the Refresh register then
;   the value that is loaded into R needs to be $F5. :-)
;
;
	OUT ($FD),A		; (11) Stop the NMI generator.

#ifndef zxmore
	jp IX_to_PC		; (10) Delay
IX_to_PC

#endif
	JP (IX) 		; (8) forward to L0281 (after top) or L028F

; ****************
; ** KEY TABLES **
; ****************

; -------------------------------
; THE 'UNSHIFTED' CHARACTER CODES
; -------------------------------

;; K-UNSHIFT
L007E:	DEFB $3F  ; Z
	DEFB $3D  ; X
	DEFB $28  ; C
	DEFB $3B  ; V
	DEFB $26  ; A
	DEFB $38  ; S
	DEFB $29  ; D
	DEFB $2B  ; F
	DEFB $2C  ; G
	DEFB $36  ; Q
	DEFB $3C  ; W
	DEFB $2A  ; E
	DEFB $37  ; R
	DEFB $39  ; T
	DEFB $1D  ; 1
	DEFB $1E  ; 2
	DEFB $1F  ; 3
	DEFB $20  ; 4
	DEFB $21  ; 5
	DEFB $1C  ; 0
	DEFB $25  ; 9
	DEFB $24  ; 8
	DEFB $23  ; 7
	DEFB $22  ; 6
	DEFB $35  ; P
	DEFB $34  ; O
	DEFB $2E  ; I
	DEFB $3A  ; U
	DEFB $3E  ; Y
	DEFB $76  ; NEWLINE
	DEFB $31  ; L
	DEFB $30  ; K
	DEFB $2F  ; J
	DEFB $2D  ; H
	DEFB $00  ; SPACE
	DEFB $1B  ; .
	DEFB $32  ; M
	DEFB $33  ; N
	DEFB $27  ; B

; -----------------------------
; THE 'SHIFTED' CHARACTER CODES
; -----------------------------

;; K-SHIFT
L00A5:	DEFB $0E  ; :
	DEFB $19  ; ;
	DEFB $0F  ; ?
	DEFB $18  ; /
	DEFB $E3  ; STOP
	DEFB $E1  ; LPRINT
	DEFB $E4  ; SLOW
	DEFB $E5  ; FAST
	DEFB $E2  ; LLIST
	DEFB $C0  ; ""
	DEFB $D9  ; OR
	DEFB $E0  ; STEP
	DEFB $DB  ; <=
	DEFB $DD  ; <>
	DEFB $75  ; EDIT
	DEFB $DA  ; AND
	DEFB $DE  ; THEN
	DEFB $DF  ; TO
	DEFB $72  ; cursor-left
	DEFB $77  ; RUBOUT
	DEFB $74  ; GRAPHICS
	DEFB $73  ; cursor-right
	DEFB $70  ; cursor-up
	DEFB $71  ; cursor-down
	DEFB $0B  ; "
	DEFB $11  ; )
	DEFB $10  ; (
	DEFB $0D  ; $
	DEFB $DC  ; >=
	DEFB $79  ; FUNCTION
	DEFB $14  ; =
	DEFB $15  ; +
	DEFB $16  ; -
	DEFB $D8  ; **
	DEFB $0C  ;  &#163; 
	DEFB $1A  ; ,
	DEFB $12  ; >
	DEFB $13  ; <
	DEFB $17  ; *

; ------------------------------
; THE 'FUNCTION' CHARACTER CODES
; ------------------------------

;; K-FUNCT
L00CC:	DEFB $CD  ; LN
	DEFB $CE  ; EXP
	DEFB $C1  ; AT
	DEFB $78  ; KL
	DEFB $CA  ; ASN
	DEFB $CB  ; ACS
	DEFB $CC  ; ATN
	DEFB $D1  ; SGN
	DEFB $D2  ; ABS
	DEFB $C7  ; SIN
	DEFB $C8  ; COS
	DEFB $C9  ; TAN
	DEFB $CF  ; INT
	DEFB $40  ; RND
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $C2  ; TAB
	DEFB $D3  ; PEEK
	DEFB $C4  ; CODE
	DEFB $D6  ; CHR$
	DEFB $D5  ; STR$
	DEFB $78  ; KL
	DEFB $D4  ; USR
	DEFB $C6  ; LEN
	DEFB $C5  ; VAL
	DEFB $D0  ; SQR
	DEFB $78  ; KL
	DEFB $78  ; KL
	DEFB $42  ; PI
	DEFB $D7  ; NOT
	DEFB $41  ; INKEY$

; -----------------------------
; THE 'GRAPHIC' CHARACTER CODES
; -----------------------------

;; K-GRAPH
L00F3:	DEFB $08  ; graphic
	DEFB $0A  ; graphic
	DEFB $09  ; graphic
	DEFB $8A  ; graphic
	DEFB $89  ; graphic
	DEFB $81  ; graphic
	DEFB $82  ; graphic
	DEFB $07  ; graphic
	DEFB $84  ; graphic
	DEFB $06  ; graphic
	DEFB $01  ; graphic
	DEFB $02  ; graphic
	DEFB $87  ; graphic
	DEFB $04  ; graphic
	DEFB $05  ; graphic
	DEFB $77  ; RUBOUT
	DEFB $78  ; KL
	DEFB $85  ; graphic
	DEFB $03  ; graphic
	DEFB $83  ; graphic
	DEFB $8B  ; graphic
	DEFB $91  ; inverse )
	DEFB $90  ; inverse (
	DEFB $8D  ; inverse $
	DEFB $86  ; graphic
	DEFB $78  ; KL
	DEFB $92  ; inverse >
	DEFB $95  ; inverse +
	DEFB $96  ; inverse -
	DEFB $88  ; graphic

; ------------------
; THE 'TOKEN' TABLES
; ------------------

;; TOKENS
L0111:	DEFB $0F+$80				; '?'+$80
	DEFB $0B,$0B+$80			; ""
	DEFB $26,$39+$80			; AT
	DEFB $39,$26,$27+$80			; TAB
	DEFB $0F+$80				; '?'+$80
	DEFB $28,$34,$29,$2A+$80		; CODE
	DEFB $3B,$26,$31+$80			; VAL
	DEFB $31,$2A,$33+$80			; LEN
	DEFB $38,$2E,$33+$80			; SIN
	DEFB $28,$34,$38+$80			; COS
	DEFB $39,$26,$33+$80			; TAN
	DEFB $26,$38,$33+$80			; ASN
	DEFB $26,$28,$38+$80			; ACS
	DEFB $26,$39,$33+$80			; ATN
	DEFB $31,$33+$80			; LN
	DEFB $2A,$3D,$35+$80			; EXP
	DEFB $2E,$33,$39+$80			; INT
	DEFB $38,$36,$37+$80			; SQR
	DEFB $38,$2C,$33+$80			; SGN
	DEFB $26,$27,$38+$80			; ABS
	DEFB $35,$2A,$2A,$30+$80		; PEEK
	DEFB $3A,$38,$37+$80			; USR
	DEFB $38,$39,$37,$0D+$80		; STR$
	DEFB $28,$2D,$37,$0D+$80		; CHR$
	DEFB $33,$34,$39+$80			; NOT
	DEFB $17,$17+$80			; **
	DEFB $34,$37+$80			; OR
	DEFB $26,$33,$29+$80			; AND
	DEFB $13,$14+$80			; <=
	DEFB $12,$14+$80			; >=
	DEFB $13,$12+$80			; <>
	DEFB $39,$2D,$2A,$33+$80		; THEN
	DEFB $39,$34+$80			; TO
	DEFB $38,$39,$2A,$35+$80		; STEP
	DEFB $31,$35,$37,$2E,$33,$39+$80	; LPRINT
	DEFB $31,$31,$2E,$38,$39+$80		; LLIST
	DEFB $38,$39,$34,$35+$80		; STOP
	DEFB $38,$31,$34,$3C+$80		; SLOW
	DEFB $2B,$26,$38,$39+$80		; FAST
	DEFB $33,$2A,$3C+$80			; NEW
	DEFB $38,$28,$37,$34,$31,$31+$80	; SCROLL
	DEFB $28,$34,$33,$39+$80		; CONT
	DEFB $29,$2E,$32+$80			; DIM
	DEFB $37,$2A,$32+$80			; REM
	DEFB $2B,$34,$37+$80			; FOR
	DEFB $2C,$34,$39,$34+$80		; GOTO
	DEFB $2C,$34,$38,$3A,$27+$80		; GOSUB
	DEFB $2E,$33,$35,$3A,$39+$80		; INPUT
	DEFB $31,$34,$26,$29+$80		; LOAD
	DEFB $31,$2E,$38,$39+$80		; LIST
	DEFB $31,$2A,$39+$80			; LET
	DEFB $35,$26,$3A,$38,$2A+$80		; PAUSE
	DEFB $33,$2A,$3D,$39+$80		; NEXT
	DEFB $35,$34,$30,$2A+$80		; POKE
	DEFB $35,$37,$2E,$33,$39+$80		; PRINT
	DEFB $35,$31,$34,$39+$80		; PLOT
	DEFB $37,$3A,$33+$80			; RUN
	DEFB $38,$26,$3B,$2A+$80		; SAVE
	DEFB $37,$26,$33,$29+$80		; RAND
	DEFB $2E,$2B+$80			; IF
	DEFB $28,$31,$38+$80			; CLS
	DEFB $3A,$33,$35,$31,$34,$39+$80	; UNPLOT
	DEFB $28,$31,$2A,$26,$37+$80		; CLEAR
	DEFB $37,$2A,$39,$3A,$37,$33+$80	; RETURN
	DEFB $28,$34,$35,$3E+$80		; COPY
	DEFB $37,$33,$29+$80			; RND
	DEFB $2E,$33,$30,$2A,$3E,$0D+$80	; INKEY$
	DEFB $35,$2E+$80			; PI

; ------------------------------
; THE 'LOAD-SAVE UPDATE' ROUTINE
; ------------------------------
;
;; LOAD/SAVE
L01FC:
	INC HL			;
	EX DE,HL		;
	LD HL,($4014)		; system variable edit line E_LINE.
	SCF			; set carry flag
	SBC HL,DE		;
	EX DE,HL		;
	RET NC			; return if more bytes to load/save.

	POP HL			; else drop return address

; ----------------------
; THE 'DISPLAY' ROUTINES
; ----------------------
;
;; SLOW/FAST
L0207:
	LD HL,$403B		; Address the system variable CDFLAG.
	LD A,(HL)		; Load value to the accumulator.
	RLA			; rotate bit 6 to position 7.
	XOR (HL)		; exclusive or with original bit 7.
	RLA			; rotate result out to carry.
	RET NC			; return if both bits were the same.

;   Now test if this really is a ZX81 or a ZX80 running the upgraded ROM.
;   The standard ZX80 did not have an NMI generator.

	LD A,$7F		; Load accumulator with %011111111
	EX AF,AF'		; save in AF'

#ifdef zxmore			; A counter within which an NMI should occur

	LD B,$22		; if this is a zxmore.
#else
	LD B,$11		; if this is a ZX81.
#endif		
	OUT ($FE),A		; start the NMI generator.

;  Note that if this is a ZX81 then the NMI will increment AF'.

;; LOOP-11
L0216:
	DJNZ L0216		; self loop to give the NMI a chance to kick in.
				; = 16*13 clock cycles + 8 = 216 clock cycles.

	OUT ($FD),A		; Turn off the NMI generator.
	EX AF,AF'		; bring back the AF' value.
	RLA			; test bit 7.
	JR NC,L0226		; forward, if bit 7 is still reset, to NO-SLOW.

;   If the AF' was incremented then the NMI generator works and SLOW mode can be set.

	SET 7,(HL)		; Indicate SLOW mode - Compute and Display.

	PUSH AF			; *  Save Main Registers
	PUSH BC			; **
	PUSH DE			; ***
	PUSH HL			; ****

	JR L0229		; skip forward - to DISPLAY-1.
; ---

;; NO-SLOW
L0226:
	RES 6,(HL)		; reset bit 6 of CDFLAG.
	RET 			; return.

; -----------------------
; THE 'MAIN DISPLAY' LOOP
; -----------------------
; This routine is executed once for every frame displayed.

;; DISPLAY-1
L0229:
	LD HL,($4034)		; fetch two-byte system variable FRAMES.
	DEC HL			; decrement frames counter.

;; DISPLAY-P
L022D:
	LD A,$7F		; prepare a mask
	AND H			; pick up bits 6-0 of H.
	OR L			; and any bits of L.
	LD A,H			; reload A with all bits of H for PAUSE test.

;   Note both branches must take the same time.

	JR NZ,L0237		; (12/7) forward if bits 14-0 are not zero 
				; to ANOTHER

	RLA			; (4) test bit 15 of FRAMES.
	JR L0239		; (12) forward with result to OVER-NC
; ---

;; ANOTHER
L0237:
	LD B,(HL)		; (7) Note. Harmless Nonsensical Timing weight.
	SCF			; (4) Set Carry Flag.

; Note. the branch to here takes either (12)(7)(4) cyles or (7)(4)(12) cycles.

;; OVER-NC
L0239:
	LD H,A			; (4)  set H to zero
	LD ($4034),HL		; (16) update system variable FRAMES 
	RET NC			; (11/5) return if FRAMES is in use by PAUSE 
				; command.
;; DISPLAY-2
L023E:
	CALL L02BB		; routine KEYBOARD gets the key row in H and 
				; the column in L. Reading the ports also starts
				; the TV frame synchronization pulse. (VSYNC)(T735)

	LD BC,($4025)		; fetch the last key values read from LAST_K
	LD ($4025),HL		; update LAST_K with new values.

	LD A,B			; load A with previous column - will be $FF if
				; there was no key.
	ADD A,$02		; adding two will set carry if no previous key.

	SBC HL,BC		; subtract with the carry the two key values.

; If the same key value has been returned twice then HL will be zero.

	LD A,($4027)		; fetch system variable DEBOUNCE
	OR H			; and OR with both bytes of the difference
	OR L			; setting the zero flag for the upcoming branch.

	LD E,B			; transfer the column value to E
	LD B,$0B		; and load B with eleven 

	LD HL,$403B		; address system variable CDFLAG 
	RES 0,(HL)		; reset the rightmost bit of CDFLAG (VSYNC=T735+T119=T854)
	JR NZ,L0264		; skip forward if debounce/diff >0 to NO-KEY (+T12)

	BIT 7,(HL)		; test compute and display bit of CDFLAG
	SET 0,(HL)		; set the rightmost bit of CDFLAG.
	RET Z			; return if bit 7 indicated fast mode.

	DEC B			; (4) decrement the counter.
	NOP			; (4) Timing - 4 clock cycles. ??
	SCF			; (4) Set Carry Flag (+T7+T44=+T49)

;; NO-KEY			  Tdiff=T49-T12=T37
L0264:
	LD HL,$4027		; (10) sv DEBOUNCE
	CCF			; (4)  Complement Carry Flag
	RL B			; (8)  rotate left B picking up carry	(B=2*11+CY=23 if no key)
				;  C<-76543210<-C			(B=2*10+NC=20 else)
;; LOOP-B			  Tcomp=(23-20)*T13=T39
L026A:
	DJNZ L026A		; self-loop while B>0 to LOOP-B (T=19*13+8=T255)
				; (VSYNC=T854+T12+T22+T255+T39=T1182)

	LD B,(HL)		; fetch value of DEBOUNCE to B
	LD A,E			; transfer column value
	CP $FE			;
	SBC A,A			;
	LD B,$1F		;
	OR (HL)			;
	AND B			;
	RRA			;
	LD (HL),A		; (T1233)

	OUT ($FF),A		; end the TV frame synchronization pulse.

	LD HL,($400C)		; (12) set HL to the Display File from D_FILE
	SET 7,H			; (8) set bit 15 to address the echo display.

	CALL L0292		; (17) routine DISPLAY-3 displays the top set 
				; of blank lines.
; ---------------------
; THE 'VIDEO-1' ROUTINE
; ---------------------

;; R-IX-1
L0281:
	LD A,R			; (9)  Harmless Nonsensical Timing or something
				; very clever?
	LD BC,$1901		; (10) 25 lines, 1 scanline in first.
	LD A,$F5		; (7)  This value will be loaded into R and 
				; ensures that the cycle starts at the right 
				; part of the display  - after 32nd character 
				; position.

	CALL L02B5		; (17) routine DISPLAY-5 completes the current 
				; blank line and then generates the display of 
				; the live picture using INT interrupts
				; The final interrupt returns to the next 
				; address.
L028B:
	DEC HL			; point HL to the last NEWLINE/HALT.

	CALL L0292		; routine DISPLAY-3 displays the bottom set of
				; blank lines.
; ---
;; R-IX-2
L028F:
	JP L0229		; JUMP back to DISPLAY-1

; ---------------------------------
; THE 'DISPLAY BLANK LINES' ROUTINE 
; ---------------------------------
;   This subroutine is called twice (see above) to generate first the blank 
;   lines at the top of the television display and then the blank lines at the
;   bottom of the display. 

;; DISPLAY-3
L0292:
	POP IX			; pop the return address to IX register.
				; will be either L0281 or L028F - see above.

	LD C,(IY+$28)		; load C with value of system constant MARGIN.
	BIT 7,(IY+$3B)		; test CDFLAG for compute and display.
	JR Z,L02A9		; forward, with FAST mode, to DISPLAY-4

	LD A,C			; move MARGIN to A - 31d or 55d.
	NEG			; Negate
	INC A			;
	EX AF,AF'		; place negative count of blank lines in A'

	OUT ($FE),A		; enable the NMI generator.

	POP HL			; ****
	POP DE			; ***
	POP BC			; **
	POP AF			; *  Restore Main Registers

	RET 			; return - end of interrupt.  Return is to 
				; user's program - BASIC or machine code.
				; which will be interrupted by every NMI.
; ------------------------
; THE 'FAST MODE' ROUTINES
; ------------------------

;; DISPLAY-4
L02A9:
	LD A,$FC		; (7)  load A with first R delay value
	LD B,$01		; (7)  one row only.

	CALL L02B5		; (17) routine DISPLAY-5

	DEC HL			; (6)  point back to the HALT.
	EX (SP),HL		; (19) Harmless Nonsensical Timing if paired.
	EX (SP),HL		; (19) Harmless Nonsensical Timing.
	JP (IX)			; (8)  to L0281 or L028F

; --------------------------
; THE 'DISPLAY-5' SUBROUTINE
; --------------------------
;   This subroutine is called from SLOW mode and FAST mode to generate the 
;   central TV picture. With SLOW mode the R register is incremented, with
;   each instruction, to $F7 by the time it completes.  With fast mode, the 
;   final R value will be $FF and an interrupt will occur as soon as the 
;   Program Counter reaches the HALT.  (24 clock cycles)

;; DISPLAY-5
L02B5:
	LD R,A			; (9) Load R from A.    R = slow: $F5 fast: $FC
	LD A,$DD		; (7) load future R value.	  $F6	    $FD

	EI			; (4) Enable Interrupts		  $F7	    $FE

	JP (HL)			; (4) jump to the echo display.	  $F8	    $FF

; ----------------------------------
; THE 'KEYBOARD SCANNING' SUBROUTINE
; ----------------------------------
; The keyboard is read during the vertical sync interval while no video is 
; being displayed.  Reading a port with address bit 0 low i.e. $FE starts the 
; vertical sync pulse.

;; KEYBOARD
L02BB:
	LD HL,$FFFF		; (16) prepare a buffer to take key.
	LD BC,$FEFE		; (20) set BC to port $FEFE. The B register, 
				; with its single reset bit also acts as 
				; an 8-counter.
	IN A,(C)		; (12) read the port - all 16 bits are put on 
				; the address bus.  Start VSYNC pulse.
	OR $01			; (7)  set the rightmost bit so as to ignore 
				; the SHIFT key.
;; EACH-LINE			  (T19)
L02C5:
	OR $E0			; [7] OR %11100000
	LD D,A			; [4] transfer to D.
	CPL			; [4] complement - only bits 4-0 meaningful now.
	CP $01			; [7] sets carry if A is zero.
	SBC A,A			; [4] $FF if $00 else zero.
	OR B			; [7] $FF or port FE,FD,FB....
	AND L			; [4] unless more than one key, L will still be 
				;     $FF. if more than one key is pressed then A is 
				;     now invalid.
	LD L,A			; [4] transfer to L.

; now consider the column identifier.

	LD A,H			; [4] will be $FF if no previous keys.
	AND D			; [4] 111xxxxx
	LD H,A			; [4] transfer A to H

; since only one key may be pressed, H will, if valid, be one of
; 11111110, 11111101, 11111011, 11110111, 11101111
; reading from the outer column, say Q, to the inner column, say T.

	RLC B			; [8]  rotate the 8-counter/port address.
				; sets carry if more to do.
	IN A,(C)		; [10] read another half-row.
				; all five bits this time. (T70)

	JR C,L02C5		; [12](7) loop back, until done, to EACH-LINE
				; (7*T82+T77=T651)

;   The last row read is SHIFT,Z,X,C,V  for the second time.

	RRA			; (4) test the shift key - carry will be reset
				;	if the key is pressed.
	RL H			; (8) rotate left H picking up the carry giving
				;	column values -
				;	$FD, $FB, $F7, $EF, $DF.
				;	or $FC, $FA, $F6, $EE, $DE if shifted.

;   We now have H identifying the column and L identifying the row in the
;   keyboard matrix.

;   This is a good time to test if this is an American or British machine.
;   The US machine has an extra diode that causes bit 6 of a byte read from
;   a port to be reset.

	RLA			; (4) compensate for the shift test.
	RLA			; (4) rotate bit 7 out.
	RLA			; (4) test bit 6.

	SBC A,A			; (4)	$FF or $00 {USA}
	AND $18			; (7)	$18 or $00
	ADD A,$1F		; (7)	$37 or $1F

;   result is either 31 (USA) or 55 (UK) blank lines above and below the TV 
;   picture.

	LD ($4028),A		; (13) update system variable MARGIN

	RET 			; (10) return
	 			; (T_VSYNC=T19+T651+T65=T735)

; ------------------------------
; THE 'SET FAST MODE' SUBROUTINE
; ------------------------------
;
;; SET-FAST
L02E7:
	BIT 7,(IY+$3B)		; test slow mode (CDFLAG)
	RET Z			; return in case of fast mode

	HALT			; else wait for Interrupt
	OUT ($FD),A		; switch off NMI (fast mode)
	RES 7,(IY+$3B)		; reset CDFLAG
	RET 			; return.

; --------------
; THE 'REPORT-F'
; --------------

;; REPORT-F
L02F4:
	RST 08H			; ERROR-1
	DEFB $0E		; Error Report: No Program Name supplied.

; --------------------------
; THE 'SAVE COMMAND' ROUTINE
; --------------------------
;
;; SAVE
L02F6:
	CALL L03A8		; routine NAME
	JR C,L02F4		; back with null name to REPORT-F above.

	EX DE,HL		;
	LD DE,$12CB		; five seconds timing value

;; HEADER
L02FF:
	CALL L0F46		; routine BREAK-1
	JR NC,L0332		; to BREAK-2

;; DELAY-1
L0304:
	DJNZ L0304		; to DELAY-1

	DEC DE			;
	LD A,D			;
	OR E			;
	JR NZ,L02FF		; back for delay to HEADER

;; OUT-NAME
L030B:
	CALL L031E		; routine OUT-BYTE
	BIT 7,(HL)		; test for inverted bit.
	INC HL			; address next character of name.
	JR Z,L030B		; back if not inverted to OUT-NAME

; now start saving the system variables onwards.

	LD HL,$4009		; set start of area to VERSN thereby
				; preserving RAMTOP etc.
;; OUT-PROG
L0316:
	CALL L031E		; routine OUT-BYTE

	CALL L01FC		; routine LOAD/SAVE			>>

	JR L0316		; loop back to OUT-PROG

; -------------------------
; THE 'OUT-BYTE' SUBROUTINE
; -------------------------
; This subroutine outputs a byte a bit at a time to a domestic tape recorder.

;; OUT-BYTE
L031E:
	LD E,(HL)		; fetch byte to be saved.
	SCF			; set carry flag - as a marker.

;; EACH-BIT
L0320:
	RL E			;  C < 76543210 < C
	RET Z			; return when the marker bit has passed 
				; right through.			>>

	SBC A,A			; $FF if set bit or $00 with no carry.
	AND $05			; $05			$00
	ADD A,$04		; $09			$04
	LD C,A			; transfer timer to C. a set bit has a longer
				; pulse than a reset bit.
;; PULSES
L0329:
	OUT ($FF),A		; pulse to cassette.
	LD B,$23		; set timing constant

;; DELAY-2
L032D:
	DJNZ L032D		; self-loop to DELAY-2

	CALL L0F46		; routine BREAK-1 test for BREAK key.

;; BREAK-2
L0332:
	JR NC,L03A6		; forward with break to REPORT-D

	LD B,$1E		; set timing value.

;; DELAY-3
L0336:
	DJNZ L0336		; self-loop to DELAY-3

	DEC C			; decrement counter
	JR NZ,L0329		; loop back to PULSES

;; DELAY-4
L033B:	AND A			; clear carry for next bit test.
	DJNZ L033B		; self loop to DELAY-4 (B is zero - 256)

	JR L0320		; loop back to EACH-BIT

; --------------------------
; THE 'LOAD COMMAND' ROUTINE
; --------------------------
;
;; LOAD
L0340:
	CALL L03A8		; routine NAME

; DE points to start of name in RAM.

	RL D			; pick up carry 
	RRC D			; carry now in bit 7.

;; NEXT-PROG
L0347:
	CALL L034C		; routine IN-BYTE
	JR L0347		; loop to NEXT-PROG

; ------------------------
; THE 'IN-BYTE' SUBROUTINE
; ------------------------

;; IN-BYTE
L034C:
	LD C,$01		; prepare an eight counter 00000001.

;; NEXT-BIT
L034E:
	LD B,$00		; set counter to 256

;; BREAK-3
L0350:
	LD A,$7F		; read the keyboard row 
	IN A,($FE)		; with the SPACE key.

	OUT ($FF),A		; output signal to screen.

	RRA			; test for SPACE pressed.
	JR NC,L03A2		; forward if so to BREAK-4

	RLA			; reverse above rotation
	RLA			; test tape bit.
	JR C,L0385		; forward if set to GET-BIT

	DJNZ L0350		; loop back to BREAK-3

	POP AF			; drop the return address.
	CP D			; ugh.

;; RESTART
L0361:
	JP NC,L03E5		; jump forward to INITIAL if D is zero 
				; to reset the system
				; if the tape signal has timed out for example
				; if the tape is stopped. Not just a simple 
				; report as some system variables will have
				; been overwritten.

	LD H,D			; else transfer the start of name
	LD L,E			; to the HL register

;; IN-NAME
L0366:
	CALL L034C		; routine IN-BYTE is sort of recursion for name
				; part. received byte in C.
	BIT 7,D			; is name the null string ?
	LD A,C			; transfer byte to A.
	JR NZ,L0371		; forward with null string to MATCHING

	CP (HL)			; else compare with string in memory.
	JR NZ,L0347		; back with mis-match to NEXT-PROG
				; (seemingly out of subroutine but return 
				; address has been dropped).
;; MATCHING
L0371:
	INC HL			; address next character of name
	RLA			; test for inverted bit.
	JR NC,L0366		; back if not to IN-NAME

; the name has been matched in full. 
; proceed to load the data but first increment the high byte of E_LINE, which
; is one of the system variables to be loaded in. Since the low byte is loaded
; before the high byte, it is possible that, at the in-between stage, a false
; value could cause the load to end prematurely - see  LOAD/SAVE check.

	INC (IY+$15)		; increment system variable E_LINE_hi.
	LD HL,$4009		; start loading at system variable VERSN.

;; IN-PROG
L037B:
	LD D,B			; set D to zero as indicator.
	CALL L034C		; routine IN-BYTE loads a byte

	LD (HL),C		; insert assembled byte in memory.
	CALL L01FC		; routine LOAD/SAVE			>>

	JR L037B		; loop back to IN-PROG
; ---

; this branch assembles a full byte before exiting normally
; from the IN-BYTE subroutine.

;; GET-BIT
L0385:
	PUSH DE			; save the 
	LD E,$94		; timing value.

;; TRAILER
L0388:
	LD B,$1A		; counter to twenty six.

;; COUNTER
L038A:
	DEC E			; decrement the measuring timer.
	IN A,($FE)		; read the
	RLA			;
	BIT 7,E			;
	LD A,E			;
	JR C,L0388		; loop back with carry to TRAILER

	DJNZ L038A		; to COUNTER

	POP DE			;
	JR NZ,L039C		; to BIT-DONE

	CP $56			;
	JR NC,L034E		; to NEXT-BIT

;; BIT-DONE
L039C:
	CCF			; complement carry flag
	RL C			;
	JR NC,L034E		; to NEXT-BIT

	RET 			; return with full byte.
; ---

; if break is pressed while loading data then perform a reset.
; if break pressed while waiting for program on tape then OK to break.

;; BREAK-4
L03A2:
	LD A,D			; transfer indicator to A.
	AND A			; test for zero.
	JR Z,L0361		; back if so to RESTART

;; REPORT-D
L03A6:
	RST 08H			; ERROR-1
	DEFB $0C		; Error Report: BREAK - CONT repeats

; -----------------------------
; THE 'PROGRAM NAME' SUBROUTINE
; -----------------------------
;
;; NAME
L03A8:
	CALL SCANNING		; routine SCANNING
	LD A,($4001)		; sv FLAGS
	ADD A,A			;
	JP M,L0D9A		; to REPORT-C

	POP HL			;
	RET NC			;

	PUSH HL			;
	CALL L02E7		; routine SET-FAST

	CALL STK_FETCH		; routine STK-FETCH

	LD H,D			;
	LD L,E			;
	DEC C			;
	RET M			;

	ADD HL,BC		;
	SET 7,(HL)		;
	RET 			;

; -------------------------
; THE 'NEW' COMMAND ROUTINE
; -------------------------
;
;; NEW
L03C3:
	CALL L02E7		; routine SET-FAST

	LD BC,($4004)		; fetch value of system variable RAMTOP
	DEC BC			; point to last system byte.

; -----------------------
; THE 'RAM CHECK' ROUTINE
; -----------------------
;
;; RAM-CHECK
L03CB:
	LD H,B			;
	LD L,C			;
	LD A,$3F		;

;; RAM-FILL
L03CF:
	LD (HL),$02		;
	DEC HL			;
	CP H			;
	JR NZ,L03CF		; to RAM-FILL

;; RAM-READ
L03D5:
	AND A			;
	SBC HL,BC		;
	ADD HL,BC		;
	INC HL			;
	JR NC,L03E2		; to SET-TOP

	DEC (HL)		;
	JR Z,L03E2		; to SET-TOP

	DEC (HL)		;
	JR Z,L03D5		; to RAM-READ

;; SET-TOP
L03E2:
	LD ($4004),HL		; set system variable RAMTOP to first byte 
				; above the BASIC system area.
; ----------------------------
; THE 'INITIALIZATION' ROUTINE
; ----------------------------
;
;; INITIAL
L03E5:	LD HL,($4004)		; fetch system variable RAMTOP.
	DEC HL			; point to last system byte.
	LD (HL),$3E		; make GOSUB end-marker $3E - too high for
				; high order byte of line number.
				; (was $3F on ZX80)
	DEC HL			; point to unimportant low-order byte.
	LD SP,HL		; and initialize the stack-pointer to this
				; location.
	DEC HL			; point to first location on the machine stack
	DEC HL			; which will be filled by next CALL/PUSH.
	LD ($4002),HL		; set the error stack pointer ERR_SP to
				; the base of the now empty machine stack.

; Now set the I register so that the video hardware knows where to find the
; character set. This ROM only uses the character set when printing to 
; the ZX Printer. The TV picture is formed by the external video hardware. 
; Consider also, that this 8K ROM can be retro-fitted to the ZX80 instead of 
; its original 4K ROM so the video hardware could be on the ZX80.

	LD A,$1E		; address for this ROM is $1E00.
	LD I,A			; set I register from A.
	IM 1			; select Z80 Interrupt Mode 1.

	LD IY,$4000		; set IY to the start of RAM so that the 
				; system variables can be indexed.
	LD (IY+$3B),$40		; set CDFLAG 0100 0000. Bit 6 indicates 
				; Compute and Display required.

	LD HL,$407D		; The first location after System Variables -
				; 16509 decimal.
	LD ($400C),HL		; set system variable D_FILE to this value.
	LD B,$19		; prepare minimal screen of 24 NEWLINEs
				; following an initial NEWLINE.
;; LINE
L0408:	LD (HL),$76		; insert NEWLINE (HALT instruction)
	INC HL			; point to next location.
	DJNZ L0408		; loop back for all twenty five to LINE

	LD ($4010),HL		; set system variable VARS to next location

	CALL L149A		; routine CLEAR sets $80 end-marker and the 
				; dynamic memory pointers E_LINE, STKBOT and
				; STKEND.
;; N/L-ONLY
L0413:	CALL L14AD		; routine CURSOR-IN inserts the cursor and 
				; end-marker in the Edit Line also setting
				; size of lower display to two lines.

	CALL L0207		; routine SLOW/FAST selects COMPUTE and DISPLAY

; ---------------------------
; THE 'BASIC LISTING' SECTION
; ---------------------------
;
;; UPPER
L0419:	CALL L0A2A		; routine CLS
	LD HL,($400A)		; sv E_PPC
	LD DE,($4023)		; sv S_TOP
	AND A			;
	SBC HL,DE		;
	EX DE,HL		;
	JR NC,L042D		; to ADDR-TOP

	ADD HL,DE		;
	LD ($4023),HL		; sv S_TOP
;
;; ADDR-TOP
L042D:	CALL L09D8		; routine LINE-ADDR
	JR Z,L0433		; to LIST-TOP

	EX DE,HL		;
;
;; LIST-TOP
L0433:	CALL L073E		; routine LIST-PROG
	DEC (IY+$1E)		; sv BERG
	JR NZ,L0472		; to LOWER

	LD HL,($400A)		; sv E_PPC
	CALL L09D8		; routine LINE-ADDR
	LD HL,($4016)		; sv CH_ADD
	SCF			; Set Carry Flag
	SBC HL,DE		;
	LD HL,$4023		; sv S_TOP_lo
	JR NC,L0457		; to INC-LINE

	EX DE,HL		;
	LD A,(HL)		;
	INC HL			;
	LDI			;
	LD (DE),A		;
	JR  L0419		; to UPPER
;
;; DOWN-KEY
L0454:	LD HL,$400A		; sv E_PPC_lo

;; INC-LINE
L0457:	LD E,(HL)		;
	INC HL			;
	LD D,(HL)		;
	PUSH HL			;
	EX DE,HL		;
	INC HL	;
	CALL L09D8		; routine LINE-ADDR
	CALL L05BB		; routine LINE-NO
	POP HL			;

;; KEY-INPUT
L0464:	BIT 5,(IY+$2D)		; sv FLAGX
	JR NZ,L0472		; forward to LOWER

	LD (HL),D		;
	DEC HL			;
	LD (HL),E		;
	JR L0419		; to UPPER

; ----------------------------
; THE 'EDIT LINE COPY' SECTION
; ----------------------------
; This routine sets the edit line to just the cursor when
; 1) There is not enough memory to edit a BASIC line.
; 2) The edit key is used during input.
; The entry point LOWER
;
;; EDIT-INP
L046F:	CALL L14AD		; routine CURSOR-IN sets cursor only edit line.

; ->

;; LOWER
L0472:	LD HL,($4014)		; fetch edit line start from E_LINE.

;; EACH-CHAR
L0475:	LD A,(HL)		; fetch a character from edit line.
	CP $7E			; compare to the number marker.
	JR NZ,L0482		; forward if not to END-LINE

	LD BC,$0006		; else six invisible bytes to be removed.
	CALL L0A60		; routine RECLAIM-2
	JR L0475		; back to EACH-CHAR
; ---
;
;; END-LINE
L0482:	CP $76			;
	INC HL			;
	JR NZ,L0475		; to EACH-CHAR

;; EDIT-LINE
L0487:	CALL L0537		; routine CURSOR sets cursor K or L.

;; EDIT-ROOM
L048A:	CALL L0A1F		; routine LINE-ENDS
	LD HL,($4014)		; sv E_LINE_lo
	LD (IY+$00),$FF		; sv ERR_NR
	CALL L0766		; routine COPY-LINE
	BIT 7,(IY+$00)		; sv ERR_NR
	JR NZ,L04C1		; to DISPLAY-6

	LD A,($4022)		; sv DF_SZ
	CP $18			;
	JR NC,L04C1		; to DISPLAY-6

	INC A			;
	LD ($4022),A		; sv DF_SZ
	LD B,A			;
	LD C,$01		;
	CALL L0918		; routine LOC-ADDR
	LD D,H			;
	LD E,L			;
	LD A,(HL)		;

;; FREE-LINE
L04B1:	DEC HL			;
	CP (HL)			;
	JR NZ,L04B1		; to FREE-LINE

	INC HL			;
	EX DE,HL		;
	LD A,($4005)		; sv RAMTOP_hi
	CP $4D  ;
	CALL C,L0A5D		; routine RECLAIM-1
	JR L048A		; to EDIT-ROOM
;
; --------------------------
; THE 'WAIT FOR KEY' SECTION
; --------------------------
;
;; DISPLAY-6
L04C1:	LD HL,$0000		;
	LD ($4018),HL		; sv X_PTR_lo

	LD HL,$403B		; system variable CDFLAG
	BIT 7,(HL)		;

	CALL Z,L0229		; routine DISPLAY-1

;; SLOW-DISP
L04CF:	BIT 0,(HL)		;
	JR Z,L04CF		; to SLOW-DISP

	LD BC,($4025)		; sv LAST_K
	CALL L0F4B		; routine DEBOUNCE
	CALL L07BD		; routine DECODE

	JR NC,L0472		; back to LOWER
;
; -------------------------------
; THE 'KEYBOARD DECODING' SECTION
; -------------------------------
;   The decoded key value is in E and HL points to the position in the 
;   key table. D contains zero.

;; K-DECODE 
L04DF:	LD A,($4006)		; Fetch value of system variable MODE
	DEC A			; test the three values together

	JP M,L0508		; forward, if was zero, to FETCH-2

	JR NZ,L04F7		; forward, if was 2, to FETCH-1

;   The original value was one and is now zero.

	LD ($4006),A		; update the system variable MODE

	DEC E			; reduce E to range $00 - $7F
	LD A,E			; place in A
	SUB $27			; subtract 39 setting carry if range 00 - 38
	JR C,L04F2		; forward, if so, to FUNC-BASE

	LD E,A			; else set E to reduced value

;; FUNC-BASE
L04F2:	LD HL,L00CC		; address of K-FUNCT table for function keys.
	JR L0505		; forward to TABLE-ADD
; ---

;; FETCH-1
L04F7:	LD A,(HL)		;
	CP $76			;
	JR Z,L052B		; to K/L-KEY

	CP $40			;
	SET 7,A			;
	JR C,L051B		; to ENTER

	LD HL,$00C7		; (expr reqd)

;; TABLE-ADD
L0505:	ADD HL,DE		;
	JR L0515		; to FETCH-3
; ---

;; FETCH-2
L0508:	LD A,(HL)		;
	BIT 2,(IY+$01)		; sv FLAGS  - K or L mode ?
	JR NZ,L0516		; to TEST-CURS

	ADD A,$C0		;
	CP $E6			;
	JR NC,L0516		; to TEST-CURS

;; FETCH-3
L0515:	LD A,(HL)		;

;; TEST-CURS
L0516:	CP $F0			;
	JP PE,L052D		; to KEY-SORT

;; ENTER
L051B:	LD E,A			;
	CALL L0537		; routine CURSOR

	LD A,E			;
	CALL L0526		; routine ADD-CHAR

;; BACK-NEXT
L0523:	JP L0472		; back to LOWER

; ------------------------------
; THE 'ADD CHARACTER' SUBROUTINE
; ------------------------------
;
;; ADD-CHAR
L0526:	CALL L099B		; routine ONE-SPACE
	LD (DE),A		;
	RET 			;
;
; -------------------------
; THE 'CURSOR KEYS' ROUTINE
; -------------------------
;
;; K/L-KEY
L052B:	LD A,$78		;

;; KEY-SORT
L052D:	LD E,A			;
	LD HL,$0482		; base address of ED-KEYS (exp reqd)
	ADD HL,DE		;
	ADD HL,DE		;
	LD C,(HL)		;
	INC HL			;
	LD B,(HL)		;
	PUSH BC			;

;; CURSOR
L0537:	LD HL,($4014)		; sv E_LINE_lo
	BIT 5,(IY+$2D)		; sv FLAGX
	JR NZ,L0556		; to L-MODE

;; K-MODE
L0540:	RES 2,(IY+$01)		; sv FLAGS  - Signal use K mode

;; TEST-CHAR
L0544:	LD A,(HL)		;
	CP $7F			;
	RET Z			; return

	INC HL			;
	CALL L07B4		; routine NUMBER
	JR Z,L0544		; to TEST-CHAR

	CP $26			;
	JR C,L0544		; to TEST-CHAR

	CP $DE			;
	JR Z,L0540		; to K-MODE

;; L-MODE
L0556:	SET 2,(IY+$01)		; sv FLAGS  - Signal use L mode
	JR L0544		; to TEST-CHAR
;
; --------------------------
; THE 'CLEAR-ONE' SUBROUTINE
; --------------------------
;
;; CLEAR-ONE
L055C:	LD BC,$0001		;
	JP L0A60		; to RECLAIM-2
;
; ------------------------
; THE 'EDITING KEYS' TABLE
; ------------------------
;
;; ED-KEYS
L0562:	DEFW L059F	; Address: $059F ; Address: UP-KEY
	DEFW L0454	; Address: $0454 ; Address: DOWN-KEY
	DEFW L0576	; Address: $0576 ; Address: LEFT-KEY
	DEFW L057F	; Address: $057F ; Address: RIGHT-KEY
	DEFW L05AF	; Address: $05AF ; Address: FUNCTION
	DEFW L05C4	; Address: $05C4 ; Address: EDIT-KEY
	DEFW L060C	; Address: $060C ; Address: N/L-KEY
	DEFW L058B	; Address: $058B ; Address: RUBOUT
	DEFW L05AF	; Address: $05AF ; Address: FUNCTION
	DEFW L05AF	; Address: $05AF ; Address: FUNCTION
;
; -------------------------
; THE 'CURSOR LEFT' ROUTINE
; -------------------------
;
;; LEFT-KEY
L0576:	CALL L0593		; routine LEFT-EDGE
	LD A,(HL)		;
	LD (HL),$7F		;
	INC HL			;
	JR L0588		; to GET-CODE
;
; --------------------------
; THE 'CURSOR RIGHT' ROUTINE
; --------------------------
;
;; RIGHT-KEY
L057F:	INC HL			;
	LD A,(HL)		;
	CP $76  ;
	JR Z,L059D		; to ENDED-2

	LD (HL),$7F		;
	DEC HL			;
;
;; GET-CODE
L0588:	LD (HL),A		;
;
;; ENDED-1
L0589:	JR L0523		; to BACK-NEXT
;
; ----------------------------
; THE patched 'RUBOUT' ROUTINE
; ----------------------------
;
;; RUBOUT
L058B:	CALL L0593		; routine LEFT-EDGE
	CALL L055C		; routine CLEAR-ONE
	jr L0523		; to BACK-NEXT
;
; --------------------------------
; THE patched 'ED-EDGE' SUBROUTINE
; --------------------------------
;
;; LEFT-EDGE
L0593:	DEC HL			;
	LD DE,($4014)		; sv E_LINE_lo
	LD A,(DE)		;
	CP $7F			;
	RET NZ			;

	POP DE			;

;; ENDED-2
L059D:
	jr L0523		; to BACK-NEXT
;
; -----------------------
; THE 'CURSOR UP' ROUTINE
; -----------------------
;
;; UP-KEY
L059F:	LD HL,($400A)		; sv E_PPC_lo
	CALL L09D8		; routine LINE-ADDR
	EX DE,HL		;
	CALL L05BB		; routine LINE-NO
	LD HL,$400B		; point to system variable E_PPC_hi
	JP L0464		; jump back to KEY-INPUT
;
; --------------------------
; THE 'FUNCTION KEY' ROUTINE
; --------------------------
;
;; FUNCTION
L05AF:	LD A,E			;
	AND $07			;
	LD ($4006),A		; sv MODE
	JR L059D		; back to ENDED-2
;
; ------------------------------------
; THE 'COLLECT LINE NUMBER' SUBROUTINE
; ------------------------------------
;
;; ZERO-DE
L05B7:	EX DE,HL		;
	LD DE,L04C1 + 1		; $04C2 - a location addressing two zeros.
; ->

;; LINE-NO
L05BB:	LD A,(HL)		;
	AND $C0  ;
	JR NZ,L05B7		; to ZERO-DE

	LD D,(HL)		;
	INC HL			;
	LD E,(HL)		;
	RET 			;
;
; ----------------------
; THE 'EDIT KEY' ROUTINE
; ----------------------
;
;; EDIT-KEY
L05C4:	CALL L0A1F		; routine LINE-ENDS clears lower display.

	LD HL,L046F		; Address: EDIT-INP
	PUSH HL			; ** is pushed as an error looping address.

	BIT 5,(IY+$2D)		; test FLAGX
	RET NZ			; indirect jump if in input mode
				; to L046F, EDIT-INP (begin again).
	LD HL,($4014)		; fetch E_LINE
	LD ($400E),HL		; and use to update the screen cursor DF_CC

; so now RST $10 will print the line numbers to the edit line instead of screen.
; first make sure that no newline/out of screen can occur while printing the
; line numbers to the edit line.

	LD HL,$1821		; prepare line 0, column 0.
	LD ($4039),HL		; update S_POSN with these dummy values.

	LD HL,($400A)		; fetch current line from E_PPC may be a 
				; non-existent line e.g. last line deleted.
	CALL L09D8		; routine LINE-ADDR gets address or that of
				; the following line.
	CALL L05BB		; routine LINE-NO gets line number if any in DE
				; leaving HL pointing at second low byte.

	LD A,D			; test the line number for zero.
	OR E			;
	RET Z			; return if no line number - no program to edit.

	DEC HL			; point to high byte.
	CALL L0AA5		; routine OUT-NO writes number to edit line.

	INC HL			; point to length bytes.
	LD C,(HL)		; low byte to C.
	INC HL			;
	LD B,(HL)		; high byte to B.

	INC HL			; point to first character in line.
	LD DE,($400E)		; fetch display file cursor DF_CC

	LD A,$7F		; prepare the cursor character.
	LD (DE),A		; and insert in edit line.
	INC DE			; increment intended destination.

	PUSH HL			; * save start of BASIC.

	LD HL,$001D		; set an overhead of 29 bytes.
	ADD HL,DE		; add in the address of cursor.
	ADD HL,BC		; add the length of the line.
	SBC HL,SP		; subtract the stack pointer.

	POP HL			; * restore pointer to start of BASIC.

	RET NC			; return if not enough room to L046F EDIT-INP.
				; the edit key appears not to work.

	LDIR			; else copy bytes from program to edit line.
				; Note. hidden floating point forms are also
				; copied to edit line.

	EX DE,HL		; transfer free location pointer to HL

	POP DE			; ** remove address EDIT-INP from stack.

	CALL L14A6		; routine SET-STK-B sets STKEND from HL.

	JR L059D		; back to ENDED-2 and after 3 more jumps
				; to L0472, LOWER.
				; Note. The LOWER routine removes the hidden 
				; floating-point numbers from the edit line.
;
; -------------------------
; THE 'NEWLINE KEY' ROUTINE
; -------------------------
;
;; N/L-KEY
L060C:	CALL L0A1F		; routine LINE-ENDS

	LD HL,L0472		; prepare address: LOWER

	BIT 5,(IY+$2D)		; sv FLAGX
	JR NZ,L0629		; to NOW-SCAN

	LD HL,($4014)		; sv E_LINE_lo
	LD A,(HL)		;
	CP $FF  ;
	JR Z,L0626		; to STK-UPPER

	CALL L08E2		; routine CLEAR-PRB
	CALL L0A2A		; routine CLS

;; STK-UPPER
L0626:	LD HL,L0419		; Address: UPPER

;; NOW-SCAN
L0629:	PUSH HL			; push routine address (LOWER or UPPER).
	CALL L0CBA		; routine LINE-SCAN
	POP HL			;
	CALL L0537		; routine CURSOR
	CALL L055C		; routine CLEAR-ONE
	CALL L0A73		; routine E-LINE-NO
	JR NZ,L064E		; to N/L-INP

	LD A,B			;
	OR C			;
	JP NZ,L06E0		; to N/L-LINE

	DEC BC			;
	DEC BC			;
	LD ($4007),BC		; sv PPC_lo
	LD (IY+$22),$02		; sv DF_SZ
	LD DE,($400C)		; sv D_FILE_lo

	JR L0661		; forward to TEST-NULL
; ---
;
;; N/L-INP
L064E:	CP $76			;
	JR Z,L0664		; to N/L-NULL

	LD BC,($4030)		; sv T_ADDR_lo
	CALL L0918		; routine LOC-ADDR
	LD DE,($4029)		; sv NXTLIN_lo
	LD (IY+$22),$02		; sv DF_SZ
;
;; TEST-NULL
L0661:	RST 18H			; GET-CHAR
	CP $76			;
;
;; N/L-NULL
L0664:	JP Z,L0413		; to N/L-ONLY

	LD (IY+$01),$80		; sv FLAGS
	EX DE,HL		;
;
;; NEXT-LINE
L066C:	LD ($4029),HL		; sv NXTLIN_lo
	EX DE,HL		;
	CALL L004D		; routine TEMP-PTR-2
	CALL L0CC1		; routine LINE-RUN
	RES 1,(IY+$01)		; sv FLAGS  - Signal printer not in use
	LD A,$C0		;
	LD (IY+$19),A		; sv X_PTR_lo
	CALL L14A3		; routine X-TEMP
	RES 5,(IY+$2D)		; sv FLAGX
	BIT 7,(IY+$00)		; sv ERR_NR
	JR Z,L06AE		; to STOP-LINE

	LD HL,($4029)		; sv NXTLIN_lo
	AND (HL) ;
	JR  NZ,L06AE		; to STOP-LINE

	LD D,(HL)		;
	INC HL			;
	LD E,(HL)		;
	LD ($4007),DE		; sv PPC_lo
	INC HL			;
	LD E,(HL)		;
	INC HL			;
	LD D,(HL)		;
	INC HL			;
	EX DE,HL		;
	ADD HL,DE		;
	CALL L0F46		; routine BREAK-1
	JR C,L066C		; to NEXT-LINE

	LD HL,$4000		; sv ERR_NR
	BIT 7,(HL)		;
	JR Z,L06AE		; to STOP-LINE

	LD (HL),$0C		;
;
;; STOP-LINE
L06AE:	BIT 7,(IY+$38)		; sv PR_CC
	CALL Z,L0871		; routine COPY-BUFF
	LD BC,$0121		;
	CALL L0918		; routine LOC-ADDR
	LD A,($4000)		; sv ERR_NR
	LD BC,($4007)		; sv PPC_lo
	INC A			;
	JR Z,L06D1		; to REPORT

	CP $09			;
	JR NZ,L06CA		; to CONTINUE

	INC BC			;
;
;; CONTINUE
L06CA:	LD ($402B),BC		; sv OLDPPC_lo
	JR NZ,L06D1		; to REPORT

	DEC BC			;
;
;; REPORT
L06D1:	CALL L07EB		; routine OUT-CODE
	LD A,$18		; '/'

	RST 10H			; PRINT-A
	CALL L0A98		; routine OUT-NUM
	CALL L14AD		; routine CURSOR-IN
	JP L04C1		; to DISPLAY-6
; ---
;
;; N/L-LINE
L06E0:	LD ($400A),BC		; sv E_PPC_lo
	LD HL,($4016)		; sv CH_ADD_lo
	EX DE,HL		;
	LD HL,L0413		; Address: N/L-ONLY
	PUSH HL			;
	LD HL,($401A)		; sv STKBOT_lo
	SBC HL,DE		;
	PUSH HL			;
	PUSH BC			;
	CALL L02E7		; routine SET-FAST
	CALL L0A2A		; routine CLS
	POP HL			;
	CALL L09D8		; routine LINE-ADDR
	JR NZ,L0705		; to COPY-OVER

	CALL L09F2		; routine NEXT-ONE
	CALL L0A60		; routine RECLAIM-2

;; COPY-OVER
L0705:	POP BC			;
	LD A,C  		;
	DEC A			;
	OR B			;
	RET Z			;

	PUSH BC			;
	INC BC			;
	INC BC			;
	INC BC			;
	INC BC			;
	DEC HL			;
	CALL L099E		; routine MAKE-ROOM
	CALL L0207		; routine SLOW/FAST
	POP BC			;
	PUSH BC			;
	INC DE			;
	LD HL,($401A)		; sv STKBOT_lo
	DEC HL			;
	LDDR			; copy bytes
	LD HL,($400A)	 	; sv E_PPC_lo
	EX DE,HL		;
	POP BC			;
	LD (HL),B		;
	DEC HL			;
	LD (HL),C		;
	DEC HL			;
	LD (HL),E		;
	DEC HL			;
	LD (HL),D		;

	RET 			; return.
;
; ---------------------------------------
; THE 'LIST' AND 'LLIST' COMMAND ROUTINES
; ---------------------------------------
;
;; LLIST
L072C:	SET 1,(IY+$01)		; sv FLAGS  - signal printer in use
;
;; LIST
L0730:	CALL FIND_INT		; routine FIND-INT

	LD A,B			; fetch high byte of user-supplied line number.
	AND $3F			; and crudely limit to range 1-16383.

	LD H,A			;
	LD L,C			;
	LD ($400A),HL		; sv E_PPC_lo
	CALL L09D8		; routine LINE-ADDR
;
;; LIST-PROG
L073E:	LD E,$00		;

;; UNTIL-END
L0740:	CALL L0745		; routine OUT-LINE lists one line of BASIC
				; making an early return when the screen is
				; full or the end of program is reached.    >>
	JR L0740		; loop back to UNTIL-END
;
; -----------------------------------
; THE 'PRINT A BASIC LINE' SUBROUTINE
; -----------------------------------
;
;; OUT-LINE
L0745:	LD BC,($400A)		; sv E_PPC_lo
	CALL L09EA		; routine CP-LINES
	LD D,$92		;
	JR Z,L0755 		; to TEST-END

	LD DE,$0000		;
	RL E			;

;; TEST-END
L0755:	LD (IY+$1E),E		; sv BERG
	LD A,(HL)		;
	CP $40			;
	POP BC			;
	RET NC			;

	PUSH BC			;
	CALL L0AA5		; routine OUT-NO
	INC HL			;
	LD A,D			;

	RST 10H			; PRINT-A
	INC HL			;
	INC HL			;
;
;; COPY-LINE
L0766:	LD ($4016),HL		; sv CH_ADD_lo
	SET 0,(IY+$01)		; sv FLAGS  - Suppress leading space

;; MORE-LINE
L076D:	LD BC,($4018)		; sv X_PTR_lo
	LD HL,($4016)		; sv CH_ADD_lo
	AND A			;
	SBC HL,BC		;
	JR NZ,L077C		; to TEST-NUM

	LD A,$B8		;

	RST 10H			; PRINT-A

;; TEST-NUM
L077C:	LD HL,($4016)		; sv CH_ADD_lo
	LD A,(HL)		;
	INC HL			;
	CALL L07B4		; routine NUMBER
	LD ($4016),HL		; sv CH_ADD_lo
	JR Z,L076D		; to MORE-LINE

	CP $7F			;
	JR Z,L079D		; to OUT-CURS

	CP $76			;
	JR Z,L07EE		; to OUT-CH

	BIT 6,A			;
	JR Z,L079A		; to NOT-TOKEN

	CALL L094B		; routine TOKENS
	JR L076D		; to MORE-LINE
; ---
;
;; NOT-TOKEN
L079A:	RST 10H			; PRINT-A
	JR L076D		; to MORE-LINE
; ---
;
;; OUT-CURS
L079D:	LD A,($4006)		; Fetch value of system variable MODE
	LD B,$AB		; Prepare an inverse [F] for function cursor.

	AND A			; Test for zero -
	JR NZ,L07AA		; forward if not to FLAGS-2

	LD A,($4001)		; Fetch system variable FLAGS.
	LD B,$B0		; Prepare an inverse [K] for keyword cursor.
;
;; FLAGS-2
L07AA:	RRA			; 00000?00 -> 000000?0
	RRA			; 000000?0 -> 0000000?
	AND $01			; 0000000?    0000000x

	ADD A,B			; Possibly [F] -> [G]  or  [K] -> [L]

	CALL L07F5		; routine PRINT-SP prints character 
	JR L076D		; back to MORE-LINE
;
; -----------------------
; THE 'NUMBER' SUBROUTINE
; -----------------------
;
;; NUMBER
L07B4:	CP $7E			;
	RET NZ			;

	INC HL			;
	INC HL			;
	INC HL			;
	INC HL			;
	INC HL			;
	RET 			;
;
; --------------------------------
; THE 'KEYBOARD DECODE' SUBROUTINE
; --------------------------------
;
;; DECODE
L07BD:	LD D,$00		;
	SRA B			;
	SBC A,A			;
	OR $26			;
	LD L,$05		;
	SUB L			;
;
;; KEY-LINE
L07C7:	ADD A,L			;
	SCF			; Set Carry Flag
	RR C			;
	JR C,L07C7		; to KEY-LINE

	INC C			;
	RET NZ			;

	LD C,B			;
	DEC L			;
	LD L,$01		;
	JR NZ,L07C7		; to KEY-LINE

	LD HL,$007D		; (expr reqd)
	LD E,A			;
	ADD HL,DE		;
	SCF			; Set Carry Flag
	RET 			;
;
; ---------------------------------
; THE patched 'PRINTING' SUBROUTINE
; ---------------------------------
;
;; LEAD-SP
L07DC:	LD A,E			;
	AND A			;
	RET M			;

	JR L07F1		; to PRINT-CH
; ---
;
;; OUT-DIGIT
L07E1:	XOR A			;
;
;; DIGIT-INC
L07E2:	ADD HL,BC		;
	INC A			;
	JR C,L07E2		; to DIGIT-INC

	SBC HL,BC		;
	DEC A			;
	JR Z,L07DC		; to LEAD-SP
;
;; OUT-CODE
L07EB:	LD E,$1C		;
	ADD A,E			;
;
;; OUT-CH
L07EE:	AND A			;
	JR Z,L07F5		; to PRINT-SP
;
;; PRINT-CH
L07F1:	RES 0,(IY+$01)		; update FLAGS - signal leading space permitted
;
;; PRINT-SP
L07F5:	EXX			;
	PUSH HL			;

	call prn_test		;

	pop hl			;
	exx			;
	ret 			;
;
;	==============================================================
;	entry points of the new 'PRINT A FLOATING-POINT NUMBER' subr.
;
prnt_num
	inc a			; offset1 (+1) - code of zero (-27)
prnt_dot
	add a,$1B		; offset2 (+27) - code of '.'

	jr L07F5		; print
;
;	==============================================================
;
prn_test
	bit 1,(iy+$01)		; test FLAGS - is printer in use ?
	jr nz,L0851		; routine LPRINT-CH
; ---
;
;; ENTER-CH
L0808:	LD D,A			;
	LD BC,($4039)		; sv S_POSN_x
	LD A,C			;
	CP $21			;
	JR Z,L082C		; to TEST-LOW
;
;; TEST-N/L
L0812:	LD A,$76		;
	CP D			;
	JR Z,L0847		; to WRITE-N/L

	LD HL,($400E)		; sv DF_CC_lo
	CP (HL)			;
	LD A,D			;
	JR NZ,L083E		; to WRITE-CH

	DEC C			;
	JR NZ,L083A		; to EXPAND-1

	INC HL			;
	LD  ($400E),HL		; sv DF_CC_lo
	LD C,$21		;
	DEC B			;
	LD ($4039),BC		; sv S_POSN_x
;
;; TEST-LOW
L082C:	LD A,B			;
	CP (IY+$22)		; sv DF_SZ
	JR Z,L0835		; to REPORT-5

	AND A			;
	JR NZ,L0812		; to TEST-N/L
;
;; REPORT-5
L0835:	LD L,$04		; 'No more room on screen'
	JP L0058		; to ERROR-3
; ---
;
;; EXPAND-1
L083A:	CALL L099B		; routine ONE-SPACE
	EX DE,HL		;
;
;; WRITE-CH
L083E:	LD (HL),A		;
	INC HL			;
	LD ($400E),HL		; sv DF_CC_lo
	DEC (IY+$39)		; sv S_POSN_x
	RET			;
; ---
;
;; WRITE-N/L
L0847:
	SET 0,(IY+$01)		; sv FLAGS  - Suppress leading space
loc_nxt0
	DEC B			; set line counter
loc_pos0
	LD C,$21		; point the leading N/L character
	JP L0918		; to (quick) LOC-ADDR
;
; --------------------------
; THE 'LPRINT-CH' SUBROUTINE
; --------------------------
; This routine sends a character to the ZX-Printer placing the code for the
; character in the Printer Buffer.
; Note. PR-CC contains the low byte of the buffer address. The high order byte 
; is always constant. 
;
;; LPRINT-CH
L0851:	CP $76			; compare to NEWLINE.
	JR Z,L0871		; forward if so to COPY-BUFF

	LD C,A			; take a copy of the character in C.
	LD A,($4038)		; fetch print location from PR_CC
	AND $7F			; ignore bit 7 to form true position.
	CP $5C			; compare to 33rd location

	LD L,A			; form low-order byte.
	LD H,$40		; the high-order byte is fixed.

	CALL Z,L0871		; routine COPY-BUFF to send full buffer to 
				; the printer if first 32 bytes full.
				; (this will reset HL to start.)

	LD (HL),C		; place character at location.
	INC L			; increment - will not cross a 256 boundary.
	LD (IY+$38),L		; update system variable PR_CC
				; automatically resetting bit 7 to show that
				; the buffer is not empty.
	RET 			; return.
;
; --------------------------
; THE 'COPY' COMMAND ROUTINE
; --------------------------
; The full character-mapped screen is copied to the ZX-Printer.
; All twenty-four text/graphic lines are printed.
;
;; COPY
L0869:	LD D,$16		; prepare to copy twenty four text lines.
	LD HL,($400C)		; set HL to start of display file from D_FILE.
	INC HL			; 
	JR L0876		; forward to COPY*D
; ---
;
; A single character-mapped printer buffer is copied to the ZX-Printer.
;
;; COPY-BUFF
L0871:	LD D,$01		; prepare to copy a single text line.
	LD HL,$403C		; set HL to start of printer buffer PRBUFF.
;
; both paths converge here.
;
;; COPY*D
L0876:	CALL L02E7		; routine SET-FAST

	PUSH BC			; *** preserve BC throughout.
				; a pending character may be present 
				; in C from LPRINT-CH
;
;; COPY-LOOP
L087A:	PUSH HL			; save first character of line pointer. (*)
	XOR A			; clear accumulator.
	LD E,A			; set pixel line count, range 0-7, to zero.
;
; this inner loop deals with each horizontal pixel line.
;
;; COPY-TIME
L087D:	OUT ($FB),A		; bit 2 reset starts the printer motor
				; with an inactive stylus - bit 7 reset.
	POP HL			; pick up first character of line pointer (*)
				; on inner loop.
;
;; COPY-BRK
L0880:	CALL L0F46		; routine BREAK-1
	JR C,L088A		; forward with no keypress to COPY-CONT
;
; else A will hold 11111111 0
;
	RRA			; 0111 1111
	OUT ($FB),A		; stop ZX printer motor, de-activate stylus.
;
;; REPORT-D2
L0888:	RST 08H			; ERROR-1
	DEFB $0C		; Error Report: BREAK - CONT repeats
; ---
;
;; COPY-CONT
L088A:	IN A,($FB)		; read from printer port.
	ADD A,A			; test bit 6 and 7
	JP M,L08DE		; jump forward with no printer to COPY-END

	JR NC,L0880		; back if stylus not in position to COPY-BRK

	PUSH HL			; save first character of line pointer (*)
	PUSH DE			; ** preserve character line and pixel line.

	LD A,D			; text line count to A?
	CP $02			; sets carry if last line.
	SBC A,A			; now $FF if last line else zero.
;
; now cleverly prepare a printer control mask setting bit 2 (later moved to 1)
; of D to slow printer for the last two pixel lines ( E = 6 and 7)
;
	AND E			; and with pixel line offset 0-7
	RLCA			; shift to left.
	AND E			; and again.
	LD D,A			; store control mask in D.
;
;; COPY-NEXT
L089C:	LD C,(HL)		; load character from screen or buffer.
	LD A,C			; save a copy in C for later inverse test.
	INC HL			; update pointer for next time.
	CP $76			; is character a NEWLINE ?
	JR Z,L08C7		; forward, if so, to COPY-N/L

	PUSH HL			; * else preserve the character pointer.

	SLA A			; (?) multiply by two
	ADD A,A			; multiply by four
	ADD A,A			; multiply by eight

	LD H,$0F		; load H with half the address of character set.
	RL H			; now $1E or $1F (with carry)
	ADD A,E			; add byte offset 0-7
	LD L,A			; now HL addresses character source byte

	RL C			; test character, setting carry if inverse.
	SBC A,A			; accumulator now $00 if normal, $FF if inverse.

	XOR (HL)		; combine with bit pattern at end or ROM.
	LD C,A			; transfer the byte to C.
	LD B,$08		; count eight bits to output.
;
;; COPY-BITS
L08B5:	LD A,D			; fetch speed control mask from D.
	RLC C			; rotate a bit from output byte to carry.
	RRA			; pick up in bit 7, speed bit to bit 1
	LD H,A			; store aligned mask in H register.

;; COPY-WAIT
L08BA:	IN A,($FB)		; read the printer port
	RRA			; test for alignment signal from encoder.
	JR NC,L08BA		; loop if not present to COPY-WAIT

	LD A,H			; control byte to A.
	OUT ($FB),A		; and output to printer port.
	DJNZ L08B5		; loop for all eight bits to COPY-BITS

	POP HL			; * restore character pointer.
	JR L089C		; back for adjacent character line to COPY-NEXT
; ---
;
; A NEWLINE has been encountered either following a text line or as the 
; first character of the screen or printer line.
;
;; COPY-N/L
L08C7:	IN A,($FB)		; read printer port.
	RRA			; wait for encoder signal.
	JR NC,L08C7		; loop back if not to COPY-N/L

	LD A,D			; transfer speed mask to A.
	RRCA			; rotate speed bit to bit 1. 
				; bit 7, stylus control is reset.
	OUT ($FB),A		; set the printer speed.

	POP DE			; ** restore character line and pixel line.
	INC E			; increment pixel line 0-7.
	BIT 3,E			; test if value eight reached.
	JR Z,L087D		; back if not to COPY-TIME

; eight pixel lines, a text line have been completed.

	POP BC			; lose the now redundant first character 
				; pointer
	DEC D			; decrease text line count.
	JR NZ,L087A		; back if not zero to COPY-LOOP

	LD A,$04		; stop the already slowed printer motor.
	OUT ($FB),A		; output to printer port.

;; COPY-END
L08DE:	CALL L0207		; routine SLOW/FAST
	POP BC			; *** restore preserved BC.
;
; -------------------------------------
; THE 'CLEAR PRINTER BUFFER' SUBROUTINE
; -------------------------------------
; This subroutine sets 32 bytes of the printer buffer to zero (space) and
; the 33rd character is set to a NEWLINE.
; This occurs after the printer buffer is sent to the printer but in addition
; after the 24 lines of the screen are sent to the printer. 
; Note. This is a logic error as the last operation does not involve the 
; buffer at all. Logically one should be able to use 
; 10 LPRINT "HELLO ";
; 20 COPY
; 30 LPRINT ; "WORLD"
; and expect to see the entire greeting emerge from the printer.
; Surprisingly this logic error was never discovered and although one can argue
; if the above is a bug, the repetition of this error on the Spectrum was most
; definitely a bug.
; Since the printer buffer is fixed at the end of the system variables, and
; the print position is in the range $3C - $5C, then bit 7 of the system
; variable is set to show the buffer is empty and automatically reset when
; the variable is updated with any print position - neat.

;; CLEAR-PRB
L08E2:
	ld a,$3C+$80		; signal the printer buffer is clear (bit 7)
	ld ($4038),a		; update one-byte system variable PR_CC

	ld hl,$405D		; address fixed end of PRBUFF (+1)
;
;	------------------------- the new CLS routine joins here
clr_line
	dec hl			; set pointer
;
;	------------------------- the new SCROLL routine joins here
clr_scrl
	ld b,$20		; prepare to blank 32 preceding characters. 
	xor a			;
	ld (hl),$76		; place a newline at last position.

;; PRB-BYTES
clr_prbf
	dec hl			; decrement address.
	ld (hl),a		; place a zero byte.
	djnz clr_prbf		; loop for all thirty-two to PRB-BYTES

	ret 			; return.
;
; -------------------------
; THE 'PRINT AT' SUBROUTINE
; -------------------------
;
;; PRINT-AT
L08F5:	LD A,$17		; test, if Y>23
	SUB B			;
	JR C,L0905		; yes? -> to WRONG-VAL
;
;; TEST-VAL
L08FA:	CP (IY+$22)		; compare to DF_SZ
	JP C,L0835		; out of screen? -> to REPORT-5

	INC A			; else
	LD B,A			; Y=24-Y
;
;	------------------------- the new PLOT routine joins here
prn_at_x
	LD A,$1F		; test, if X>31
	SUB C			;
;
;; WRONG-VAL
L0905:	JP C,L0EAD		; yes? -> to REPORT-B

	ADD A,$02		; else
	LD C,A			; X=33-X
;
;; SET-FIELD
L090B:	BIT 1,(IY+$01)		; sv FLAGS  - Is printer in use?
	JR Z,L0918		; to LOC-ADDR

	LD A,$5D		;
	SUB C			;
	LD ($4038),A		; save in PR_CC
	RET 			;
;
;	========================================================
;
; ----------------------------------
; THE quick 'LOCATE ADDRESS' ROUTINE
; ----------------------------------
;
;; LOC-ADDR
L0918:	LD ($4039),BC		; sv S_POSN

	ld hl,$1922		; the limits (y: 25, x: 34)
	ld d,c			; save old 'X' value
	and a			; transform the coordinates
	sbc hl,bc		; in to the necessary format
	ld b,h			; Y=25-Y
	ld c,l			; X=34-X

	call loc_xpnd		; if D-File is collapsed, then
				; it returns with address of
				; D-File in HL 

	ld a,(hl)		; HL points the 1st N/L char ($76)
look_fw:
	cp (hl)			; look for the next N/L char ($76)
	INC HL			; set pointer
	JR NZ,look_fw		; to LOOK-FW, if no match

	DJNZ look_fw		; else set line counter (B) and jump
				; back to LOOK-FW if it is nonzero

	CPIR			; look for the next N/L char ($76)
	DEC HL			; HL now points a N/L or addresses
				; the requested coorinates in D-File
	LD ($400E),HL		; save pointer in DF_CC
	SCF			; Set Carry Flag
	RET PO			; return, if not found N/L

	DEC D			; if a N/L was requested (X was 1),
	RET Z			; then return

	PUSH BC			; else save byte counter
	CALL L099E		; routine MAKE-ROOM expands the D-File
	POP BC			; restore byte counter

	LD B,C			; set up B as byte counter
	LD H,D			; save the pointer
	LD L,E			; in HL

	xor a			; the 'SPACE' character
expand2:			;
	ld (de),a		; fill the new
	dec de			; area with 'SPACE'-s
	DJNZ expand2		; to EXPAND-2

	INC HL			; set the new pointer
set_DFCC
	LD ($400E),HL		; save pointer in DF_CC
	RET 
;
;	========================================================
;
; ------------------------------
; THE 'EXPAND TOKENS' SUBROUTINE
; ------------------------------
;
;; TOKENS
L094B:	PUSH AF			;
	CALL L0975		; routine TOKEN-ADD
	JR NC,L0959		; to ALL-CHARS

	BIT 0,(IY+$01)		; sv FLAGS  - Leading space if set
	JR NZ,L0959		; to ALL-CHARS

	XOR A			;

	RST 10H			; PRINT-A
;
;; ALL-CHARS
L0959:	LD A,(BC)		;
	AND $3F			;

	RST 10H			; PRINT-A
	LD A,(BC)		;
	INC BC			;
	ADD A,A			;
	JR NC,L0959		; to ALL-CHARS

	POP BC			;
	BIT 7,B			;
	RET Z			;

	CP $1A			;
	JR Z,L096D		; to TRAIL-SP

	CP $38			;
	RET C			;
;
;; TRAIL-SP
L096D:	XOR A			;
	SET 0,(IY+$01)		; sv FLAGS  - Suppress leading space
	JP L07F5		; to PRINT-SP
; ---
;
;; TOKEN-ADD
L0975:	PUSH HL			;
	LD HL,L0111		; Address of TOKENS
	BIT 7,A			;
	JR Z,L097F		; to TEST-HIGH

	AND $3F			;
;
;; TEST-HIGH
L097F:	CP $43			;
	JR NC,L0993		; to FOUND

	LD B,A			;
	INC B			;
;
;; WORDS
L0985:	BIT 7,(HL)		;
	INC HL			;
	JR Z,L0985		; to WORDS

	DJNZ L0985		; to WORDS

	BIT 6,A			;
	JR NZ,L0992		; to COMP-FLAG

	CP $18			;
;
;; COMP-FLAG
L0992:	CCF			; Complement Carry Flag

;; FOUND
L0993:	LD B,H			;
	LD  C,L			;
	POP HL			; 
	RET NC			;

	LD A,(BC)		;
	ADD A,$E4		;
	RET 			;
;
; --------------------------
; THE 'ONE SPACE' SUBROUTINE
; --------------------------
;
;; ONE-SPACE
L099B:	LD BC,$0001		;

; --------------------------
; THE 'MAKE ROOM' SUBROUTINE
; --------------------------
;
;; MAKE-ROOM
L099E:	PUSH HL			;
	CALL TEST_ROOM		; routine TEST-ROOM
	POP HL			;
	CALL L09AD		; routine POINTERS
	LD HL,($401C)		; sv STKEND
	EX DE,HL		;
	LDDR			; Copy Bytes
	RET 			;
;
; ---------------------------------
; THE patched 'POINTERS' SUBROUTINE
; ---------------------------------
;
;; POINTERS
L09AD:	PUSH AF			;
	PUSH HL			;
	LD HL,$400C		; sv D_FILE_lo
	LD A,$09		;
;
;; NEXT-PTR
L09B4:	LD E,(HL)		; LSB of the sv
	INC HL			; then
	LD D,(HL)		; MSB of the sv

	EX (SP),HL		; 
	AND A			;
	SBC HL,DE		;
	ADD HL,DE		;
	EX (SP),HL		;
	JR NC,L09CA		; to PTR-DONE

	PUSH DE			; save the old value
	EX DE,HL		; 
	ADD HL,BC		; the offset
	EX DE,HL		;
	LD (HL),D		; save the MSB
	DEC HL			; then the
	LD (HL),E		; LSB of the 
	INC HL			; new value
	POP DE			; restore the old value
;
;; PTR-DONE
L09CA:	INC HL			; next sv
	DEC A			; 
	JR NZ,L09B4		; to NEXT-PTR

	EX DE,HL		;
	POP DE			;
	POP AF			;

	call L0A17		; -> DIFFER

	inc bc			;
        ret                     ;
;
;	===============================================
;	in "SLOW" mode the DISPLAY-1 routine joins here
;	if FRAMES is in use by PAUSE
jp_DISP2
	push hl			; restore stack (HL = 0 !!!)
	jp L023E		; back to DISPLAY-2
;
; -----------------------------
; THE 'LINE ADDRESS' SUBROUTINE
; -----------------------------
;
;; LINE-ADDR
L09D8:	PUSH HL			;
	LD HL,$407D		;
	LD D,H			;
	LD E,L			;
;
;; NEXT-TEST
L09DE:	POP BC			;
	CALL L09EA		; routine CP-LINES
	RET NC			;

	PUSH BC			;
	CALL L09F2		; routine NEXT-ONE
	EX DE,HL		;
	JR L09DE		; to NEXT-TEST
;
; -------------------------------------
; THE 'COMPARE LINE NUMBERS' SUBROUTINE
; -------------------------------------
;
;; CP-LINES
L09EA:	LD A,(HL)		;
	CP B			;
	RET NZ			;

	INC HL			;
	LD A,(HL)		;
	DEC HL			;
	CP C			;
	RET 			;
;
; --------------------------------------
; THE 'NEXT LINE OR VARIABLE' SUBROUTINE
; --------------------------------------
;
;; NEXT-ONE
L09F2:	PUSH HL			;
	LD A,(HL)		;
	CP $40			;
	JR C,L0A0F		; to LINES

	BIT 5,A			;
	JR Z,L0A10		; forward to NEXT-O-4

	ADD A,A			;
	JP M,L0A01		; to NEXT+FIVE

	CCF			; Complement Carry Flag
;
;; NEXT+FIVE
L0A01:	LD BC,$0005		;
	JR NC,L0A08		; to NEXT-LETT

	LD C,$11		;
;
;; NEXT-LETT
L0A08:	RLA			;
	INC HL			;
	LD A,(HL)		;
	JR NC,L0A08		; to NEXT-LETT

	JR L0A15		; to NEXT-ADD
; ---
;
;; LINES
L0A0F:	INC HL			;
;
;; NEXT-O-4
L0A10:	INC HL			;
	LD C,(HL)		;
	INC HL			;
	LD B,(HL)		;
	INC HL			;
;
;; NEXT-ADD
L0A15:	ADD HL,BC		;
	POP DE			;
;
; ---------------------------
; THE 'DIFFERENCE' SUBROUTINE
; ---------------------------
;
;; DIFFER
L0A17:	AND A			;
	SBC HL,DE		;
	LD B,H			;
	LD C,L			;
	ADD HL,DE		;
	EX DE,HL		;
	RET 			;
;
; ----------------------------------
; THE patched 'LINE-ENDS' SUBROUTINE
; ----------------------------------
;
;; LINE-ENDS
L0A1F:	LD B,(IY+$22)		; sv DF_SZ
	PUSH BC			;
	CALL L0A2C		; routine B-LINES
	POP BC			;

	jp loc_nxt0		; dec b -> ld c,$21 ==> retun via LOC-ADDR
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
; ------------------------------
; THE 'E-LINE NUMBER' SUBROUTINE
; ------------------------------
;
;; E-LINE-NO
L0A73:	LD HL,($4014)		; sv E_LINE_lo
	CALL L004D		; routine TEMP-PTR-2

	RST 18H			; GET-CHAR
	BIT 5,(IY+$2D)		; sv FLAGX
	RET NZ			;

	LD HL,$405D		; sv MEM-0-1st
	LD ($401C),HL		; sv STKEND_lo
	CALL L1548		; routine INT-TO-FP
	CALL L158A		; routine FP-TO-BC
	JR C,L0A91		; to NO-NUMBER

	LD HL,$D8F0		; value '-10000'
	ADD HL,BC		;
;
;; NO-NUMBER
L0A91:	JP C,L0D9A		; to REPORT-C

	CP A			;
	JP L14BC		; routine SET-MIN
;
; -------------------------------------------------
; THE 'REPORT AND LINE NUMBER' PRINTING SUBROUTINES
; -------------------------------------------------
;
;; OUT-NUM
L0A98:	PUSH DE			;
	PUSH HL			;
	XOR A			;
	BIT 7,B			;
	JR NZ,L0ABF		; to UNITS

	LD H,B			;
	LD L,C			;
	LD E,$FF		;
	JR L0AAD		; to THOUSAND
; ---
;
;; OUT-NO
L0AA5:	PUSH DE			;
	LD D,(HL)		;
	INC HL			;
	LD E,(HL)		;
	PUSH HL			;
	EX DE,HL		;
	LD E,$00		; set E to leading space.
;
;; THOUSAND
L0AAD:	LD BC,$FC18		; BC= -1000
	CALL L07E1		; routine OUT-DIGIT
	LD BC,$FF9C		; BC= -100
	CALL L07E1		; routine OUT-DIGIT
	LD C,$F6		; BC= -10
	CALL L07E1		; routine OUT-DIGIT
	LD A,L			;
;
;; UNITS
L0ABF:	CALL L07EB		; routine OUT-CODE
	POP HL			;
	POP DE			;
	RET 			;
;
; --------------------------
; THE 'UNSTACK-Z' SUBROUTINE
; --------------------------
; This subroutine is used to return early from a routine when checking syntax.
; On the ZX81 the same routines that execute commands also check the syntax
; on line entry. This enables precise placement of the error marker in a line
; that fails syntax.
; The sequence CALL SYNTAX-Z ; RET Z can be replaced by a call to this routine
; although it has not replaced every occurrence of the above two instructions.
; Even on the ZX-80 this routine was not fully utilized.
;
;; UNSTACK-Z
L0AC5:	CALL L0DA6		; routine SYNTAX-Z resets the ZERO flag if
				; checking syntax.
	POP HL			; drop the return address.
	RET Z			; return to previous calling routine if 
				; checking syntax.

	JP (HL)			; else jump to the continuation address in
				; the calling routine as RET would have done.
;
; ----------------------------
; THE 'LPRINT' COMMAND ROUTINE
; ----------------------------
;
;; LPRINT
L0ACB:	SET 1,(IY+$01)		; sv FLAGS  - Signal printer in use
;
; ---------------------------
; THE 'PRINT' COMMAND ROUTINE
; ---------------------------
;
;; PRINT
L0ACF:	LD A,(HL)		;
	CP $76			;
	JP Z,L0B84		; to PRINT-END
;
;; PRINT-1
L0AD5:	SUB $1A			;
	ADC A,$00		;
	JR Z,L0B44		; to SPACING

	CP $A7			;
	JR NZ,L0AFA		; to NOT-AT


	RST 20H			; NEXT-CHAR
	CALL CLASS_06		; routine CLASS-6
	CP $1A			;
	JP NZ,L0D9A		; to REPORT-C


	RST 20H			; NEXT-CHAR
	CALL CLASS_06		; routine CLASS-6
	CALL L0B4E		; routine SYNTAX-ON

	RST 28H		;; FP-CALC
	DEFB $01	;;exchange
	DEFB $34	;;end-calc

	CALL L0BF5		; routine STK-TO-BC
	CALL L08F5		; routine PRINT-AT
	JR L0B37		; to PRINT-ON
; ---
;
;; NOT-AT
L0AFA:	CP $A8			;
	JR NZ,L0B31		; to NOT-TAB


	RST 20H			; NEXT-CHAR
	CALL CLASS_06		; routine CLASS-6
	CALL L0B4E		; routine SYNTAX-ON
	CALL L0C02		; routine STK-TO-A
	JP NZ,L0EAD		; to REPORT-B

	AND $1F			;
	LD C,A			;
	BIT 1,(IY+$01)		; sv FLAGS  - Is printer in use
	JR Z,L0B1E		; to TAB-TEST

	SUB (IY+$38)		; sv PR_CC
	SET 7,A			;
	ADD A,$3C		;
	CALL NC,L0871		; routine COPY-BUFF
;
;; TAB-TEST
L0B1E:	ADD A,(IY+$39)		; sv S_POSN_x
	CP $21			;
	LD A,($403A)		; sv S_POSN_y
	SBC A,$01		;
	CALL L08FA		; routine TEST-VAL
	SET 0,(IY+$01)		; sv FLAGS  - Suppress leading space
	JR L0B37		; to PRINT-ON
; ---
;
;; NOT-TAB
L0B31:	CALL SCANNING		; routine SCANNING
	CALL L0B55		; routine PRINT-STK

;; PRINT-ON
L0B37:	RST 18H			; GET-CHAR
	SUB $1A			;
	ADC A,$00		;
	JR Z,L0B44		; to SPACING

	CALL L0D1D		; routine CHECK-END

	JP L0B84		; to PRINT-END
; ---
;
;; SPACING
L0B44:	CALL NC,L0B8B		; routine FIELD

	RST 20H			; NEXT-CHAR
	CP $76			;
	RET Z			;

	JP L0AD5		; to PRINT-1
; ---
;
;; SYNTAX-ON
L0B4E:	CALL L0DA6		; routine SYNTAX-Z
	RET NZ			;

	POP HL			;
	JR L0B37		; to PRINT-ON
; ---
;
;; PRINT-STK
L0B55:	CALL L0AC5		; routine UNSTACK-Z
	BIT 6,(IY+$01)		; sv FLAGS  - Numeric or string result?
	CALL Z,STK_FETCH	; routine STK-FETCH
	JR Z,L0B6B		; to PR-STR-4

	JP PRINT_FP		; jump forward to PRINT-FP
; ---
;
;; PR-STR-1
L0B64:	LD A,$0B		;
;
;; PR-STR-2
L0B66:	RST 10H			; PRINT-A
;
;; PR-STR-3
L0B67:	LD DE,($4018)		; sv X_PTR_lo
;
;; PR-STR-4
L0B6B:	LD A,B			;
	OR C			;
	DEC BC			;
	RET Z			;

	LD A,(DE)		;
	INC DE			;
	LD ($4018),DE		; sv X_PTR_lo
	BIT 6,A			;
	JR Z,L0B66		; to PR-STR-2

	CP $C0			;
	JR Z,L0B64		; to PR-STR-1

	PUSH BC			;
	CALL L094B		; routine TOKENS
	POP BC			;
	JR L0B67		; to PR-STR-3
; ---
;
;; PRINT-END
L0B84:	CALL L0AC5		; routine UNSTACK-Z
	LD A,$76		;

	RST 10H			; PRINT-A
	RET 			;
; ---
;
;; FIELD
L0B8B:	CALL L0AC5		; routine UNSTACK-Z
	SET 0,(IY+$01)		; sv FLAGS  - Suppress leading space
	XOR A			;

	RST 10H			; PRINT-A
	LD BC,($4039)		; sv S_POSN_x
	LD A,C			;
	BIT 1,(IY+$01)		; sv FLAGS  - Is printer in use
	JR Z,L0BA4		; to CENTRE

	LD A,$5D		;
	SUB (IY+$38)		; sv PR_CC
;
;; CENTRE
L0BA4:	LD C,$11		;
	CP C			;
	JR NC,L0BAB		; to RIGHT

	LD C,$01		;
;
;; RIGHT
L0BAB:
	jp L090B		; return via routine SET-FIELD
; ---
	.db $FF			; spare :D
;
;	========================================================
;
; ------------------------------------------
; THE new 'PLOT AND UNPLOT' COMMAND ROUTINES
; ------------------------------------------
;
;	========================================================
;
;; PLOT/UNP
L0BAF:	CALL L0BF5		; routine STK-TO-BC (B=Y, C=X)
	LD ($4036),BC		; save in sv COORDS

	ld a,$04		; set mosaic lower left
	SRA B			; test odd values of Y
	JR NC,columns		; skip if not (to COLUMNS)

	ld a,$01		; else set mosaic upper left
;
;; COLUMNS
columns
	SRA C			; test odd values of X
	JR NC,fnd_addr		; skip if not (to FIND-ADDR)

	RLCA			; else set mosaic upper/lower right
;
;; FIND-ADDR
fnd_addr
	PUSH AF			; save mosaic value

	ld a,$18		; set limit of the line number (24)
	bit 4,(iy+$3B)		; sv CDFLAG - test plot48 bit
	jr nz,plot_48		; if set, then skip correction

	inc b			; else the origin will be at
	inc b			; the beginning of line 21
plot_48
	inc b			; check the limit value
	cp b			; if it is over,
	jp c,L0EAD		; then jump to REPORT-B
	
	call prn_at_x		; else test x, then return via LOC-ADDR

	LD A,(HL)		; fetch character code from display file
	RLCA			; test if it is a mosaic character
	CP $10			; (0..7)
	JR NC,TABL_PTR		; if not, then jump to TABLE-PTR

	RRCA			; test if it is an inverted mosaic char.
	JR NC,SQ_SAVED		; if not then skip (to SQ-SAVED)

	XOR $8F			; else swap bits
;
;; SQ-SAVED
SQ_SAVED
	LD B,A			; and save in B
;
;; TABLE-PTR
TABL_PTR
	ld a,($4030)		; fetch T_ADDR_lo
	cp $9E			; is P-UNPLOT?
	jr c,to_plot		; if not -> to PLOT

	POP AF			; restore the mosaic
	CPL			; mask out
	AND B			; the necessary bits
	JR to_unplt		; forward to UNPLOT
;
;; PLOT
to_plot
	POP AF			; restore the mosaic
	OR B			; copy the necessary bits
;
;; UNPLOT
to_unplt
	CP $08			; must be inverted?
	jp plot_ext		; continue in the new part
;
;	========================================================
;
; ----------------------------
; THE 'STACK-TO-BC' SUBROUTINE
; ----------------------------
;
;; STK-TO-BC
L0BF5:	CALL L0C02		; routine STK-TO-A
	LD B,A			;
	PUSH BC			;
	CALL L0C02		; routine STK-TO-A
	LD E,C			;
	POP BC			;
	LD D,C			;
	LD C,A			;
	RET 			;
;
; ---------------------------
; THE 'STACK-TO-A' SUBROUTINE
; ---------------------------
;
;; STK-TO-A
L0C02:	CALL FP_TO_A		; routine FP-TO-A
	JP C,L0EAD		; to REPORT-B

	LD C,$01		;
	RET Z			;

	LD C,$FF		;
	RET 			;
;
;	==============================================================
;
; --------------------------------------
; THE new 'SCROLL' SUBROUTINE (27 bytes)
; --------------------------------------
;
;; SCROLL
L0C0E:	LD B,(IY+$22)		; fetch DF_SZ

	ld a,$17		; set A as counter of
	sub b			; the lines to move
	push bc			; save Y position (B)

	ld de,($400C)		; address of the D-File
	ld hl,33		; HL points the end of
	add hl,de		; the 1st line

	bit 5,(IY+$3B)		; test collapsed D-FILE

	call scrl_new		; move lines

	pop bc			; restore the saved position
	inc b			; the last printable line

	jp loc_pos0		; ld c,$21 --> LOC-ADDR
				; set new S_POSN and DF_CC
;
;	==============================================================
;
; -------------------
; THE 'SYNTAX' TABLES
; -------------------
;
; i) The Offset table
;
;; offset-t
L0C29:	DEFB L0CB4 - $	; 8B offset to Address: P-LPRINT
	DEFB L0CB7 - $	; 8D offset to Address: P-LLIST
	DEFB L0C58 - $	; 2D offset to Address: P-STOP
	DEFB L0CAB - $	; 7F offset to Address: P-SLOW
	DEFB L0CAE - $	; 81 offset to Address: P-FAST
	DEFB L0C77 - $	; 49 offset to Address: P-NEW
	DEFB L0CA4 - $	; 75 offset to Address: P-SCROLL
	DEFB L0C8F - $	; 5F offset to Address: P-CONT
	DEFB L0C71 - $	; 40 offset to Address: P-DIM
	DEFB L0C74 - $	; 42 offset to Address: P-REM
	DEFB L0C5E - $	; 2B offset to Address: P-FOR
	DEFB L0C4B - $	; 17 offset to Address: P-GOTO
	DEFB L0C54 - $	; 1F offset to Address: P-GOSUB
	DEFB L0C6D - $	; 37 offset to Address: P-INPUT
	DEFB L0C89 - $	; 52 offset to Address: P-LOAD
	DEFB L0C7D - $	; 45 offset to Address: P-LIST
	DEFB L0C48 - $	; 0F offset to Address: P-LET
	DEFB L0CA7 - $	; 6D offset to Address: P-PAUSE
	DEFB L0C66 - $	; 2B offset to Address: P-NEXT
	DEFB L0C80 - $	; 44 offset to Address: P-POKE
	DEFB L0C6A - $	; 2D offset to Address: P-PRINT
	DEFB L0C98 - $	; 5A offset to Address: P-PLOT
	DEFB L0C7A - $	; 3B offset to Address: P-RUN
	DEFB L0C8C - $	; 4C offset to Address: P-SAVE
	DEFB L0C86 - $	; 45 offset to Address: P-RAND
	DEFB L0C4F - $	; 0D offset to Address: P-IF
	DEFB L0C95 - $	; 52 offset to Address: P-CLS
	DEFB L0C9E - $	; 5A offset to Address: P-UNPLOT
	DEFB L0C92 - $	; 4D offset to Address: P-CLEAR
	DEFB L0C5B - $	; 15 offset to Address: P-RETURN
	DEFB L0CB1 - $	; 6A offset to Address: P-COPY
;
; ii) The parameter table.
;
;; P-LET
L0C48:	DEFB $01	; Class-01 - A variable is required.
	DEFB $14	; Separator:	'='
	DEFB $02	; Class-02 - An expression, numeric or string,
			; must follow.
;
;; P-GOTO
L0C4B:	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $00	; Class-00 - No further operands.
	DEFW L0E81	; Address: $0E81; Address: GOTO
;
;; P-IF
L0C4F:	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $DE	; Separator:	'THEN'
	DEFB $05	; Class-05 - Variable syntax checked entirely
			; by routine.
	DEFW L0DAB	; Address: $0DAB; Address: IF
;
;; P-GOSUB
L0C54:	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $00	; Class-00 - No further operands.
	DEFW L0EB5	; Address: $0EB5; Address: GOSUB
;
;; P-STOP
L0C58:	DEFB $00	; Class-00 - No further operands.
	DEFW L0CDC	; Address: $0CDC; Address: STOP
;
;; P-RETURN
L0C5B:	DEFB $00	; Class-00 - No further operands.
	DEFW L0ED8	; Address: $0ED8; Address: RETURN
;
;; P-FOR
L0C5E:	DEFB $04	; Class-04 - A single character variable must
			; follow.
	DEFB $14	; Separator:	'='
	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $DF	; Separator:	'TO'
	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $05	; Class-05 - Variable syntax checked entirely
			; by routine.
	DEFW L0DB9	; Address: $0DB9; Address: FOR
;
;; P-NEXT
L0C66:	DEFB $04	; Class-04 - A single character variable must
			; follow.
	DEFB $00	; Class-00 - No further operands.
	DEFW L0E2E	; Address: $0E2E; Address: NEXT
;
;; P-PRINT
L0C6A:	DEFB $05	; Class-05 - Variable syntax checked entirely
			; by routine.
	DEFW L0ACF	; Address: $0ACF; Address: PRINT
;
;; P-INPUT
L0C6D:	DEFB $01	; Class-01 - A variable is required.
	DEFB $00	; Class-00 - No further operands.
	DEFW L0EE9	; Address: $0EE9; Address: INPUT
;
;; P-DIM
L0C71:	DEFB $05	; Class-05 - Variable syntax checked entirely
			; by routine.
	DEFW L1409	; Address: $1409; Address: DIM
;
;; P-REM
L0C74:	DEFB $05	; Class-05 - Variable syntax checked entirely
			; by routine.
	DEFW L0D6A	; Address: $0D6A; Address: REM
;
;; P-NEW
L0C77:	DEFB $00	; Class-00 - No further operands.
	DEFW L03C3	; Address: $03C3; Address: NEW
;
;; P-RUN
L0C7A:	DEFB $03	; Class-03 - A numeric expression may follow
			; else default to zero.
	DEFW L0EAF	; Address: $0EAF; Address: RUN
;
;; P-LIST
L0C7D:	DEFB $03	; Class-03 - A numeric expression may follow
			; else default to zero.
	DEFW L0730	; Address: $0730; Address: LIST
;
;; P-POKE
L0C80:	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $1A	; Separator:	','
	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $00	; Class-00 - No further operands.
	DEFW L0E92	; Address: $0E92; Address: POKE
;
;; P-RAND
L0C86:	DEFB $03	; Class-03 - A numeric expression may follow
			; else default to zero.
	DEFW L0E6C	; Address: $0E6C; Address: RAND
;
;; P-LOAD
L0C89:	DEFB $05	; Class-05 - Variable syntax checked entirely
			; by routine.
	DEFW L0340	; Address: $0340; Address: LOAD
;
;; P-SAVE
L0C8C:	DEFB $05	; Class-05 - Variable syntax checked entirely
			; by routine.
	DEFW L02F6	; Address: $02F6; Address: SAVE
;
;; P-CONT
L0C8F:	DEFB $00	; Class-00 - No further operands.
	DEFW L0E7C	; Address: $0E7C; Address: CONT
;
;; P-CLEAR
L0C92:	DEFB $00	; Class-00 - No further operands.
	DEFW L149A	; Address: $149A; Address: CLEAR
;
;; P-CLS
L0C95:	DEFB $00	; Class-00 - No further operands.
	DEFW L0A2A	; Address: $0A2A; Address: CLS
;
;; P-PLOT
L0C98:	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $1A	; Separator:	','
	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $00	; Class-00 - No further operands.
	DEFW L0BAF	; Address: $0BAF; Address: PLOT/UNP
;
;; P-UNPLOT
L0C9E:	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $1A	; Separator:	','
	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $00	; Class-00 - No further operands.
	DEFW L0BAF	; Address: $0BAF; Address: PLOT/UNP
;
;; P-SCROLL
L0CA4:	DEFB $00	; Class-00 - No further operands.
	DEFW L0C0E	; Address: $0C0E; Address: SCROLL
;
;; P-PAUSE
L0CA7:	DEFB $06	; Class-06 - A numeric expression must follow.
	DEFB $00	; Class-00 - No further operands.
	DEFW L0F32	; Address: $0F32; Address: PAUSE
;
;; P-SLOW
L0CAB:	DEFB $00	; Class-00 - No further operands.
	DEFW L0F2B	; Address: $0F2B; Address: SLOW
;
;; P-FAST
L0CAE:	DEFB $00	; Class-00 - No further operands.
	DEFW L0F23	; Address: $0F23; Address: FAST
;
;; P-COPY
L0CB1:	DEFB $00	; Class-00 - No further operands.
	DEFW L0869	; Address: $0869; Address: COPY
;
;; P-LPRINT
L0CB4:	DEFB $05	; Class-05 - Variable syntax checked entirely
			; by routine.
	DEFW L0ACB	; Address: $0ACB; Address: LPRINT
;
;; P-LLIST
L0CB7:	DEFB $03	; Class-03 - A numeric expression may follow
			; else default to zero.
	DEFW L072C	; Address: $072C; Address: LLIST
;
; ---------------------------
; THE 'LINE SCANNING' ROUTINE
; ---------------------------
;
;; LINE-SCAN
L0CBA:	LD (IY+$01),$01		; sv FLAGS
	CALL L0A73		; routine E-LINE-NO

;; LINE-RUN
L0CC1:	CALL L14BC		; routine SET-MIN
	LD HL,$4000		; sv ERR_NR
	LD (HL),$FF		;
	LD HL,$402D		; sv FLAGX
	BIT 5,(HL)		;
	JR Z,L0CDE		; to LINE-NULL

	CP $E3			; 'STOP' ?
	LD A,(HL)		;
	JP NZ,L0D6F		; to INPUT-REP

	CALL L0DA6		; routine SYNTAX-Z
	RET Z			;

	RST 08H			; ERROR-1
	DEFB $0C		; Error Report: BREAK - CONT repeats
;
; --------------------------
; THE 'STOP' COMMAND ROUTINE
; --------------------------
;
;; STOP
L0CDC:	RST 08H			; ERROR-1
	DEFB $08		; Error Report: STOP statement
; ---
;
; the interpretation of a line continues with a check for just spaces
; followed by a carriage return.
; The IF command also branches here with a true value to execute the
; statement after the THEN but the statement can be null so
; 10 IF 1 = 1 THEN
; passes syntax (on all ZX computers).
;
;; LINE-NULL
L0CDE:	RST 18H			; GET-CHAR
	LD B,$00		; prepare to index - early.
	CP $76			; compare to NEWLINE.
	RET Z			; return if so.

	LD C,A			; transfer character to C.

	RST 20H			; NEXT-CHAR advances.
	LD A,C			; character to A
	SUB $E1			; subtract 'LPRINT' - lowest command.
	JR C,L0D26		; forward if less to REPORT-C2

	LD C,A			; reduced token to C
	LD HL,L0C29		; set HL to address of offset table.
	ADD HL,BC		; index into offset table.
	LD C,(HL)		; fetch offset
	ADD HL,BC		; index into parameter table.
	JR L0CF7		; to GET-PARAM
; ---
;
;; SCAN-LOOP
L0CF4:	LD HL,($4030)		; sv T_ADDR_lo
;
; -> Entry Point to Scanning Loop
;
;; GET-PARAM
L0CF7:	LD A,(HL)		;
	INC HL			;
	LD ($4030),HL		; sv T_ADDR_lo

	LD BC,L0CF4		; Address: SCAN-LOOP
	PUSH BC			; is pushed on machine stack.

	LD C,A			;
	CP $0B			;
	JR NC,L0D10		; to SEPARATOR

	LD HL,L0D16		; class-tbl - the address of the class table.
	LD B,$00		;
	ADD HL,BC		;
	LD C,(HL)		;
	ADD HL,BC		;
	PUSH HL			;

	RST 18H			; GET-CHAR
	RET 			; indirect jump to class routine and
				; by subsequent RET to SCAN-LOOP.
;
; -----------------------
; THE 'SEPARATOR' ROUTINE
; -----------------------
;
;; SEPARATOR
L0D10:	RST 18H			; GET-CHAR
	CP C			;
	JR NZ,L0D26		; to REPORT-C2
				; 'Nonsense in BASIC'

	RST 20H			; NEXT-CHAR
	RET 			; return
;
; -------------------------
; THE 'COMMAND CLASS' TABLE
; -------------------------
;
;; class-tbl
L0D16:	DEFB L0D2D - $		; 17 offset to Address: CLASS-0
	DEFB L0D3C - $		; 25 offset to Address: CLASS-1
	DEFB L0D6B - $		; 53 offset to Address: CLASS-2
	DEFB L0D28 - $		; 0F offset to Address: CLASS-3
	DEFB L0D85 - $		; 6B offset to Address: CLASS-4
	DEFB L0D2E - $		; 13 offset to Address: CLASS-5
	DEFB CLASS_06 - $	; 76 offset to Address: CLASS-6
;
; --------------------------
; THE 'CHECK END' SUBROUTINE
; --------------------------
; Check for end of statement and that no spurious characters occur after
; a correctly parsed statement. Since only one statement is allowed on each
; line, the only character that may follow a statement is a NEWLINE.
;
;; CHECK-END
L0D1D:	CALL L0DA6		; routine SYNTAX-Z
	RET NZ			; return in runtime.

	POP BC			; else drop return address.
;
CHECK_2				;(L0D22)
	LD A,(HL)		; fetch character.
	CP $76			; compare to NEWLINE.
	RET Z			; return if so.
;
;; REPORT-C2
L0D26:	JR L0D9A		; to REPORT-C
				; 'Nonsense in BASIC'
;
; --------------------------
; COMMAND CLASSES 03, 00, 05
; --------------------------
;
;; CLASS-3
L0D28:	CP $76			;
	CALL L0D9C		; routine NO-TO-STK
;
;; CLASS-0
L0D2D:	CP A			;
;
;; CLASS-5
L0D2E:	POP BC			;
	CALL Z,L0D1D		; routine CHECK-END
	EX DE,HL		;
	LD HL,($4030)		; sv T_ADDR_lo
	LD C,(HL)		;
	INC HL			;
	LD B,(HL)		;
	EX DE,HL		;
;
;; CLASS-END
L0D3A:	PUSH BC			;
	RET 			;
;
; ------------------------------
; COMMAND CLASSES 01, 02, 04, 06
; ------------------------------
;
;; CLASS-1
L0D3C:	CALL L111C		; routine LOOK-VARS
;
;; CLASS-4-2
L0D3F:	LD (IY+$2D),$00		; sv FLAGX
	JR NC,L0D4D		; to SET-STK

	SET 1,(IY+$2D)		; sv FLAGX
	JR NZ,L0D63		; to SET-STRLN
;
;; REPORT-2
L0D4B:	RST 08H			; ERROR-1
	DEFB $01		; Error Report: Variable not found
; ---
;
;; SET-STK
L0D4D:	CALL Z,L11A7		; routine STK-VAR
	BIT 6,(IY+$01)		; sv FLAGS  - Numeric or string result?
	JR NZ,L0D63		; to SET-STRLN

	XOR A			;
	CALL L0DA6		; routine SYNTAX-Z
	CALL NZ,STK_FETCH		; routine STK-FETCH
	LD HL,$402D		; sv FLAGX
	OR (HL)			;
	LD (HL),A		;
	EX DE,HL		;
;
;; SET-STRLN
L0D63:	LD ($402E),BC		; sv STRLEN_lo
	LD ($4012),HL		; sv DEST-lo
;
; ------------------------------
; THE 'REM' COMMAND ROUTINE
; ------------------------------
;
;; REM
L0D6A:	RET 			;
;
; ---
;
;; CLASS-2
L0D6B:	POP BC			;
	LD A,($4001)		; sv FLAGS
;
;; INPUT-REP
L0D6F:	PUSH AF			;
	CALL SCANNING		; routine SCANNING
	POP AF			;
	LD BC,L1321		; Address: LET
	LD D,(IY+$01)		; sv FLAGS
	XOR D			;
	AND $40			;
	JR NZ,L0D9A		; to REPORT-C

	BIT 7,D			;
	JR NZ,L0D3A		; to CLASS-END

	JR CHECK_2		; to CHECK-2
; ---
;
;; CLASS-4
L0D85:	CALL L111C		; routine LOOK-VARS
	PUSH AF			;
	LD A,C			;
	OR $9F			;
	INC A			;
	JR NZ,L0D9A		; to REPORT-C

	POP AF			;
	JR L0D3F		; to CLASS-4-2
; ---
;
CLASS_06			; (L0D92)
	CALL SCANNING		; routine SCANNING
	BIT 6,(IY+$01)		; sv FLAGS  - Numeric or string result?
	RET NZ			;
;
;; REPORT-C
L0D9A:	RST 08H			; ERROR-1
	DEFB $0B		; Error Report: Nonsense in BASIC
;
; --------------------------------
; THE 'NUMBER TO STACK' SUBROUTINE
; --------------------------------
;
;; NO-TO-STK
L0D9C:	JR NZ,CLASS_06		; back to CLASS-6 with a non-zero number.

	CALL L0DA6		; routine SYNTAX-Z
	RET Z			; return if checking syntax.
;
; in runtime a zero default is placed on the calculator stack.
;
	RST 28H		;; FP-CALC
	DEFB $A0	;;stk-zero
	DEFB $34	;;end-calc

	RET 			; return.
;
; -------------------------
; THE 'SYNTAX-Z' SUBROUTINE
; -------------------------
; This routine returns with zero flag set if checking syntax.
; Calling this routine uses three instruction bytes compared to four if the
; bit test is implemented inline.
;
;; SYNTAX-Z
L0DA6:	BIT 7,(IY+$01)		; test FLAGS  - checking syntax only?
	RET 			; return.
;
; --------------------------------
; THE patched 'IF' COMMAND ROUTINE
; --------------------------------
; In runtime, the class routines have evaluated the test expression and
; the result, true or false, is on the stack.
;
;; IF
L0DAB:
	CALL L0DA6		; routine SYNTAX-Z
	jr z,if_end		; forward if checking syntax to IF-END
;
; else delete the Boolean value on the calculator stack.
;
	call STK_FETCH		; routine STK-FETCH - exponent to A
				; mantissa to EDCB.
	AND A			; test exponent for zero - FALSE.
	RET Z			; return if so.
;
;; IF-END (was L0DB6)
if_end
	JP L0CDE		; jump back to LINE-NULL
; ---
	.db $FF			; spare
;
; ---------------------------------
; THE patched 'FOR' COMMAND ROUTINE
; ---------------------------------
;
;; FOR
L0DB9:	CP $E0			; is current character 'STEP' ?
	JR NZ,L0DC6		; forward if not to F-USE-ONE


	RST 20H			; NEXT-CHAR
	CALL CLASS_06		; routine CLASS-6 stacks the number
	CALL L0D1D		; routine CHECK-END
	JR L0DCC		; forward to F-REORDER
; ---
;
;; F-USE-ONE
L0DC6:	CALL L0D1D		; routine CHECK-END

	RST 28H		;; FP-CALC
	DEFB $A1	;;stk-one
	DEFB $34	;;end-calc
;
;; F-REORDER
L0DCC:	RST 28H		;; FP-CALC	v, l, s.
	DEFB $C0	;;st-mem-0	v, l, s.
	DEFB $02	;;delete	v, l.
	DEFB $01	;;exchange	l, v.
	DEFB $E0	;;get-mem-0	l, v, s.
	DEFB $01	;;exchange	l, s, v.
	DEFB $34	;;end-calc	l, s, v.

	CALL L1321		; routine LET

	LD ($401F),HL		; set MEM to address variable.
	DEC HL			; point to letter.
	LD A,(HL)		;
	SET 7,(HL)		;
	LD BC,$0006		;
	ADD HL,BC		;
	RLCA			;
	JR C,L0DEA		; to F-LMT-STP

	SLA C			;
	CALL L099E		; routine MAKE-ROOM
	INC HL			;
;
;; F-LMT-STP
L0DEA:	PUSH HL			;

	RST 28H		;; FP-CALC
	DEFB $02	;;delete
	DEFB $02	;;delete
	DEFB $34	;;end-calc

	POP HL			;
	EX DE,HL		;

	LD C,$0A		; ten bytes to be moved.
	LDIR			; copy bytes
;
; QCOM1 - patch (Ludwig Röck)
;
	LD HL,($4029)		; set HL to system variable NXTLIN current line.
	EX DE,HL		; transfer to DE, variable pointer to HL.
;
; QCOM1 - patch (Ludwig Röck)
;
	NOP			;

	LD (HL),E		;
	INC HL			;
	LD (HL),D		;
	CALL L0E5A		; routine NEXT-LOOP considers an initial pass.
	RET NC			; return if possible.
;
; else program continues from point following matching NEXT.
;
	BIT 7,(IY+$08)		; test PPC_hi
	RET NZ			; return if over 32767 ???

	LD B,(IY+$2E)		; fetch variable name from STRLEN_lo
	RES 6,B			; make a true letter.
	LD HL,($4029)		; set HL from NXTLIN
;
; now enter a loop to look for matching next.
;
;; NXTLIN-NO
L0E0E:	LD A,(HL)		; fetch high byte of line number.
	AND $C0			; mask off low bits $3F
	JR NZ,L0E2A		; forward at end of program to FOR-END

	PUSH BC			; save letter
	CALL L09F2		; routine NEXT-ONE finds next line.
	POP BC			; restore letter

	INC HL			; step past low byte
	INC HL			; past the
	INC HL			; line length.
	CALL L004C		; routine TEMP-PTR1 sets CH_ADD

	RST 18H			; GET-CHAR
	CP $F3			; compare to 'NEXT'.
	EX DE,HL		; next line to HL.
	JR NZ,L0E0E		; back with no match to NXTLIN-NO

	EX DE,HL		; restore pointer.

	RST 20H			; NEXT-CHAR advances and gets letter in A.
	EX DE,HL		; save pointer
	CP B			; compare to variable name.
	JR NZ,L0E0E		; back with mismatch to NXTLIN-NO
;
;; FOR-END
L0E2A:
	JR L0E8E		; to GOTO-3
; ---
;
;; REPORT-1
L0E2C:
	RST 08H			; ERROR-1
	DEFB $00		; Error Report: NEXT without FOR
;
; ----------------------------------
; THE patched 'NEXT' COMMAND ROUTINE
; ----------------------------------
;
;; NEXT
L0E2E:	BIT 1,(IY+$2D)		; sv FLAGX
	JP NZ,L0D4B		; to REPORT-2

	LD HL,($4012)		; DEST (addr. of loop variable)
	BIT 7,(HL)		;
	jr z,L0E2C		; to REPORT-1

	INC HL			;
	LD ($401F),HL		; set MEM to loop variable value
				; mem0: value, mem1: limit, mem2: step

	ld de,$000A		; offset to 'step'
	ex de,hl		;
	add hl,de		; 
	ex de,hl		; HL points 'value', DE points 'step'
	call addition		; new value = value + step

	CALL L0E5A		; test limit - routine NEXT-LOOP

	RET C			; if it has reached, then return

	LD HL,($401F)		; else fetch MEM (HL points 'value')
	LD DE,$000F		; offset to the starting address of the loop
	ADD HL,DE		; HL now points the starting address
	LD E,(HL)		;
	INC HL			;
	LD D,(HL)		;
	EX DE,HL		; HL now contains the starting address
;
; QCOM1 - patch (Ludwig Röck)
;
	JR L0E8E		; to GOTO-3 (back to the beginning of the loop)
;
; -----------------------------------
; THE improved 'NEXT-LOOP' SUBROUTINE
; -----------------------------------
;
;; NEXT-LOOP
L0E5A:
	RST 28H		;; FP-CALC

	.db $E0		;;get-mem-0		value.
	.db $E1		;;get-mem-1		value, limit.

	DEFB $E2	;;get-mem-2		value, limit, step.

	DEFB $32	;;less-0		value, limit, 0/1.
	DEFB $00	;;jump-true		if 'step'<0
	DEFB L0E62-$	;;to LMT-V-VAL		then a=value, b=limit.

	DEFB $01	;;exchange		else a=limit, b=value.
;
;; LMT-V-VAL
L0E62:
	.db $02		;;delete		a.
	.db $02		;;delete		.
	.db $34		;;end-calc		the calculator stack is empty
	
	ld hl,5			; DE points 'a'
	add hl,de		; HL points 'b'

	jp comp_num		; return: if b>a then CY=1, else CY=0
;
; --------------------------
; THE 'RAND' COMMAND ROUTINE
; --------------------------
; The keyword was 'RANDOMISE' on the ZX80, is 'RAND' here on the ZX81 and
; becomes 'RANDOMIZE' on the ZX Spectrum.
; In all invocations the procedure is the same - to set the SEED system variable
; with a supplied integer value or to use a time-based value if no number, or
; zero, is supplied.
;
;; RAND
L0E6C:	CALL FIND_INT		; routine FIND-INT
	LD A,B			; test value
	OR C			; for zero
	JR NZ,L0E77		; forward if not zero to SET-SEED

	LD BC,($4034)		; fetch value of FRAMES system variable.
;
;; SET-SEED
L0E77:	LD  ($4032),BC		; update the SEED system variable.
	RET 			; return.
;
; --------------------------
; THE 'CONT' COMMAND ROUTINE
; --------------------------
; Another abbreviated command. ROM space was really tight.
; CONTINUE at the line number that was set when break was pressed.
; Sometimes the current line, sometimes the next line.
;
;; CONT
L0E7C:	LD HL,($402B)		; set HL from system variable OLDPPC
	JR L0E86		; forward to GOTO-2
;
; --------------------------
; THE 'GOTO' COMMAND ROUTINE
; --------------------------
; This token also suffered from the shortage of room and there is no space
; getween GO and TO as there is on the ZX80 and ZX Spectrum. The same also 
; applies to the GOSUB keyword.

;; GOTO
L0E81:	CALL FIND_INT		; routine FIND-INT
	LD H,B			;
	LD L,C			;
;
;; GOTO-2
L0E86:	LD A,H			;
	CP $F0			;
	JR NC,L0EAD		; to REPORT-B

	CALL L09D8		; routine LINE-ADDR
;
;; GOTO-3 QCOM1 - patch (Ludwig Röck)
L0E8E:
	LD ($4029),HL		; sv NXTLIN
	RET 			;
;
; ----------------------------------
; THE patched 'POKE' COMMAND ROUTINE
; ----------------------------------
;
;; POKE
L0E92:
	call L0C02		; routine STK-TO-A (with overflow check)

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
;
;	========================================================
;	called by the new 'PAUSE'
ffp_test
	bit 7,(iy+$3B)		; sv CDFLAG - test SLOW mode
	jp ffp_hook		; forward 
;
; -----------------------------
; THE 'FIND INTEGER' SUBROUTINE
; -----------------------------
;
FIND_INT			; (L0EA7)
	CALL L158A		; routine FP-TO-BC
	JR C,L0EAD		; forward with overflow to REPORT-B

	RET Z			; return if positive (0-65535).
;
;; REPORT-B
L0EAD:	RST 08H			; ERROR-1
	DEFB $0A		; Error Report: Integer out of range
;
; -------------------------
; THE 'RUN' COMMAND ROUTINE
; -------------------------
;
;; RUN
L0EAF:	CALL L0E81		; routine GOTO
	JP L149A		; to CLEAR
;
; ---------------------------
; THE 'GOSUB' COMMAND ROUTINE
; ---------------------------
;
;; GOSUB  QCOM1 - patch (Ludwig Röck)
;
L0EB5:
	LD HL,($4029)		; sv NXTLIN_lo
	NOP			;
	EX (SP),HL		;
	PUSH HL			;
	LD ($4002),SP		; set the error stack pointer - ERR_SP
	CALL L0E81		; routine GOTO
	LD BC,$0006		;
;
; --------------------------
; THE 'TEST ROOM' SUBROUTINE
; --------------------------
;
TEST_ROOM			; (L0EC5)
	LD HL,($401C)		; sv STKEND_lo
	ADD HL,BC		;
	JR C,L0ED3		; to REPORT-4

	EX DE,HL		;
	LD HL,$0024		;
	ADD HL,DE		;
	SBC HL,SP		;
	RET C			;
;
;; REPORT-4
L0ED3:	LD L,$03		;
	JP L0058		; to ERROR-3
;
; ----------------------------
; THE 'RETURN' COMMAND ROUTINE
; ----------------------------
;
;; RETURN
L0ED8:	POP HL			;
	EX (SP),HL		;
	LD A,H			;
	CP $3E			;
	JR Z,L0EE5		; to REPORT-7

	LD ($4002),SP		; sv ERR_SP_lo
;
; QCOM1 - patch (Ludwig Röck)
;
	JR L0E8E		; back to GOTO-3
; ---
;; REPORT-7
L0EE5:	EX (SP),HL		;
	PUSH HL			;

	RST 08H			; ERROR-1
	DEFB $06		; Error Report: RETURN without GOSUB
;
; ---------------------------
; THE 'INPUT' COMMAND ROUTINE
; ---------------------------
;
;; INPUT
L0EE9:	BIT 7,(IY+$08)		; sv PPC_hi
	JR NZ,L0F21		; to REPORT-8

	CALL L14A3		; routine X-TEMP
	LD HL,$402D		; sv FLAGX
	SET 5,(HL)		;
	RES 6,(HL)		;
	LD A,($4001)		; sv FLAGS
	AND $40  		;
	LD BC,$0002		;
	JR NZ,L0F05		; to PROMPT

	LD C,$04		;
;
;; PROMPT
L0F05:	OR (HL)			;
	LD (HL),A		; sv FLAGX

	RST 30H			; BC-SPACES
	LD (HL),$76		;
	LD A,C			;
	RRCA			;
	RRCA			;
	JR C,L0F14		; to ENTER-CUR

	LD A,$0B		;
	LD (DE),A		;
	DEC HL			;
	LD (HL),A		;
;
;; ENTER-CUR
L0F14:	DEC HL			;
	LD (HL),$7F		;
	LD HL,($4039)		; sv S_POSN_x
	LD ($4030),HL		; sv T_ADDR_lo
	POP HL			;
	JP L0472		; to LOWER
; ---
;
;; REPORT-8
L0F21:	RST 08H			; ERROR-1
	DEFB $07		; Error Report: End of file
;
; ---------------------------
; THE 'FAST' COMMAND ROUTINE
; ---------------------------
;
;; FAST
L0F23:	CALL L02E7		; routine SET-FAST
	RES 6,(IY+$3B)		; sv CDFLAG
	RET 			; return.
;
; --------------------------
; THE 'SLOW' COMMAND ROUTINE
; --------------------------
;
;; SLOW
L0F2B:	SET 6,(IY+$3B)		; sv CDFLAG
	JP L0207		; to SLOW/FAST
;
; -------------------------------
; THE new 'PAUSE' COMMAND ROUTINE
; -------------------------------
;
;; PAUSE
L0F32:
	CALL FIND_INT		; routine FIND-INT

	call ffp_test		; flicker free PAUSE (in SLOW mode)
wt_frame
	ld a,h			; test if HL is
	or l			; already zero
	jr z,ffp_quit		; done?

	bit 0,(IY+$3B)		; test CDFLAG
	jr z,wt_frame		; back if no keypress
ffp_quit
	ld (iy+$35),$FF		; set FRAMES_hi
				; return via  BREAK/DEBOUNCE
;
; ----------------------
; THE 'BREAK' SUBROUTINE
; ----------------------
;
;; BREAK-1
L0F46:	LD A,$7F		; read port $7FFE - keys B,N,M,.,SPACE.
	IN A,($FE)		;
	RRA			; carry will be set if space not pressed.
;
; -------------------------
; THE 'DEBOUNCE' SUBROUTINE
; -------------------------
;
;; DEBOUNCE
L0F4B:	RES 0,(IY+$3B)		; update system variable CDFLAG
	LD A,$FF		;
	LD ($4027),A		; update system variable DEBOUNCE
	RET 			; return.
;
; -------------------------
; THE 'SCANNING' SUBROUTINE
; -------------------------
; This recursive routine is where the ZX81 gets its power. Provided there is
; enough memory it can evaluate an expression of unlimited complexity.
; Note. there is no unary plus so, as on the ZX80, PRINT +1 gives a syntax error.
; PRINT +1 works on the Spectrum but so too does PRINT + "STRING".
;
SCANNING			; (L0F55)
	RST 18H			; GET-CHAR
	LD B,$00		; set B register to zero.
	PUSH BC			; stack zero as a priority end-marker.
;
;; S-LOOP-1
L0F59:	CP $40			; compare to the 'RND' character
	JR NZ,L0F8C		; forward, if not, to S-TEST-PI
;
; ---------------------------
; THE improved 'RND' FUNCTION
; ---------------------------
;
	CALL L0DA6		; routine SYNTAX-Z
	jr z,L0F99		; forward if checking syntax to S-PI-END

	LD BC,($4032)		; sv SEED_lo
	CALL STACK_BC		; routine STACK-BC

	RST 28H		 ;; FP-CALC
	DEFB $A1	 ;;stk-one
	DEFB $0F	 ;;addition
	DEFB $30	 ;;stk-data
	DEFB $37	 ;;Exponent: $87, Bytes: 1
	DEFB $16	 ;;(+00,+00,+00)
	DEFB $04	 ;;multiply
	DEFB $30	 ;;stk-data
	DEFB $80	 ;;Bytes: 3
	DEFB $41	 ;;Exponent $91
	DEFB $00,$00,$80 ;;(+00)
	DEFB $2E	 ;;n-mod-m
	DEFB $02	 ;;delete

	.db $39		 ;;sub-one macro

	DEFB $2D	 ;;duplicate
	DEFB $34	 ;;end-calc

	CALL L158A		; routine FP-TO-BC
	LD ($4032),BC		; update the SEED system variable.
	LD A,(HL)		; HL addresses the exponent of the last value.
	AND A			; test for zero
	jr z,L0F99		; forward, if so, to S-PI-END

	SUB $10			; else reduce exponent by sixteen
	LD (HL),A		; thus dividing by 65536 for last value.

	JR L0F99		; forward to S-PI-END
; ---
	.db $FF			; spare
; ---
;
;; S-TEST-PI
L0F8C:	CP $42			; the 'PI' character
	JR NZ,L0F9D		; forward, if not, to S-TST-INK
;
; -------------------
; THE 'PI' EVALUATION
; -------------------
;
	CALL L0DA6		; routine SYNTAX-Z
	JR Z,L0F99		; forward if checking syntax to S-PI-END

	RST 28H		;; FP-CALC
	DEFB $A3	;;stk-pi/2
	DEFB $34	;;end-calc

	INC (HL)		; double the exponent giving PI on the stack.

;; S-PI-END
L0F99:	RST 20H			; NEXT-CHAR advances character pointer.

	JP L1083		; jump forward to S-NUMERIC to set the flag
				; to signal numeric result before advancing.
; ---
;
;; S-TST-INK
L0F9D:	CP $41			; compare to character 'INKEY$'
	JR NZ,L0FB2		; forward, if not, to S-ALPHANUM
;
; -----------------------
; THE 'INKEY$' EVALUATION
; -----------------------
;
	CALL L02BB		; routine KEYBOARD
	LD B,H			;
	LD C,L			;
	LD D,C			;
	INC D			;
	CALL NZ,L07BD		; routine DECODE
	LD A,D			;
	ADC A,D			;
	LD B,D			;
	LD C,A			;
	EX DE,HL		;
	JR L0FED		; forward to S-STRING
; ---
;
;; S-ALPHANUM
L0FB2:	CALL L14D2		; routine ALPHANUM
	JR C,L1025		; forward, if alphanumeric to S-LTR-DGT

	CP $1B			; is character a '.' ?
	JP Z,L1047		; jump forward if so to S-DECIMAL

	LD BC,$09D8		; prepare priority 09, operation 'subtract'
	CP $16			; is character unary minus '-' ?
	JR Z,L1020		; forward, if so, to S-PUSH-PO

	CP $10			; is character a '(' ?
	JR NZ,L0FD6		; forward if not to S-QUOTE

	CALL L0049		; routine CH-ADD+1 advances character pointer.

	CALL SCANNING		; recursively call routine SCANNING to
				; evaluate the sub-expression.

	CP $11			; is subsequent character a ')' ?
	JR NZ,L0FFF		; forward if not to S-RPT-C


	CALL L0049		; routine CH-ADD+1  advances.
	JR L0FF8		; relative jump to S-JP-CONT3 and then S-CONT3
; ---
;
; consider a quoted string e.g. PRINT "Hooray!"
; Note. quotes are not allowed within a string.
;
;; S-QUOTE
L0FD6:	CP $0B			; is character a quote (") ?
	JR NZ,L1002		; forward, if not, to S-FUNCTION

	CALL L0049		; routine CH-ADD+1 advances
	PUSH HL			; * save start of string.
	JR L0FE3		; forward to S-QUOTE-S
; ---
;
;; S-Q-AGAIN
L0FE0:	CALL L0049		; routine CH-ADD+1
;
;; S-QUOTE-S
L0FE3:	CP $0B			; is character a '"' ?
	JR NZ,L0FFB		; forward if not to S-Q-NL

	POP DE			; * retrieve start of string
	AND A			; prepare to subtract.
	SBC HL,DE		; subtract start from current position.
	LD B,H			; transfer this length
	LD C,L			; to the BC register pair.
;
;; S-STRING
L0FED:	LD HL,$4001		; address system variable FLAGS
	RES 6,(HL)		; signal string result
	BIT 7,(HL)		; test if checking syntax.

	CALL NZ,STK_ST_s	; in run-time routine STK-STO-$ stacks the
				; string descriptor - start DE, length BC.

	RST 20H			; NEXT-CHAR advances pointer.
;
;; S-J-CONT-3
L0FF8:	JP L1088		; jump to S-CONT-3
;
; A string with no terminating quote has to be considered.
;
;; S-Q-NL
L0FFB:	CP $76			; compare to NEWLINE
	JR NZ,L0FE0		; loop back if not to S-Q-AGAIN
;
;; S-RPT-C
L0FFF:	JP L0D9A		; to REPORT-C
;
; ---
;
;; S-FUNCTION
L1002:	SUB $C4			; subtract 'CODE' reducing codes
				; CODE thru '<>' to range $00 - $XX
	JR C,L0FFF		; back, if less, to S-RPT-C
;
; test for NOT the last function in character set.
;
	LD BC,$04EC		; prepare priority $04, operation 'not'
	CP $13			; compare to 'NOT'  ( - CODE)
	JR Z,L1020		; forward, if so, to S-PUSH-PO

	JR NC,L0FFF		; back with anything higher to S-RPT-C
;
; else is a function 'CODE' thru 'CHR$'
;
	LD B,$10		; priority sixteen binds all functions to
				; arguments removing the need for brackets.

	ADD A,$D9		; add $D9 to give range $D9 thru $EB
				; bit 6 is set to show numeric argument.
				; bit 7 is set to show numeric result.
;
; now adjust these default argument/result indicators.
;
	LD C,A			; save code in C

	CP $DC			; separate 'CODE', 'VAL', 'LEN'
	JR NC,L101A		; skip forward if string operand to S-NO-TO-$

	RES 6,C			; signal string operand.
;
;; S-NO-TO-$
L101A:	CP $EA			; isolate top of range 'STR$' and 'CHR$'
	JR C,L1020		; skip forward with others to S-PUSH-PO

	RES 7,C			; signal string result.
;
;; S-PUSH-PO
L1020:	PUSH BC			; push the priority/operation

	RST 20H			; NEXT-CHAR
	JP L0F59		; jump back to S-LOOP-1
; ---
;
;; S-LTR-DGT
L1025:	CP $26			; compare to 'A'.
	JR C,L1047		; forward if less to S-DECIMAL

	CALL L111C		; routine LOOK-VARS
	JP C,L0D4B		; back if not found to REPORT-2
				; a variable is always 'found' when checking
				; syntax.

	CALL Z,L11A7		; routine STK-VAR stacks string parameters or
				; returns cell location if numeric.

	LD A,($4001)		; fetch FLAGS
	CP $C0			; compare to numeric result/numeric operand
	JR C,L1087		; forward if not numeric to S-CONT-2

	INC HL			; address numeric contents of variable.
	LD DE,($401C)		; set destination to STKEND
	CALL COPY_FP		; routine COPY-FP stacks the five bytes
	EX DE,HL		; transfer new free location from DE to HL.
	LD ($401C),HL		; update STKEND system variable.
	JR L1087		; forward to S-CONT-2
; ---
;
; The Scanning Decimal routine is invoked when a decimal point or digit is
; found in the expression.
; When checking syntax, then the 'hidden floating point' form is placed
; after the number in the BASIC line.
; In run-time, the digits are skipped and the floating point number is picked
; up.
;
;; S-DECIMAL
L1047:	CALL L0DA6		; routine SYNTAX-Z
	JR NZ,L106F		; forward in run-time to S-STK-DEC

	CALL L14D9		; routine DEC-TO-FP

	RST 18H			; GET-CHAR advances HL past digits
	LD BC,$0006		; six locations are required.
	CALL L099E		; routine MAKE-ROOM
	INC HL			; point to first new location
	LD (HL),$7E		; insert the number marker 126 decimal.
	INC HL			; increment
	EX DE,HL		; transfer destination to DE.
	LD HL,($401C)		; set HL from STKEND which points to the
				; first location after the 'last value'
	LD C,$05		; five bytes to move.
	AND A			; clear carry.
	SBC HL,BC		; subtract five pointing to 'last value'.
	LD ($401C),HL		; update STKEND thereby 'deleting the value.

	LDIR			; copy the five value bytes.

	EX DE,HL		; basic pointer to HL which may be white-space
				; following the number.
	DEC HL			; now points to last of five bytes.
	CALL L004C		; routine TEMP-PTR1 advances the character
				; address skipping any white-space.
	JR L1083		; forward to S-NUMERIC
				; to signal a numeric result.
; ---
;
; In run-time the branch is here when a digit or point is encountered.
;
;; S-STK-DEC
L106F:	RST 20H			; NEXT-CHAR
	CP $7E			; compare to 'number marker'
	JR NZ,L106F		; loop back until found to S-STK-DEC
				; skipping all the digits.

	INC HL			; point to first of five hidden bytes.
	LD DE,($401C)		; set destination from STKEND system variable
	CALL COPY_FP		; routine COPY-FP stacks the number.
	LD ($401C),DE		; update system variable STKEND.
	LD ($4016),HL		; update system variable CH_ADD.
;
;; S-NUMERIC
L1083:	SET 6,(IY+$01)		; update FLAGS  - Signal numeric result
;
;; S-CONT-2
L1087:	RST 18H			; GET-CHAR
;
;; S-CONT-3
L1088:	CP $10			; compare to opening bracket '('
	JR NZ,L1098		; forward if not to S-OPERTR

	BIT 6,(IY+$01)		; test FLAGS  - Numeric or string result?
	JR NZ,L10BC		; forward if numeric to S-LOOP
;
; else is a string
;
	CALL L1263		; routine SLICING

	RST 20H			; NEXT-CHAR
	JR L1088		; back to S-CONT-3
; ---
;
; the character is now manipulated to form an equivalent in the table of
; calculator literals. This is quite cumbersome and in the ZX Spectrum a
; simple look-up table was introduced at this point.
;
;; S-OPERTR
L1098:	LD BC,$00C3		; prepare operator 'subtract' as default.
				; also set B to zero for later indexing.

	CP $12			; is character '>' ?
	JR C,L10BC		; forward if less to S-LOOP as
				; we have reached end of meaningful expression

	SUB $16			; is character '-' ?
	JR NC,L10A7		; forward with - * / and '**' '<>' to SUBMLTDIV

	ADD A,$0D		; increase others by thirteen
				; $09 '>' thru $0C '+'
	JR L10B5		; forward to GET-PRIO
; ---
;
;; SUBMLTDIV
L10A7:	CP $03			; isolate $00 '-', $01 '*', $02 '/'
	JR C,L10B5		; forward if so to GET-PRIO
;
; else possibly originally $D8 '**' thru $DD '<>' already reduced by $16
;
	SUB $C2			; giving range $00 to $05
	JR C,L10BC		; forward if less to S-LOOP

	CP $06			; test the upper limit for nonsense also
	JR NC,L10BC		; forward if so to S-LOOP

	ADD A,$03		; increase by 3 to give combined operators of

				; $00 '-'
				; $01 '*'
				; $02 '/'

				; $03 '**'
				; $04 'OR'
				; $05 'AND'
				; $06 '<='
				; $07 '>='
				; $08 '<>'

				; $09 '>'
				; $0A '<'
				; $0B '='
				; $0C '+'
;
;; GET-PRIO
L10B5:	ADD A,C			; add to default operation 'sub' ($C3)
	LD C,A			; and place in operator byte - C.

	LD HL,L110F - $C3	; theoretical base of the priorities table.
	ADD HL,BC		; add C ( B is zero)
	LD B,(HL)		; pick up the priority in B
;
;; S-LOOP
L10BC:	POP DE			; restore previous
	LD A,D			; load A with priority.
	CP B			; is present priority higher
	JR C,L10ED		; forward if so to S-TIGHTER

	AND A			; are both priorities zero
	JP Z,L0018		; exit if zero via GET-CHAR

	PUSH BC			; stack present values
	PUSH DE			; stack last values
	CALL L0DA6		; routine SYNTAX-Z
	JR Z,L10D5		; forward is checking syntax to S-SYNTEST

	LD A,E			; fetch last operation
	AND $3F			; mask off the indicator bits to give true
				; calculator literal.
	LD B,A			; place in the B register for BREG
;
; perform the single operation
;
	RST 28H		;; FP-CALC
	DEFB $37	;;fp-calc-2
	DEFB $34	;;end-calc

	JR L10DE		; forward to S-RUNTEST
; ---
;
;; S-SYNTEST
L10D5:	LD A,E			; transfer masked operator to A
	XOR (IY+$01)		; XOR with FLAGS like results will reset bit 6
	AND $40			; test bit 6
;
;; S-RPORT-C
L10DB:	JP NZ,L0D9A		; back to REPORT-C if results do not agree.
;
; in run-time impose bit 7 of the operator onto bit 6 of the FLAGS
;
;; S-RUNTEST
L10DE:	POP DE			; restore last operation.
	LD HL,$4001		; address system variable FLAGS
	SET 6,(HL)		; presume a numeric result
	BIT 7,E			; test expected result in operation
	JR NZ,L10EA		; forward if numeric to S-LOOPEND

	RES 6,(HL)		; reset to signal string result
;
;; S-LOOPEND
L10EA:	POP BC			; restore present values
	JR L10BC		; back to S-LOOP
;
; ---
;
;; S-TIGHTER
L10ED:	PUSH DE	; push last values and consider these

	LD A,C			; get the present operator.
	BIT 6,(IY+$01)		; test FLAGS  - Numeric or string result?
	JR NZ,L110A		; forward if numeric to S-NEXT

	AND $3F			; strip indicator bits to give clear literal.
	ADD A,$08		; add eight - augmenting numeric to equivalent
				; string literals.
	LD C,A			; place plain literal back in C.
	CP $10			; compare to 'AND'
	JR NZ,L1102		; forward if not to S-NOT-AND

	SET 6,C			; set the numeric operand required for 'AND'
	JR L110A		; forward to S-NEXT
; ---
;
;; S-NOT-AND
L1102:	JR C,L10DB		; back if less than 'AND' to S-RPORT-C
				; Nonsense if '-', '*' etc.

	CP $17			; compare to 'strs-add' literal
	JR Z,L110A		; forward if so signaling string result

	SET 7,C			; set bit to numeric (Boolean) for others.
;
;; S-NEXT
L110A:	PUSH BC			; stack 'present' values

	RST 20H			; NEXT-CHAR
	JP L0F59		; jump back to S-LOOP-1
;
; -------------------------
; THE 'TABLE OF PRIORITIES'
; -------------------------
;
;; tbl-pri
L110F:	DEFB $06  ;  '-'
	DEFB $08  ;  '*'
	DEFB $08  ;  '/'
	DEFB $0A  ;  '**'
	DEFB $02  ;  'OR'
	DEFB $03  ;  'AND'
	DEFB $05  ;  '<='
	DEFB $05  ;  '>='
	DEFB $05  ;  '<>'
	DEFB $05  ;  '>'
	DEFB $05  ;  '<'
	DEFB $05  ;  '='
	DEFB $06  ;  '+'
;
; --------------------------
; THE 'LOOK-VARS' SUBROUTINE
; --------------------------
;
;; LOOK-VARS
L111C:	SET 6,(IY+$01)		; sv FLAGS  - Signal numeric result

	RST 18H			; GET-CHAR
	CALL L14CE		; routine ALPHA
	JP NC,L0D9A		; to REPORT-C

	PUSH HL			;
	LD C,A			;

	RST 20H			; NEXT-CHAR
	PUSH HL			;
	RES 5,C			;
	CP $10  ;
	JR Z,L1148		; to V-SYN/RUN

	SET 6,C			;
	CP $0D			;
	JR Z,L1143		; forward to V-STR-VAR

	SET 5,C			;
;
;; V-CHAR
L1139:	CALL L14D2		; routine ALPHANUM
	JR NC,L1148		; forward when not to V-RUN/SYN

	RES 6,C			;

	RST 20H			; NEXT-CHAR
	JR L1139		; loop back to V-CHAR
; ---
;
;; V-STR-VAR
L1143:	RST 20H			; NEXT-CHAR
	RES 6,(IY+$01)		; sv FLAGS  - Signal string result
;
;; V-RUN/SYN
L1148:	LD B,C			;
	CALL L0DA6		; routine SYNTAX-Z
	JR NZ,L1156		; forward to V-RUN

	LD A,C			;
	AND $E0			;
	SET 7,A			;
	LD C,A			;
	JR L118A		; forward to V-SYNTAX
; ---
;
;; V-RUN
L1156:	LD HL,($4010)		; sv VARS
;
;; V-EACH
L1159:	LD A,(HL)		;
	AND $7F			;
	JR Z,L1188		; to V-80-BYTE

	CP C			;
	JR NZ,L1180		; to V-NEXT

	RLA			;
	ADD A,A			;
	JP P,L1195		; to V-FOUND-2

	JR C,L1195		; to V-FOUND-2

	POP DE			;
	PUSH DE			;
	PUSH HL			;
;
;; V-MATCHES
L116B:	INC HL			;
;
;; V-SPACES
L116C:	LD A,(DE)		;
	INC DE			;
	AND A			;
	JR Z,L116C		; back to V-SPACES

	CP (HL)			;
	JR Z,L116B		; back to V-MATCHES

	OR $80			;
	CP (HL)			;
	JR  NZ,L117F		; forward to V-GET-PTR

	LD A,(DE)		;
	CALL L14D2		; routine ALPHANUM
	JR NC,L1194		; forward to V-FOUND-1
;
;; V-GET-PTR
L117F:	POP HL			;
;
;; V-NEXT
L1180:	PUSH BC			;
	CALL L09F2		; routine NEXT-ONE
	EX DE,HL		;
	POP BC			;
	JR L1159		; back to V-EACH
; ---
;
;; V-80-BYTE
L1188:	SET 7,B			;
;
;; V-SYNTAX
L118A:	POP DE			;

	RST 18H			; GET-CHAR
	CP $10			;
	JR Z,L1199		; forward to V-PASS

	SET 5,B			;
	JR L11A1		; forward to V-END
; ---
;
;; V-FOUND-1
L1194:	POP DE			;
;
;; V-FOUND-2
L1195:	POP DE			;
	POP DE			;
	PUSH HL			;

	RST 18H			; GET-CHAR

;; V-PASS
L1199:	CALL L14D2		; routine ALPHANUM
	JR NC,L11A1		; forward if not alphanumeric to V-END


	RST 20H			; NEXT-CHAR
	JR L1199		; back to V-PASS
; ---
;
;; V-END
L11A1:	POP HL			;
	RL B			;
	BIT 6,B			;
	RET 			;
;
; ------------------------
; THE 'STK-VAR' SUBROUTINE
; ------------------------
;
;; STK-VAR
L11A7:	XOR A			;
	LD B,A			;
	BIT 7,C			;
	JR NZ,L11F8		; forward to SV-COUNT

	BIT 7,(HL)		;
	JR NZ,L11BF		; forward to SV-ARRAYS

	INC A			;

;; SV-SIMPLE$
L11B2:	INC HL			;
	LD C,(HL)		;
	INC HL			;
	LD B,(HL)		;
	INC HL			;
	EX DE,HL		;
	CALL STK_ST_s		; routine STK-STO-$

	RST 18H			; GET-CHAR
	JP L125A		; jump forward to SV-SLICE?
; ---
;
;; SV-ARRAYS
L11BF:	INC HL			;
	INC HL			;
	INC HL			;
	LD B,(HL)		;
	BIT 6,C			;
	JR Z,L11D1		; forward to SV-PTR

	DEC B			;
	JR Z,L11B2		; forward to SV-SIMPLE$

	EX DE,HL		;

	RST 18H			; GET-CHAR
	CP $10			;
	JR NZ,L1231		; forward to REPORT-3

	EX DE,HL		;

;; SV-PTR
L11D1:	EX DE,HL		;
	JR L11F8		; forward to SV-COUNT
; ---
;
;; SV-COMMA
L11D4:	PUSH HL			;

	RST 18H			; GET-CHAR
	POP HL			;
	CP $1A			;
	JR Z,L11FB		; forward to SV-LOOP

	BIT 7,C			;
	JR Z,L1231		; forward to REPORT-3

	BIT 6,C			;
	JR NZ,L11E9		; forward to SV-CLOSE

	CP $11			;
	JR NZ,L1223		; forward to SV-RPT-C

	RST 20H			; NEXT-CHAR
	RET 			;
; ---
;
;; SV-CLOSE
L11E9:	CP $11			;
	JR Z,L1259		; forward to SV-DIM

	CP $DF			;
	JR NZ,L1223		; forward to SV-RPT-C
;
;; SV-CH-ADD
L11F1:	RST 18H			; GET-CHAR
	DEC HL			;
	LD ($4016),HL		; sv CH_ADD
	JR L1256		; forward to SV-SLICE
; ---
;
;; SV-COUNT
L11F8:	LD HL,$0000		;
;
;; SV-LOOP
L11FB:	PUSH HL			;

	RST 20H			; NEXT-CHAR
	POP HL			;
	LD A,C			;
	CP $C0			;
	JR NZ,L120C		; forward to SV-MULT

	RST 18H			; GET-CHAR
	CP $11			;
	JR Z,L1259		; forward to SV-DIM

	CP $DF			;
	JR Z,L11F1		; back to SV-CH-ADD
;
;; SV-MULT
L120C:	PUSH BC			;
	PUSH HL			;
	CALL L12FF		; routine DE,(DE+1)
	EX (SP),HL		;
	EX DE,HL		;
	CALL L12DD		; routine INT-EXP1
	JR C,L1231		; forward to REPORT-3

	DEC BC			;
	CALL L1305		; routine GET-HL*DE
	ADD HL,BC		;
	POP DE			;
	POP BC			;
	DJNZ L11D4		; loop back to SV-COMMA

	BIT 7,C			;
;
;; SV-RPT-C
L1223:	JR NZ,L128B		; relative jump to SL-RPT-C

	PUSH HL			;
	BIT 6,C			;
	JR NZ,L123D		; forward to SV-ELEM$

	LD B,D			;
	LD C,E			;

	RST 18H			; GET-CHAR
	CP $11			; is character a ')' ?
	JR Z,L1233		; skip forward to SV-NUMBER
;
;; REPORT-3
L1231:	RST 08H			; ERROR-1
	DEFB $02		; Error Report: Subscript wrong
;
;; SV-NUMBER
L1233:	RST 20H			; NEXT-CHAR
	POP HL			;
	LD DE,$0005		;
	CALL L1305		; routine GET-HL*DE
	ADD HL,BC		;
	RET 			; return			  >>
; ---
;
;; SV-ELEM$
L123D:	CALL L12FF		; routine DE,(DE+1)
	EX (SP),HL		;
	CALL L1305		; routine GET-HL*DE
	POP BC			;
	ADD HL,BC		;
	INC HL			;
	LD B,D			;
	LD C,E			;
	EX DE,HL		;
	CALL L12C2		; routine STK-ST-0

	RST 18H			; GET-CHAR
	CP $11			; is it ')' ?
	JR Z,L1259		; forward if so to SV-DIM

	CP $1A			; is it ',' ?
	JR NZ,L1231		; back if not to REPORT-3
;
;; SV-SLICE
L1256:	CALL L1263		; routine SLICING
;
;; SV-DIM
L1259:	RST 20H			; NEXT-CHAR
;
;; SV-SLICE?
L125A:	CP $10			;
	JR Z,L1256		; back to SV-SLICE

	RES 6,(IY+$01)		; sv FLAGS  - Signal string result
	RET 			; return.
;
; ------------------------
; THE 'SLICING' SUBROUTINE
; ------------------------
;
;; SLICING
L1263:	CALL L0DA6		; routine SYNTAX-Z
	CALL NZ,STK_FETCH	; routine STK-FETCH

	RST 20H			; NEXT-CHAR
	CP $11			; is it ')' ?
	JR Z,L12BE		; forward if so to SL-STORE

	PUSH DE			;
	XOR A			;
	PUSH AF			;
	PUSH BC			;
	LD DE,$0001		;

	RST 18H			; GET-CHAR
	POP HL			;
	CP $DF			; is it 'TO' ?
	JR Z,L1292		; forward if so to SL-SECOND

	POP AF			;
	CALL L12DE		; routine INT-EXP2
	PUSH AF			;
	LD D,B			;
	LD E,C			;
	PUSH HL			;

	RST 18H			; GET-CHAR
	POP HL			;
	CP $DF			; is it 'TO' ?
	JR Z,L1292		; forward if so to SL-SECOND

	CP $11			;
;
;; SL-RPT-C
L128B:	JP NZ,L0D9A		; to REPORT-C

	LD H,D			;
	LD L,E			;
	JR L12A5		; forward to SL-DEFINE
; ---
;
;; SL-SECOND
L1292:	PUSH HL			;

	RST 20H			; NEXT-CHAR
	POP HL			;
	CP $11			; is it ')' ?
	JR Z,L12A5		; forward if so to SL-DEFINE

	POP AF			;
	CALL L12DE		; routine INT-EXP2
	PUSH AF			;

	RST 18H			; GET-CHAR
	LD H,B			;
	LD L,C			;
	CP $11			; is it ')' ?
	JR NZ,L128B		; back if not to SL-RPT-C
;
;; SL-DEFINE
L12A5:	POP AF			;
	EX (SP),HL		;
	ADD HL,DE		;
	DEC HL			;
	EX (SP),HL		;
	AND A			;
	SBC HL,DE		;
	LD BC,$0000		;
	JR C,L12B9		; forward to SL-OVER

	INC HL			;
	AND A			;
	JP M,L1231		; jump back to REPORT-3

	LD B,H			;
	LD C,L			;
;
;; SL-OVER
L12B9:	POP DE			;
	RES 6,(IY+$01)		; sv FLAGS  - Signal string result
;
;; SL-STORE
L12BE:	CALL L0DA6		; routine SYNTAX-Z
	RET Z			; return if checking syntax.
;
; --------------------------
; THE 'STK-STORE' SUBROUTINE
; --------------------------
;
;; STK-ST-0
L12C2:	XOR A			;
;
STK_ST_s			; (L12C3)
	PUSH BC			;
	CALL TEST_5_SP		; routine TEST-5-SP
	POP BC			;
	LD HL,($401C)		; sv STKEND
	LD (HL),A		;
	INC HL			;
	LD (HL),E		;
	INC HL			;
	LD (HL),D		;
	INC HL			;
	LD (HL),C		;
	INC HL			;
	LD (HL),B		;
	INC HL			;
	LD ($401C),HL		; sv STKEND
	RES 6,(IY+$01)		; update FLAGS - signal string result
	RET 			; return.
;
; -------------------------
; THE 'INT EXP' SUBROUTINES
; -------------------------
;
;; INT-EXP1
L12DD:	XOR A			;
;
;; INT-EXP2
L12DE:	PUSH DE			;
	PUSH HL			;
	PUSH AF			;
	CALL CLASS_06		; routine CLASS-6
	POP AF			;
	CALL L0DA6		; routine SYNTAX-Z
	JR Z,L12FC		; forward if checking syntax to I-RESTORE

	PUSH AF			;
	CALL FIND_INT		; routine FIND-INT
	POP DE			;
	LD A,B			;
	OR C			;
	SCF			; Set Carry Flag
	JR Z,L12F9		; forward to I-CARRY

	POP HL			;
	PUSH HL			;
	AND A			;
	SBC HL,BC		;
;
;; I-CARRY
L12F9:	LD A,D			;
	SBC A,$00		;
;
;; I-RESTORE
L12FC:	POP HL			;
	POP DE			;
	RET 			;
;
; --------------------------
; THE 'DE,(DE+1)' SUBROUTINE
; --------------------------
; INDEX and LOAD Z80 subroutine. 
; This emulates the 6800 processor instruction LDX 1,X which loads a two-byte
; value from memory into the register indexing it. Often these are hardly worth
; the bother of writing as subroutines and this one doesn't save any time or 
; memory. The timing and space overheads have to be offset against the ease of
; writing and the greater program readability from using such toolkit routines.
;
;; DE,(DE+1)
L12FF:	EX DE,HL		; move index address into HL.
	INC HL			; increment to address word.
	LD E,(HL)		; pick up word low-order byte.
	INC HL			; index high-order byte and 
	LD D,(HL)		; pick it up.
	RET 			; return with DE = word.
;
; --------------------------
; THE 'GET-HL*DE' SUBROUTINE
; --------------------------
;
;; GET-HL*DE
L1305:	CALL L0DA6		; routine SYNTAX-Z
	RET Z			;

	PUSH BC			;
	LD B,$10		;
	LD A,H			;
	LD C,L			;
	LD HL,$0000		;
;
;; HL-LOOP
L1311:	ADD HL,HL		;
	JR C,L131A		; forward with carry to HL-END

	RL C			;
	RLA			;
	JR NC,L131D		; forward with no carry to HL-AGAIN

	ADD HL,DE		;
;
;; HL-END
L131A:	JP C,L0ED3		; to REPORT-4
;
;; HL-AGAIN
L131D:	DJNZ L1311		; loop back to HL-LOOP

	POP BC			;
	RET 			; return.
;
; --------------------
; THE 'LET' SUBROUTINE
; --------------------
;
;; LET
L1321:	LD HL,($4012)		; sv DEST-lo
	BIT 1,(IY+$2D)		; sv FLAGX
	JR Z,L136E		; forward to L-EXISTS

	LD BC,$0005		;
;
;; L-EACH-CH
L132D:	INC BC			;
;
; check
;
;; L-NO-SP
L132E:	INC HL			;
	LD A,(HL)		;
	AND A			;
	JR Z,L132E		; back to L-NO-SP

	CALL L14D2		; routine ALPHANUM
	JR C,L132D		; back to L-EACH-CH

	CP $0D			; is it '$' ?
	JP Z,L13C8		; forward if so to L-NEW$

	RST 30H			; BC-SPACES
	PUSH DE			;
	LD HL,($4012)		; sv DEST
	DEC DE			;
	LD A,C			;
	SUB $06			;
	LD B,A			;
	LD A,$40		;
	JR Z,L1359		; forward to L-SINGLE
;
;; L-CHAR
L134B:	INC HL			;
	LD A,(HL)		;
	AND A			; is it a space ?
	JR Z,L134B		; back to L-CHAR

	INC DE			;
	LD (DE),A		;
	DJNZ L134B		; loop back to L-CHAR

	OR $80			;
	LD (DE),A		;
	LD A,$80		;
;
;; L-SINGLE
L1359:	LD HL,($4012)		; sv DEST-lo
	XOR (HL)		;
	POP HL			;
	CALL L13E7		; routine L-FIRST

;; L-NUMERIC
L1361:	PUSH HL			;

	RST 28H		;; FP-CALC
	DEFB $02	;;delete
	DEFB $34	;;end-calc

	POP HL			;
	LD BC,$0005		;
	AND A			;
	SBC HL,BC		;
	JR L13AE		; forward to L-ENTER
; ---
;
;; L-EXISTS
L136E:	BIT 6,(IY+$01)		; sv FLAGS  - Numeric or string result?
	JR Z,L137A		; forward to L-DELETE$

	LD DE,$0006		;
	ADD HL,DE		;
	JR L1361		; back to L-NUMERIC
; ---
;
;; L-DELETE$
L137A:	LD HL,($4012)		; sv DEST-lo
	LD BC,($402E)		; sv STRLEN_lo
	BIT 0,(IY+$2D)		; sv FLAGX
	JR NZ,L13B7		; forward to L-ADD$

	LD A,B			;
	OR C			;
	RET Z			;

	PUSH HL			;

	RST 30H			; BC-SPACES
	PUSH DE			;
	PUSH BC			;
	LD D,H			;
	LD E,L			;
	INC HL			;
	LD (HL),$00		;
	LDDR			; Copy Bytes
	PUSH HL			;
	CALL STK_FETCH		; routine STK-FETCH
	POP HL			;
	EX (SP),HL		;
	AND A			;
	SBC HL,BC		;
	ADD HL,BC		;
	JR NC,L13A3		; forward to L-LENGTH

	LD B,H			;
	LD C,L			;
;
;; L-LENGTH
L13A3:	EX (SP),HL		;
	EX DE,HL		;
	LD A,B			;
	OR C			;
	JR Z,L13AB		; forward if zero to L-IN-W/S

	LDIR			; Copy Bytes
;
;; L-IN-W/S
L13AB:	POP BC			;
	POP DE			;
	POP HL			;
;
; ------------------------
; THE 'L-ENTER' SUBROUTINE
; ------------------------
;   Part of the LET command contains a natural subroutine which is a 
;   conditional LDIR. The copy only occurs of BC is non-zero.
;
;; L-ENTER
L13AE:
	EX DE,HL		;
COND_MV
	LD A,B			;
	OR C			;
	RET Z			;

	PUSH DE			;
	LDIR			; Copy Bytes
	POP HL			;
	RET 			; return.
; ---
;
;; L-ADD$
L13B7:	DEC HL			;
	DEC HL			;
	DEC HL			;
	LD A,(HL)		;
	PUSH HL			;
	PUSH BC			;

	CALL L13CE		; routine L-STRING

	POP BC			;
	POP HL			;
	INC BC			;
	INC BC			;
	INC BC			;
	JP L0A60		; jump back to exit via RECLAIM-2
; ---
;
;; L-NEW$
L13C8:	LD A,$60		; prepare mask %01100000
	LD HL,($4012)		; sv DEST-lo
	XOR (HL)		;
;
; -------------------------
; THE 'L-STRING' SUBROUTINE
; -------------------------
;
;; L-STRING
L13CE:	PUSH AF			;
	CALL STK_FETCH		; routine STK-FETCH
	EX DE,HL		;
	ADD HL,BC		;
	PUSH HL			;
	INC BC			;
	INC BC			;
	INC BC			;

	RST 30H			; BC-SPACES
	EX DE,HL		;
	POP HL			;
	DEC BC			;
	DEC BC			;
	PUSH BC			;
	LDDR			; Copy Bytes
	EX DE,HL		;
	POP BC			;
	DEC BC			;
	LD (HL),B		;
	DEC HL			;
	LD (HL),C		;
	POP AF			;
;
;; L-FIRST
L13E7:	PUSH AF			;
	CALL L14C7		; routine REC-V80
	POP AF			;
	DEC HL			;
	LD (HL),A		;
	LD HL,($401A)		; sv STKBOT_lo
	LD ($4014),HL		; sv E_LINE_lo
	DEC HL			;
	LD (HL),$80		;
	RET 			;
;
; --------------------------
; THE 'STK-FETCH' SUBROUTINE
; --------------------------
; This routine fetches a five-byte value from the calculator stack
; reducing the pointer to the end of the stack by five.
; For a floating-point number the exponent is in A and the mantissa
; is the thirty-two bits EDCB.
; For strings, the start of the string is in DE and the length in BC.
; A is unused.
;
STK_FETCH			; (L13F8)
	LD HL,($401C)		; load HL from system variable STKEND

	DEC HL			;
	LD B,(HL)		;
	DEC HL			;
	LD C,(HL)		;
	DEC HL			;
	LD D,(HL)		;
	DEC HL			;
	LD E,(HL)		;
	DEC HL			;
	LD A,(HL)		;

	LD ($401C),HL		; set system variable STKEND to lower value.
	RET 			; return.
;
; -------------------------
; THE 'DIM' COMMAND ROUTINE
; -------------------------
; An array is created and initialized to zeros which is also the space
; character on the ZX81.
;
;; DIM
L1409:	CALL L111C		; routine LOOK-VARS
;
;; D-RPORT-C
L140C:	JP NZ,L0D9A		; to REPORT-C

	CALL L0DA6		; routine SYNTAX-Z
	JR NZ,L141C		; forward to D-RUN

	RES 6,C			;
	CALL L11A7		; routine STK-VAR
	CALL L0D1D		; routine CHECK-END
;
;; D-RUN
L141C:	JR C,L1426		; forward to D-LETTER

	PUSH BC			;
	CALL L09F2		; routine NEXT-ONE
	CALL L0A60		; routine RECLAIM-2
	POP BC			;
;
;; D-LETTER
L1426:	SET 7,C			;
	LD B,$00		;
	PUSH BC			;
	LD HL,$0001		;
	BIT 6,C			;
	JR NZ,L1434		; forward to D-SIZE

	LD L,$05		;
;
;; D-SIZE
L1434:	EX DE,HL		;
;
;; D-NO-LOOP
L1435:	RST 20H			; NEXT-CHAR
	LD H,$40		;
	CALL L12DD		; routine INT-EXP1
	JP C,L1231		; jump back to REPORT-3

	POP HL			;
	PUSH BC			;
	INC H			;
	PUSH HL			;
	LD H,B			;
	LD L,C			;
	CALL L1305		; routine GET-HL*DE
	EX DE,HL		;

	RST 18H			; GET-CHAR
	CP $1A			;
	JR Z,L1435		; back to D-NO-LOOP

	CP $11			; is it ')' ?
	JR NZ,L140C		; back if not to D-RPORT-C

	RST 20H			; NEXT-CHAR
	POP BC			;
	LD A,C			;
	LD L,B			;
	LD H,$00		;
	INC HL			;
	INC HL			;
	ADD HL,HL		;
	ADD HL,DE		;
	JP C,L0ED3		; jump to REPORT-4

	PUSH DE			;
	PUSH BC			;
	PUSH HL			;
	LD B,H			;
	LD C,L			;
	LD HL,($4014)		; sv E_LINE_lo
	DEC HL			;
	CALL L099E		; routine MAKE-ROOM
	INC HL			;
	LD  (HL),A		;
	POP BC			;
	DEC BC			;
	DEC BC			;
	DEC BC			;
	INC HL			;
	LD (HL),C		;
	INC HL			;
	LD (HL),B		;
	POP AF			;
	INC HL			;
	LD (HL),A		;
	LD H,D			;
	LD L,E			;
	DEC DE			;
	LD (HL),$00		;
	POP BC			;
	LDDR			; Copy Bytes
;
;; DIM-SIZES
L147F:	POP BC			;
	LD (HL),B		;
	DEC HL			;
	LD (HL),C		;
	DEC HL			;
	DEC A			;
	JR NZ,L147F		; back to DIM-SIZES

	RET 			; return.
;
; ---------------------
; THE 'RESERVE' ROUTINE
; ---------------------
;
;; RESERVE
L1488:	LD HL,($401A)		; address STKBOT
	DEC HL			; now last byte of workspace
	CALL L099E		; routine MAKE-ROOM
	INC HL			;
	INC HL			;
	POP BC			;
	LD ($4014),BC		; sv E_LINE_lo
	POP BC			;
	EX DE,HL		;
	INC HL			;
	RET 			;
;
; ---------------------------
; THE 'CLEAR' COMMAND ROUTINE
; ---------------------------
;
;; CLEAR
L149A:	LD HL,($4010)		; sv VARS_lo
	LD (HL),$80		;
	INC HL			;
	LD ($4014),HL		; sv E_LINE_lo
;
; -----------------------
; THE 'X-TEMP' SUBROUTINE
; -----------------------
;
;; X-TEMP
L14A3:	LD HL,($4014)		; sv E_LINE_lo
;
; ----------------------
; THE 'SET-STK' ROUTINES
; ----------------------
;
;; SET-STK-B
L14A6:	LD ($401A),HL		; sv STKBOT
;
;; SET-STK-E
L14A9:	LD ($401C),HL		; sv STKEND
	RET 			;
;
; -----------------------
; THE 'CURSOR-IN' ROUTINE
; -----------------------
; This routine is called to set the edit line to the minimum cursor/newline
; and to set STKEND, the start of free space, at the next position.
;
;; CURSOR-IN
L14AD:	LD HL,($4014)		; fetch start of edit line from E_LINE
	LD (HL),$7F		; insert cursor character

	INC HL			; point to next location.
	LD (HL),$76		; insert NEWLINE character
	INC HL			; point to next free location.

	LD (IY+$22),$02		; set lower screen display file size DF_SZ

	JR L14A6		; exit via SET-STK-B above
;
; ------------------------
; THE 'SET-MIN' SUBROUTINE
; ------------------------
;
;; SET-MIN
L14BC:	LD HL,$405D		; normal location of calculator's memory area
	LD ($401F),HL		; update system variable MEM
	LD HL,($401A)		; fetch STKBOT
	JR L14A9		; back to SET-STK-E
;
; ------------------------------------
; THE 'RECLAIM THE END-MARKER' ROUTINE
; ------------------------------------
;
;; REC-V80
L14C7:	LD DE,($4014)		; sv E_LINE_lo
	JP L0A5D		; to RECLAIM-1
;
; ----------------------
; THE 'ALPHA' SUBROUTINE
; ----------------------
;
;; ALPHA
L14CE:	CP $26			;
	JR L14D4		; skip forward to ALPHA-2
;
; -------------------------
; THE 'ALPHANUM' SUBROUTINE
; -------------------------

;; ALPHANUM
L14D2:	CP $1C			;
;
;; ALPHA-2
L14D4:	CCF			; Complement Carry Flag
	RET NC			;

	CP $40			;
	RET 			;
;
; ------------------------------------------
; THE 'DECIMAL TO FLOATING POINT' SUBROUTINE
; ------------------------------------------
;
;; DEC-TO-FP
L14D9:	CALL L1548		; routine INT-TO-FP gets first part
	CP $1B			; is character a '.' ?
	JR NZ,L14F5		; forward if not to E-FORMAT

	RST 28H		;; FP-CALC
	DEFB $A1	;;stk-one
	DEFB $C0	;;st-mem-0
	DEFB $02	;;delete
	DEFB $34	;;end-calc
;
; ---------------------
; THE 'NEXT DIGIT' LOOP
; ---------------------
;   Within the 'DECIMAL TO FLOATING POINT' routine, swapping the multiply and
;   divide literals preserves accuracy and ensures that .5 is evaluated 
;   as 5/10 and not as .1 * 5.
;
;; NXT-DGT-1
L14E5:	RST 20H			; NEXT-CHAR
	CALL L1514		; routine STK-DIGIT
	JR C,L14F5		; forward to E-FORMAT

	RST 28H		;; FP-CALC

	DEFB $E0	;;get-mem-0

	.db $3B		;;macro mul-by-10

	DEFB $C0	;;st-mem-0
	DEFB $05	;;+division
	DEFB $0F	;;addition
	DEFB $34	;;end-calc

	JR L14E5		; loop back till exhausted to NXT-DGT-1
; ---
	.db $FF			; spare :)
;
;; E-FORMAT
L14F5:	CP $2A			; is character 'E' ?
	RET NZ			; return if not

	LD (IY+$5D),$FF		; initialize sv MEM-0-1st to $FF TRUE

	RST 20H			; NEXT-CHAR
	CP $15			; is character a '+' ?
	JR Z,L1508		; forward if so to SIGN-DONE

	CP $16			; is it a '-' ?
	JR NZ,L1509		; forward if not to ST-E-PART

	INC (IY+$5D)		; sv MEM-0-1st change to FALSE

;; SIGN-DONE
L1508:	RST 20H			; NEXT-CHAR

;; ST-E-PART
L1509:	CALL L1548		; routine INT-TO-FP

	RST 28H		;; FP-CALC	m, e.
	DEFB $E0	;;get-mem-0	m, e, (1/0) TRUE/FALSE

	DEFB $00	;;jump-true
	DEFB L1511-$	;;to E-POSTVE

	DEFB $18	;;neg		m, -e

;; E-POSTVE
L1511:	DEFB $38	;;e-to-fp	x.
	DEFB $34	;;end-calc	x.

	RET 			; return.
;
; --------------------------
; THE 'STK-DIGIT' SUBROUTINE
; --------------------------
;
;; STK-DIGIT
L1514:	CP $1C			;
	RET C			;

	CP $26			;
	CCF			; Complement Carry Flag
	RET C			;

	SUB $1C			;
;
; ------------------------
; THE 'STACK-A' SUBROUTINE
; ------------------------
;
STACK_A				; (L151D)
	LD C,A			;
	LD B,$00		;
;
; -------------------------
; THE 'STACK-BC' SUBROUTINE
; -------------------------
; The ZX81 does not have an integer number format so the BC register contents
; must be converted to their full floating-point form.
;
STACK_BC			; (L1520)
	LD IY,$4000		; re-initialize the system variables pointer.
	PUSH BC			; save the integer value.

; now stack zero, five zero bytes as a starting point.

	RST 28H		;; FP-CALC
	DEFB $A0	;;stk-zero	0.
	DEFB $34	;;end-calc

	POP BC			; restore integer value.

	LD (HL),$91		; place $91 in exponent 65536.
				; this is the maximum possible value

	LD A,B			; fetch hi-byte.
	AND A			; test for zero.
	JR NZ,L1536		; forward if not zero to STK-BC-2

	LD (HL),A		; else make exponent zero again
	OR C			; test lo-byte
	RET Z			; return if BC was zero - done.

; else  there has to be a set bit if only the value one.

	LD B,C			; save C in B.
	LD C,(HL)		; fetch zero to C
	LD (HL),$89		; make exponent $89  256.

;; STK-BC-2
L1536:	DEC (HL)		; decrement exponent - halving number
	SLA C			;  C<-76543210<-0
	RL B			;  C<-76543210<-C
	JR NC,L1536		; loop back if no carry to STK-BC-2

	SRL B			;  0->76543210->C
	RR C			;  C->76543210->C

	INC HL			; address first byte of mantissa
	LD (HL),B		; insert B
	INC HL			; address second byte of mantissa
	LD (HL),C		; insert C

	DEC HL			; point to the
	DEC HL			; exponent again
	RET 			; return.
;
; ---------------------------------------------------
; THE improved 'INTEGER TO FLOATING POINT' SUBROUTINE
; ---------------------------------------------------
;
;; INT-TO-FP
L1548:	PUSH AF			;

	RST 28H		;; FP-CALC
	DEFB $A0	;;stk-zero
	DEFB $34	;;end-calc

	POP AF			;

;; NXT-DGT-2
L154D:	CALL L1514		; routine STK-DIGIT
	RET C			;


	RST 28H		;; FP-CALC
	DEFB $01	;;exchange

	.db $3B		;;macro mul-by-10

	DEFB $0F	;;addition
	DEFB $34	;;end-calc

	RST 20H			; NEXT-CHAR
	JR L154D		; to NXT-DGT-2
; ---
	.db $FF			; spare :)
;
; -----------------------------------------------
; THE new 'E-FORMAT TO FLOATING POINT' SUBROUTINE
; -----------------------------------------------
; (Offset $38: 'e-to-fp')
; invoked from DEC-TO-FP and PRINT-FP.
; e.g. 2.3E4 is 23000.
; This subroutine evaluates x*E exp10 where exp10 is a positive or
; negative integer.
; On entry in the ZX81, the exponent (exp10) is the 'last value',
; and the floating-point decimal mantissa is beneath it.
;
;; new E-TO-FP
e_to_fp				; (L155A)
	call L158A		; routine FP-TO-BC - the exponent

	jr z,E_POSTV		; test the exponent's sign

	inc b			; if negative then B=1
	push bc			; save counter (exponent and its sign)

	rst 28H		;; FP-CALC	x.
	.db $A4		;; stk-ten	x, 10.
	.db $34		;; end-calc

	jr skip_mul		; restore counter (exponent and its sign)
E_POSTV
	and a			; if exponent is zero
	ret z			; then return
;
;; E-LOOP	now enter a loop
LOOP_E10
	push bc			; save counter (exponent and its sign)
	call mul_by10		; multiply by 10
skip_mul
	pop bc			; restore counter (exponent and its sign)
	dec c			; set counter
	jr nz,LOOP_E10		; loop while nonzero

	djnz E_END		; in case of pos. exp. return

	rst 28H		;; FP-CALC	else
	.db $05		;;division	x/10^exp10.
	.db $34		;;end-calc	new x.
E_END
	ret
;
;	========================================================
mb_loop
	ld b,4			; size of the mantissa
	ld h,d			; set pointer after the
	ld l,e			; LSB of the mantissa
	scf			; CY=1
nx_mbyte
	dec hl			; the last/prev. mantissa byte
	rl (hl)			; CY <- 76543210 <- CY
	djnz nx_mbyte		; done? back if not

	dec hl			; points the exponent
	dec (hl)		; decrease it
	ret			;
;
; ==============================================================
;
; -------------------------
; Handle PEEK function (28)
; -------------------------
; This function returns the contents of a memory address.
; The entire address space can be peeked including the ROM.
;
fn_peek
	CALL FIND_INT		; routine FIND-INT puts address in BC.
	LD A,(BC)		; load contents into A register.

	JP STACK_A		; exit via STACK-A to put value on the
				; calculator stack.
;
; ==============================================================
;
; ---------------------------------------------------------
; THE improved 'FLOATING-POINT TO BC' SUBROUTINE (67 bytes)
; ---------------------------------------------------------
; The floating-point form on the calculator stack is compressed
; directly into the BC register rounding up if necessary.
; Valid range is 0 to 65535.4999
;
;; FP-TO-BC
L158A:	CALL STK_FETCH		; routine STK-FETCH - exponent to A
				; mantissa to EDCB.
	rla			; test if abs(x)>=0.5  (exp>=128)
	jr c,L1595		; forward if yes (CY=1) to FPBC-NZRO
;
; else value is zero
;
	xor a			; else clear CY and A, set Z flag
	LD B,A			; zero to B
	LD C,A			; also to C
	jr L15C4		; forward to FPBC-ZRO
; ---
;
; EDCB  =>  BCE
;
;; FPBC-NZRO
L1595:
	LD B,E			; transfer the mantissa from EDCB
	LD E,C			; to BCE. Bit 7 of E is the 17th bit which
	LD C,D			; will be significant for rounding if the
				; number is already normalized.

	rra			; restore the original exponent

	SUB $91			; subtract 65536
	CCF			; complement carry flag
	BIT 7,B			; test sign bit
	PUSH AF			; push the result

	SET 7,B			; set the implied bit
	JR C,L15C5		; forward with carry from SUB/CCF to FPBC-END
				; number is too big.

	cpl			; complement to make range $00 - $0F

	CP $08			; test if one or two bytes
	JR C,L15AE		; forward with two to BIG-INT

	LD E,C			; shift mantissa
	LD C,B			; 8 places right
	LD B,$00		; insert a zero in B
	SUB $08			; reduce exponent by eight
;
;; BIG-INT
L15AE:	AND A			; test the exponent
	LD D,A			; save exponent in D.

	LD A,E			; fractional bits to A
	RLCA			; rotate most significant bit to carry for
				; rounding of an already normal number.

	JR Z,L15BB		; forward if exponent zero to EXP-ZERO
				; the number is normalized
;
;; FPBC-NORM
L15B4:	SRL B			;   0->76543210->C
	RR C			;   C->76543210->C

	DEC D			; decrement exponent
	JR NZ,L15B4		; loop back till zero to FPBC-NORM
;
;; EXP-ZERO
L15BB:
	JR NC,L15C5		; forward without carry to FPBC-END (NO-ROUND)

	INC BC			; round up.
	LD A,B			; test result
	OR C			; for zero
	JR NZ,L15C5		; forward if not to FPBC-END

	POP AF			; restore sign flag
	SCF			; set carry flag to indicate overflow

;; FPBC-ZRO
L15C4:	PUSH AF			; save combined flags again
;
;; FPBC-END
L15C5:	PUSH BC			; save BC value

;; set HL and DE to calculator stack pointers.

	call STK_PNTRS		; routine STK-PNTRS is called to set up the
				; calculator stack pointers:
				; HL = last value on stack.
				; DE = STKEND first location after stack.

	POP BC			; restore BC value
	POP AF			; restore flags
	LD A,C			; copy low byte to A also.
	RET 			; return
;
; ------------------------------------
; THE 'FLOATING-POINT TO A' SUBROUTINE
; ------------------------------------
;
FP_TO_A				; (L15CD)
	CALL L158A		; routine FP-TO-BC
	RET C			;

	PUSH AF			;
	DEC B			;
	INC B			;
	JR Z,L15D9		; forward if in range to FP-A-END

	POP AF			; fetch result
	SCF			; set carry flag signaling overflow
	RET			; return
;
;; FP-A-END
L15D9:	POP AF			;
	RET			;
;
; --------------------------------------------------
; THE new 'PRINT A FLOATING-POINT NUMBER' SUBROUTINE
; --------------------------------------------------
; prints 'last value' x on calculator stack.
;
;; PRINT-FP (L15DB)
PRINT_FP
	rst 28h		; FP-CALC	x.
	.db $C0		;;set-mem-0	x.
	.db $02		;;delete	.	clear the
	.db $34		;;end-calc		calc. stack

	ld a,(de)		; pick up the exponent byte
	and a			; if it is zero, then return via
	jp z,prnt_num		; routine OUT-CODE (prints a zero)

	call STACK_A		; else STACK-A places on calculator stack.

	ld hl,$405E		; first byte of the mantissa (MEMBOT+1)
	bit 7,(hl)		; test if positive
	set 7,(hl)		; complete the mantissa (make it negative)

	ld l,$67		; set pointer to MEMBOT+10 (mem2)
	push hl			; save pointer (of the digit buffer)

	jr z,positive		; skip if positive

	ld a,$16		; load code '-'
	rst 10h			; PRINT-A
positive
	rst 28H		;; FP-CALC		e	[1..255]

        .db $30, $EF		;; stk-data, exponent: $7F, bytes: 4
        .db $9A,$20,$9A,$84	;;		e, -0.30103 (-log 2)

        .db $04		;; multiply		e*(-log 2)

	.db $30, $36	;; stk-data exponent:	$86, Bytes: 1
	.db $1C		;; (+00,+00,+00)	e*(-log 2), 39

	.db $0F		;; addition		e*(-log 2)+39

	.db $C2		;; st-mem-2		exp10.
	.db $E0		;; get-mem-0		exp10, x.
	.db $E2		;; get-mem-2		exp10, x, exp10.

	.db $38		;; new e-to-fp		exp10,x * (10^exp10).
	.db $34		;; end-calc
;
;	---------------------------------------------
;
	ld bc,$0900		; B: 9 digits to convert
				; C: exp10 factor (0 by default)
	push bc			; save counter/factor

	ld a,(hl)		; test the normalized number
	sub $81			; >=1?
	jr nc,getDigit		; if yes, then get the 1st digit

	pop bc			; else restore counter/factor
	dec c			; set factor to -1
	push bc			; save counter/factor
	inc hl			; set pointer to the mantissa, then
mul_ten
	dec hl			; hl points the exponent
	call mul_by10		; multiply by 10

	ld a,(hl)		; pick up the exponent
	sub $81			; test if >=1
	jr nc,getDigit		; jump if so

	xor a			; else clear A
	jr putDigit		; less than 1? -> put zero into buffer
;
;	--------------------------------------------- else
getDigit
	inc a			; exp-$80 gives the
	ld c,a			; bit counter of a digit
	xor a			; clear CY and the bit buffer
nxt_mbit
	call mb_loop		; shift left the mantissa

	rla			; store 1 bit of the digit
	dec c			; set bit counter
	jr nz,nxt_mbit		; done? -> back if not
putDigit
	pop bc			; restore counter/factor
	ex (sp),hl		; switch pointers
	ld (hl),a		; put digit into buffer
	inc l			; set buffer pointer
	ex (sp),hl		; switch back pointers

	dec b			; set the digit counter
	push bc			; save counter/factor
	jr z,dig9done		; done if it was the 9th digit
test_msb
	inc hl			; else normalize the number
	bit 7,(hl)		; test the msb of the mantissa
	jr nz,mul_ten		; back if it is nonzero

	call mb_loop		; shift left the mantissa
	jr test_msb		;
;
;	---------------------------------------------
dig9done
	call STK_FETCH		; remove final x from calc. stack

	call FP_TO_A		; FP-TO-A (-exp10) : A=abs(exp10)
	jr nz,negative		; if it is positive

	neg			; then make it negative
negative
	pop bc			; get the exp10 factor (0 or -1)
	add a,c			; and add to the exp10

	pop hl			; get the buffer pointer
	dec l			; points the 9th digit
	push af			; save the final exp10
;
;	---------------------------------------------
rounding
	push hl			; save the buffer pointer
	ld a,4			; test the last digit (>=5?)
	sub (hl)		; CY=1 if rounding is necessary
	ld b,8			; set the digit counter
round_8
	dec l			; set buffer pointer
	ld a,(hl)		; pick up the next digit
	adc a,$90		; add the rounding bit
	daa			; BCD correction
	jr c,overflow		; jump if overflow

	and $0F			; else clear the upper nibble
overflow
	ld (hl),a		; store the digit
	djnz round_8		; done? -> back if not

	jr nc,cnt_zero		; jump if no overflow

	pop hl			; get pointer of the 9th digit
	pop af			; <- exp10
	inc a			; exp10 +1
	push af			; exp10 ->
	push hl			; save pointer
	ld d,h			; set the
	ld e,l			; destination pointer
	dec l			; 8th digit
	ld c,8			; set counter
	lddr			; copy
	
	inc l			; HL points the first digit
	ld (hl),1		; set as '1'
;
;	--------------------------------------------------
cnt_zero
	pop hl			; HL points the 9th digit
	pop de			; D <- exp10
;
;	--------------------------------------------------
;
	ld bc,$0901		; 8 digits to print, decimal
				; point is after the first
	ld e,c			; e=1 (not e-format)
cnt_back
	dec l			; points a digit of the mantissa 
	dec b			; decrease the counter
	ld a,(hl)		; read in and
	and a			; test a digit of the mantissa
	jr z,cnt_back		; if zero then check next digit

	ld a,d			; test the exp10
	bit 7,a			; positive?
	jr z,pos_exp		; yes, jump
;
;	--------------------------------------------------
;
	neg			; make it positive
	cp $05			; less than .0001?
	jr nc,neg_exp		; yes -> e-format
;
;	--------------------------------------------------
;
	ld d,a			; nr. of leading zeros
	add a,b			; increase and
	ld b,a			; save nr. of printable digits
leadzero	
	xor a			; print
	call pr_digit		; leading
	dec d			; zeros
	jr nz,leadzero		; done?

	jr not_efmt		; forward to printing the rest
;
;	--------------------------------------------------
;
pos_exp
	cp $08			; more than 99999999?
	jr nc,e_format		; yes, e-format

	add a,c			; set position of
	ld c,a			; the decimal point
	cp b			; if nr. of the printable digits
	jr c,not_efmt		; is greater than position of the
				; decimal point then forward
	ld b,c			; else set nr. of printable digits
	jr not_efmt		; to decimal point position
;
;	--------------------------------------------------
neg_exp
	inc e			; the exponent is negative
;
;	--------------------------------------------------
e_format
	ld d,a			; save value of the exponent
	inc e			; set e-format (e>1)
;
;	--------------------------------------------------
not_efmt
	ld l,$67		; $4067 - addr. of the first digit
e_form1
	ld a,(hl)		; get value
	inc l			; set pointer
	call pr_digit		; display a digit

	jr nz,e_form1		; back until done
print_E
	dec e			; e-format (e>1) ?
	ret z			; no, done

	dec c			; else set decimal point

	ld a,$2A		;
	rst 10h			; print 'E'

	ld a,$15		; load '+' 
	dec e			; if exp>0 then E=0
	add a,e			; else E=1 -> A: '-'
	rst 10h			; PRINT-A
;
;	--------------------------------------------------
;
 	ld a,d			; get value of the exponent
set_E1
	ld d,a			; save as ones
	sub 10			; decrease by 10
	jr c,set_E2		; until negative

	djnz set_E1		; count tens
set_E2	
	xor a			; the counter of tens is negative
	sub b			; make it positive, then
	call nz,pr_digit	; print if nonzero

 	ld a,d			; the ones
;
;	--------------------------------------------------
pr_digit
	call prnt_num		; print as number (0..9)

	dec b			; it was the last digit?
	ret z			; yes return

	dec c			; decimal point?
	ret nz			; no, return

	xor a			;
	jp prnt_dot		; print '.'
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

	inc bc			;
	dec hl			; HL points the old end of D-FILE
	jr c,cls_cont		; if room is enough then return

	call L099E		; else routine MAKE-ROOM

	inc de			; position of the latest N/L in D-FILE
cls_cont
	ex de,hl		; 
	inc hl			; points the (expected) variables area
	pop bc			; restore counter
	jp clr_next		; back to renewed CLS routine
;
;	==============================================================
scrl_new
	jr z,scrl_old		; jump if D-File is collapsed
scrl_nxt
	ld bc,33		; set byte counter (32 spaces + 1 N/L)
	ldir			; copy a line
	dec a			; set line counter
	jr nz,scrl_nxt		; done? back, if not

	jp clr_scrl		; clear the last line and return
;
;	--------------------------------------
scrl_old
	push de			;
	call loc_pos0		; ld c,$21 --> LOC-ADDR
	
	dec hl			; insert a N/L before the N/L
	call L099B		; routine ONE-SPACE  

	pop hl			; HL points D_FILE
	INC HL			; skip 1st N/L
	LD D,H			; save pointer
	LD E,L			; in DE
	CPIR			; find next N/L and
	jp L0A5D		; return via RECLAIM-1 (erase line 1)
;
;	==============================================================
;
;
;
;********************************
;**  FLOATING-POINT CALCULATOR **
;********************************
;
; As a general rule the calculator avoids using the IY register.
; Exceptions are val and str$.
; So an assembly language programmer who has disabled interrupts to use
; IY for other purposes can still use the calculator for mathematical
; purposes.
;
;
;
; ==============================================================
; =======		ARITHMETIC ROUTINES		 =======
; ==============================================================
;
;	hl: points the LSB of the greater number's mantissa
;	a:  the LSB of the greater number's mantissa
;	b'7: the rounding bit
;	B(MSB),C,D,E(LSB) contain the less number's mantissa
sub_OP2
	exx			; ..	(alternate set)
	rlc b			; the rounding bit (B'7)
	exx			;  ..	(main set)

	sbc a,e			; the real subtraction
	ld e,a			; 4th byte of the mantissa
	dec hl			;
	ld a,(hl)		;
	sbc a,d			;
	ld d,a			; 3rd byte of the mantissa
	dec hl			;
	ld a,(hl)		;
	sbc a,c			;
	ld c,a			; 2nd byte of the mantissa
	dec hl			;
	ld a,(hl)		;
	set 7,a			; the msb is always '1'
	sbc a,b			;
	ld b,a			; B(MSB),C,D,E(LSB): the result's mantissa

	ld h,b			;
	ld l,c			; HL: the upper word of the result's mantissa
	jr nc,sub_spos		; skip if it is positive

	ld hl,1			; else negate the mantissa
	sbc hl,de		;
	ex de,hl		;
	add hl,de		; clear HL
	sbc hl,bc		; H,L,D,E: the result's mantissa
sub_spos
	ld bc,$2100		; set counters
	ld a,c			; clear A
	rra			; A7 indicates the sign change
sub_norm
	exx			; ..	(alternate set)
	rlc b			; the rounding bit (B'7)
	exx			;  ..	(main set)
	bit 7,h			; normalize
	jp nz,sub_end		; done if msb=1

	ex de,hl		;
	adc hl,hl		; double the lower word of the result's mantissa
	ex de,hl		;
	adc hl,hl		; double the upper word of the result's mantissa
	inc c			; set counter
	djnz sub_norm		; max. 32 shifts are accepted
;
;	--------------------------------------------------------
;
	pop hl			; drop return address 
	pop hl			; drop the greater exponent 
	jr z_result		; the result is zero
;
;	========================================================
;
; ---------------------------
; THE 'SUBTRACTION' OPERATION
; ---------------------------
; just switch the sign of subtrahend and do an add.
;
;; subtract (L174C)
;
;	========================================================
; in:
;	hl: points OP1 (the destination)
;	de: points OP2
;
subtract
	LD A,(DE)		; fetch exponent byte of second number the
				; subtrahend. 
	AND A			; test for zero
	RET Z			; return if zero - first number is result.

	INC DE			; address the first mantissa byte.
	LD A,(DE)		; fetch to accumulator.
	XOR $80			; toggle the sign bit.
	LD (DE),A		; place back on calculator stack.
	DEC DE			; point to exponent byte.
				; continue into addition routine.
;
;	========================================================
;
; ----------------------------
; THE new 'ADDITION' OPERATION
; ----------------------------
;
;; addition (L1755)
;
;	========================================================
; in &
; out:	hl: points OP1 (the destination)
;	de: points OP2
;
addition
	ld a,(de)		; fetch OP2.exp 
	and a			; =0?
	ret z			; if yes, then OP1 is the result

	ld c,a			; save OP2.exp
	ld a,(hl)		; fetch OP1.exp
	and a			; =0?

	push de			; save the original
	push hl			; pointers

	jr z,fw_OPcpy		; if OP1=0, then OP2 is the result
				; return via 'copy_OP2'
	ld b,a			; save OP1.exp
	sub c			; OP1.exp-OP2.exp

	cp 33			; test distance
	jr c,pos_dist		; jump if it is less than 33 bit

	cp -32			; if it is more
	jp c,diff_33p		; then return

	cpl			; the difference is negative
	inc a			; so negate it
	ld b,c			; change the greater exponent
	ex de,hl		; de points the less number
pos_dist
	push bc			; save the greater exponent (B)
	inc hl			; n1
	ld c,(hl)		; sgn
	push hl			; save pointer (man. of the greater num.)
	ex de,hl		; hl points the less exponent

	inc hl			; m1
	ld b,(hl)		; sgn
	push bc			; save MSBs
	
	inc hl			; m2
	ld c,(hl)		;
	inc hl			; m3
	ld d,(hl)		;
	inc hl			; m4
	ld e,(hl)		; the LSB

	set 7,b			; the msb is always '1'

	and a			; test distance (& clear CY)
	jr z,skp_shft		; skip shifting if zero
add_shft
	srl b			; 0 -> bbbbbbbb -> CY
	rr c			; CY -> cccccccc -> CY
	rr d			; CY -> dddddddd -> CY
	rr e			; CY -> eeeeeeee -> CY
	dec a			;
	jr nz,add_shft		;
skp_shft
	exx			; ..	(alternate set)
	sbc a,a			; depending on rounding bit
	ld b,a			; B=$00 or B=$FF
	exx			; ..	(main set)

	pop hl			; the MSBs contain the sign bits
	ld a,h			; which select the next operation:
	xor l			; if A7=0 then addition else subtraction

	ld h,l			; save sign bit (H7) and HL now
	ex (sp),hl		; points the greater number's MSB

	rla			; if CY=0 then addition else subtraction
	call addorsub		; execute operation

	pop hl			; the sign bit (h7)
	ex (sp),hl		; H = the greater exponent

	and a			; test correction's value
;
;	--------------------------------------------------------
;	the multiplcation and the division joins here
;
m_d_exit
	jp m,add_nexp		; jump if it is negative
sub_pexp
	ld l,a			; else decrease
	ld a,h			; the exponent
	sub l			; w. correction
	jr z,z_result		; skip if underflow (<=0)

	jr nc,set_Exp1		; else store the return value
;
;	--------------------------------------------------------
z_result
	pop hl			; drop flags 
	pop hl			; restore the OP1 pointer
	xor a			;
	ld (hl),a		; clear OP1.exp

	ld c,a			; clear the
	ld d,a			; arithmetic
	ld e,a			; buffer
	jr OP1_fill		; and set OP1 as zero
;
;	--------------------------------------------------------
set_Exp1
	pop hl			; the sign bit (H7)
	ex (sp),hl		; points OP1
	ld (hl),a		; set OP1.exp

	ld a,$80		; mask of the sign bit (A7)
	xor b			; toggle
	ld b,a			; the sign bit (B7)

	pop af			; the new sign bit (A7)
	and $80			; mask out the sign bit
	xor b			; apply changes
OP1_fill
	push hl			;
	inc hl			; points OP1.man1
	ld (hl),a		;
	inc hl			; points OP1.man2
	ld (hl),c		;
	inc hl			; points OP1.man3
	ld (hl),d		;
	inc hl			; points OP1.man4
	ld (hl),e		;
ret_OP1
	pop hl			; restore the 
	pop de			; pointers
	ret			; done
;
;	========================================================
;
; ---------------------------------------
; THE improved 'MULTIPLICATION' OPERATION
; ---------------------------------------
;
;; multiply (L17C6)
;
;	========================================================
; in &
; out:	hl: points OP1 (the destination)
;	de: points OP2
;
multiply
	ld a,(hl)		; fetch OP1.exp
	and a			; if it is zero,
	ret z			; then the result is zero

	ld b,a			; store exp1
	ld a,(de)		; fetch OP2.exp
	and a			; test zero

	push de			; save the original
	push hl			; pointers
fw_OPcpy
	jr z,copy_OP2		; OP2=0? -> return via 'copy_OP2'
	
	ld c,a			; store exp2
	push bc			; save exp1,exp2

	call fetchOps		; fetch both mantissas into Z80 registers

	push af			; man1.S * man2.S
	push hl			; save pointer to the next calculator literal
	sbc hl,hl		; H'L'H,L = 0

	ld a,b			; transfer high mantissa byte of first number
	ld b,$20		; register B can now be used to count 32 shifts.
; ---
;
mul_loop
	rra			; C > 76543210 > C
	rr c			; C > 76543210 > C
	exx			; ..	(main set)
	rr b			; C > 76543210 > C
	rr c			; C > 76543210 > C

	jr nc,skip_add		; skip if no carry, else add in the multiplicand.

	add hl,de		; add the lower word to result
	exx			; switch to more significant bytes.
	adc hl,de		; add high bytes of multiplicand and any carry.
	exx			; switch back to main set
skip_add
	exx			; ..	(alternate set)
	rr h			; C > 76543210 > C
	rr l			; C > 76543210 > C
	exx			; ..	(main set)
	rr h			; C > 76543210 > C
	rr l			; C > 76543210 > C
	exx			; ..	(alternate set)

	djnz mul_loop		; loop back 32 times

	ex (sp),hl		; save upper word of the mantissa and
				; restore pointer to the next calculator literal
	exx			; switch back to main set 
	ex de,hl		; 
	pop bc			; mantissa in B(MSB),C,D,E(LSB)

	pop hl			; man1.S * man2.S
	ex (sp),hl		; exp1,exp2

	bit 7,b			; if the mantissa's msb is '1',
	jr nz,man_isOK		; then skip the shifting

	rl e			; else shift left the mantissa
	rl d			; 
	rl c			; 
	rl b			;
	rla			; underflow bit to CY
	dec h			; exponent correction
man_isOK
	ld a,0			; set correction to zero
	call c,round32b		; round if it is necessary

	sub l			; fetch exp2 with correction
	add a,$80		; remove the offset
	jr m_d_exit		; go to subtract from exp1
;
;	========================================================
;
;	sub_OP2 (the real subtraction) routine ends here
sub_end
	xor h			; set the sign bit
	ld b,a			; store the MSB of the mantissa
	ld a,c			; store the counter
	ld c,l			; the 2nd byte of the mantissa
	ret	
;
;	========================================================
;
; 	addition joins here if difference between exponents is more than 32
;	the final result will be the number with greater exponent
;
diff_33p
	rla			; if difference is positive,
	jr nc,ret_OP1		; then OP1 is the result, else
copy_OP2
	ex de,hl		; exchange the pointers
	ld bc,5			; 5 bytes to copy
	ldir			; copy
	jr ret_OP1		; restore the pointers
;
;	========================================================
;
; -----------------------------------------------
; successor of THE 'FETCH TWO NUMBERS' SUBROUTINE
; -----------------------------------------------
; This routine is used by multiplication and division to fetch the two
; five-byte numbers' mantissa addressed by HL and DE from the calculator
; stack into the Z80 registers.
;
; In: HL points OP1, DE points OP2
;
; Out:	B'C'B,C	: OP1.man
;	D'E'D,E	: OP2.man
;	HL = 0
;	A7 = sign bit of the (later) result
;
fetchOps
	inc de			; set OP2 pointer
	ld a,(de)		; fetch MSB of the man2
	inc hl			; set OP1 pointer
	ld b,(hl)		; fetch MSB of the man1
	xor b			; A7 = man1.S * man2.S (and CY=0!)

	inc hl			; set OP1 pointer
	ld c,(hl)		; fetch man1.2
	push bc			; save man1.1,man1.2

	inc hl			; set OP1 pointer
	ld b,(hl)		; fetch man1.3
	inc hl			; fetch set OP1 pointer
	ld c,(hl)		; fetch man1.4

	ex de,hl		; HL points now OP2

	ld d,(hl)		; fetch man2.1
	inc hl			; set OP2 pointer
	ld e,(hl)		; fetch man2.2
	push de			; save man2.1,man2.2

	inc hl			; set OP2 pointer
	ld d,(hl)		; fetch man2.3
	inc hl			; set OP2 pointer
	ld e,(hl)		; fetch man2.4

	sbc hl,hl		; clear HL
	
	exx			; switch to alternate set
	pop de			; man2.1,man2.2 
	set 7,d			; the msb is always '1'
	pop bc			; man1.1,man1.2 
	set 7,b			; the msb is always '1'

	ret			;
;
;	========================================================
;
;	CY indicates the operation: 0=addition 1=subtraction
;	hl: points the MSB of the greater number's mantissa
;	b'7: the rounding bit
;	B(MSB),C,D,E(LSB) contain the less number's mantissa
addorsub
	inc hl			; set pointer
	inc hl			;
	inc hl			; HL now points the LSB of the mantissa
	ld a,(hl)		; fetch the LSB of the mantissa

	jp c,sub_OP2		; CY=1? --> subtraction

	add a,e			; the real addition
	ld e,a			; 4th byte of the mantissa
	dec hl			;
	ld a,(hl)		;
	adc a,d			;
	ld d,a			; 3rd byte of the mantissa
	dec hl			;
	ld a,(hl)		;
	adc a,c			;
	ld c,a			; 2nd byte of the mantissa
	dec hl			;
	ld a,(hl)		;
	set 7,a			; the msb is always '1'
	adc a,b			;
;
;	--------------------------------------------------------
norm_res
	ld b,a			; B(MSB),C,D,E(LSB): the result's mantissa

	sbc a,a			; if CY=1 -> A=-1 ($FF)
	jr nc,roundbit		; if CY=0 -> A= 0	- the correction -

	rr b			; CY -> bbbbbbbb -> CY
	rr c			; CY -> cccccccc -> CY
	rr d			; CY -> dddddddd -> CY
	rr e			; CY -> eeeeeeee -> CY
norm_end
	ret nc			;
;
;	--------------------------------------------------------
round32b	
	inc e			; set LS byte of the mantissa
	ret nz			; return if there is no overflow

	inc d			; set 3rd byte of the mantissa
	ret nz			; return if there is no overflow

	inc c			; set 2nd byte of the mantissa
	ret nz			; return if there is no overflow

	inc b			; set MS byte of the mantissa
	ret nz			; return if there is no overflow

	ld b,$80		; else set MSB and
	dec a			; adjust the correction
	ret			;
;
;	--------------------------------------------------------
roundbit
	exx			; ..	(alternate set)
	rl b			; restore the rounding bit (B'7)
	exx			; ..	(main set)
	jr norm_end		; and round if it is necessary
;
;	========================================================
add_nexp
	neg			; make it positive

	add a,h			; add the 2 exponents
	jp nc,set_Exp1		; store the result if not overflow
;
;	--------------------------------------------------------
;
;; REPORT-6 (L1880)
;
error_6
	rst 08h			; Error Report:
	.db $05			; Arithmetic overflow.
;
;	========================================================
;
; ---------------------------------
; THE improved 'DIVISION' OPERATION
; ---------------------------------
;
;; division (L1882)
;
;	========================================================
; in &
; out:	hl: points OP1 (the destination)
;	de: points OP2
;
division
	ld a,(de)		; check for division by zero
	and a			; if exp2=0,
	jr z,error_6		; then -> Arithmetic overflow
	
	ld c,a			; store exp2
	ld a,(hl)		; fetch exp1
	and a			; if it is zero,
	ret z			; then the result also is zero

	push de			; save the original
	push hl			; pointers

	ld b,a			; store exp1
	push bc			; save exp1,exp2

	call fetchOps		; fetch both mantissas into Z80 registers

	push af			; man1.S * man2.S
	push hl			; save pointer to the next calculator literal

	ld h,b			;
	ld l,c			; H'L' = upper 2 bytes of the dividend

	xor a			; clear MSB of the result
	ld b,a			; clear lower 2 bytes of the result
	ld c,a			; 

	exx			; switch back to main set
	ld h,b			;
	ld l,c			; H,L = lower 2 bytes of the dividend
	ld bc,$DF00		; B: a counter (-33), C: 2nd byte of the result
; ---
;
div_loop
	sbc hl,de		; subtract divisor part
	exx			; ..	(alternate set)
	sbc hl,de		;
	jr nc,shft_inv		; forward if there is no overflow

	exx			; ..	(main set)
	add hl,de		; else restore
	exx			; ..	(alternate set)
	adc hl,de		;
shft_inv
	ccf			; complement carry flag
shft_bin
	rl c			; multiply partial quotient by two
	rl b			; setting result bit from carry
	exx			; ..	(main set)
	rl c			;
	rla			;
	inc b			; increment the counter
	jr c,endofdiv		; exit, if the 33th bit is done

	add hl,hl		;
	exx			; ..	(alternate set)
	adc hl,hl		;
	exx			; ..	(main set)
	jr nc,div_loop		; 

	and a			; SUB-ONLY
	sbc hl,de		;
	exx			; ..	(alternate set)
	sbc hl,de		;

	scf			; set CY to shift '1' into
	jr shft_bin		; the partial quotient
endofdiv
	exx			; ..	(alternate set)
	pop hl			; pointer to the next calculator literal
	push bc			; the lower 2 bytes of the mantissa
	exx			; ..	(main set)
	pop de			; D,E = lower 2 bytes of the mantissa

	pop hl			; man1.S * man2.S
	ex (sp),hl		; exp1,exp2
	djnz divbit33		; skip if there were 33 subtractions

	inc l			; else set correction
divbit33
	call norm_res		; shift right and round (if it is necessary)

	cpl			; set correction: -1 ->  0; -2 -> 1
	dec a			;		   0 -> -1;  1 -> 0
	add a,l			; fetch exp2 and add correction
	sub $80			; remove the offset
	jp m_d_exit		; jump to subtract exponents
;
;	========================================================
;
; ----------
; USR number
; ----------
; (offset $29: 'usr-no')
; The USR function followed by a number 0-65535 is the method by which
; the ZX81 invokes machine code programs. This function returns the
; contents of the BC register pair.
; Note. that STACK-BC re-initializes the IY register to $4000 if a user-written
; program has altered it.
;
fn_usr
	CALL FIND_INT		; routine FIND-INT to fetch the
				; supplied address into BC.
	LD HL,STACK_BC		; address: STACK-BC is
	PUSH HL			; pushed onto the machine stack.
	PUSH BC			; then the address of the machine code
				; routine.
	RET			; make an indirect jump to the user's routine
				; and, hopefully, to STACK-BC also.
;
; ---------------------------------------------------------
; THE improved 'INTEGER TRUNCATION TOWARDS ZERO' SUBROUTINE
; ---------------------------------------------------------
; (offset $36: 'truncate')
truncate			; (L18E4)
	LD A,(HL)		; fetch exponent

	add a,$7F		; if abs(number)<1		 (eponent<$81)	
	jp nc,FP_0_1		; then return with zero			(CY=0)

	cp $1F			; return if all 32 bits of the mantissa
	ret nc			; relate to the integer part.	 (eponent>$9f)

	cpl			; else form number of rightmost bits 
	add a,$20		; to be blanked.
;
; for instance, disregarding the sign bit, the number 3.5 is held as 
; exponent $82 mantissa .11100000 00000000 00000000 00000000
; we need to set $82+$7F=$01, CPL=$FE, $FE+$20=$1E(thirty) bits to zero 
; to form the integer. The sign of the number is never considered as the
; first bit of the mantissa must be part of the integer.
;
;; NIL-BYTES
;;L18F4:
	PUSH DE			; save pointer to STKEND
	EX DE,HL		; HL points at STKEND
clr_byte
	dec hl			;
	sub $08			;
	jr c,clr_bits		;

	ld (hl),0		;
	jr clr_byte		;

; now consider any residual bits.
;
clr_bits
	add a,$08		; the remaining bits
	jr z,ix_end		; forward if none to IX-END

	LD B,A			; transfer bit count to B counter.

	sbc a,a			; form a mask 11111111
;
;; LESS-MASK (L190C)
lessMask
	SLA A			; 1 <- 76543210 <- o	slide mask leftwards.
	DJNZ lessMask		; loop back for bit count to LESS-MASK

	AND (HL)		; lose the unwanted rightmost bits
	LD (HL),A		; and place in mantissa byte.
;
;; IX-END (L1912)
ix_end
	EX DE,HL		; restore result pointer from DE. 
	POP DE			; restore STKEND from stack.
	RET 			; return.
;
; ------------------------
; THE 'TABLE OF CONSTANTS'
; ------------------------
;   The ZX81 has only floating-point number representation.
;   Both the ZX80 and the ZX Spectrum have integer numbers in some form.
;   This table has been modified so that the constants are held in their
;   uncompressed, ready-to-party, 5-byte form.
;
TAB_CNST
	DEFB $00	; the value zero.
	DEFB $00	;
	DEFB $00	;
	DEFB $00	;
	DEFB $00	;

	DEFB $81	; the floating point value 1.
	DEFB $00	;
	DEFB $00	;
	DEFB $00	;
	DEFB $00	;

	DEFB $80	; the floating point value 1/2.
	DEFB $00	;
	DEFB $00	;
	DEFB $00	;
	DEFB $00	;

	DEFB $81	; the floating point value pi/2.
	DEFB $49	;
	DEFB $0F	;
	DEFB $DA	;
	DEFB $A2	;

	DEFB $84	; the floating point value ten.
	DEFB $20	;
	DEFB $00	;
	DEFB $00	;
	DEFB $00	;
;
; ------------------------
; THE 'TABLE OF ADDRESSES'
; ------------------------
;
; starts with binary operations which have two operands and one result.
; three pseudo binary operations first.
;
tbl_addrs
	DEFW  jmp_true		; $00 - jump-true
	DEFW  exchange		; $01 - exchange
	DEFW  delete		; $02 - delete
;
;   true binary operations.
;
	DEFW  subtract		; $03 - subtract
	DEFW  multiply		; $04 - multiply
	DEFW  division		; $05 - division
	DEFW  to_power		; $06 - to-power
	DEFW  op_or		; $07 - or

	DEFW  hnd_AND		; $08 - no-&-no
	DEFW  comp_not		; $09 - no-l-eql
	DEFW  comp_not		; $0A - no-gr-eql
	DEFW  comp_not		; $0B - nos-neql
	DEFW  comp_tru		; $0C - no-grtr
	DEFW  comp_tru		; $0D - no-less
	DEFW  comp_tru		; $0E - nos-eql
	DEFW  addition		; $0F - addition

	DEFW  hnd_AND		; $10 - str-&-no
	DEFW  comp_not		; $11 - str-l-eql
	DEFW  comp_not		; $12 - str-gr-eql
	DEFW  comp_not		; $13 - strs-neql
	DEFW  comp_tru		; $14 - str-grtr
	DEFW  comp_tru		; $15 - str-less
	DEFW  comp_tru		; $16 - strs-eql
	DEFW  strs_add		; $17 - strs-add
;
;   unary follow
;
	DEFW  negate		; $18 - neg

	DEFW  fn_code		; $19 - code
	DEFW  fn_val		; $1A - val
	DEFW  fn_len		; $1B - len
	DEFW  fn_sin		; $1C - sin
	DEFW  fn_cos		; $1D - cos
	DEFW  fn_tan		; $1E - tan
	DEFW  fn_asn		; $1F - asn
	DEFW  fn_acs		; $20 - acs
	DEFW  fn_atn		; $21 - atn
	DEFW  fn_ln		; $22 - ln
	DEFW  fn_exp		; $23 - exp
	DEFW  fn_int		; $24 - int
	DEFW  fn_sqr		; $25 - sqr
	DEFW  fn_sgn		; $26 - sgn
	DEFW  fn_abs		; $27 - abs
	DEFW  fn_peek		; $28 - peek
	DEFW  fn_usr		; $29 - usr-no
	DEFW  fn_strS		; $2A - str$
	DEFW  fn_chrS		; $2B - chrs
	DEFW  fn_not		; $2C - not
;
;   end of true unary
;
	DEFW  COPY_FP		; $2D - duplicate
	DEFW  n_mod_m		; $2E - n-mod-m

	DEFW  JUMP		; $2F - jump
	DEFW  stk_data		; $30 - stk-data

	DEFW  dec_jr_nz		; $31 - dec-jr-nz
	DEFW  less_0		; $32 - less-0
	DEFW  greater0		; $33 - greater-0
	DEFW  end_calc		; $34 - end-calc
	DEFW  get_argt		; $35 - get-argt
	DEFW  truncate		; $36 - truncate
	DEFW  fp_calc_2		; $37 - fp-calc-2
	DEFW  e_to_fp		; $38 - e-to-fp
;
;   new macros
;
	.dw sub_one		; $39 macro sub-one (part of 'INT')
	.dw mul_by_2		; $3A macro mul-by-2
	.dw mul_by10		; $3B macro mul-by-10
	.dw stk_squa		; $3C macro stk-square
;
tbl_offs .equ $-tbl_addrs
;
;   the following are just the next available slots for the 128 compound 
;   literals which are in range $80 - $FF.
;
	DEFW  seriesg_x		; series-xx    $80 - $9F.
	DEFW  stk_con_x		; stk-const-xx $A0 - $BF.
	DEFW  sto_mem_x		; st-mem-xx    $C0 - $DF.
	DEFW  get_mem_x		; get-mem-xx   $E0 - $FF.
;
; Aside: 41 - 7F are therefore unused calculator literals.
;	 3D - 7B would be available for expansion.
;
; ----------------------------------------
; THE improved 'FLOATING POINT CALCULATOR'
; ----------------------------------------
;
CALCULATE
	CALL STK_PNTRS		; routine STK-PNTRS is called to set up the
				; calculator stack pointers for a default
				; unary operation. HL = last value on stack.
				; DE = STKEND first location after stack.
;;- GEN_ENT1
	LD A,B			; fetch the Z80 B register to A
;
;   the calculate routine is called at this point by the series generator...
;
GEN_ENT1
	LD ($401E),A		; and store value in system variable BREG.
				; this will be the counter for dec-jr-nz
				; or if used from fp-calc2 the calculator
				; instruction.
;
;   ... and again later at this point
;
GEN_ENT2
	EXX			; switch sets
	EX (SP),HL		; and store the address of next instruction,
				; the return address, in H'L'.
				; If this is a recursive call then the H'L'
				; of the previous invocation goes on stack.
				; c.f. end-calc.
	EXX			; switch back to main set.
;
;   this is the re-entry looping point when handling a string of literals.
;
RE_ENTRY
	LD ($401C),DE		; save end of stack in system variable STKEND
	EXX			; switch to alt
	LD A,(HL)		; get next literal
	INC HL			; increase pointer'
;
;   single operation jumps back to here
;
SCAN_ENT
	PUSH  HL		; save pointer on stack   *
	AND A			; now test the literal
	JP P,FIRST_7F		; forward to FIRST-7F if in range $00 - $7F
				; anything with bit 7 set will be one of
				; 128 compound literals.
;
;   Compound literals have the following format.
;   bit 7 set indicates compound.
;   bits 6-5 the subgroup 0-3.
;   bits 4-0 the embedded parameter $00 - $1F.
;   The subgroup 0-3 needs to be manipulated to form the next available four
;   address places after the simple literals in the address table.
;
	LD D,A			; save literal in D
	AND $60			; and with 01100000 to isolate subgroup
	RRCA			; rotate bits
	RRCA			; 4 places to right
	RRCA			; not five as we need offset * 2
	RRCA			; 00000xx0
	ADD A,tbl_offs		; correct offset.
	LD L,A			; store in L for later indexing.
	LD A,D			; bring back compound literal
	AND $1F			; use mask to isolate parameter bits
	JR ENT_TABLE		; forward to ENT-TABLE
; ---
;
;   the branch was here with simple literals.
;
FIRST_7F
	CP $18			; compare with first unary operations.
	JR NC,DOUBLE_A		; to DOUBLE-A with unary operations
;
;   it is binary so adjust pointers.
;
	EXX			;

	ex de,hl		; transfer HL, the last value, to DE.
	ld hl,$FFFB		; the value -5
	add hl,de		; subtract 5 making HL point to second
				; value.
	EXX			;
DOUBLE_A
	RLCA			; double the literal
	LD L,A			; and store in L for indexing
ENT_TABLE
	LD DE,tbl_addrs		; Address: tbl-addrs
	LD H,$00		; prepare to index
	ADD HL,DE		; add to get address of routine
	LD E,(HL)		; low byte to E
	INC HL			;
	LD D,(HL)		; high byte to D

	LD HL,RE_ENTRY		; Address: RE-ENTRY
	EX (SP),HL		; goes on machine stack
				; address of next literal goes to HL. *

	PUSH DE			; now the address of routine is stacked.
	EXX			; back to main set
				; avoid using IY register.
	LD BC,($401D)		; STKEND_hi
				; nothing much goes to C but BREG to B
				; and continue into next ret instruction
				; which has a dual identity
;
; -----------------------
; THE 'DELETE' SUBROUTINE
; -----------------------
; (offset $02: 'delete')
;   A simple return but when used as a calculator literal this
;   deletes the last value from the calculator stack.
;   On entry, as always with binary operations,
;   HL=first number, DE=second number
;   On exit, HL=result, DE=stkend.
;   So nothing to do
;
delete	RET			; return - indirect jump if from above.
;
; ------------------------------
; THE 'TEST 5 SPACES' SUBROUTINE
; ------------------------------
;   This routine is called from COPY-FP, STK-CONST and STK-STORE to
;   test that there is enough space between the calculator stack and the
;   machine stack for another five-byte value. It returns with BC holding
;   the value 5 ready for any subsequent LDIR.
;
TEST_5_SP
	PUSH DE			; save
	PUSH HL			; registers
	LD BC,$0005		; an overhead of five bytes
	CALL TEST_ROOM		; routine TEST-ROOM tests free RAM raising
				; an error if not.
	POP HL			; else restore
	POP DE			; registers.
	RET			; return with BC set at 5.
;
; ---------------------------------------------
; THE 'COPY A FLOATING POINT NUMBER' SUBROUTINE
; ---------------------------------------------
; offset $2D: 'duplicate'
;   This simple routine is a 5-byte LDIR instruction
;   that incorporates a memory check.
;   When used as a calculator literal it duplicates the last value on the
;   calculator stack.
;   Unary so on entry HL points to last value, DE to stkend
;
COPY_FP
	CALL TEST_5_SP		; routine TEST-5-SP test free memory
				; and sets BC to 5.
	LDIR			; copy the five bytes.
	RET			; return with DE addressing new STKEND
				; and HL addressing new last value.
;
; -------------------------------
; THE 'STACK LITERALS' SUBROUTINE
; -------------------------------
; offset $30: 'stk-data'
;   When a calculator subroutine needs to put a value on the calculator
;   stack that is not a regular constant this routine is called with a
;   variable number of following data bytes that convey to the routine
;   the floating point form as succinctly as is possible.
;
stk_data
	LD H,D			; transfer STKEND
	LD L,E			; to HL for result.
STK_CONST
	CALL TEST_5_SP		; routine TEST-5-SP tests that room exists
				; and sets BC to $05.
	EXX			; switch to alternate set
	PUSH HL			; save the pointer to next literal on stack
	EXX			; switch back to main set

	EX (SP),HL		; pointer to HL, destination to stack.

	LD A,(HL)		; fetch the byte following 'stk-data'
	AND $C0			; isolate bits 7 and 6
	RLCA			; rotate
	RLCA			; to bits 1 and 0  range $00 - $03.
	LD C,A			; transfer to C
	INC C			; and increment to give number of bytes
				; to read. $01 - $04
	LD A,(HL)		; reload the first byte
	AND $3F			; mask off to give possible exponent.
	JR NZ,FORM_EXP		; forward to FORM-EXP if it was possible to
				; include the exponent.
;
; else byte is just a byte count and exponent comes next.
;
	INC HL			; address next byte and
	LD A,(HL)		; pick up the exponent ( - $50).
FORM_EXP
	ADD A,$50		; now add $50 to form actual exponent
	LD (DE),A		; and load into first destination byte.
	LD A,$05		; load accumulator with $05 and
	SUB C			; subtract C to give count of trailing
				; zeros plus one.
	INC HL			; increment source
	INC DE			; increment destination
	LDIR			; copy C bytes

	EX (SP),HL		; put HL on stack as next literal pointer
				; and the stack value - result pointer -
				; to HL.
	EXX			; switch to alternate set.
	POP HL			; restore next literal pointer from stack
				; to H'L'.
	EXX			; switch back to main set.

	LD B,A			; zero count to B
	XOR A			; clear accumulator
STK_ZEROS
	DEC B			; decrement B counter
	RET Z			; return if zero.		>>
				; DE points to new STKEND
				; HL to new number.

	LD (DE),A		; else load zero to destination
	INC DE			; increase destination
	JR STK_ZEROS		; loop back to STK-ZEROS until done.
;
; -------------------------------------
; THE 'GET FROM MEMORY AREA' SUBROUTINE
; -------------------------------------
; offsets $E0 to $FF: 'get-mem-0', 'get-mem-1' etc.
; A holds $00-$1F offset.
; The calculator stack increases by 5 bytes.
; Note. first two instructions have been swapped to create a subroutine.
;
get_mem_x
	LD HL,($401F)		; MEM is base address of the memory cells.
INDEX_5
	PUSH DE			; save STKEND

	CALL LOC_MEM		; routine LOC-MEM so that HL = first byte
	CALL COPY_FP		; routine COPY-FP moves 5 bytes with memory check.
				; DE now points to new STKEND.
;
;	-----------------------------------------------------------------------
;	also string comparisons join here to clear stack then return
cmp_nequ
	POP HL			; the original STKEND is now RESULT pointer.
	RET			; return.
;
; ---------------------------------
; THE 'STACK A CONSTANT' SUBROUTINE
; ---------------------------------
; (offset $A0: 'stk-zero')
; (offset $A1: 'stk-one')
; (offset $A2: 'stk-half')
; (offset $A3: 'stk-pi/2')
; (offset $A4: 'stk-ten')
; This routine allows a one-byte instruction to stack up to 32 constants
; held in short form in a table of constants. In fact only 5 constants are
; required. On entry the A register holds the literal ANDed with $1F.
;
; It wasn't very efficient and it is better to hold the
; numbers in full, five byte form and stack them in a similar manner
; to that which which is used by the above routine.
;
stk_con_x
	LD HL,TAB_CNST		; Address: Table of constants.
	JR INDEX_5		; and join subsroutine above.
;
; ---------------------------------------
; THE 'STORE IN A MEMORY AREA' SUBROUTINE
; ---------------------------------------
; Offsets $C0 to $DF: 'st-mem-0', 'st-mem-1' etc.
; Although 32 memory storage locations can be addressed, only six
; $C0 to $C5 are required by the ROM and only the thirty bytes (6*5)
; required for these are allocated. ZX81 programmers who wish to
; use the floating point routines from assembly language may wish to
; alter the system variable MEM to point to 160 bytes of RAM to have
; use the full range available.
; A holds derived offset $00-$1F.
; Unary so on entry HL points to last value, DE to STKEND.
;
sto_mem_x
	PUSH HL			; save the result pointer.
	EX DE,HL		; transfer to DE.
	LD HL,($401F)		; fetch MEM the base of memory area.
	CALL LOC_MEM		; routine LOC-MEM sets HL to the destination.
	EX DE,HL		; swap - HL is start, DE is destination.

	LD C,$05		;+ one extra byte but 
	LDIR			;+ faster and no memory check.

	EX DE,HL		; DE = STKEND
	POP HL			; restore original result pointer
	RET 			; return.
;
; ------------------------------------------
; THE improved 'SERIES GENERATOR' SUBROUTINE
; ------------------------------------------
; offset $86: 'series-06'
; offset $88: 'series-08'
; offset $8C: 'series-0C'
; The ZX81 uses Chebyshev polynomials to generate approximations for
; SIN, ATN, LN and EXP. These are named after the Russian mathematician
; Pafnuty Chebyshev, born in 1821, who did much pioneering work on numerical
; series. As far as calculators are concerned, Chebyshev polynomials have an
; advantage over other series, for example the Taylor series, as they can
; reach an approximation in just six iterations for SIN, eight for EXP and
; twelve for LN and ATN. The mechanics of the routine are interesting but
; for full treatment of how these are generated with demonstrations in
; Sinclair BASIC see "The Complete Spectrum ROM Disassembly" by Dr Ian Logan
; and Dr Frank O'Hara, published 1983 by Melbourne House.
;
seriesg_x
;
	CALL GEN_ENT1		; routine GEN-ENT-1 is called.
				; A recursive call to a special entry point
				; in the calculator that puts the B register
				; in the system variable BREG. The return
				; address is the next location and where
				; the calculator will expect its first
				; instruction - now pointed to by HL'.
				; The previous pointer to the series of
				; five-byte numbers goes on the machine stack.
;
; The initialization phase.
;
	.db $3A		;;mul-by-2		2*x

	DEFB $C0	;;st-mem-0		2*x
	DEFB $02	;;delete		.
	DEFB $A0	;;stk-zero		0

	.db $C1		;;st-mem-1		0
	.db $2D		;;duplicate		0,0.

	.db $2F		;;jump
	.db G_LOOP1-$	;;to G-LOOP1	- skip the 1st round
;
; a loop is now entered to perform the algebraic calculation for each of
; the numbers in the series
;
G_LOOP
	DEFB $2D	;;duplicate		v,v.
	DEFB $E0	;;get-mem-0		v,v,2*x
	DEFB $04	;;multiply		v,v*2*x
	DEFB $E2	;;get-mem-2		v,v*2*x,v
	DEFB $C1	;;st-mem-1		v,v*2*x,v
	DEFB $03	;;subtract		v,v*2*x-v
G_LOOP1
	DEFB $34	;;end-calc
;
; the previous pointer is fetched from the machine stack to H'L' where it
; addresses one of the numbers of the series following the series literal.
;
	CALL stk_data		; routine STK-DATA is called directly to
				; push a value and advance H'L'.
	CALL GEN_ENT2		; routine GEN-ENT-2 recursively re-enters
				; the calculator without disturbing
				; system variable BREG
				; H'L' value goes on the machine stack and is
				; then loaded as usual with the next address.

	DEFB $0F	;;addition
	DEFB $01	;;exchange
	DEFB $C2	;;st-mem-2
	DEFB $02	;;delete

	DEFB $31	;;dec-jr-nz
	DEFB G_LOOP-$	;;back to G-LOOP

; when the counted loop is complete the final subtraction yields the result
; for example SIN X.

	DEFB $E1	;;get-mem-1
	DEFB $03	;;subtract
	DEFB $34	;;end-calc

	RET			; return with H'L' pointing to location
				; after last number in series.
;
; -----------------------
; Handle unary minus (18)
; -----------------------
; Unary so on entry HL points to last value, DE to STKEND.
;
negate
	LD A,(HL)		; fetch exponent of last value on the
				; calculator stack.
	AND A			; test it.
	RET Z			; return if zero.
negate_1
	INC HL			; address the byte with the sign bit.
	LD A,(HL)		; fetch to accumulator.
	XOR $80			; toggle the sign bit.
	LD (HL),A		; put it back.
	DEC HL			; point to last value again.
	RET			; return.
;
; ---------------
; new Signum (26)
; ---------------
; This routine replaces the last value on the calculator stack,
; (which is in floating point form), with one if positive and with minus one
; if it is negative. If it is zero then it is left unchanged.
;
fn_sgn
	ld a,(hl)		; fetch exponent of last value on the stack
	and a			; test it.
	ret z			; return if zero.

	call greater1		; if >0 then CY=1 
	ret c			; and return value=1

	ld (hl),$81		; else make value 1
	jr negate_1		; and return via 'unary minus'
;
; -----------------------
; Greater than zero ($33)
; -----------------------
; Test if the last value on the calculator stack is greater than zero.
; This routine is also called directly from the end-tests of the comparison
; routine.
;
greater0
	LD A,(HL)		; fetch exponent.
	AND A			; test it for zero.
	RET Z			; return if so.
greater1
	LD A,$FF		; prepare XOR mask for sign bit
	JR SGN_TO_C		; forward to SIGN-TO-C
				; to put sign in carry
				; (carry will become set if sign is positive)
				; and then overwrite location with 1 or 0
				; as appropriate.
;
;	=======================================================================
;	the new entry point to perform '<=', '>=', '<>' operations, which end
;	with a 'NOT' operation
comp_not
	dec b			; correct the calculator literal in B
	call comp_tru		; then perform the comparison ...
;
;	=======================================================================
;
; ------------------------
; Handle NOT operator ($2C)
; ------------------------
; This overwrites the last value with 1 if it was zero else with zero
; if it was any other value.
;
; e.g. NOT 0 returns 1, NOT 1 returns 0, NOT -3 returns 0.
;
; The subroutine is also called directly from the end-tests of the comparison
; operator.
;
fn_not
	LD A,(HL)		; get exponent byte.
fn_not1
	NEG			; negate - sets carry if non-zero.
fn_not2
	CCF			; complement so carry set if zero, else reset.
	JR FP_0_1		; forward to FP-0/1.
;
; -------------------
; Less than zero (32)
; -------------------
; Destructively test if last value on calculator stack is less than zero.
; Bit 7 of second byte will be set if so.
;
less_0
	XOR A			; set xor mask to zero
				; (carry will become set if sign is negative).
;
; transfer sign of mantissa to Carry Flag.
;
SGN_TO_C
	INC HL			; address 2nd byte.
	XOR (HL)		; bit 7 of HL will be set if number is negative.
	DEC HL			; address 1st byte again.
	RLCA			; rotate bit 7 of A to carry.
;
; -----------
; Zero or one
; -----------
; This routine places an integer value zero or one at the addressed location
; of calculator stack or MEM area. The value one is written if carry is set on
; entry else zero.
;
FP_0_1
	PUSH  HL		; save pointer to the first byte
	LD B,$05		; five bytes to do.
FP_loop
	LD (HL),$00		; insert a zero.
	INC HL			;
	DJNZ FP_loop		; repeat.

	POP HL			;
	RET NC			;

	LD (HL),$81		; make value 1
	RET			; return.
;
; -----------------------
; Handle OR operator (07)
; -----------------------
; The Boolean OR operator. eg. X OR Y
; The result is zero if both values are zero else a non-zero value.
;
; e.g.	 0 OR  0	returns  0.
;	-3 OR  0	returns -3.
;	 0 OR -3	returns  1.
;	-3 OR  2	returns  1.
;
; A binary operation.
; On entry HL points to first operand (X) and DE to second operand (Y).
;
op_or	LD A,(DE)		; fetch exponent of second number
	AND  A			; test it.
	RET Z			; return if zero.
op_or_1
	SCF			; set carry flag
	JR FP_0_1		; back to FP-0/1 to overwrite the first operand
				; with the value 1.
;
;	=======================================================================
;	Handle AND
;
; ---------------------------------
; new Handle string AND number (10)
; ---------------------------------
; e.g. "YOU WIN" AND SCORE>99 will return the string if condition is true
; or the null string if false.
;
; ---------------------------------
; old Handle number AND number (08)
; ---------------------------------
; The Boolean AND operator.
;
; e.g.	-3 AND  2	returns -3.
;	-3 AND  0	returns  0.
;	 0 and -2	returns  0.
;	 0 and  0	returns  0.
;
; Compare with OR routine above.
;
hnd_AND
	LD A,(DE)		; fetch exponent of second number.
	AND A			; test it.
	RET NZ			; return if not zero.

	JR FP_0_1		; back to FP-0/1 to overwrite the first operand
				; with zero for return value.
;
;	=======================================================================
;
; -------------------------------------
; Perform comparison ($09-$0E, $11-$16)
; -------------------------------------
; True binary operations.
;
; This entry point is used to evaluate three numeric and three string
; comparisons. On entry, the calculator literal is in the B register and
; the two numeric values, or the two string parameters, are on the
; calculator stack.
; The individual bits of the literal are used to group similar operations.
;
;
; literal    Test   No bin       comp_not      bit 5?   End-Tests
; =========  ====   == ========  === ========= ======== =========
; no-l-eql   x<=y   09 00001001  dec 0000 1000 comp_num --- > NOT
; no-gr-eql  x>=y   0A 00001010  dec 0000 1001 comp_num --- > NOT
; nos-neql   x<>y   0B 00001011  dec 0000 1010 comp_num --- > NOT
;
; no-grtr    x>y    0C 00001100   -  0000 1100 comp_num --- > ---
; no-less    x<y    0D 00001101   -  0000 1101 comp_num --- > ---
; nos-eql    x=y    0E 00001110   -  0000 1110 comp_num --- > ---
;
;
; str-l-eql  x$<=y$ 11 00010001  dec 0001 0000 comp_str --- > NOT
; str-gr-eql x$>=y$ 12 00010010  dec 0001 0001 comp_str --- > NOT
; strs-neql  x$<>y$ 13 00010011  dec 0001 0010 comp_str --- > NOT
;
; str-grtr   x$>y$  14 00010100   -  0001 0100 comp_str --- > ---
; str-less   x$<y$  15 00010101   -  0001 0101 comp_str --- > ---
; strs-eql   x$=y$  16 00010110   -  0001 0110 comp_str --- > ---
;
comp_tru
	push bc			; save calculator literal
	push de			; save pointer to operand2
	push hl			; save pointer to operand1

				; if operand1 < operand2 then Z=0, CY=0
	call compare		; if operand1 = operand2 then Z=1, CY=0
				; if operand1 > operand2 then Z=0, CY=1

	pop hl			; restore pointer to operand2
	pop de			; restore pointer to operand1
	pop bc			; restore calculator literal

	jr z,comp_equ		; jump if operands are equal

	jr c,comp_op1		; jump if operand1 > operand2

	bit 0,b			;
				; condition
	jr z,FP_0_1		; op1>op2 or op1=op2	(CY=0 -> place '0')
	jr fn_not2		; op1<op2		(CY=1 -> place '1')
;
;	-----------------------------------------------------------------------
comp_op1
	ld a,$03		; set mask '000000xx'
	and b			; (clears CY!)
				; condition
	jr nz,FP_0_1		; op1<op2 or op1=op2	(CY=0 -> place '0')
	jr fn_not2		; op1>op2		(CY=1 -> place '1')
;
;	-----------------------------------------------------------------------
comp_equ
	bit 1,b			;
				; condition
	jr nz,op_or_1		; op1=op2		(CY=1 -> place '1')
	jr FP_0_1		; op1<>op2		(CY=0 -> place '0')
;
;	=======================================================================
compare
	bit 4,b			; bit 4 selects strings as operands
	jr z,comp_num		; else compare numbers
;
;	-----------------------------------------------------------------------
;	String comparisons:
;	--------------------
;
	call STK_FETCH		; routine STK-FETCH gets 2nd string's params
	push de			; save start2 *.
	push bc			; and the length2.

	call STK_FETCH		; routine STK-FETCH gets 1st string's
				; parameters - start in DE, length in BC.
	pop hl			; restore length of second to HL.
	and a			; clear CY
	sbc hl,bc		; compare

	jr nc,cplen_eq		; jump, if len1<=len2

	add hl,bc		; restore length2
	ld b,h			; and set counter
	ld c,l			; of comparision
cplen_eq
	pop hl			; restore start2 to HL.
	jr z,comp_neg		; if the lengths are equal compare byte by byte

	push af			; save flags (Z=0 and CY=1, if len1>len2)
	call comp_neg		; compare byte by byte
	jp nz,cmp_nequ		; jump if parts are different

	pop af			; else restore flags
	ret			; CY=1 if 1st string is longer
;
;	-----------------------------------------------------------------------
;	Numeric Comparisons:
;	--------------------
comp_num
	ld bc,5			; the size of a floating point number (5 bytes)
	inc hl			; points the MSB of the 1st mantissa
	inc de			; points the MSB of the 2nd mantissa
	ld a,(de)		; compare the
	xor (hl)		; sign bits
	rla			; CY=1 if they are different
	ld a,(de)		; MSB of the 2nd mantissa (A7=sign bit)
	dec de			; restore the
	dec hl			; pointers

	jr nc,comp_pos		; if signs are equals then compare byte by byte

	rla			; else set CY if the 2nd number is negative
	ret			; and return
comp_pos
	rla			; if signs are positive
	jr nc,comp_nxt		; then continue with byte by byte comparision
comp_neg
	ex de,hl		; else swap pointers
comp_tst
	ld a,b			; test byte counter
	or c			; if it is zero (CY=0 and Z=1)
	ret z			; then end of comparision
comp_nxt
	ld a,(de)		; compare byte
	cp (hl)			; by byte
	ret nz			; return if they are different

	inc hl			; set pointers
	inc de			; 
	dec bc			; and the byte counter
	jr comp_tst		; 

;
;	=======================================================================
;
; -----------------------------------
; THE 'STRING CONCATENATION' OPERATOR
; -----------------------------------
; (offset $17: 'strs_add')
; This literal combines two strings into one e.g. LET A$ = B$ + C$
; The two parameters of the two strings to be combined are on the stack.
;
strs_add
	CALL STK_FETCH		; routine STK-FETCH fetches string parameters
				; and deletes calculator stack entry.
	PUSH DE			; save start address.
	PUSH BC			; and length.

	CALL STK_FETCH		; routine STK-FETCH for first string
	POP HL			; re-fetch first length
	PUSH HL			; and save again
	PUSH DE			; save start of second string
	PUSH BC			; and its length.

	ADD HL,BC		; add the two lengths.
	LD B,H			; transfer to BC
	LD C,L			; and create
	RST 30H			; BC-SPACES in workspace.
				; DE points to start of space.

	CALL STK_ST_s		; routine STK-STO-$ stores parameters
				; of new string updating STKEND.

	POP BC			; length of first
	POP HL			; address of start

	CALL COND_MV		;+ a conditional (NZ) ldir routine. 

OTHER_STR
	POP BC			; now second length
	POP HL			; and start of string

	CALL COND_MV		;+ a conditional (NZ) ldir routine. 
;
;   Continue into next routine which sets the calculator stack pointers.
;
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

	ex de,hl		; switch pointers
	ld hl,$FFFB		; the value -5

	add hl,de		; HL = STKEND - 5
	ret 			; return.
;
; ------------------
; THE 'VAL' FUNCTION
; ------------------
; (offset $1A: 'val')
;   VAL treats the characters in a string as a numeric expression.
;   e.g. VAL "2.3" = 2.3, VAL "2+4" = 6, VAL ("2" + "4") = 24.
;
fn_val
	RST 18H			;+ shorter way to fetch CH_ADD.
	PUSH HL			; and save on the machine stack.

	CALL STK_FETCH		; routine STK-FETCH fetches the string operand
				; from calculator stack.

	PUSH DE			; save the address of the start of the string.
	INC BC			; increment the length for a carriage return.

	RST 30H			; BC-SPACES creates the space in workspace.
	POP HL			; restore start of string to HL.
	LD ($4016),DE		; load CH_ADD with start DE in workspace.

	PUSH DE			; save the start in workspace
	LDIR			; copy string from program or variables or
				; workspace to the workspace area.
	EX DE,HL		; end of string + 1 to HL
	DEC HL			; decrement HL to point to end of new area.
	LD (HL),$76		; insert a carriage return at end.
				; ZX81 has a non-ASCII character set
	RES 7,(IY+$01)		; update FLAGS  - signal checking syntax.
	CALL CLASS_06		; routine CLASS-06 - SCANNING evaluates string
				; expression and checks for integer result.

	CALL CHECK_2		; routine CHECK-2 checks for carriage return.

	POP HL			; restore start of string in workspace.

	LD ($4016),HL		; set CH_ADD to the start of the string again.
	SET 7,(IY+$01)		; update FLAGS  - signal running program.
	CALL SCANNING		; routine SCANNING evaluates the string
				; in full leaving result on calculator stack.

	POP HL			; restore saved character address in program.
	LD ($4016),HL		; and reset the system variable CH_ADD.

	JR STK_PNTRS		; back to exit via STK-PNTRS.
				; resetting the calculator stack pointers
				; HL and DE from STKEND as it wasn't possible
				; to preserve them during this routine.
;
; --------------------
; THE 'LEN' SUBROUTINE
; --------------------
; (offset $1b: 'len')
; Returns the length of a string.
; In Sinclair BASIC strings can be more than twenty thousand characters long
; so a sixteen-bit register is required to store the length
;
fn_len
	CALL STK_FETCH		; routine STK-FETCH to fetch and delete the
				; string parameters from the calculator stack.
				; register BC now holds the length of string.

	JP STACK_BC		; jump back to STACK-BC to save result on the
				; calculator stack (with memory check).
;
; -----------------------------------------
; THE improved 'TO POWER' OPERATION (cont.)
; -----------------------------------------
; X_IS_0
to_pwr_0
	ex de,hl		; else switch pointers
	inc hl			; 
	bit 7,(hl)		; test if Y is negative
	dec hl			; 
	ld a,(hl)		; fetch Y.exp
	ex de,hl		; switch back pointers
	jp z,fn_not1		; jump if it is positive or zero to
				; replace X with 1 (Y=0) or 0 (Y>0)
; ---
	rst 08h			; else Error Report:
	.db $05			; arithmetic overflow
;
; ---------------------------------
; THE improved 'TO POWER' OPERATION
; ---------------------------------
; (Offset $06: 'to-power')
;   The 'Exponential' operation.
;   This raises the first number X to the power of the second number Y.
;   e.g. PRINT 2 ** 3 gives the result 8
;   As with the ZX80,
;   0 ** 0 = 1
;   0 ** +n = 0
;   0 ** -n = arithmetic overflow.

to_power			; HL points X, DE points Y.
	ld a,(hl)		; fetch X.exp
	and a			; test zero
	jr z,to_pwr_0		; continue if X<>0
;
;   X is non-zero. function 'ln' will catch a negative value of X.
;
	rst 28h		;; FP-CALC		X,Y.
	.db $01		;;exchange		Y, X.
	.db $22		;;ln			Y, LN X.
;
;   Multiply the power by the logarithm of the argument.
;
	.db $04		;;multiply		Y * LN X
	.db $34		;;end-calc
;
;   Then find the 'antiln'
;
; -----------------------------------
; THE improved 'EXPONENTIAL' FUNCTION
; -----------------------------------
; (Offset $23: 'exp')
;   The exponential function returns the exponential of the argument, or the
;   value of 'e' (2.7182818...) raised to the power of the argument.
;   PRINT EXP 1 gives 2.7182818
;
;   EXP is the opposite of the LN function (see below) and is equivalent to 
;   the 'antiln' function found on pocket calculators or the 'Inverse ln'
;   function found on the Windows scientific calculator.
;   So PRINT EXP LN 5.3 will give 5.3 as will PRINT LN EXP 5.3 or indeed
;   any number e.g. PRINT EXP LN PI.
;
;   The applications of the exponential function are in areas where exponential
;   growth is experienced, calculus, population growth and compound interest.
;
;   Error 6 if the argument is above 88.
;
fn_exp
	RST 28H		;; FP-CALC
	DEFB $30	;;stk-data			1/LN 2
	DEFB $F1	;;Exponent: $81, Bytes: 4
	DEFB $38,$AA,$3B,$29 ;;
	DEFB $04	;;multiply
	DEFB $2D	;;duplicate
	DEFB $24	;;int
	DEFB $C3	;;st-mem-3
	DEFB $03	;;subtract

	.db $3A		;;mul-by-2			*2
	.db $39		;;sub-one macro			-1

	DEFB $88	;;series-08
	DEFB $13	;;Exponent: $63, Bytes: 1
	DEFB $36	;;(+00,+00,+00)
	DEFB $58	;;Exponent: $68, Bytes: 2
	DEFB $65,$66	;;(+00,+00)
	DEFB $9D	;;Exponent: $6D, Bytes: 3
	DEFB $78,$65,$40 ;;(+00)
	DEFB $A2	;;Exponent: $72, Bytes: 3
	DEFB $60,$32,$C9 ;;(+00)
	DEFB $E7	;;Exponent: $77, Bytes: 4
	DEFB $21,$F7,$AF,$24 ;;
	DEFB $EB	;;Exponent: $7B, Bytes: 4
	DEFB $2F,$B0,$B0,$14 ;;
	DEFB $EE	;;Exponent: $7E, Bytes: 4
	DEFB $7E,$BB,$94,$58 ;;
	DEFB $F1	;;Exponent: $81, Bytes: 4
	DEFB $3A,$7E,$F8,$CF ;;

	DEFB $E3	;;get-mem-3
	DEFB $34	;;end-calc

	CALL FP_TO_A		; routine FP-TO-A
	JR NZ,N_NEGTV		; to N-NEGTV

	JR C,REPORT_6b		; to REPORT-6b

	ADD A,(HL)		;
	JR NC,RESULT_OK		; to RESULT-OK
;
REPORT_6b
	RST 08H			; ERROR-1
	DEFB $05		; Error Report: Number too big
;
N_NEGTV
	jp c,fn_not2		; return via FP-0/1 to replace last value with zero

	SUB (HL)		;
	jp nc,FP_0_1		; return via FP-0/1 to replace last value with zero

	NEG			; Negate
;
RESULT_OK
	LD (HL),A		;
	RET			; return.
;
; -------------------
; THE 'CHR$' FUNCTION
; -------------------
; (offset $2B: 'chr$')
;   This function returns a single character string that is a result of
;   converting a number in the range 0-255 to a string e.g. CHR$ 38 = "A".
;   Note. the ZX81 does not have an ASCII character set.
;
fn_chrS
	CALL FP_TO_A		; routine FP-TO-A puts the number in A.
	JR C,REPORT_Bd		; forward to REPORT-Bd if overflow

	JR NZ,REPORT_Bd		; forward to REPORT-Bd if negative

	LD BC,$0001		; one space required.
	RST 30H			; BC-SPACES makes DE point to start

	LD (DE),A		; and store in workspace

	JR str_STK		;+ relative jump to similar sequence in str$.
;
; -------------------
; THE 'STR$' FUNCTION
; -------------------
; (offset $2A: 'str$')
; This function returns a string representation of a numeric argument.
; The method used is to trick the PRINT-FP routine into thinking it
; is writing to a collapsed display file when in fact it is writing to
; string workspace.
; If there is already a newline at the intended print position and the
; column count has not been reduced to zero then the print routine
; assumes that there is only 1K of RAM and the screen memory, like the rest
; of dynamic memory, expands as necessary using calls to the ONE-SPACE
; routine. The screen is character-mapped not bit-mapped.
;
fn_strS
	LD BC,$0001		; create an initial byte in workspace
	RST 30H			; using BC-SPACES restart.

	LD (HL),$76		; place a carriage return there.

	LD HL,($4039)		; fetch value of S_POSN column/line
	PUSH HL			; and preserve on stack.

	LD L,$FF		; make column value high to create a
				; contrived buffer of length 254.
	LD ($4039),HL		; and store in system variable S_POSN.

	LD HL,($400E)		; fetch value of DF_CC
	PUSH HL			; and preserve on stack also.

	LD ($400E),DE		; now set DF_CC which normally addresses
				; somewhere in the display file to the start
				; of workspace.
	PUSH DE			; save the start of new string.

	CALL PRINT_FP		; routine PRINT-FP.

	POP DE			; retrieve start of string.

	LD HL,($400E)		; fetch end of string from DF_CC.
	AND A			; prepare for true subtraction.
	SBC  HL,DE		; subtract to give length.

	LD B,H			; and transfer to the BC
	LD C,L			; register.

	POP HL			; restore original
	LD ($400E),HL		; DF_CC value

	POP HL			; restore original
	LD ($4039),HL		; S_POSN values.
;
;   New entry-point to exploit similarities and save 3 bytes of code.
;
str_STK
	CALL STK_ST_s		; routine STK-STO-$ stores the string
				; descriptor on the calculator stack.

	EX DE,HL		; HL = last value, DE = STKEND.
	RET			; return.
;
; -------------------
; THE 'CODE' FUNCTION
; -------------------
; (offset $19: 'code')
; Returns the code of a character or first character of a string
; e.g. CODE "AARDVARK" = 38  (not 65 as the ZX81 does not have an ASCII
; character set).
;
fn_code
	CALL STK_FETCH		; routine STK-FETCH to fetch and delete the
				; string parameters.
				; DE points to the start, BC holds the length.
	LD A,B			; test length
	OR C			; of the string.
	JR Z,STK_CODE		; skip to STK-CODE with zero if the null string.

	LD A,(DE)		; else fetch the first character.
STK_CODE
	JP STACK_A		; jump back to STACK-A (with memory check)
;
; -------------------------
; THE 'EXCHANGE' SUBROUTINE
; -------------------------
; offset $01: 'exchange'
; This routine exchanges the last two values on the calculator stack
; On entry, as always with binary operations,
; HL=first number, DE=second number
; On exit, HL=result, DE=stkend.
;
exchange
	LD B,$05		; there are five bytes to be swapped
;
; start of loop.
;
SWAP_BYTE
	LD A,(DE)		; each byte of second
	LD C,A			;+
	LD A,(HL)		;+ each byte of first
	LD (DE),A		; store each byte of first
	LD (HL),C		; store each byte of second
	INC HL			; advance both
	INC DE			; pointers.
	DJNZ SWAP_BYTE		; loop back to SWAP-BYTE until all 5 done.

	RET			; return.
;
; -------------------------------------
; THE 'DECREASE THE COUNTER' SUBROUTINE
; -------------------------------------
; (offset $31: 'dec-jr-nz')
; The calculator has an instruction that decrements a single-byte
; pseudo-register and makes consequential relative jumps just like
; the Z80's DJNZ instruction.
;
dec_jr_nz
	EXX			; switch in set that addresses code

	PUSH HL			; save pointer to offset byte
	LD HL,$401E		; address BREG in system variables
	DEC (HL)		; decrement it
	POP HL			; restore pointer
jmp_tru1
	JR NZ,JUMP_2		; to JUMP-2 if not zero

	INC HL			; step past the jump length.
	EXX			; switch in the main set.
	RET			; return.
;
; Note. as a general rule the calculator avoids using the IY register
; otherwise the cumbersome 4 instructions in the middle could be replaced by
; dec (iy+$xx) - using three instruction bytes instead of six.
;
;
; ---------------------
; THE 'JUMP' SUBROUTINE
; ---------------------
; (Offset $2F; 'jump')
; This enables the calculator to perform relative jumps just like
; the Z80 chip's JR instruction.
; This is one of the few routines that was polished for the ZX Spectrum.
;
JUMP
	EXX			; switch in pointer set
JUMP_2
	LD E,(HL)		; the jump byte 0-127 forward, 128-255 back.

	LD A,E			;+
	RLA			;+
	SBC A,A			;+
JUMP_3
	LD D,A			; transfer to high byte.
	ADD HL,DE		; advance calculator pointer forward or back.

	EXX			; switch out pointer set.
	RET			; return.
;
; -----------------------------
; THE 'JUMP ON TRUE' SUBROUTINE
; -----------------------------
; (Offset $00; 'jump-true')
; This enables the calculator to perform conditional relative jumps
; dependent on whether the last test gave a true result
; On the ZX81, the exponent will be zero for zero or else $81 for one.
;
jmp_true
	LD A,(DE)		; collect exponent byte
	AND A			; is result 0 or 1 ?
	EXX			; switch in the pointer set.

	jr jmp_tru1		; back to JUMP if true (1).
;
; ------------------------
; THE 'MODULUS' SUBROUTINE
; ------------------------
; ( Offset $2E: 'n-mod-m' )
; ( i1, i2 -- i3, i4 )
; The subroutine calculate N mod M where M is the positive integer, the
; 'last value' on the calculator stack and N is the integer beneath.
; The subroutine returns the integer quotient as the last value and the
; remainder as the value beneath.
; e.g.    17 MOD 3 = 5 remainder 2
; It is invoked during the calculation of a random number and also by
; the PRINT-FP routine.
;
n_mod_m
	RST 28H		;; FP-CALC		17, 3.
	DEFB $C0	;;st-mem-0		17, 3.
	DEFB $02	;;delete		17.
	DEFB $2D	;;duplicate		17, 17.
	DEFB $E0	;;get-mem-0		17, 17, 3.
	DEFB $05	;;division		17, 17/3.
	DEFB $24	;;int			17, 5.
	DEFB $E0	;;get-mem-0		17, 5, 3.
	DEFB $01	;;exchange		17, 3, 5.
	DEFB $C0	;;st-mem-0		17, 3, 5.
	DEFB $04	;;multiply		17, 15.
	DEFB $03	;;subtract		2.
	DEFB $E0	;;get-mem-0		2, 5.
	DEFB $34	;;end-calc		2, 5.

	RET			; return.
;
; --------------------------
;
REPORT_Bd
	RST 08H			; ERROR-1
	DEFB $0A		; Error Report: Integer out of range
;
; --------------------------
; THE new 'INTEGER' FUNCTION
; --------------------------
; (offset $24: 'int')
; This function returns the integer of x, which is just the same as truncate
; for positive numbers. The truncate literal truncates negative numbers
; upwards so that -3.4 gives -3 whereas the BASIC INT function has to
; truncate negative numbers down so that INT -3.4 is -4.
;
fn_int
	push hl			; save pointer to 'X'
	call COPY_FP		; duplicate

	ex de,hl		; DE now points the duplication
	pop hl			; HL now points 'X' again

	call truncate		; truncation towards zero

	push hl			; save pointer to the truncated 'X'
	push de			; save pointer to the duplication

	call comp_num		; copmpare truncated 'X' to the duplication

	pop de			; DE now points end of the duplication
	pop hl			; HL now points 'X' again

	ret z			; return if 'X' was an integer or	

	ret nc			; return if 'X' was positive or zero
;				  else...
; ---------------------------
; THE 'SUBTRACT ONE' FUNCTION
; ---------------------------
; (Offset $39: 'sub-one')
; this part is a new 'macro', which replaces the next 2 calc. literals
;
;	$A1  :  stk-one
;	$03  :  subtract
;
sub_one
	push hl			; save pointer to 'X'

	ld a,$01		; stack 'ONE'
	call stk_con_x		;

	ex de,hl		; DE now points 'ONE'
	pop hl			; HL now points 'X' again

	jp subtract		; return w. X=X-1
;
; -----------------------------------------
; THE improved 'NATURAL LOGARITHM' FUNCTION
; -----------------------------------------
; (offset $22: 'ln')
;   Like the ZX81 itself, 'natural' logarithms came from Scotland.
;   They were devised in 1614 by well-traveled Scotsman John Napier who noted
;   "Nothing doth more molest and hinder calculators than the multiplications,
;    divisions, square and cubical extractions of great numbers".
;   Napier's logarithms enabled the above operations to be accomplished by 
;   simple addition and subtraction simplifying the navigational and 
;   astronomical calculations which beset his age.
;   Napier's logarithms were quickly overtaken by logarithms to the base 10
;   devised, in conjunction with Napier, by Henry Briggs a Cambridge-educated 
;   professor of Geometry at Oxford University. These simplified the layout
;   of the tables enabling humans to easily scale calculations.
;
;   It is only recently with the introduction of pocket calculators and
;   computers like the ZX81 that natural logarithms are once more at the fore,
;   although some computers retain logarithms to the base ten.
;   'Natural' logarithms are powers to the base 'e', which like 'pi' is a 
;   naturally occurring number in branches of mathematics.
;   Like 'pi' also, 'e' is an irrational number and starts 2.718281828...
;
;   The tabular use of logarithms was that to multiply two numbers one looked
;   up their two logarithms in the tables, added them together and then looked 
;   for the result in a table of antilogarithms to give the desired product.
;
;   The EXP function is the BASIC equivalent of a calculator's 'antiln' function 
;   and by picking any two numbers, 1.72 and 6.89 say,
;	10 PRINT EXP ( LN 1.72 + LN 6.89 ) 
;   will give just the same result as
;	20 PRINT 1.72 * 6.89.
;   Division is accomplished by subtracting the two logs.
;
;   Napier also mentioned "square and cubicle extractions". 
;   To raise a number to the power 3, find its 'ln', multiply by 3 and find the 
;   'antiln'.  e.g. PRINT EXP( LN 4 * 3 )  gives 64.
;   Similarly to find the n'th root divide the logarithm by 'n'.
;
;   First test that the argument to LN is a positive, non-zero number.
fn_ln
	ld a,(hl)		; Fetch exponent to A.
	and a			; Test for zero argument
	jr z,REPORT_A		; if =0 then REPORT_A: 'Invalid argument'
;
	LD (HL),$80		; Insert 'plus zero' as exponent.
;
	inc hl			; Address byte with sign bit.
	bit 7,(hl)		; Test the bit. 
	jr nz,REPORT_A		; if <0 then REPORT_A: 'Invalid argument'

;;-	dec hl			; HL now points to exponent
	CALL STACK_A		; routine STACK-A stacks true binary exponent.
		
	RST 28H		;; FP-CALC
	DEFB $30	;;stk-data
	DEFB $38	;;Exponent: $88, Bytes: 1
	DEFB $00	;;(+00,+00,+00)
	DEFB $03	;;subtract
	DEFB $01	;;exchange
	DEFB $2D	;;duplicate
	DEFB $30	;;stk-data
	DEFB $F0	;;Exponent: $80, Bytes: 4
	DEFB $4C,$CC,$CC,$CD ;;
	DEFB $03	;;subtract

	DEFB $33	;;greater-0
	DEFB $00	;;jump-true
	DEFB GRE_8-$	;;to GRE_8

	DEFB $01	;;exchange

	.db $39		;;sub-one macro

	DEFB $01	;;exchange

	.db $3A		;;mul-by-2			*2
GRE_8
	DEFB $01	;;exchange
	DEFB $30	;;stk-data			LN 2
	DEFB $F0	;;Exponent: $80, Bytes: 4
	DEFB $31,$72,$17,$F8 ;;
	DEFB $04	;;multiply
	DEFB $01	;;exchange

	.db $39		 ;;sub-one macro

	DEFB $2D	;;duplicate
	DEFB $30	;;stk-data
	DEFB $32	;;Exponent: $82, Bytes: 1
	DEFB $20	;;(+00,+00,+00)
	DEFB $04	;;multiply
	DEFB $A2	;;stk-half
	DEFB $03	;;subtract
	DEFB $8C	;;series-0C
	DEFB $11	;;Exponent: $61, Bytes: 1
	DEFB $AC	;;(+00,+00,+00)
	DEFB $14	;;Exponent: $64, Bytes: 1
	DEFB $09	;;(+00,+00,+00)
	DEFB $56	;;Exponent: $66, Bytes: 2
	DEFB $DA,$A5	;;(+00,+00)
	DEFB $59	;;Exponent: $69, Bytes: 2
	DEFB $30,$C5	;;(+00,+00)
	DEFB $5C	;;Exponent: $6C, Bytes: 2
	DEFB $90,$AA	;;(+00,+00)
	DEFB $9E	;;Exponent: $6E, Bytes: 3
	DEFB $70,$6F,$61 ;;(+00)
	DEFB $A1	;;Exponent: $71, Bytes: 3
	DEFB $CB,$DA,$96 ;;(+00)
	DEFB $A4	;;Exponent: $74, Bytes: 3
	DEFB $31,$9F,$B4 ;;(+00)
	DEFB $E7	;;Exponent: $77, Bytes: 4
	DEFB $A0,$FE,$5C,$FC ;;
	DEFB $EA	;;Exponent: $7A, Bytes: 4
	DEFB $1B,$43,$CA,$36 ;;
	DEFB $ED	;;Exponent: $7D, Bytes: 4
	DEFB $A7,$9C,$7E,$5E ;;
	DEFB $F0	;;Exponent: $80, Bytes: 4
	DEFB $6E,$23,$80,$93 ;;

	DEFB $04	;;multiply
	DEFB $0F	;;addition
	DEFB $34	;;end-calc

	RET			; return.
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
;	the new 'PAUSE' joins here
ffp_hook
	ld hl,jp_DISP2		; hook to DISPLAY-2
	inc bc			; set counter
	ld ($4034),bc		; set FRAMES
	ret nz			; flicker free PAUSE (in SLOW mode)

	jp L0229		; DISPLAY-1 (in FAST mode)
;
; -----------------------------
; THE 'TRIGONOMETRIC' FUNCTIONS
; -----------------------------
;   Trigonometry is rocket science.
;   It is also used by carpenters and pyramid builders. 
;   Some uses can be quite abstract but the principles can be seen in simple
;   right-angled triangles. Triangles have some special properties:
;
;   1) The sum of the three angles is always PI radians (180 degrees).
;      Very helpful if you know two angles and wish to find the third.
;   2) In any right-angled triangle the sum of the squares of the two shorter
;      sides is equal to the square of the longest side opposite the right-angle.
;      Very useful if you know the length of two sides and wish to know the
;      length of the third side.
;   3) Functions sine, cosine and tangent enable one to calculate the length 
;      of an unknown side when the length of one other side and an angle is known.
;   4) Functions arcsin, arccosine and arctan enable one to calculate an unknown
;      angle when the length of two of the sides is known.

;
; -------------------------
; THE new 'COSINE' FUNCTION
; -------------------------
; (offset $1D: 'cos')
;
; Cosines are calculated as COS(X)=SIN(X + PI/2)
;
fn_cos
	RST 28H		;; FP-CALC		angle in radians
	.db $A2		;;stk-half  		X, 0.5 (offset: halfPI / PI)

	.db $2F		;;jump
	.db cos_entr-$	;;to cos_entr		continue as SINE function
;
; ----------------------------
; THE improved 'SINE' FUNCTION
; ----------------------------
; (offset $1C: 'sin')
;   This is a fundamental transcendental function from which others such as cos
;   and tan are directly, or indirectly, derived.
;   It uses the series generator to produce Chebyshev polynomials.
;
;	    /|
;	 1 / |
;	  /  |x
;	 /a  |
;	/----|    
;	  y
;
;   The 'get-argt' part is designed to modify the angle and its sign 
;   in line with the desired sine value.
;
fn_sin

; ------------------------------
; THE improved 'REDUCE ARGUMENT'
; ------------------------------
;
;   This part performs two functions on the angle, in radians, that forms
;   the argument to the sine and cosine functions.
;   First it ensures that the angle 'wraps round'. That if a ship turns through 
;   an angle of, say, 3*PI radians (540 degrees) then the net effect is to turn 
;   through an angle of PI radians (180 degrees).
;   Secondly it converts the angle in radians to a fraction of a right angle,
;   depending within which quadrant the angle lies, with the periodicity 
;   resembling that of the desired sine value.
;   The result lies in the range -1 to +1.	
;
;                       90 deg.
; 
;                       (pi/2)
;                II       +1        I
;                         |
;          sin+      |\   |   /|    sin+
;          cos-      | \  |  / |    cos+
;          tan-      |  \ | /  |    tan+
;                    |   \|/)  |           
;   180 deg. (pi) 0 -|----+----|-- 0  (0)   0 degrees
;                    |   /|\   |
;          sin-      |  / | \  |    sin-
;          cos-      | /  |  \ |    cos+
;          tan+      |/   |   \|    tan-
;                         |
;                III      -1       IV
;                       (3pi/2)
;
;                       270 deg.
;
	RST 28H		;; FP-CALC		angle in radians
	.db $A0		;;stk-zero  		X, 0.	 (offset)
cos_entr
	.db $01		;;exchange		ofs, X.

	DEFB $30	;;stk-data
	DEFB $EE	;;Exponent: $7E, Bytes: 4
	DEFB $22,$F9,$83,$6E ;;			ofs, X, 1/(2*PI)  
	DEFB $04	;;multiply		ofs, X/(2*PI) = fraction

	DEFB $2D	;;duplicate  		ofs, fraction, fraction
	DEFB $A2	;;stk-half  		ofs, fraction, fraction, 0.5
	DEFB $0F	;;addition  		ofs, fraction, fraction + 0.5
	DEFB $24	;;int  			ofs, fraction, int(fraction+0.5)

	DEFB $03	;;subtract		ofs, now range -.5 to .5

	.db $3A		;;mul-by-2		ofs, now range -1 to 1.
	.db $0F		;;addition 		ofs + range (-1 to 1).

	.db $2D		;;duplicate		ofs_rng, ofs_rng
	.db $39		;;sub-one macro		ofs_rng, ofs_rng-1.

	.db $2D		;;duplicate		ofs_rng, ofs_rng-1, ofs_rng-1.
	.db $32		;;less-0		ofs_rng, ofs_rng-1, 0/1.
	.db $00		;;jump-true
	.db no_qchg-$	;;to no_qchg 		

	.db $39		;;sub-one macro		ofs_rng, ofs_rng-2.
	.db $01		;;exchange		ofs_rng-2, ofs_rng.
no_qchg
	.db $02		;;delete		delete test value.
	.db $3A		;;mul-by-2		now range -2 to 2.
;
;   quadrant I (0 to +1) and quadrant IV (-1 to 0) are now correct.
;   quadrant II ranges +1 to +2.
;   quadrant III ranges -2 to -1.
;
	DEFB $2D	;;duplicate		Y, Y.
	DEFB $27	;;abs			Y, abs(Y).    range 1 to 2

	.db $39		;;sub-one macro		Y, abs(Y)-1.  range 0 to 1

	DEFB $2D	;;duplicate		Y, Z, Z.

	DEFB $33	;;greater-0		Y, Z, (1/0).
	DEFB $00	;;jump-true
	DEFB ZPLUS-$	;;to ZPLUS with quadrants II and III
;
;   else the angle lies in quadrant I or IV and value Y is already correct.
;
	DEFB $02	;;delete		Y	delete test value.

	.db $2F		;;jump
	.db YNEG-$	;;to YNEG		Y.	with Q1 and Q4 >>>
;
;   The branch was here with quadrants II (0 to 1) and III (1 to 0).
;   Y will hold -2 to -1 if this is quadrant III.
;
ZPLUS
	.db $39		;;sub-one macro		Y, Z-1.  Q3 = 0 to -1

	DEFB $01	;;exchange		Z-1, Y.

	DEFB $32	;;less-0		Z-1, (1/0).
	DEFB $00	;;jump-true		Z-1.
	DEFB YNEG-$	;;to YNEG		if angle in quadrant III
;
;   else angle is within quadrant II (-1 to 0)
;
	DEFB $18	;;negate		range +1 to 0
;
;	-------------------------------------------
YNEG
	.db $3C		;;stk-square		x, x*x.
	.db $3A		;;mul-by-2		x, 2*x*x.
	.db $39		;;sub-one macro		x, 2*x*x-1

	DEFB $86	;;series-06
	DEFB $14	;;Exponent: $64, Bytes: 1
	DEFB $E6	;;(+00,+00,+00)
	DEFB $5C	;;Exponent: $6C, Bytes: 2
	DEFB $1F,$0B	;;(+00,+00)
	DEFB $A3	;;Exponent: $73, Bytes: 3
	DEFB $8F,$38,$EE ;;(+00)
	DEFB $E9	;;Exponent: $79, Bytes: 4
	DEFB $15,$63,$BB,$23 ;;
	DEFB $EE	;;Exponent: $7E, Bytes: 4
	DEFB $92,$0D,$CD,$ED ;;
	DEFB $F1	;;Exponent: $81, Bytes: 4
	DEFB $23,$5D,$1B,$EA ;;

	DEFB $04	;;multiply		x*series_06
	DEFB $34	;;end-calc
;
; -------------------------------------------
; THE eliminated 'REDUCE ARGUMENT' SUBROUTINE
; -------------------------------------------
; (offset $35: 'get-argt')
;
; now it is part of the sine function - see above
;
get_argt
	RET 	; return.
;
; ----------------------
; THE 'TANGENT' FUNCTION
; ----------------------
; (offset $1E: 'tan')
;
; Evaluates tangent x as    sin(x) / cos(x).
;
;	    /|
;	 h / |
;	  /  |o
;	 /x  |
;	/----|    
;	  a
;
;   The tangent of angle x is the ratio of the length of the opposite side 
;   divided by the length of the adjacent side.  As the opposite length can 
;   be calculates using sin(x) and the adjacent length using cos(x) then 
;   the tangent can be defined in terms of the previous two functions.

;   Error 6 if the argument, in radians, is too close to one like pi/2
;   which has an infinite tangent. e.g. PRINT TAN (PI/2)  evaluates as 1/0.
;   Similarly PRINT TAN (3*PI/2), TAN (5*PI/2) etc.
;
fn_tan
	RST 28H		;; FP-CALC		x.
	DEFB $2D	;;duplicate		x, x.
	DEFB $1C	;;sin			x, sin x.
	DEFB $01	;;exchange		sin x, x.
	DEFB $1D	;;cos			sin x, cos x.
	DEFB $05	;;division		sin x/cos x (= tan x).
	DEFB $34	;;end-calc		tan x.

	RET			; return.
;
; ------------------------------
; THE improved 'ARCTAN' FUNCTION
; ------------------------------
; (Offset $21: 'atn')
;   The inverse tangent function with the result in radians.
;   This is a fundamental transcendental function from which others such
;   as asn and acs are directly, or indirectly, derived.
;   It uses the series generator to produce Chebyshev polynomials.
;
fn_atn
	LD A,(HL)		; fetch exponent
	CP $81			; compare to that for 'one'
	JR C,SMALL		; forward, if less, to SMALL

	RST 28H		;; FP-CALC		X.
	DEFB $A1	;;stk-one		X, 1.
	DEFB $18	;;negate		X, -1.
	DEFB $01	;;exchange		-1, X.
	DEFB $05	;;division		-1/X.
	DEFB $2D	;;duplicate		-1/X, -1/X.

	.db $A3		;;stk-pi/2		-1/X, -1/X, PI/2.
	.db $01		;;exchange		-1/X, PI/2, -1/X.

	.db $32		;;less-0		-1/X, PI/2, (1/0).
	DEFB $00	;;jump-true
	DEFB CASES-$	;;to CASES		-1/X, PI/2.

	DEFB $18	;;negate		-1/X, -PI/2.
	DEFB $2F	;;jump
	DEFB CASES-$	;;to CASES
; ---
;
SMALL
	RST 28H		;; FP-CALC
	DEFB $A0	;;stk-zero
CASES
	DEFB $01	;;exchange

	.db $3C		;;stk-square		x, x*x.
	.db $3A		;;mul-by-2		x, 2*x*x.
	.db $39		;;sub-one macro		x, 2*x*x-1.

	DEFB $8C	;;series-0C
	DEFB $10	;;Exponent: $60, Bytes: 1
	DEFB $B2	;;(+00,+00,+00)
	DEFB $13	;;Exponent: $63, Bytes: 1
	DEFB $0E	;;(+00,+00,+00)
	DEFB $55	;;Exponent: $65, Bytes: 2
	DEFB $E4,$8D	;;(+00,+00)
	DEFB $58	;;Exponent: $68, Bytes: 2
	DEFB $39,$BC	;;(+00,+00)
	DEFB $5B	;;Exponent: $6B, Bytes: 2
	DEFB $98,$FD	;;(+00,+00)
	DEFB $9E	;;Exponent: $6E, Bytes: 3
	DEFB $00,$36,$75 ;;(+00)
	DEFB $A0	;;Exponent: $70, Bytes: 3
	DEFB $DB,$E8,$B4 ;;(+00)
	DEFB $63	;;Exponent: $73, Bytes: 2
	DEFB $42,$C4	;;(+00,+00)
	DEFB $E6	;;Exponent: $76, Bytes: 4
	DEFB $B5,$09,$36,$BE ;;
	DEFB $E9	;;Exponent: $79, Bytes: 4
	DEFB $36,$73,$1B,$5D ;;
	DEFB $EC	;;Exponent: $7C, Bytes: 4
	DEFB $D8,$DE,$63,$BE ;;
	DEFB $F0	;;Exponent: $80, Bytes: 4
	DEFB $61,$A1,$B3,$0C ;;

	DEFB $04	;;multiply
	DEFB $0F	;;addition
	DEFB $34	;;end-calc

	RET			; return.
;
; ------------------------------
; THE improved 'ARCSIN' FUNCTION
; ------------------------------
; (Offset $1F: 'asn')
;   The inverse sine function with result in radians.
;   Derived from arctan function above.
;   Error A unless the argument is between -1 and +1 inclusive.
;   Uses an adaptation of the formula asn(x) = atn(x/sqr(1-x*x))
;
;	    /|
;	   / |
;	 1/  |x
;	 /a  |
;	/----|    
;	  y
;
;   e.g. We know the opposite side (x) and hypotenuse (1) 
;   and we wish to find angle a in radians.
;   We can derive length y by Pythagoras and then use ATN instead. 
;   Since y*y + x*x = 1*1 (Pythagoras Theorem) then y=sqr(1-x*x)
;   - no need to multiply 1 by itself.
;   So, asn(a) = atn(x/y)
;   or more fully,
;   asn(a) = atn(x/sqr(1-x*x))

;   Close but no cigar.

;   While PRINT ATN (x/SQR (1-x*x)) gives the same results as PRINT ASN x,
;   it leads to division by zero when x is 1 or -1.
;   To overcome this, 1 is added to y giving half the required angle and the 
;   result is then doubled. 
;   That is, PRINT ATN (x/(SQR (1-x*x) +1)) *2
;
;
;		. /|
;	     .  c/ |
;	  .     /1 |x
;      . c   b /a  |
;    ---------/----|    
;      1      y
;
;   By creating an isosceles triangle with two equal sides of 1, angles c and 
;   c are also equal. If b+c+c = 180 degrees and b+a = 180 degress then c=a/2.
;
;   A value higher than 1 gives the required error as attempting to find  the
;   square root of a negative number generates an error in Sinclair BASIC.
;
fn_asn
	RST 28H		;; FP-CALC		x.

	.db $3C		;;stk-square		x, x*x.
	.db $39		;;sub-one macro		x, x*x-1.

	DEFB $18	;;negate		x, 1-x*x.
	DEFB $25	;;sqr			x, sqr(1-x*x) = y.
	DEFB $A1	;;stk-one		x, y, 1.
	DEFB $0F	;;addition		x, y+1.
	DEFB $05	;;division		x/(y+1).
	DEFB $21	;;atn			a/2	(half the angle)
	DEFB $34	;;end-calc		return via mul-by-2:  a=2*a/2.
;
; ------------------------------
; THE 'MULTIPLY BY TWO' FUNCTION
; ------------------------------
; (Offset $3A: 'mul-by-2')
; this part is a new 'macro', which replaces the next 2 calc. literals
;
;	$2D  :  duplicate	(x,x)
;	$0F  :  addition	(x+x = 2*x)
;
mul_by_2
	ld a,(hl)		; test exponent
	and a			; >0?
	ret z			; return if it is zero (2*0=0!)

	inc (hl)		; else increase the exponent (*2)
	ret nz			; return if no overflow occurred
mul2_ovf
	rst 08h			; Error Report:
	.db $05			; Number is too big
;
; ------------------------
; THE 'ARCCOS' FUNCTION
; ------------------------
; (Offset $20: 'acs')
; the inverse cosine function with the result in radians.
; Error A unless the argument is between -1 and +1.
; Result in range 0 to pi.
; Derived from asn above which is in turn derived from the preceding atn.
; It could have been derived directly from atn using acs(x) = atn(sqr(1-x*x)/x).
; However, as sine and cosine are horizontal translations of each other,
; uses acs(x) = pi/2 - asn(x)

; e.g. the arccosine of a known x value will give the required angle b in 
; radians.
; We know, from above, how to calculate the angle a using asn(x). 
; Since the three angles of any triangle add up to 180 degrees, or pi radians,
; and the largest angle in this case is a right-angle (pi/2 radians), then
; we can calculate angle b as pi/2 (both angles) minus asn(x) (angle a).
; 
;	    /|
;	 1 /b|
;	  /  |x
;	 /a  |
;	/----|    
;	  y
;
fn_acs	RST 28H		;; FP-CALC		x.

	DEFB $1F	;;asn			asn(x).
	DEFB $A3	;;stk-pi/2		asn(x), pi/2.
	DEFB $03	;;subtract		asn(x) - pi/2.
	DEFB $18	;;negate		pi/2 - asn(x) = acs(x).
	DEFB $34	;;end-calc		acs(x)

	RET	 		; return.
;
; ---------------------------------
; THE 'SINGLE OPERATION' SUBROUTINE
; ---------------------------------
;   offset $37: 'fp-calc-2'
;   this single operation is used, in the first instance, to evaluate most
;   of the mathematical and string functions found in BASIC expressions.

fp_calc_2
	POP AF			; drop return address.
	LD A,($401E)		; load accumulator from system variable BREG
				; value will be literal eg. 'tan'
	EXX			; switch to alt

	jp SCAN_ENT		; back to SCAN-ENT
				; next literal will be end-calc in scanning
;
; --------------------------------
; THE 'MEMORY LOCATION' SUBROUTINE
; --------------------------------
; This routine, when supplied with a base address in HL and an index in A,
; will calculate the address of the A'th entry, where each entry occupies
; five bytes. It is used for addressing floating-point numbers in the
; calculator's memory area.
;
LOC_MEM
	LD C,A			; store the original number $00-$1F.
	RLCA			; double.
	RLCA			; quadruple.
	ADD A,C			; now add original value to multiply by five.

	LD C,A			; place the result in C.
	LD B,$00		; set B to 0.
	ADD HL,BC		; add to form address of start of number in HL.
	RET			; return.
;
; ------------------------------
; THE 'MULTIPLY BY TEN' FUNCTION
; ------------------------------
; (Offset $3B: 'mul-by-10')
; the 'tricky' multiplication:  10x = 2x + 8x
; the new E-TO-FP and PRINT-FP call this subroutine
;
mul_by10
	call mul_by_2		; x1 = x*2 	(tests overflow)
	ret z			; return if it is zero (2*0=0!)

	push hl			; save OP1 pointer
	call COPY_FP		; duplicate 

	inc (hl)		; increase the exponent (4*x)
	jr z,mul2_ovf		; if overflow occurred

	inc (hl)		; increase the exponent (8*x)
	jr z,mul2_ovf		; if overflow occurred

	ex de,hl		; de: OP2 pointer
	pop hl			; hl: OP1 pointer
	jp addition		; routine addition (L1755)
				; y = 2*x + 8*x    (=10*x)
;
; ---------------------------
; THE 'STACK-SQUARE' FUNCTION
; ---------------------------
; (Offset $3C: 'stk-square') 
; this part is a new 'macro', which replaces the next 3 calc. literals
;
;	$2D  :  duplicate	(x, x)
;	$2D  :  duplicate	(x, x, x)
;	$04  :  multiply	(x, x*x)
;
stk_squa
	call COPY_FP		; duplicate 

	push de			; save stack end
	ld d,h			; set pointer to
	ld e,l			; last value on stack
	call multiply		; multiplication

	pop de			; restore pointer
	ret			; return w. square
;
;	========================================================
;	the quick 'LOCATE ADDRESS' routine joins here
;
loc_xpnd
	ld hl,($400C)		; HL points the beginning of the D-File
	bit 5,(IY+$3B)		; sv CDFLAG - test expanded display file
	ret z			; return if not

	pop de			; else drop return address
	ld de,33		; size of a complete line in bytes
	jr add_33b		; skip the 1st addition
add_33a
	add hl,de		; set pointer to the next line
add_33b
	djnz add_33a		; back if the line counter is nonzero

	add hl,bc		; add value of the X coordinate
	jp set_DFCC		; jump back to the caller
;
;	========================================================
;	the new 'PLOT AND UNPLOT' routine joins here
;
plot_ext			; must be inverted?
	jr c,plot_end		; forward to PLOT-END, if not

	xor $8F			; swap the necessary bits
;
;; PLOT-END
plot_end
	bit 5,(iy+$3B)		; sv CDFLAG - test expanded D-FILE
	jp z,L07EE		; if not, then return via OUT-CH

	ld (hl),a		; else write D-File immediate
	ret 			; and return
;
;	========================================================
;

;
; ------------------------
; THE 'ZX81 CHARACTER SET'
; ------------------------

;; char-set - begins with space character.

; $00 - Character: ' '		CHR$(0)

L1E00:	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000

; $01 - Character: mosaic	CHR$(1)

	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000


; $02 - Character: mosaic	CHR$(2)

	DEFB    %00001111
	DEFB    %00001111
	DEFB    %00001111
	DEFB    %00001111
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000


; $03 - Character: mosaic	CHR$(3)

	DEFB    %11111111
	DEFB    %11111111
	DEFB    %11111111
	DEFB    %11111111
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000

; $04 - Character: mosaic	CHR$(4)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000

; $05 - Character: mosaic	CHR$(5)

	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000

; $06 - Character: mosaic	CHR$(6)

	DEFB    %00001111
	DEFB    %00001111
	DEFB    %00001111
	DEFB    %00001111
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000

; $07 - Character: mosaic	CHR$(7)

	DEFB    %11111111
	DEFB    %11111111
	DEFB    %11111111
	DEFB    %11111111
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000
	DEFB    %11110000

; $08 - Character: mosaic	CHR$(8)

	DEFB    %10101010
	DEFB    %01010101
	DEFB    %10101010
	DEFB    %01010101
	DEFB    %10101010
	DEFB    %01010101
	DEFB    %10101010
	DEFB    %01010101

; $09 - Character: mosaic	CHR$(9)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %10101010
	DEFB    %01010101
	DEFB    %10101010
	DEFB    %01010101

; $0A - Character: mosaic	CHR$(10)

	DEFB    %10101010
	DEFB    %01010101
	DEFB    %10101010
	DEFB    %01010101
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000

; $0B - Character: '"'		CHR$(11)

	DEFB    %00000000
	DEFB    %00100100
	DEFB    %00100100
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000

; $0C - Character Pound		CHR$(12)

	DEFB    %00000000
	DEFB    %00011100
	DEFB    %00100010
	DEFB    %01111000
	DEFB    %00100000
	DEFB    %00100000
	DEFB    %01111110
	DEFB    %00000000

; $0D - Character: '$'		CHR$(13)

	DEFB    %00000000
	DEFB    %00001000
	DEFB    %00111110
	DEFB    %00101000
	DEFB    %00111110
	DEFB    %00001010
	DEFB    %00111110
	DEFB    %00001000

; $0E - Character: ':'		CHR$(14)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00010000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00010000
	DEFB    %00000000

; $0F - Character: '?'		CHR$(15)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %00000100
	DEFB    %00001000
	DEFB    %00000000
	DEFB    %00001000
	DEFB    %00000000

; $10 - Character: '('		CHR$(16)

	DEFB    %00000000
	DEFB    %00000100
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00000100
	DEFB    %00000000

; $11 - Character: ')'		CHR$(17)

	DEFB    %00000000
	DEFB    %00100000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00100000
	DEFB    %00000000

; $12 - Character: '>'		CHR$(18)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00010000
	DEFB    %00001000
	DEFB    %00000100
	DEFB    %00001000
	DEFB    %00010000
	DEFB    %00000000

; $13 - Character: '<'		CHR$(19)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000100
	DEFB    %00001000
	DEFB    %00010000
	DEFB    %00001000
	DEFB    %00000100
	DEFB    %00000000

; $14 - Character: '='		CHR$(20)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00111110
	DEFB    %00000000
	DEFB    %00111110
	DEFB    %00000000
	DEFB    %00000000

; $15 - Character: '+'		CHR$(21)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00111110
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00000000

; $16 - Character: '-'		CHR$(22)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00111110
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000

; $17 - Character: '*'		CHR$(23)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00010100
	DEFB    %00001000
	DEFB    %00111110
	DEFB    %00001000
	DEFB    %00010100
	DEFB    %00000000

; $18 - Character: '/'		CHR$(24)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000010
	DEFB    %00000100
	DEFB    %00001000
	DEFB    %00010000
	DEFB    %00100000
	DEFB    %00000000

; $19 - Character: ';'		CHR$(25)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00010000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00100000

; $1A - Character: ','		CHR$(26)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00010000

; $1B - Character: '.'		CHR$(27)

	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00000000
	DEFB    %00011000
	DEFB    %00011000
	DEFB    %00000000

; $1C - Character: '0'		CHR$(28)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000110
	DEFB    %01001010
	DEFB    %01010010
	DEFB    %01100010
	DEFB    %00111100
	DEFB    %00000000

; $1D - Character: '1'		CHR$(29)

	DEFB    %00000000
	DEFB    %00011000
	DEFB    %00101000
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00111110
	DEFB    %00000000

; $1E - Character: '2'		CHR$(30)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %00000010
	DEFB    %00111100
	DEFB    %01000000
	DEFB    %01111110
	DEFB    %00000000

; $1F - Character: '3'		CHR$(31)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %00001100
	DEFB    %00000010
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $20 - Character: '4'		CHR$(32)

	DEFB    %00000000
	DEFB    %00001000
	DEFB    %00011000
	DEFB    %00101000
	DEFB    %01001000
	DEFB    %01111110
	DEFB    %00001000
	DEFB    %00000000

; $21 - Character: '5'		CHR$(33)

	DEFB    %00000000
	DEFB    %01111110
	DEFB    %01000000
	DEFB    %01111100
	DEFB    %00000010
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $22 - Character: '6'		CHR$(34)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000000
	DEFB    %01111100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $23 - Character: '7'		CHR$(35)

	DEFB    %00000000
	DEFB    %01111110
	DEFB    %00000010
	DEFB    %00000100
	DEFB    %00001000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00000000

; $24 - Character: '8'		CHR$(36)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $25 - Character: '9'		CHR$(37)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00111110
	DEFB    %00000010
	DEFB    %00111100
	DEFB    %00000000

; $26 - Character: 'A'		CHR$(38)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01111110
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00000000

; $27 - Character: 'B'		CHR$(39)

	DEFB    %00000000
	DEFB    %01111100
	DEFB    %01000010
	DEFB    %01111100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01111100
	DEFB    %00000000

; $28 - Character: 'C'		CHR$(40)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %01000000
	DEFB    %01000000
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $29 - Character: 'D'		CHR$(41)

	DEFB    %00000000
	DEFB    %01111000
	DEFB    %01000100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000100
	DEFB    %01111000
	DEFB    %00000000

; $2A - Character: 'E'		CHR$(42)

	DEFB    %00000000
	DEFB    %01111110
	DEFB    %01000000
	DEFB    %01111100
	DEFB    %01000000
	DEFB    %01000000
	DEFB    %01111110
	DEFB    %00000000

; $2B - Character: 'F'		CHR$(43)

	DEFB    %00000000
	DEFB    %01111110
	DEFB    %01000000
	DEFB    %01111100
	DEFB    %01000000
	DEFB    %01000000
	DEFB    %01000000
	DEFB    %00000000

; $2C - Character: 'G'		CHR$(44)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %01000000
	DEFB    %01001110
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $2D - Character: 'H'		CHR$(45)

	DEFB    %00000000
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01111110
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00000000

; $2E - Character: 'I'		CHR$(46)

	DEFB    %00000000
	DEFB    %00111110
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00001000
	DEFB    %00111110
	DEFB    %00000000

; $2F - Character: 'J'		CHR$(47)

	DEFB    %00000000
	DEFB    %00000010
	DEFB    %00000010
	DEFB    %00000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $30 - Character: 'K'		CHR$(48)

	DEFB    %00000000
	DEFB    %01000100
	DEFB    %01001000
	DEFB    %01110000
	DEFB    %01001000
	DEFB    %01000100
	DEFB    %01000010
	DEFB    %00000000

; $31 - Character: 'L'		CHR$(49)

	DEFB    %00000000
	DEFB    %01000000
	DEFB    %01000000
	DEFB    %01000000
	DEFB    %01000000
	DEFB    %01000000
	DEFB    %01111110
	DEFB    %00000000

; $32 - Character: 'M'		CHR$(50)

	DEFB    %00000000
	DEFB    %01000010
	DEFB    %01100110
	DEFB    %01011010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00000000

; $33 - Character: 'N'		CHR$(51)

	DEFB    %00000000
	DEFB    %01000010
	DEFB    %01100010
	DEFB    %01010010
	DEFB    %01001010
	DEFB    %01000110
	DEFB    %01000010
	DEFB    %00000000

; $34 - Character: 'O'		CHR$(52)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $35 - Character: 'P'		CHR$(53)

	DEFB    %00000000
	DEFB    %01111100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01111100
	DEFB    %01000000
	DEFB    %01000000
	DEFB    %00000000

; $36 - Character: 'Q'		CHR$(54)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01010010
	DEFB    %01001010
	DEFB    %00111100
	DEFB    %00000000

; $37 - Character: 'R'		CHR$(55)

	DEFB    %00000000
	DEFB    %01111100
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01111100
	DEFB    %01000100
	DEFB    %01000010
	DEFB    %00000000

; $38 - Character: 'S'		CHR$(56)

	DEFB    %00000000
	DEFB    %00111100
	DEFB    %01000000
	DEFB    %00111100
	DEFB    %00000010
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $39 - Character: 'T'		CHR$(57)

	DEFB    %00000000
	DEFB    %11111110
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00000000

; $3A - Character: 'U'		CHR$(58)

	DEFB    %00000000
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00111100
	DEFB    %00000000

; $3B - Character: 'V'		CHR$(59)

	DEFB    %00000000
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %00100100
	DEFB    %00011000
	DEFB    %00000000

; $3C - Character: 'W'		CHR$(60)

	DEFB    %00000000
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01000010
	DEFB    %01011010
	DEFB    %00100100
	DEFB    %00000000

; $3D - Character: 'X'		CHR$(61)

	DEFB    %00000000
	DEFB    %01000010
	DEFB    %00100100
	DEFB    %00011000
	DEFB    %00011000
	DEFB    %00100100
	DEFB    %01000010
	DEFB    %00000000

; $3E - Character: 'Y'		CHR$(62)

	DEFB    %00000000
	DEFB    %10000010
	DEFB    %01000100
	DEFB    %00101000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00010000
	DEFB    %00000000

; $3F - Character: 'Z'		CHR$(63)

	DEFB    %00000000
	DEFB    %01111110
	DEFB    %00000100
	DEFB    %00001000
	DEFB    %00010000
	DEFB    %00100000
	DEFB    %01111110
	DEFB    %00000000

.END				;TASM assembler instruction.


