; ===============================================================================
;               An Assembly Listing of the ZX81x2 ROM
; ===============================================================================
;
; -------------------------
; Last updated: 26-NOV-2020
; -------------------------
;
;   Based on the "Shoulders of Giants" ZX81 ROM (Geoff Wearmouth).
;
;  SG81.ROM ---------------------------------------------------------------------
;
;   The main feature is the inclusion of Newton Raphson square roots.
;   The square roots are executed 3 times faster than those in the
;   standard ROM. They are more accurate also and
;
;   PRINT SQR 100 = INT SQR 100 gives the result 1 (true) not 0 (false)
;
;   The input and storage of fractional numbers is improved
;
;   PRINT 1/2 = .5 gives the result 1 (true) and not 0 (false)
;
;   The output of fractional numbers to the ZX Printer is corrected
;
;   LPRINT .00001 gives the output .00001 and not .0XYZ1
;
;   Other alterations have been made to create the space required by the
;   new square root routine and some are obscure and would not otherwise have
;   been made.
;   Using uncompressed constants rectifies a logic error and improves speed.
;
;  SG81_A.ROM -------------------------------------------------------------------
;
;   T3 (NMI) patch - faster NMI-service:  the user application gets +3TS/NMI
;
;  SG81_B.ROM -------------------------------------------------------------------
;
;   QCOM1 patch by Ludwig Röck (faster FOR/NEXT, GOSUB/RETURN)
;
;  SG81_C.ROM ===============================================================(GZS)
;
;   improved LOC-ADDR routine -> faster printing
;
;  SG81_D1.ROM --------------------------------------------------------------(GZS)
;
;   modified routine 'POINTERS' and a patch to use 24 lines 'SCROLL'
;   (the POKE 16418,0 is a cheat code, which enables 24 lines printing)
;
;   improved 'E-TO-FP' routine - a (1B shorter) ZX Spectrum-like solution
;
;  SG81E_MT.ROM -------------------------------------------------------------(GZS)
;
;   improved 'FP-TO-BC' routine - no longer returns value "-0"
;   new 'E-TO-FP' routine with a tricky 'Multiply by Ten' subroutine
;   new (much faster) 'PRINT-FP' routine to printing the numbers
;
;  SG81F_MT.ROM -------------------------------------------------------------(GZS)
;
;   renewed arithmetic routines - the 4 basic operations are faster
;   the patched 'NEXT' command routine calls directly the new 'ADDITION'
;
;  SG81_G2.ROM --------------------------------------------------------------(GZS)
;
;   improved exponent correction in 'MULTIPLICATION' and 'DIVISION' routines
;
;   rewritten functions: INT, SGN, COS
;   improved routines: ASIN, ATAN, EXP, FP-CALC, FP2BC, INT2FP, LN, NXTDGT1,
;              RND, SER-GEN, SIN, TO-POWER, TRUNCATE
;
;   the 'get-argt' literal from now does nothing (points to a simple RET)
;   the improved 'GETARGT' function is part of the improved 'SINE' function.
;
;   new macros (calculator literals): sub-one, mul-by-2, mul-by-10, stk-square
;
;   the patched routines: PRINTING, LINE-ENDS, SCROLL, IF, SQR, 'JUMP ON TRUE'
;
;
;  ZX81x2.ROM ----------------------------------------------------- (the big bang)
;
;   the renewed comparison operations from now have two entry points:
;   one for "=,<,>", and an other for "<>,>=,<="
;
;   the improved INT function and the renewed NEXT-LOOP routine are calling
;   directly the new and quick numeric comparison instead of subtraction
;
;   the system variable CDFLAG from now includes two new status bits:
;
;   - bit 5 signs the noncollapsed (expanded) display file
;     its status is checked by the renewed screen manipulating routines
;
;   - bit 4 is the plot48 flag - if it is set, then the PLOT origin will be
;     moved to the left bottom corner and the Y coordinate can be 0..47
;
;   the ending part of the new 'CLEAR PRINTER BUFFER' routine is used by
;   the new 'CLS' and 'SCROLL' routines
;
;   the new CLS routine is much faster than the original and sets the new
;   status bit of the CDFLAG (bit 5) depending on the available memory
;   (dramatically reduces also the time required for booting)
;
;   the 'SCROLL', the 'LOCATE ADDRESS' and the 'PLOT AND UNPLOT' routines
;   were enhanced to work in two ways depending on bit 5 of CDFLAG:
;
;   (1) as before (bit 5 = 0): eg. the 'SCROLL' damages the display file
;
;   (2) or quick (bit 5 = 1): making use of the direct writing possibility
;                             of the linear display file
;
;   the old 'Handle string AND number' routine was completely removed
;   its function is provided by the 'Handle number AND number' routine
;
;   the 'Absolute magnitude' and the 'Handle PEEK' functions have been moved
;
;   the patched routines: 'PRINT A CHARACTER','RUBOUT','ED-EDGE','RND'
;
;   the "POINTERS" routine is again in its original (unpatched) format
;
;  ZX81x2aaa.ROM -----------------------------------------------------------------
;
;   the 'MODULUS', the 'TEST 5 SPACES', the 'COPY A FLOATING POINT NUMBER'
;   and the 'STR$' subroutines have been moved to their original location
;
;  ZX81x2b.ROM -------------------------------------------------------------------
;
;   improved (faster) series generator
;
;  ZX81x2c.ROM -------------------------------------------------------------------
;
;   new square root method by Andy Wright (from the SAM Coupe ROM)
;   it is ~2x faster than the previous Newton-Raphson iteration
;
;   a "flickerfree", new 'PAUSE' command routine
;
;   the patched routines:  'POINTERS','POKE', 'STACK POINTERS'
;
;   the 'CLS' command routine is renewed
;
;   ==================================================================== (GZS)

#define defb .BYTE              ; TASM cross-assembler definitions
#define defw .WORD
#define EQU .EQU
#define org .org

; ------------------------------------------------------------------------------

;#define zxmore         ; if this line is uncommented, then the 3T-patch
                                ; will be disabled (ClckFreq result is ~3% less)

; -------------------------------------------------------------------------------

;*****************************************
;** Part 1. RESTART ROUTINES AND TABLES **
;*****************************************

        org     $0000

; -----------
; THE 'START'
; -----------
; All Z80 chips start at location zero.
; At start-up the Interrupt Mode is 0, ZX computers use Interrupt Mode 1.
; Interrupts are disabled .

;; START
L0000:
        out     ($FD), a        ; Turn off the NMI generator if this ROM is
                                ; running in ZX81 hardware. This does nothing
                                ; if this ROM is running within an upgraded ZX80.
        ld      bc, $7FFF       ; Set BC to the top of possible RAM.
                                ; The higher unpopulated addresses are used for
                                ; video generation.
        jp      L03CB           ; Jump forward to RAM-CHECK.

; -------------------
; THE 'ERROR' RESTART
; -------------------
; The error restart deals immediately with an error. ZX computers execute the
; same code in runtime as when checking syntax. If the error occurred while
; running a program then a brief report is produced. If the error occurred
; while entering a BASIC line or in input etc., then the error marker indicates
; the exact point at which the error lies.

;; ERROR-1
L0008:  ld hl, ($4016)          ; fetch character address from CH_ADD.
        ld      ($4018), hl     ; and set the error pointer X_PTR.
        jr      L0056           ; forward to continue at ERROR-2.

; ---------------------------------------
; THE patched 'PRINT A CHARACTER' RESTART
; ---------------------------------------
; This restart prints the character in the accumulator using the alternate
; register set so there is no requirement to save the main registers.
; There is sufficient room available to separate a space (zero) from other
; characters as leading spaces need not be considered with a space.

;; PRINT-A
L0010:
        jp      L07EE           ; routine OUT-CH
;
;   ==============================================================
;
; -----------------------
; Absolute magnitude (27)
; -----------------------
; This calculator literal finds the absolute value of the last value,
; floating point, on calculator stack.
;
fn_abs
        inc     hl              ; point to byte with sign bit.
        res     7, (hl)         ; make the sign positive.
        dec     hl              ; point to last value again.
        ret                     ; return.
;
;   ==============================================================
;
; ---------------------------------
; THE 'COLLECT A CHARACTER' RESTART
; ---------------------------------
; The character addressed by the system variable CH_ADD is fetched and if it
; is a non-space, non-cursor character it is returned else CH_ADD is
; incremented and the new addressed character tested until it is not a space.

;; GET-CHAR
L0018:  ld hl, ($4016)          ; set HL to character address CH_ADD.
        ld      a, (hl)         ; fetch addressed character to A.

;; TEST-SP
L001C:  and a                   ; test for space.
        ret     nz              ; return if not a space

        nop                     ; else trickle through
        nop                     ; to the next routine.

; ------------------------------------
; THE 'COLLECT NEXT CHARACTER' RESTART
; ------------------------------------
; The character address in incremented and the new addressed character is
; returned if not a space, or cursor, else the process is repeated.

;; NEXT-CHAR
L0020:  call L0049              ; routine CH-ADD+1 gets next immediate
                                ; character.
        jr      L001C           ; back to TEST-SP.
;
;   ==============================================================
;
        .db $26, $10, $20       ; unused locations - FW_ID: 26.10.2020
;
;   ==============================================================
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
L0028:  jp CALCULATE            ;+ jump to the NEW calculate routine address.

end_calc                        ; (L002B)
        pop     af              ; drop the calculator return address RE-ENTRY
        exx                     ; switch to the other set.

        ex      (sp), hl        ; transfer H'L' to machine stack for the
                                ; return address.
                                ; when exiting recursion then the previous
                                ; pointer is transferred to H'L'.

        exx                     ; back to main set.
        ret                     ; return.

; -----------------------------
; THE 'MAKE BC SPACES'  RESTART
; -----------------------------
; This restart is used eight times to create, in workspace, the number of
; spaces passed in the BC register.

;; BC-SPACES
L0030:
        push    bc              ; push number of spaces on stack.
        ld      hl, ($4014)     ; fetch edit line location from E_LINE.
        push    hl              ; save this value on stack.
        jp      L1488           ; jump forward to continue at RESERVE.

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
        dec     c               ; (4)  decrement C - the scan line counter.
        jp      nz, L0045       ; (10/10) JUMP forward if not zero to SCAN-LINE

        pop     hl              ; (10) point to start of next row in display file.

        dec     b               ; (4)  decrement the row counter. (4)
        ret     z               ; (11/5) return when picture complete to L028B
                                ; with interrupts disabled.

        set     3, c            ; (8)  Load the scan line counter with eight.
                                ; Note. LD C,$08 is 7 clock cycles which
                                ; is way too fast.
; ->

;; WAIT-INT
L0041:
        ld      r, a            ; (9) Load R with initial rising value $DD.

        ei                      ; (4) Enable Interrupts.  [ R is now $DE ].

        jp      (hl)            ; (4) jump to the echo display file in upper
                                ;   memory and execute characters $00 - $3F
                                ;   as NOP instructions.  The video hardware
                                ;   is able to read these characters and,
                                ;   with the I register is able to convert
                                ;   the character bitmaps in this ROM into a
                                ;   line of bytes. Eventually the NEWLINE/HALT
                                ;   will be encountered before R reaches $FF.
                                ;   It is however the transition from $FF to
                                ;   $80 that triggers the next interrupt.
                                ;   [ The Refresh register is now $DF ]
; ---

;; SCAN-LINE
L0045:
        pop     de              ; (10) discard the address after NEWLINE as the
                                ; same text line has to be done again
                                ; eight times.

        ret     z               ; (5)  Harmless Nonsensical Timing.
                                ; (condition never met)

        jr      L0041           ; (12) back to WAIT-INT

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
        ld      hl, ($4016)     ; fetch character address to CH_ADD.

;; TEMP-PTR1
L004C:
        inc     hl              ; address next immediate location.

;; TEMP-PTR2
L004D:
        ld      ($4016), hl     ; update system variable CH_ADD.

        ld      a, (hl)         ; fetch the character.
        cp      $7F             ; compare to cursor character.
        ret     nz              ; return if not the cursor.

        jr      L004C           ; back for next character to TEMP-PTR1.

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
        pop     hl              ; pop the return address which points to the
                                ; DEFB, error code, after the RST 08.
        ld      l, (hl)         ; load L with the error code. HL is not needed
                                ; anymore.
;; ERROR-3
L0058:
        ld      (iy+$00), l     ; place error code in system variable ERR_NR
        ld      sp, ($4002)     ; set the stack pointer from ERR_SP
        call    L0207           ; routine SLOW/FAST selects slow mode.

        jp      L14BC           ; exit to address on stack via routine SET-MIN.
; ---
        defb    $FF             ; unused.

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
        ex      af, af'       ; (4) switch in the NMI's copy of the
                                ;   accumulator.
        inc     a               ; (4) increment.

#ifdef zxmore

        jp      m, NMI_RET      ; (10/10) jump, if minus, to NMI-RET as this is
                                ;   part of a test to see if the NMI
                                ;   generation is working or an intermediate
                                ;   value for the ascending negated blank
                                ;   line counter.
#endif
        jr      z, NMI_CONT     ; (12) forward to NMI-CONT
                                ; when line count has incremented to zero.
;; NMI-RET
;
NMI_RET
        ex      af, af'         ; (4)  switch out the incremented line counter
                                ; or test result $80
        ret                     ; (10) return to User application for a while.
; ---
;   This branch is taken when the 55 (or 31) lines have been drawn.

;; NMI-CONT
NMI_CONT
        ex      af, af'         ; (4) restore the main accumulator.

        push    af              ; (11) *  Save Main Registers
        push    bc              ; (11) **
        push    de              ; (11) ***
        push    hl              ; (11) ****

;   the next set-up procedure is only really applicable when the top set of
;   blank lines have been generated.

        ld      hl, ($400C)     ; (16) fetch start of Display File from D_FILE
                                ; points to the HALT at beginning.
        set     7, h            ; (8) point to upper 32K 'echo display file'

        halt                    ; (1) HALT synchronizes with NMI.
                                ; Used with special hardware connected to the
                                ; Z80 HALT and WAIT lines to take 1 clock cycle.

; ----------------------------------------------------------------------------
;   the NMI has been generated - start counting.
;
;   The cathode ray is at the RH side of the TV.
;   First the NMI servicing, similar to CALL        =  17 clock cycles.
;   Then the time taken by the NMI for zero-to-one path =  29 cycles.(it was 32)
;   The HALT above                  =  01 cycles.
;   The 3 (previously 2) instructions below     =  29 cycles.(it was 19)
;   The code at L0281 up to and including the CALL  =  43 cycles.
;   The Called routine at L02B5             =  24 cycles.
;   --------------------------------------        ---
;   Total Z80 instructions              = 143 cycles.
;
;   Meanwhile in TV world,
;   Horizontal retrace                  =  15 cycles.
;   Left blanking border 8 character positions      =  32 cycles
;   Generation of 75% scanline from the first NEWLINE   =  96 cycles
;   ---------------------------------------        ---
;                              143 cycles
;
;   Since at the time the first JP (HL) is encountered to execute the echo
;   display another 8 character positions have to be put out, then the
;   Refresh register need to hold $F8. Working back and counteracting
;   the fact that every instruction increments the Refresh register then
;   the value that is loaded into R needs to be $F5. :-)
;
;
        out     ($FD), a        ; (11) Stop the NMI generator.

#ifndef zxmore
        jp      IX_to_PC        ; (10) Delay
IX_to_PC

#endif
        jp      (ix)            ; (8) forward to L0281 (after top) or L028F

; ****************
; ** KEY TABLES **
; ****************

; -------------------------------
; THE 'UNSHIFTED' CHARACTER CODES
; -------------------------------

;; K-UNSHIFT
L007E:  defb $3F                ; Z
        defb    $3D             ; X
        defb    $28             ; C
        defb    $3B             ; V
        defb    $26             ; A
        defb    $38             ; S
        defb    $29             ; D
        defb    $2B             ; F
        defb    $2C             ; G
        defb    $36             ; Q
        defb    $3C             ; W
        defb    $2A             ; E
        defb    $37             ; R
        defb    $39             ; T
        defb    $1D             ; 1
        defb    $1E             ; 2
        defb    $1F             ; 3
        defb    $20             ; 4
        defb    $21             ; 5
        defb    $1C             ; 0
        defb    $25             ; 9
        defb    $24             ; 8
        defb    $23             ; 7
        defb    $22             ; 6
        defb    $35             ; P
        defb    $34             ; O
        defb    $2E             ; I
        defb    $3A             ; U
        defb    $3E             ; Y
        defb    $76             ; NEWLINE
        defb    $31             ; L
        defb    $30             ; K
        defb    $2F             ; J
        defb    $2D             ; H
        defb    $00             ; SPACE
        defb    $1B             ; .
        defb    $32             ; M
        defb    $33             ; N
        defb    $27             ; B

; -----------------------------
; THE 'SHIFTED' CHARACTER CODES
; -----------------------------

;; K-SHIFT
L00A5:  defb $0E                ; :
        defb    $19             ; ;
        defb    $0F             ; ?
        defb    $18             ; /
        defb    $E3             ; STOP
        defb    $E1             ; LPRINT
        defb    $E4             ; SLOW
        defb    $E5             ; FAST
        defb    $E2             ; LLIST
        defb    $C0             ; ""
        defb    $D9             ; OR
        defb    $E0             ; STEP
        defb    $DB             ; <=
        defb    $DD             ; <>
        defb    $75             ; EDIT
        defb    $DA             ; AND
        defb    $de             ; THEN
        defb    $DF             ; TO
        defb    $72             ; cursor-left
        defb    $77             ; RUBOUT
        defb    $74             ; GRAPHICS
        defb    $73             ; cursor-right
        defb    $70             ; cursor-up
        defb    $71             ; cursor-down
        defb    $0B             ; "
        defb    $11             ; )
        defb    $10             ; (
        defb    $0D             ; $
        defb    $DC             ; >=
        defb    $79             ; FUNCTION
        defb    $14             ; =
        defb    $15             ; +
        defb    $16             ; -
        defb    $D8             ; **
        defb    $0C             ;  &#163;
        defb    $1A             ; ,
        defb    $12             ; >
        defb    $13             ; <
        defb    $17             ; *

; ------------------------------
; THE 'FUNCTION' CHARACTER CODES
; ------------------------------

;; K-FUNCT
L00CC:  defb $CD                ; LN
        defb    $CE             ; EXP
        defb    $C1             ; AT
        defb    $78             ; KL
        defb    $CA             ; ASN
        defb    $CB             ; ACS
        defb    $CC             ; ATN
        defb    $D1             ; SGN
        defb    $D2             ; ABS
        defb    $C7             ; SIN
        defb    $C8             ; COS
        defb    $C9             ; TAN
        defb    $CF             ; INT
        defb    $40             ; RND
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $C2             ; TAB
        defb    $D3             ; PEEK
        defb    $C4             ; CODE
        defb    $D6             ; CHR$
        defb    $D5             ; STR$
        defb    $78             ; KL
        defb    $D4             ; USR
        defb    $C6             ; LEN
        defb    $C5             ; VAL
        defb    $D0             ; SQR
        defb    $78             ; KL
        defb    $78             ; KL
        defb    $42             ; PI
        defb    $D7             ; NOT
        defb    $41             ; INKEY$

; -----------------------------
; THE 'GRAPHIC' CHARACTER CODES
; -----------------------------

;; K-GRAPH
L00F3:  defb $08                ; graphic
        defb    $0A             ; graphic
        defb    $09             ; graphic
        defb    $8A             ; graphic
        defb    $89             ; graphic
        defb    $81             ; graphic
        defb    $82             ; graphic
        defb    $07             ; graphic
        defb    $84             ; graphic
        defb    $06             ; graphic
        defb    $01             ; graphic
        defb    $02             ; graphic
        defb    $87             ; graphic
        defb    $04             ; graphic
        defb    $05             ; graphic
        defb    $77             ; RUBOUT
        defb    $78             ; KL
        defb    $85             ; graphic
        defb    $03             ; graphic
        defb    $83             ; graphic
        defb    $8B             ; graphic
        defb    $91             ; inverse )
        defb    $90             ; inverse (
        defb    $8D             ; inverse $
        defb    $86             ; graphic
        defb    $78             ; KL
        defb    $92             ; inverse >
        defb    $95             ; inverse +
        defb    $96             ; inverse -
        defb    $88             ; graphic

; ------------------
; THE 'TOKEN' TABLES
; ------------------

;; TOKENS
L0111:  defb $0F+$80            ; '?'+$80
        defb    $0B, $0B+$80    ; ""
        defb    $26, $39+$80    ; AT
        defb    $39, $26, $27+$80
                                ; TAB
        defb    $0F+$80         ; '?'+$80
        defb    $28, $34, $29, $2A+$80
                                ; CODE
        defb    $3B, $26, $31+$80
                                ; VAL
        defb    $31, $2A, $33+$80
                                ; LEN
        defb    $38, $2E, $33+$80
                                ; SIN
        defb    $28, $34, $38+$80
                                ; COS
        defb    $39, $26, $33+$80
                                ; TAN
        defb    $26, $38, $33+$80
                                ; ASN
        defb    $26, $28, $38+$80
                                ; ACS
        defb    $26, $39, $33+$80
                                ; ATN
        defb    $31, $33+$80    ; LN
        defb    $2A, $3D, $35+$80
                                ; EXP
        defb    $2E, $33, $39+$80
                                ; INT
        defb    $38, $36, $37+$80
                                ; SQR
        defb    $38, $2C, $33+$80
                                ; SGN
        defb    $26, $27, $38+$80
                                ; ABS
        defb    $35, $2A, $2A, $30+$80
                                ; PEEK
        defb    $3A, $38, $37+$80
                                ; USR
        defb    $38, $39, $37, $0D+$80
                                ; STR$
        defb    $28, $2D, $37, $0D+$80
                                ; CHR$
        defb    $33, $34, $39+$80
                                ; NOT
        defb    $17, $17+$80    ; **
        defb    $34, $37+$80    ; OR
        defb    $26, $33, $29+$80
                                ; AND
        defb    $13, $14+$80    ; <=
        defb    $12, $14+$80    ; >=
        defb    $13, $12+$80    ; <>
        defb    $39, $2D, $2A, $33+$80
                                ; THEN
        defb    $39, $34+$80    ; TO
        defb    $38, $39, $2A, $35+$80
                                ; STEP
        defb    $31, $35, $37, $2E, $33, $39+$80
                                ; LPRINT
        defb    $31, $31, $2E, $38, $39+$80
                                ; LLIST
        defb    $38, $39, $34, $35+$80
                                ; STOP
        defb    $38, $31, $34, $3C+$80
                                ; SLOW
        defb    $2B, $26, $38, $39+$80
                                ; FAST
        defb    $33, $2A, $3C+$80
                                ; NEW
        defb    $38, $28, $37, $34, $31, $31+$80
                                ; SCROLL
        defb    $28, $34, $33, $39+$80
                                ; CONT
        defb    $29, $2E, $32+$80
                                ; DIM
        defb    $37, $2A, $32+$80
                                ; REM
        defb    $2B, $34, $37+$80
                                ; FOR
        defb    $2C, $34, $39, $34+$80
                                ; GOTO
        defb    $2C, $34, $38, $3A, $27+$80
                                ; GOSUB
        defb    $2E, $33, $35, $3A, $39+$80
                                ; INPUT
        defb    $31, $34, $26, $29+$80
                                ; LOAD
        defb    $31, $2E, $38, $39+$80
                                ; LIST
        defb    $31, $2A, $39+$80
                                ; LET
        defb    $35, $26, $3A, $38, $2A+$80
                                ; PAUSE
        defb    $33, $2A, $3D, $39+$80
                                ; NEXT
        defb    $35, $34, $30, $2A+$80
                                ; POKE
        defb    $35, $37, $2E, $33, $39+$80
                                ; PRINT
        defb    $35, $31, $34, $39+$80
                                ; PLOT
        defb    $37, $3A, $33+$80
                                ; RUN
        defb    $38, $26, $3B, $2A+$80
                                ; SAVE
        defb    $37, $26, $33, $29+$80
                                ; RAND
        defb    $2E, $2B+$80    ; IF
        defb    $28, $31, $38+$80
                                ; CLS
        defb    $3A, $33, $35, $31, $34, $39+$80
                                ; UNPLOT
        defb    $28, $31, $2A, $26, $37+$80
                                ; CLEAR
        defb    $37, $2A, $39, $3A, $37, $33+$80
                                ; RETURN
        defb    $28, $34, $35, $3E+$80
                                ; COPY
        defb    $37, $33, $29+$80
                                ; RND
        defb    $2E, $33, $30, $2A, $3E, $0D+$80
                                ; INKEY$
        defb    $35, $2E+$80    ; PI

; ------------------------------
; THE 'LOAD-SAVE UPDATE' ROUTINE
; ------------------------------
;
;; LOAD/SAVE
L01FC:
        inc     hl              ;
        ex      de, hl          ;
        ld      hl, ($4014)     ; system variable edit line E_LINE.
        scf                     ; set carry flag
        sbc     hl, de          ;
        ex      de, hl          ;
        ret     nc              ; return if more bytes to load/save.

        pop     hl              ; else drop return address

; ----------------------
; THE 'DISPLAY' ROUTINES
; ----------------------
;
;; SLOW/FAST
L0207:
        ld      hl, $403B       ; Address the system variable CDFLAG.
        ld      a, (hl)         ; Load value to the accumulator.
        rla                     ; rotate bit 6 to position 7.
        xor     (hl)            ; exclusive or with original bit 7.
        rla                     ; rotate result out to carry.
        ret     nc              ; return if both bits were the same.

;   Now test if this really is a ZX81 or a ZX80 running the upgraded ROM.
;   The standard ZX80 did not have an NMI generator.

        ld      a, $7F          ; Load accumulator with %011111111
        ex      af, af'       ; save in AF'

#ifdef zxmore                   ; A counter within which an NMI should occur

        ld      b, $22          ; if this is a zxmore.
#else
        ld      b, $11          ; if this is a ZX81.
#endif
        out     ($FE), a        ; start the NMI generator.

;  Note that if this is a ZX81 then the NMI will increment AF'.

;; LOOP-11
L0216:
        djnz    L0216           ; self loop to give the NMI a chance to kick in.
                                ; = 16*13 clock cycles + 8 = 216 clock cycles.

        out     ($FD), a        ; Turn off the NMI generator.
        ex      af, af'       ; bring back the AF' value.
        rla                     ; test bit 7.
        jr      nc, L0226       ; forward, if bit 7 is still reset, to NO-SLOW.

;   If the AF' was incremented then the NMI generator works and SLOW mode can be set.

        set     7, (hl)         ; Indicate SLOW mode - Compute and Display.

        push    af              ; *  Save Main Registers
        push    bc              ; **
        push    de              ; ***
        push    hl              ; ****

        jr      L0229           ; skip forward - to DISPLAY-1.
; ---

;; NO-SLOW
L0226:
        res     6, (hl)         ; reset bit 6 of CDFLAG.
        ret                     ; return.

; -----------------------
; THE 'MAIN DISPLAY' LOOP
; -----------------------
; This routine is executed once for every frame displayed.

;; DISPLAY-1
L0229:
        ld      hl, ($4034)     ; fetch two-byte system variable FRAMES.
        dec     hl              ; decrement frames counter.

;; DISPLAY-P
L022D:
        ld      a, $7F          ; prepare a mask
        and     h               ; pick up bits 6-0 of H.
        or      l               ; and any bits of L.
        ld      a, h            ; reload A with all bits of H for PAUSE test.

;   Note both branches must take the same time.

        jr      nz, L0237       ; (12/7) forward if bits 14-0 are not zero
                                ; to ANOTHER

        rla                     ; (4) test bit 15 of FRAMES.
        jr      L0239           ; (12) forward with result to OVER-NC
; ---

;; ANOTHER
L0237:
        ld      b, (hl)         ; (7) Note. Harmless Nonsensical Timing weight.
        scf                     ; (4) Set Carry Flag.

; Note. the branch to here takes either (12)(7)(4) cyles or (7)(4)(12) cycles.

;; OVER-NC
L0239:
        ld      h, a            ; (4)  set H to zero
        ld      ($4034), hl     ; (16) update system variable FRAMES
        ret     nc              ; (11/5) return if FRAMES is in use by PAUSE
                                ; command.
;; DISPLAY-2
L023E:
        call    L02BB           ; routine KEYBOARD gets the key row in H and
                                ; the column in L. Reading the ports also starts
                                ; the TV frame synchronization pulse. (VSYNC)(T735)

        ld      bc, ($4025)     ; fetch the last key values read from LAST_K
        ld      ($4025), hl     ; update LAST_K with new values.

        ld      a, b            ; load A with previous column - will be $FF if
                                ; there was no key.
        add     a, $02          ; adding two will set carry if no previous key.

        sbc     hl, bc          ; subtract with the carry the two key values.

; If the same key value has been returned twice then HL will be zero.

        ld      a, ($4027)      ; fetch system variable DEBOUNCE
        or      h               ; and OR with both bytes of the difference
        or      l               ; setting the zero flag for the upcoming branch.

        ld      e, b            ; transfer the column value to E
        ld      b, $0B          ; and load B with eleven

        ld      hl, $403B       ; address system variable CDFLAG
        res     0, (hl)         ; reset the rightmost bit of CDFLAG (VSYNC=T735+T119=T854)
        jr      nz, L0264       ; skip forward if debounce/diff >0 to NO-KEY (+T12)

        bit     7, (hl)         ; test compute and display bit of CDFLAG
        set     0, (hl)         ; set the rightmost bit of CDFLAG.
        ret     z               ; return if bit 7 indicated fast mode.

        dec     b               ; (4) decrement the counter.
        nop                     ; (4) Timing - 4 clock cycles. ??
        scf                     ; (4) Set Carry Flag (+T7+T44=+T49)

;; NO-KEY             Tdiff=T49-T12=T37
L0264:
        ld      hl, $4027       ; (10) sv DEBOUNCE
        ccf                     ; (4)  Complement Carry Flag
        rl      b               ; (8)  rotate left B picking up carry   (B=2*11+CY=23 if no key)
                                ;  C<-76543210<-C           (B=2*10+NC=20 else)
;; LOOP-B             Tcomp=(23-20)*T13=T39
L026A:
        djnz    L026A           ; self-loop while B>0 to LOOP-B (T=19*13+8=T255)
                                ; (VSYNC=T854+T12+T22+T255+T39=T1182)

        ld      b, (hl)         ; fetch value of DEBOUNCE to B
        ld      a, e            ; transfer column value
        cp      $FE             ;
        sbc     a, a            ;
        ld      b, $1F          ;
        or      (hl)            ;
        and     b               ;
        rra                     ;
        ld      (hl), a         ; (T1233)

        out     ($FF), a        ; end the TV frame synchronization pulse.

        ld      hl, ($400C)     ; (12) set HL to the Display File from D_FILE
        set     7, h            ; (8) set bit 15 to address the echo display.

        call    L0292           ; (17) routine DISPLAY-3 displays the top set
                                ; of blank lines.
; ---------------------
; THE 'VIDEO-1' ROUTINE
; ---------------------

;; R-IX-1
L0281:
        ld      a, r            ; (9)  Harmless Nonsensical Timing or something
                                ; very clever?
        ld      bc, $1901       ; (10) 25 lines, 1 scanline in first.
        ld      a, $F5          ; (7)  This value will be loaded into R and
                                ; ensures that the cycle starts at the right
                                ; part of the display  - after 32nd character
                                ; position.

        call    L02B5           ; (17) routine DISPLAY-5 completes the current
                                ; blank line and then generates the display of
                                ; the live picture using INT interrupts
                                ; The final interrupt returns to the next
                                ; address.
L028B:
        dec     hl              ; point HL to the last NEWLINE/HALT.

        call    L0292           ; routine DISPLAY-3 displays the bottom set of
                                ; blank lines.
; ---
;; R-IX-2
L028F:
        jp      L0229           ; JUMP back to DISPLAY-1

; ---------------------------------
; THE 'DISPLAY BLANK LINES' ROUTINE
; ---------------------------------
;   This subroutine is called twice (see above) to generate first the blank
;   lines at the top of the television display and then the blank lines at the
;   bottom of the display.

;; DISPLAY-3
L0292:
        pop     ix              ; pop the return address to IX register.
                                ; will be either L0281 or L028F - see above.

        ld      c, (iy+$28)     ; load C with value of system constant MARGIN.
        bit     7, (iy+$3B)     ; test CDFLAG for compute and display.
        jr      z, L02A9        ; forward, with FAST mode, to DISPLAY-4

        ld      a, c            ; move MARGIN to A - 31d or 55d.
        neg                     ; Negate
        inc     a               ;
        ex      af, af'       ; place negative count of blank lines in A'

        out     ($FE), a        ; enable the NMI generator.

        pop     hl              ; ****
        pop     de              ; ***
        pop     bc              ; **
        pop     af              ; *  Restore Main Registers

        ret                     ; return - end of interrupt.  Return is to
                                ; user's program - BASIC or machine code.
                                ; which will be interrupted by every NMI.
; ------------------------
; THE 'FAST MODE' ROUTINES
; ------------------------

;; DISPLAY-4
L02A9:
        ld      a, $FC          ; (7)  load A with first R delay value
        ld      b, $01          ; (7)  one row only.

        call    L02B5           ; (17) routine DISPLAY-5

        dec     hl              ; (6)  point back to the HALT.
        ex      (sp), hl        ; (19) Harmless Nonsensical Timing if paired.
        ex      (sp), hl        ; (19) Harmless Nonsensical Timing.
        jp      (ix)            ; (8)  to L0281 or L028F

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
        ld      r, a            ; (9) Load R from A.    R = slow: $F5 fast: $FC
        ld      a, $DD          ; (7) load future R value.    $F6       $FD

        ei                      ; (4) Enable Interrupts       $F7       $FE

        jp      (hl)            ; (4) jump to the echo display.   $F8       $FF

; ----------------------------------
; THE 'KEYBOARD SCANNING' SUBROUTINE
; ----------------------------------
; The keyboard is read during the vertical sync interval while no video is
; being displayed.  Reading a port with address bit 0 low i.e. $FE starts the
; vertical sync pulse.

;; KEYBOARD
L02BB:
        ld      hl, $FFFF       ; (16) prepare a buffer to take key.
        ld      bc, $FEFE       ; (20) set BC to port $FEFE. The B register,
                                ; with its single reset bit also acts as
                                ; an 8-counter.
        in      a, (c)          ; (12) read the port - all 16 bits are put on
                                ; the address bus.  Start VSYNC pulse.
        or      $01             ; (7)  set the rightmost bit so as to ignore
                                ; the SHIFT key.
;; EACH-LINE              (T19)
L02C5:
        or      $E0             ; [7] OR %11100000
        ld      d, a            ; [4] transfer to D.
        cpl                     ; [4] complement - only bits 4-0 meaningful now.
        cp      $01             ; [7] sets carry if A is zero.
        sbc     a, a            ; [4] $FF if $00 else zero.
        or      b               ; [7] $FF or port FE,FD,FB....
        and     l               ; [4] unless more than one key, L will still be
                                ;     $FF. if more than one key is pressed then A is
                                ;     now invalid.
        ld      l, a            ; [4] transfer to L.

; now consider the column identifier.

        ld      a, h            ; [4] will be $FF if no previous keys.
        and     d               ; [4] 111xxxxx
        ld      h, a            ; [4] transfer A to H

; since only one key may be pressed, H will, if valid, be one of
; 11111110, 11111101, 11111011, 11110111, 11101111
; reading from the outer column, say Q, to the inner column, say T.

        rlc     b               ; [8]  rotate the 8-counter/port address.
                                ; sets carry if more to do.
        in      a, (c)          ; [10] read another half-row.
                                ; all five bits this time. (T70)

        jr      c, L02C5        ; [12](7) loop back, until done, to EACH-LINE
                                ; (7*T82+T77=T651)

;   The last row read is SHIFT,Z,X,C,V  for the second time.

        rra                     ; (4) test the shift key - carry will be reset
                                ;   if the key is pressed.
        rl      h               ; (8) rotate left H picking up the carry giving
                                ;   column values -
                                ;   $FD, $FB, $F7, $EF, $DF.
                                ;   or $FC, $FA, $F6, $EE, $DE if shifted.

;   We now have H identifying the column and L identifying the row in the
;   keyboard matrix.

;   This is a good time to test if this is an American or British machine.
;   The US machine has an extra diode that causes bit 6 of a byte read from
;   a port to be reset.

        rla                     ; (4) compensate for the shift test.
        rla                     ; (4) rotate bit 7 out.
        rla                     ; (4) test bit 6.

        sbc     a, a            ; (4)   $FF or $00 {USA}
        and     $18             ; (7)   $18 or $00
        add     a, $1F          ; (7)   $37 or $1F

;   result is either 31 (USA) or 55 (UK) blank lines above and below the TV
;   picture.

        ld      ($4028), a      ; (13) update system variable MARGIN

        ret                     ; (10) return
                                ; (T_VSYNC=T19+T651+T65=T735)

; ------------------------------
; THE 'SET FAST MODE' SUBROUTINE
; ------------------------------
;
;; SET-FAST
L02E7:
        bit     7, (iy+$3B)     ; test slow mode (CDFLAG)
        ret     z               ; return in case of fast mode

        halt                    ; else wait for Interrupt
        out     ($FD), a        ; switch off NMI (fast mode)
        res     7, (iy+$3B)     ; reset CDFLAG
        ret                     ; return.

; --------------
; THE 'REPORT-F'
; --------------

;; REPORT-F
L02F4:
        rst     08H             ; ERROR-1
        defb    $0E             ; Error Report: No Program Name supplied.

; --------------------------
; THE 'SAVE COMMAND' ROUTINE
; --------------------------
;
;; SAVE
L02F6:
        call    L03A8           ; routine NAME
        jr      c, L02F4        ; back with null name to REPORT-F above.

        ex      de, hl          ;
        ld      de, $12CB       ; five seconds timing value

;; HEADER
L02FF:
        call    L0F46           ; routine BREAK-1
        jr      nc, L0332       ; to BREAK-2

;; DELAY-1
L0304:
        djnz    L0304           ; to DELAY-1

        dec     de              ;
        ld      a, d            ;
        or      e               ;
        jr      nz, L02FF       ; back for delay to HEADER

;; OUT-NAME
L030B:
        call    L031E           ; routine OUT-BYTE
        bit     7, (hl)         ; test for inverted bit.
        inc     hl              ; address next character of name.
        jr      z, L030B        ; back if not inverted to OUT-NAME

; now start saving the system variables onwards.

        ld      hl, $4009       ; set start of area to VERSN thereby
                                ; preserving RAMTOP etc.
;; OUT-PROG
L0316:
        call    L031E           ; routine OUT-BYTE

        call    L01FC           ; routine LOAD/SAVE         >>

        jr      L0316           ; loop back to OUT-PROG

; -------------------------
; THE 'OUT-BYTE' SUBROUTINE
; -------------------------
; This subroutine outputs a byte a bit at a time to a domestic tape recorder.

;; OUT-BYTE
L031E:
        ld      e, (hl)         ; fetch byte to be saved.
        scf                     ; set carry flag - as a marker.

;; EACH-BIT
L0320:
        rl      e               ;  C < 76543210 < C
        ret     z               ; return when the marker bit has passed
                                ; right through.            >>

        sbc     a, a            ; $FF if set bit or $00 with no carry.
        and     $05             ; $05           $00
        add     a, $04          ; $09           $04
        ld      c, a            ; transfer timer to C. a set bit has a longer
                                ; pulse than a reset bit.
;; PULSES
L0329:
        out     ($FF), a        ; pulse to cassette.
        ld      b, $23          ; set timing constant

;; DELAY-2
L032D:
        djnz    L032D           ; self-loop to DELAY-2

        call    L0F46           ; routine BREAK-1 test for BREAK key.

;; BREAK-2
L0332:
        jr      nc, L03A6       ; forward with break to REPORT-D

        ld      b, $1E          ; set timing value.

;; DELAY-3
L0336:
        djnz    L0336           ; self-loop to DELAY-3

        dec     c               ; decrement counter
        jr      nz, L0329       ; loop back to PULSES

;; DELAY-4
L033B:  and a                   ; clear carry for next bit test.
        djnz    L033B           ; self loop to DELAY-4 (B is zero - 256)

        jr      L0320           ; loop back to EACH-BIT

; --------------------------
; THE 'LOAD COMMAND' ROUTINE
; --------------------------
;
;; LOAD
L0340:
        call    L03A8           ; routine NAME

; DE points to start of name in RAM.

        rl      d               ; pick up carry
        rrc     d               ; carry now in bit 7.

;; NEXT-PROG
L0347:
        call    L034C           ; routine IN-BYTE
        jr      L0347           ; loop to NEXT-PROG

; ------------------------
; THE 'IN-BYTE' SUBROUTINE
; ------------------------

;; IN-BYTE
L034C:
        ld      c, $01          ; prepare an eight counter 00000001.

;; NEXT-BIT
L034E:
        ld      b, $00          ; set counter to 256

;; BREAK-3
L0350:
        ld      a, $7F          ; read the keyboard row
        in      a, ($FE)        ; with the SPACE key.

        out     ($FF), a        ; output signal to screen.

        rra                     ; test for SPACE pressed.
        jr      nc, L03A2       ; forward if so to BREAK-4

        rla                     ; reverse above rotation
        rla                     ; test tape bit.
        jr      c, L0385        ; forward if set to GET-BIT

        djnz    L0350           ; loop back to BREAK-3

        pop     af              ; drop the return address.
        cp      d               ; ugh.

;; RESTART
L0361:
        jp      nc, L03E5       ; jump forward to INITIAL if D is zero
                                ; to reset the system
                                ; if the tape signal has timed out for example
                                ; if the tape is stopped. Not just a simple
                                ; report as some system variables will have
                                ; been overwritten.

        ld      h, d            ; else transfer the start of name
        ld      l, e            ; to the HL register

;; IN-NAME
L0366:
        call    L034C           ; routine IN-BYTE is sort of recursion for name
                                ; part. received byte in C.
        bit     7, d            ; is name the null string ?
        ld      a, c            ; transfer byte to A.
        jr      nz, L0371       ; forward with null string to MATCHING

        cp      (hl)            ; else compare with string in memory.
        jr      nz, L0347       ; back with mis-match to NEXT-PROG
                                ; (seemingly out of subroutine but return
                                ; address has been dropped).
;; MATCHING
L0371:
        inc     hl              ; address next character of name
        rla                     ; test for inverted bit.
        jr      nc, L0366       ; back if not to IN-NAME

; the name has been matched in full.
; proceed to load the data but first increment the high byte of E_LINE, which
; is one of the system variables to be loaded in. Since the low byte is loaded
; before the high byte, it is possible that, at the in-between stage, a false
; value could cause the load to end prematurely - see  LOAD/SAVE check.

        inc     (iy+$15)        ; increment system variable E_LINE_hi.
        ld      hl, $4009       ; start loading at system variable VERSN.

;; IN-PROG
L037B:
        ld      d, b            ; set D to zero as indicator.
        call    L034C           ; routine IN-BYTE loads a byte

        ld      (hl), c         ; insert assembled byte in memory.
        call    L01FC           ; routine LOAD/SAVE         >>

        jr      L037B           ; loop back to IN-PROG
; ---

; this branch assembles a full byte before exiting normally
; from the IN-BYTE subroutine.

;; GET-BIT
L0385:
        push    de              ; save the
        ld      e, $94          ; timing value.

;; TRAILER
L0388:
        ld      b, $1A          ; counter to twenty six.

;; COUNTER
L038A:
        dec     e               ; decrement the measuring timer.
        in      a, ($FE)        ; read the
        rla                     ;
        bit     7, e            ;
        ld      a, e            ;
        jr      c, L0388        ; loop back with carry to TRAILER

        djnz    L038A           ; to COUNTER

        pop     de              ;
        jr      nz, L039C       ; to BIT-DONE

        cp      $56             ;
        jr      nc, L034E       ; to NEXT-BIT

;; BIT-DONE
L039C:
        ccf                     ; complement carry flag
        rl      c               ;
        jr      nc, L034E       ; to NEXT-BIT

        ret                     ; return with full byte.
; ---

; if break is pressed while loading data then perform a reset.
; if break pressed while waiting for program on tape then OK to break.

;; BREAK-4
L03A2:
        ld      a, d            ; transfer indicator to A.
        and     a               ; test for zero.
        jr      z, L0361        ; back if so to RESTART

;; REPORT-D
L03A6:
        rst     08H             ; ERROR-1
        defb    $0C             ; Error Report: BREAK - CONT repeats

; -----------------------------
; THE 'PROGRAM NAME' SUBROUTINE
; -----------------------------
;
;; NAME
L03A8:
        call    SCANNING        ; routine SCANNING
        ld      a, ($4001)      ; sv FLAGS
        add     a, a            ;
        jp      m, L0D9A        ; to REPORT-C

        pop     hl              ;
        ret     nc              ;

        push    hl              ;
        call    L02E7           ; routine SET-FAST

        call    STK_FETCH       ; routine STK-FETCH

        ld      h, d            ;
        ld      l, e            ;
        dec     c               ;
        ret     m               ;

        add     hl, bc          ;
        set     7, (hl)         ;
        ret                     ;

; -------------------------
; THE 'NEW' COMMAND ROUTINE
; -------------------------
;
;; NEW
L03C3:
        call    L02E7           ; routine SET-FAST

        ld      bc, ($4004)     ; fetch value of system variable RAMTOP
        dec     bc              ; point to last system byte.

; -----------------------
; THE 'RAM CHECK' ROUTINE
; -----------------------
;
;; RAM-CHECK
L03CB:
        ld      h, b            ;
        ld      l, c            ;
        ld      a, $3F          ;

;; RAM-FILL
L03CF:
        ld      (hl), $02       ;
        dec     hl              ;
        cp      h               ;
        jr      nz, L03CF       ; to RAM-FILL

;; RAM-READ
L03D5:
        and     a               ;
        sbc     hl, bc          ;
        add     hl, bc          ;
        inc     hl              ;
        jr      nc, L03E2       ; to SET-TOP

        dec     (hl)            ;
        jr      z, L03E2        ; to SET-TOP

        dec     (hl)            ;
        jr      z, L03D5        ; to RAM-READ

;; SET-TOP
L03E2:
        ld      ($4004), hl     ; set system variable RAMTOP to first byte
                                ; above the BASIC system area.
; ----------------------------
; THE 'INITIALIZATION' ROUTINE
; ----------------------------
;
;; INITIAL
L03E5:  ld hl, ($4004)          ; fetch system variable RAMTOP.
        dec     hl              ; point to last system byte.
        ld      (hl), $3E       ; make GOSUB end-marker $3E - too high for
                                ; high order byte of line number.
                                ; (was $3F on ZX80)
        dec     hl              ; point to unimportant low-order byte.
        ld      sp, hl          ; and initialize the stack-pointer to this
                                ; location.
        dec     hl              ; point to first location on the machine stack
        dec     hl              ; which will be filled by next CALL/PUSH.
        ld      ($4002), hl     ; set the error stack pointer ERR_SP to
                                ; the base of the now empty machine stack.

; Now set the I register so that the video hardware knows where to find the
; character set. This ROM only uses the character set when printing to
; the ZX Printer. The TV picture is formed by the external video hardware.
; Consider also, that this 8K ROM can be retro-fitted to the ZX80 instead of
; its original 4K ROM so the video hardware could be on the ZX80.

        ld      a, $1E          ; address for this ROM is $1E00.
        ld      i, a            ; set I register from A.
        im      1               ; select Z80 Interrupt Mode 1.

        ld      iy, $4000       ; set IY to the start of RAM so that the
                                ; system variables can be indexed.
        ld      (iy+$3B), $40   ; set CDFLAG 0100 0000. Bit 6 indicates
                                ; Compute and Display required.

        ld      hl, $407D       ; The first location after System Variables -
                                ; 16509 decimal.
        ld      ($400C), hl     ; set system variable D_FILE to this value.
        ld      b, $19          ; prepare minimal screen of 24 NEWLINEs
                                ; following an initial NEWLINE.
;; LINE
L0408:  ld (hl), $76            ; insert NEWLINE (HALT instruction)
        inc     hl              ; point to next location.
        djnz    L0408           ; loop back for all twenty five to LINE

        ld      ($4010), hl     ; set system variable VARS to next location

        call    L149A           ; routine CLEAR sets $80 end-marker and the
                                ; dynamic memory pointers E_LINE, STKBOT and
                                ; STKEND.
;; N/L-ONLY
L0413:  call L14AD              ; routine CURSOR-IN inserts the cursor and
                                ; end-marker in the Edit Line also setting
                                ; size of lower display to two lines.

        call    L0207           ; routine SLOW/FAST selects COMPUTE and DISPLAY

; ---------------------------
; THE 'BASIC LISTING' SECTION
; ---------------------------
;
;; UPPER
L0419:  call L0A2A              ; routine CLS
        ld      hl, ($400A)     ; sv E_PPC
        ld      de, ($4023)     ; sv S_TOP
        and     a               ;
        sbc     hl, de          ;
        ex      de, hl          ;
        jr      nc, L042D       ; to ADDR-TOP

        add     hl, de          ;
        ld      ($4023), hl     ; sv S_TOP
;
;; ADDR-TOP
L042D:  call L09D8              ; routine LINE-ADDR
        jr      z, L0433        ; to LIST-TOP

        ex      de, hl          ;
;
;; LIST-TOP
L0433:  call L073E              ; routine LIST-PROG
        dec     (iy+$1E)        ; sv BERG
        jr      nz, L0472       ; to LOWER

        ld      hl, ($400A)     ; sv E_PPC
        call    L09D8           ; routine LINE-ADDR
        ld      hl, ($4016)     ; sv CH_ADD
        scf                     ; Set Carry Flag
        sbc     hl, de          ;
        ld      hl, $4023       ; sv S_TOP_lo
        jr      nc, L0457       ; to INC-LINE

        ex      de, hl          ;
        ld      a, (hl)         ;
        inc     hl              ;
        ldi                     ;
        ld      (de), a         ;
        jr      L0419           ; to UPPER
;
;; DOWN-KEY
L0454:  ld hl, $400A            ; sv E_PPC_lo

;; INC-LINE
L0457:  ld e, (hl)              ;
        inc     hl              ;
        ld      d, (hl)         ;
        push    hl              ;
        ex      de, hl          ;
        inc     hl              ;
        call    L09D8           ; routine LINE-ADDR
        call    L05BB           ; routine LINE-NO
        pop     hl              ;

;; KEY-INPUT
L0464:  bit 5, (iy+$2D)         ; sv FLAGX
        jr      nz, L0472       ; forward to LOWER

        ld      (hl), d         ;
        dec     hl              ;
        ld      (hl), e         ;
        jr      L0419           ; to UPPER

; ----------------------------
; THE 'EDIT LINE COPY' SECTION
; ----------------------------
; This routine sets the edit line to just the cursor when
; 1) There is not enough memory to edit a BASIC line.
; 2) The edit key is used during input.
; The entry point LOWER
;
;; EDIT-INP
L046F:  call L14AD              ; routine CURSOR-IN sets cursor only edit line.

; ->

;; LOWER
L0472:  ld hl, ($4014)          ; fetch edit line start from E_LINE.

;; EACH-CHAR
L0475:  ld a, (hl)              ; fetch a character from edit line.
        cp      $7E             ; compare to the number marker.
        jr      nz, L0482       ; forward if not to END-LINE

        ld      bc, $0006       ; else six invisible bytes to be removed.
        call    L0A60           ; routine RECLAIM-2
        jr      L0475           ; back to EACH-CHAR
; ---
;
;; END-LINE
L0482:  cp $76                  ;
        inc     hl              ;
        jr      nz, L0475       ; to EACH-CHAR

;; EDIT-LINE
L0487:  call L0537              ; routine CURSOR sets cursor K or L.

;; EDIT-ROOM
L048A:  call L0A1F              ; routine LINE-ENDS
        ld      hl, ($4014)     ; sv E_LINE_lo
        ld      (iy+$00), $FF   ; sv ERR_NR
        call    L0766           ; routine COPY-LINE
        bit     7, (iy+$00)     ; sv ERR_NR
        jr      nz, L04C1       ; to DISPLAY-6

        ld      a, ($4022)      ; sv DF_SZ
        cp      $18             ;
        jr      nc, L04C1       ; to DISPLAY-6

        inc     a               ;
        ld      ($4022), a      ; sv DF_SZ
        ld      b, a            ;
        ld      c, $01          ;
        call    L0918           ; routine LOC-ADDR
        ld      d, h            ;
        ld      e, l            ;
        ld      a, (hl)         ;

;; FREE-LINE
L04B1:  dec hl                  ;
        cp      (hl)            ;
        jr      nz, L04B1       ; to FREE-LINE

        inc     hl              ;
        ex      de, hl          ;
        ld      a, ($4005)      ; sv RAMTOP_hi
        cp      $4D             ;
        call    c, L0A5D        ; routine RECLAIM-1
        jr      L048A           ; to EDIT-ROOM
;
; --------------------------
; THE 'WAIT FOR KEY' SECTION
; --------------------------
;
;; DISPLAY-6
L04C1:  ld hl, $0000            ;
        ld      ($4018), hl     ; sv X_PTR_lo

        ld      hl, $403B       ; system variable CDFLAG
        bit     7, (hl)         ;

        call    z, L0229        ; routine DISPLAY-1

;; SLOW-DISP
L04CF:  bit 0, (hl)             ;
        jr      z, L04CF        ; to SLOW-DISP

        ld      bc, ($4025)     ; sv LAST_K
        call    L0F4B           ; routine DEBOUNCE
        call    L07BD           ; routine DECODE

        jr      nc, L0472       ; back to LOWER
;
; -------------------------------
; THE 'KEYBOARD DECODING' SECTION
; -------------------------------
;   The decoded key value is in E and HL points to the position in the
;   key table. D contains zero.

;; K-DECODE
L04DF:  ld a, ($4006)           ; Fetch value of system variable MODE
        dec     a               ; test the three values together

        jp      m, L0508        ; forward, if was zero, to FETCH-2

        jr      nz, L04F7       ; forward, if was 2, to FETCH-1

;   The original value was one and is now zero.

        ld      ($4006), a      ; update the system variable MODE

        dec     e               ; reduce E to range $00 - $7F
        ld      a, e            ; place in A
        sub     $27             ; subtract 39 setting carry if range 00 - 38
        jr      c, L04F2        ; forward, if so, to FUNC-BASE

        ld      e, a            ; else set E to reduced value

;; FUNC-BASE
L04F2:  ld hl, L00CC            ; address of K-FUNCT table for function keys.
        jr      L0505           ; forward to TABLE-ADD
; ---

;; FETCH-1
L04F7:  ld a, (hl)              ;
        cp      $76             ;
        jr      z, L052B        ; to K/L-KEY

        cp      $40             ;
        set     7, a            ;
        jr      c, L051B        ; to ENTER

        ld      hl, $00C7       ; (expr reqd)

;; TABLE-ADD
L0505:  add hl, de              ;
        jr      L0515           ; to FETCH-3
; ---

;; FETCH-2
L0508:  ld a, (hl)              ;
        bit     2, (iy+$01)     ; sv FLAGS  - K or L mode ?
        jr      nz, L0516       ; to TEST-CURS

        add     a, $C0          ;
        cp      $E6             ;
        jr      nc, L0516       ; to TEST-CURS

;; FETCH-3
L0515:  ld a, (hl)              ;

;; TEST-CURS
L0516:  cp $F0                  ;
        jp      pe, L052D       ; to KEY-SORT

;; ENTER
L051B:  ld e, a                 ;
        call    L0537           ; routine CURSOR

        ld      a, e            ;
        call    L0526           ; routine ADD-CHAR

;; BACK-NEXT
L0523:  jp L0472                ; back to LOWER

; ------------------------------
; THE 'ADD CHARACTER' SUBROUTINE
; ------------------------------
;
;; ADD-CHAR
L0526:  call L099B              ; routine ONE-SPACE
        ld      (de), a         ;
        ret                     ;
;
; -------------------------
; THE 'CURSOR KEYS' ROUTINE
; -------------------------
;
;; K/L-KEY
L052B:  ld a, $78               ;

;; KEY-SORT
L052D:  ld e, a                 ;
        ld      hl, $0482       ; base address of ED-KEYS (exp reqd)
        add     hl, de          ;
        add     hl, de          ;
        ld      c, (hl)         ;
        inc     hl              ;
        ld      b, (hl)         ;
        push    bc              ;

;; CURSOR
L0537:  ld hl, ($4014)          ; sv E_LINE_lo
        bit     5, (iy+$2D)     ; sv FLAGX
        jr      nz, L0556       ; to L-MODE

;; K-MODE
L0540:  res 2, (iy+$01)         ; sv FLAGS  - Signal use K mode

;; TEST-CHAR
L0544:  ld a, (hl)              ;
        cp      $7F             ;
        ret     z               ; return

        inc     hl              ;
        call    L07B4           ; routine NUMBER
        jr      z, L0544        ; to TEST-CHAR

        cp      $26             ;
        jr      c, L0544        ; to TEST-CHAR

        cp      $de             ;
        jr      z, L0540        ; to K-MODE

;; L-MODE
L0556:  set 2, (iy+$01)         ; sv FLAGS  - Signal use L mode
        jr      L0544           ; to TEST-CHAR
;
; --------------------------
; THE 'CLEAR-ONE' SUBROUTINE
; --------------------------
;
;; CLEAR-ONE
L055C:  ld bc, $0001            ;
        jp      L0A60           ; to RECLAIM-2
;
; ------------------------
; THE 'EDITING KEYS' TABLE
; ------------------------
;
;; ED-KEYS
L0562:  defw L059F              ; Address: $059F ; Address: UP-KEY
        defw    L0454           ; Address: $0454 ; Address: DOWN-KEY
        defw    L0576           ; Address: $0576 ; Address: LEFT-KEY
        defw    L057F           ; Address: $057F ; Address: RIGHT-KEY
        defw    L05AF           ; Address: $05AF ; Address: FUNCTION
        defw    L05C4           ; Address: $05C4 ; Address: EDIT-KEY
        defw    L060C           ; Address: $060C ; Address: N/L-KEY
        defw    L058B           ; Address: $058B ; Address: RUBOUT
        defw    L05AF           ; Address: $05AF ; Address: FUNCTION
        defw    L05AF           ; Address: $05AF ; Address: FUNCTION
;
; -------------------------
; THE 'CURSOR LEFT' ROUTINE
; -------------------------
;
;; LEFT-KEY
L0576:  call L0593              ; routine LEFT-EDGE
        ld      a, (hl)         ;
        ld      (hl), $7F       ;
        inc     hl              ;
        jr      L0588           ; to GET-CODE
;
; --------------------------
; THE 'CURSOR RIGHT' ROUTINE
; --------------------------
;
;; RIGHT-KEY
L057F:  inc hl                  ;
        ld      a, (hl)         ;
        cp      $76             ;
        jr      z, L059D        ; to ENDED-2

        ld      (hl), $7F       ;
        dec     hl              ;
;
;; GET-CODE
L0588:  ld (hl), a              ;
;
;; ENDED-1
L0589:  jr L0523                ; to BACK-NEXT
;
; ----------------------------
; THE patched 'RUBOUT' ROUTINE
; ----------------------------
;
;; RUBOUT
L058B:  call L0593              ; routine LEFT-EDGE
        call    L055C           ; routine CLEAR-ONE
        jr      L0523           ; to BACK-NEXT
;
; --------------------------------
; THE patched 'ED-EDGE' SUBROUTINE
; --------------------------------
;
;; LEFT-EDGE
L0593:  dec hl                  ;
        ld      de, ($4014)     ; sv E_LINE_lo
        ld      a, (de)         ;
        cp      $7F             ;
        ret     nz              ;

        pop     de              ;

;; ENDED-2
L059D:
        jr      L0523           ; to BACK-NEXT
;
; -----------------------
; THE 'CURSOR UP' ROUTINE
; -----------------------
;
;; UP-KEY
L059F:  ld hl, ($400A)          ; sv E_PPC_lo
        call    L09D8           ; routine LINE-ADDR
        ex      de, hl          ;
        call    L05BB           ; routine LINE-NO
        ld      hl, $400B       ; point to system variable E_PPC_hi
        jp      L0464           ; jump back to KEY-INPUT
;
; --------------------------
; THE 'FUNCTION KEY' ROUTINE
; --------------------------
;
;; FUNCTION
L05AF:  ld a, e                 ;
        and     $07             ;
        ld      ($4006), a      ; sv MODE
        jr      L059D           ; back to ENDED-2
;
; ------------------------------------
; THE 'COLLECT LINE NUMBER' SUBROUTINE
; ------------------------------------
;
;; ZERO-DE
L05B7:  ex de, hl               ;
        ld      de, L04C1 + 1   ; $04C2 - a location addressing two zeros.
; ->

;; LINE-NO
L05BB:  ld a, (hl)              ;
        and     $C0             ;
        jr      nz, L05B7       ; to ZERO-DE

        ld      d, (hl)         ;
        inc     hl              ;
        ld      e, (hl)         ;
        ret                     ;
;
; ----------------------
; THE 'EDIT KEY' ROUTINE
; ----------------------
;
;; EDIT-KEY
L05C4:  call L0A1F              ; routine LINE-ENDS clears lower display.

        ld      hl, L046F       ; Address: EDIT-INP
        push    hl              ; ** is pushed as an error looping address.

        bit     5, (iy+$2D)     ; test FLAGX
        ret     nz              ; indirect jump if in input mode
                                ; to L046F, EDIT-INP (begin again).
        ld      hl, ($4014)     ; fetch E_LINE
        ld      ($400E), hl     ; and use to update the screen cursor DF_CC

; so now RST $10 will print the line numbers to the edit line instead of screen.
; first make sure that no newline/out of screen can occur while printing the
; line numbers to the edit line.

        ld      hl, $1821       ; prepare line 0, column 0.
        ld      ($4039), hl     ; update S_POSN with these dummy values.

        ld      hl, ($400A)     ; fetch current line from E_PPC may be a
                                ; non-existent line e.g. last line deleted.
        call    L09D8           ; routine LINE-ADDR gets address or that of
                                ; the following line.
        call    L05BB           ; routine LINE-NO gets line number if any in DE
                                ; leaving HL pointing at second low byte.

        ld      a, d            ; test the line number for zero.
        or      e               ;
        ret     z               ; return if no line number - no program to edit.

        dec     hl              ; point to high byte.
        call    L0AA5           ; routine OUT-NO writes number to edit line.

        inc     hl              ; point to length bytes.
        ld      c, (hl)         ; low byte to C.
        inc     hl              ;
        ld      b, (hl)         ; high byte to B.

        inc     hl              ; point to first character in line.
        ld      de, ($400E)     ; fetch display file cursor DF_CC

        ld      a, $7F          ; prepare the cursor character.
        ld      (de), a         ; and insert in edit line.
        inc     de              ; increment intended destination.

        push    hl              ; * save start of BASIC.

        ld      hl, $001D       ; set an overhead of 29 bytes.
        add     hl, de          ; add in the address of cursor.
        add     hl, bc          ; add the length of the line.
        sbc     hl, sp          ; subtract the stack pointer.

        pop     hl              ; * restore pointer to start of BASIC.

        ret     nc              ; return if not enough room to L046F EDIT-INP.
                                ; the edit key appears not to work.

        ldir                    ; else copy bytes from program to edit line.
                                ; Note. hidden floating point forms are also
                                ; copied to edit line.

        ex      de, hl          ; transfer free location pointer to HL

        pop     de              ; ** remove address EDIT-INP from stack.

        call    L14A6           ; routine SET-STK-B sets STKEND from HL.

        jr      L059D           ; back to ENDED-2 and after 3 more jumps
                                ; to L0472, LOWER.
                                ; Note. The LOWER routine removes the hidden
                                ; floating-point numbers from the edit line.
;
; -------------------------
; THE 'NEWLINE KEY' ROUTINE
; -------------------------
;
;; N/L-KEY
L060C:  call L0A1F              ; routine LINE-ENDS

        ld      hl, L0472       ; prepare address: LOWER

        bit     5, (iy+$2D)     ; sv FLAGX
        jr      nz, L0629       ; to NOW-SCAN

        ld      hl, ($4014)     ; sv E_LINE_lo
        ld      a, (hl)         ;
        cp      $FF             ;
        jr      z, L0626        ; to STK-UPPER

        call    L08E2           ; routine CLEAR-PRB
        call    L0A2A           ; routine CLS

;; STK-UPPER
L0626:  ld hl, L0419            ; Address: UPPER

;; NOW-SCAN
L0629:  push hl                 ; push routine address (LOWER or UPPER).
        call    L0CBA           ; routine LINE-SCAN
        pop     hl              ;
        call    L0537           ; routine CURSOR
        call    L055C           ; routine CLEAR-ONE
        call    L0A73           ; routine E-LINE-NO
        jr      nz, L064E       ; to N/L-INP

        ld      a, b            ;
        or      c               ;
        jp      nz, L06E0       ; to N/L-LINE

        dec     bc              ;
        dec     bc              ;
        ld      ($4007), bc     ; sv PPC_lo
        ld      (iy+$22), $02   ; sv DF_SZ
        ld      de, ($400C)     ; sv D_FILE_lo

        jr      L0661           ; forward to TEST-NULL
; ---
;
;; N/L-INP
L064E:  cp $76                  ;
        jr      z, L0664        ; to N/L-NULL

        ld      bc, ($4030)     ; sv T_ADDR_lo
        call    L0918           ; routine LOC-ADDR
        ld      de, ($4029)     ; sv NXTLIN_lo
        ld      (iy+$22), $02   ; sv DF_SZ
;
;; TEST-NULL
L0661:  rst 18H                 ; GET-CHAR
        cp      $76             ;
;
;; N/L-NULL
L0664:  jp z, L0413             ; to N/L-ONLY

        ld      (iy+$01), $80   ; sv FLAGS
        ex      de, hl          ;
;
;; NEXT-LINE
L066C:  ld ($4029), hl          ; sv NXTLIN_lo
        ex      de, hl          ;
        call    L004D           ; routine TEMP-PTR-2
        call    L0CC1           ; routine LINE-RUN
        res     1, (iy+$01)     ; sv FLAGS  - Signal printer not in use
        ld      a, $C0          ;
        ld      (iy+$19), a     ; sv X_PTR_lo
        call    L14A3           ; routine X-TEMP
        res     5, (iy+$2D)     ; sv FLAGX
        bit     7, (iy+$00)     ; sv ERR_NR
        jr      z, L06AE        ; to STOP-LINE

        ld      hl, ($4029)     ; sv NXTLIN_lo
        and     (hl)            ;
        jr      nz, L06AE       ; to STOP-LINE

        ld      d, (hl)         ;
        inc     hl              ;
        ld      e, (hl)         ;
        ld      ($4007), de     ; sv PPC_lo
        inc     hl              ;
        ld      e, (hl)         ;
        inc     hl              ;
        ld      d, (hl)         ;
        inc     hl              ;
        ex      de, hl          ;
        add     hl, de          ;
        call    L0F46           ; routine BREAK-1
        jr      c, L066C        ; to NEXT-LINE

        ld      hl, $4000       ; sv ERR_NR
        bit     7, (hl)         ;
        jr      z, L06AE        ; to STOP-LINE

        ld      (hl), $0C       ;
;
;; STOP-LINE
L06AE:  bit 7, (iy+$38)         ; sv PR_CC
        call    z, L0871        ; routine COPY-BUFF
        ld      bc, $0121       ;
        call    L0918           ; routine LOC-ADDR
        ld      a, ($4000)      ; sv ERR_NR
        ld      bc, ($4007)     ; sv PPC_lo
        inc     a               ;
        jr      z, L06D1        ; to REPORT

        cp      $09             ;
        jr      nz, L06CA       ; to CONTINUE

        inc     bc              ;
;
;; CONTINUE
L06CA:  ld ($402B), bc          ; sv OLDPPC_lo
        jr      nz, L06D1       ; to REPORT

        dec     bc              ;
;
;; REPORT
L06D1:  call L07EB              ; routine OUT-CODE
        ld      a, $18          ; '/'

        rst     10H             ; PRINT-A
        call    L0A98           ; routine OUT-NUM
        call    L14AD           ; routine CURSOR-IN
        jp      L04C1           ; to DISPLAY-6
; ---
;
;; N/L-LINE
L06E0:  ld ($400A), bc          ; sv E_PPC_lo
        ld      hl, ($4016)     ; sv CH_ADD_lo
        ex      de, hl          ;
        ld      hl, L0413       ; Address: N/L-ONLY
        push    hl              ;
        ld      hl, ($401A)     ; sv STKBOT_lo
        sbc     hl, de          ;
        push    hl              ;
        push    bc              ;
        call    L02E7           ; routine SET-FAST
        call    L0A2A           ; routine CLS
        pop     hl              ;
        call    L09D8           ; routine LINE-ADDR
        jr      nz, L0705       ; to COPY-OVER

        call    L09F2           ; routine NEXT-ONE
        call    L0A60           ; routine RECLAIM-2

;; COPY-OVER
L0705:  pop bc                  ;
        ld      a, c            ;
        dec     a               ;
        or      b               ;
        ret     z               ;

        push    bc              ;
        inc     bc              ;
        inc     bc              ;
        inc     bc              ;
        inc     bc              ;
        dec     hl              ;
        call    L099E           ; routine MAKE-ROOM
        call    L0207           ; routine SLOW/FAST
        pop     bc              ;
        push    bc              ;
        inc     de              ;
        ld      hl, ($401A)     ; sv STKBOT_lo
        dec     hl              ;
        lddr                    ; copy bytes
        ld      hl, ($400A)     ; sv E_PPC_lo
        ex      de, hl          ;
        pop     bc              ;
        ld      (hl), b         ;
        dec     hl              ;
        ld      (hl), c         ;
        dec     hl              ;
        ld      (hl), e         ;
        dec     hl              ;
        ld      (hl), d         ;

        ret                     ; return.
;
; ---------------------------------------
; THE 'LIST' AND 'LLIST' COMMAND ROUTINES
; ---------------------------------------
;
;; LLIST
L072C:  set 1, (iy+$01)         ; sv FLAGS  - signal printer in use
;
;; LIST
L0730:  call FIND_INT           ; routine FIND-INT

        ld      a, b            ; fetch high byte of user-supplied line number.
        and     $3F             ; and crudely limit to range 1-16383.

        ld      h, a            ;
        ld      l, c            ;
        ld      ($400A), hl     ; sv E_PPC_lo
        call    L09D8           ; routine LINE-ADDR
;
;; LIST-PROG
L073E:  ld e, $00               ;

;; UNTIL-END
L0740:  call L0745              ; routine OUT-LINE lists one line of BASIC
                                ; making an early return when the screen is
                                ; full or the end of program is reached.    >>
        jr      L0740           ; loop back to UNTIL-END
;
; -----------------------------------
; THE 'PRINT A BASIC LINE' SUBROUTINE
; -----------------------------------
;
;; OUT-LINE
L0745:  ld bc, ($400A)          ; sv E_PPC_lo
        call    L09EA           ; routine CP-LINES
        ld      d, $92          ;
        jr      z, L0755        ; to TEST-END

        ld      de, $0000       ;
        rl      e               ;

;; TEST-END
L0755:  ld (iy+$1E), e          ; sv BERG
        ld      a, (hl)         ;
        cp      $40             ;
        pop     bc              ;
        ret     nc              ;

        push    bc              ;
        call    L0AA5           ; routine OUT-NO
        inc     hl              ;
        ld      a, d            ;

        rst     10H             ; PRINT-A
        inc     hl              ;
        inc     hl              ;
;
;; COPY-LINE
L0766:  ld ($4016), hl          ; sv CH_ADD_lo
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space

;; MORE-LINE
L076D:  ld bc, ($4018)          ; sv X_PTR_lo
        ld      hl, ($4016)     ; sv CH_ADD_lo
        and     a               ;
        sbc     hl, bc          ;
        jr      nz, L077C       ; to TEST-NUM

        ld      a, $B8          ;

        rst     10H             ; PRINT-A

;; TEST-NUM
L077C:  ld hl, ($4016)          ; sv CH_ADD_lo
        ld      a, (hl)         ;
        inc     hl              ;
        call    L07B4           ; routine NUMBER
        ld      ($4016), hl     ; sv CH_ADD_lo
        jr      z, L076D        ; to MORE-LINE

        cp      $7F             ;
        jr      z, L079D        ; to OUT-CURS

        cp      $76             ;
        jr      z, L07EE        ; to OUT-CH

        bit     6, a            ;
        jr      z, L079A        ; to NOT-TOKEN

        call    L094B           ; routine TOKENS
        jr      L076D           ; to MORE-LINE
; ---
;
;; NOT-TOKEN
L079A:  rst 10H                 ; PRINT-A
        jr      L076D           ; to MORE-LINE
; ---
;
;; OUT-CURS
L079D:  ld a, ($4006)           ; Fetch value of system variable MODE
        ld      b, $AB          ; Prepare an inverse [F] for function cursor.

        and     a               ; Test for zero -
        jr      nz, L07AA       ; forward if not to FLAGS-2

        ld      a, ($4001)      ; Fetch system variable FLAGS.
        ld      b, $B0          ; Prepare an inverse [K] for keyword cursor.
;
;; FLAGS-2
L07AA:  rra                     ; 00000?00 -> 000000?0
        rra                     ; 000000?0 -> 0000000?
        and     $01             ; 0000000?    0000000x

        add     a, b            ; Possibly [F] -> [G]  or  [K] -> [L]

        call    L07F5           ; routine PRINT-SP prints character
        jr      L076D           ; back to MORE-LINE
;
; -----------------------
; THE 'NUMBER' SUBROUTINE
; -----------------------
;
;; NUMBER
L07B4:  cp $7E                  ;
        ret     nz              ;

        inc     hl              ;
        inc     hl              ;
        inc     hl              ;
        inc     hl              ;
        inc     hl              ;
        ret                     ;
;
; --------------------------------
; THE 'KEYBOARD DECODE' SUBROUTINE
; --------------------------------
;
;; DECODE
L07BD:  ld d, $00               ;
        sra     b               ;
        sbc     a, a            ;
        or      $26             ;
        ld      l, $05          ;
        sub     l               ;
;
;; KEY-LINE
L07C7:  add a, l                ;
        scf                     ; Set Carry Flag
        rr      c               ;
        jr      c, L07C7        ; to KEY-LINE

        inc     c               ;
        ret     nz              ;

        ld      c, b            ;
        dec     l               ;
        ld      l, $01          ;
        jr      nz, L07C7       ; to KEY-LINE

        ld      hl, $007D       ; (expr reqd)
        ld      e, a            ;
        add     hl, de          ;
        scf                     ; Set Carry Flag
        ret                     ;
;
; ---------------------------------
; THE patched 'PRINTING' SUBROUTINE
; ---------------------------------
;
;; LEAD-SP
L07DC:  ld a, e                 ;
        and     a               ;
        ret     m               ;

        jr      L07F1           ; to PRINT-CH
; ---
;
;; OUT-DIGIT
L07E1:  xor a                   ;
;
;; DIGIT-INC
L07E2:  add hl, bc              ;
        inc     a               ;
        jr      c, L07E2        ; to DIGIT-INC

        sbc     hl, bc          ;
        dec     a               ;
        jr      z, L07DC        ; to LEAD-SP
;
;; OUT-CODE
L07EB:  ld e, $1C               ;
        add     a, e            ;
;
;; OUT-CH
L07EE:  and a                   ;
        jr      z, L07F5        ; to PRINT-SP
;
;; PRINT-CH
L07F1:  res 0, (iy+$01)         ; update FLAGS - signal leading space permitted
;
;; PRINT-SP
L07F5:  exx                     ;
        push    hl              ;

        call    prn_test        ;

        pop     hl              ;
        exx                     ;
        ret                     ;
;
;   ==============================================================
;   entry points of the new 'PRINT A FLOATING-POINT NUMBER' subr.
;
prnt_num
        inc     a               ; offset1 (+1) - code of zero (-27)
prnt_dot
        add     a, $1B          ; offset2 (+27) - code of '.'

        jr      L07F5           ; print
;
;   ==============================================================
;
prn_test
        bit     1, (iy+$01)     ; test FLAGS - is printer in use ?
        jr      nz, L0851       ; routine LPRINT-CH
; ---
;
;; ENTER-CH
L0808:  ld d, a                 ;
        ld      bc, ($4039)     ; sv S_POSN_x
        ld      a, c            ;
        cp      $21             ;
        jr      z, L082C        ; to TEST-LOW
;
;; TEST-N/L
L0812:  ld a, $76               ;
        cp      d               ;
        jr      z, L0847        ; to WRITE-N/L

        ld      hl, ($400E)     ; sv DF_CC_lo
        cp      (hl)            ;
        ld      a, d            ;
        jr      nz, L083E       ; to WRITE-CH

        dec     c               ;
        jr      nz, L083A       ; to EXPAND-1

        inc     hl              ;
        ld      ($400E), hl     ; sv DF_CC_lo
        ld      c, $21          ;
        dec     b               ;
        ld      ($4039), bc     ; sv S_POSN_x
;
;; TEST-LOW
L082C:  ld a, b                 ;
        cp      (iy+$22)        ; sv DF_SZ
        jr      z, L0835        ; to REPORT-5

        and     a               ;
        jr      nz, L0812       ; to TEST-N/L
;
;; REPORT-5
L0835:  ld l, $04               ; 'No more room on screen'
        jp      L0058           ; to ERROR-3
; ---
;
;; EXPAND-1
L083A:  call L099B              ; routine ONE-SPACE
        ex      de, hl          ;
;
;; WRITE-CH
L083E:  ld (hl), a              ;
        inc     hl              ;
        ld      ($400E), hl     ; sv DF_CC_lo
        dec     (iy+$39)        ; sv S_POSN_x
        ret                     ;
; ---
;
;; WRITE-N/L
L0847:
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space
loc_nxt0
        dec     b               ; set line counter
loc_pos0
        ld      c, $21          ; point the leading N/L character
        jp      L0918           ; to (quick) LOC-ADDR
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
L0851:  cp $76                  ; compare to NEWLINE.
        jr      z, L0871        ; forward if so to COPY-BUFF

        ld      c, a            ; take a copy of the character in C.
        ld      a, ($4038)      ; fetch print location from PR_CC
        and     $7F             ; ignore bit 7 to form true position.
        cp      $5C             ; compare to 33rd location

        ld      l, a            ; form low-order byte.
        ld      h, $40          ; the high-order byte is fixed.

        call    z, L0871        ; routine COPY-BUFF to send full buffer to
                                ; the printer if first 32 bytes full.
                                ; (this will reset HL to start.)

        ld      (hl), c         ; place character at location.
        inc     l               ; increment - will not cross a 256 boundary.
        ld      (iy+$38), l     ; update system variable PR_CC
                                ; automatically resetting bit 7 to show that
                                ; the buffer is not empty.
        ret                     ; return.
;
; --------------------------
; THE 'COPY' COMMAND ROUTINE
; --------------------------
; The full character-mapped screen is copied to the ZX-Printer.
; All twenty-four text/graphic lines are printed.
;
;; COPY
L0869:  ld d, $16               ; prepare to copy twenty four text lines.
        ld      hl, ($400C)     ; set HL to start of display file from D_FILE.
        inc     hl              ;
        jr      L0876           ; forward to COPY*D
; ---
;
; A single character-mapped printer buffer is copied to the ZX-Printer.
;
;; COPY-BUFF
L0871:  ld d, $01               ; prepare to copy a single text line.
        ld      hl, $403C       ; set HL to start of printer buffer PRBUFF.
;
; both paths converge here.
;
;; COPY*D
L0876:  call L02E7              ; routine SET-FAST

        push    bc              ; *** preserve BC throughout.
                                ; a pending character may be present
                                ; in C from LPRINT-CH
;
;; COPY-LOOP
L087A:  push hl                 ; save first character of line pointer. (*)
        xor     a               ; clear accumulator.
        ld      e, a            ; set pixel line count, range 0-7, to zero.
;
; this inner loop deals with each horizontal pixel line.
;
;; COPY-TIME
L087D:  out ($FB), a            ; bit 2 reset starts the printer motor
                                ; with an inactive stylus - bit 7 reset.
        pop     hl              ; pick up first character of line pointer (*)
                                ; on inner loop.
;
;; COPY-BRK
L0880:  call L0F46              ; routine BREAK-1
        jr      c, L088A        ; forward with no keypress to COPY-CONT
;
; else A will hold 11111111 0
;
        rra                     ; 0111 1111
        out     ($FB), a        ; stop ZX printer motor, de-activate stylus.
;
;; REPORT-D2
L0888:  rst 08H                 ; ERROR-1
        defb    $0C             ; Error Report: BREAK - CONT repeats
; ---
;
;; COPY-CONT
L088A:  in a, ($FB)             ; read from printer port.
        add     a, a            ; test bit 6 and 7
        jp      m, L08DE        ; jump forward with no printer to COPY-END

        jr      nc, L0880       ; back if stylus not in position to COPY-BRK

        push    hl              ; save first character of line pointer (*)
        push    de              ; ** preserve character line and pixel line.

        ld      a, d            ; text line count to A?
        cp      $02             ; sets carry if last line.
        sbc     a, a            ; now $FF if last line else zero.
;
; now cleverly prepare a printer control mask setting bit 2 (later moved to 1)
; of D to slow printer for the last two pixel lines ( E = 6 and 7)
;
        and     e               ; and with pixel line offset 0-7
        rlca                    ; shift to left.
        and     e               ; and again.
        ld      d, a            ; store control mask in D.
;
;; COPY-NEXT
L089C:  ld c, (hl)              ; load character from screen or buffer.
        ld      a, c            ; save a copy in C for later inverse test.
        inc     hl              ; update pointer for next time.
        cp      $76             ; is character a NEWLINE ?
        jr      z, L08C7        ; forward, if so, to COPY-N/L

        push    hl              ; * else preserve the character pointer.

        sla     a               ; (?) multiply by two
        add     a, a            ; multiply by four
        add     a, a            ; multiply by eight

        ld      h, $0F          ; load H with half the address of character set.
        rl      h               ; now $1E or $1F (with carry)
        add     a, e            ; add byte offset 0-7
        ld      l, a            ; now HL addresses character source byte

        rl      c               ; test character, setting carry if inverse.
        sbc     a, a            ; accumulator now $00 if normal, $FF if inverse.

        xor     (hl)            ; combine with bit pattern at end or ROM.
        ld      c, a            ; transfer the byte to C.
        ld      b, $08          ; count eight bits to output.
;
;; COPY-BITS
L08B5:  ld a, d                 ; fetch speed control mask from D.
        rlc     c               ; rotate a bit from output byte to carry.
        rra                     ; pick up in bit 7, speed bit to bit 1
        ld      h, a            ; store aligned mask in H register.

;; COPY-WAIT
L08BA:  in a, ($FB)             ; read the printer port
        rra                     ; test for alignment signal from encoder.
        jr      nc, L08BA       ; loop if not present to COPY-WAIT

        ld      a, h            ; control byte to A.
        out     ($FB), a        ; and output to printer port.
        djnz    L08B5           ; loop for all eight bits to COPY-BITS

        pop     hl              ; * restore character pointer.
        jr      L089C           ; back for adjacent character line to COPY-NEXT
; ---
;
; A NEWLINE has been encountered either following a text line or as the
; first character of the screen or printer line.
;
;; COPY-N/L
L08C7:  in a, ($FB)             ; read printer port.
        rra                     ; wait for encoder signal.
        jr      nc, L08C7       ; loop back if not to COPY-N/L

        ld      a, d            ; transfer speed mask to A.
        rrca                    ; rotate speed bit to bit 1.
                                ; bit 7, stylus control is reset.
        out     ($FB), a        ; set the printer speed.

        pop     de              ; ** restore character line and pixel line.
        inc     e               ; increment pixel line 0-7.
        bit     3, e            ; test if value eight reached.
        jr      z, L087D        ; back if not to COPY-TIME

; eight pixel lines, a text line have been completed.

        pop     bc              ; lose the now redundant first character
                                ; pointer
        dec     d               ; decrease text line count.
        jr      nz, L087A       ; back if not zero to COPY-LOOP

        ld      a, $04          ; stop the already slowed printer motor.
        out     ($FB), a        ; output to printer port.

;; COPY-END
L08DE:  call L0207              ; routine SLOW/FAST
        pop     bc              ; *** restore preserved BC.
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
        ld      a, $3C+$80      ; signal the printer buffer is clear (bit 7)
        ld      ($4038), a      ; update one-byte system variable PR_CC

        ld      hl, $405D       ; address fixed end of PRBUFF (+1)
;
;   ------------------------- the new CLS routine joins here
clr_line
        dec     hl              ; set pointer
;
;   ------------------------- the new SCROLL routine joins here
clr_scrl
        ld      b, $20          ; prepare to blank 32 preceding characters.
        xor     a               ;
        ld      (hl), $76       ; place a newline at last position.

;; PRB-BYTES
clr_prbf
        dec     hl              ; decrement address.
        ld      (hl), a         ; place a zero byte.
        djnz    clr_prbf        ; loop for all thirty-two to PRB-BYTES

        ret                     ; return.
;
; -------------------------
; THE 'PRINT AT' SUBROUTINE
; -------------------------
;
;; PRINT-AT
L08F5:  ld a, $17               ; test, if Y>23
        sub     b               ;
        jr      c, L0905        ; yes? -> to WRONG-VAL
;
;; TEST-VAL
L08FA:  cp (iy+$22)             ; compare to DF_SZ
        jp      c, L0835        ; out of screen? -> to REPORT-5

        inc     a               ; else
        ld      b, a            ; Y=24-Y
;
;   ------------------------- the new PLOT routine joins here
prn_at_x
        ld      a, $1F          ; test, if X>31
        sub     c               ;
;
;; WRONG-VAL
L0905:  jp c, L0EAD             ; yes? -> to REPORT-B

        add     a, $02          ; else
        ld      c, a            ; X=33-X
;
;; SET-FIELD
L090B:  bit 1, (iy+$01)         ; sv FLAGS  - Is printer in use?
        jr      z, L0918        ; to LOC-ADDR

        ld      a, $5D          ;
        sub     c               ;
        ld      ($4038), a      ; save in PR_CC
        ret                     ;
;
;   ========================================================
;
; ----------------------------------
; THE quick 'LOCATE ADDRESS' ROUTINE
; ----------------------------------
;
;; LOC-ADDR
L0918:  ld ($4039), bc          ; sv S_POSN

        ld      hl, $1922       ; the limits (y: 25, x: 34)
        ld      d, c            ; save old 'X' value
        and     a               ; transform the coordinates
        sbc     hl, bc          ; in to the necessary format
        ld      b, h            ; Y=25-Y
        ld      c, l            ; X=34-X

        call    loc_xpnd        ; if D-File is collapsed, then
                                ; it returns with address of
                                ; D-File in HL

        ld      a, (hl)         ; HL points the 1st N/L char ($76)
look_fw:
        cp      (hl)            ; look for the next N/L char ($76)
        inc     hl              ; set pointer
        jr      nz, look_fw     ; to LOOK-FW, if no match

        djnz    look_fw         ; else set line counter (B) and jump
                                ; back to LOOK-FW if it is nonzero

        cpir                    ; look for the next N/L char ($76)
        dec     hl              ; HL now points a N/L or addresses
                                ; the requested coorinates in D-File
        ld      ($400E), hl     ; save pointer in DF_CC
        scf                     ; Set Carry Flag
        ret     po              ; return, if not found N/L

        dec     d               ; if a N/L was requested (X was 1),
        ret     z               ; then return

        push    bc              ; else save byte counter
        call    L099E           ; routine MAKE-ROOM expands the D-File
        pop     bc              ; restore byte counter

        ld      b, c            ; set up B as byte counter
        ld      h, d            ; save the pointer
        ld      l, e            ; in HL

        xor     a               ; the 'SPACE' character
expand2:                        ;
        ld      (de), a         ; fill the new
        dec     de              ; area with 'SPACE'-s
        djnz    expand2         ; to EXPAND-2

        inc     hl              ; set the new pointer
set_DFCC
        ld      ($400E), hl     ; save pointer in DF_CC
        ret
;
;   ========================================================
;
; ------------------------------
; THE 'EXPAND TOKENS' SUBROUTINE
; ------------------------------
;
;; TOKENS
L094B:  push af                 ;
        call    L0975           ; routine TOKEN-ADD
        jr      nc, L0959       ; to ALL-CHARS

        bit     0, (iy+$01)     ; sv FLAGS  - Leading space if set
        jr      nz, L0959       ; to ALL-CHARS

        xor     a               ;

        rst     10H             ; PRINT-A
;
;; ALL-CHARS
L0959:  ld a, (bc)              ;
        and     $3F             ;

        rst     10H             ; PRINT-A
        ld      a, (bc)         ;
        inc     bc              ;
        add     a, a            ;
        jr      nc, L0959       ; to ALL-CHARS

        pop     bc              ;
        bit     7, b            ;
        ret     z               ;

        cp      $1A             ;
        jr      z, L096D        ; to TRAIL-SP

        cp      $38             ;
        ret     c               ;
;
;; TRAIL-SP
L096D:  xor a                   ;
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space
        jp      L07F5           ; to PRINT-SP
; ---
;
;; TOKEN-ADD
L0975:  push hl                 ;
        ld      hl, L0111       ; Address of TOKENS
        bit     7, a            ;
        jr      z, L097F        ; to TEST-HIGH

        and     $3F             ;
;
;; TEST-HIGH
L097F:  cp $43                  ;
        jr      nc, L0993       ; to FOUND

        ld      b, a            ;
        inc     b               ;
;
;; WORDS
L0985:  bit 7, (hl)             ;
        inc     hl              ;
        jr      z, L0985        ; to WORDS

        djnz    L0985           ; to WORDS

        bit     6, a            ;
        jr      nz, L0992       ; to COMP-FLAG

        cp      $18             ;
;
;; COMP-FLAG
L0992:  ccf                     ; Complement Carry Flag

;; FOUND
L0993:  ld b, h                 ;
        ld      c, l            ;
        pop     hl              ;
        ret     nc              ;

        ld      a, (bc)         ;
        add     a, $E4          ;
        ret                     ;
;
; --------------------------
; THE 'ONE SPACE' SUBROUTINE
; --------------------------
;
;; ONE-SPACE
L099B:  ld bc, $0001            ;

; --------------------------
; THE 'MAKE ROOM' SUBROUTINE
; --------------------------
;
;; MAKE-ROOM
L099E:  push hl                 ;
        call    TEST_ROOM       ; routine TEST-ROOM
        pop     hl              ;
        call    L09AD           ; routine POINTERS
        ld      hl, ($401C)     ; sv STKEND
        ex      de, hl          ;
        lddr                    ; Copy Bytes
        ret                     ;
;
; ---------------------------------
; THE patched 'POINTERS' SUBROUTINE
; ---------------------------------
;
;; POINTERS
L09AD:  push af                 ;
        push    hl              ;
        ld      hl, $400C       ; sv D_FILE_lo
        ld      a, $09          ;
;
;; NEXT-PTR
L09B4:  ld e, (hl)              ; LSB of the sv
        inc     hl              ; then
        ld      d, (hl)         ; MSB of the sv

        ex      (sp), hl        ;
        and     a               ;
        sbc     hl, de          ;
        add     hl, de          ;
        ex      (sp), hl        ;
        jr      nc, L09CA       ; to PTR-DONE

        push    de              ; save the old value
        ex      de, hl          ;
        add     hl, bc          ; the offset
        ex      de, hl          ;
        ld      (hl), d         ; save the MSB
        dec     hl              ; then the
        ld      (hl), e         ; LSB of the
        inc     hl              ; new value
        pop     de              ; restore the old value
;
;; PTR-DONE
L09CA:  inc hl                  ; next sv
        dec     a               ;
        jr      nz, L09B4       ; to NEXT-PTR

        ex      de, hl          ;
        pop     de              ;
        pop     af              ;

        call    L0A17           ; -> DIFFER

        inc     bc              ;
        ret                     ;
;
;   ===============================================
;   in "SLOW" mode the DISPLAY-1 routine joins here
;   if FRAMES is in use by PAUSE
jp_DISP2
        push    hl              ; restore stack (HL = 0 !!!)
        jp      L023E           ; back to DISPLAY-2
;
; -----------------------------
; THE 'LINE ADDRESS' SUBROUTINE
; -----------------------------
;
;; LINE-ADDR
L09D8:  push hl                 ;
        ld      hl, $407D       ;
        ld      d, h            ;
        ld      e, l            ;
;
;; NEXT-TEST
L09DE:  pop bc                  ;
        call    L09EA           ; routine CP-LINES
        ret     nc              ;

        push    bc              ;
        call    L09F2           ; routine NEXT-ONE
        ex      de, hl          ;
        jr      L09DE           ; to NEXT-TEST
;
; -------------------------------------
; THE 'COMPARE LINE NUMBERS' SUBROUTINE
; -------------------------------------
;
;; CP-LINES
L09EA:  ld a, (hl)              ;
        cp      b               ;
        ret     nz              ;

        inc     hl              ;
        ld      a, (hl)         ;
        dec     hl              ;
        cp      c               ;
        ret                     ;
;
; --------------------------------------
; THE 'NEXT LINE OR VARIABLE' SUBROUTINE
; --------------------------------------
;
;; NEXT-ONE
L09F2:  push hl                 ;
        ld      a, (hl)         ;
        cp      $40             ;
        jr      c, L0A0F        ; to LINES

        bit     5, a            ;
        jr      z, L0A10        ; forward to NEXT-O-4

        add     a, a            ;
        jp      m, L0A01        ; to NEXT+FIVE

        ccf                     ; Complement Carry Flag
;
;; NEXT+FIVE
L0A01:  ld bc, $0005            ;
        jr      nc, L0A08       ; to NEXT-LETT

        ld      c, $11          ;
;
;; NEXT-LETT
L0A08:  rla                     ;
        inc     hl              ;
        ld      a, (hl)         ;
        jr      nc, L0A08       ; to NEXT-LETT

        jr      L0A15           ; to NEXT-ADD
; ---
;
;; LINES
L0A0F:  inc hl                  ;
;
;; NEXT-O-4
L0A10:  inc hl                  ;
        ld      c, (hl)         ;
        inc     hl              ;
        ld      b, (hl)         ;
        inc     hl              ;
;
;; NEXT-ADD
L0A15:  add hl, bc              ;
        pop     de              ;
;
; ---------------------------
; THE 'DIFFERENCE' SUBROUTINE
; ---------------------------
;
;; DIFFER
L0A17:  and a                   ;
        sbc     hl, de          ;
        ld      b, h            ;
        ld      c, l            ;
        add     hl, de          ;
        ex      de, hl          ;
        ret                     ;
;
; ----------------------------------
; THE patched 'LINE-ENDS' SUBROUTINE
; ----------------------------------
;
;; LINE-ENDS
L0A1F:  ld b, (iy+$22)          ; sv DF_SZ
        push    bc              ;
        call    L0A2C           ; routine B-LINES
        pop     bc              ;

        jp      loc_nxt0        ; dec b -> ld c,$21 ==> retun via LOC-ADDR
;
; --------------------------------------------
; THE renewed 'CLS' COMMAND ROUTINE (51 bytes)
; --------------------------------------------
;
;; CLS
L0A2A:  ld b, $18               ; set line counter: 24 lines to clear
;
;; B-LINES
L0A2C:  res 1, (iy+$01)         ; sv FLAGS - Signal printer not in use

        push    bc              ; save line counter
        call    loc_pos0        ; ld c,$21 --> LOC-ADDR
        pop     bc              ; restore line counter
        ld      c, b            ; save counter

        bit     5, (iy+$3B)     ; sv CDFLAG - test expanded D-FILE
        jr      z, cls_frst     ;

        ld      de, 33          ; size of a line
cls_addr
        add     hl, de          ; set address
        djnz    cls_addr        ; until end of D-FILE
clr_next
        call    clr_line        ; clear a line - part of new CLEAR-PRB
        dec     c               ; set counter
        jr      nz, clr_next    ; done?

        ret
;
;   ----------------------------------------
cls_frst
        inc     b               ; set line counter
        dec     hl              ; points the previous N/L
        ld      a, (hl)         ; fetch a N/L character
next_nl
        ld      (hl), a         ; then
        inc     hl              ; make a compressed
        djnz    next_nl         ; D-File

        ld      de, ($4010)     ; sv VARS

        ld      a, ($4005)      ; sv RAMTOP_hi
        cp      $4D             ; >3KB?
        jp      nc, cls_chck    ; yes, check room

        ex      de, hl          ; else return w. collapsed D-FILE via
;
; ----------------------------
; THE 'RECLAIMING' SUBROUTINES
; ----------------------------
;
;; RECLAIM-1
L0A5D:  call L0A17              ; routine DIFFER

;; RECLAIM-2
L0A60:  push bc                 ;
        ld      a, b            ;
        cpl                     ;
        ld      b, a            ;
        ld      a, c            ;
        cpl                     ;
        ld      c, a            ;
        inc     bc              ;
        call    L09AD           ; routine POINTERS
        ex      de, hl          ;
        pop     hl              ;
        add     hl, de          ;
        push    de              ;
        ldir                    ; Copy Bytes
        pop     hl              ;
        ret                     ;
;
; ------------------------------
; THE 'E-LINE NUMBER' SUBROUTINE
; ------------------------------
;
;; E-LINE-NO
L0A73:  ld hl, ($4014)          ; sv E_LINE_lo
        call    L004D           ; routine TEMP-PTR-2

        rst     18H             ; GET-CHAR
        bit     5, (iy+$2D)     ; sv FLAGX
        ret     nz              ;

        ld      hl, $405D       ; sv MEM-0-1st
        ld      ($401C), hl     ; sv STKEND_lo
        call    L1548           ; routine INT-TO-FP
        call    L158A           ; routine FP-TO-BC
        jr      c, L0A91        ; to NO-NUMBER

        ld      hl, $D8F0       ; value '-10000'
        add     hl, bc          ;
;
;; NO-NUMBER
L0A91:  jp c, L0D9A             ; to REPORT-C

        cp      a               ;
        jp      L14BC           ; routine SET-MIN
;
; -------------------------------------------------
; THE 'REPORT AND LINE NUMBER' PRINTING SUBROUTINES
; -------------------------------------------------
;
;; OUT-NUM
L0A98:  push de                 ;
        push    hl              ;
        xor     a               ;
        bit     7, b            ;
        jr      nz, L0ABF       ; to UNITS

        ld      h, b            ;
        ld      l, c            ;
        ld      e, $FF          ;
        jr      L0AAD           ; to THOUSAND
; ---
;
;; OUT-NO
L0AA5:  push de                 ;
        ld      d, (hl)         ;
        inc     hl              ;
        ld      e, (hl)         ;
        push    hl              ;
        ex      de, hl          ;
        ld      e, $00          ; set E to leading space.
;
;; THOUSAND
L0AAD:  ld bc, $FC18            ; BC= -1000
        call    L07E1           ; routine OUT-DIGIT
        ld      bc, $FF9C       ; BC= -100
        call    L07E1           ; routine OUT-DIGIT
        ld      c, $F6          ; BC= -10
        call    L07E1           ; routine OUT-DIGIT
        ld      a, l            ;
;
;; UNITS
L0ABF:  call L07EB              ; routine OUT-CODE
        pop     hl              ;
        pop     de              ;
        ret                     ;
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
L0AC5:  call L0DA6              ; routine SYNTAX-Z resets the ZERO flag if
                                ; checking syntax.
        pop     hl              ; drop the return address.
        ret     z               ; return to previous calling routine if
                                ; checking syntax.

        jp      (hl)            ; else jump to the continuation address in
                                ; the calling routine as RET would have done.
;
; ----------------------------
; THE 'LPRINT' COMMAND ROUTINE
; ----------------------------
;
;; LPRINT
L0ACB:  set 1, (iy+$01)         ; sv FLAGS  - Signal printer in use
;
; ---------------------------
; THE 'PRINT' COMMAND ROUTINE
; ---------------------------
;
;; PRINT
L0ACF:  ld a, (hl)              ;
        cp      $76             ;
        jp      z, L0B84        ; to PRINT-END
;
;; PRINT-1
L0AD5:  sub $1A                 ;
        adc     a, $00          ;
        jr      z, L0B44        ; to SPACING

        cp      $A7             ;
        jr      nz, L0AFA       ; to NOT-AT


        rst     20H             ; NEXT-CHAR
        call    CLASS_06        ; routine CLASS-6
        cp      $1A             ;
        jp      nz, L0D9A       ; to REPORT-C


        rst     20H             ; NEXT-CHAR
        call    CLASS_06        ; routine CLASS-6
        call    L0B4E           ; routine SYNTAX-ON

        rst     28H             ;; FP-CALC
        defb    $01             ;;exchange
        defb    $34             ;;end-calc

        call    L0BF5           ; routine STK-TO-BC
        call    L08F5           ; routine PRINT-AT
        jr      L0B37           ; to PRINT-ON
; ---
;
;; NOT-AT
L0AFA:  cp $A8                  ;
        jr      nz, L0B31       ; to NOT-TAB


        rst     20H             ; NEXT-CHAR
        call    CLASS_06        ; routine CLASS-6
        call    L0B4E           ; routine SYNTAX-ON
        call    L0C02           ; routine STK-TO-A
        jp      nz, L0EAD       ; to REPORT-B

        and     $1F             ;
        ld      c, a            ;
        bit     1, (iy+$01)     ; sv FLAGS  - Is printer in use
        jr      z, L0B1E        ; to TAB-TEST

        sub     (iy+$38)        ; sv PR_CC
        set     7, a            ;
        add     a, $3C          ;
        call    nc, L0871       ; routine COPY-BUFF
;
;; TAB-TEST
L0B1E:  add a, (iy+$39)         ; sv S_POSN_x
        cp      $21             ;
        ld      a, ($403A)      ; sv S_POSN_y
        sbc     a, $01          ;
        call    L08FA           ; routine TEST-VAL
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space
        jr      L0B37           ; to PRINT-ON
; ---
;
;; NOT-TAB
L0B31:  call SCANNING           ; routine SCANNING
        call    L0B55           ; routine PRINT-STK

;; PRINT-ON
L0B37:  rst 18H                 ; GET-CHAR
        sub     $1A             ;
        adc     a, $00          ;
        jr      z, L0B44        ; to SPACING

        call    L0D1D           ; routine CHECK-END

        jp      L0B84           ; to PRINT-END
; ---
;
;; SPACING
L0B44:  call nc, L0B8B          ; routine FIELD

        rst     20H             ; NEXT-CHAR
        cp      $76             ;
        ret     z               ;

        jp      L0AD5           ; to PRINT-1
; ---
;
;; SYNTAX-ON
L0B4E:  call L0DA6              ; routine SYNTAX-Z
        ret     nz              ;

        pop     hl              ;
        jr      L0B37           ; to PRINT-ON
; ---
;
;; PRINT-STK
L0B55:  call L0AC5              ; routine UNSTACK-Z
        bit     6, (iy+$01)     ; sv FLAGS  - Numeric or string result?
        call    z, STK_FETCH    ; routine STK-FETCH
        jr      z, L0B6B        ; to PR-STR-4

        jp      PRINT_FP        ; jump forward to PRINT-FP
; ---
;
;; PR-STR-1
L0B64:  ld a, $0B               ;
;
;; PR-STR-2
L0B66:  rst 10H                 ; PRINT-A
;
;; PR-STR-3
L0B67:  ld de, ($4018)          ; sv X_PTR_lo
;
;; PR-STR-4
L0B6B:  ld a, b                 ;
        or      c               ;
        dec     bc              ;
        ret     z               ;

        ld      a, (de)         ;
        inc     de              ;
        ld      ($4018), de     ; sv X_PTR_lo
        bit     6, a            ;
        jr      z, L0B66        ; to PR-STR-2

        cp      $C0             ;
        jr      z, L0B64        ; to PR-STR-1

        push    bc              ;
        call    L094B           ; routine TOKENS
        pop     bc              ;
        jr      L0B67           ; to PR-STR-3
; ---
;
;; PRINT-END
L0B84:  call L0AC5              ; routine UNSTACK-Z
        ld      a, $76          ;

        rst     10H             ; PRINT-A
        ret                     ;
; ---
;
;; FIELD
L0B8B:  call L0AC5              ; routine UNSTACK-Z
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space
        xor     a               ;

        rst     10H             ; PRINT-A
        ld      bc, ($4039)     ; sv S_POSN_x
        ld      a, c            ;
        bit     1, (iy+$01)     ; sv FLAGS  - Is printer in use
        jr      z, L0BA4        ; to CENTRE

        ld      a, $5D          ;
        sub     (iy+$38)        ; sv PR_CC
;
;; CENTRE
L0BA4:  ld c, $11               ;
        cp      c               ;
        jr      nc, L0BAB       ; to RIGHT

        ld      c, $01          ;
;
;; RIGHT
L0BAB:
        jp      L090B           ; return via routine SET-FIELD
; ---
        .db $FF                 ; spare :D
;
;   ========================================================
;
; ------------------------------------------
; THE new 'PLOT AND UNPLOT' COMMAND ROUTINES
; ------------------------------------------
;
;   ========================================================
;
;; PLOT/UNP
L0BAF:  call L0BF5              ; routine STK-TO-BC (B=Y, C=X)
        ld      ($4036), bc     ; save in sv COORDS

        ld      a, $04          ; set mosaic lower left
        sra     b               ; test odd values of Y
        jr      nc, columns     ; skip if not (to COLUMNS)

        ld      a, $01          ; else set mosaic upper left
;
;; COLUMNS
columns
        sra     c               ; test odd values of X
        jr      nc, fnd_addr    ; skip if not (to FIND-ADDR)

        rlca                    ; else set mosaic upper/lower right
;
;; FIND-ADDR
fnd_addr
        push    af              ; save mosaic value

        ld      a, $18          ; set limit of the line number (24)
        bit     4, (iy+$3B)     ; sv CDFLAG - test plot48 bit
        jr      nz, plot_48     ; if set, then skip correction

        inc     b               ; else the origin will be at
        inc     b               ; the beginning of line 21
plot_48
        inc     b               ; check the limit value
        cp      b               ; if it is over,
        jp      c, L0EAD        ; then jump to REPORT-B

        call    prn_at_x        ; else test x, then return via LOC-ADDR

        ld      a, (hl)         ; fetch character code from display file
        rlca                    ; test if it is a mosaic character
        cp      $10             ; (0..7)
        jr      nc, TABL_PTR    ; if not, then jump to TABLE-PTR

        rrca                    ; test if it is an inverted mosaic char.
        jr      nc, SQ_SAVED    ; if not then skip (to SQ-SAVED)

        xor     $8F             ; else swap bits
;
;; SQ-SAVED
SQ_SAVED
        ld      b, a            ; and save in B
;
;; TABLE-PTR
TABL_PTR
        ld      a, ($4030)      ; fetch T_ADDR_lo
        cp      $9E             ; is P-UNPLOT?
        jr      c, to_plot      ; if not -> to PLOT

        pop     af              ; restore the mosaic
        cpl                     ; mask out
        and     b               ; the necessary bits
        jr      to_unplt        ; forward to UNPLOT
;
;; PLOT
to_plot
        pop     af              ; restore the mosaic
        or      b               ; copy the necessary bits
;
;; UNPLOT
to_unplt
        cp      $08             ; must be inverted?
        jp      plot_ext        ; continue in the new part
;
;   ========================================================
;
; ----------------------------
; THE 'STACK-TO-BC' SUBROUTINE
; ----------------------------
;
;; STK-TO-BC
L0BF5:  call L0C02              ; routine STK-TO-A
        ld      b, a            ;
        push    bc              ;
        call    L0C02           ; routine STK-TO-A
        ld      e, c            ;
        pop     bc              ;
        ld      d, c            ;
        ld      c, a            ;
        ret                     ;
;
; ---------------------------
; THE 'STACK-TO-A' SUBROUTINE
; ---------------------------
;
;; STK-TO-A
L0C02:  call FP_TO_A            ; routine FP-TO-A
        jp      c, L0EAD        ; to REPORT-B

        ld      c, $01          ;
        ret     z               ;

        ld      c, $FF          ;
        ret                     ;
;
;   ==============================================================
;
; --------------------------------------
; THE new 'SCROLL' SUBROUTINE (27 bytes)
; --------------------------------------
;
;; SCROLL
L0C0E:  ld b, (iy+$22)          ; fetch DF_SZ

        ld      a, $17          ; set A as counter of
        sub     b               ; the lines to move
        push    bc              ; save Y position (B)

        ld      de, ($400C)     ; address of the D-File
        ld      hl, 33          ; HL points the end of
        add     hl, de          ; the 1st line

        bit     5, (iy+$3B)     ; test collapsed D-FILE

        call    scrl_new        ; move lines

        pop     bc              ; restore the saved position
        inc     b               ; the last printable line

        jp      loc_pos0        ; ld c,$21 --> LOC-ADDR
                                ; set new S_POSN and DF_CC
;
;   ==============================================================
;
; -------------------
; THE 'SYNTAX' TABLES
; -------------------
;
; i) The Offset table
;
;; offset-t
L0C29:  defb L0CB4 - $          ; 8B offset to Address: P-LPRINT
        defb    L0CB7 - $       ; 8D offset to Address: P-LLIST
        defb    L0C58 - $       ; 2D offset to Address: P-STOP
        defb    L0CAB - $       ; 7F offset to Address: P-SLOW
        defb    L0CAE - $       ; 81 offset to Address: P-FAST
        defb    L0C77 - $       ; 49 offset to Address: P-NEW
        defb    L0CA4 - $       ; 75 offset to Address: P-SCROLL
        defb    L0C8F - $       ; 5F offset to Address: P-CONT
        defb    L0C71 - $       ; 40 offset to Address: P-DIM
        defb    L0C74 - $       ; 42 offset to Address: P-REM
        defb    L0C5E - $       ; 2B offset to Address: P-FOR
        defb    L0C4B - $       ; 17 offset to Address: P-GOTO
        defb    L0C54 - $       ; 1F offset to Address: P-GOSUB
        defb    L0C6D - $       ; 37 offset to Address: P-INPUT
        defb    L0C89 - $       ; 52 offset to Address: P-LOAD
        defb    L0C7D - $       ; 45 offset to Address: P-LIST
        defb    L0C48 - $       ; 0F offset to Address: P-LET
        defb    L0CA7 - $       ; 6D offset to Address: P-PAUSE
        defb    L0C66 - $       ; 2B offset to Address: P-NEXT
        defb    L0C80 - $       ; 44 offset to Address: P-POKE
        defb    L0C6A - $       ; 2D offset to Address: P-PRINT
        defb    L0C98 - $       ; 5A offset to Address: P-PLOT
        defb    L0C7A - $       ; 3B offset to Address: P-RUN
        defb    L0C8C - $       ; 4C offset to Address: P-SAVE
        defb    L0C86 - $       ; 45 offset to Address: P-RAND
        defb    L0C4F - $       ; 0D offset to Address: P-IF
        defb    L0C95 - $       ; 52 offset to Address: P-CLS
        defb    L0C9E - $       ; 5A offset to Address: P-UNPLOT
        defb    L0C92 - $       ; 4D offset to Address: P-CLEAR
        defb    L0C5B - $       ; 15 offset to Address: P-RETURN
        defb    L0CB1 - $       ; 6A offset to Address: P-COPY
;
; ii) The parameter table.
;
;; P-LET
L0C48:  defb $01                ; Class-01 - A variable is required.
        defb    $14             ; Separator:    '='
        defb    $02             ; Class-02 - An expression, numeric or string,
                                ; must follow.
;
;; P-GOTO
L0C4B:  defb $06                ; Class-06 - A numeric expression must follow.
        defb    $00             ; Class-00 - No further operands.
        defw    L0E81           ; Address: $0E81; Address: GOTO
;
;; P-IF
L0C4F:  defb $06                ; Class-06 - A numeric expression must follow.
        defb    $de             ; Separator:    'THEN'
        defb    $05             ; Class-05 - Variable syntax checked entirely
                                ; by routine.
        defw    L0DAB           ; Address: $0DAB; Address: IF
;
;; P-GOSUB
L0C54:  defb $06                ; Class-06 - A numeric expression must follow.
        defb    $00             ; Class-00 - No further operands.
        defw    L0EB5           ; Address: $0EB5; Address: GOSUB
;
;; P-STOP
L0C58:  defb $00                ; Class-00 - No further operands.
        defw    L0CDC           ; Address: $0CDC; Address: STOP
;
;; P-RETURN
L0C5B:  defb $00                ; Class-00 - No further operands.
        defw    L0ED8           ; Address: $0ED8; Address: RETURN
;
;; P-FOR
L0C5E:  defb $04                ; Class-04 - A single character variable must
                                ; follow.
        defb    $14             ; Separator:    '='
        defb    $06             ; Class-06 - A numeric expression must follow.
        defb    $DF             ; Separator:    'TO'
        defb    $06             ; Class-06 - A numeric expression must follow.
        defb    $05             ; Class-05 - Variable syntax checked entirely
                                ; by routine.
        defw    L0DB9           ; Address: $0DB9; Address: FOR
;
;; P-NEXT
L0C66:  defb $04                ; Class-04 - A single character variable must
                                ; follow.
        defb    $00             ; Class-00 - No further operands.
        defw    L0E2E           ; Address: $0E2E; Address: NEXT
;
;; P-PRINT
L0C6A:  defb $05                ; Class-05 - Variable syntax checked entirely
                                ; by routine.
        defw    L0ACF           ; Address: $0ACF; Address: PRINT
;
;; P-INPUT
L0C6D:  defb $01                ; Class-01 - A variable is required.
        defb    $00             ; Class-00 - No further operands.
        defw    L0EE9           ; Address: $0EE9; Address: INPUT
;
;; P-DIM
L0C71:  defb $05                ; Class-05 - Variable syntax checked entirely
                                ; by routine.
        defw    L1409           ; Address: $1409; Address: DIM
;
;; P-REM
L0C74:  defb $05                ; Class-05 - Variable syntax checked entirely
                                ; by routine.
        defw    L0D6A           ; Address: $0D6A; Address: REM
;
;; P-NEW
L0C77:  defb $00                ; Class-00 - No further operands.
        defw    L03C3           ; Address: $03C3; Address: NEW
;
;; P-RUN
L0C7A:  defb $03                ; Class-03 - A numeric expression may follow
                                ; else default to zero.
        defw    L0EAF           ; Address: $0EAF; Address: RUN
;
;; P-LIST
L0C7D:  defb $03                ; Class-03 - A numeric expression may follow
                                ; else default to zero.
        defw    L0730           ; Address: $0730; Address: LIST
;
;; P-POKE
L0C80:  defb $06                ; Class-06 - A numeric expression must follow.
        defb    $1A             ; Separator:    ','
        defb    $06             ; Class-06 - A numeric expression must follow.
        defb    $00             ; Class-00 - No further operands.
        defw    L0E92           ; Address: $0E92; Address: POKE
;
;; P-RAND
L0C86:  defb $03                ; Class-03 - A numeric expression may follow
                                ; else default to zero.
        defw    L0E6C           ; Address: $0E6C; Address: RAND
;
;; P-LOAD
L0C89:  defb $05                ; Class-05 - Variable syntax checked entirely
                                ; by routine.
        defw    L0340           ; Address: $0340; Address: LOAD
;
;; P-SAVE
L0C8C:  defb $05                ; Class-05 - Variable syntax checked entirely
                                ; by routine.
        defw    L02F6           ; Address: $02F6; Address: SAVE
;
;; P-CONT
L0C8F:  defb $00                ; Class-00 - No further operands.
        defw    L0E7C           ; Address: $0E7C; Address: CONT
;
;; P-CLEAR
L0C92:  defb $00                ; Class-00 - No further operands.
        defw    L149A           ; Address: $149A; Address: CLEAR
;
;; P-CLS
L0C95:  defb $00                ; Class-00 - No further operands.
        defw    L0A2A           ; Address: $0A2A; Address: CLS
;
;; P-PLOT
L0C98:  defb $06                ; Class-06 - A numeric expression must follow.
        defb    $1A             ; Separator:    ','
        defb    $06             ; Class-06 - A numeric expression must follow.
        defb    $00             ; Class-00 - No further operands.
        defw    L0BAF           ; Address: $0BAF; Address: PLOT/UNP
;
;; P-UNPLOT
L0C9E:  defb $06                ; Class-06 - A numeric expression must follow.
        defb    $1A             ; Separator:    ','
        defb    $06             ; Class-06 - A numeric expression must follow.
        defb    $00             ; Class-00 - No further operands.
        defw    L0BAF           ; Address: $0BAF; Address: PLOT/UNP
;
;; P-SCROLL
L0CA4:  defb $00                ; Class-00 - No further operands.
        defw    L0C0E           ; Address: $0C0E; Address: SCROLL
;
;; P-PAUSE
L0CA7:  defb $06                ; Class-06 - A numeric expression must follow.
        defb    $00             ; Class-00 - No further operands.
        defw    L0F32           ; Address: $0F32; Address: PAUSE
;
;; P-SLOW
L0CAB:  defb $00                ; Class-00 - No further operands.
        defw    L0F2B           ; Address: $0F2B; Address: SLOW
;
;; P-FAST
L0CAE:  defb $00                ; Class-00 - No further operands.
        defw    L0F23           ; Address: $0F23; Address: FAST
;
;; P-COPY
L0CB1:  defb $00                ; Class-00 - No further operands.
        defw    L0869           ; Address: $0869; Address: COPY
;
;; P-LPRINT
L0CB4:  defb $05                ; Class-05 - Variable syntax checked entirely
                                ; by routine.
        defw    L0ACB           ; Address: $0ACB; Address: LPRINT
;
;; P-LLIST
L0CB7:  defb $03                ; Class-03 - A numeric expression may follow
                                ; else default to zero.
        defw    L072C           ; Address: $072C; Address: LLIST
;
; ---------------------------
; THE 'LINE SCANNING' ROUTINE
; ---------------------------
;
;; LINE-SCAN
L0CBA:  ld (iy+$01), $01        ; sv FLAGS
        call    L0A73           ; routine E-LINE-NO

;; LINE-RUN
L0CC1:  call L14BC              ; routine SET-MIN
        ld      hl, $4000       ; sv ERR_NR
        ld      (hl), $FF       ;
        ld      hl, $402D       ; sv FLAGX
        bit     5, (hl)         ;
        jr      z, L0CDE        ; to LINE-NULL

        cp      $E3             ; 'STOP' ?
        ld      a, (hl)         ;
        jp      nz, L0D6F       ; to INPUT-REP

        call    L0DA6           ; routine SYNTAX-Z
        ret     z               ;

        rst     08H             ; ERROR-1
        defb    $0C             ; Error Report: BREAK - CONT repeats
;
; --------------------------
; THE 'STOP' COMMAND ROUTINE
; --------------------------
;
;; STOP
L0CDC:  rst 08H                 ; ERROR-1
        defb    $08             ; Error Report: STOP statement
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
L0CDE:  rst 18H                 ; GET-CHAR
        ld      b, $00          ; prepare to index - early.
        cp      $76             ; compare to NEWLINE.
        ret     z               ; return if so.

        ld      c, a            ; transfer character to C.

        rst     20H             ; NEXT-CHAR advances.
        ld      a, c            ; character to A
        sub     $E1             ; subtract 'LPRINT' - lowest command.
        jr      c, L0D26        ; forward if less to REPORT-C2

        ld      c, a            ; reduced token to C
        ld      hl, L0C29       ; set HL to address of offset table.
        add     hl, bc          ; index into offset table.
        ld      c, (hl)         ; fetch offset
        add     hl, bc          ; index into parameter table.
        jr      L0CF7           ; to GET-PARAM
; ---
;
;; SCAN-LOOP
L0CF4:  ld hl, ($4030)          ; sv T_ADDR_lo
;
; -> Entry Point to Scanning Loop
;
;; GET-PARAM
L0CF7:  ld a, (hl)              ;
        inc     hl              ;
        ld      ($4030), hl     ; sv T_ADDR_lo

        ld      bc, L0CF4       ; Address: SCAN-LOOP
        push    bc              ; is pushed on machine stack.

        ld      c, a            ;
        cp      $0B             ;
        jr      nc, L0D10       ; to SEPARATOR

        ld      hl, L0D16       ; class-tbl - the address of the class table.
        ld      b, $00          ;
        add     hl, bc          ;
        ld      c, (hl)         ;
        add     hl, bc          ;
        push    hl              ;

        rst     18H             ; GET-CHAR
        ret                     ; indirect jump to class routine and
                                ; by subsequent RET to SCAN-LOOP.
;
; -----------------------
; THE 'SEPARATOR' ROUTINE
; -----------------------
;
;; SEPARATOR
L0D10:  rst 18H                 ; GET-CHAR
        cp      c               ;
        jr      nz, L0D26       ; to REPORT-C2
                                ; 'Nonsense in BASIC'

        rst     20H             ; NEXT-CHAR
        ret                     ; return
;
; -------------------------
; THE 'COMMAND CLASS' TABLE
; -------------------------
;
;; class-tbl
L0D16:  defb L0D2D - $          ; 17 offset to Address: CLASS-0
        defb    L0D3C - $       ; 25 offset to Address: CLASS-1
        defb    L0D6B - $       ; 53 offset to Address: CLASS-2
        defb    L0D28 - $       ; 0F offset to Address: CLASS-3
        defb    L0D85 - $       ; 6B offset to Address: CLASS-4
        defb    L0D2E - $       ; 13 offset to Address: CLASS-5
        defb    CLASS_06 - $    ; 76 offset to Address: CLASS-6
;
; --------------------------
; THE 'CHECK END' SUBROUTINE
; --------------------------
; Check for end of statement and that no spurious characters occur after
; a correctly parsed statement. Since only one statement is allowed on each
; line, the only character that may follow a statement is a NEWLINE.
;
;; CHECK-END
L0D1D:  call L0DA6              ; routine SYNTAX-Z
        ret     nz              ; return in runtime.

        pop     bc              ; else drop return address.
;
CHECK_2                         ;(L0D22)
        ld      a, (hl)         ; fetch character.
        cp      $76             ; compare to NEWLINE.
        ret     z               ; return if so.
;
;; REPORT-C2
L0D26:  jr L0D9A                ; to REPORT-C
                                ; 'Nonsense in BASIC'
;
; --------------------------
; COMMAND CLASSES 03, 00, 05
; --------------------------
;
;; CLASS-3
L0D28:  cp $76                  ;
        call    L0D9C           ; routine NO-TO-STK
;
;; CLASS-0
L0D2D:  cp a                    ;
;
;; CLASS-5
L0D2E:  pop bc                  ;
        call    z, L0D1D        ; routine CHECK-END
        ex      de, hl          ;
        ld      hl, ($4030)     ; sv T_ADDR_lo
        ld      c, (hl)         ;
        inc     hl              ;
        ld      b, (hl)         ;
        ex      de, hl          ;
;
;; CLASS-END
L0D3A:  push bc                 ;
        ret                     ;
;
; ------------------------------
; COMMAND CLASSES 01, 02, 04, 06
; ------------------------------
;
;; CLASS-1
L0D3C:  call L111C              ; routine LOOK-VARS
;
;; CLASS-4-2
L0D3F:  ld (iy+$2D), $00        ; sv FLAGX
        jr      nc, L0D4D       ; to SET-STK

        set     1, (iy+$2D)     ; sv FLAGX
        jr      nz, L0D63       ; to SET-STRLN
;
;; REPORT-2
L0D4B:  rst 08H                 ; ERROR-1
        defb    $01             ; Error Report: Variable not found
; ---
;
;; SET-STK
L0D4D:  call z, L11A7           ; routine STK-VAR
        bit     6, (iy+$01)     ; sv FLAGS  - Numeric or string result?
        jr      nz, L0D63       ; to SET-STRLN

        xor     a               ;
        call    L0DA6           ; routine SYNTAX-Z
        call    nz, STK_FETCH   ; routine STK-FETCH
        ld      hl, $402D       ; sv FLAGX
        or      (hl)            ;
        ld      (hl), a         ;
        ex      de, hl          ;
;
;; SET-STRLN
L0D63:  ld ($402E), bc          ; sv STRLEN_lo
        ld      ($4012), hl     ; sv DEST-lo
;
; ------------------------------
; THE 'REM' COMMAND ROUTINE
; ------------------------------
;
;; REM
L0D6A:  ret                     ;
;
; ---
;
;; CLASS-2
L0D6B:  pop bc                  ;
        ld      a, ($4001)      ; sv FLAGS
;
;; INPUT-REP
L0D6F:  push af                 ;
        call    SCANNING        ; routine SCANNING
        pop     af              ;
        ld      bc, L1321       ; Address: LET
        ld      d, (iy+$01)     ; sv FLAGS
        xor     d               ;
        and     $40             ;
        jr      nz, L0D9A       ; to REPORT-C

        bit     7, d            ;
        jr      nz, L0D3A       ; to CLASS-END

        jr      CHECK_2         ; to CHECK-2
; ---
;
;; CLASS-4
L0D85:  call L111C              ; routine LOOK-VARS
        push    af              ;
        ld      a, c            ;
        or      $9F             ;
        inc     a               ;
        jr      nz, L0D9A       ; to REPORT-C

        pop     af              ;
        jr      L0D3F           ; to CLASS-4-2
; ---
;
CLASS_06                        ; (L0D92)
        call    SCANNING        ; routine SCANNING
        bit     6, (iy+$01)     ; sv FLAGS  - Numeric or string result?
        ret     nz              ;
;
;; REPORT-C
L0D9A:  rst 08H                 ; ERROR-1
        defb    $0B             ; Error Report: Nonsense in BASIC
;
; --------------------------------
; THE 'NUMBER TO STACK' SUBROUTINE
; --------------------------------
;
;; NO-TO-STK
L0D9C:  jr nz, CLASS_06         ; back to CLASS-6 with a non-zero number.

        call    L0DA6           ; routine SYNTAX-Z
        ret     z               ; return if checking syntax.
;
; in runtime a zero default is placed on the calculator stack.
;
        rst     28H             ;; FP-CALC
        defb    $A0             ;;stk-zero
        defb    $34             ;;end-calc

        ret                     ; return.
;
; -------------------------
; THE 'SYNTAX-Z' SUBROUTINE
; -------------------------
; This routine returns with zero flag set if checking syntax.
; Calling this routine uses three instruction bytes compared to four if the
; bit test is implemented inline.
;
;; SYNTAX-Z
L0DA6:  bit 7, (iy+$01)         ; test FLAGS  - checking syntax only?
        ret                     ; return.
;
; --------------------------------
; THE patched 'IF' COMMAND ROUTINE
; --------------------------------
; In runtime, the class routines have evaluated the test expression and
; the result, true or false, is on the stack.
;
;; IF
L0DAB:
        call    L0DA6           ; routine SYNTAX-Z
        jr      z, if_end       ; forward if checking syntax to IF-END
;
; else delete the Boolean value on the calculator stack.
;
        call    STK_FETCH       ; routine STK-FETCH - exponent to A
                                ; mantissa to EDCB.
        and     a               ; test exponent for zero - FALSE.
        ret     z               ; return if so.
;
;; IF-END (was L0DB6)
if_end
        jp      L0CDE           ; jump back to LINE-NULL
; ---
        .db $FF                 ; spare
;
; ---------------------------------
; THE patched 'FOR' COMMAND ROUTINE
; ---------------------------------
;
;; FOR
L0DB9:  cp $E0                  ; is current character 'STEP' ?
        jr      nz, L0DC6       ; forward if not to F-USE-ONE


        rst     20H             ; NEXT-CHAR
        call    CLASS_06        ; routine CLASS-6 stacks the number
        call    L0D1D           ; routine CHECK-END
        jr      L0DCC           ; forward to F-REORDER
; ---
;
;; F-USE-ONE
L0DC6:  call L0D1D              ; routine CHECK-END

        rst     28H             ;; FP-CALC
        defb    $A1             ;;stk-one
        defb    $34             ;;end-calc
;
;; F-REORDER
L0DCC:  rst 28H                 ;; FP-CALC  v, l, s.
        defb    $C0             ;;st-mem-0  v, l, s.
        defb    $02             ;;delete    v, l.
        defb    $01             ;;exchange  l, v.
        defb    $E0             ;;get-mem-0 l, v, s.
        defb    $01             ;;exchange  l, s, v.
        defb    $34             ;;end-calc  l, s, v.

        call    L1321           ; routine LET

        ld      ($401F), hl     ; set MEM to address variable.
        dec     hl              ; point to letter.
        ld      a, (hl)         ;
        set     7, (hl)         ;
        ld      bc, $0006       ;
        add     hl, bc          ;
        rlca                    ;
        jr      c, L0DEA        ; to F-LMT-STP

        sla     c               ;
        call    L099E           ; routine MAKE-ROOM
        inc     hl              ;
;
;; F-LMT-STP
L0DEA:  push hl                 ;

        rst     28H             ;; FP-CALC
        defb    $02             ;;delete
        defb    $02             ;;delete
        defb    $34             ;;end-calc

        pop     hl              ;
        ex      de, hl          ;

        ld      c, $0A          ; ten bytes to be moved.
        ldir                    ; copy bytes
;
; QCOM1 - patch (Ludwig Röck)
;
        ld      hl, ($4029)     ; set HL to system variable NXTLIN current line.
        ex      de, hl          ; transfer to DE, variable pointer to HL.
;
; QCOM1 - patch (Ludwig Röck)
;
        nop                     ;

        ld      (hl), e         ;
        inc     hl              ;
        ld      (hl), d         ;
        call    L0E5A           ; routine NEXT-LOOP considers an initial pass.
        ret     nc              ; return if possible.
;
; else program continues from point following matching NEXT.
;
        bit     7, (iy+$08)     ; test PPC_hi
        ret     nz              ; return if over 32767 ???

        ld      b, (iy+$2E)     ; fetch variable name from STRLEN_lo
        res     6, b            ; make a true letter.
        ld      hl, ($4029)     ; set HL from NXTLIN
;
; now enter a loop to look for matching next.
;
;; NXTLIN-NO
L0E0E:  ld a, (hl)              ; fetch high byte of line number.
        and     $C0             ; mask off low bits $3F
        jr      nz, L0E2A       ; forward at end of program to FOR-END

        push    bc              ; save letter
        call    L09F2           ; routine NEXT-ONE finds next line.
        pop     bc              ; restore letter

        inc     hl              ; step past low byte
        inc     hl              ; past the
        inc     hl              ; line length.
        call    L004C           ; routine TEMP-PTR1 sets CH_ADD

        rst     18H             ; GET-CHAR
        cp      $F3             ; compare to 'NEXT'.
        ex      de, hl          ; next line to HL.
        jr      nz, L0E0E       ; back with no match to NXTLIN-NO

        ex      de, hl          ; restore pointer.

        rst     20H             ; NEXT-CHAR advances and gets letter in A.
        ex      de, hl          ; save pointer
        cp      b               ; compare to variable name.
        jr      nz, L0E0E       ; back with mismatch to NXTLIN-NO
;
;; FOR-END
L0E2A:
        jr      L0E8E           ; to GOTO-3
; ---
;
;; REPORT-1
L0E2C:
        rst     08H             ; ERROR-1
        defb    $00             ; Error Report: NEXT without FOR
;
; ----------------------------------
; THE patched 'NEXT' COMMAND ROUTINE
; ----------------------------------
;
;; NEXT
L0E2E:  bit 1, (iy+$2D)         ; sv FLAGX
        jp      nz, L0D4B       ; to REPORT-2

        ld      hl, ($4012)     ; DEST (addr. of loop variable)
        bit     7, (hl)         ;
        jr      z, L0E2C        ; to REPORT-1

        inc     hl              ;
        ld      ($401F), hl     ; set MEM to loop variable value
                                ; mem0: value, mem1: limit, mem2: step

        ld      de, $000A       ; offset to 'step'
        ex      de, hl          ;
        add     hl, de          ;
        ex      de, hl          ; HL points 'value', DE points 'step'
        call    addition        ; new value = value + step

        call    L0E5A           ; test limit - routine NEXT-LOOP

        ret     c               ; if it has reached, then return

        ld      hl, ($401F)     ; else fetch MEM (HL points 'value')
        ld      de, $000F       ; offset to the starting address of the loop
        add     hl, de          ; HL now points the starting address
        ld      e, (hl)         ;
        inc     hl              ;
        ld      d, (hl)         ;
        ex      de, hl          ; HL now contains the starting address
;
; QCOM1 - patch (Ludwig Röck)
;
        jr      L0E8E           ; to GOTO-3 (back to the beginning of the loop)
;
; -----------------------------------
; THE improved 'NEXT-LOOP' SUBROUTINE
; -----------------------------------
;
;; NEXT-LOOP
L0E5A:
        rst     28H             ;; FP-CALC

        .db $E0                 ;;get-mem-0     value.
        .db $E1                 ;;get-mem-1     value, limit.

        defb    $E2             ;;get-mem-2     value, limit, step.

        defb    $32             ;;less-0        value, limit, 0/1.
        defb    $00             ;;jump-true     if 'step'<0
        defb    L0E62-$         ;;to LMT-V-VAL      then a=value, b=limit.

        defb    $01             ;;exchange      else a=limit, b=value.
;
;; LMT-V-VAL
L0E62:
        .db $02                 ;;delete        a.
        .db $02                 ;;delete        .
        .db $34                 ;;end-calc      the calculator stack is empty

        ld      hl, 5           ; DE points 'a'
        add     hl, de          ; HL points 'b'

        jp      comp_num        ; return: if b>a then CY=1, else CY=0
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
L0E6C:  call FIND_INT           ; routine FIND-INT
        ld      a, b            ; test value
        or      c               ; for zero
        jr      nz, L0E77       ; forward if not zero to SET-SEED

        ld      bc, ($4034)     ; fetch value of FRAMES system variable.
;
;; SET-SEED
L0E77:  ld  ($4032), bc         ; update the SEED system variable.
        ret                     ; return.
;
; --------------------------
; THE 'CONT' COMMAND ROUTINE
; --------------------------
; Another abbreviated command. ROM space was really tight.
; CONTINUE at the line number that was set when break was pressed.
; Sometimes the current line, sometimes the next line.
;
;; CONT
L0E7C:  ld hl, ($402B)          ; set HL from system variable OLDPPC
        jr      L0E86           ; forward to GOTO-2
;
; --------------------------
; THE 'GOTO' COMMAND ROUTINE
; --------------------------
; This token also suffered from the shortage of room and there is no space
; getween GO and TO as there is on the ZX80 and ZX Spectrum. The same also
; applies to the GOSUB keyword.

;; GOTO
L0E81:  call FIND_INT           ; routine FIND-INT
        ld      h, b            ;
        ld      l, c            ;
;
;; GOTO-2
L0E86:  ld a, h                 ;
        cp      $F0             ;
        jr      nc, L0EAD       ; to REPORT-B

        call    L09D8           ; routine LINE-ADDR
;
;; GOTO-3 QCOM1 - patch (Ludwig Röck)
L0E8E:
        ld      ($4029), hl     ; sv NXTLIN
        ret                     ;
;
; ----------------------------------
; THE patched 'POKE' COMMAND ROUTINE
; ----------------------------------
;
;; POKE
L0E92:
        call    L0C02           ; routine STK-TO-A (with overflow check)

        jr      z, L0E9B        ; forward, if positive, to POKE-SAVE

        neg                     ; else negate
;
;; POKE-SAVE
L0E9B:  push af                 ; preserve value.
        call    FIND_INT        ; routine FIND-INT gets address in BC
                                ; invoking the error routine with overflow
                                ; or a negative number.
        pop     af              ; restore value.

        ld      (bc), a         ; update the address contents.
        ret                     ; return.
;
;   ========================================================
;   called by the new 'PAUSE'
ffp_test
        bit     7, (iy+$3B)     ; sv CDFLAG - test SLOW mode
        jp      ffp_hook        ; forward
;
; -----------------------------
; THE 'FIND INTEGER' SUBROUTINE
; -----------------------------
;
FIND_INT                        ; (L0EA7)
        call    L158A           ; routine FP-TO-BC
        jr      c, L0EAD        ; forward with overflow to REPORT-B

        ret     z               ; return if positive (0-65535).
;
;; REPORT-B
L0EAD:  rst 08H                 ; ERROR-1
        defb    $0A             ; Error Report: Integer out of range
;
; -------------------------
; THE 'RUN' COMMAND ROUTINE
; -------------------------
;
;; RUN
L0EAF:  call L0E81              ; routine GOTO
        jp      L149A           ; to CLEAR
;
; ---------------------------
; THE 'GOSUB' COMMAND ROUTINE
; ---------------------------
;
;; GOSUB  QCOM1 - patch (Ludwig Röck)
;
L0EB5:
        ld      hl, ($4029)     ; sv NXTLIN_lo
        nop                     ;
        ex      (sp), hl        ;
        push    hl              ;
        ld      ($4002), sp     ; set the error stack pointer - ERR_SP
        call    L0E81           ; routine GOTO
        ld      bc, $0006       ;
;
; --------------------------
; THE 'TEST ROOM' SUBROUTINE
; --------------------------
;
TEST_ROOM                       ; (L0EC5)
        ld      hl, ($401C)     ; sv STKEND_lo
        add     hl, bc          ;
        jr      c, L0ED3        ; to REPORT-4

        ex      de, hl          ;
        ld      hl, $0024       ;
        add     hl, de          ;
        sbc     hl, sp          ;
        ret     c               ;
;
;; REPORT-4
L0ED3:  ld l, $03               ;
        jp      L0058           ; to ERROR-3
;
; ----------------------------
; THE 'RETURN' COMMAND ROUTINE
; ----------------------------
;
;; RETURN
L0ED8:  pop hl                  ;
        ex      (sp), hl        ;
        ld      a, h            ;
        cp      $3E             ;
        jr      z, L0EE5        ; to REPORT-7

        ld      ($4002), sp     ; sv ERR_SP_lo
;
; QCOM1 - patch (Ludwig Röck)
;
        jr      L0E8E           ; back to GOTO-3
; ---
;; REPORT-7
L0EE5:  ex (sp), hl             ;
        push    hl              ;

        rst     08H             ; ERROR-1
        defb    $06             ; Error Report: RETURN without GOSUB
;
; ---------------------------
; THE 'INPUT' COMMAND ROUTINE
; ---------------------------
;
;; INPUT
L0EE9:  bit 7, (iy+$08)         ; sv PPC_hi
        jr      nz, L0F21       ; to REPORT-8

        call    L14A3           ; routine X-TEMP
        ld      hl, $402D       ; sv FLAGX
        set     5, (hl)         ;
        res     6, (hl)         ;
        ld      a, ($4001)      ; sv FLAGS
        and     $40             ;
        ld      bc, $0002       ;
        jr      nz, L0F05       ; to PROMPT

        ld      c, $04          ;
;
;; PROMPT
L0F05:  or (hl)                 ;
        ld      (hl), a         ; sv FLAGX

        rst     30H             ; BC-SPACES
        ld      (hl), $76       ;
        ld      a, c            ;
        rrca                    ;
        rrca                    ;
        jr      c, L0F14        ; to ENTER-CUR

        ld      a, $0B          ;
        ld      (de), a         ;
        dec     hl              ;
        ld      (hl), a         ;
;
;; ENTER-CUR
L0F14:  dec hl                  ;
        ld      (hl), $7F       ;
        ld      hl, ($4039)     ; sv S_POSN_x
        ld      ($4030), hl     ; sv T_ADDR_lo
        pop     hl              ;
        jp      L0472           ; to LOWER
; ---
;
;; REPORT-8
L0F21:  rst 08H                 ; ERROR-1
        defb    $07             ; Error Report: End of file
;
; ---------------------------
; THE 'FAST' COMMAND ROUTINE
; ---------------------------
;
;; FAST
L0F23:  call L02E7              ; routine SET-FAST
        res     6, (iy+$3B)     ; sv CDFLAG
        ret                     ; return.
;
; --------------------------
; THE 'SLOW' COMMAND ROUTINE
; --------------------------
;
;; SLOW
L0F2B:  set 6, (iy+$3B)         ; sv CDFLAG
        jp      L0207           ; to SLOW/FAST
;
; -------------------------------
; THE new 'PAUSE' COMMAND ROUTINE
; -------------------------------
;
;; PAUSE
L0F32:
        call    FIND_INT        ; routine FIND-INT

        call    ffp_test        ; flicker free PAUSE (in SLOW mode)
wt_frame
        ld      a, h            ; test if HL is
        or      l               ; already zero
        jr      z, ffp_quit     ; done?

        bit     0, (iy+$3B)     ; test CDFLAG
        jr      z, wt_frame     ; back if no keypress
ffp_quit
        ld      (iy+$35), $FF   ; set FRAMES_hi
                                ; return via  BREAK/DEBOUNCE
;
; ----------------------
; THE 'BREAK' SUBROUTINE
; ----------------------
;
;; BREAK-1
L0F46:  ld a, $7F               ; read port $7FFE - keys B,N,M,.,SPACE.
        in      a, ($FE)        ;
        rra                     ; carry will be set if space not pressed.
;
; -------------------------
; THE 'DEBOUNCE' SUBROUTINE
; -------------------------
;
;; DEBOUNCE
L0F4B:  res 0, (iy+$3B)         ; update system variable CDFLAG
        ld      a, $FF          ;
        ld      ($4027), a      ; update system variable DEBOUNCE
        ret                     ; return.
;
; -------------------------
; THE 'SCANNING' SUBROUTINE
; -------------------------
; This recursive routine is where the ZX81 gets its power. Provided there is
; enough memory it can evaluate an expression of unlimited complexity.
; Note. there is no unary plus so, as on the ZX80, PRINT +1 gives a syntax error.
; PRINT +1 works on the Spectrum but so too does PRINT + "STRING".
;
SCANNING                        ; (L0F55)
        rst     18H             ; GET-CHAR
        ld      b, $00          ; set B register to zero.
        push    bc              ; stack zero as a priority end-marker.
;
;; S-LOOP-1
L0F59:  cp $40                  ; compare to the 'RND' character
        jr      nz, L0F8C       ; forward, if not, to S-TEST-PI
;
; ---------------------------
; THE improved 'RND' FUNCTION
; ---------------------------
;
        call    L0DA6           ; routine SYNTAX-Z
        jr      z, L0F99        ; forward if checking syntax to S-PI-END

        ld      bc, ($4032)     ; sv SEED_lo
        call    STACK_BC        ; routine STACK-BC

        rst     28H             ;; FP-CALC
        defb    $A1             ;;stk-one
        defb    $0F             ;;addition
        defb    $30             ;;stk-data
        defb    $37             ;;Exponent: $87, Bytes: 1
        defb    $16             ;;(+00,+00,+00)
        defb    $04             ;;multiply
        defb    $30             ;;stk-data
        defb    $80             ;;Bytes: 3
        defb    $41             ;;Exponent $91
        defb    $00, $00, $80   ;;(+00)
        defb    $2E             ;;n-mod-m
        defb    $02             ;;delete

        .db $39                 ;;sub-one macro

        defb    $2D             ;;duplicate
        defb    $34             ;;end-calc

        call    L158A           ; routine FP-TO-BC
        ld      ($4032), bc     ; update the SEED system variable.
        ld      a, (hl)         ; HL addresses the exponent of the last value.
        and     a               ; test for zero
        jr      z, L0F99        ; forward, if so, to S-PI-END

        sub     $10             ; else reduce exponent by sixteen
        ld      (hl), a         ; thus dividing by 65536 for last value.

        jr      L0F99           ; forward to S-PI-END
; ---
        .db $FF                 ; spare
; ---
;
;; S-TEST-PI
L0F8C:  cp $42                  ; the 'PI' character
        jr      nz, L0F9D       ; forward, if not, to S-TST-INK
;
; -------------------
; THE 'PI' EVALUATION
; -------------------
;
        call    L0DA6           ; routine SYNTAX-Z
        jr      z, L0F99        ; forward if checking syntax to S-PI-END

        rst     28H             ;; FP-CALC
        defb    $A3             ;;stk-pi/2
        defb    $34             ;;end-calc

        inc     (hl)            ; double the exponent giving PI on the stack.

;; S-PI-END
L0F99:  rst 20H                 ; NEXT-CHAR advances character pointer.

        jp      L1083           ; jump forward to S-NUMERIC to set the flag
                                ; to signal numeric result before advancing.
; ---
;
;; S-TST-INK
L0F9D:  cp $41                  ; compare to character 'INKEY$'
        jr      nz, L0FB2       ; forward, if not, to S-ALPHANUM
;
; -----------------------
; THE 'INKEY$' EVALUATION
; -----------------------
;
        call    L02BB           ; routine KEYBOARD
        ld      b, h            ;
        ld      c, l            ;
        ld      d, c            ;
        inc     d               ;
        call    nz, L07BD       ; routine DECODE
        ld      a, d            ;
        adc     a, d            ;
        ld      b, d            ;
        ld      c, a            ;
        ex      de, hl          ;
        jr      L0FED           ; forward to S-STRING
; ---
;
;; S-ALPHANUM
L0FB2:  call L14D2              ; routine ALPHANUM
        jr      c, L1025        ; forward, if alphanumeric to S-LTR-DGT

        cp      $1B             ; is character a '.' ?
        jp      z, L1047        ; jump forward if so to S-DECIMAL

        ld      bc, $09D8       ; prepare priority 09, operation 'subtract'
        cp      $16             ; is character unary minus '-' ?
        jr      z, L1020        ; forward, if so, to S-PUSH-PO

        cp      $10             ; is character a '(' ?
        jr      nz, L0FD6       ; forward if not to S-QUOTE

        call    L0049           ; routine CH-ADD+1 advances character pointer.

        call    SCANNING        ; recursively call routine SCANNING to
                                ; evaluate the sub-expression.

        cp      $11             ; is subsequent character a ')' ?
        jr      nz, L0FFF       ; forward if not to S-RPT-C


        call    L0049           ; routine CH-ADD+1  advances.
        jr      L0FF8           ; relative jump to S-JP-CONT3 and then S-CONT3
; ---
;
; consider a quoted string e.g. PRINT "Hooray!"
; Note. quotes are not allowed within a string.
;
;; S-QUOTE
L0FD6:  cp $0B                  ; is character a quote (") ?
        jr      nz, L1002       ; forward, if not, to S-FUNCTION

        call    L0049           ; routine CH-ADD+1 advances
        push    hl              ; * save start of string.
        jr      L0FE3           ; forward to S-QUOTE-S
; ---
;
;; S-Q-AGAIN
L0FE0:  call L0049              ; routine CH-ADD+1
;
;; S-QUOTE-S
L0FE3:  cp $0B                  ; is character a '"' ?
        jr      nz, L0FFB       ; forward if not to S-Q-NL

        pop     de              ; * retrieve start of string
        and     a               ; prepare to subtract.
        sbc     hl, de          ; subtract start from current position.
        ld      b, h            ; transfer this length
        ld      c, l            ; to the BC register pair.
;
;; S-STRING
L0FED:  ld hl, $4001            ; address system variable FLAGS
        res     6, (hl)         ; signal string result
        bit     7, (hl)         ; test if checking syntax.

        call    nz, STK_ST_s    ; in run-time routine STK-STO-$ stacks the
                                ; string descriptor - start DE, length BC.

        rst     20H             ; NEXT-CHAR advances pointer.
;
;; S-J-CONT-3
L0FF8:  jp L1088                ; jump to S-CONT-3
;
; A string with no terminating quote has to be considered.
;
;; S-Q-NL
L0FFB:  cp $76                  ; compare to NEWLINE
        jr      nz, L0FE0       ; loop back if not to S-Q-AGAIN
;
;; S-RPT-C
L0FFF:  jp L0D9A                ; to REPORT-C
;
; ---
;
;; S-FUNCTION
L1002:  sub $C4                 ; subtract 'CODE' reducing codes
                                ; CODE thru '<>' to range $00 - $XX
        jr      c, L0FFF        ; back, if less, to S-RPT-C
;
; test for NOT the last function in character set.
;
        ld      bc, $04EC       ; prepare priority $04, operation 'not'
        cp      $13             ; compare to 'NOT'  ( - CODE)
        jr      z, L1020        ; forward, if so, to S-PUSH-PO

        jr      nc, L0FFF       ; back with anything higher to S-RPT-C
;
; else is a function 'CODE' thru 'CHR$'
;
        ld      b, $10          ; priority sixteen binds all functions to
                                ; arguments removing the need for brackets.

        add     a, $D9          ; add $D9 to give range $D9 thru $EB
                                ; bit 6 is set to show numeric argument.
                                ; bit 7 is set to show numeric result.
;
; now adjust these default argument/result indicators.
;
        ld      c, a            ; save code in C

        cp      $DC             ; separate 'CODE', 'VAL', 'LEN'
        jr      nc, L101A       ; skip forward if string operand to S-NO-TO-$

        res     6, c            ; signal string operand.
;
;; S-NO-TO-$
L101A:  cp $EA                  ; isolate top of range 'STR$' and 'CHR$'
        jr      c, L1020        ; skip forward with others to S-PUSH-PO

        res     7, c            ; signal string result.
;
;; S-PUSH-PO
L1020:  push bc                 ; push the priority/operation

        rst     20H             ; NEXT-CHAR
        jp      L0F59           ; jump back to S-LOOP-1
; ---
;
;; S-LTR-DGT
L1025:  cp $26                  ; compare to 'A'.
        jr      c, L1047        ; forward if less to S-DECIMAL

        call    L111C           ; routine LOOK-VARS
        jp      c, L0D4B        ; back if not found to REPORT-2
                                ; a variable is always 'found' when checking
                                ; syntax.

        call    z, L11A7        ; routine STK-VAR stacks string parameters or
                                ; returns cell location if numeric.

        ld      a, ($4001)      ; fetch FLAGS
        cp      $C0             ; compare to numeric result/numeric operand
        jr      c, L1087        ; forward if not numeric to S-CONT-2

        inc     hl              ; address numeric contents of variable.
        ld      de, ($401C)     ; set destination to STKEND
        call    COPY_FP         ; routine COPY-FP stacks the five bytes
        ex      de, hl          ; transfer new free location from DE to HL.
        ld      ($401C), hl     ; update STKEND system variable.
        jr      L1087           ; forward to S-CONT-2
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
L1047:  call L0DA6              ; routine SYNTAX-Z
        jr      nz, L106F       ; forward in run-time to S-STK-DEC

        call    L14D9           ; routine DEC-TO-FP

        rst     18H             ; GET-CHAR advances HL past digits
        ld      bc, $0006       ; six locations are required.
        call    L099E           ; routine MAKE-ROOM
        inc     hl              ; point to first new location
        ld      (hl), $7E       ; insert the number marker 126 decimal.
        inc     hl              ; increment
        ex      de, hl          ; transfer destination to DE.
        ld      hl, ($401C)     ; set HL from STKEND which points to the
                                ; first location after the 'last value'
        ld      c, $05          ; five bytes to move.
        and     a               ; clear carry.
        sbc     hl, bc          ; subtract five pointing to 'last value'.
        ld      ($401C), hl     ; update STKEND thereby 'deleting the value.

        ldir                    ; copy the five value bytes.

        ex      de, hl          ; basic pointer to HL which may be white-space
                                ; following the number.
        dec     hl              ; now points to last of five bytes.
        call    L004C           ; routine TEMP-PTR1 advances the character
                                ; address skipping any white-space.
        jr      L1083           ; forward to S-NUMERIC
                                ; to signal a numeric result.
; ---
;
; In run-time the branch is here when a digit or point is encountered.
;
;; S-STK-DEC
L106F:  rst 20H                 ; NEXT-CHAR
        cp      $7E             ; compare to 'number marker'
        jr      nz, L106F       ; loop back until found to S-STK-DEC
                                ; skipping all the digits.

        inc     hl              ; point to first of five hidden bytes.
        ld      de, ($401C)     ; set destination from STKEND system variable
        call    COPY_FP         ; routine COPY-FP stacks the number.
        ld      ($401C), de     ; update system variable STKEND.
        ld      ($4016), hl     ; update system variable CH_ADD.
;
;; S-NUMERIC
L1083:  set 6, (iy+$01)         ; update FLAGS  - Signal numeric result
;
;; S-CONT-2
L1087:  rst 18H                 ; GET-CHAR
;
;; S-CONT-3
L1088:  cp $10                  ; compare to opening bracket '('
        jr      nz, L1098       ; forward if not to S-OPERTR

        bit     6, (iy+$01)     ; test FLAGS  - Numeric or string result?
        jr      nz, L10BC       ; forward if numeric to S-LOOP
;
; else is a string
;
        call    L1263           ; routine SLICING

        rst     20H             ; NEXT-CHAR
        jr      L1088           ; back to S-CONT-3
; ---
;
; the character is now manipulated to form an equivalent in the table of
; calculator literals. This is quite cumbersome and in the ZX Spectrum a
; simple look-up table was introduced at this point.
;
;; S-OPERTR
L1098:  ld bc, $00C3            ; prepare operator 'subtract' as default.
                                ; also set B to zero for later indexing.

        cp      $12             ; is character '>' ?
        jr      c, L10BC        ; forward if less to S-LOOP as
                                ; we have reached end of meaningful expression

        sub     $16             ; is character '-' ?
        jr      nc, L10A7       ; forward with - * / and '**' '<>' to SUBMLTDIV

        add     a, $0D          ; increase others by thirteen
                                ; $09 '>' thru $0C '+'
        jr      L10B5           ; forward to GET-PRIO
; ---
;
;; SUBMLTDIV
L10A7:  cp $03                  ; isolate $00 '-', $01 '*', $02 '/'
        jr      c, L10B5        ; forward if so to GET-PRIO
;
; else possibly originally $D8 '**' thru $DD '<>' already reduced by $16
;
        sub     $C2             ; giving range $00 to $05
        jr      c, L10BC        ; forward if less to S-LOOP

        cp      $06             ; test the upper limit for nonsense also
        jr      nc, L10BC       ; forward if so to S-LOOP

        add     a, $03          ; increase by 3 to give combined operators of

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
L10B5:  add a, c                ; add to default operation 'sub' ($C3)
        ld      c, a            ; and place in operator byte - C.

        ld      hl, L110F - $C3 ; theoretical base of the priorities table.
        add     hl, bc          ; add C ( B is zero)
        ld      b, (hl)         ; pick up the priority in B
;
;; S-LOOP
L10BC:  pop de                  ; restore previous
        ld      a, d            ; load A with priority.
        cp      b               ; is present priority higher
        jr      c, L10ED        ; forward if so to S-TIGHTER

        and     a               ; are both priorities zero
        jp      z, L0018        ; exit if zero via GET-CHAR

        push    bc              ; stack present values
        push    de              ; stack last values
        call    L0DA6           ; routine SYNTAX-Z
        jr      z, L10D5        ; forward is checking syntax to S-SYNTEST

        ld      a, e            ; fetch last operation
        and     $3F             ; mask off the indicator bits to give true
                                ; calculator literal.
        ld      b, a            ; place in the B register for BREG
;
; perform the single operation
;
        rst     28H             ;; FP-CALC
        defb    $37             ;;fp-calc-2
        defb    $34             ;;end-calc

        jr      L10DE           ; forward to S-RUNTEST
; ---
;
;; S-SYNTEST
L10D5:  ld a, e                 ; transfer masked operator to A
        xor     (iy+$01)        ; XOR with FLAGS like results will reset bit 6
        and     $40             ; test bit 6
;
;; S-RPORT-C
L10DB:  jp nz, L0D9A            ; back to REPORT-C if results do not agree.
;
; in run-time impose bit 7 of the operator onto bit 6 of the FLAGS
;
;; S-RUNTEST
L10DE:  pop de                  ; restore last operation.
        ld      hl, $4001       ; address system variable FLAGS
        set     6, (hl)         ; presume a numeric result
        bit     7, e            ; test expected result in operation
        jr      nz, L10EA       ; forward if numeric to S-LOOPEND

        res     6, (hl)         ; reset to signal string result
;
;; S-LOOPEND
L10EA:  pop bc                  ; restore present values
        jr      L10BC           ; back to S-LOOP
;
; ---
;
;; S-TIGHTER
L10ED:  push de                 ; push last values and consider these

        ld      a, c            ; get the present operator.
        bit     6, (iy+$01)     ; test FLAGS  - Numeric or string result?
        jr      nz, L110A       ; forward if numeric to S-NEXT

        and     $3F             ; strip indicator bits to give clear literal.
        add     a, $08          ; add eight - augmenting numeric to equivalent
                                ; string literals.
        ld      c, a            ; place plain literal back in C.
        cp      $10             ; compare to 'AND'
        jr      nz, L1102       ; forward if not to S-NOT-AND

        set     6, c            ; set the numeric operand required for 'AND'
        jr      L110A           ; forward to S-NEXT
; ---
;
;; S-NOT-AND
L1102:  jr c, L10DB             ; back if less than 'AND' to S-RPORT-C
                                ; Nonsense if '-', '*' etc.

        cp      $17             ; compare to 'strs-add' literal
        jr      z, L110A        ; forward if so signaling string result

        set     7, c            ; set bit to numeric (Boolean) for others.
;
;; S-NEXT
L110A:  push bc                 ; stack 'present' values

        rst     20H             ; NEXT-CHAR
        jp      L0F59           ; jump back to S-LOOP-1
;
; -------------------------
; THE 'TABLE OF PRIORITIES'
; -------------------------
;
;; tbl-pri
L110F:  defb $06                ;  '-'
        defb    $08             ;  '*'
        defb    $08             ;  '/'
        defb    $0A             ;  '**'
        defb    $02             ;  'OR'
        defb    $03             ;  'AND'
        defb    $05             ;  '<='
        defb    $05             ;  '>='
        defb    $05             ;  '<>'
        defb    $05             ;  '>'
        defb    $05             ;  '<'
        defb    $05             ;  '='
        defb    $06             ;  '+'
;
; --------------------------
; THE 'LOOK-VARS' SUBROUTINE
; --------------------------
;
;; LOOK-VARS
L111C:  set 6, (iy+$01)         ; sv FLAGS  - Signal numeric result

        rst     18H             ; GET-CHAR
        call    L14CE           ; routine ALPHA
        jp      nc, L0D9A       ; to REPORT-C

        push    hl              ;
        ld      c, a            ;

        rst     20H             ; NEXT-CHAR
        push    hl              ;
        res     5, c            ;
        cp      $10             ;
        jr      z, L1148        ; to V-SYN/RUN

        set     6, c            ;
        cp      $0D             ;
        jr      z, L1143        ; forward to V-STR-VAR

        set     5, c            ;
;
;; V-CHAR
L1139:  call L14D2              ; routine ALPHANUM
        jr      nc, L1148       ; forward when not to V-RUN/SYN

        res     6, c            ;

        rst     20H             ; NEXT-CHAR
        jr      L1139           ; loop back to V-CHAR
; ---
;
;; V-STR-VAR
L1143:  rst 20H                 ; NEXT-CHAR
        res     6, (iy+$01)     ; sv FLAGS  - Signal string result
;
;; V-RUN/SYN
L1148:  ld b, c                 ;
        call    L0DA6           ; routine SYNTAX-Z
        jr      nz, L1156       ; forward to V-RUN

        ld      a, c            ;
        and     $E0             ;
        set     7, a            ;
        ld      c, a            ;
        jr      L118A           ; forward to V-SYNTAX
; ---
;
;; V-RUN
L1156:  ld hl, ($4010)          ; sv VARS
;
;; V-EACH
L1159:  ld a, (hl)              ;
        and     $7F             ;
        jr      z, L1188        ; to V-80-BYTE

        cp      c               ;
        jr      nz, L1180       ; to V-NEXT

        rla                     ;
        add     a, a            ;
        jp      p, L1195        ; to V-FOUND-2

        jr      c, L1195        ; to V-FOUND-2

        pop     de              ;
        push    de              ;
        push    hl              ;
;
;; V-MATCHES
L116B:  inc hl                  ;
;
;; V-SPACES
L116C:  ld a, (de)              ;
        inc     de              ;
        and     a               ;
        jr      z, L116C        ; back to V-SPACES

        cp      (hl)            ;
        jr      z, L116B        ; back to V-MATCHES

        or      $80             ;
        cp      (hl)            ;
        jr      nz, L117F       ; forward to V-GET-PTR

        ld      a, (de)         ;
        call    L14D2           ; routine ALPHANUM
        jr      nc, L1194       ; forward to V-FOUND-1
;
;; V-GET-PTR
L117F:  pop hl                  ;
;
;; V-NEXT
L1180:  push bc                 ;
        call    L09F2           ; routine NEXT-ONE
        ex      de, hl          ;
        pop     bc              ;
        jr      L1159           ; back to V-EACH
; ---
;
;; V-80-BYTE
L1188:  set 7, b                ;
;
;; V-SYNTAX
L118A:  pop de                  ;

        rst     18H             ; GET-CHAR
        cp      $10             ;
        jr      z, L1199        ; forward to V-PASS

        set     5, b            ;
        jr      L11A1           ; forward to V-END
; ---
;
;; V-FOUND-1
L1194:  pop de                  ;
;
;; V-FOUND-2
L1195:  pop de                  ;
        pop     de              ;
        push    hl              ;

        rst     18H             ; GET-CHAR

;; V-PASS
L1199:  call L14D2              ; routine ALPHANUM
        jr      nc, L11A1       ; forward if not alphanumeric to V-END


        rst     20H             ; NEXT-CHAR
        jr      L1199           ; back to V-PASS
; ---
;
;; V-END
L11A1:  pop hl                  ;
        rl      b               ;
        bit     6, b            ;
        ret                     ;
;
; ------------------------
; THE 'STK-VAR' SUBROUTINE
; ------------------------
;
;; STK-VAR
L11A7:  xor a                   ;
        ld      b, a            ;
        bit     7, c            ;
        jr      nz, L11F8       ; forward to SV-COUNT

        bit     7, (hl)         ;
        jr      nz, L11BF       ; forward to SV-ARRAYS

        inc     a               ;

;; SV-SIMPLE$
L11B2:  inc hl                  ;
        ld      c, (hl)         ;
        inc     hl              ;
        ld      b, (hl)         ;
        inc     hl              ;
        ex      de, hl          ;
        call    STK_ST_s        ; routine STK-STO-$

        rst     18H             ; GET-CHAR
        jp      L125A           ; jump forward to SV-SLICE?
; ---
;
;; SV-ARRAYS
L11BF:  inc hl                  ;
        inc     hl              ;
        inc     hl              ;
        ld      b, (hl)         ;
        bit     6, c            ;
        jr      z, L11D1        ; forward to SV-PTR

        dec     b               ;
        jr      z, L11B2        ; forward to SV-SIMPLE$

        ex      de, hl          ;

        rst     18H             ; GET-CHAR
        cp      $10             ;
        jr      nz, L1231       ; forward to REPORT-3

        ex      de, hl          ;

;; SV-PTR
L11D1:  ex de, hl               ;
        jr      L11F8           ; forward to SV-COUNT
; ---
;
;; SV-COMMA
L11D4:  push hl                 ;

        rst     18H             ; GET-CHAR
        pop     hl              ;
        cp      $1A             ;
        jr      z, L11FB        ; forward to SV-LOOP

        bit     7, c            ;
        jr      z, L1231        ; forward to REPORT-3

        bit     6, c            ;
        jr      nz, L11E9       ; forward to SV-CLOSE

        cp      $11             ;
        jr      nz, L1223       ; forward to SV-RPT-C

        rst     20H             ; NEXT-CHAR
        ret                     ;
; ---
;
;; SV-CLOSE
L11E9:  cp $11                  ;
        jr      z, L1259        ; forward to SV-DIM

        cp      $DF             ;
        jr      nz, L1223       ; forward to SV-RPT-C
;
;; SV-CH-ADD
L11F1:  rst 18H                 ; GET-CHAR
        dec     hl              ;
        ld      ($4016), hl     ; sv CH_ADD
        jr      L1256           ; forward to SV-SLICE
; ---
;
;; SV-COUNT
L11F8:  ld hl, $0000            ;
;
;; SV-LOOP
L11FB:  push hl                 ;

        rst     20H             ; NEXT-CHAR
        pop     hl              ;
        ld      a, c            ;
        cp      $C0             ;
        jr      nz, L120C       ; forward to SV-MULT

        rst     18H             ; GET-CHAR
        cp      $11             ;
        jr      z, L1259        ; forward to SV-DIM

        cp      $DF             ;
        jr      z, L11F1        ; back to SV-CH-ADD
;
;; SV-MULT
L120C:  push bc                 ;
        push    hl              ;
        call    L12FF           ; routine DE,(DE+1)
        ex      (sp), hl        ;
        ex      de, hl          ;
        call    L12DD           ; routine INT-EXP1
        jr      c, L1231        ; forward to REPORT-3

        dec     bc              ;
        call    L1305           ; routine GET-HL*DE
        add     hl, bc          ;
        pop     de              ;
        pop     bc              ;
        djnz    L11D4           ; loop back to SV-COMMA

        bit     7, c            ;
;
;; SV-RPT-C
L1223:  jr nz, L128B            ; relative jump to SL-RPT-C

        push    hl              ;
        bit     6, c            ;
        jr      nz, L123D       ; forward to SV-ELEM$

        ld      b, d            ;
        ld      c, e            ;

        rst     18H             ; GET-CHAR
        cp      $11             ; is character a ')' ?
        jr      z, L1233        ; skip forward to SV-NUMBER
;
;; REPORT-3
L1231:  rst 08H                 ; ERROR-1
        defb    $02             ; Error Report: Subscript wrong
;
;; SV-NUMBER
L1233:  rst 20H                 ; NEXT-CHAR
        pop     hl              ;
        ld      de, $0005       ;
        call    L1305           ; routine GET-HL*DE
        add     hl, bc          ;
        ret                     ; return              >>
; ---
;
;; SV-ELEM$
L123D:  call L12FF              ; routine DE,(DE+1)
        ex      (sp), hl        ;
        call    L1305           ; routine GET-HL*DE
        pop     bc              ;
        add     hl, bc          ;
        inc     hl              ;
        ld      b, d            ;
        ld      c, e            ;
        ex      de, hl          ;
        call    L12C2           ; routine STK-ST-0

        rst     18H             ; GET-CHAR
        cp      $11             ; is it ')' ?
        jr      z, L1259        ; forward if so to SV-DIM

        cp      $1A             ; is it ',' ?
        jr      nz, L1231       ; back if not to REPORT-3
;
;; SV-SLICE
L1256:  call L1263              ; routine SLICING
;
;; SV-DIM
L1259:  rst 20H                 ; NEXT-CHAR
;
;; SV-SLICE?
L125A:  cp $10                  ;
        jr      z, L1256        ; back to SV-SLICE

        res     6, (iy+$01)     ; sv FLAGS  - Signal string result
        ret                     ; return.
;
; ------------------------
; THE 'SLICING' SUBROUTINE
; ------------------------
;
;; SLICING
L1263:  call L0DA6              ; routine SYNTAX-Z
        call    nz, STK_FETCH   ; routine STK-FETCH

        rst     20H             ; NEXT-CHAR
        cp      $11             ; is it ')' ?
        jr      z, L12BE        ; forward if so to SL-STORE

        push    de              ;
        xor     a               ;
        push    af              ;
        push    bc              ;
        ld      de, $0001       ;

        rst     18H             ; GET-CHAR
        pop     hl              ;
        cp      $DF             ; is it 'TO' ?
        jr      z, L1292        ; forward if so to SL-SECOND

        pop     af              ;
        call    L12DE           ; routine INT-EXP2
        push    af              ;
        ld      d, b            ;
        ld      e, c            ;
        push    hl              ;

        rst     18H             ; GET-CHAR
        pop     hl              ;
        cp      $DF             ; is it 'TO' ?
        jr      z, L1292        ; forward if so to SL-SECOND

        cp      $11             ;
;
;; SL-RPT-C
L128B:  jp nz, L0D9A            ; to REPORT-C

        ld      h, d            ;
        ld      l, e            ;
        jr      L12A5           ; forward to SL-DEFINE
; ---
;
;; SL-SECOND
L1292:  push hl                 ;

        rst     20H             ; NEXT-CHAR
        pop     hl              ;
        cp      $11             ; is it ')' ?
        jr      z, L12A5        ; forward if so to SL-DEFINE

        pop     af              ;
        call    L12DE           ; routine INT-EXP2
        push    af              ;

        rst     18H             ; GET-CHAR
        ld      h, b            ;
        ld      l, c            ;
        cp      $11             ; is it ')' ?
        jr      nz, L128B       ; back if not to SL-RPT-C
;
;; SL-DEFINE
L12A5:  pop af                  ;
        ex      (sp), hl        ;
        add     hl, de          ;
        dec     hl              ;
        ex      (sp), hl        ;
        and     a               ;
        sbc     hl, de          ;
        ld      bc, $0000       ;
        jr      c, L12B9        ; forward to SL-OVER

        inc     hl              ;
        and     a               ;
        jp      m, L1231        ; jump back to REPORT-3

        ld      b, h            ;
        ld      c, l            ;
;
;; SL-OVER
L12B9:  pop de                  ;
        res     6, (iy+$01)     ; sv FLAGS  - Signal string result
;
;; SL-STORE
L12BE:  call L0DA6              ; routine SYNTAX-Z
        ret     z               ; return if checking syntax.
;
; --------------------------
; THE 'STK-STORE' SUBROUTINE
; --------------------------
;
;; STK-ST-0
L12C2:  xor a                   ;
;
STK_ST_s                        ; (L12C3)
        push    bc              ;
        call    TEST_5_SP       ; routine TEST-5-SP
        pop     bc              ;
        ld      hl, ($401C)     ; sv STKEND
        ld      (hl), a         ;
        inc     hl              ;
        ld      (hl), e         ;
        inc     hl              ;
        ld      (hl), d         ;
        inc     hl              ;
        ld      (hl), c         ;
        inc     hl              ;
        ld      (hl), b         ;
        inc     hl              ;
        ld      ($401C), hl     ; sv STKEND
        res     6, (iy+$01)     ; update FLAGS - signal string result
        ret                     ; return.
;
; -------------------------
; THE 'INT EXP' SUBROUTINES
; -------------------------
;
;; INT-EXP1
L12DD:  xor a                   ;
;
;; INT-EXP2
L12DE:  push de                 ;
        push    hl              ;
        push    af              ;
        call    CLASS_06        ; routine CLASS-6
        pop     af              ;
        call    L0DA6           ; routine SYNTAX-Z
        jr      z, L12FC        ; forward if checking syntax to I-RESTORE

        push    af              ;
        call    FIND_INT        ; routine FIND-INT
        pop     de              ;
        ld      a, b            ;
        or      c               ;
        scf                     ; Set Carry Flag
        jr      z, L12F9        ; forward to I-CARRY

        pop     hl              ;
        push    hl              ;
        and     a               ;
        sbc     hl, bc          ;
;
;; I-CARRY
L12F9:  ld a, d                 ;
        sbc     a, $00          ;
;
;; I-RESTORE
L12FC:  pop hl                  ;
        pop     de              ;
        ret                     ;
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
L12FF:  ex de, hl               ; move index address into HL.
        inc     hl              ; increment to address word.
        ld      e, (hl)         ; pick up word low-order byte.
        inc     hl              ; index high-order byte and
        ld      d, (hl)         ; pick it up.
        ret                     ; return with DE = word.
;
; --------------------------
; THE 'GET-HL*DE' SUBROUTINE
; --------------------------
;
;; GET-HL*DE
L1305:  call L0DA6              ; routine SYNTAX-Z
        ret     z               ;

        push    bc              ;
        ld      b, $10          ;
        ld      a, h            ;
        ld      c, l            ;
        ld      hl, $0000       ;
;
;; HL-LOOP
L1311:  add hl, hl              ;
        jr      c, L131A        ; forward with carry to HL-END

        rl      c               ;
        rla                     ;
        jr      nc, L131D       ; forward with no carry to HL-AGAIN

        add     hl, de          ;
;
;; HL-END
L131A:  jp c, L0ED3             ; to REPORT-4
;
;; HL-AGAIN
L131D:  djnz L1311              ; loop back to HL-LOOP

        pop     bc              ;
        ret                     ; return.
;
; --------------------
; THE 'LET' SUBROUTINE
; --------------------
;
;; LET
L1321:  ld hl, ($4012)          ; sv DEST-lo
        bit     1, (iy+$2D)     ; sv FLAGX
        jr      z, L136E        ; forward to L-EXISTS

        ld      bc, $0005       ;
;
;; L-EACH-CH
L132D:  inc bc                  ;
;
; check
;
;; L-NO-SP
L132E:  inc hl                  ;
        ld      a, (hl)         ;
        and     a               ;
        jr      z, L132E        ; back to L-NO-SP

        call    L14D2           ; routine ALPHANUM
        jr      c, L132D        ; back to L-EACH-CH

        cp      $0D             ; is it '$' ?
        jp      z, L13C8        ; forward if so to L-NEW$

        rst     30H             ; BC-SPACES
        push    de              ;
        ld      hl, ($4012)     ; sv DEST
        dec     de              ;
        ld      a, c            ;
        sub     $06             ;
        ld      b, a            ;
        ld      a, $40          ;
        jr      z, L1359        ; forward to L-SINGLE
;
;; L-CHAR
L134B:  inc hl                  ;
        ld      a, (hl)         ;
        and     a               ; is it a space ?
        jr      z, L134B        ; back to L-CHAR

        inc     de              ;
        ld      (de), a         ;
        djnz    L134B           ; loop back to L-CHAR

        or      $80             ;
        ld      (de), a         ;
        ld      a, $80          ;
;
;; L-SINGLE
L1359:  ld hl, ($4012)          ; sv DEST-lo
        xor     (hl)            ;
        pop     hl              ;
        call    L13E7           ; routine L-FIRST

;; L-NUMERIC
L1361:  push hl                 ;

        rst     28H             ;; FP-CALC
        defb    $02             ;;delete
        defb    $34             ;;end-calc

        pop     hl              ;
        ld      bc, $0005       ;
        and     a               ;
        sbc     hl, bc          ;
        jr      L13AE           ; forward to L-ENTER
; ---
;
;; L-EXISTS
L136E:  bit 6, (iy+$01)         ; sv FLAGS  - Numeric or string result?
        jr      z, L137A        ; forward to L-DELETE$

        ld      de, $0006       ;
        add     hl, de          ;
        jr      L1361           ; back to L-NUMERIC
; ---
;
;; L-DELETE$
L137A:  ld hl, ($4012)          ; sv DEST-lo
        ld      bc, ($402E)     ; sv STRLEN_lo
        bit     0, (iy+$2D)     ; sv FLAGX
        jr      nz, L13B7       ; forward to L-ADD$

        ld      a, b            ;
        or      c               ;
        ret     z               ;

        push    hl              ;

        rst     30H             ; BC-SPACES
        push    de              ;
        push    bc              ;
        ld      d, h            ;
        ld      e, l            ;
        inc     hl              ;
        ld      (hl), $00       ;
        lddr                    ; Copy Bytes
        push    hl              ;
        call    STK_FETCH       ; routine STK-FETCH
        pop     hl              ;
        ex      (sp), hl        ;
        and     a               ;
        sbc     hl, bc          ;
        add     hl, bc          ;
        jr      nc, L13A3       ; forward to L-LENGTH

        ld      b, h            ;
        ld      c, l            ;
;
;; L-LENGTH
L13A3:  ex (sp), hl             ;
        ex      de, hl          ;
        ld      a, b            ;
        or      c               ;
        jr      z, L13AB        ; forward if zero to L-IN-W/S

        ldir                    ; Copy Bytes
;
;; L-IN-W/S
L13AB:  pop bc                  ;
        pop     de              ;
        pop     hl              ;
;
; ------------------------
; THE 'L-ENTER' SUBROUTINE
; ------------------------
;   Part of the LET command contains a natural subroutine which is a
;   conditional LDIR. The copy only occurs of BC is non-zero.
;
;; L-ENTER
L13AE:
        ex      de, hl          ;
COND_MV
        ld      a, b            ;
        or      c               ;
        ret     z               ;

        push    de              ;
        ldir                    ; Copy Bytes
        pop     hl              ;
        ret                     ; return.
; ---
;
;; L-ADD$
L13B7:  dec hl                  ;
        dec     hl              ;
        dec     hl              ;
        ld      a, (hl)         ;
        push    hl              ;
        push    bc              ;

        call    L13CE           ; routine L-STRING

        pop     bc              ;
        pop     hl              ;
        inc     bc              ;
        inc     bc              ;
        inc     bc              ;
        jp      L0A60           ; jump back to exit via RECLAIM-2
; ---
;
;; L-NEW$
L13C8:  ld a, $60               ; prepare mask %01100000
        ld      hl, ($4012)     ; sv DEST-lo
        xor     (hl)            ;
;
; -------------------------
; THE 'L-STRING' SUBROUTINE
; -------------------------
;
;; L-STRING
L13CE:  push af                 ;
        call    STK_FETCH       ; routine STK-FETCH
        ex      de, hl          ;
        add     hl, bc          ;
        push    hl              ;
        inc     bc              ;
        inc     bc              ;
        inc     bc              ;

        rst     30H             ; BC-SPACES
        ex      de, hl          ;
        pop     hl              ;
        dec     bc              ;
        dec     bc              ;
        push    bc              ;
        lddr                    ; Copy Bytes
        ex      de, hl          ;
        pop     bc              ;
        dec     bc              ;
        ld      (hl), b         ;
        dec     hl              ;
        ld      (hl), c         ;
        pop     af              ;
;
;; L-FIRST
L13E7:  push af                 ;
        call    L14C7           ; routine REC-V80
        pop     af              ;
        dec     hl              ;
        ld      (hl), a         ;
        ld      hl, ($401A)     ; sv STKBOT_lo
        ld      ($4014), hl     ; sv E_LINE_lo
        dec     hl              ;
        ld      (hl), $80       ;
        ret                     ;
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
STK_FETCH                       ; (L13F8)
        ld      hl, ($401C)     ; load HL from system variable STKEND

        dec     hl              ;
        ld      b, (hl)         ;
        dec     hl              ;
        ld      c, (hl)         ;
        dec     hl              ;
        ld      d, (hl)         ;
        dec     hl              ;
        ld      e, (hl)         ;
        dec     hl              ;
        ld      a, (hl)         ;

        ld      ($401C), hl     ; set system variable STKEND to lower value.
        ret                     ; return.
;
; -------------------------
; THE 'DIM' COMMAND ROUTINE
; -------------------------
; An array is created and initialized to zeros which is also the space
; character on the ZX81.
;
;; DIM
L1409:  call L111C              ; routine LOOK-VARS
;
;; D-RPORT-C
L140C:  jp nz, L0D9A            ; to REPORT-C

        call    L0DA6           ; routine SYNTAX-Z
        jr      nz, L141C       ; forward to D-RUN

        res     6, c            ;
        call    L11A7           ; routine STK-VAR
        call    L0D1D           ; routine CHECK-END
;
;; D-RUN
L141C:  jr c, L1426             ; forward to D-LETTER

        push    bc              ;
        call    L09F2           ; routine NEXT-ONE
        call    L0A60           ; routine RECLAIM-2
        pop     bc              ;
;
;; D-LETTER
L1426:  set 7, c                ;
        ld      b, $00          ;
        push    bc              ;
        ld      hl, $0001       ;
        bit     6, c            ;
        jr      nz, L1434       ; forward to D-SIZE

        ld      l, $05          ;
;
;; D-SIZE
L1434:  ex de, hl               ;
;
;; D-NO-LOOP
L1435:  rst 20H                 ; NEXT-CHAR
        ld      h, $40          ;
        call    L12DD           ; routine INT-EXP1
        jp      c, L1231        ; jump back to REPORT-3

        pop     hl              ;
        push    bc              ;
        inc     h               ;
        push    hl              ;
        ld      h, b            ;
        ld      l, c            ;
        call    L1305           ; routine GET-HL*DE
        ex      de, hl          ;

        rst     18H             ; GET-CHAR
        cp      $1A             ;
        jr      z, L1435        ; back to D-NO-LOOP

        cp      $11             ; is it ')' ?
        jr      nz, L140C       ; back if not to D-RPORT-C

        rst     20H             ; NEXT-CHAR
        pop     bc              ;
        ld      a, c            ;
        ld      l, b            ;
        ld      h, $00          ;
        inc     hl              ;
        inc     hl              ;
        add     hl, hl          ;
        add     hl, de          ;
        jp      c, L0ED3        ; jump to REPORT-4

        push    de              ;
        push    bc              ;
        push    hl              ;
        ld      b, h            ;
        ld      c, l            ;
        ld      hl, ($4014)     ; sv E_LINE_lo
        dec     hl              ;
        call    L099E           ; routine MAKE-ROOM
        inc     hl              ;
        ld      (hl), a         ;
        pop     bc              ;
        dec     bc              ;
        dec     bc              ;
        dec     bc              ;
        inc     hl              ;
        ld      (hl), c         ;
        inc     hl              ;
        ld      (hl), b         ;
        pop     af              ;
        inc     hl              ;
        ld      (hl), a         ;
        ld      h, d            ;
        ld      l, e            ;
        dec     de              ;
        ld      (hl), $00       ;
        pop     bc              ;
        lddr                    ; Copy Bytes
;
;; DIM-SIZES
L147F:  pop bc                  ;
        ld      (hl), b         ;
        dec     hl              ;
        ld      (hl), c         ;
        dec     hl              ;
        dec     a               ;
        jr      nz, L147F       ; back to DIM-SIZES

        ret                     ; return.
;
; ---------------------
; THE 'RESERVE' ROUTINE
; ---------------------
;
;; RESERVE
L1488:  ld hl, ($401A)          ; address STKBOT
        dec     hl              ; now last byte of workspace
        call    L099E           ; routine MAKE-ROOM
        inc     hl              ;
        inc     hl              ;
        pop     bc              ;
        ld      ($4014), bc     ; sv E_LINE_lo
        pop     bc              ;
        ex      de, hl          ;
        inc     hl              ;
        ret                     ;
;
; ---------------------------
; THE 'CLEAR' COMMAND ROUTINE
; ---------------------------
;
;; CLEAR
L149A:  ld hl, ($4010)          ; sv VARS_lo
        ld      (hl), $80       ;
        inc     hl              ;
        ld      ($4014), hl     ; sv E_LINE_lo
;
; -----------------------
; THE 'X-TEMP' SUBROUTINE
; -----------------------
;
;; X-TEMP
L14A3:  ld hl, ($4014)          ; sv E_LINE_lo
;
; ----------------------
; THE 'SET-STK' ROUTINES
; ----------------------
;
;; SET-STK-B
L14A6:  ld ($401A), hl          ; sv STKBOT
;
;; SET-STK-E
L14A9:  ld ($401C), hl          ; sv STKEND
        ret                     ;
;
; -----------------------
; THE 'CURSOR-IN' ROUTINE
; -----------------------
; This routine is called to set the edit line to the minimum cursor/newline
; and to set STKEND, the start of free space, at the next position.
;
;; CURSOR-IN
L14AD:  ld hl, ($4014)          ; fetch start of edit line from E_LINE
        ld      (hl), $7F       ; insert cursor character

        inc     hl              ; point to next location.
        ld      (hl), $76       ; insert NEWLINE character
        inc     hl              ; point to next free location.

        ld      (iy+$22), $02   ; set lower screen display file size DF_SZ

        jr      L14A6           ; exit via SET-STK-B above
;
; ------------------------
; THE 'SET-MIN' SUBROUTINE
; ------------------------
;
;; SET-MIN
L14BC:  ld hl, $405D            ; normal location of calculator's memory area
        ld      ($401F), hl     ; update system variable MEM
        ld      hl, ($401A)     ; fetch STKBOT
        jr      L14A9           ; back to SET-STK-E
;
; ------------------------------------
; THE 'RECLAIM THE END-MARKER' ROUTINE
; ------------------------------------
;
;; REC-V80
L14C7:  ld de, ($4014)          ; sv E_LINE_lo
        jp      L0A5D           ; to RECLAIM-1
;
; ----------------------
; THE 'ALPHA' SUBROUTINE
; ----------------------
;
;; ALPHA
L14CE:  cp $26                  ;
        jr      L14D4           ; skip forward to ALPHA-2
;
; -------------------------
; THE 'ALPHANUM' SUBROUTINE
; -------------------------

;; ALPHANUM
L14D2:  cp $1C                  ;
;
;; ALPHA-2
L14D4:  ccf                     ; Complement Carry Flag
        ret     nc              ;

        cp      $40             ;
        ret                     ;
;
; ------------------------------------------
; THE 'DECIMAL TO FLOATING POINT' SUBROUTINE
; ------------------------------------------
;
;; DEC-TO-FP
L14D9:  call L1548              ; routine INT-TO-FP gets first part
        cp      $1B             ; is character a '.' ?
        jr      nz, L14F5       ; forward if not to E-FORMAT

        rst     28H             ;; FP-CALC
        defb    $A1             ;;stk-one
        defb    $C0             ;;st-mem-0
        defb    $02             ;;delete
        defb    $34             ;;end-calc
;
; ---------------------
; THE 'NEXT DIGIT' LOOP
; ---------------------
;   Within the 'DECIMAL TO FLOATING POINT' routine, swapping the multiply and
;   divide literals preserves accuracy and ensures that .5 is evaluated
;   as 5/10 and not as .1 * 5.
;
;; NXT-DGT-1
L14E5:  rst 20H                 ; NEXT-CHAR
        call    L1514           ; routine STK-DIGIT
        jr      c, L14F5        ; forward to E-FORMAT

        rst     28H             ;; FP-CALC

        defb    $E0             ;;get-mem-0

        .db $3B                 ;;macro mul-by-10

        defb    $C0             ;;st-mem-0
        defb    $05             ;;+division
        defb    $0F             ;;addition
        defb    $34             ;;end-calc

        jr      L14E5           ; loop back till exhausted to NXT-DGT-1
; ---
        .db $FF                 ; spare :)
;
;; E-FORMAT
L14F5:  cp $2A                  ; is character 'E' ?
        ret     nz              ; return if not

        ld      (iy+$5D), $FF   ; initialize sv MEM-0-1st to $FF TRUE

        rst     20H             ; NEXT-CHAR
        cp      $15             ; is character a '+' ?
        jr      z, L1508        ; forward if so to SIGN-DONE

        cp      $16             ; is it a '-' ?
        jr      nz, L1509       ; forward if not to ST-E-PART

        inc     (iy+$5D)        ; sv MEM-0-1st change to FALSE

;; SIGN-DONE
L1508:  rst 20H                 ; NEXT-CHAR

;; ST-E-PART
L1509:  call L1548              ; routine INT-TO-FP

        rst     28H             ;; FP-CALC  m, e.
        defb    $E0             ;;get-mem-0 m, e, (1/0) TRUE/FALSE

        defb    $00             ;;jump-true
        defb    L1511-$         ;;to E-POSTVE

        defb    $18             ;;neg       m, -e

;; E-POSTVE
L1511:  defb $38                ;;e-to-fp   x.
        defb    $34             ;;end-calc  x.

        ret                     ; return.
;
; --------------------------
; THE 'STK-DIGIT' SUBROUTINE
; --------------------------
;
;; STK-DIGIT
L1514:  cp $1C                  ;
        ret     c               ;

        cp      $26             ;
        ccf                     ; Complement Carry Flag
        ret     c               ;

        sub     $1C             ;
;
; ------------------------
; THE 'STACK-A' SUBROUTINE
; ------------------------
;
STACK_A                         ; (L151D)
        ld      c, a            ;
        ld      b, $00          ;
;
; -------------------------
; THE 'STACK-BC' SUBROUTINE
; -------------------------
; The ZX81 does not have an integer number format so the BC register contents
; must be converted to their full floating-point form.
;
STACK_BC                        ; (L1520)
        ld      iy, $4000       ; re-initialize the system variables pointer.
        push    bc              ; save the integer value.

; now stack zero, five zero bytes as a starting point.

        rst     28H             ;; FP-CALC
        defb    $A0             ;;stk-zero  0.
        defb    $34             ;;end-calc

        pop     bc              ; restore integer value.

        ld      (hl), $91       ; place $91 in exponent 65536.
                                ; this is the maximum possible value

        ld      a, b            ; fetch hi-byte.
        and     a               ; test for zero.
        jr      nz, L1536       ; forward if not zero to STK-BC-2

        ld      (hl), a         ; else make exponent zero again
        or      c               ; test lo-byte
        ret     z               ; return if BC was zero - done.

; else  there has to be a set bit if only the value one.

        ld      b, c            ; save C in B.
        ld      c, (hl)         ; fetch zero to C
        ld      (hl), $89       ; make exponent $89  256.

;; STK-BC-2
L1536:  dec (hl)                ; decrement exponent - halving number
        sla     c               ;  C<-76543210<-0
        rl      b               ;  C<-76543210<-C
        jr      nc, L1536       ; loop back if no carry to STK-BC-2

        srl     b               ;  0->76543210->C
        rr      c               ;  C->76543210->C

        inc     hl              ; address first byte of mantissa
        ld      (hl), b         ; insert B
        inc     hl              ; address second byte of mantissa
        ld      (hl), c         ; insert C

        dec     hl              ; point to the
        dec     hl              ; exponent again
        ret                     ; return.
;
; ---------------------------------------------------
; THE improved 'INTEGER TO FLOATING POINT' SUBROUTINE
; ---------------------------------------------------
;
;; INT-TO-FP
L1548:  push af                 ;

        rst     28H             ;; FP-CALC
        defb    $A0             ;;stk-zero
        defb    $34             ;;end-calc

        pop     af              ;

;; NXT-DGT-2
L154D:  call L1514              ; routine STK-DIGIT
        ret     c               ;


        rst     28H             ;; FP-CALC
        defb    $01             ;;exchange

        .db $3B                 ;;macro mul-by-10

        defb    $0F             ;;addition
        defb    $34             ;;end-calc

        rst     20H             ; NEXT-CHAR
        jr      L154D           ; to NXT-DGT-2
; ---
        .db $FF                 ; spare :)
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
e_to_fp                         ; (L155A)
        call    L158A           ; routine FP-TO-BC - the exponent

        jr      z, E_POSTV      ; test the exponent's sign

        inc     b               ; if negative then B=1
        push    bc              ; save counter (exponent and its sign)

        rst     28H             ;; FP-CALC  x.
        .db $A4                 ;; stk-ten  x, 10.
        .db $34                 ;; end-calc

        jr      skip_mul        ; restore counter (exponent and its sign)
E_POSTV
        and     a               ; if exponent is zero
        ret     z               ; then return
;
;; E-LOOP   now enter a loop
LOOP_E10
        push    bc              ; save counter (exponent and its sign)
        call    mul_by10        ; multiply by 10
skip_mul
        pop     bc              ; restore counter (exponent and its sign)
        dec     c               ; set counter
        jr      nz, LOOP_E10    ; loop while nonzero

        djnz    E_END           ; in case of pos. exp. return

        rst     28H             ;; FP-CALC  else
        .db $05                 ;;division  x/10^exp10.
        .db $34                 ;;end-calc  new x.
E_END
        ret
;
;   ========================================================
mb_loop
        ld      b, 4            ; size of the mantissa
        ld      h, d            ; set pointer after the
        ld      l, e            ; LSB of the mantissa
        scf                     ; CY=1
nx_mbyte
        dec     hl              ; the last/prev. mantissa byte
        rl      (hl)            ; CY <- 76543210 <- CY
        djnz    nx_mbyte        ; done? back if not

        dec     hl              ; points the exponent
        dec     (hl)            ; decrease it
        ret                     ;
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
        call    FIND_INT        ; routine FIND-INT puts address in BC.
        ld      a, (bc)         ; load contents into A register.

        jp      STACK_A         ; exit via STACK-A to put value on the
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
L158A:  call STK_FETCH          ; routine STK-FETCH - exponent to A
                                ; mantissa to EDCB.
        rla                     ; test if abs(x)>=0.5  (exp>=128)
        jr      c, L1595        ; forward if yes (CY=1) to FPBC-NZRO
;
; else value is zero
;
        xor     a               ; else clear CY and A, set Z flag
        ld      b, a            ; zero to B
        ld      c, a            ; also to C
        jr      L15C4           ; forward to FPBC-ZRO
; ---
;
; EDCB  =>  BCE
;
;; FPBC-NZRO
L1595:
        ld      b, e            ; transfer the mantissa from EDCB
        ld      e, c            ; to BCE. Bit 7 of E is the 17th bit which
        ld      c, d            ; will be significant for rounding if the
                                ; number is already normalized.

        rra                     ; restore the original exponent

        sub     $91             ; subtract 65536
        ccf                     ; complement carry flag
        bit     7, b            ; test sign bit
        push    af              ; push the result

        set     7, b            ; set the implied bit
        jr      c, L15C5        ; forward with carry from SUB/CCF to FPBC-END
                                ; number is too big.

        cpl                     ; complement to make range $00 - $0F

        cp      $08             ; test if one or two bytes
        jr      c, L15AE        ; forward with two to BIG-INT

        ld      e, c            ; shift mantissa
        ld      c, b            ; 8 places right
        ld      b, $00          ; insert a zero in B
        sub     $08             ; reduce exponent by eight
;
;; BIG-INT
L15AE:  and a                   ; test the exponent
        ld      d, a            ; save exponent in D.

        ld      a, e            ; fractional bits to A
        rlca                    ; rotate most significant bit to carry for
                                ; rounding of an already normal number.

        jr      z, L15BB        ; forward if exponent zero to EXP-ZERO
                                ; the number is normalized
;
;; FPBC-NORM
L15B4:  srl b                   ;   0->76543210->C
        rr      c               ;   C->76543210->C

        dec     d               ; decrement exponent
        jr      nz, L15B4       ; loop back till zero to FPBC-NORM
;
;; EXP-ZERO
L15BB:
        jr      nc, L15C5       ; forward without carry to FPBC-END (NO-ROUND)

        inc     bc              ; round up.
        ld      a, b            ; test result
        or      c               ; for zero
        jr      nz, L15C5       ; forward if not to FPBC-END

        pop     af              ; restore sign flag
        scf                     ; set carry flag to indicate overflow

;; FPBC-ZRO
L15C4:  push af                 ; save combined flags again
;
;; FPBC-END
L15C5:  push bc                 ; save BC value

;; set HL and DE to calculator stack pointers.

        call    STK_PNTRS       ; routine STK-PNTRS is called to set up the
                                ; calculator stack pointers:
                                ; HL = last value on stack.
                                ; DE = STKEND first location after stack.

        pop     bc              ; restore BC value
        pop     af              ; restore flags
        ld      a, c            ; copy low byte to A also.
        ret                     ; return
;
; ------------------------------------
; THE 'FLOATING-POINT TO A' SUBROUTINE
; ------------------------------------
;
FP_TO_A                         ; (L15CD)
        call    L158A           ; routine FP-TO-BC
        ret     c               ;

        push    af              ;
        dec     b               ;
        inc     b               ;
        jr      z, L15D9        ; forward if in range to FP-A-END

        pop     af              ; fetch result
        scf                     ; set carry flag signaling overflow
        ret                     ; return
;
;; FP-A-END
L15D9:  pop af                  ;
        ret                     ;
;
; --------------------------------------------------
; THE new 'PRINT A FLOATING-POINT NUMBER' SUBROUTINE
; --------------------------------------------------
; prints 'last value' x on calculator stack.
;
;; PRINT-FP (L15DB)
PRINT_FP
        rst     28h             ; FP-CALC   x.
        .db $C0                 ;;set-mem-0 x.
        .db $02                 ;;delete    .   clear the
        .db $34                 ;;end-calc      calc. stack

        ld      a, (de)         ; pick up the exponent byte
        and     a               ; if it is zero, then return via
        jp      z, prnt_num     ; routine OUT-CODE (prints a zero)

        call    STACK_A         ; else STACK-A places on calculator stack.

        ld      hl, $405E       ; first byte of the mantissa (MEMBOT+1)
        bit     7, (hl)         ; test if positive
        set     7, (hl)         ; complete the mantissa (make it negative)

        ld      l, $67          ; set pointer to MEMBOT+10 (mem2)
        push    hl              ; save pointer (of the digit buffer)

        jr      z, positive     ; skip if positive

        ld      a, $16          ; load code '-'
        rst     10h             ; PRINT-A
positive
        rst     28H             ;; FP-CALC      e   [1..255]

        .db $30, $EF            ;; stk-data, exponent: $7F, bytes: 4
        .db $9A, $20, $9A, $84  ;;      e, -0.30103 (-log 2)

        .db $04                 ;; multiply     e*(-log 2)

        .db $30, $36            ;; stk-data exponent:   $86, Bytes: 1
        .db $1C                 ;; (+00,+00,+00)    e*(-log 2), 39

        .db $0F                 ;; addition     e*(-log 2)+39

        .db $C2                 ;; st-mem-2     exp10.
        .db $E0                 ;; get-mem-0        exp10, x.
        .db $E2                 ;; get-mem-2        exp10, x, exp10.

        .db $38                 ;; new e-to-fp      exp10,x * (10^exp10).
        .db $34                 ;; end-calc
;
;   ---------------------------------------------
;
        ld      bc, $0900       ; B: 9 digits to convert
                                ; C: exp10 factor (0 by default)
        push    bc              ; save counter/factor

        ld      a, (hl)         ; test the normalized number
        sub     $81             ; >=1?
        jr      nc, getDigit    ; if yes, then get the 1st digit

        pop     bc              ; else restore counter/factor
        dec     c               ; set factor to -1
        push    bc              ; save counter/factor
        inc     hl              ; set pointer to the mantissa, then
mul_ten
        dec     hl              ; hl points the exponent
        call    mul_by10        ; multiply by 10

        ld      a, (hl)         ; pick up the exponent
        sub     $81             ; test if >=1
        jr      nc, getDigit    ; jump if so

        xor     a               ; else clear A
        jr      putDigit        ; less than 1? -> put zero into buffer
;
;   --------------------------------------------- else
getDigit
        inc     a               ; exp-$80 gives the
        ld      c, a            ; bit counter of a digit
        xor     a               ; clear CY and the bit buffer
nxt_mbit
        call    mb_loop         ; shift left the mantissa

        rla                     ; store 1 bit of the digit
        dec     c               ; set bit counter
        jr      nz, nxt_mbit    ; done? -> back if not
putDigit
        pop     bc              ; restore counter/factor
        ex      (sp), hl        ; switch pointers
        ld      (hl), a         ; put digit into buffer
        inc     l               ; set buffer pointer
        ex      (sp), hl        ; switch back pointers

        dec     b               ; set the digit counter
        push    bc              ; save counter/factor
        jr      z, dig9done     ; done if it was the 9th digit
test_msb
        inc     hl              ; else normalize the number
        bit     7, (hl)         ; test the msb of the mantissa
        jr      nz, mul_ten     ; back if it is nonzero

        call    mb_loop         ; shift left the mantissa
        jr      test_msb        ;
;
;   ---------------------------------------------
dig9done
        call    STK_FETCH       ; remove final x from calc. stack

        call    FP_TO_A         ; FP-TO-A (-exp10) : A=abs(exp10)
        jr      nz, negative    ; if it is positive

        neg                     ; then make it negative
negative
        pop     bc              ; get the exp10 factor (0 or -1)
        add     a, c            ; and add to the exp10

        pop     hl              ; get the buffer pointer
        dec     l               ; points the 9th digit
        push    af              ; save the final exp10
;
;   ---------------------------------------------
rounding
        push    hl              ; save the buffer pointer
        ld      a, 4            ; test the last digit (>=5?)
        sub     (hl)            ; CY=1 if rounding is necessary
        ld      b, 8            ; set the digit counter
round_8
        dec     l               ; set buffer pointer
        ld      a, (hl)         ; pick up the next digit
        adc     a, $90          ; add the rounding bit
        daa                     ; BCD correction
        jr      c, overflow     ; jump if overflow

        and     $0F             ; else clear the upper nibble
overflow
        ld      (hl), a         ; store the digit
        djnz    round_8         ; done? -> back if not

        jr      nc, cnt_zero    ; jump if no overflow

        pop     hl              ; get pointer of the 9th digit
        pop     af              ; <- exp10
        inc     a               ; exp10 +1
        push    af              ; exp10 ->
        push    hl              ; save pointer
        ld      d, h            ; set the
        ld      e, l            ; destination pointer
        dec     l               ; 8th digit
        ld      c, 8            ; set counter
        lddr                    ; copy

        inc     l               ; HL points the first digit
        ld      (hl), 1         ; set as '1'
;
;   --------------------------------------------------
cnt_zero
        pop     hl              ; HL points the 9th digit
        pop     de              ; D <- exp10
;
;   --------------------------------------------------
;
        ld      bc, $0901       ; 8 digits to print, decimal
                                ; point is after the first
        ld      e, c            ; e=1 (not e-format)
cnt_back
        dec     l               ; points a digit of the mantissa
        dec     b               ; decrease the counter
        ld      a, (hl)         ; read in and
        and     a               ; test a digit of the mantissa
        jr      z, cnt_back     ; if zero then check next digit

        ld      a, d            ; test the exp10
        bit     7, a            ; positive?
        jr      z, pos_exp      ; yes, jump
;
;   --------------------------------------------------
;
        neg                     ; make it positive
        cp      $05             ; less than .0001?
        jr      nc, neg_exp     ; yes -> e-format
;
;   --------------------------------------------------
;
        ld      d, a            ; nr. of leading zeros
        add     a, b            ; increase and
        ld      b, a            ; save nr. of printable digits
leadzero
        xor     a               ; print
        call    pr_digit        ; leading
        dec     d               ; zeros
        jr      nz, leadzero    ; done?

        jr      not_efmt        ; forward to printing the rest
;
;   --------------------------------------------------
;
pos_exp
        cp      $08             ; more than 99999999?
        jr      nc, e_format    ; yes, e-format

        add     a, c            ; set position of
        ld      c, a            ; the decimal point
        cp      b               ; if nr. of the printable digits
        jr      c, not_efmt     ; is greater than position of the
                                ; decimal point then forward
        ld      b, c            ; else set nr. of printable digits
        jr      not_efmt        ; to decimal point position
;
;   --------------------------------------------------
neg_exp
        inc     e               ; the exponent is negative
;
;   --------------------------------------------------
e_format
        ld      d, a            ; save value of the exponent
        inc     e               ; set e-format (e>1)
;
;   --------------------------------------------------
not_efmt
        ld      l, $67          ; $4067 - addr. of the first digit
e_form1
        ld      a, (hl)         ; get value
        inc     l               ; set pointer
        call    pr_digit        ; display a digit

        jr      nz, e_form1     ; back until done
print_E
        dec     e               ; e-format (e>1) ?
        ret     z               ; no, done

        dec     c               ; else set decimal point

        ld      a, $2A          ;
        rst     10h             ; print 'E'

        ld      a, $15          ; load '+'
        dec     e               ; if exp>0 then E=0
        add     a, e            ; else E=1 -> A: '-'
        rst     10h             ; PRINT-A
;
;   --------------------------------------------------
;
        ld      a, d            ; get value of the exponent
set_E1
        ld      d, a            ; save as ones
        sub     10              ; decrease by 10
        jr      c, set_E2       ; until negative

        djnz    set_E1          ; count tens
set_E2
        xor     a               ; the counter of tens is negative
        sub     b               ; make it positive, then
        call    nz, pr_digit    ; print if nonzero

        ld      a, d            ; the ones
;
;   --------------------------------------------------
pr_digit
        call    prnt_num        ; print as number (0..9)

        dec     b               ; it was the last digit?
        ret     z               ; yes return

        dec     c               ; decimal point?
        ret     nz              ; no, return

        xor     a               ;
        jp      prnt_dot        ; print '.'
;
;   ============================================================== 36B
;   de: points sv VARS
;   hl: points the 1st free byte in D-FILE
cls_chck
        push    bc              ; save counter
        ld      a, c            ; test line counter (Y)
        cp      $18             ; clear whole screen?
        jr      nz, cls_skip    ; skip, if not

        set     5, (iy+$3B)     ; sv CDFLAG - signal expanded D-FILE
cls_skip
        add     a, a            ;  2*Y (line counter)
        add     a, a            ;  4*Y
        add     a, a            ;  8*Y
        ld      c, a            ; BC = 8 * Y (line counter)

        add     hl, bc          ; + 8 * Y
        add     hl, bc          ; + 8 * Y
        add     hl, bc          ; + 8 * Y
        add     hl, bc          ; HL points the
        dec     hl              ; end of D-FILE
        call    L0A17           ; routine DIFFER

        inc     bc              ;
        dec     hl              ; HL points the old end of D-FILE
        jr      c, cls_cont     ; if room is enough then return

        call    L099E           ; else routine MAKE-ROOM

        inc     de              ; position of the latest N/L in D-FILE
cls_cont
        ex      de, hl          ;
        inc     hl              ; points the (expected) variables area
        pop     bc              ; restore counter
        jp      clr_next        ; back to renewed CLS routine
;
;   ==============================================================
scrl_new
        jr      z, scrl_old     ; jump if D-File is collapsed
scrl_nxt
        ld      bc, 33          ; set byte counter (32 spaces + 1 N/L)
        ldir                    ; copy a line
        dec     a               ; set line counter
        jr      nz, scrl_nxt    ; done? back, if not

        jp      clr_scrl        ; clear the last line and return
;
;   --------------------------------------
scrl_old
        push    de              ;
        call    loc_pos0        ; ld c,$21 --> LOC-ADDR

        dec     hl              ; insert a N/L before the N/L
        call    L099B           ; routine ONE-SPACE

        pop     hl              ; HL points D_FILE
        inc     hl              ; skip 1st N/L
        ld      d, h            ; save pointer
        ld      e, l            ; in DE
        cpir                    ; find next N/L and
        jp      L0A5D           ; return via RECLAIM-1 (erase line 1)
;
;   ==============================================================
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
; =======       ARITHMETIC ROUTINES      =======
; ==============================================================
;
;   hl: points the LSB of the greater number's mantissa
;   a:  the LSB of the greater number's mantissa
;   b'7: the rounding bit
;   B(MSB),C,D,E(LSB) contain the less number's mantissa
sub_OP2
        exx                     ; ..    (alternate set)
        rlc     b               ; the rounding bit (B'7)
        exx                     ;  ..   (main set)

        sbc     a, e            ; the real subtraction
        ld      e, a            ; 4th byte of the mantissa
        dec     hl              ;
        ld      a, (hl)         ;
        sbc     a, d            ;
        ld      d, a            ; 3rd byte of the mantissa
        dec     hl              ;
        ld      a, (hl)         ;
        sbc     a, c            ;
        ld      c, a            ; 2nd byte of the mantissa
        dec     hl              ;
        ld      a, (hl)         ;
        set     7, a            ; the msb is always '1'
        sbc     a, b            ;
        ld      b, a            ; B(MSB),C,D,E(LSB): the result's mantissa

        ld      h, b            ;
        ld      l, c            ; HL: the upper word of the result's mantissa
        jr      nc, sub_spos    ; skip if it is positive

        ld      hl, 1           ; else negate the mantissa
        sbc     hl, de          ;
        ex      de, hl          ;
        add     hl, de          ; clear HL
        sbc     hl, bc          ; H,L,D,E: the result's mantissa
sub_spos
        ld      bc, $2100       ; set counters
        ld      a, c            ; clear A
        rra                     ; A7 indicates the sign change
sub_norm
        exx                     ; ..    (alternate set)
        rlc     b               ; the rounding bit (B'7)
        exx                     ;  ..   (main set)
        bit     7, h            ; normalize
        jp      nz, sub_end     ; done if msb=1

        ex      de, hl          ;
        adc     hl, hl          ; double the lower word of the result's mantissa
        ex      de, hl          ;
        adc     hl, hl          ; double the upper word of the result's mantissa
        inc     c               ; set counter
        djnz    sub_norm        ; max. 32 shifts are accepted
;
;   --------------------------------------------------------
;
        pop     hl              ; drop return address
        pop     hl              ; drop the greater exponent
        jr      z_result        ; the result is zero
;
;   ========================================================
;
; ---------------------------
; THE 'SUBTRACTION' OPERATION
; ---------------------------
; just switch the sign of subtrahend and do an add.
;
;; subtract (L174C)
;
;   ========================================================
; in:
;   hl: points OP1 (the destination)
;   de: points OP2
;
subtract
        ld      a, (de)         ; fetch exponent byte of second number the
                                ; subtrahend.
        and     a               ; test for zero
        ret     z               ; return if zero - first number is result.

        inc     de              ; address the first mantissa byte.
        ld      a, (de)         ; fetch to accumulator.
        xor     $80             ; toggle the sign bit.
        ld      (de), a         ; place back on calculator stack.
        dec     de              ; point to exponent byte.
                                ; continue into addition routine.
;
;   ========================================================
;
; ----------------------------
; THE new 'ADDITION' OPERATION
; ----------------------------
;
;; addition (L1755)
;
;   ========================================================
; in &
; out:  hl: points OP1 (the destination)
;   de: points OP2
;
addition
        ld      a, (de)         ; fetch OP2.exp
        and     a               ; =0?
        ret     z               ; if yes, then OP1 is the result

        ld      c, a            ; save OP2.exp
        ld      a, (hl)         ; fetch OP1.exp
        and     a               ; =0?

        push    de              ; save the original
        push    hl              ; pointers

        jr      z, fw_OPcpy     ; if OP1=0, then OP2 is the result
                                ; return via 'copy_OP2'
        ld      b, a            ; save OP1.exp
        sub     c               ; OP1.exp-OP2.exp

        cp      33              ; test distance
        jr      c, pos_dist     ; jump if it is less than 33 bit

        cp      -32             ; if it is more
        jp      c, diff_33p     ; then return

        cpl                     ; the difference is negative
        inc     a               ; so negate it
        ld      b, c            ; change the greater exponent
        ex      de, hl          ; de points the less number
pos_dist
        push    bc              ; save the greater exponent (B)
        inc     hl              ; n1
        ld      c, (hl)         ; sgn
        push    hl              ; save pointer (man. of the greater num.)
        ex      de, hl          ; hl points the less exponent

        inc     hl              ; m1
        ld      b, (hl)         ; sgn
        push    bc              ; save MSBs

        inc     hl              ; m2
        ld      c, (hl)         ;
        inc     hl              ; m3
        ld      d, (hl)         ;
        inc     hl              ; m4
        ld      e, (hl)         ; the LSB

        set     7, b            ; the msb is always '1'

        and     a               ; test distance (& clear CY)
        jr      z, skp_shft     ; skip shifting if zero
add_shft
        srl     b               ; 0 -> bbbbbbbb -> CY
        rr      c               ; CY -> cccccccc -> CY
        rr      d               ; CY -> dddddddd -> CY
        rr      e               ; CY -> eeeeeeee -> CY
        dec     a               ;
        jr      nz, add_shft    ;
skp_shft
        exx                     ; ..    (alternate set)
        sbc     a, a            ; depending on rounding bit
        ld      b, a            ; B=$00 or B=$FF
        exx                     ; ..    (main set)

        pop     hl              ; the MSBs contain the sign bits
        ld      a, h            ; which select the next operation:
        xor     l               ; if A7=0 then addition else subtraction

        ld      h, l            ; save sign bit (H7) and HL now
        ex      (sp), hl        ; points the greater number's MSB

        rla                     ; if CY=0 then addition else subtraction
        call    addorsub        ; execute operation

        pop     hl              ; the sign bit (h7)
        ex      (sp), hl        ; H = the greater exponent

        and     a               ; test correction's value
;
;   --------------------------------------------------------
;   the multiplcation and the division joins here
;
m_d_exit
        jp      m, add_nexp     ; jump if it is negative
sub_pexp
        ld      l, a            ; else decrease
        ld      a, h            ; the exponent
        sub     l               ; w. correction
        jr      z, z_result     ; skip if underflow (<=0)

        jr      nc, set_Exp1    ; else store the return value
;
;   --------------------------------------------------------
z_result
        pop     hl              ; drop flags
        pop     hl              ; restore the OP1 pointer
        xor     a               ;
        ld      (hl), a         ; clear OP1.exp

        ld      c, a            ; clear the
        ld      d, a            ; arithmetic
        ld      e, a            ; buffer
        jr      OP1_fill        ; and set OP1 as zero
;
;   --------------------------------------------------------
set_Exp1
        pop     hl              ; the sign bit (H7)
        ex      (sp), hl        ; points OP1
        ld      (hl), a         ; set OP1.exp

        ld      a, $80          ; mask of the sign bit (A7)
        xor     b               ; toggle
        ld      b, a            ; the sign bit (B7)

        pop     af              ; the new sign bit (A7)
        and     $80             ; mask out the sign bit
        xor     b               ; apply changes
OP1_fill
        push    hl              ;
        inc     hl              ; points OP1.man1
        ld      (hl), a         ;
        inc     hl              ; points OP1.man2
        ld      (hl), c         ;
        inc     hl              ; points OP1.man3
        ld      (hl), d         ;
        inc     hl              ; points OP1.man4
        ld      (hl), e         ;
ret_OP1
        pop     hl              ; restore the
        pop     de              ; pointers
        ret                     ; done
;
;   ========================================================
;
; ---------------------------------------
; THE improved 'MULTIPLICATION' OPERATION
; ---------------------------------------
;
;; multiply (L17C6)
;
;   ========================================================
; in &
; out:  hl: points OP1 (the destination)
;   de: points OP2
;
multiply
        ld      a, (hl)         ; fetch OP1.exp
        and     a               ; if it is zero,
        ret     z               ; then the result is zero

        ld      b, a            ; store exp1
        ld      a, (de)         ; fetch OP2.exp
        and     a               ; test zero

        push    de              ; save the original
        push    hl              ; pointers
fw_OPcpy
        jr      z, copy_OP2     ; OP2=0? -> return via 'copy_OP2'

        ld      c, a            ; store exp2
        push    bc              ; save exp1,exp2

        call    fetchOps        ; fetch both mantissas into Z80 registers

        push    af              ; man1.S * man2.S
        push    hl              ; save pointer to the next calculator literal
        sbc     hl, hl          ; H'L'H,L = 0

        ld      a, b            ; transfer high mantissa byte of first number
        ld      b, $20          ; register B can now be used to count 32 shifts.
; ---
;
mul_loop
        rra                     ; C > 76543210 > C
        rr      c               ; C > 76543210 > C
        exx                     ; ..    (main set)
        rr      b               ; C > 76543210 > C
        rr      c               ; C > 76543210 > C

        jr      nc, skip_add    ; skip if no carry, else add in the multiplicand.

        add     hl, de          ; add the lower word to result
        exx                     ; switch to more significant bytes.
        adc     hl, de          ; add high bytes of multiplicand and any carry.
        exx                     ; switch back to main set
skip_add
        exx                     ; ..    (alternate set)
        rr      h               ; C > 76543210 > C
        rr      l               ; C > 76543210 > C
        exx                     ; ..    (main set)
        rr      h               ; C > 76543210 > C
        rr      l               ; C > 76543210 > C
        exx                     ; ..    (alternate set)

        djnz    mul_loop        ; loop back 32 times

        ex      (sp), hl        ; save upper word of the mantissa and
                                ; restore pointer to the next calculator literal
        exx                     ; switch back to main set
        ex      de, hl          ;
        pop     bc              ; mantissa in B(MSB),C,D,E(LSB)

        pop     hl              ; man1.S * man2.S
        ex      (sp), hl        ; exp1,exp2

        bit     7, b            ; if the mantissa's msb is '1',
        jr      nz, man_isOK    ; then skip the shifting

        rl      e               ; else shift left the mantissa
        rl      d               ;
        rl      c               ;
        rl      b               ;
        rla                     ; underflow bit to CY
        dec     h               ; exponent correction
man_isOK
        ld      a, 0            ; set correction to zero
        call    c, round32b     ; round if it is necessary

        sub     l               ; fetch exp2 with correction
        add     a, $80          ; remove the offset
        jr      m_d_exit        ; go to subtract from exp1
;
;   ========================================================
;
;   sub_OP2 (the real subtraction) routine ends here
sub_end
        xor     h               ; set the sign bit
        ld      b, a            ; store the MSB of the mantissa
        ld      a, c            ; store the counter
        ld      c, l            ; the 2nd byte of the mantissa
        ret
;
;   ========================================================
;
;   addition joins here if difference between exponents is more than 32
;   the final result will be the number with greater exponent
;
diff_33p
        rla                     ; if difference is positive,
        jr      nc, ret_OP1     ; then OP1 is the result, else
copy_OP2
        ex      de, hl          ; exchange the pointers
        ld      bc, 5           ; 5 bytes to copy
        ldir                    ; copy
        jr      ret_OP1         ; restore the pointers
;
;   ========================================================
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
; Out:  B'C'B,C : OP1.man
;   D'E'D,E : OP2.man
;   HL = 0
;   A7 = sign bit of the (later) result
;
fetchOps
        inc     de              ; set OP2 pointer
        ld      a, (de)         ; fetch MSB of the man2
        inc     hl              ; set OP1 pointer
        ld      b, (hl)         ; fetch MSB of the man1
        xor     b               ; A7 = man1.S * man2.S (and CY=0!)

        inc     hl              ; set OP1 pointer
        ld      c, (hl)         ; fetch man1.2
        push    bc              ; save man1.1,man1.2

        inc     hl              ; set OP1 pointer
        ld      b, (hl)         ; fetch man1.3
        inc     hl              ; fetch set OP1 pointer
        ld      c, (hl)         ; fetch man1.4

        ex      de, hl          ; HL points now OP2

        ld      d, (hl)         ; fetch man2.1
        inc     hl              ; set OP2 pointer
        ld      e, (hl)         ; fetch man2.2
        push    de              ; save man2.1,man2.2

        inc     hl              ; set OP2 pointer
        ld      d, (hl)         ; fetch man2.3
        inc     hl              ; set OP2 pointer
        ld      e, (hl)         ; fetch man2.4

        sbc     hl, hl          ; clear HL

        exx                     ; switch to alternate set
        pop     de              ; man2.1,man2.2
        set     7, d            ; the msb is always '1'
        pop     bc              ; man1.1,man1.2
        set     7, b            ; the msb is always '1'

        ret                     ;
;
;   ========================================================
;
;   CY indicates the operation: 0=addition 1=subtraction
;   hl: points the MSB of the greater number's mantissa
;   b'7: the rounding bit
;   B(MSB),C,D,E(LSB) contain the less number's mantissa
addorsub
        inc     hl              ; set pointer
        inc     hl              ;
        inc     hl              ; HL now points the LSB of the mantissa
        ld      a, (hl)         ; fetch the LSB of the mantissa

        jp      c, sub_OP2      ; CY=1? --> subtraction

        add     a, e            ; the real addition
        ld      e, a            ; 4th byte of the mantissa
        dec     hl              ;
        ld      a, (hl)         ;
        adc     a, d            ;
        ld      d, a            ; 3rd byte of the mantissa
        dec     hl              ;
        ld      a, (hl)         ;
        adc     a, c            ;
        ld      c, a            ; 2nd byte of the mantissa
        dec     hl              ;
        ld      a, (hl)         ;
        set     7, a            ; the msb is always '1'
        adc     a, b            ;
;
;   --------------------------------------------------------
norm_res
        ld      b, a            ; B(MSB),C,D,E(LSB): the result's mantissa

        sbc     a, a            ; if CY=1 -> A=-1 ($FF)
        jr      nc, roundbit    ; if CY=0 -> A= 0   - the correction -

        rr      b               ; CY -> bbbbbbbb -> CY
        rr      c               ; CY -> cccccccc -> CY
        rr      d               ; CY -> dddddddd -> CY
        rr      e               ; CY -> eeeeeeee -> CY
norm_end
        ret     nc              ;
;
;   --------------------------------------------------------
round32b
        inc     e               ; set LS byte of the mantissa
        ret     nz              ; return if there is no overflow

        inc     d               ; set 3rd byte of the mantissa
        ret     nz              ; return if there is no overflow

        inc     c               ; set 2nd byte of the mantissa
        ret     nz              ; return if there is no overflow

        inc     b               ; set MS byte of the mantissa
        ret     nz              ; return if there is no overflow

        ld      b, $80          ; else set MSB and
        dec     a               ; adjust the correction
        ret                     ;
;
;   --------------------------------------------------------
roundbit
        exx                     ; ..    (alternate set)
        rl      b               ; restore the rounding bit (B'7)
        exx                     ; ..    (main set)
        jr      norm_end        ; and round if it is necessary
;
;   ========================================================
add_nexp
        neg                     ; make it positive

        add     a, h            ; add the 2 exponents
        jp      nc, set_Exp1    ; store the result if not overflow
;
;   --------------------------------------------------------
;
;; REPORT-6 (L1880)
;
error_6
        rst     08h             ; Error Report:
        .db $05                 ; Arithmetic overflow.
;
;   ========================================================
;
; ---------------------------------
; THE improved 'DIVISION' OPERATION
; ---------------------------------
;
;; division (L1882)
;
;   ========================================================
; in &
; out:  hl: points OP1 (the destination)
;   de: points OP2
;
division
        ld      a, (de)         ; check for division by zero
        and     a               ; if exp2=0,
        jr      z, error_6      ; then -> Arithmetic overflow

        ld      c, a            ; store exp2
        ld      a, (hl)         ; fetch exp1
        and     a               ; if it is zero,
        ret     z               ; then the result also is zero

        push    de              ; save the original
        push    hl              ; pointers

        ld      b, a            ; store exp1
        push    bc              ; save exp1,exp2

        call    fetchOps        ; fetch both mantissas into Z80 registers

        push    af              ; man1.S * man2.S
        push    hl              ; save pointer to the next calculator literal

        ld      h, b            ;
        ld      l, c            ; H'L' = upper 2 bytes of the dividend

        xor     a               ; clear MSB of the result
        ld      b, a            ; clear lower 2 bytes of the result
        ld      c, a            ;

        exx                     ; switch back to main set
        ld      h, b            ;
        ld      l, c            ; H,L = lower 2 bytes of the dividend
        ld      bc, $DF00       ; B: a counter (-33), C: 2nd byte of the result
; ---
;
div_loop
        sbc     hl, de          ; subtract divisor part
        exx                     ; ..    (alternate set)
        sbc     hl, de          ;
        jr      nc, shft_inv    ; forward if there is no overflow

        exx                     ; ..    (main set)
        add     hl, de          ; else restore
        exx                     ; ..    (alternate set)
        adc     hl, de          ;
shft_inv
        ccf                     ; complement carry flag
shft_bin
        rl      c               ; multiply partial quotient by two
        rl      b               ; setting result bit from carry
        exx                     ; ..    (main set)
        rl      c               ;
        rla                     ;
        inc     b               ; increment the counter
        jr      c, endofdiv     ; exit, if the 33th bit is done

        add     hl, hl          ;
        exx                     ; ..    (alternate set)
        adc     hl, hl          ;
        exx                     ; ..    (main set)
        jr      nc, div_loop    ;

        and     a               ; SUB-ONLY
        sbc     hl, de          ;
        exx                     ; ..    (alternate set)
        sbc     hl, de          ;

        scf                     ; set CY to shift '1' into
        jr      shft_bin        ; the partial quotient
endofdiv
        exx                     ; ..    (alternate set)
        pop     hl              ; pointer to the next calculator literal
        push    bc              ; the lower 2 bytes of the mantissa
        exx                     ; ..    (main set)
        pop     de              ; D,E = lower 2 bytes of the mantissa

        pop     hl              ; man1.S * man2.S
        ex      (sp), hl        ; exp1,exp2
        djnz    divbit33        ; skip if there were 33 subtractions

        inc     l               ; else set correction
divbit33
        call    norm_res        ; shift right and round (if it is necessary)

        cpl                     ; set correction: -1 ->  0; -2 -> 1
        dec     a               ;          0 -> -1;  1 -> 0
        add     a, l            ; fetch exp2 and add correction
        sub     $80             ; remove the offset
        jp      m_d_exit        ; jump to subtract exponents
;
;   ========================================================
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
        call    FIND_INT        ; routine FIND-INT to fetch the
                                ; supplied address into BC.
        ld      hl, STACK_BC    ; address: STACK-BC is
        push    hl              ; pushed onto the machine stack.
        push    bc              ; then the address of the machine code
                                ; routine.
        ret                     ; make an indirect jump to the user's routine
                                ; and, hopefully, to STACK-BC also.
;
; ---------------------------------------------------------
; THE improved 'INTEGER TRUNCATION TOWARDS ZERO' SUBROUTINE
; ---------------------------------------------------------
; (offset $36: 'truncate')
truncate                        ; (L18E4)
        ld      a, (hl)         ; fetch exponent

        add     a, $7F          ; if abs(number)<1       (eponent<$81)
        jp      nc, FP_0_1      ; then return with zero         (CY=0)

        cp      $1F             ; return if all 32 bits of the mantissa
        ret     nc              ; relate to the integer part.    (eponent>$9f)

        cpl                     ; else form number of rightmost bits
        add     a, $20          ; to be blanked.
;
; for instance, disregarding the sign bit, the number 3.5 is held as
; exponent $82 mantissa .11100000 00000000 00000000 00000000
; we need to set $82+$7F=$01, CPL=$FE, $FE+$20=$1E(thirty) bits to zero
; to form the integer. The sign of the number is never considered as the
; first bit of the mantissa must be part of the integer.
;
;; NIL-BYTES
;;L18F4:
        push    de              ; save pointer to STKEND
        ex      de, hl          ; HL points at STKEND
clr_byte
        dec     hl              ;
        sub     $08             ;
        jr      c, clr_bits     ;

        ld      (hl), 0         ;
        jr      clr_byte        ;

; now consider any residual bits.
;
clr_bits
        add     a, $08          ; the remaining bits
        jr      z, ix_end       ; forward if none to IX-END

        ld      b, a            ; transfer bit count to B counter.

        sbc     a, a            ; form a mask 11111111
;
;; LESS-MASK (L190C)
lessMask
        sla     a               ; 1 <- 76543210 <- o    slide mask leftwards.
        djnz    lessMask        ; loop back for bit count to LESS-MASK

        and     (hl)            ; lose the unwanted rightmost bits
        ld      (hl), a         ; and place in mantissa byte.
;
;; IX-END (L1912)
ix_end
        ex      de, hl          ; restore result pointer from DE.
        pop     de              ; restore STKEND from stack.
        ret                     ; return.
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
        defb    $00             ; the value zero.
        defb    $00             ;
        defb    $00             ;
        defb    $00             ;
        defb    $00             ;

        defb    $81             ; the floating point value 1.
        defb    $00             ;
        defb    $00             ;
        defb    $00             ;
        defb    $00             ;

        defb    $80             ; the floating point value 1/2.
        defb    $00             ;
        defb    $00             ;
        defb    $00             ;
        defb    $00             ;

        defb    $81             ; the floating point value pi/2.
        defb    $49             ;
        defb    $0F             ;
        defb    $DA             ;
        defb    $A2             ;

        defb    $84             ; the floating point value ten.
        defb    $20             ;
        defb    $00             ;
        defb    $00             ;
        defb    $00             ;
;
; ------------------------
; THE 'TABLE OF ADDRESSES'
; ------------------------
;
; starts with binary operations which have two operands and one result.
; three pseudo binary operations first.
;
tbl_addrs
        defw    jmp_true        ; $00 - jump-true
        defw    exchange        ; $01 - exchange
        defw    delete          ; $02 - delete
;
;   true binary operations.
;
        defw    subtract        ; $03 - subtract
        defw    multiply        ; $04 - multiply
        defw    division        ; $05 - division
        defw    to_power        ; $06 - to-power
        defw    op_or           ; $07 - or

        defw    hnd_AND         ; $08 - no-&-no
        defw    comp_not        ; $09 - no-l-eql
        defw    comp_not        ; $0A - no-gr-eql
        defw    comp_not        ; $0B - nos-neql
        defw    comp_tru        ; $0C - no-grtr
        defw    comp_tru        ; $0D - no-less
        defw    comp_tru        ; $0E - nos-eql
        defw    addition        ; $0F - addition

        defw    hnd_AND         ; $10 - str-&-no
        defw    comp_not        ; $11 - str-l-eql
        defw    comp_not        ; $12 - str-gr-eql
        defw    comp_not        ; $13 - strs-neql
        defw    comp_tru        ; $14 - str-grtr
        defw    comp_tru        ; $15 - str-less
        defw    comp_tru        ; $16 - strs-eql
        defw    strs_add        ; $17 - strs-add
;
;   unary follow
;
        defw    negate          ; $18 - neg

        defw    fn_code         ; $19 - code
        defw    fn_val          ; $1A - val
        defw    fn_len          ; $1B - len
        defw    fn_sin          ; $1C - sin
        defw    fn_cos          ; $1D - cos
        defw    fn_tan          ; $1E - tan
        defw    fn_asn          ; $1F - asn
        defw    fn_acs          ; $20 - acs
        defw    fn_atn          ; $21 - atn
        defw    fn_ln           ; $22 - ln
        defw    fn_exp          ; $23 - exp
        defw    fn_int          ; $24 - int
        defw    fn_sqr          ; $25 - sqr
        defw    fn_sgn          ; $26 - sgn
        defw    fn_abs          ; $27 - abs
        defw    fn_peek         ; $28 - peek
        defw    fn_usr          ; $29 - usr-no
        defw    fn_strS         ; $2A - str$
        defw    fn_chrS         ; $2B - chrs
        defw    fn_not          ; $2C - not
;
;   end of true unary
;
        defw    COPY_FP         ; $2D - duplicate
        defw    n_mod_m         ; $2E - n-mod-m

        defw    JUMP            ; $2F - jump
        defw    stk_data        ; $30 - stk-data

        defw    dec_jr_nz       ; $31 - dec-jr-nz
        defw    less_0          ; $32 - less-0
        defw    greater0        ; $33 - greater-0
        defw    end_calc        ; $34 - end-calc
        defw    get_argt        ; $35 - get-argt
        defw    truncate        ; $36 - truncate
        defw    fp_calc_2       ; $37 - fp-calc-2
        defw    e_to_fp         ; $38 - e-to-fp
;
;   new macros
;
        .dw sub_one             ; $39 macro sub-one (part of 'INT')
        .dw mul_by_2            ; $3A macro mul-by-2
        .dw mul_by10            ; $3B macro mul-by-10
        .dw stk_squa            ; $3C macro stk-square
;
tbl_offs .equ $-tbl_addrs
;
;   the following are just the next available slots for the 128 compound
;   literals which are in range $80 - $FF.
;
        defw    seriesg_x       ; series-xx    $80 - $9F.
        defw    stk_con_x       ; stk-const-xx $A0 - $BF.
        defw    sto_mem_x       ; st-mem-xx    $C0 - $DF.
        defw    get_mem_x       ; get-mem-xx   $E0 - $FF.
;
; Aside: 41 - 7F are therefore unused calculator literals.
;    3D - 7B would be available for expansion.
;
; ----------------------------------------
; THE improved 'FLOATING POINT CALCULATOR'
; ----------------------------------------
;
CALCULATE
        call    STK_PNTRS       ; routine STK-PNTRS is called to set up the
                                ; calculator stack pointers for a default
                                ; unary operation. HL = last value on stack.
                                ; DE = STKEND first location after stack.
;;- GEN_ENT1
        ld      a, b            ; fetch the Z80 B register to A
;
;   the calculate routine is called at this point by the series generator...
;
GEN_ENT1
        ld      ($401E), a      ; and store value in system variable BREG.
                                ; this will be the counter for dec-jr-nz
                                ; or if used from fp-calc2 the calculator
                                ; instruction.
;
;   ... and again later at this point
;
GEN_ENT2
        exx                     ; switch sets
        ex      (sp), hl        ; and store the address of next instruction,
                                ; the return address, in H'L'.
                                ; If this is a recursive call then the H'L'
                                ; of the previous invocation goes on stack.
                                ; c.f. end-calc.
        exx                     ; switch back to main set.
;
;   this is the re-entry looping point when handling a string of literals.
;
RE_ENTRY
        ld      ($401C), de     ; save end of stack in system variable STKEND
        exx                     ; switch to alt
        ld      a, (hl)         ; get next literal
        inc     hl              ; increase pointer'
;
;   single operation jumps back to here
;
SCAN_ENT
        push    hl              ; save pointer on stack   *
        and     a               ; now test the literal
        jp      p, FIRST_7F     ; forward to FIRST-7F if in range $00 - $7F
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
        ld      d, a            ; save literal in D
        and     $60             ; and with 01100000 to isolate subgroup
        rrca                    ; rotate bits
        rrca                    ; 4 places to right
        rrca                    ; not five as we need offset * 2
        rrca                    ; 00000xx0
        add     a, tbl_offs     ; correct offset.
        ld      l, a            ; store in L for later indexing.
        ld      a, d            ; bring back compound literal
        and     $1F             ; use mask to isolate parameter bits
        jr      ENT_TABLE       ; forward to ENT-TABLE
; ---
;
;   the branch was here with simple literals.
;
FIRST_7F
        cp      $18             ; compare with first unary operations.
        jr      nc, DOUBLE_A    ; to DOUBLE-A with unary operations
;
;   it is binary so adjust pointers.
;
        exx                     ;

        ex      de, hl          ; transfer HL, the last value, to DE.
        ld      hl, $FFFB       ; the value -5
        add     hl, de          ; subtract 5 making HL point to second
                                ; value.
        exx                     ;
DOUBLE_A
        rlca                    ; double the literal
        ld      l, a            ; and store in L for indexing
ENT_TABLE
        ld      de, tbl_addrs   ; Address: tbl-addrs
        ld      h, $00          ; prepare to index
        add     hl, de          ; add to get address of routine
        ld      e, (hl)         ; low byte to E
        inc     hl              ;
        ld      d, (hl)         ; high byte to D

        ld      hl, RE_ENTRY    ; Address: RE-ENTRY
        ex      (sp), hl        ; goes on machine stack
                                ; address of next literal goes to HL. *

        push    de              ; now the address of routine is stacked.
        exx                     ; back to main set
                                ; avoid using IY register.
        ld      bc, ($401D)     ; STKEND_hi
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
delete  ret                     ; return - indirect jump if from above.
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
        push    de              ; save
        push    hl              ; registers
        ld      bc, $0005       ; an overhead of five bytes
        call    TEST_ROOM       ; routine TEST-ROOM tests free RAM raising
                                ; an error if not.
        pop     hl              ; else restore
        pop     de              ; registers.
        ret                     ; return with BC set at 5.
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
        call    TEST_5_SP       ; routine TEST-5-SP test free memory
                                ; and sets BC to 5.
        ldir                    ; copy the five bytes.
        ret                     ; return with DE addressing new STKEND
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
        ld      h, d            ; transfer STKEND
        ld      l, e            ; to HL for result.
STK_CONST
        call    TEST_5_SP       ; routine TEST-5-SP tests that room exists
                                ; and sets BC to $05.
        exx                     ; switch to alternate set
        push    hl              ; save the pointer to next literal on stack
        exx                     ; switch back to main set

        ex      (sp), hl        ; pointer to HL, destination to stack.

        ld      a, (hl)         ; fetch the byte following 'stk-data'
        and     $C0             ; isolate bits 7 and 6
        rlca                    ; rotate
        rlca                    ; to bits 1 and 0  range $00 - $03.
        ld      c, a            ; transfer to C
        inc     c               ; and increment to give number of bytes
                                ; to read. $01 - $04
        ld      a, (hl)         ; reload the first byte
        and     $3F             ; mask off to give possible exponent.
        jr      nz, FORM_EXP    ; forward to FORM-EXP if it was possible to
                                ; include the exponent.
;
; else byte is just a byte count and exponent comes next.
;
        inc     hl              ; address next byte and
        ld      a, (hl)         ; pick up the exponent ( - $50).
FORM_EXP
        add     a, $50          ; now add $50 to form actual exponent
        ld      (de), a         ; and load into first destination byte.
        ld      a, $05          ; load accumulator with $05 and
        sub     c               ; subtract C to give count of trailing
                                ; zeros plus one.
        inc     hl              ; increment source
        inc     de              ; increment destination
        ldir                    ; copy C bytes

        ex      (sp), hl        ; put HL on stack as next literal pointer
                                ; and the stack value - result pointer -
                                ; to HL.
        exx                     ; switch to alternate set.
        pop     hl              ; restore next literal pointer from stack
                                ; to H'L'.
        exx                     ; switch back to main set.

        ld      b, a            ; zero count to B
        xor     a               ; clear accumulator
STK_ZEROS
        dec     b               ; decrement B counter
        ret     z               ; return if zero.       >>
                                ; DE points to new STKEND
                                ; HL to new number.

        ld      (de), a         ; else load zero to destination
        inc     de              ; increase destination
        jr      STK_ZEROS       ; loop back to STK-ZEROS until done.
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
        ld      hl, ($401F)     ; MEM is base address of the memory cells.
INDEX_5
        push    de              ; save STKEND

        call    LOC_MEM         ; routine LOC-MEM so that HL = first byte
        call    COPY_FP         ; routine COPY-FP moves 5 bytes with memory check.
                                ; DE now points to new STKEND.
;
;   -----------------------------------------------------------------------
;   also string comparisons join here to clear stack then return
cmp_nequ
        pop     hl              ; the original STKEND is now RESULT pointer.
        ret                     ; return.
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
        ld      hl, TAB_CNST    ; Address: Table of constants.
        jr      INDEX_5         ; and join subsroutine above.
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
        push    hl              ; save the result pointer.
        ex      de, hl          ; transfer to DE.
        ld      hl, ($401F)     ; fetch MEM the base of memory area.
        call    LOC_MEM         ; routine LOC-MEM sets HL to the destination.
        ex      de, hl          ; swap - HL is start, DE is destination.

        ld      c, $05          ;+ one extra byte but
        ldir                    ;+ faster and no memory check.

        ex      de, hl          ; DE = STKEND
        pop     hl              ; restore original result pointer
        ret                     ; return.
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
        call    GEN_ENT1        ; routine GEN-ENT-1 is called.
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
        .db $3A                 ;;mul-by-2      2*x

        defb    $C0             ;;st-mem-0      2*x
        defb    $02             ;;delete        .
        defb    $A0             ;;stk-zero      0

        .db $C1                 ;;st-mem-1      0
        .db $2D                 ;;duplicate     0,0.

        .db $2F                 ;;jump
        .db G_LOOP1-$           ;;to G-LOOP1    - skip the 1st round
;
; a loop is now entered to perform the algebraic calculation for each of
; the numbers in the series
;
G_LOOP
        defb    $2D             ;;duplicate     v,v.
        defb    $E0             ;;get-mem-0     v,v,2*x
        defb    $04             ;;multiply      v,v*2*x
        defb    $E2             ;;get-mem-2     v,v*2*x,v
        defb    $C1             ;;st-mem-1      v,v*2*x,v
        defb    $03             ;;subtract      v,v*2*x-v
G_LOOP1
        defb    $34             ;;end-calc
;
; the previous pointer is fetched from the machine stack to H'L' where it
; addresses one of the numbers of the series following the series literal.
;
        call    stk_data        ; routine STK-DATA is called directly to
                                ; push a value and advance H'L'.
        call    GEN_ENT2        ; routine GEN-ENT-2 recursively re-enters
                                ; the calculator without disturbing
                                ; system variable BREG
                                ; H'L' value goes on the machine stack and is
                                ; then loaded as usual with the next address.

        defb    $0F             ;;addition
        defb    $01             ;;exchange
        defb    $C2             ;;st-mem-2
        defb    $02             ;;delete

        defb    $31             ;;dec-jr-nz
        defb    G_LOOP-$        ;;back to G-LOOP

; when the counted loop is complete the final subtraction yields the result
; for example SIN X.

        defb    $E1             ;;get-mem-1
        defb    $03             ;;subtract
        defb    $34             ;;end-calc

        ret                     ; return with H'L' pointing to location
                                ; after last number in series.
;
; -----------------------
; Handle unary minus (18)
; -----------------------
; Unary so on entry HL points to last value, DE to STKEND.
;
negate
        ld      a, (hl)         ; fetch exponent of last value on the
                                ; calculator stack.
        and     a               ; test it.
        ret     z               ; return if zero.
negate_1
        inc     hl              ; address the byte with the sign bit.
        ld      a, (hl)         ; fetch to accumulator.
        xor     $80             ; toggle the sign bit.
        ld      (hl), a         ; put it back.
        dec     hl              ; point to last value again.
        ret                     ; return.
;
; ---------------
; new Signum (26)
; ---------------
; This routine replaces the last value on the calculator stack,
; (which is in floating point form), with one if positive and with minus one
; if it is negative. If it is zero then it is left unchanged.
;
fn_sgn
        ld      a, (hl)         ; fetch exponent of last value on the stack
        and     a               ; test it.
        ret     z               ; return if zero.

        call    greater1        ; if >0 then CY=1
        ret     c               ; and return value=1

        ld      (hl), $81       ; else make value 1
        jr      negate_1        ; and return via 'unary minus'
;
; -----------------------
; Greater than zero ($33)
; -----------------------
; Test if the last value on the calculator stack is greater than zero.
; This routine is also called directly from the end-tests of the comparison
; routine.
;
greater0
        ld      a, (hl)         ; fetch exponent.
        and     a               ; test it for zero.
        ret     z               ; return if so.
greater1
        ld      a, $FF          ; prepare XOR mask for sign bit
        jr      SGN_TO_C        ; forward to SIGN-TO-C
                                ; to put sign in carry
                                ; (carry will become set if sign is positive)
                                ; and then overwrite location with 1 or 0
                                ; as appropriate.
;
;   =======================================================================
;   the new entry point to perform '<=', '>=', '<>' operations, which end
;   with a 'NOT' operation
comp_not
        dec     b               ; correct the calculator literal in B
        call    comp_tru        ; then perform the comparison ...
;
;   =======================================================================
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
        ld      a, (hl)         ; get exponent byte.
fn_not1
        neg                     ; negate - sets carry if non-zero.
fn_not2
        ccf                     ; complement so carry set if zero, else reset.
        jr      FP_0_1          ; forward to FP-0/1.
;
; -------------------
; Less than zero (32)
; -------------------
; Destructively test if last value on calculator stack is less than zero.
; Bit 7 of second byte will be set if so.
;
less_0
        xor     a               ; set xor mask to zero
                                ; (carry will become set if sign is negative).
;
; transfer sign of mantissa to Carry Flag.
;
SGN_TO_C
        inc     hl              ; address 2nd byte.
        xor     (hl)            ; bit 7 of HL will be set if number is negative.
        dec     hl              ; address 1st byte again.
        rlca                    ; rotate bit 7 of A to carry.
;
; -----------
; Zero or one
; -----------
; This routine places an integer value zero or one at the addressed location
; of calculator stack or MEM area. The value one is written if carry is set on
; entry else zero.
;
FP_0_1
        push    hl              ; save pointer to the first byte
        ld      b, $05          ; five bytes to do.
FP_loop
        ld      (hl), $00       ; insert a zero.
        inc     hl              ;
        djnz    FP_loop         ; repeat.

        pop     hl              ;
        ret     nc              ;

        ld      (hl), $81       ; make value 1
        ret                     ; return.
;
; -----------------------
; Handle OR operator (07)
; -----------------------
; The Boolean OR operator. eg. X OR Y
; The result is zero if both values are zero else a non-zero value.
;
; e.g.   0 OR  0    returns  0.
;   -3 OR  0    returns -3.
;    0 OR -3    returns  1.
;   -3 OR  2    returns  1.
;
; A binary operation.
; On entry HL points to first operand (X) and DE to second operand (Y).
;
op_or   ld a, (de)              ; fetch exponent of second number
        and     a               ; test it.
        ret     z               ; return if zero.
op_or_1
        scf                     ; set carry flag
        jr      FP_0_1          ; back to FP-0/1 to overwrite the first operand
                                ; with the value 1.
;
;   =======================================================================
;   Handle AND
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
; e.g.  -3 AND  2   returns -3.
;   -3 AND  0   returns  0.
;    0 and -2   returns  0.
;    0 and  0   returns  0.
;
; Compare with OR routine above.
;
hnd_AND
        ld      a, (de)         ; fetch exponent of second number.
        and     a               ; test it.
        ret     nz              ; return if not zero.

        jr      FP_0_1          ; back to FP-0/1 to overwrite the first operand
                                ; with zero for return value.
;
;   =======================================================================
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
        push    bc              ; save calculator literal
        push    de              ; save pointer to operand2
        push    hl              ; save pointer to operand1

                                ; if operand1 < operand2 then Z=0, CY=0
        call    compare         ; if operand1 = operand2 then Z=1, CY=0
                                ; if operand1 > operand2 then Z=0, CY=1

        pop     hl              ; restore pointer to operand2
        pop     de              ; restore pointer to operand1
        pop     bc              ; restore calculator literal

        jr      z, comp_equ     ; jump if operands are equal

        jr      c, comp_op1     ; jump if operand1 > operand2

        bit     0, b            ;
                                ; condition
        jr      z, FP_0_1       ; op1>op2 or op1=op2    (CY=0 -> place '0')
        jr      fn_not2         ; op1<op2       (CY=1 -> place '1')
;
;   -----------------------------------------------------------------------
comp_op1
        ld      a, $03          ; set mask '000000xx'
        and     b               ; (clears CY!)
                                ; condition
        jr      nz, FP_0_1      ; op1<op2 or op1=op2    (CY=0 -> place '0')
        jr      fn_not2         ; op1>op2       (CY=1 -> place '1')
;
;   -----------------------------------------------------------------------
comp_equ
        bit     1, b            ;
                                ; condition
        jr      nz, op_or_1     ; op1=op2       (CY=1 -> place '1')
        jr      FP_0_1          ; op1<>op2      (CY=0 -> place '0')
;
;   =======================================================================
compare
        bit     4, b            ; bit 4 selects strings as operands
        jr      z, comp_num     ; else compare numbers
;
;   -----------------------------------------------------------------------
;   String comparisons:
;   --------------------
;
        call    STK_FETCH       ; routine STK-FETCH gets 2nd string's params
        push    de              ; save start2 *.
        push    bc              ; and the length2.

        call    STK_FETCH       ; routine STK-FETCH gets 1st string's
                                ; parameters - start in DE, length in BC.
        pop     hl              ; restore length of second to HL.
        and     a               ; clear CY
        sbc     hl, bc          ; compare

        jr      nc, cplen_eq    ; jump, if len1<=len2

        add     hl, bc          ; restore length2
        ld      b, h            ; and set counter
        ld      c, l            ; of comparision
cplen_eq
        pop     hl              ; restore start2 to HL.
        jr      z, comp_neg     ; if the lengths are equal compare byte by byte

        push    af              ; save flags (Z=0 and CY=1, if len1>len2)
        call    comp_neg        ; compare byte by byte
        jp      nz, cmp_nequ    ; jump if parts are different

        pop     af              ; else restore flags
        ret                     ; CY=1 if 1st string is longer
;
;   -----------------------------------------------------------------------
;   Numeric Comparisons:
;   --------------------
comp_num
        ld      bc, 5           ; the size of a floating point number (5 bytes)
        inc     hl              ; points the MSB of the 1st mantissa
        inc     de              ; points the MSB of the 2nd mantissa
        ld      a, (de)         ; compare the
        xor     (hl)            ; sign bits
        rla                     ; CY=1 if they are different
        ld      a, (de)         ; MSB of the 2nd mantissa (A7=sign bit)
        dec     de              ; restore the
        dec     hl              ; pointers

        jr      nc, comp_pos    ; if signs are equals then compare byte by byte

        rla                     ; else set CY if the 2nd number is negative
        ret                     ; and return
comp_pos
        rla                     ; if signs are positive
        jr      nc, comp_nxt    ; then continue with byte by byte comparision
comp_neg
        ex      de, hl          ; else swap pointers
comp_tst
        ld      a, b            ; test byte counter
        or      c               ; if it is zero (CY=0 and Z=1)
        ret     z               ; then end of comparision
comp_nxt
        ld      a, (de)         ; compare byte
        cp      (hl)            ; by byte
        ret     nz              ; return if they are different

        inc     hl              ; set pointers
        inc     de              ;
        dec     bc              ; and the byte counter
        jr      comp_tst        ;

;
;   =======================================================================
;
; -----------------------------------
; THE 'STRING CONCATENATION' OPERATOR
; -----------------------------------
; (offset $17: 'strs_add')
; This literal combines two strings into one e.g. LET A$ = B$ + C$
; The two parameters of the two strings to be combined are on the stack.
;
strs_add
        call    STK_FETCH       ; routine STK-FETCH fetches string parameters
                                ; and deletes calculator stack entry.
        push    de              ; save start address.
        push    bc              ; and length.

        call    STK_FETCH       ; routine STK-FETCH for first string
        pop     hl              ; re-fetch first length
        push    hl              ; and save again
        push    de              ; save start of second string
        push    bc              ; and its length.

        add     hl, bc          ; add the two lengths.
        ld      b, h            ; transfer to BC
        ld      c, l            ; and create
        rst     30H             ; BC-SPACES in workspace.
                                ; DE points to start of space.

        call    STK_ST_s        ; routine STK-STO-$ stores parameters
                                ; of new string updating STKEND.

        pop     bc              ; length of first
        pop     hl              ; address of start

        call    COND_MV         ;+ a conditional (NZ) ldir routine.

OTHER_STR
        pop     bc              ; now second length
        pop     hl              ; and start of string

        call    COND_MV         ;+ a conditional (NZ) ldir routine.
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
        ld      hl, ($401C)     ; fetch STKEND value from system variable.

        ex      de, hl          ; switch pointers
        ld      hl, $FFFB       ; the value -5

        add     hl, de          ; HL = STKEND - 5
        ret                     ; return.
;
; ------------------
; THE 'VAL' FUNCTION
; ------------------
; (offset $1A: 'val')
;   VAL treats the characters in a string as a numeric expression.
;   e.g. VAL "2.3" = 2.3, VAL "2+4" = 6, VAL ("2" + "4") = 24.
;
fn_val
        rst     18H             ;+ shorter way to fetch CH_ADD.
        push    hl              ; and save on the machine stack.

        call    STK_FETCH       ; routine STK-FETCH fetches the string operand
                                ; from calculator stack.

        push    de              ; save the address of the start of the string.
        inc     bc              ; increment the length for a carriage return.

        rst     30H             ; BC-SPACES creates the space in workspace.
        pop     hl              ; restore start of string to HL.
        ld      ($4016), de     ; load CH_ADD with start DE in workspace.

        push    de              ; save the start in workspace
        ldir                    ; copy string from program or variables or
                                ; workspace to the workspace area.
        ex      de, hl          ; end of string + 1 to HL
        dec     hl              ; decrement HL to point to end of new area.
        ld      (hl), $76       ; insert a carriage return at end.
                                ; ZX81 has a non-ASCII character set
        res     7, (iy+$01)     ; update FLAGS  - signal checking syntax.
        call    CLASS_06        ; routine CLASS-06 - SCANNING evaluates string
                                ; expression and checks for integer result.

        call    CHECK_2         ; routine CHECK-2 checks for carriage return.

        pop     hl              ; restore start of string in workspace.

        ld      ($4016), hl     ; set CH_ADD to the start of the string again.
        set     7, (iy+$01)     ; update FLAGS  - signal running program.
        call    SCANNING        ; routine SCANNING evaluates the string
                                ; in full leaving result on calculator stack.

        pop     hl              ; restore saved character address in program.
        ld      ($4016), hl     ; and reset the system variable CH_ADD.

        jr      STK_PNTRS       ; back to exit via STK-PNTRS.
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
        call    STK_FETCH       ; routine STK-FETCH to fetch and delete the
                                ; string parameters from the calculator stack.
                                ; register BC now holds the length of string.

        jp      STACK_BC        ; jump back to STACK-BC to save result on the
                                ; calculator stack (with memory check).
;
; -----------------------------------------
; THE improved 'TO POWER' OPERATION (cont.)
; -----------------------------------------
; X_IS_0
to_pwr_0
        ex      de, hl          ; else switch pointers
        inc     hl              ;
        bit     7, (hl)         ; test if Y is negative
        dec     hl              ;
        ld      a, (hl)         ; fetch Y.exp
        ex      de, hl          ; switch back pointers
        jp      z, fn_not1      ; jump if it is positive or zero to
                                ; replace X with 1 (Y=0) or 0 (Y>0)
; ---
        rst     08h             ; else Error Report:
        .db $05                 ; arithmetic overflow
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

to_power                        ; HL points X, DE points Y.
        ld      a, (hl)         ; fetch X.exp
        and     a               ; test zero
        jr      z, to_pwr_0     ; continue if X<>0
;
;   X is non-zero. function 'ln' will catch a negative value of X.
;
        rst     28h             ;; FP-CALC      X,Y.
        .db $01                 ;;exchange      Y, X.
        .db $22                 ;;ln            Y, LN X.
;
;   Multiply the power by the logarithm of the argument.
;
        .db $04                 ;;multiply      Y * LN X
        .db $34                 ;;end-calc
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
        rst     28H             ;; FP-CALC
        defb    $30             ;;stk-data          1/LN 2
        defb    $F1             ;;Exponent: $81, Bytes: 4
        defb    $38, $AA, $3B, $29
                                ;;
        defb    $04             ;;multiply
        defb    $2D             ;;duplicate
        defb    $24             ;;int
        defb    $C3             ;;st-mem-3
        defb    $03             ;;subtract

        .db $3A                 ;;mul-by-2          *2
        .db $39                 ;;sub-one macro         -1

        defb    $88             ;;series-08
        defb    $13             ;;Exponent: $63, Bytes: 1
        defb    $36             ;;(+00,+00,+00)
        defb    $58             ;;Exponent: $68, Bytes: 2
        defb    $65, $66        ;;(+00,+00)
        defb    $9D             ;;Exponent: $6D, Bytes: 3
        defb    $78, $65, $40   ;;(+00)
        defb    $A2             ;;Exponent: $72, Bytes: 3
        defb    $60, $32, $C9   ;;(+00)
        defb    $E7             ;;Exponent: $77, Bytes: 4
        defb    $21, $F7, $af, $24
                                ;;
        defb    $EB             ;;Exponent: $7B, Bytes: 4
        defb    $2F, $B0, $B0, $14
                                ;;
        defb    $EE             ;;Exponent: $7E, Bytes: 4
        defb    $7E, $BB, $94, $58
                                ;;
        defb    $F1             ;;Exponent: $81, Bytes: 4
        defb    $3A, $7E, $F8, $CF
                                ;;

        defb    $E3             ;;get-mem-3
        defb    $34             ;;end-calc

        call    FP_TO_A         ; routine FP-TO-A
        jr      nz, N_NEGTV     ; to N-NEGTV

        jr      c, REPORT_6b    ; to REPORT-6b

        add     a, (hl)         ;
        jr      nc, RESULT_OK   ; to RESULT-OK
;
REPORT_6b
        rst     08H             ; ERROR-1
        defb    $05             ; Error Report: Number too big
;
N_NEGTV
        jp      c, fn_not2      ; return via FP-0/1 to replace last value with zero

        sub     (hl)            ;
        jp      nc, FP_0_1      ; return via FP-0/1 to replace last value with zero

        neg                     ; Negate
;
RESULT_OK
        ld      (hl), a         ;
        ret                     ; return.
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
        call    FP_TO_A         ; routine FP-TO-A puts the number in A.
        jr      c, REPORT_Bd    ; forward to REPORT-Bd if overflow

        jr      nz, REPORT_Bd   ; forward to REPORT-Bd if negative

        ld      bc, $0001       ; one space required.
        rst     30H             ; BC-SPACES makes DE point to start

        ld      (de), a         ; and store in workspace

        jr      str_STK         ;+ relative jump to similar sequence in str$.
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
        ld      bc, $0001       ; create an initial byte in workspace
        rst     30H             ; using BC-SPACES restart.

        ld      (hl), $76       ; place a carriage return there.

        ld      hl, ($4039)     ; fetch value of S_POSN column/line
        push    hl              ; and preserve on stack.

        ld      l, $FF          ; make column value high to create a
                                ; contrived buffer of length 254.
        ld      ($4039), hl     ; and store in system variable S_POSN.

        ld      hl, ($400E)     ; fetch value of DF_CC
        push    hl              ; and preserve on stack also.

        ld      ($400E), de     ; now set DF_CC which normally addresses
                                ; somewhere in the display file to the start
                                ; of workspace.
        push    de              ; save the start of new string.

        call    PRINT_FP        ; routine PRINT-FP.

        pop     de              ; retrieve start of string.

        ld      hl, ($400E)     ; fetch end of string from DF_CC.
        and     a               ; prepare for true subtraction.
        sbc     hl, de          ; subtract to give length.

        ld      b, h            ; and transfer to the BC
        ld      c, l            ; register.

        pop     hl              ; restore original
        ld      ($400E), hl     ; DF_CC value

        pop     hl              ; restore original
        ld      ($4039), hl     ; S_POSN values.
;
;   New entry-point to exploit similarities and save 3 bytes of code.
;
str_STK
        call    STK_ST_s        ; routine STK-STO-$ stores the string
                                ; descriptor on the calculator stack.

        ex      de, hl          ; HL = last value, DE = STKEND.
        ret                     ; return.
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
        call    STK_FETCH       ; routine STK-FETCH to fetch and delete the
                                ; string parameters.
                                ; DE points to the start, BC holds the length.
        ld      a, b            ; test length
        or      c               ; of the string.
        jr      z, STK_CODE     ; skip to STK-CODE with zero if the null string.

        ld      a, (de)         ; else fetch the first character.
STK_CODE
        jp      STACK_A         ; jump back to STACK-A (with memory check)
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
        ld      b, $05          ; there are five bytes to be swapped
;
; start of loop.
;
SWAP_BYTE
        ld      a, (de)         ; each byte of second
        ld      c, a            ;+
        ld      a, (hl)         ;+ each byte of first
        ld      (de), a         ; store each byte of first
        ld      (hl), c         ; store each byte of second
        inc     hl              ; advance both
        inc     de              ; pointers.
        djnz    SWAP_BYTE       ; loop back to SWAP-BYTE until all 5 done.

        ret                     ; return.
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
        exx                     ; switch in set that addresses code

        push    hl              ; save pointer to offset byte
        ld      hl, $401E       ; address BREG in system variables
        dec     (hl)            ; decrement it
        pop     hl              ; restore pointer
jmp_tru1
        jr      nz, JUMP_2      ; to JUMP-2 if not zero

        inc     hl              ; step past the jump length.
        exx                     ; switch in the main set.
        ret                     ; return.
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
        exx                     ; switch in pointer set
JUMP_2
        ld      e, (hl)         ; the jump byte 0-127 forward, 128-255 back.

        ld      a, e            ;+
        rla                     ;+
        sbc     a, a            ;+
JUMP_3
        ld      d, a            ; transfer to high byte.
        add     hl, de          ; advance calculator pointer forward or back.

        exx                     ; switch out pointer set.
        ret                     ; return.
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
        ld      a, (de)         ; collect exponent byte
        and     a               ; is result 0 or 1 ?
        exx                     ; switch in the pointer set.

        jr      jmp_tru1        ; back to JUMP if true (1).
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
        rst     28H             ;; FP-CALC      17, 3.
        defb    $C0             ;;st-mem-0      17, 3.
        defb    $02             ;;delete        17.
        defb    $2D             ;;duplicate     17, 17.
        defb    $E0             ;;get-mem-0     17, 17, 3.
        defb    $05             ;;division      17, 17/3.
        defb    $24             ;;int           17, 5.
        defb    $E0             ;;get-mem-0     17, 5, 3.
        defb    $01             ;;exchange      17, 3, 5.
        defb    $C0             ;;st-mem-0      17, 3, 5.
        defb    $04             ;;multiply      17, 15.
        defb    $03             ;;subtract      2.
        defb    $E0             ;;get-mem-0     2, 5.
        defb    $34             ;;end-calc      2, 5.

        ret                     ; return.
;
; --------------------------
;
REPORT_Bd
        rst     08H             ; ERROR-1
        defb    $0A             ; Error Report: Integer out of range
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
        push    hl              ; save pointer to 'X'
        call    COPY_FP         ; duplicate

        ex      de, hl          ; DE now points the duplication
        pop     hl              ; HL now points 'X' again

        call    truncate        ; truncation towards zero

        push    hl              ; save pointer to the truncated 'X'
        push    de              ; save pointer to the duplication

        call    comp_num        ; copmpare truncated 'X' to the duplication

        pop     de              ; DE now points end of the duplication
        pop     hl              ; HL now points 'X' again

        ret     z               ; return if 'X' was an integer or

        ret     nc              ; return if 'X' was positive or zero
;                 else...
; ---------------------------
; THE 'SUBTRACT ONE' FUNCTION
; ---------------------------
; (Offset $39: 'sub-one')
; this part is a new 'macro', which replaces the next 2 calc. literals
;
;   $A1  :  stk-one
;   $03  :  subtract
;
sub_one
        push    hl              ; save pointer to 'X'

        ld      a, $01          ; stack 'ONE'
        call    stk_con_x       ;

        ex      de, hl          ; DE now points 'ONE'
        pop     hl              ; HL now points 'X' again

        jp      subtract        ; return w. X=X-1
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
;   10 PRINT EXP ( LN 1.72 + LN 6.89 )
;   will give just the same result as
;   20 PRINT 1.72 * 6.89.
;   Division is accomplished by subtracting the two logs.
;
;   Napier also mentioned "square and cubicle extractions".
;   To raise a number to the power 3, find its 'ln', multiply by 3 and find the
;   'antiln'.  e.g. PRINT EXP( LN 4 * 3 )  gives 64.
;   Similarly to find the n'th root divide the logarithm by 'n'.
;
;   First test that the argument to LN is a positive, non-zero number.
fn_ln
        ld      a, (hl)         ; Fetch exponent to A.
        and     a               ; Test for zero argument
        jr      z, REPORT_A     ; if =0 then REPORT_A: 'Invalid argument'
;
        ld      (hl), $80       ; Insert 'plus zero' as exponent.
;
        inc     hl              ; Address byte with sign bit.
        bit     7, (hl)         ; Test the bit.
        jr      nz, REPORT_A    ; if <0 then REPORT_A: 'Invalid argument'

;;- dec hl          ; HL now points to exponent
        call    STACK_A         ; routine STACK-A stacks true binary exponent.

        rst     28H             ;; FP-CALC
        defb    $30             ;;stk-data
        defb    $38             ;;Exponent: $88, Bytes: 1
        defb    $00             ;;(+00,+00,+00)
        defb    $03             ;;subtract
        defb    $01             ;;exchange
        defb    $2D             ;;duplicate
        defb    $30             ;;stk-data
        defb    $F0             ;;Exponent: $80, Bytes: 4
        defb    $4C, $CC, $CC, $CD
                                ;;
        defb    $03             ;;subtract

        defb    $33             ;;greater-0
        defb    $00             ;;jump-true
        defb    GRE_8-$         ;;to GRE_8

        defb    $01             ;;exchange

        .db $39                 ;;sub-one macro

        defb    $01             ;;exchange

        .db $3A                 ;;mul-by-2          *2
GRE_8
        defb    $01             ;;exchange
        defb    $30             ;;stk-data          LN 2
        defb    $F0             ;;Exponent: $80, Bytes: 4
        defb    $31, $72, $17, $F8
                                ;;
        defb    $04             ;;multiply
        defb    $01             ;;exchange

        .db $39                 ;;sub-one macro

        defb    $2D             ;;duplicate
        defb    $30             ;;stk-data
        defb    $32             ;;Exponent: $82, Bytes: 1
        defb    $20             ;;(+00,+00,+00)
        defb    $04             ;;multiply
        defb    $A2             ;;stk-half
        defb    $03             ;;subtract
        defb    $8C             ;;series-0C
        defb    $11             ;;Exponent: $61, Bytes: 1
        defb    $AC             ;;(+00,+00,+00)
        defb    $14             ;;Exponent: $64, Bytes: 1
        defb    $09             ;;(+00,+00,+00)
        defb    $56             ;;Exponent: $66, Bytes: 2
        defb    $DA, $A5        ;;(+00,+00)
        defb    $59             ;;Exponent: $69, Bytes: 2
        defb    $30, $C5        ;;(+00,+00)
        defb    $5C             ;;Exponent: $6C, Bytes: 2
        defb    $90, $AA        ;;(+00,+00)
        defb    $9E             ;;Exponent: $6E, Bytes: 3
        defb    $70, $6F, $61   ;;(+00)
        defb    $A1             ;;Exponent: $71, Bytes: 3
        defb    $CB, $DA, $96   ;;(+00)
        defb    $A4             ;;Exponent: $74, Bytes: 3
        defb    $31, $9F, $B4   ;;(+00)
        defb    $E7             ;;Exponent: $77, Bytes: 4
        defb    $A0, $FE, $5C, $FC
                                ;;
        defb    $EA             ;;Exponent: $7A, Bytes: 4
        defb    $1B, $43, $CA, $36
                                ;;
        defb    $ED             ;;Exponent: $7D, Bytes: 4
        defb    $A7, $9C, $7E, $5E
                                ;;
        defb    $F0             ;;Exponent: $80, Bytes: 4
        defb    $6E, $23, $80, $93
                                ;;

        defb    $04             ;;multiply
        defb    $0F             ;;addition
        defb    $34             ;;end-calc

        ret                     ; return.
;
; ------------
; THE REPORT_A
; ------------
;
REPORT_A

        rst     08H             ; ERROR-1
        defb    $09             ; Error Report: Invalid argument
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
        rst     28H             ;; FP-CALC          n
        .db $C3                 ;; st-mem-3 (store in mem-3)    n
        .db $34                 ;; end_calc (exit calculator)   n

        ld      a, (hl)         ;  exponent to A
        and     a               ;  test against zero
        ret     z               ;  return if so

        add     a, $80          ;  set carry if greater or equal to 128
        rra                     ;  divide by two
        ld      (hl), a         ;  replace value

        inc     hl              ;  next location
        ld      a, (hl)         ;  get sign bit
        rla                     ;  rotate left
        jr      c, REPORT_A     ;  error with negative number

        ld      (hl), 127       ;  mantissa starts at about one
        ld      b, 5            ;  set counter
fn_sqr1
        rst     28H             ;; FP-CALC          x
        .db $2D                 ;; duplicate            x, x
        .db $E3                 ;; get_mem_3            x, x, n
        .db $01                 ;; exchange         x, n, x
        .db $05                 ;; division         x, n / x
        .db $0F                 ;; addition         x + n / x
        .db $34                 ;; end_calc (exit calculator)

        dec     (hl)            ;  halve value
        djnz    fn_sqr1         ;  loop until found

        ret                     ;  return with square root on stack
;
;   ========================================================
;   the new 'PAUSE' joins here
ffp_hook
        ld      hl, jp_DISP2    ; hook to DISPLAY-2
        inc     bc              ; set counter
        ld      ($4034), bc     ; set FRAMES
        ret     nz              ; flicker free PAUSE (in SLOW mode)

        jp      L0229           ; DISPLAY-1 (in FAST mode)
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
        rst     28H             ;; FP-CALC      angle in radians
        .db $A2                 ;;stk-half          X, 0.5 (offset: halfPI / PI)

        .db $2F                 ;;jump
        .db cos_entr-$          ;;to cos_entr       continue as SINE function
;
; ----------------------------
; THE improved 'SINE' FUNCTION
; ----------------------------
; (offset $1C: 'sin')
;   This is a fundamental transcendental function from which others such as cos
;   and tan are directly, or indirectly, derived.
;   It uses the series generator to produce Chebyshev polynomials.
;
;       /|
;    1 / |
;     /  |x
;    /a  |
;   /----|
;     y
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
        rst     28H             ;; FP-CALC      angle in radians
        .db $A0                 ;;stk-zero          X, 0.    (offset)
cos_entr
        .db $01                 ;;exchange      ofs, X.

        defb    $30             ;;stk-data
        defb    $EE             ;;Exponent: $7E, Bytes: 4
        defb    $22, $F9, $83, $6E
                                ;;         ofs, X, 1/(2*PI)
        defb    $04             ;;multiply      ofs, X/(2*PI) = fraction

        defb    $2D             ;;duplicate         ofs, fraction, fraction
        defb    $A2             ;;stk-half          ofs, fraction, fraction, 0.5
        defb    $0F             ;;addition          ofs, fraction, fraction + 0.5
        defb    $24             ;;int           ofs, fraction, int(fraction+0.5)

        defb    $03             ;;subtract      ofs, now range -.5 to .5

        .db $3A                 ;;mul-by-2      ofs, now range -1 to 1.
        .db $0F                 ;;addition      ofs + range (-1 to 1).

        .db $2D                 ;;duplicate     ofs_rng, ofs_rng
        .db $39                 ;;sub-one macro     ofs_rng, ofs_rng-1.

        .db $2D                 ;;duplicate     ofs_rng, ofs_rng-1, ofs_rng-1.
        .db $32                 ;;less-0        ofs_rng, ofs_rng-1, 0/1.
        .db $00                 ;;jump-true
        .db no_qchg-$           ;;to no_qchg

        .db $39                 ;;sub-one macro     ofs_rng, ofs_rng-2.
        .db $01                 ;;exchange      ofs_rng-2, ofs_rng.
no_qchg
        .db $02                 ;;delete        delete test value.
        .db $3A                 ;;mul-by-2      now range -2 to 2.
;
;   quadrant I (0 to +1) and quadrant IV (-1 to 0) are now correct.
;   quadrant II ranges +1 to +2.
;   quadrant III ranges -2 to -1.
;
        defb    $2D             ;;duplicate     Y, Y.
        defb    $27             ;;abs           Y, abs(Y).    range 1 to 2

        .db $39                 ;;sub-one macro     Y, abs(Y)-1.  range 0 to 1

        defb    $2D             ;;duplicate     Y, Z, Z.

        defb    $33             ;;greater-0     Y, Z, (1/0).
        defb    $00             ;;jump-true
        defb    ZPLUS-$         ;;to ZPLUS with quadrants II and III
;
;   else the angle lies in quadrant I or IV and value Y is already correct.
;
        defb    $02             ;;delete        Y   delete test value.

        .db $2F                 ;;jump
        .db YNEG-$              ;;to YNEG       Y.  with Q1 and Q4 >>>
;
;   The branch was here with quadrants II (0 to 1) and III (1 to 0).
;   Y will hold -2 to -1 if this is quadrant III.
;
ZPLUS
        .db $39                 ;;sub-one macro     Y, Z-1.  Q3 = 0 to -1

        defb    $01             ;;exchange      Z-1, Y.

        defb    $32             ;;less-0        Z-1, (1/0).
        defb    $00             ;;jump-true     Z-1.
        defb    YNEG-$          ;;to YNEG       if angle in quadrant III
;
;   else angle is within quadrant II (-1 to 0)
;
        defb    $18             ;;negate        range +1 to 0
;
;   -------------------------------------------
YNEG
        .db $3C                 ;;stk-square        x, x*x.
        .db $3A                 ;;mul-by-2      x, 2*x*x.
        .db $39                 ;;sub-one macro     x, 2*x*x-1

        defb    $86             ;;series-06
        defb    $14             ;;Exponent: $64, Bytes: 1
        defb    $E6             ;;(+00,+00,+00)
        defb    $5C             ;;Exponent: $6C, Bytes: 2
        defb    $1F, $0B        ;;(+00,+00)
        defb    $A3             ;;Exponent: $73, Bytes: 3
        defb    $8F, $38, $EE   ;;(+00)
        defb    $E9             ;;Exponent: $79, Bytes: 4
        defb    $15, $63, $BB, $23
                                ;;
        defb    $EE             ;;Exponent: $7E, Bytes: 4
        defb    $92, $0D, $CD, $ED
                                ;;
        defb    $F1             ;;Exponent: $81, Bytes: 4
        defb    $23, $5D, $1B, $EA
                                ;;

        defb    $04             ;;multiply      x*series_06
        defb    $34             ;;end-calc
;
; -------------------------------------------
; THE eliminated 'REDUCE ARGUMENT' SUBROUTINE
; -------------------------------------------
; (offset $35: 'get-argt')
;
; now it is part of the sine function - see above
;
get_argt
        ret                     ; return.
;
; ----------------------
; THE 'TANGENT' FUNCTION
; ----------------------
; (offset $1E: 'tan')
;
; Evaluates tangent x as    sin(x) / cos(x).
;
;       /|
;    h / |
;     /  |o
;    /x  |
;   /----|
;     a
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
        rst     28H             ;; FP-CALC      x.
        defb    $2D             ;;duplicate     x, x.
        defb    $1C             ;;sin           x, sin x.
        defb    $01             ;;exchange      sin x, x.
        defb    $1D             ;;cos           sin x, cos x.
        defb    $05             ;;division      sin x/cos x (= tan x).
        defb    $34             ;;end-calc      tan x.

        ret                     ; return.
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
        ld      a, (hl)         ; fetch exponent
        cp      $81             ; compare to that for 'one'
        jr      c, SMALL        ; forward, if less, to SMALL

        rst     28H             ;; FP-CALC      X.
        defb    $A1             ;;stk-one       X, 1.
        defb    $18             ;;negate        X, -1.
        defb    $01             ;;exchange      -1, X.
        defb    $05             ;;division      -1/X.
        defb    $2D             ;;duplicate     -1/X, -1/X.

        .db $A3                 ;;stk-pi/2      -1/X, -1/X, PI/2.
        .db $01                 ;;exchange      -1/X, PI/2, -1/X.

        .db $32                 ;;less-0        -1/X, PI/2, (1/0).
        defb    $00             ;;jump-true
        defb    CASES-$         ;;to CASES      -1/X, PI/2.

        defb    $18             ;;negate        -1/X, -PI/2.
        defb    $2F             ;;jump
        defb    CASES-$         ;;to CASES
; ---
;
SMALL
        rst     28H             ;; FP-CALC
        defb    $A0             ;;stk-zero
CASES
        defb    $01             ;;exchange

        .db $3C                 ;;stk-square        x, x*x.
        .db $3A                 ;;mul-by-2      x, 2*x*x.
        .db $39                 ;;sub-one macro     x, 2*x*x-1.

        defb    $8C             ;;series-0C
        defb    $10             ;;Exponent: $60, Bytes: 1
        defb    $B2             ;;(+00,+00,+00)
        defb    $13             ;;Exponent: $63, Bytes: 1
        defb    $0E             ;;(+00,+00,+00)
        defb    $55             ;;Exponent: $65, Bytes: 2
        defb    $E4, $8D        ;;(+00,+00)
        defb    $58             ;;Exponent: $68, Bytes: 2
        defb    $39, $bc        ;;(+00,+00)
        defb    $5B             ;;Exponent: $6B, Bytes: 2
        defb    $98, $FD        ;;(+00,+00)
        defb    $9E             ;;Exponent: $6E, Bytes: 3
        defb    $00, $36, $75   ;;(+00)
        defb    $A0             ;;Exponent: $70, Bytes: 3
        defb    $DB, $E8, $B4   ;;(+00)
        defb    $63             ;;Exponent: $73, Bytes: 2
        defb    $42, $C4        ;;(+00,+00)
        defb    $E6             ;;Exponent: $76, Bytes: 4
        defb    $B5, $09, $36, $BE
                                ;;
        defb    $E9             ;;Exponent: $79, Bytes: 4
        defb    $36, $73, $1B, $5D
                                ;;
        defb    $EC             ;;Exponent: $7C, Bytes: 4
        defb    $D8, $de, $63, $BE
                                ;;
        defb    $F0             ;;Exponent: $80, Bytes: 4
        defb    $61, $A1, $B3, $0C
                                ;;

        defb    $04             ;;multiply
        defb    $0F             ;;addition
        defb    $34             ;;end-calc

        ret                     ; return.
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
;       /|
;      / |
;    1/  |x
;    /a  |
;   /----|
;     y
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
;       . /|
;        .  c/ |
;     .     /1 |x
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
        rst     28H             ;; FP-CALC      x.

        .db $3C                 ;;stk-square        x, x*x.
        .db $39                 ;;sub-one macro     x, x*x-1.

        defb    $18             ;;negate        x, 1-x*x.
        defb    $25             ;;sqr           x, sqr(1-x*x) = y.
        defb    $A1             ;;stk-one       x, y, 1.
        defb    $0F             ;;addition      x, y+1.
        defb    $05             ;;division      x/(y+1).
        defb    $21             ;;atn           a/2 (half the angle)
        defb    $34             ;;end-calc      return via mul-by-2:  a=2*a/2.
;
; ------------------------------
; THE 'MULTIPLY BY TWO' FUNCTION
; ------------------------------
; (Offset $3A: 'mul-by-2')
; this part is a new 'macro', which replaces the next 2 calc. literals
;
;   $2D  :  duplicate   (x,x)
;   $0F  :  addition    (x+x = 2*x)
;
mul_by_2
        ld      a, (hl)         ; test exponent
        and     a               ; >0?
        ret     z               ; return if it is zero (2*0=0!)

        inc     (hl)            ; else increase the exponent (*2)
        ret     nz              ; return if no overflow occurred
mul2_ovf
        rst     08h             ; Error Report:
        .db $05                 ; Number is too big
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
;       /|
;    1 /b|
;     /  |x
;    /a  |
;   /----|
;     y
;
fn_acs  rst 28H                 ;; FP-CALC      x.

        defb    $1F             ;;asn           asn(x).
        defb    $A3             ;;stk-pi/2      asn(x), pi/2.
        defb    $03             ;;subtract      asn(x) - pi/2.
        defb    $18             ;;negate        pi/2 - asn(x) = acs(x).
        defb    $34             ;;end-calc      acs(x)

        ret                     ; return.
;
; ---------------------------------
; THE 'SINGLE OPERATION' SUBROUTINE
; ---------------------------------
;   offset $37: 'fp-calc-2'
;   this single operation is used, in the first instance, to evaluate most
;   of the mathematical and string functions found in BASIC expressions.

fp_calc_2
        pop     af              ; drop return address.
        ld      a, ($401E)      ; load accumulator from system variable BREG
                                ; value will be literal eg. 'tan'
        exx                     ; switch to alt

        jp      SCAN_ENT        ; back to SCAN-ENT
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
        ld      c, a            ; store the original number $00-$1F.
        rlca                    ; double.
        rlca                    ; quadruple.
        add     a, c            ; now add original value to multiply by five.

        ld      c, a            ; place the result in C.
        ld      b, $00          ; set B to 0.
        add     hl, bc          ; add to form address of start of number in HL.
        ret                     ; return.
;
; ------------------------------
; THE 'MULTIPLY BY TEN' FUNCTION
; ------------------------------
; (Offset $3B: 'mul-by-10')
; the 'tricky' multiplication:  10x = 2x + 8x
; the new E-TO-FP and PRINT-FP call this subroutine
;
mul_by10
        call    mul_by_2        ; x1 = x*2  (tests overflow)
        ret     z               ; return if it is zero (2*0=0!)

        push    hl              ; save OP1 pointer
        call    COPY_FP         ; duplicate

        inc     (hl)            ; increase the exponent (4*x)
        jr      z, mul2_ovf     ; if overflow occurred

        inc     (hl)            ; increase the exponent (8*x)
        jr      z, mul2_ovf     ; if overflow occurred

        ex      de, hl          ; de: OP2 pointer
        pop     hl              ; hl: OP1 pointer
        jp      addition        ; routine addition (L1755)
                                ; y = 2*x + 8*x    (=10*x)
;
; ---------------------------
; THE 'STACK-SQUARE' FUNCTION
; ---------------------------
; (Offset $3C: 'stk-square')
; this part is a new 'macro', which replaces the next 3 calc. literals
;
;   $2D  :  duplicate   (x, x)
;   $2D  :  duplicate   (x, x, x)
;   $04  :  multiply    (x, x*x)
;
stk_squa
        call    COPY_FP         ; duplicate

        push    de              ; save stack end
        ld      d, h            ; set pointer to
        ld      e, l            ; last value on stack
        call    multiply        ; multiplication

        pop     de              ; restore pointer
        ret                     ; return w. square
;
;   ========================================================
;   the quick 'LOCATE ADDRESS' routine joins here
;
loc_xpnd
        ld      hl, ($400C)     ; HL points the beginning of the D-File
        bit     5, (iy+$3B)     ; sv CDFLAG - test expanded display file
        ret     z               ; return if not

        pop     de              ; else drop return address
        ld      de, 33          ; size of a complete line in bytes
        jr      add_33b         ; skip the 1st addition
add_33a
        add     hl, de          ; set pointer to the next line
add_33b
        djnz    add_33a         ; back if the line counter is nonzero

        add     hl, bc          ; add value of the X coordinate
        jp      set_DFCC        ; jump back to the caller
;
;   ========================================================
;   the new 'PLOT AND UNPLOT' routine joins here
;
plot_ext                        ; must be inverted?
        jr      c, plot_end     ; forward to PLOT-END, if not

        xor     $8F             ; swap the necessary bits
;
;; PLOT-END
plot_end
        bit     5, (iy+$3B)     ; sv CDFLAG - test expanded D-FILE
        jp      z, L07EE        ; if not, then return via OUT-CH

        ld      (hl), a         ; else write D-File immediate
        ret                     ; and return
;
;   ========================================================
;

;
; ------------------------
; THE 'ZX81 CHARACTER SET'
; ------------------------

;; char-set - begins with space character.

; $00 - Character: ' '      CHR$(0)

L1E00:  defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000

; $01 - Character: mosaic   CHR$(1)

        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000


; $02 - Character: mosaic   CHR$(2)

        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000


; $03 - Character: mosaic   CHR$(3)

        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000

; $04 - Character: mosaic   CHR$(4)

        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %11110000

; $05 - Character: mosaic   CHR$(5)

        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %11110000

; $06 - Character: mosaic   CHR$(6)

        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %11110000

; $07 - Character: mosaic   CHR$(7)

        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11110000
        defb    %11110000
        defb    %11110000
        defb    %11110000

; $08 - Character: mosaic   CHR$(8)

        defb    %10101010
        defb    %01010101
        defb    %10101010
        defb    %01010101
        defb    %10101010
        defb    %01010101
        defb    %10101010
        defb    %01010101

; $09 - Character: mosaic   CHR$(9)

        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %10101010
        defb    %01010101
        defb    %10101010
        defb    %01010101

; $0A - Character: mosaic   CHR$(10)

        defb    %10101010
        defb    %01010101
        defb    %10101010
        defb    %01010101
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000

; $0B - Character: '"'      CHR$(11)

        defb    %00000000
        defb    %00100100
        defb    %00100100
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000

; $0C - Character Pound     CHR$(12)

        defb    %00000000
        defb    %00011100
        defb    %00100010
        defb    %01111000
        defb    %00100000
        defb    %00100000
        defb    %01111110
        defb    %00000000

; $0D - Character: '$'      CHR$(13)

        defb    %00000000
        defb    %00001000
        defb    %00111110
        defb    %00101000
        defb    %00111110
        defb    %00001010
        defb    %00111110
        defb    %00001000

; $0E - Character: ':'      CHR$(14)

        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00010000
        defb    %00000000
        defb    %00000000
        defb    %00010000
        defb    %00000000

; $0F - Character: '?'      CHR$(15)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %00000100
        defb    %00001000
        defb    %00000000
        defb    %00001000
        defb    %00000000

; $10 - Character: '('      CHR$(16)

        defb    %00000000
        defb    %00000100
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00000100
        defb    %00000000

; $11 - Character: ')'      CHR$(17)

        defb    %00000000
        defb    %00100000
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00100000
        defb    %00000000

; $12 - Character: '>'      CHR$(18)

        defb    %00000000
        defb    %00000000
        defb    %00010000
        defb    %00001000
        defb    %00000100
        defb    %00001000
        defb    %00010000
        defb    %00000000

; $13 - Character: '<'      CHR$(19)

        defb    %00000000
        defb    %00000000
        defb    %00000100
        defb    %00001000
        defb    %00010000
        defb    %00001000
        defb    %00000100
        defb    %00000000

; $14 - Character: '='      CHR$(20)

        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00111110
        defb    %00000000
        defb    %00111110
        defb    %00000000
        defb    %00000000

; $15 - Character: '+'      CHR$(21)

        defb    %00000000
        defb    %00000000
        defb    %00001000
        defb    %00001000
        defb    %00111110
        defb    %00001000
        defb    %00001000
        defb    %00000000

; $16 - Character: '-'      CHR$(22)

        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00111110
        defb    %00000000
        defb    %00000000
        defb    %00000000

; $17 - Character: '*'      CHR$(23)

        defb    %00000000
        defb    %00000000
        defb    %00010100
        defb    %00001000
        defb    %00111110
        defb    %00001000
        defb    %00010100
        defb    %00000000

; $18 - Character: '/'      CHR$(24)

        defb    %00000000
        defb    %00000000
        defb    %00000010
        defb    %00000100
        defb    %00001000
        defb    %00010000
        defb    %00100000
        defb    %00000000

; $19 - Character: ';'      CHR$(25)

        defb    %00000000
        defb    %00000000
        defb    %00010000
        defb    %00000000
        defb    %00000000
        defb    %00010000
        defb    %00010000
        defb    %00100000

; $1A - Character: ','      CHR$(26)

        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00001000
        defb    %00001000
        defb    %00010000

; $1B - Character: '.'      CHR$(27)

        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00000000

; $1C - Character: '0'      CHR$(28)

        defb    %00000000
        defb    %00111100
        defb    %01000110
        defb    %01001010
        defb    %01010010
        defb    %01100010
        defb    %00111100
        defb    %00000000

; $1D - Character: '1'      CHR$(29)

        defb    %00000000
        defb    %00011000
        defb    %00101000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00111110
        defb    %00000000

; $1E - Character: '2'      CHR$(30)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %00000010
        defb    %00111100
        defb    %01000000
        defb    %01111110
        defb    %00000000

; $1F - Character: '3'      CHR$(31)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %00001100
        defb    %00000010
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $20 - Character: '4'      CHR$(32)

        defb    %00000000
        defb    %00001000
        defb    %00011000
        defb    %00101000
        defb    %01001000
        defb    %01111110
        defb    %00001000
        defb    %00000000

; $21 - Character: '5'      CHR$(33)

        defb    %00000000
        defb    %01111110
        defb    %01000000
        defb    %01111100
        defb    %00000010
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $22 - Character: '6'      CHR$(34)

        defb    %00000000
        defb    %00111100
        defb    %01000000
        defb    %01111100
        defb    %01000010
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $23 - Character: '7'      CHR$(35)

        defb    %00000000
        defb    %01111110
        defb    %00000010
        defb    %00000100
        defb    %00001000
        defb    %00010000
        defb    %00010000
        defb    %00000000

; $24 - Character: '8'      CHR$(36)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %00111100
        defb    %01000010
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $25 - Character: '9'      CHR$(37)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %01000010
        defb    %00111110
        defb    %00000010
        defb    %00111100
        defb    %00000000

; $26 - Character: 'A'      CHR$(38)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %01000010
        defb    %01111110
        defb    %01000010
        defb    %01000010
        defb    %00000000

; $27 - Character: 'B'      CHR$(39)

        defb    %00000000
        defb    %01111100
        defb    %01000010
        defb    %01111100
        defb    %01000010
        defb    %01000010
        defb    %01111100
        defb    %00000000

; $28 - Character: 'C'      CHR$(40)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %01000000
        defb    %01000000
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $29 - Character: 'D'      CHR$(41)

        defb    %00000000
        defb    %01111000
        defb    %01000100
        defb    %01000010
        defb    %01000010
        defb    %01000100
        defb    %01111000
        defb    %00000000

; $2A - Character: 'E'      CHR$(42)

        defb    %00000000
        defb    %01111110
        defb    %01000000
        defb    %01111100
        defb    %01000000
        defb    %01000000
        defb    %01111110
        defb    %00000000

; $2B - Character: 'F'      CHR$(43)

        defb    %00000000
        defb    %01111110
        defb    %01000000
        defb    %01111100
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %00000000

; $2C - Character: 'G'      CHR$(44)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %01000000
        defb    %01001110
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $2D - Character: 'H'      CHR$(45)

        defb    %00000000
        defb    %01000010
        defb    %01000010
        defb    %01111110
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %00000000

; $2E - Character: 'I'      CHR$(46)

        defb    %00000000
        defb    %00111110
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00111110
        defb    %00000000

; $2F - Character: 'J'      CHR$(47)

        defb    %00000000
        defb    %00000010
        defb    %00000010
        defb    %00000010
        defb    %01000010
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $30 - Character: 'K'      CHR$(48)

        defb    %00000000
        defb    %01000100
        defb    %01001000
        defb    %01110000
        defb    %01001000
        defb    %01000100
        defb    %01000010
        defb    %00000000

; $31 - Character: 'L'      CHR$(49)

        defb    %00000000
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %01111110
        defb    %00000000

; $32 - Character: 'M'      CHR$(50)

        defb    %00000000
        defb    %01000010
        defb    %01100110
        defb    %01011010
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %00000000

; $33 - Character: 'N'      CHR$(51)

        defb    %00000000
        defb    %01000010
        defb    %01100010
        defb    %01010010
        defb    %01001010
        defb    %01000110
        defb    %01000010
        defb    %00000000

; $34 - Character: 'O'      CHR$(52)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $35 - Character: 'P'      CHR$(53)

        defb    %00000000
        defb    %01111100
        defb    %01000010
        defb    %01000010
        defb    %01111100
        defb    %01000000
        defb    %01000000
        defb    %00000000

; $36 - Character: 'Q'      CHR$(54)

        defb    %00000000
        defb    %00111100
        defb    %01000010
        defb    %01000010
        defb    %01010010
        defb    %01001010
        defb    %00111100
        defb    %00000000

; $37 - Character: 'R'      CHR$(55)

        defb    %00000000
        defb    %01111100
        defb    %01000010
        defb    %01000010
        defb    %01111100
        defb    %01000100
        defb    %01000010
        defb    %00000000

; $38 - Character: 'S'      CHR$(56)

        defb    %00000000
        defb    %00111100
        defb    %01000000
        defb    %00111100
        defb    %00000010
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $39 - Character: 'T'      CHR$(57)

        defb    %00000000
        defb    %11111110
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00000000

; $3A - Character: 'U'      CHR$(58)

        defb    %00000000
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %00111100
        defb    %00000000

; $3B - Character: 'V'      CHR$(59)

        defb    %00000000
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %00100100
        defb    %00011000
        defb    %00000000

; $3C - Character: 'W'      CHR$(60)

        defb    %00000000
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %01000010
        defb    %01011010
        defb    %00100100
        defb    %00000000

; $3D - Character: 'X'      CHR$(61)

        defb    %00000000
        defb    %01000010
        defb    %00100100
        defb    %00011000
        defb    %00011000
        defb    %00100100
        defb    %01000010
        defb    %00000000

; $3E - Character: 'Y'      CHR$(62)

        defb    %00000000
        defb    %10000010
        defb    %01000100
        defb    %00101000
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00000000

; $3F - Character: 'Z'      CHR$(63)

        defb    %00000000
        defb    %01111110
        defb    %00000100
        defb    %00001000
        defb    %00010000
        defb    %00100000
        defb    %01111110
        defb    %00000000

.END                            ;TASM assembler instruction.


