line 140:
#define DEFB .BYTE      ; TASM cross-assembler definitions
#define defb .BYTE              ; TASM cross-assembler definitions

line 141:
#define DEFW .WORD
#define defw .WORD

line 143:
#define ORG .ORG
#define org .org

line 148:
                ; will be disabled (ClckFreq result is ~3% less)
                                ; will be disabled (ClckFreq result is ~3% less)

line 156:
    ORG $0000
        org     $0000

line 167:
    OUT ($FD),A     ; Turn off the NMI generator if this ROM is
        out     ($FD), a        ; Turn off the NMI generator if this ROM is

line 168:
                ; running in ZX81 hardware. This does nothing
                                ; running in ZX81 hardware. This does nothing

line 169:
                ; if this ROM is running within an upgraded ZX80.
                                ; if this ROM is running within an upgraded ZX80.

line 170:
    LD BC,$7FFF     ; Set BC to the top of possible RAM.
        ld      bc, $7FFF       ; Set BC to the top of possible RAM.

line 171:
                ; The higher unpopulated addresses are used for
                                ; The higher unpopulated addresses are used for

line 172:
                ; video generation.
                                ; video generation.

line 173:
    JP L03CB        ; Jump forward to RAM-CHECK.
        jp      L03CB           ; Jump forward to RAM-CHECK.

line 185:
L0008:  LD HL,($4016)       ; fetch character address from CH_ADD.
L0008:  ld hl, ($4016)          ; fetch character address from CH_ADD.

line 186:
    LD ($4018),HL       ; and set the error pointer X_PTR.
        ld      ($4018), hl     ; and set the error pointer X_PTR.

line 187:
    JR L0056        ; forward to continue at ERROR-2.
        jr      L0056           ; forward to continue at ERROR-2.

line 199:
    jp L07EE        ; routine OUT-CH
        jp      L07EE           ; routine OUT-CH

line 210:
    INC HL          ; point to byte with sign bit.
        inc     hl              ; point to byte with sign bit.

line 211:
    RES 7,(HL)      ; make the sign positive.
        res     7, (hl)         ; make the sign positive.

line 212:
    DEC HL          ; point to last value again.
        dec     hl              ; point to last value again.

line 213:
    RET         ; return.
        ret                     ; return.

line 225:
L0018:  LD HL,($4016)       ; set HL to character address CH_ADD.
L0018:  ld hl, ($4016)          ; set HL to character address CH_ADD.

line 226:
    LD A,(HL)       ; fetch addressed character to A.
        ld      a, (hl)         ; fetch addressed character to A.

line 229:
L001C:  AND A           ; test for space.
L001C:  and a                   ; test for space.

line 230:
    RET NZ          ; return if not a space
        ret     nz              ; return if not a space

line 232:
    NOP         ; else trickle through
        nop                     ; else trickle through

line 233:
    NOP         ; to the next routine.
        nop                     ; to the next routine.

line 242:
L0020:  CALL L0049      ; routine CH-ADD+1 gets next immediate
L0020:  call L0049              ; routine CH-ADD+1 gets next immediate

line 243:
                ; character.
                                ; character.

line 244:
    JR L001C        ; back to TEST-SP.
        jr      L001C           ; back to TEST-SP.

line 248:
    .db $26,$10,$20     ; unused locations - FW_ID: 26.10.2020
        .db $26, $10, $20       ; unused locations - FW_ID: 26.10.2020

line 262:
L0028:  JP CALCULATE        ;+ jump to the NEW calculate routine address.
L0028:  jp CALCULATE            ;+ jump to the NEW calculate routine address.

line 264:
end_calc            ; (L002B)
end_calc                        ; (L002B)

line 265:
    POP AF          ; drop the calculator return address RE-ENTRY
        pop     af              ; drop the calculator return address RE-ENTRY

line 266:
    EXX         ; switch to the other set.
        exx                     ; switch to the other set.

line 268:
    EX (SP),HL      ; transfer H'L' to machine stack for the
        ex      (sp), hl        ; transfer H'L' to machine stack for the

line 269:
                ; return address.
                                ; return address.

line 270:
                ; when exiting recursion then the previous
                                ; when exiting recursion then the previous

line 271:
                ; pointer is transferred to H'L'.
                                ; pointer is transferred to H'L'.

line 273:
    EXX         ; back to main set.
        exx                     ; back to main set.

line 274:
    RET             ; return.
        ret                     ; return.

line 284:
    PUSH BC         ; push number of spaces on stack.
        push    bc              ; push number of spaces on stack.

line 285:
    LD HL,($4014)       ; fetch edit line location from E_LINE.
        ld      hl, ($4014)     ; fetch edit line location from E_LINE.

line 286:
    PUSH HL         ; save this value on stack.
        push    hl              ; save this value on stack.

line 287:
    JP L1488        ; jump forward to continue at RESERVE.
        jp      L1488           ; jump forward to continue at RESERVE.

line 326:
    DEC C           ; (4)  decrement C - the scan line counter.
        dec     c               ; (4)  decrement C - the scan line counter.

line 327:
    JP NZ,L0045     ; (10/10) JUMP forward if not zero to SCAN-LINE
        jp      nz, L0045       ; (10/10) JUMP forward if not zero to SCAN-LINE

line 329:
    POP HL          ; (10) point to start of next row in display file.
        pop     hl              ; (10) point to start of next row in display file.

line 331:
    DEC B           ; (4)  decrement the row counter. (4)
        dec     b               ; (4)  decrement the row counter. (4)

line 332:
    RET Z           ; (11/5) return when picture complete to L028B
        ret     z               ; (11/5) return when picture complete to L028B

line 333:
                ; with interrupts disabled.
                                ; with interrupts disabled.

line 335:
    SET 3,C         ; (8)  Load the scan line counter with eight.
        set     3, c            ; (8)  Load the scan line counter with eight.

line 336:
                ; Note. LD C,$08 is 7 clock cycles which
                                ; Note. LD C,$08 is 7 clock cycles which

line 337:
                ; is way too fast.
                                ; is way too fast.

line 342:
    LD R,A          ; (9) Load R with initial rising value $DD.
        ld      r, a            ; (9) Load R with initial rising value $DD.

line 344:
    EI          ; (4) Enable Interrupts.  [ R is now $DE ].
        ei                      ; (4) Enable Interrupts.  [ R is now $DE ].

line 346:
    JP (HL)         ; (4) jump to the echo display file in upper
        jp      (hl)            ; (4) jump to the echo display file in upper

line 347:
                ;   memory and execute characters $00 - $3F
                                ;   memory and execute characters $00 - $3F

line 348:
                ;   as NOP instructions.  The video hardware
                                ;   as NOP instructions.  The video hardware

line 349:
                ;   is able to read these characters and,
                                ;   is able to read these characters and,

line 350:
                ;   with the I register is able to convert
                                ;   with the I register is able to convert

line 351:
                ;   the character bitmaps in this ROM into a
                                ;   the character bitmaps in this ROM into a

line 352:
                ;   line of bytes. Eventually the NEWLINE/HALT
                                ;   line of bytes. Eventually the NEWLINE/HALT

line 353:
                ;   will be encountered before R reaches $FF.
                                ;   will be encountered before R reaches $FF.

line 354:
                ;   It is however the transition from $FF to
                                ;   It is however the transition from $FF to

line 355:
                ;   $80 that triggers the next interrupt.
                                ;   $80 that triggers the next interrupt.

line 356:
                ;   [ The Refresh register is now $DF ]
                                ;   [ The Refresh register is now $DF ]

line 361:
    POP DE          ; (10) discard the address after NEWLINE as the
        pop     de              ; (10) discard the address after NEWLINE as the

line 362:
                ; same text line has to be done again
                                ; same text line has to be done again

line 363:
                ; eight times.
                                ; eight times.

line 365:
    RET Z           ; (5)  Harmless Nonsensical Timing.
        ret     z               ; (5)  Harmless Nonsensical Timing.

line 366:
                ; (condition never met)
                                ; (condition never met)

line 368:
    JR L0041        ; (12) back to WAIT-INT
        jr      L0041           ; (12) back to WAIT-INT

line 393:
    LD HL,($4016)       ; fetch character address to CH_ADD.
        ld      hl, ($4016)     ; fetch character address to CH_ADD.

line 397:
    INC HL          ; address next immediate location.
        inc     hl              ; address next immediate location.

line 401:
    LD ($4016),HL       ; update system variable CH_ADD.
        ld      ($4016), hl     ; update system variable CH_ADD.

line 403:
    LD A,(HL)       ; fetch the character.
        ld      a, (hl)         ; fetch the character.

line 404:
    CP $7F          ; compare to cursor character.
        cp      $7F             ; compare to cursor character.

line 405:
    RET NZ          ; return if not the cursor.
        ret     nz              ; return if not the cursor.

line 407:
    JR L004C        ; back for next character to TEMP-PTR1.
        jr      L004C           ; back for next character to TEMP-PTR1.

line 421:
    POP HL          ; pop the return address which points to the
        pop     hl              ; pop the return address which points to the

line 422:
                ; DEFB, error code, after the RST 08.
                                ; DEFB, error code, after the RST 08.

line 423:
    LD L,(HL)       ; load L with the error code. HL is not needed
        ld      l, (hl)         ; load L with the error code. HL is not needed

line 424:
                ; anymore.
                                ; anymore.

line 427:
    LD (IY+$00),L       ; place error code in system variable ERR_NR
        ld      (iy+$00), l     ; place error code in system variable ERR_NR

line 428:
    LD SP,($4002)       ; set the stack pointer from ERR_SP
        ld      sp, ($4002)     ; set the stack pointer from ERR_SP

line 429:
    CALL L0207      ; routine SLOW/FAST selects slow mode.
        call    L0207           ; routine SLOW/FAST selects slow mode.

line 431:
    JP L14BC        ; exit to address on stack via routine SET-MIN.
        jp      L14BC           ; exit to address on stack via routine SET-MIN.

line 433:
    DEFB $FF        ; unused.
        defb    $FF             ; unused.

line 449:
    EX AF,AF'       ; (4) switch in the NMI's copy of the
        ex      af, af'       ; (4) switch in the NMI's copy of the

line 450:
                ;   accumulator.
                                ;   accumulator.

line 451:
    INC A           ; (4) increment.
        inc     a               ; (4) increment.

line 455:
    JP M,NMI_RET        ; (10/10) jump, if minus, to NMI-RET as this is
        jp      m, NMI_RET      ; (10/10) jump, if minus, to NMI-RET as this is

line 456:
                ;   part of a test to see if the NMI
                                ;   part of a test to see if the NMI

line 457:
                ;   generation is working or an intermediate
                                ;   generation is working or an intermediate

line 458:
                ;   value for the ascending negated blank
                                ;   value for the ascending negated blank

line 459:
                ;   line counter.
                                ;   line counter.

line 461:
    JR Z,NMI_CONT       ; (12) forward to NMI-CONT
        jr      z, NMI_CONT     ; (12) forward to NMI-CONT

line 462:
                ; when line count has incremented to zero.
                                ; when line count has incremented to zero.

line 466:
    EX AF,AF'       ; (4)  switch out the incremented line counter
        ex      af, af'         ; (4)  switch out the incremented line counter

line 467:
                ; or test result $80
                                ; or test result $80

line 468:
    RET             ; (10) return to User application for a while.
        ret                     ; (10) return to User application for a while.

line 474:
    EX AF,AF'       ; (4) restore the main accumulator.
        ex      af, af'         ; (4) restore the main accumulator.

line 476:
    PUSH AF         ; (11) *  Save Main Registers
        push    af              ; (11) *  Save Main Registers

line 477:
    PUSH BC         ; (11) **
        push    bc              ; (11) **

line 478:
    PUSH DE         ; (11) ***
        push    de              ; (11) ***

line 479:
    PUSH HL         ; (11) ****
        push    hl              ; (11) ****

line 484:
    LD HL,($400C)       ; (16) fetch start of Display File from D_FILE
        ld      hl, ($400C)     ; (16) fetch start of Display File from D_FILE

line 485:
                ; points to the HALT at beginning.
                                ; points to the HALT at beginning.

line 486:
    SET 7,H         ; (8) point to upper 32K 'echo display file'
        set     7, h            ; (8) point to upper 32K 'echo display file'

line 488:
    HALT            ; (1) HALT synchronizes with NMI.
        halt                    ; (1) HALT synchronizes with NMI.

line 489:
                ; Used with special hardware connected to the
                                ; Used with special hardware connected to the

line 490:
                ; Z80 HALT and WAIT lines to take 1 clock cycle.
                                ; Z80 HALT and WAIT lines to take 1 clock cycle.

line 519:
    OUT ($FD),A     ; (11) Stop the NMI generator.
        out     ($FD), a        ; (11) Stop the NMI generator.

line 522:
    jp IX_to_PC     ; (10) Delay
        jp      IX_to_PC        ; (10) Delay

line 526:
    JP (IX)         ; (8) forward to L0281 (after top) or L028F
        jp      (ix)            ; (8) forward to L0281 (after top) or L028F

line 537:
L007E:  DEFB $3F  ; Z
L007E:  defb $3F                ; Z

line 538:
    DEFB $3D  ; X
        defb    $3D             ; X

line 539:
    DEFB $28  ; C
        defb    $28             ; C

line 540:
    DEFB $3B  ; V
        defb    $3B             ; V

line 541:
    DEFB $26  ; A
        defb    $26             ; A

line 542:
    DEFB $38  ; S
        defb    $38             ; S

line 543:
    DEFB $29  ; D
        defb    $29             ; D

line 544:
    DEFB $2B  ; F
        defb    $2B             ; F

line 545:
    DEFB $2C  ; G
        defb    $2C             ; G

line 546:
    DEFB $36  ; Q
        defb    $36             ; Q

line 547:
    DEFB $3C  ; W
        defb    $3C             ; W

line 548:
    DEFB $2A  ; E
        defb    $2A             ; E

line 549:
    DEFB $37  ; R
        defb    $37             ; R

line 550:
    DEFB $39  ; T
        defb    $39             ; T

line 551:
    DEFB $1D  ; 1
        defb    $1D             ; 1

line 552:
    DEFB $1E  ; 2
        defb    $1E             ; 2

line 553:
    DEFB $1F  ; 3
        defb    $1F             ; 3

line 554:
    DEFB $20  ; 4
        defb    $20             ; 4

line 555:
    DEFB $21  ; 5
        defb    $21             ; 5

line 556:
    DEFB $1C  ; 0
        defb    $1C             ; 0

line 557:
    DEFB $25  ; 9
        defb    $25             ; 9

line 558:
    DEFB $24  ; 8
        defb    $24             ; 8

line 559:
    DEFB $23  ; 7
        defb    $23             ; 7

line 560:
    DEFB $22  ; 6
        defb    $22             ; 6

line 561:
    DEFB $35  ; P
        defb    $35             ; P

line 562:
    DEFB $34  ; O
        defb    $34             ; O

line 563:
    DEFB $2E  ; I
        defb    $2E             ; I

line 564:
    DEFB $3A  ; U
        defb    $3A             ; U

line 565:
    DEFB $3E  ; Y
        defb    $3E             ; Y

line 566:
    DEFB $76  ; NEWLINE
        defb    $76             ; NEWLINE

line 567:
    DEFB $31  ; L
        defb    $31             ; L

line 568:
    DEFB $30  ; K
        defb    $30             ; K

line 569:
    DEFB $2F  ; J
        defb    $2F             ; J

line 570:
    DEFB $2D  ; H
        defb    $2D             ; H

line 571:
    DEFB $00  ; SPACE
        defb    $00             ; SPACE

line 572:
    DEFB $1B  ; .
        defb    $1B             ; .

line 573:
    DEFB $32  ; M
        defb    $32             ; M

line 574:
    DEFB $33  ; N
        defb    $33             ; N

line 575:
    DEFB $27  ; B
        defb    $27             ; B

line 582:
L00A5:  DEFB $0E  ; :
L00A5:  defb $0E                ; :

line 583:
    DEFB $19  ; ;
        defb    $19             ; ;

line 584:
    DEFB $0F  ; ?
        defb    $0F             ; ?

line 585:
    DEFB $18  ; /
        defb    $18             ; /

line 586:
    DEFB $E3  ; STOP
        defb    $E3             ; STOP

line 587:
    DEFB $E1  ; LPRINT
        defb    $E1             ; LPRINT

line 588:
    DEFB $E4  ; SLOW
        defb    $E4             ; SLOW

line 589:
    DEFB $E5  ; FAST
        defb    $E5             ; FAST

line 590:
    DEFB $E2  ; LLIST
        defb    $E2             ; LLIST

line 591:
    DEFB $C0  ; ""
        defb    $C0             ; ""

line 592:
    DEFB $D9  ; OR
        defb    $D9             ; OR

line 593:
    DEFB $E0  ; STEP
        defb    $E0             ; STEP

line 594:
    DEFB $DB  ; <=
        defb    $DB             ; <=

line 595:
    DEFB $DD  ; <>
        defb    $DD             ; <>

line 596:
    DEFB $75  ; EDIT
        defb    $75             ; EDIT

line 597:
    DEFB $DA  ; AND
        defb    $DA             ; AND

line 598:
    DEFB $DE  ; THEN
        defb    $de             ; THEN

line 599:
    DEFB $DF  ; TO
        defb    $DF             ; TO

line 600:
    DEFB $72  ; cursor-left
        defb    $72             ; cursor-left

line 601:
    DEFB $77  ; RUBOUT
        defb    $77             ; RUBOUT

line 602:
    DEFB $74  ; GRAPHICS
        defb    $74             ; GRAPHICS

line 603:
    DEFB $73  ; cursor-right
        defb    $73             ; cursor-right

line 604:
    DEFB $70  ; cursor-up
        defb    $70             ; cursor-up

line 605:
    DEFB $71  ; cursor-down
        defb    $71             ; cursor-down

line 606:
    DEFB $0B  ; "
        defb    $0B             ; "

line 607:
    DEFB $11  ; )
        defb    $11             ; )

line 608:
    DEFB $10  ; (
        defb    $10             ; (

line 609:
    DEFB $0D  ; $
        defb    $0D             ; $

line 610:
    DEFB $DC  ; >=
        defb    $DC             ; >=

line 611:
    DEFB $79  ; FUNCTION
        defb    $79             ; FUNCTION

line 612:
    DEFB $14  ; =
        defb    $14             ; =

line 613:
    DEFB $15  ; +
        defb    $15             ; +

line 614:
    DEFB $16  ; -
        defb    $16             ; -

line 615:
    DEFB $D8  ; **
        defb    $D8             ; **

line 616:
    DEFB $0C  ;  &#163;
        defb    $0C             ;  &#163;

line 617:
    DEFB $1A  ; ,
        defb    $1A             ; ,

line 618:
    DEFB $12  ; >
        defb    $12             ; >

line 619:
    DEFB $13  ; <
        defb    $13             ; <

line 620:
    DEFB $17  ; *
        defb    $17             ; *

line 627:
L00CC:  DEFB $CD  ; LN
L00CC:  defb $CD                ; LN

line 628:
    DEFB $CE  ; EXP
        defb    $CE             ; EXP

line 629:
    DEFB $C1  ; AT
        defb    $C1             ; AT

line 630:
    DEFB $78  ; KL
        defb    $78             ; KL

line 631:
    DEFB $CA  ; ASN
        defb    $CA             ; ASN

line 632:
    DEFB $CB  ; ACS
        defb    $CB             ; ACS

line 633:
    DEFB $CC  ; ATN
        defb    $CC             ; ATN

line 634:
    DEFB $D1  ; SGN
        defb    $D1             ; SGN

line 635:
    DEFB $D2  ; ABS
        defb    $D2             ; ABS

line 636:
    DEFB $C7  ; SIN
        defb    $C7             ; SIN

line 637:
    DEFB $C8  ; COS
        defb    $C8             ; COS

line 638:
    DEFB $C9  ; TAN
        defb    $C9             ; TAN

line 639:
    DEFB $CF  ; INT
        defb    $CF             ; INT

line 640:
    DEFB $40  ; RND
        defb    $40             ; RND

line 641:
    DEFB $78  ; KL
        defb    $78             ; KL

line 642:
    DEFB $78  ; KL
        defb    $78             ; KL

line 643:
    DEFB $78  ; KL
        defb    $78             ; KL

line 644:
    DEFB $78  ; KL
        defb    $78             ; KL

line 645:
    DEFB $78  ; KL
        defb    $78             ; KL

line 646:
    DEFB $78  ; KL
        defb    $78             ; KL

line 647:
    DEFB $78  ; KL
        defb    $78             ; KL

line 648:
    DEFB $78  ; KL
        defb    $78             ; KL

line 649:
    DEFB $78  ; KL
        defb    $78             ; KL

line 650:
    DEFB $78  ; KL
        defb    $78             ; KL

line 651:
    DEFB $C2  ; TAB
        defb    $C2             ; TAB

line 652:
    DEFB $D3  ; PEEK
        defb    $D3             ; PEEK

line 653:
    DEFB $C4  ; CODE
        defb    $C4             ; CODE

line 654:
    DEFB $D6  ; CHR$
        defb    $D6             ; CHR$

line 655:
    DEFB $D5  ; STR$
        defb    $D5             ; STR$

line 656:
    DEFB $78  ; KL
        defb    $78             ; KL

line 657:
    DEFB $D4  ; USR
        defb    $D4             ; USR

line 658:
    DEFB $C6  ; LEN
        defb    $C6             ; LEN

line 659:
    DEFB $C5  ; VAL
        defb    $C5             ; VAL

line 660:
    DEFB $D0  ; SQR
        defb    $D0             ; SQR

line 661:
    DEFB $78  ; KL
        defb    $78             ; KL

line 662:
    DEFB $78  ; KL
        defb    $78             ; KL

line 663:
    DEFB $42  ; PI
        defb    $42             ; PI

line 664:
    DEFB $D7  ; NOT
        defb    $D7             ; NOT

line 665:
    DEFB $41  ; INKEY$
        defb    $41             ; INKEY$

line 672:
L00F3:  DEFB $08  ; graphic
L00F3:  defb $08                ; graphic

line 673:
    DEFB $0A  ; graphic
        defb    $0A             ; graphic

line 674:
    DEFB $09  ; graphic
        defb    $09             ; graphic

line 675:
    DEFB $8A  ; graphic
        defb    $8A             ; graphic

line 676:
    DEFB $89  ; graphic
        defb    $89             ; graphic

line 677:
    DEFB $81  ; graphic
        defb    $81             ; graphic

line 678:
    DEFB $82  ; graphic
        defb    $82             ; graphic

line 679:
    DEFB $07  ; graphic
        defb    $07             ; graphic

line 680:
    DEFB $84  ; graphic
        defb    $84             ; graphic

line 681:
    DEFB $06  ; graphic
        defb    $06             ; graphic

line 682:
    DEFB $01  ; graphic
        defb    $01             ; graphic

line 683:
    DEFB $02  ; graphic
        defb    $02             ; graphic

line 684:
    DEFB $87  ; graphic
        defb    $87             ; graphic

line 685:
    DEFB $04  ; graphic
        defb    $04             ; graphic

line 686:
    DEFB $05  ; graphic
        defb    $05             ; graphic

line 687:
    DEFB $77  ; RUBOUT
        defb    $77             ; RUBOUT

line 688:
    DEFB $78  ; KL
        defb    $78             ; KL

line 689:
    DEFB $85  ; graphic
        defb    $85             ; graphic

line 690:
    DEFB $03  ; graphic
        defb    $03             ; graphic

line 691:
    DEFB $83  ; graphic
        defb    $83             ; graphic

line 692:
    DEFB $8B  ; graphic
        defb    $8B             ; graphic

line 693:
    DEFB $91  ; inverse )
        defb    $91             ; inverse )

line 694:
    DEFB $90  ; inverse (
        defb    $90             ; inverse (

line 695:
    DEFB $8D  ; inverse $
        defb    $8D             ; inverse $

line 696:
    DEFB $86  ; graphic
        defb    $86             ; graphic

line 697:
    DEFB $78  ; KL
        defb    $78             ; KL

line 698:
    DEFB $92  ; inverse >
        defb    $92             ; inverse >

line 699:
    DEFB $95  ; inverse +
        defb    $95             ; inverse +

line 700:
    DEFB $96  ; inverse -
        defb    $96             ; inverse -

line 701:
    DEFB $88  ; graphic
        defb    $88             ; graphic

line 708:
L0111:  DEFB $0F+$80                ; '?'+$80
L0111:  defb $0F+$80            ; '?'+$80

line 709:
    DEFB $0B,$0B+$80            ; ""
        defb    $0B, $0B+$80    ; ""

line 710:
    DEFB $26,$39+$80            ; AT
        defb    $26, $39+$80    ; AT

line 711:
    DEFB $39,$26,$27+$80            ; TAB
        defb    $39, $26, $27+$80
                                ; TAB

line 712:
    DEFB $0F+$80                ; '?'+$80
        defb    $0F+$80         ; '?'+$80

line 713:
    DEFB $28,$34,$29,$2A+$80        ; CODE
        defb    $28, $34, $29, $2A+$80
                                ; CODE

line 714:
    DEFB $3B,$26,$31+$80            ; VAL
        defb    $3B, $26, $31+$80
                                ; VAL

line 715:
    DEFB $31,$2A,$33+$80            ; LEN
        defb    $31, $2A, $33+$80
                                ; LEN

line 716:
    DEFB $38,$2E,$33+$80            ; SIN
        defb    $38, $2E, $33+$80
                                ; SIN

line 717:
    DEFB $28,$34,$38+$80            ; COS
        defb    $28, $34, $38+$80
                                ; COS

line 718:
    DEFB $39,$26,$33+$80            ; TAN
        defb    $39, $26, $33+$80
                                ; TAN

line 719:
    DEFB $26,$38,$33+$80            ; ASN
        defb    $26, $38, $33+$80
                                ; ASN

line 720:
    DEFB $26,$28,$38+$80            ; ACS
        defb    $26, $28, $38+$80
                                ; ACS

line 721:
    DEFB $26,$39,$33+$80            ; ATN
        defb    $26, $39, $33+$80
                                ; ATN

line 722:
    DEFB $31,$33+$80            ; LN
        defb    $31, $33+$80    ; LN

line 723:
    DEFB $2A,$3D,$35+$80            ; EXP
        defb    $2A, $3D, $35+$80
                                ; EXP

line 724:
    DEFB $2E,$33,$39+$80            ; INT
        defb    $2E, $33, $39+$80
                                ; INT

line 725:
    DEFB $38,$36,$37+$80            ; SQR
        defb    $38, $36, $37+$80
                                ; SQR

line 726:
    DEFB $38,$2C,$33+$80            ; SGN
        defb    $38, $2C, $33+$80
                                ; SGN

line 727:
    DEFB $26,$27,$38+$80            ; ABS
        defb    $26, $27, $38+$80
                                ; ABS

line 728:
    DEFB $35,$2A,$2A,$30+$80        ; PEEK
        defb    $35, $2A, $2A, $30+$80
                                ; PEEK

line 729:
    DEFB $3A,$38,$37+$80            ; USR
        defb    $3A, $38, $37+$80
                                ; USR

line 730:
    DEFB $38,$39,$37,$0D+$80        ; STR$
        defb    $38, $39, $37, $0D+$80
                                ; STR$

line 731:
    DEFB $28,$2D,$37,$0D+$80        ; CHR$
        defb    $28, $2D, $37, $0D+$80
                                ; CHR$

line 732:
    DEFB $33,$34,$39+$80            ; NOT
        defb    $33, $34, $39+$80
                                ; NOT

line 733:
    DEFB $17,$17+$80            ; **
        defb    $17, $17+$80    ; **

line 734:
    DEFB $34,$37+$80            ; OR
        defb    $34, $37+$80    ; OR

line 735:
    DEFB $26,$33,$29+$80            ; AND
        defb    $26, $33, $29+$80
                                ; AND

line 736:
    DEFB $13,$14+$80            ; <=
        defb    $13, $14+$80    ; <=

line 737:
    DEFB $12,$14+$80            ; >=
        defb    $12, $14+$80    ; >=

line 738:
    DEFB $13,$12+$80            ; <>
        defb    $13, $12+$80    ; <>

line 739:
    DEFB $39,$2D,$2A,$33+$80        ; THEN
        defb    $39, $2D, $2A, $33+$80
                                ; THEN

line 740:
    DEFB $39,$34+$80            ; TO
        defb    $39, $34+$80    ; TO

line 741:
    DEFB $38,$39,$2A,$35+$80        ; STEP
        defb    $38, $39, $2A, $35+$80
                                ; STEP

line 742:
    DEFB $31,$35,$37,$2E,$33,$39+$80    ; LPRINT
        defb    $31, $35, $37, $2E, $33, $39+$80
                                ; LPRINT

line 743:
    DEFB $31,$31,$2E,$38,$39+$80        ; LLIST
        defb    $31, $31, $2E, $38, $39+$80
                                ; LLIST

line 744:
    DEFB $38,$39,$34,$35+$80        ; STOP
        defb    $38, $39, $34, $35+$80
                                ; STOP

line 745:
    DEFB $38,$31,$34,$3C+$80        ; SLOW
        defb    $38, $31, $34, $3C+$80
                                ; SLOW

line 746:
    DEFB $2B,$26,$38,$39+$80        ; FAST
        defb    $2B, $26, $38, $39+$80
                                ; FAST

line 747:
    DEFB $33,$2A,$3C+$80            ; NEW
        defb    $33, $2A, $3C+$80
                                ; NEW

line 748:
    DEFB $38,$28,$37,$34,$31,$31+$80    ; SCROLL
        defb    $38, $28, $37, $34, $31, $31+$80
                                ; SCROLL

line 749:
    DEFB $28,$34,$33,$39+$80        ; CONT
        defb    $28, $34, $33, $39+$80
                                ; CONT

line 750:
    DEFB $29,$2E,$32+$80            ; DIM
        defb    $29, $2E, $32+$80
                                ; DIM

line 751:
    DEFB $37,$2A,$32+$80            ; REM
        defb    $37, $2A, $32+$80
                                ; REM

line 752:
    DEFB $2B,$34,$37+$80            ; FOR
        defb    $2B, $34, $37+$80
                                ; FOR

line 753:
    DEFB $2C,$34,$39,$34+$80        ; GOTO
        defb    $2C, $34, $39, $34+$80
                                ; GOTO

line 754:
    DEFB $2C,$34,$38,$3A,$27+$80        ; GOSUB
        defb    $2C, $34, $38, $3A, $27+$80
                                ; GOSUB

line 755:
    DEFB $2E,$33,$35,$3A,$39+$80        ; INPUT
        defb    $2E, $33, $35, $3A, $39+$80
                                ; INPUT

line 756:
    DEFB $31,$34,$26,$29+$80        ; LOAD
        defb    $31, $34, $26, $29+$80
                                ; LOAD

line 757:
    DEFB $31,$2E,$38,$39+$80        ; LIST
        defb    $31, $2E, $38, $39+$80
                                ; LIST

line 758:
    DEFB $31,$2A,$39+$80            ; LET
        defb    $31, $2A, $39+$80
                                ; LET

line 759:
    DEFB $35,$26,$3A,$38,$2A+$80        ; PAUSE
        defb    $35, $26, $3A, $38, $2A+$80
                                ; PAUSE

line 760:
    DEFB $33,$2A,$3D,$39+$80        ; NEXT
        defb    $33, $2A, $3D, $39+$80
                                ; NEXT

line 761:
    DEFB $35,$34,$30,$2A+$80        ; POKE
        defb    $35, $34, $30, $2A+$80
                                ; POKE

line 762:
    DEFB $35,$37,$2E,$33,$39+$80        ; PRINT
        defb    $35, $37, $2E, $33, $39+$80
                                ; PRINT

line 763:
    DEFB $35,$31,$34,$39+$80        ; PLOT
        defb    $35, $31, $34, $39+$80
                                ; PLOT

line 764:
    DEFB $37,$3A,$33+$80            ; RUN
        defb    $37, $3A, $33+$80
                                ; RUN

line 765:
    DEFB $38,$26,$3B,$2A+$80        ; SAVE
        defb    $38, $26, $3B, $2A+$80
                                ; SAVE

line 766:
    DEFB $37,$26,$33,$29+$80        ; RAND
        defb    $37, $26, $33, $29+$80
                                ; RAND

line 767:
    DEFB $2E,$2B+$80            ; IF
        defb    $2E, $2B+$80    ; IF

line 768:
    DEFB $28,$31,$38+$80            ; CLS
        defb    $28, $31, $38+$80
                                ; CLS

line 769:
    DEFB $3A,$33,$35,$31,$34,$39+$80    ; UNPLOT
        defb    $3A, $33, $35, $31, $34, $39+$80
                                ; UNPLOT

line 770:
    DEFB $28,$31,$2A,$26,$37+$80        ; CLEAR
        defb    $28, $31, $2A, $26, $37+$80
                                ; CLEAR

line 771:
    DEFB $37,$2A,$39,$3A,$37,$33+$80    ; RETURN
        defb    $37, $2A, $39, $3A, $37, $33+$80
                                ; RETURN

line 772:
    DEFB $28,$34,$35,$3E+$80        ; COPY
        defb    $28, $34, $35, $3E+$80
                                ; COPY

line 773:
    DEFB $37,$33,$29+$80            ; RND
        defb    $37, $33, $29+$80
                                ; RND

line 774:
    DEFB $2E,$33,$30,$2A,$3E,$0D+$80    ; INKEY$
        defb    $2E, $33, $30, $2A, $3E, $0D+$80
                                ; INKEY$

line 775:
    DEFB $35,$2E+$80            ; PI
        defb    $35, $2E+$80    ; PI

line 783:
    INC HL          ;
        inc     hl              ;

line 784:
    EX DE,HL        ;
        ex      de, hl          ;

line 785:
    LD HL,($4014)       ; system variable edit line E_LINE.
        ld      hl, ($4014)     ; system variable edit line E_LINE.

line 786:
    SCF         ; set carry flag
        scf                     ; set carry flag

line 787:
    SBC HL,DE       ;
        sbc     hl, de          ;

line 788:
    EX DE,HL        ;
        ex      de, hl          ;

line 789:
    RET NC          ; return if more bytes to load/save.
        ret     nc              ; return if more bytes to load/save.

line 791:
    POP HL          ; else drop return address
        pop     hl              ; else drop return address

line 799:
    LD HL,$403B     ; Address the system variable CDFLAG.
        ld      hl, $403B       ; Address the system variable CDFLAG.

line 800:
    LD A,(HL)       ; Load value to the accumulator.
        ld      a, (hl)         ; Load value to the accumulator.

line 801:
    RLA         ; rotate bit 6 to position 7.
        rla                     ; rotate bit 6 to position 7.

line 802:
    XOR (HL)        ; exclusive or with original bit 7.
        xor     (hl)            ; exclusive or with original bit 7.

line 803:
    RLA         ; rotate result out to carry.
        rla                     ; rotate result out to carry.

line 804:
    RET NC          ; return if both bits were the same.
        ret     nc              ; return if both bits were the same.

line 809:
    LD A,$7F        ; Load accumulator with %011111111
        ld      a, $7F          ; Load accumulator with %011111111

line 810:
    EX AF,AF'       ; save in AF'
        ex      af, af'       ; save in AF'

line 812:
#ifdef zxmore           ; A counter within which an NMI should occur
#ifdef zxmore                   ; A counter within which an NMI should occur

line 814:
    LD B,$22        ; if this is a zxmore.
        ld      b, $22          ; if this is a zxmore.

line 816:
    LD B,$11        ; if this is a ZX81.
        ld      b, $11          ; if this is a ZX81.

line 818:
    OUT ($FE),A     ; start the NMI generator.
        out     ($FE), a        ; start the NMI generator.

line 824:
    DJNZ L0216      ; self loop to give the NMI a chance to kick in.
        djnz    L0216           ; self loop to give the NMI a chance to kick in.

line 825:
                ; = 16*13 clock cycles + 8 = 216 clock cycles.
                                ; = 16*13 clock cycles + 8 = 216 clock cycles.

line 827:
    OUT ($FD),A     ; Turn off the NMI generator.
        out     ($FD), a        ; Turn off the NMI generator.

line 828:
    EX AF,AF'       ; bring back the AF' value.
        ex      af, af'       ; bring back the AF' value.

line 829:
    RLA         ; test bit 7.
        rla                     ; test bit 7.

line 830:
    JR NC,L0226     ; forward, if bit 7 is still reset, to NO-SLOW.
        jr      nc, L0226       ; forward, if bit 7 is still reset, to NO-SLOW.

line 834:
    SET 7,(HL)      ; Indicate SLOW mode - Compute and Display.
        set     7, (hl)         ; Indicate SLOW mode - Compute and Display.

line 836:
    PUSH AF         ; *  Save Main Registers
        push    af              ; *  Save Main Registers

line 837:
    PUSH BC         ; **
        push    bc              ; **

line 838:
    PUSH DE         ; ***
        push    de              ; ***

line 839:
    PUSH HL         ; ****
        push    hl              ; ****

line 841:
    JR L0229        ; skip forward - to DISPLAY-1.
        jr      L0229           ; skip forward - to DISPLAY-1.

line 846:
    RES 6,(HL)      ; reset bit 6 of CDFLAG.
        res     6, (hl)         ; reset bit 6 of CDFLAG.

line 847:
    RET             ; return.
        ret                     ; return.

line 856:
    LD HL,($4034)       ; fetch two-byte system variable FRAMES.
        ld      hl, ($4034)     ; fetch two-byte system variable FRAMES.

line 857:
    DEC HL          ; decrement frames counter.
        dec     hl              ; decrement frames counter.

line 861:
    LD A,$7F        ; prepare a mask
        ld      a, $7F          ; prepare a mask

line 862:
    AND H           ; pick up bits 6-0 of H.
        and     h               ; pick up bits 6-0 of H.

line 863:
    OR L            ; and any bits of L.
        or      l               ; and any bits of L.

line 864:
    LD A,H          ; reload A with all bits of H for PAUSE test.
        ld      a, h            ; reload A with all bits of H for PAUSE test.

line 868:
    JR NZ,L0237     ; (12/7) forward if bits 14-0 are not zero
        jr      nz, L0237       ; (12/7) forward if bits 14-0 are not zero

line 869:
                ; to ANOTHER
                                ; to ANOTHER

line 871:
    RLA         ; (4) test bit 15 of FRAMES.
        rla                     ; (4) test bit 15 of FRAMES.

line 872:
    JR L0239        ; (12) forward with result to OVER-NC
        jr      L0239           ; (12) forward with result to OVER-NC

line 877:
    LD B,(HL)       ; (7) Note. Harmless Nonsensical Timing weight.
        ld      b, (hl)         ; (7) Note. Harmless Nonsensical Timing weight.

line 878:
    SCF         ; (4) Set Carry Flag.
        scf                     ; (4) Set Carry Flag.

line 884:
    LD H,A          ; (4)  set H to zero
        ld      h, a            ; (4)  set H to zero

line 885:
    LD ($4034),HL       ; (16) update system variable FRAMES
        ld      ($4034), hl     ; (16) update system variable FRAMES

line 886:
    RET NC          ; (11/5) return if FRAMES is in use by PAUSE
        ret     nc              ; (11/5) return if FRAMES is in use by PAUSE

line 887:
                ; command.
                                ; command.

line 890:
    CALL L02BB      ; routine KEYBOARD gets the key row in H and
        call    L02BB           ; routine KEYBOARD gets the key row in H and

line 891:
                ; the column in L. Reading the ports also starts
                                ; the column in L. Reading the ports also starts

line 892:
                ; the TV frame synchronization pulse. (VSYNC)(T735)
                                ; the TV frame synchronization pulse. (VSYNC)(T735)

line 894:
    LD BC,($4025)       ; fetch the last key values read from LAST_K
        ld      bc, ($4025)     ; fetch the last key values read from LAST_K

line 895:
    LD ($4025),HL       ; update LAST_K with new values.
        ld      ($4025), hl     ; update LAST_K with new values.

line 897:
    LD A,B          ; load A with previous column - will be $FF if
        ld      a, b            ; load A with previous column - will be $FF if

line 898:
                ; there was no key.
                                ; there was no key.

line 899:
    ADD A,$02       ; adding two will set carry if no previous key.
        add     a, $02          ; adding two will set carry if no previous key.

line 901:
    SBC HL,BC       ; subtract with the carry the two key values.
        sbc     hl, bc          ; subtract with the carry the two key values.

line 905:
    LD A,($4027)        ; fetch system variable DEBOUNCE
        ld      a, ($4027)      ; fetch system variable DEBOUNCE

line 906:
    OR H            ; and OR with both bytes of the difference
        or      h               ; and OR with both bytes of the difference

line 907:
    OR L            ; setting the zero flag for the upcoming branch.
        or      l               ; setting the zero flag for the upcoming branch.

line 909:
    LD E,B          ; transfer the column value to E
        ld      e, b            ; transfer the column value to E

line 910:
    LD B,$0B        ; and load B with eleven
        ld      b, $0B          ; and load B with eleven

line 912:
    LD HL,$403B     ; address system variable CDFLAG
        ld      hl, $403B       ; address system variable CDFLAG

line 913:
    RES 0,(HL)      ; reset the rightmost bit of CDFLAG (VSYNC=T735+T119=T854)
        res     0, (hl)         ; reset the rightmost bit of CDFLAG (VSYNC=T735+T119=T854)

line 914:
    JR NZ,L0264     ; skip forward if debounce/diff >0 to NO-KEY (+T12)
        jr      nz, L0264       ; skip forward if debounce/diff >0 to NO-KEY (+T12)

line 916:
    BIT 7,(HL)      ; test compute and display bit of CDFLAG
        bit     7, (hl)         ; test compute and display bit of CDFLAG

line 917:
    SET 0,(HL)      ; set the rightmost bit of CDFLAG.
        set     0, (hl)         ; set the rightmost bit of CDFLAG.

line 918:
    RET Z           ; return if bit 7 indicated fast mode.
        ret     z               ; return if bit 7 indicated fast mode.

line 920:
    DEC B           ; (4) decrement the counter.
        dec     b               ; (4) decrement the counter.

line 921:
    NOP         ; (4) Timing - 4 clock cycles. ??
        nop                     ; (4) Timing - 4 clock cycles. ??

line 922:
    SCF         ; (4) Set Carry Flag (+T7+T44=+T49)
        scf                     ; (4) Set Carry Flag (+T7+T44=+T49)

line 926:
    LD HL,$4027     ; (10) sv DEBOUNCE
        ld      hl, $4027       ; (10) sv DEBOUNCE

line 927:
    CCF         ; (4)  Complement Carry Flag
        ccf                     ; (4)  Complement Carry Flag

line 928:
    RL B            ; (8)  rotate left B picking up carry   (B=2*11+CY=23 if no key)
        rl      b               ; (8)  rotate left B picking up carry   (B=2*11+CY=23 if no key)

line 929:
                ;  C<-76543210<-C           (B=2*10+NC=20 else)
                                ;  C<-76543210<-C           (B=2*10+NC=20 else)

line 932:
    DJNZ L026A      ; self-loop while B>0 to LOOP-B (T=19*13+8=T255)
        djnz    L026A           ; self-loop while B>0 to LOOP-B (T=19*13+8=T255)

line 933:
                ; (VSYNC=T854+T12+T22+T255+T39=T1182)
                                ; (VSYNC=T854+T12+T22+T255+T39=T1182)

line 935:
    LD B,(HL)       ; fetch value of DEBOUNCE to B
        ld      b, (hl)         ; fetch value of DEBOUNCE to B

line 936:
    LD A,E          ; transfer column value
        ld      a, e            ; transfer column value

line 937:
    CP $FE          ;
        cp      $FE             ;

line 938:
    SBC A,A         ;
        sbc     a, a            ;

line 939:
    LD B,$1F        ;
        ld      b, $1F          ;

line 940:
    OR (HL)         ;
        or      (hl)            ;

line 941:
    AND B           ;
        and     b               ;

line 942:
    RRA         ;
        rra                     ;

line 943:
    LD (HL),A       ; (T1233)
        ld      (hl), a         ; (T1233)

line 945:
    OUT ($FF),A     ; end the TV frame synchronization pulse.
        out     ($FF), a        ; end the TV frame synchronization pulse.

line 947:
    LD HL,($400C)       ; (12) set HL to the Display File from D_FILE
        ld      hl, ($400C)     ; (12) set HL to the Display File from D_FILE

line 948:
    SET 7,H         ; (8) set bit 15 to address the echo display.
        set     7, h            ; (8) set bit 15 to address the echo display.

line 950:
    CALL L0292      ; (17) routine DISPLAY-3 displays the top set
        call    L0292           ; (17) routine DISPLAY-3 displays the top set

line 951:
                ; of blank lines.
                                ; of blank lines.

line 958:
    LD A,R          ; (9)  Harmless Nonsensical Timing or something
        ld      a, r            ; (9)  Harmless Nonsensical Timing or something

line 959:
                ; very clever?
                                ; very clever?

line 960:
    LD BC,$1901     ; (10) 25 lines, 1 scanline in first.
        ld      bc, $1901       ; (10) 25 lines, 1 scanline in first.

line 961:
    LD A,$F5        ; (7)  This value will be loaded into R and
        ld      a, $F5          ; (7)  This value will be loaded into R and

line 962:
                ; ensures that the cycle starts at the right
                                ; ensures that the cycle starts at the right

line 963:
                ; part of the display  - after 32nd character
                                ; part of the display  - after 32nd character

line 964:
                ; position.
                                ; position.

line 966:
    CALL L02B5      ; (17) routine DISPLAY-5 completes the current
        call    L02B5           ; (17) routine DISPLAY-5 completes the current

line 967:
                ; blank line and then generates the display of
                                ; blank line and then generates the display of

line 968:
                ; the live picture using INT interrupts
                                ; the live picture using INT interrupts

line 969:
                ; The final interrupt returns to the next
                                ; The final interrupt returns to the next

line 970:
                ; address.
                                ; address.

line 972:
    DEC HL          ; point HL to the last NEWLINE/HALT.
        dec     hl              ; point HL to the last NEWLINE/HALT.

line 974:
    CALL L0292      ; routine DISPLAY-3 displays the bottom set of
        call    L0292           ; routine DISPLAY-3 displays the bottom set of

line 975:
                ; blank lines.
                                ; blank lines.

line 979:
    JP L0229        ; JUMP back to DISPLAY-1
        jp      L0229           ; JUMP back to DISPLAY-1

line 990:
    POP IX          ; pop the return address to IX register.
        pop     ix              ; pop the return address to IX register.

line 991:
                ; will be either L0281 or L028F - see above.
                                ; will be either L0281 or L028F - see above.

line 993:
    LD C,(IY+$28)       ; load C with value of system constant MARGIN.
        ld      c, (iy+$28)     ; load C with value of system constant MARGIN.

line 994:
    BIT 7,(IY+$3B)      ; test CDFLAG for compute and display.
        bit     7, (iy+$3B)     ; test CDFLAG for compute and display.

line 995:
    JR Z,L02A9      ; forward, with FAST mode, to DISPLAY-4
        jr      z, L02A9        ; forward, with FAST mode, to DISPLAY-4

line 997:
    LD A,C          ; move MARGIN to A - 31d or 55d.
        ld      a, c            ; move MARGIN to A - 31d or 55d.

line 998:
    NEG         ; Negate
        neg                     ; Negate

line 999:
    INC A           ;
        inc     a               ;

line 1000:
    EX AF,AF'       ; place negative count of blank lines in A'
        ex      af, af'       ; place negative count of blank lines in A'

line 1002:
    OUT ($FE),A     ; enable the NMI generator.
        out     ($FE), a        ; enable the NMI generator.

line 1004:
    POP HL          ; ****
        pop     hl              ; ****

line 1005:
    POP DE          ; ***
        pop     de              ; ***

line 1006:
    POP BC          ; **
        pop     bc              ; **

line 1007:
    POP AF          ; *  Restore Main Registers
        pop     af              ; *  Restore Main Registers

line 1009:
    RET             ; return - end of interrupt.  Return is to
        ret                     ; return - end of interrupt.  Return is to

line 1010:
                ; user's program - BASIC or machine code.
                                ; user's program - BASIC or machine code.

line 1011:
                ; which will be interrupted by every NMI.
                                ; which will be interrupted by every NMI.

line 1018:
    LD A,$FC        ; (7)  load A with first R delay value
        ld      a, $FC          ; (7)  load A with first R delay value

line 1019:
    LD B,$01        ; (7)  one row only.
        ld      b, $01          ; (7)  one row only.

line 1021:
    CALL L02B5      ; (17) routine DISPLAY-5
        call    L02B5           ; (17) routine DISPLAY-5

line 1023:
    DEC HL          ; (6)  point back to the HALT.
        dec     hl              ; (6)  point back to the HALT.

line 1024:
    EX (SP),HL      ; (19) Harmless Nonsensical Timing if paired.
        ex      (sp), hl        ; (19) Harmless Nonsensical Timing if paired.

line 1025:
    EX (SP),HL      ; (19) Harmless Nonsensical Timing.
        ex      (sp), hl        ; (19) Harmless Nonsensical Timing.

line 1026:
    JP (IX)         ; (8)  to L0281 or L028F
        jp      (ix)            ; (8)  to L0281 or L028F

line 1039:
    LD R,A          ; (9) Load R from A.    R = slow: $F5 fast: $FC
        ld      r, a            ; (9) Load R from A.    R = slow: $F5 fast: $FC

line 1040:
    LD A,$DD        ; (7) load future R value.    $F6       $FD
        ld      a, $DD          ; (7) load future R value.    $F6       $FD

line 1042:
    EI          ; (4) Enable Interrupts       $F7       $FE
        ei                      ; (4) Enable Interrupts       $F7       $FE

line 1044:
    JP (HL)         ; (4) jump to the echo display.   $F8       $FF
        jp      (hl)            ; (4) jump to the echo display.   $F8       $FF

line 1055:
    LD HL,$FFFF     ; (16) prepare a buffer to take key.
        ld      hl, $FFFF       ; (16) prepare a buffer to take key.

line 1056:
    LD BC,$FEFE     ; (20) set BC to port $FEFE. The B register,
        ld      bc, $FEFE       ; (20) set BC to port $FEFE. The B register,

line 1057:
                ; with its single reset bit also acts as
                                ; with its single reset bit also acts as

line 1058:
                ; an 8-counter.
                                ; an 8-counter.

line 1059:
    IN A,(C)        ; (12) read the port - all 16 bits are put on
        in      a, (c)          ; (12) read the port - all 16 bits are put on

line 1060:
                ; the address bus.  Start VSYNC pulse.
                                ; the address bus.  Start VSYNC pulse.

line 1061:
    OR $01          ; (7)  set the rightmost bit so as to ignore
        or      $01             ; (7)  set the rightmost bit so as to ignore

line 1062:
                ; the SHIFT key.
                                ; the SHIFT key.

line 1065:
    OR $E0          ; [7] OR %11100000
        or      $E0             ; [7] OR %11100000

line 1066:
    LD D,A          ; [4] transfer to D.
        ld      d, a            ; [4] transfer to D.

line 1067:
    CPL         ; [4] complement - only bits 4-0 meaningful now.
        cpl                     ; [4] complement - only bits 4-0 meaningful now.

line 1068:
    CP $01          ; [7] sets carry if A is zero.
        cp      $01             ; [7] sets carry if A is zero.

line 1069:
    SBC A,A         ; [4] $FF if $00 else zero.
        sbc     a, a            ; [4] $FF if $00 else zero.

line 1070:
    OR B            ; [7] $FF or port FE,FD,FB....
        or      b               ; [7] $FF or port FE,FD,FB....

line 1071:
    AND L           ; [4] unless more than one key, L will still be
        and     l               ; [4] unless more than one key, L will still be

line 1072:
                ;     $FF. if more than one key is pressed then A is
                                ;     $FF. if more than one key is pressed then A is

line 1073:
                ;     now invalid.
                                ;     now invalid.

line 1074:
    LD L,A          ; [4] transfer to L.
        ld      l, a            ; [4] transfer to L.

line 1078:
    LD A,H          ; [4] will be $FF if no previous keys.
        ld      a, h            ; [4] will be $FF if no previous keys.

line 1079:
    AND D           ; [4] 111xxxxx
        and     d               ; [4] 111xxxxx

line 1080:
    LD H,A          ; [4] transfer A to H
        ld      h, a            ; [4] transfer A to H

line 1086:
    RLC B           ; [8]  rotate the 8-counter/port address.
        rlc     b               ; [8]  rotate the 8-counter/port address.

line 1087:
                ; sets carry if more to do.
                                ; sets carry if more to do.

line 1088:
    IN A,(C)        ; [10] read another half-row.
        in      a, (c)          ; [10] read another half-row.

line 1089:
                ; all five bits this time. (T70)
                                ; all five bits this time. (T70)

line 1091:
    JR C,L02C5      ; [12](7) loop back, until done, to EACH-LINE
        jr      c, L02C5        ; [12](7) loop back, until done, to EACH-LINE

line 1092:
                ; (7*T82+T77=T651)
                                ; (7*T82+T77=T651)

line 1096:
    RRA         ; (4) test the shift key - carry will be reset
        rra                     ; (4) test the shift key - carry will be reset

line 1097:
                ;   if the key is pressed.
                                ;   if the key is pressed.

line 1098:
    RL H            ; (8) rotate left H picking up the carry giving
        rl      h               ; (8) rotate left H picking up the carry giving

line 1099:
                ;   column values -
                                ;   column values -

line 1100:
                ;   $FD, $FB, $F7, $EF, $DF.
                                ;   $FD, $FB, $F7, $EF, $DF.

line 1101:
                ;   or $FC, $FA, $F6, $EE, $DE if shifted.
                                ;   or $FC, $FA, $F6, $EE, $DE if shifted.

line 1110:
    RLA         ; (4) compensate for the shift test.
        rla                     ; (4) compensate for the shift test.

line 1111:
    RLA         ; (4) rotate bit 7 out.
        rla                     ; (4) rotate bit 7 out.

line 1112:
    RLA         ; (4) test bit 6.
        rla                     ; (4) test bit 6.

line 1114:
    SBC A,A         ; (4)   $FF or $00 {USA}
        sbc     a, a            ; (4)   $FF or $00 {USA}

line 1115:
    AND $18         ; (7)   $18 or $00
        and     $18             ; (7)   $18 or $00

line 1116:
    ADD A,$1F       ; (7)   $37 or $1F
        add     a, $1F          ; (7)   $37 or $1F

line 1121:
    LD ($4028),A        ; (13) update system variable MARGIN
        ld      ($4028), a      ; (13) update system variable MARGIN

line 1123:
    RET             ; (10) return
        ret                     ; (10) return

line 1124:
                ; (T_VSYNC=T19+T651+T65=T735)
                                ; (T_VSYNC=T19+T651+T65=T735)

line 1132:
    BIT 7,(IY+$3B)      ; test slow mode (CDFLAG)
        bit     7, (iy+$3B)     ; test slow mode (CDFLAG)

line 1133:
    RET Z           ; return in case of fast mode
        ret     z               ; return in case of fast mode

line 1135:
    HALT            ; else wait for Interrupt
        halt                    ; else wait for Interrupt

line 1136:
    OUT ($FD),A     ; switch off NMI (fast mode)
        out     ($FD), a        ; switch off NMI (fast mode)

line 1137:
    RES 7,(IY+$3B)      ; reset CDFLAG
        res     7, (iy+$3B)     ; reset CDFLAG

line 1138:
    RET             ; return.
        ret                     ; return.

line 1146:
    RST 08H         ; ERROR-1
        rst     08H             ; ERROR-1

line 1147:
    DEFB $0E        ; Error Report: No Program Name supplied.
        defb    $0E             ; Error Report: No Program Name supplied.

line 1155:
    CALL L03A8      ; routine NAME
        call    L03A8           ; routine NAME

line 1156:
    JR C,L02F4      ; back with null name to REPORT-F above.
        jr      c, L02F4        ; back with null name to REPORT-F above.

line 1158:
    EX DE,HL        ;
        ex      de, hl          ;

line 1159:
    LD DE,$12CB     ; five seconds timing value
        ld      de, $12CB       ; five seconds timing value

line 1163:
    CALL L0F46      ; routine BREAK-1
        call    L0F46           ; routine BREAK-1

line 1164:
    JR NC,L0332     ; to BREAK-2
        jr      nc, L0332       ; to BREAK-2

line 1168:
    DJNZ L0304      ; to DELAY-1
        djnz    L0304           ; to DELAY-1

line 1170:
    DEC DE          ;
        dec     de              ;

line 1171:
    LD A,D          ;
        ld      a, d            ;

line 1172:
    OR E            ;
        or      e               ;

line 1173:
    JR NZ,L02FF     ; back for delay to HEADER
        jr      nz, L02FF       ; back for delay to HEADER

line 1177:
    CALL L031E      ; routine OUT-BYTE
        call    L031E           ; routine OUT-BYTE

line 1178:
    BIT 7,(HL)      ; test for inverted bit.
        bit     7, (hl)         ; test for inverted bit.

line 1179:
    INC HL          ; address next character of name.
        inc     hl              ; address next character of name.

line 1180:
    JR Z,L030B      ; back if not inverted to OUT-NAME
        jr      z, L030B        ; back if not inverted to OUT-NAME

line 1184:
    LD HL,$4009     ; set start of area to VERSN thereby
        ld      hl, $4009       ; set start of area to VERSN thereby

line 1185:
                ; preserving RAMTOP etc.
                                ; preserving RAMTOP etc.

line 1188:
    CALL L031E      ; routine OUT-BYTE
        call    L031E           ; routine OUT-BYTE

line 1190:
    CALL L01FC      ; routine LOAD/SAVE         >>
        call    L01FC           ; routine LOAD/SAVE         >>

line 1192:
    JR L0316        ; loop back to OUT-PROG
        jr      L0316           ; loop back to OUT-PROG

line 1201:
    LD E,(HL)       ; fetch byte to be saved.
        ld      e, (hl)         ; fetch byte to be saved.

line 1202:
    SCF         ; set carry flag - as a marker.
        scf                     ; set carry flag - as a marker.

line 1206:
    RL E            ;  C < 76543210 < C
        rl      e               ;  C < 76543210 < C

line 1207:
    RET Z           ; return when the marker bit has passed
        ret     z               ; return when the marker bit has passed

line 1208:
                ; right through.            >>
                                ; right through.            >>

line 1210:
    SBC A,A         ; $FF if set bit or $00 with no carry.
        sbc     a, a            ; $FF if set bit or $00 with no carry.

line 1211:
    AND $05         ; $05           $00
        and     $05             ; $05           $00

line 1212:
    ADD A,$04       ; $09           $04
        add     a, $04          ; $09           $04

line 1213:
    LD C,A          ; transfer timer to C. a set bit has a longer
        ld      c, a            ; transfer timer to C. a set bit has a longer

line 1214:
                ; pulse than a reset bit.
                                ; pulse than a reset bit.

line 1217:
    OUT ($FF),A     ; pulse to cassette.
        out     ($FF), a        ; pulse to cassette.

line 1218:
    LD B,$23        ; set timing constant
        ld      b, $23          ; set timing constant

line 1222:
    DJNZ L032D      ; self-loop to DELAY-2
        djnz    L032D           ; self-loop to DELAY-2

line 1224:
    CALL L0F46      ; routine BREAK-1 test for BREAK key.
        call    L0F46           ; routine BREAK-1 test for BREAK key.

line 1228:
    JR NC,L03A6     ; forward with break to REPORT-D
        jr      nc, L03A6       ; forward with break to REPORT-D

line 1230:
    LD B,$1E        ; set timing value.
        ld      b, $1E          ; set timing value.

line 1234:
    DJNZ L0336      ; self-loop to DELAY-3
        djnz    L0336           ; self-loop to DELAY-3

line 1236:
    DEC C           ; decrement counter
        dec     c               ; decrement counter

line 1237:
    JR NZ,L0329     ; loop back to PULSES
        jr      nz, L0329       ; loop back to PULSES

line 1240:
L033B:  AND A           ; clear carry for next bit test.
L033B:  and a                   ; clear carry for next bit test.

line 1241:
    DJNZ L033B      ; self loop to DELAY-4 (B is zero - 256)
        djnz    L033B           ; self loop to DELAY-4 (B is zero - 256)

line 1243:
    JR L0320        ; loop back to EACH-BIT
        jr      L0320           ; loop back to EACH-BIT

line 1251:
    CALL L03A8      ; routine NAME
        call    L03A8           ; routine NAME

line 1255:
    RL D            ; pick up carry
        rl      d               ; pick up carry

line 1256:
    RRC D           ; carry now in bit 7.
        rrc     d               ; carry now in bit 7.

line 1260:
    CALL L034C      ; routine IN-BYTE
        call    L034C           ; routine IN-BYTE

line 1261:
    JR L0347        ; loop to NEXT-PROG
        jr      L0347           ; loop to NEXT-PROG

line 1269:
    LD C,$01        ; prepare an eight counter 00000001.
        ld      c, $01          ; prepare an eight counter 00000001.

line 1273:
    LD B,$00        ; set counter to 256
        ld      b, $00          ; set counter to 256

line 1277:
    LD A,$7F        ; read the keyboard row
        ld      a, $7F          ; read the keyboard row

line 1278:
    IN A,($FE)      ; with the SPACE key.
        in      a, ($FE)        ; with the SPACE key.

line 1280:
    OUT ($FF),A     ; output signal to screen.
        out     ($FF), a        ; output signal to screen.

line 1282:
    RRA         ; test for SPACE pressed.
        rra                     ; test for SPACE pressed.

line 1283:
    JR NC,L03A2     ; forward if so to BREAK-4
        jr      nc, L03A2       ; forward if so to BREAK-4

line 1285:
    RLA         ; reverse above rotation
        rla                     ; reverse above rotation

line 1286:
    RLA         ; test tape bit.
        rla                     ; test tape bit.

line 1287:
    JR C,L0385      ; forward if set to GET-BIT
        jr      c, L0385        ; forward if set to GET-BIT

line 1289:
    DJNZ L0350      ; loop back to BREAK-3
        djnz    L0350           ; loop back to BREAK-3

line 1291:
    POP AF          ; drop the return address.
        pop     af              ; drop the return address.

line 1292:
    CP D            ; ugh.
        cp      d               ; ugh.

line 1296:
    JP NC,L03E5     ; jump forward to INITIAL if D is zero
        jp      nc, L03E5       ; jump forward to INITIAL if D is zero

line 1297:
                ; to reset the system
                                ; to reset the system

line 1298:
                ; if the tape signal has timed out for example
                                ; if the tape signal has timed out for example

line 1299:
                ; if the tape is stopped. Not just a simple
                                ; if the tape is stopped. Not just a simple

line 1300:
                ; report as some system variables will have
                                ; report as some system variables will have

line 1301:
                ; been overwritten.
                                ; been overwritten.

line 1303:
    LD H,D          ; else transfer the start of name
        ld      h, d            ; else transfer the start of name

line 1304:
    LD L,E          ; to the HL register
        ld      l, e            ; to the HL register

line 1308:
    CALL L034C      ; routine IN-BYTE is sort of recursion for name
        call    L034C           ; routine IN-BYTE is sort of recursion for name

line 1309:
                ; part. received byte in C.
                                ; part. received byte in C.

line 1310:
    BIT 7,D         ; is name the null string ?
        bit     7, d            ; is name the null string ?

line 1311:
    LD A,C          ; transfer byte to A.
        ld      a, c            ; transfer byte to A.

line 1312:
    JR NZ,L0371     ; forward with null string to MATCHING
        jr      nz, L0371       ; forward with null string to MATCHING

line 1314:
    CP (HL)         ; else compare with string in memory.
        cp      (hl)            ; else compare with string in memory.

line 1315:
    JR NZ,L0347     ; back with mis-match to NEXT-PROG
        jr      nz, L0347       ; back with mis-match to NEXT-PROG

line 1316:
                ; (seemingly out of subroutine but return
                                ; (seemingly out of subroutine but return

line 1317:
                ; address has been dropped).
                                ; address has been dropped).

line 1320:
    INC HL          ; address next character of name
        inc     hl              ; address next character of name

line 1321:
    RLA         ; test for inverted bit.
        rla                     ; test for inverted bit.

line 1322:
    JR NC,L0366     ; back if not to IN-NAME
        jr      nc, L0366       ; back if not to IN-NAME

line 1330:
    INC (IY+$15)        ; increment system variable E_LINE_hi.
        inc     (iy+$15)        ; increment system variable E_LINE_hi.

line 1331:
    LD HL,$4009     ; start loading at system variable VERSN.
        ld      hl, $4009       ; start loading at system variable VERSN.

line 1335:
    LD D,B          ; set D to zero as indicator.
        ld      d, b            ; set D to zero as indicator.

line 1336:
    CALL L034C      ; routine IN-BYTE loads a byte
        call    L034C           ; routine IN-BYTE loads a byte

line 1338:
    LD (HL),C       ; insert assembled byte in memory.
        ld      (hl), c         ; insert assembled byte in memory.

line 1339:
    CALL L01FC      ; routine LOAD/SAVE         >>
        call    L01FC           ; routine LOAD/SAVE         >>

line 1341:
    JR L037B        ; loop back to IN-PROG
        jr      L037B           ; loop back to IN-PROG

line 1349:
    PUSH DE         ; save the
        push    de              ; save the

line 1350:
    LD E,$94        ; timing value.
        ld      e, $94          ; timing value.

line 1354:
    LD B,$1A        ; counter to twenty six.
        ld      b, $1A          ; counter to twenty six.

line 1358:
    DEC E           ; decrement the measuring timer.
        dec     e               ; decrement the measuring timer.

line 1359:
    IN A,($FE)      ; read the
        in      a, ($FE)        ; read the

line 1360:
    RLA         ;
        rla                     ;

line 1361:
    BIT 7,E         ;
        bit     7, e            ;

line 1362:
    LD A,E          ;
        ld      a, e            ;

line 1363:
    JR C,L0388      ; loop back with carry to TRAILER
        jr      c, L0388        ; loop back with carry to TRAILER

line 1365:
    DJNZ L038A      ; to COUNTER
        djnz    L038A           ; to COUNTER

line 1367:
    POP DE          ;
        pop     de              ;

line 1368:
    JR NZ,L039C     ; to BIT-DONE
        jr      nz, L039C       ; to BIT-DONE

line 1370:
    CP $56          ;
        cp      $56             ;

line 1371:
    JR NC,L034E     ; to NEXT-BIT
        jr      nc, L034E       ; to NEXT-BIT

line 1375:
    CCF         ; complement carry flag
        ccf                     ; complement carry flag

line 1376:
    RL C            ;
        rl      c               ;

line 1377:
    JR NC,L034E     ; to NEXT-BIT
        jr      nc, L034E       ; to NEXT-BIT

line 1379:
    RET             ; return with full byte.
        ret                     ; return with full byte.

line 1387:
    LD A,D          ; transfer indicator to A.
        ld      a, d            ; transfer indicator to A.

line 1388:
    AND A           ; test for zero.
        and     a               ; test for zero.

line 1389:
    JR Z,L0361      ; back if so to RESTART
        jr      z, L0361        ; back if so to RESTART

line 1393:
    RST 08H         ; ERROR-1
        rst     08H             ; ERROR-1

line 1394:
    DEFB $0C        ; Error Report: BREAK - CONT repeats
        defb    $0C             ; Error Report: BREAK - CONT repeats

line 1402:
    CALL SCANNING       ; routine SCANNING
        call    SCANNING        ; routine SCANNING

line 1403:
    LD A,($4001)        ; sv FLAGS
        ld      a, ($4001)      ; sv FLAGS

line 1404:
    ADD A,A         ;
        add     a, a            ;

line 1405:
    JP M,L0D9A      ; to REPORT-C
        jp      m, L0D9A        ; to REPORT-C

line 1407:
    POP HL          ;
        pop     hl              ;

line 1408:
    RET NC          ;
        ret     nc              ;

line 1410:
    PUSH HL         ;
        push    hl              ;

line 1411:
    CALL L02E7      ; routine SET-FAST
        call    L02E7           ; routine SET-FAST

line 1413:
    CALL STK_FETCH      ; routine STK-FETCH
        call    STK_FETCH       ; routine STK-FETCH

line 1415:
    LD H,D          ;
        ld      h, d            ;

line 1416:
    LD L,E          ;
        ld      l, e            ;

line 1417:
    DEC C           ;
        dec     c               ;

line 1418:
    RET M           ;
        ret     m               ;

line 1420:
    ADD HL,BC       ;
        add     hl, bc          ;

line 1421:
    SET 7,(HL)      ;
        set     7, (hl)         ;

line 1422:
    RET             ;
        ret                     ;

line 1430:
    CALL L02E7      ; routine SET-FAST
        call    L02E7           ; routine SET-FAST

line 1432:
    LD BC,($4004)       ; fetch value of system variable RAMTOP
        ld      bc, ($4004)     ; fetch value of system variable RAMTOP

line 1433:
    DEC BC          ; point to last system byte.
        dec     bc              ; point to last system byte.

line 1441:
    LD H,B          ;
        ld      h, b            ;

line 1442:
    LD L,C          ;
        ld      l, c            ;

line 1443:
    LD A,$3F        ;
        ld      a, $3F          ;

line 1447:
    LD (HL),$02     ;
        ld      (hl), $02       ;

line 1448:
    DEC HL          ;
        dec     hl              ;

line 1449:
    CP H            ;
        cp      h               ;

line 1450:
    JR NZ,L03CF     ; to RAM-FILL
        jr      nz, L03CF       ; to RAM-FILL

line 1454:
    AND A           ;
        and     a               ;

line 1455:
    SBC HL,BC       ;
        sbc     hl, bc          ;

line 1456:
    ADD HL,BC       ;
        add     hl, bc          ;

line 1457:
    INC HL          ;
        inc     hl              ;

line 1458:
    JR NC,L03E2     ; to SET-TOP
        jr      nc, L03E2       ; to SET-TOP

line 1460:
    DEC (HL)        ;
        dec     (hl)            ;

line 1461:
    JR Z,L03E2      ; to SET-TOP
        jr      z, L03E2        ; to SET-TOP

line 1463:
    DEC (HL)        ;
        dec     (hl)            ;

line 1464:
    JR Z,L03D5      ; to RAM-READ
        jr      z, L03D5        ; to RAM-READ

line 1468:
    LD ($4004),HL       ; set system variable RAMTOP to first byte
        ld      ($4004), hl     ; set system variable RAMTOP to first byte

line 1469:
                ; above the BASIC system area.
                                ; above the BASIC system area.

line 1475:
L03E5:  LD HL,($4004)       ; fetch system variable RAMTOP.
L03E5:  ld hl, ($4004)          ; fetch system variable RAMTOP.

line 1476:
    DEC HL          ; point to last system byte.
        dec     hl              ; point to last system byte.

line 1477:
    LD (HL),$3E     ; make GOSUB end-marker $3E - too high for
        ld      (hl), $3E       ; make GOSUB end-marker $3E - too high for

line 1478:
                ; high order byte of line number.
                                ; high order byte of line number.

line 1479:
                ; (was $3F on ZX80)
                                ; (was $3F on ZX80)

line 1480:
    DEC HL          ; point to unimportant low-order byte.
        dec     hl              ; point to unimportant low-order byte.

line 1481:
    LD SP,HL        ; and initialize the stack-pointer to this
        ld      sp, hl          ; and initialize the stack-pointer to this

line 1482:
                ; location.
                                ; location.

line 1483:
    DEC HL          ; point to first location on the machine stack
        dec     hl              ; point to first location on the machine stack

line 1484:
    DEC HL          ; which will be filled by next CALL/PUSH.
        dec     hl              ; which will be filled by next CALL/PUSH.

line 1485:
    LD ($4002),HL       ; set the error stack pointer ERR_SP to
        ld      ($4002), hl     ; set the error stack pointer ERR_SP to

line 1486:
                ; the base of the now empty machine stack.
                                ; the base of the now empty machine stack.

line 1494:
    LD A,$1E        ; address for this ROM is $1E00.
        ld      a, $1E          ; address for this ROM is $1E00.

line 1495:
    LD I,A          ; set I register from A.
        ld      i, a            ; set I register from A.

line 1496:
    IM 1            ; select Z80 Interrupt Mode 1.
        im      1               ; select Z80 Interrupt Mode 1.

line 1498:
    LD IY,$4000     ; set IY to the start of RAM so that the
        ld      iy, $4000       ; set IY to the start of RAM so that the

line 1499:
                ; system variables can be indexed.
                                ; system variables can be indexed.

line 1500:
    LD (IY+$3B),$40     ; set CDFLAG 0100 0000. Bit 6 indicates
        ld      (iy+$3B), $40   ; set CDFLAG 0100 0000. Bit 6 indicates

line 1501:
                ; Compute and Display required.
                                ; Compute and Display required.

line 1503:
    LD HL,$407D     ; The first location after System Variables -
        ld      hl, $407D       ; The first location after System Variables -

line 1504:
                ; 16509 decimal.
                                ; 16509 decimal.

line 1505:
    LD ($400C),HL       ; set system variable D_FILE to this value.
        ld      ($400C), hl     ; set system variable D_FILE to this value.

line 1506:
    LD B,$19        ; prepare minimal screen of 24 NEWLINEs
        ld      b, $19          ; prepare minimal screen of 24 NEWLINEs

line 1507:
                ; following an initial NEWLINE.
                                ; following an initial NEWLINE.

line 1509:
L0408:  LD (HL),$76     ; insert NEWLINE (HALT instruction)
L0408:  ld (hl), $76            ; insert NEWLINE (HALT instruction)

line 1510:
    INC HL          ; point to next location.
        inc     hl              ; point to next location.

line 1511:
    DJNZ L0408      ; loop back for all twenty five to LINE
        djnz    L0408           ; loop back for all twenty five to LINE

line 1513:
    LD ($4010),HL       ; set system variable VARS to next location
        ld      ($4010), hl     ; set system variable VARS to next location

line 1515:
    CALL L149A      ; routine CLEAR sets $80 end-marker and the
        call    L149A           ; routine CLEAR sets $80 end-marker and the

line 1516:
                ; dynamic memory pointers E_LINE, STKBOT and
                                ; dynamic memory pointers E_LINE, STKBOT and

line 1517:
                ; STKEND.
                                ; STKEND.

line 1519:
L0413:  CALL L14AD      ; routine CURSOR-IN inserts the cursor and
L0413:  call L14AD              ; routine CURSOR-IN inserts the cursor and

line 1520:
                ; end-marker in the Edit Line also setting
                                ; end-marker in the Edit Line also setting

line 1521:
                ; size of lower display to two lines.
                                ; size of lower display to two lines.

line 1523:
    CALL L0207      ; routine SLOW/FAST selects COMPUTE and DISPLAY
        call    L0207           ; routine SLOW/FAST selects COMPUTE and DISPLAY

line 1530:
L0419:  CALL L0A2A      ; routine CLS
L0419:  call L0A2A              ; routine CLS

line 1531:
    LD HL,($400A)       ; sv E_PPC
        ld      hl, ($400A)     ; sv E_PPC

line 1532:
    LD DE,($4023)       ; sv S_TOP
        ld      de, ($4023)     ; sv S_TOP

line 1533:
    AND A           ;
        and     a               ;

line 1534:
    SBC HL,DE       ;
        sbc     hl, de          ;

line 1535:
    EX DE,HL        ;
        ex      de, hl          ;

line 1536:
    JR NC,L042D     ; to ADDR-TOP
        jr      nc, L042D       ; to ADDR-TOP

line 1538:
    ADD HL,DE       ;
        add     hl, de          ;

line 1539:
    LD ($4023),HL       ; sv S_TOP
        ld      ($4023), hl     ; sv S_TOP

line 1542:
L042D:  CALL L09D8      ; routine LINE-ADDR
L042D:  call L09D8              ; routine LINE-ADDR

line 1543:
    JR Z,L0433      ; to LIST-TOP
        jr      z, L0433        ; to LIST-TOP

line 1545:
    EX DE,HL        ;
        ex      de, hl          ;

line 1548:
L0433:  CALL L073E      ; routine LIST-PROG
L0433:  call L073E              ; routine LIST-PROG

line 1549:
    DEC (IY+$1E)        ; sv BERG
        dec     (iy+$1E)        ; sv BERG

line 1550:
    JR NZ,L0472     ; to LOWER
        jr      nz, L0472       ; to LOWER

line 1552:
    LD HL,($400A)       ; sv E_PPC
        ld      hl, ($400A)     ; sv E_PPC

line 1553:
    CALL L09D8      ; routine LINE-ADDR
        call    L09D8           ; routine LINE-ADDR

line 1554:
    LD HL,($4016)       ; sv CH_ADD
        ld      hl, ($4016)     ; sv CH_ADD

line 1555:
    SCF         ; Set Carry Flag
        scf                     ; Set Carry Flag

line 1556:
    SBC HL,DE       ;
        sbc     hl, de          ;

line 1557:
    LD HL,$4023     ; sv S_TOP_lo
        ld      hl, $4023       ; sv S_TOP_lo

line 1558:
    JR NC,L0457     ; to INC-LINE
        jr      nc, L0457       ; to INC-LINE

line 1560:
    EX DE,HL        ;
        ex      de, hl          ;

line 1561:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 1562:
    INC HL          ;
        inc     hl              ;

line 1563:
    LDI         ;
        ldi                     ;

line 1564:
    LD (DE),A       ;
        ld      (de), a         ;

line 1565:
    JR  L0419       ; to UPPER
        jr      L0419           ; to UPPER

line 1568:
L0454:  LD HL,$400A     ; sv E_PPC_lo
L0454:  ld hl, $400A            ; sv E_PPC_lo

line 1571:
L0457:  LD E,(HL)       ;
L0457:  ld e, (hl)              ;

line 1572:
    INC HL          ;
        inc     hl              ;

line 1573:
    LD D,(HL)       ;
        ld      d, (hl)         ;

line 1574:
    PUSH HL         ;
        push    hl              ;

line 1575:
    EX DE,HL        ;
        ex      de, hl          ;

line 1576:
    INC HL  ;
        inc     hl              ;

line 1577:
    CALL L09D8      ; routine LINE-ADDR
        call    L09D8           ; routine LINE-ADDR

line 1578:
    CALL L05BB      ; routine LINE-NO
        call    L05BB           ; routine LINE-NO

line 1579:
    POP HL          ;
        pop     hl              ;

line 1582:
L0464:  BIT 5,(IY+$2D)      ; sv FLAGX
L0464:  bit 5, (iy+$2D)         ; sv FLAGX

line 1583:
    JR NZ,L0472     ; forward to LOWER
        jr      nz, L0472       ; forward to LOWER

line 1585:
    LD (HL),D       ;
        ld      (hl), d         ;

line 1586:
    DEC HL          ;
        dec     hl              ;

line 1587:
    LD (HL),E       ;
        ld      (hl), e         ;

line 1588:
    JR L0419        ; to UPPER
        jr      L0419           ; to UPPER

line 1599:
L046F:  CALL L14AD      ; routine CURSOR-IN sets cursor only edit line.
L046F:  call L14AD              ; routine CURSOR-IN sets cursor only edit line.

line 1604:
L0472:  LD HL,($4014)       ; fetch edit line start from E_LINE.
L0472:  ld hl, ($4014)          ; fetch edit line start from E_LINE.

line 1607:
L0475:  LD A,(HL)       ; fetch a character from edit line.
L0475:  ld a, (hl)              ; fetch a character from edit line.

line 1608:
    CP $7E          ; compare to the number marker.
        cp      $7E             ; compare to the number marker.

line 1609:
    JR NZ,L0482     ; forward if not to END-LINE
        jr      nz, L0482       ; forward if not to END-LINE

line 1611:
    LD BC,$0006     ; else six invisible bytes to be removed.
        ld      bc, $0006       ; else six invisible bytes to be removed.

line 1612:
    CALL L0A60      ; routine RECLAIM-2
        call    L0A60           ; routine RECLAIM-2

line 1613:
    JR L0475        ; back to EACH-CHAR
        jr      L0475           ; back to EACH-CHAR

line 1617:
L0482:  CP $76          ;
L0482:  cp $76                  ;

line 1618:
    INC HL          ;
        inc     hl              ;

line 1619:
    JR NZ,L0475     ; to EACH-CHAR
        jr      nz, L0475       ; to EACH-CHAR

line 1622:
L0487:  CALL L0537      ; routine CURSOR sets cursor K or L.
L0487:  call L0537              ; routine CURSOR sets cursor K or L.

line 1625:
L048A:  CALL L0A1F      ; routine LINE-ENDS
L048A:  call L0A1F              ; routine LINE-ENDS

line 1626:
    LD HL,($4014)       ; sv E_LINE_lo
        ld      hl, ($4014)     ; sv E_LINE_lo

line 1627:
    LD (IY+$00),$FF     ; sv ERR_NR
        ld      (iy+$00), $FF   ; sv ERR_NR

line 1628:
    CALL L0766      ; routine COPY-LINE
        call    L0766           ; routine COPY-LINE

line 1629:
    BIT 7,(IY+$00)      ; sv ERR_NR
        bit     7, (iy+$00)     ; sv ERR_NR

line 1630:
    JR NZ,L04C1     ; to DISPLAY-6
        jr      nz, L04C1       ; to DISPLAY-6

line 1632:
    LD A,($4022)        ; sv DF_SZ
        ld      a, ($4022)      ; sv DF_SZ

line 1633:
    CP $18          ;
        cp      $18             ;

line 1634:
    JR NC,L04C1     ; to DISPLAY-6
        jr      nc, L04C1       ; to DISPLAY-6

line 1636:
    INC A           ;
        inc     a               ;

line 1637:
    LD ($4022),A        ; sv DF_SZ
        ld      ($4022), a      ; sv DF_SZ

line 1638:
    LD B,A          ;
        ld      b, a            ;

line 1639:
    LD C,$01        ;
        ld      c, $01          ;

line 1640:
    CALL L0918      ; routine LOC-ADDR
        call    L0918           ; routine LOC-ADDR

line 1641:
    LD D,H          ;
        ld      d, h            ;

line 1642:
    LD E,L          ;
        ld      e, l            ;

line 1643:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 1646:
L04B1:  DEC HL          ;
L04B1:  dec hl                  ;

line 1647:
    CP (HL)         ;
        cp      (hl)            ;

line 1648:
    JR NZ,L04B1     ; to FREE-LINE
        jr      nz, L04B1       ; to FREE-LINE

line 1650:
    INC HL          ;
        inc     hl              ;

line 1651:
    EX DE,HL        ;
        ex      de, hl          ;

line 1652:
    LD A,($4005)        ; sv RAMTOP_hi
        ld      a, ($4005)      ; sv RAMTOP_hi

line 1653:
    CP $4D  ;
        cp      $4D             ;

line 1654:
    CALL C,L0A5D        ; routine RECLAIM-1
        call    c, L0A5D        ; routine RECLAIM-1

line 1655:
    JR L048A        ; to EDIT-ROOM
        jr      L048A           ; to EDIT-ROOM

line 1662:
L04C1:  LD HL,$0000     ;
L04C1:  ld hl, $0000            ;

line 1663:
    LD ($4018),HL       ; sv X_PTR_lo
        ld      ($4018), hl     ; sv X_PTR_lo

line 1665:
    LD HL,$403B     ; system variable CDFLAG
        ld      hl, $403B       ; system variable CDFLAG

line 1666:
    BIT 7,(HL)      ;
        bit     7, (hl)         ;

line 1668:
    CALL Z,L0229        ; routine DISPLAY-1
        call    z, L0229        ; routine DISPLAY-1

line 1671:
L04CF:  BIT 0,(HL)      ;
L04CF:  bit 0, (hl)             ;

line 1672:
    JR Z,L04CF      ; to SLOW-DISP
        jr      z, L04CF        ; to SLOW-DISP

line 1674:
    LD BC,($4025)       ; sv LAST_K
        ld      bc, ($4025)     ; sv LAST_K

line 1675:
    CALL L0F4B      ; routine DEBOUNCE
        call    L0F4B           ; routine DEBOUNCE

line 1676:
    CALL L07BD      ; routine DECODE
        call    L07BD           ; routine DECODE

line 1678:
    JR NC,L0472     ; back to LOWER
        jr      nc, L0472       ; back to LOWER

line 1687:
L04DF:  LD A,($4006)        ; Fetch value of system variable MODE
L04DF:  ld a, ($4006)           ; Fetch value of system variable MODE

line 1688:
    DEC A           ; test the three values together
        dec     a               ; test the three values together

line 1690:
    JP M,L0508      ; forward, if was zero, to FETCH-2
        jp      m, L0508        ; forward, if was zero, to FETCH-2

line 1692:
    JR NZ,L04F7     ; forward, if was 2, to FETCH-1
        jr      nz, L04F7       ; forward, if was 2, to FETCH-1

line 1696:
    LD ($4006),A        ; update the system variable MODE
        ld      ($4006), a      ; update the system variable MODE

line 1698:
    DEC E           ; reduce E to range $00 - $7F
        dec     e               ; reduce E to range $00 - $7F

line 1699:
    LD A,E          ; place in A
        ld      a, e            ; place in A

line 1700:
    SUB $27         ; subtract 39 setting carry if range 00 - 38
        sub     $27             ; subtract 39 setting carry if range 00 - 38

line 1701:
    JR C,L04F2      ; forward, if so, to FUNC-BASE
        jr      c, L04F2        ; forward, if so, to FUNC-BASE

line 1703:
    LD E,A          ; else set E to reduced value
        ld      e, a            ; else set E to reduced value

line 1706:
L04F2:  LD HL,L00CC     ; address of K-FUNCT table for function keys.
L04F2:  ld hl, L00CC            ; address of K-FUNCT table for function keys.

line 1707:
    JR L0505        ; forward to TABLE-ADD
        jr      L0505           ; forward to TABLE-ADD

line 1711:
L04F7:  LD A,(HL)       ;
L04F7:  ld a, (hl)              ;

line 1712:
    CP $76          ;
        cp      $76             ;

line 1713:
    JR Z,L052B      ; to K/L-KEY
        jr      z, L052B        ; to K/L-KEY

line 1715:
    CP $40          ;
        cp      $40             ;

line 1716:
    SET 7,A         ;
        set     7, a            ;

line 1717:
    JR C,L051B      ; to ENTER
        jr      c, L051B        ; to ENTER

line 1719:
    LD HL,$00C7     ; (expr reqd)
        ld      hl, $00C7       ; (expr reqd)

line 1722:
L0505:  ADD HL,DE       ;
L0505:  add hl, de              ;

line 1723:
    JR L0515        ; to FETCH-3
        jr      L0515           ; to FETCH-3

line 1727:
L0508:  LD A,(HL)       ;
L0508:  ld a, (hl)              ;

line 1728:
    BIT 2,(IY+$01)      ; sv FLAGS  - K or L mode ?
        bit     2, (iy+$01)     ; sv FLAGS  - K or L mode ?

line 1729:
    JR NZ,L0516     ; to TEST-CURS
        jr      nz, L0516       ; to TEST-CURS

line 1731:
    ADD A,$C0       ;
        add     a, $C0          ;

line 1732:
    CP $E6          ;
        cp      $E6             ;

line 1733:
    JR NC,L0516     ; to TEST-CURS
        jr      nc, L0516       ; to TEST-CURS

line 1736:
L0515:  LD A,(HL)       ;
L0515:  ld a, (hl)              ;

line 1739:
L0516:  CP $F0          ;
L0516:  cp $F0                  ;

line 1740:
    JP PE,L052D     ; to KEY-SORT
        jp      pe, L052D       ; to KEY-SORT

line 1743:
L051B:  LD E,A          ;
L051B:  ld e, a                 ;

line 1744:
    CALL L0537      ; routine CURSOR
        call    L0537           ; routine CURSOR

line 1746:
    LD A,E          ;
        ld      a, e            ;

line 1747:
    CALL L0526      ; routine ADD-CHAR
        call    L0526           ; routine ADD-CHAR

line 1750:
L0523:  JP L0472        ; back to LOWER
L0523:  jp L0472                ; back to LOWER

line 1757:
L0526:  CALL L099B      ; routine ONE-SPACE
L0526:  call L099B              ; routine ONE-SPACE

line 1758:
    LD (DE),A       ;
        ld      (de), a         ;

line 1759:
    RET             ;
        ret                     ;

line 1766:
L052B:  LD A,$78        ;
L052B:  ld a, $78               ;

line 1769:
L052D:  LD E,A          ;
L052D:  ld e, a                 ;

line 1770:
    LD HL,$0482     ; base address of ED-KEYS (exp reqd)
        ld      hl, $0482       ; base address of ED-KEYS (exp reqd)

line 1771:
    ADD HL,DE       ;
        add     hl, de          ;

line 1772:
    ADD HL,DE       ;
        add     hl, de          ;

line 1773:
    LD C,(HL)       ;
        ld      c, (hl)         ;

line 1774:
    INC HL          ;
        inc     hl              ;

line 1775:
    LD B,(HL)       ;
        ld      b, (hl)         ;

line 1776:
    PUSH BC         ;
        push    bc              ;

line 1779:
L0537:  LD HL,($4014)       ; sv E_LINE_lo
L0537:  ld hl, ($4014)          ; sv E_LINE_lo

line 1780:
    BIT 5,(IY+$2D)      ; sv FLAGX
        bit     5, (iy+$2D)     ; sv FLAGX

line 1781:
    JR NZ,L0556     ; to L-MODE
        jr      nz, L0556       ; to L-MODE

line 1784:
L0540:  RES 2,(IY+$01)      ; sv FLAGS  - Signal use K mode
L0540:  res 2, (iy+$01)         ; sv FLAGS  - Signal use K mode

line 1787:
L0544:  LD A,(HL)       ;
L0544:  ld a, (hl)              ;

line 1788:
    CP $7F          ;
        cp      $7F             ;

line 1789:
    RET Z           ; return
        ret     z               ; return

line 1791:
    INC HL          ;
        inc     hl              ;

line 1792:
    CALL L07B4      ; routine NUMBER
        call    L07B4           ; routine NUMBER

line 1793:
    JR Z,L0544      ; to TEST-CHAR
        jr      z, L0544        ; to TEST-CHAR

line 1795:
    CP $26          ;
        cp      $26             ;

line 1796:
    JR C,L0544      ; to TEST-CHAR
        jr      c, L0544        ; to TEST-CHAR

line 1798:
    CP $DE          ;
        cp      $de             ;

line 1799:
    JR Z,L0540      ; to K-MODE
        jr      z, L0540        ; to K-MODE

line 1802:
L0556:  SET 2,(IY+$01)      ; sv FLAGS  - Signal use L mode
L0556:  set 2, (iy+$01)         ; sv FLAGS  - Signal use L mode

line 1803:
    JR L0544        ; to TEST-CHAR
        jr      L0544           ; to TEST-CHAR

line 1810:
L055C:  LD BC,$0001     ;
L055C:  ld bc, $0001            ;

line 1811:
    JP L0A60        ; to RECLAIM-2
        jp      L0A60           ; to RECLAIM-2

line 1818:
L0562:  DEFW L059F  ; Address: $059F ; Address: UP-KEY
L0562:  defw L059F              ; Address: $059F ; Address: UP-KEY

line 1819:
    DEFW L0454  ; Address: $0454 ; Address: DOWN-KEY
        defw    L0454           ; Address: $0454 ; Address: DOWN-KEY

line 1820:
    DEFW L0576  ; Address: $0576 ; Address: LEFT-KEY
        defw    L0576           ; Address: $0576 ; Address: LEFT-KEY

line 1821:
    DEFW L057F  ; Address: $057F ; Address: RIGHT-KEY
        defw    L057F           ; Address: $057F ; Address: RIGHT-KEY

line 1822:
    DEFW L05AF  ; Address: $05AF ; Address: FUNCTION
        defw    L05AF           ; Address: $05AF ; Address: FUNCTION

line 1823:
    DEFW L05C4  ; Address: $05C4 ; Address: EDIT-KEY
        defw    L05C4           ; Address: $05C4 ; Address: EDIT-KEY

line 1824:
    DEFW L060C  ; Address: $060C ; Address: N/L-KEY
        defw    L060C           ; Address: $060C ; Address: N/L-KEY

line 1825:
    DEFW L058B  ; Address: $058B ; Address: RUBOUT
        defw    L058B           ; Address: $058B ; Address: RUBOUT

line 1826:
    DEFW L05AF  ; Address: $05AF ; Address: FUNCTION
        defw    L05AF           ; Address: $05AF ; Address: FUNCTION

line 1827:
    DEFW L05AF  ; Address: $05AF ; Address: FUNCTION
        defw    L05AF           ; Address: $05AF ; Address: FUNCTION

line 1834:
L0576:  CALL L0593      ; routine LEFT-EDGE
L0576:  call L0593              ; routine LEFT-EDGE

line 1835:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 1836:
    LD (HL),$7F     ;
        ld      (hl), $7F       ;

line 1837:
    INC HL          ;
        inc     hl              ;

line 1838:
    JR L0588        ; to GET-CODE
        jr      L0588           ; to GET-CODE

line 1845:
L057F:  INC HL          ;
L057F:  inc hl                  ;

line 1846:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 1847:
    CP $76  ;
        cp      $76             ;

line 1848:
    JR Z,L059D      ; to ENDED-2
        jr      z, L059D        ; to ENDED-2

line 1850:
    LD (HL),$7F     ;
        ld      (hl), $7F       ;

line 1851:
    DEC HL          ;
        dec     hl              ;

line 1854:
L0588:  LD (HL),A       ;
L0588:  ld (hl), a              ;

line 1857:
L0589:  JR L0523        ; to BACK-NEXT
L0589:  jr L0523                ; to BACK-NEXT

line 1864:
L058B:  CALL L0593      ; routine LEFT-EDGE
L058B:  call L0593              ; routine LEFT-EDGE

line 1865:
    CALL L055C      ; routine CLEAR-ONE
        call    L055C           ; routine CLEAR-ONE

line 1866:
    jr L0523        ; to BACK-NEXT
        jr      L0523           ; to BACK-NEXT

line 1873:
L0593:  DEC HL          ;
L0593:  dec hl                  ;

line 1874:
    LD DE,($4014)       ; sv E_LINE_lo
        ld      de, ($4014)     ; sv E_LINE_lo

line 1875:
    LD A,(DE)       ;
        ld      a, (de)         ;

line 1876:
    CP $7F          ;
        cp      $7F             ;

line 1877:
    RET NZ          ;
        ret     nz              ;

line 1879:
    POP DE          ;
        pop     de              ;

line 1883:
    jr L0523        ; to BACK-NEXT
        jr      L0523           ; to BACK-NEXT

line 1890:
L059F:  LD HL,($400A)       ; sv E_PPC_lo
L059F:  ld hl, ($400A)          ; sv E_PPC_lo

line 1891:
    CALL L09D8      ; routine LINE-ADDR
        call    L09D8           ; routine LINE-ADDR

line 1892:
    EX DE,HL        ;
        ex      de, hl          ;

line 1893:
    CALL L05BB      ; routine LINE-NO
        call    L05BB           ; routine LINE-NO

line 1894:
    LD HL,$400B     ; point to system variable E_PPC_hi
        ld      hl, $400B       ; point to system variable E_PPC_hi

line 1895:
    JP L0464        ; jump back to KEY-INPUT
        jp      L0464           ; jump back to KEY-INPUT

line 1902:
L05AF:  LD A,E          ;
L05AF:  ld a, e                 ;

line 1903:
    AND $07         ;
        and     $07             ;

line 1904:
    LD ($4006),A        ; sv MODE
        ld      ($4006), a      ; sv MODE

line 1905:
    JR L059D        ; back to ENDED-2
        jr      L059D           ; back to ENDED-2

line 1912:
L05B7:  EX DE,HL        ;
L05B7:  ex de, hl               ;

line 1913:
    LD DE,L04C1 + 1     ; $04C2 - a location addressing two zeros.
        ld      de, L04C1 + 1   ; $04C2 - a location addressing two zeros.

line 1917:
L05BB:  LD A,(HL)       ;
L05BB:  ld a, (hl)              ;

line 1918:
    AND $C0  ;
        and     $C0             ;

line 1919:
    JR NZ,L05B7     ; to ZERO-DE
        jr      nz, L05B7       ; to ZERO-DE

line 1921:
    LD D,(HL)       ;
        ld      d, (hl)         ;

line 1922:
    INC HL          ;
        inc     hl              ;

line 1923:
    LD E,(HL)       ;
        ld      e, (hl)         ;

line 1924:
    RET             ;
        ret                     ;

line 1931:
L05C4:  CALL L0A1F      ; routine LINE-ENDS clears lower display.
L05C4:  call L0A1F              ; routine LINE-ENDS clears lower display.

line 1933:
    LD HL,L046F     ; Address: EDIT-INP
        ld      hl, L046F       ; Address: EDIT-INP

line 1934:
    PUSH HL         ; ** is pushed as an error looping address.
        push    hl              ; ** is pushed as an error looping address.

line 1936:
    BIT 5,(IY+$2D)      ; test FLAGX
        bit     5, (iy+$2D)     ; test FLAGX

line 1937:
    RET NZ          ; indirect jump if in input mode
        ret     nz              ; indirect jump if in input mode

line 1938:
                ; to L046F, EDIT-INP (begin again).
                                ; to L046F, EDIT-INP (begin again).

line 1939:
    LD HL,($4014)       ; fetch E_LINE
        ld      hl, ($4014)     ; fetch E_LINE

line 1940:
    LD ($400E),HL       ; and use to update the screen cursor DF_CC
        ld      ($400E), hl     ; and use to update the screen cursor DF_CC

line 1946:
    LD HL,$1821     ; prepare line 0, column 0.
        ld      hl, $1821       ; prepare line 0, column 0.

line 1947:
    LD ($4039),HL       ; update S_POSN with these dummy values.
        ld      ($4039), hl     ; update S_POSN with these dummy values.

line 1949:
    LD HL,($400A)       ; fetch current line from E_PPC may be a
        ld      hl, ($400A)     ; fetch current line from E_PPC may be a

line 1950:
                ; non-existent line e.g. last line deleted.
                                ; non-existent line e.g. last line deleted.

line 1951:
    CALL L09D8      ; routine LINE-ADDR gets address or that of
        call    L09D8           ; routine LINE-ADDR gets address or that of

line 1952:
                ; the following line.
                                ; the following line.

line 1953:
    CALL L05BB      ; routine LINE-NO gets line number if any in DE
        call    L05BB           ; routine LINE-NO gets line number if any in DE

line 1954:
                ; leaving HL pointing at second low byte.
                                ; leaving HL pointing at second low byte.

line 1956:
    LD A,D          ; test the line number for zero.
        ld      a, d            ; test the line number for zero.

line 1957:
    OR E            ;
        or      e               ;

line 1958:
    RET Z           ; return if no line number - no program to edit.
        ret     z               ; return if no line number - no program to edit.

line 1960:
    DEC HL          ; point to high byte.
        dec     hl              ; point to high byte.

line 1961:
    CALL L0AA5      ; routine OUT-NO writes number to edit line.
        call    L0AA5           ; routine OUT-NO writes number to edit line.

line 1963:
    INC HL          ; point to length bytes.
        inc     hl              ; point to length bytes.

line 1964:
    LD C,(HL)       ; low byte to C.
        ld      c, (hl)         ; low byte to C.

line 1965:
    INC HL          ;
        inc     hl              ;

line 1966:
    LD B,(HL)       ; high byte to B.
        ld      b, (hl)         ; high byte to B.

line 1968:
    INC HL          ; point to first character in line.
        inc     hl              ; point to first character in line.

line 1969:
    LD DE,($400E)       ; fetch display file cursor DF_CC
        ld      de, ($400E)     ; fetch display file cursor DF_CC

line 1971:
    LD A,$7F        ; prepare the cursor character.
        ld      a, $7F          ; prepare the cursor character.

line 1972:
    LD (DE),A       ; and insert in edit line.
        ld      (de), a         ; and insert in edit line.

line 1973:
    INC DE          ; increment intended destination.
        inc     de              ; increment intended destination.

line 1975:
    PUSH HL         ; * save start of BASIC.
        push    hl              ; * save start of BASIC.

line 1977:
    LD HL,$001D     ; set an overhead of 29 bytes.
        ld      hl, $001D       ; set an overhead of 29 bytes.

line 1978:
    ADD HL,DE       ; add in the address of cursor.
        add     hl, de          ; add in the address of cursor.

line 1979:
    ADD HL,BC       ; add the length of the line.
        add     hl, bc          ; add the length of the line.

line 1980:
    SBC HL,SP       ; subtract the stack pointer.
        sbc     hl, sp          ; subtract the stack pointer.

line 1982:
    POP HL          ; * restore pointer to start of BASIC.
        pop     hl              ; * restore pointer to start of BASIC.

line 1984:
    RET NC          ; return if not enough room to L046F EDIT-INP.
        ret     nc              ; return if not enough room to L046F EDIT-INP.

line 1985:
                ; the edit key appears not to work.
                                ; the edit key appears not to work.

line 1987:
    LDIR            ; else copy bytes from program to edit line.
        ldir                    ; else copy bytes from program to edit line.

line 1988:
                ; Note. hidden floating point forms are also
                                ; Note. hidden floating point forms are also

line 1989:
                ; copied to edit line.
                                ; copied to edit line.

line 1991:
    EX DE,HL        ; transfer free location pointer to HL
        ex      de, hl          ; transfer free location pointer to HL

line 1993:
    POP DE          ; ** remove address EDIT-INP from stack.
        pop     de              ; ** remove address EDIT-INP from stack.

line 1995:
    CALL L14A6      ; routine SET-STK-B sets STKEND from HL.
        call    L14A6           ; routine SET-STK-B sets STKEND from HL.

line 1997:
    JR L059D        ; back to ENDED-2 and after 3 more jumps
        jr      L059D           ; back to ENDED-2 and after 3 more jumps

line 1998:
                ; to L0472, LOWER.
                                ; to L0472, LOWER.

line 1999:
                ; Note. The LOWER routine removes the hidden
                                ; Note. The LOWER routine removes the hidden

line 2000:
                ; floating-point numbers from the edit line.
                                ; floating-point numbers from the edit line.

line 2007:
L060C:  CALL L0A1F      ; routine LINE-ENDS
L060C:  call L0A1F              ; routine LINE-ENDS

line 2009:
    LD HL,L0472     ; prepare address: LOWER
        ld      hl, L0472       ; prepare address: LOWER

line 2011:
    BIT 5,(IY+$2D)      ; sv FLAGX
        bit     5, (iy+$2D)     ; sv FLAGX

line 2012:
    JR NZ,L0629     ; to NOW-SCAN
        jr      nz, L0629       ; to NOW-SCAN

line 2014:
    LD HL,($4014)       ; sv E_LINE_lo
        ld      hl, ($4014)     ; sv E_LINE_lo

line 2015:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 2016:
    CP $FF  ;
        cp      $FF             ;

line 2017:
    JR Z,L0626      ; to STK-UPPER
        jr      z, L0626        ; to STK-UPPER

line 2019:
    CALL L08E2      ; routine CLEAR-PRB
        call    L08E2           ; routine CLEAR-PRB

line 2020:
    CALL L0A2A      ; routine CLS
        call    L0A2A           ; routine CLS

line 2023:
L0626:  LD HL,L0419     ; Address: UPPER
L0626:  ld hl, L0419            ; Address: UPPER

line 2026:
L0629:  PUSH HL         ; push routine address (LOWER or UPPER).
L0629:  push hl                 ; push routine address (LOWER or UPPER).

line 2027:
    CALL L0CBA      ; routine LINE-SCAN
        call    L0CBA           ; routine LINE-SCAN

line 2028:
    POP HL          ;
        pop     hl              ;

line 2029:
    CALL L0537      ; routine CURSOR
        call    L0537           ; routine CURSOR

line 2030:
    CALL L055C      ; routine CLEAR-ONE
        call    L055C           ; routine CLEAR-ONE

line 2031:
    CALL L0A73      ; routine E-LINE-NO
        call    L0A73           ; routine E-LINE-NO

line 2032:
    JR NZ,L064E     ; to N/L-INP
        jr      nz, L064E       ; to N/L-INP

line 2034:
    LD A,B          ;
        ld      a, b            ;

line 2035:
    OR C            ;
        or      c               ;

line 2036:
    JP NZ,L06E0     ; to N/L-LINE
        jp      nz, L06E0       ; to N/L-LINE

line 2038:
    DEC BC          ;
        dec     bc              ;

line 2039:
    DEC BC          ;
        dec     bc              ;

line 2040:
    LD ($4007),BC       ; sv PPC_lo
        ld      ($4007), bc     ; sv PPC_lo

line 2041:
    LD (IY+$22),$02     ; sv DF_SZ
        ld      (iy+$22), $02   ; sv DF_SZ

line 2042:
    LD DE,($400C)       ; sv D_FILE_lo
        ld      de, ($400C)     ; sv D_FILE_lo

line 2044:
    JR L0661        ; forward to TEST-NULL
        jr      L0661           ; forward to TEST-NULL

line 2048:
L064E:  CP $76          ;
L064E:  cp $76                  ;

line 2049:
    JR Z,L0664      ; to N/L-NULL
        jr      z, L0664        ; to N/L-NULL

line 2051:
    LD BC,($4030)       ; sv T_ADDR_lo
        ld      bc, ($4030)     ; sv T_ADDR_lo

line 2052:
    CALL L0918      ; routine LOC-ADDR
        call    L0918           ; routine LOC-ADDR

line 2053:
    LD DE,($4029)       ; sv NXTLIN_lo
        ld      de, ($4029)     ; sv NXTLIN_lo

line 2054:
    LD (IY+$22),$02     ; sv DF_SZ
        ld      (iy+$22), $02   ; sv DF_SZ

line 2057:
L0661:  RST 18H         ; GET-CHAR
L0661:  rst 18H                 ; GET-CHAR

line 2058:
    CP $76          ;
        cp      $76             ;

line 2061:
L0664:  JP Z,L0413      ; to N/L-ONLY
L0664:  jp z, L0413             ; to N/L-ONLY

line 2063:
    LD (IY+$01),$80     ; sv FLAGS
        ld      (iy+$01), $80   ; sv FLAGS

line 2064:
    EX DE,HL        ;
        ex      de, hl          ;

line 2067:
L066C:  LD ($4029),HL       ; sv NXTLIN_lo
L066C:  ld ($4029), hl          ; sv NXTLIN_lo

line 2068:
    EX DE,HL        ;
        ex      de, hl          ;

line 2069:
    CALL L004D      ; routine TEMP-PTR-2
        call    L004D           ; routine TEMP-PTR-2

line 2070:
    CALL L0CC1      ; routine LINE-RUN
        call    L0CC1           ; routine LINE-RUN

line 2071:
    RES 1,(IY+$01)      ; sv FLAGS  - Signal printer not in use
        res     1, (iy+$01)     ; sv FLAGS  - Signal printer not in use

line 2072:
    LD A,$C0        ;
        ld      a, $C0          ;

line 2073:
    LD (IY+$19),A       ; sv X_PTR_lo
        ld      (iy+$19), a     ; sv X_PTR_lo

line 2074:
    CALL L14A3      ; routine X-TEMP
        call    L14A3           ; routine X-TEMP

line 2075:
    RES 5,(IY+$2D)      ; sv FLAGX
        res     5, (iy+$2D)     ; sv FLAGX

line 2076:
    BIT 7,(IY+$00)      ; sv ERR_NR
        bit     7, (iy+$00)     ; sv ERR_NR

line 2077:
    JR Z,L06AE      ; to STOP-LINE
        jr      z, L06AE        ; to STOP-LINE

line 2079:
    LD HL,($4029)       ; sv NXTLIN_lo
        ld      hl, ($4029)     ; sv NXTLIN_lo

line 2080:
    AND (HL) ;
        and     (hl)            ;

line 2081:
    JR  NZ,L06AE        ; to STOP-LINE
        jr      nz, L06AE       ; to STOP-LINE

line 2083:
    LD D,(HL)       ;
        ld      d, (hl)         ;

line 2084:
    INC HL          ;
        inc     hl              ;

line 2085:
    LD E,(HL)       ;
        ld      e, (hl)         ;

line 2086:
    LD ($4007),DE       ; sv PPC_lo
        ld      ($4007), de     ; sv PPC_lo

line 2087:
    INC HL          ;
        inc     hl              ;

line 2088:
    LD E,(HL)       ;
        ld      e, (hl)         ;

line 2089:
    INC HL          ;
        inc     hl              ;

line 2090:
    LD D,(HL)       ;
        ld      d, (hl)         ;

line 2091:
    INC HL          ;
        inc     hl              ;

line 2092:
    EX DE,HL        ;
        ex      de, hl          ;

line 2093:
    ADD HL,DE       ;
        add     hl, de          ;

line 2094:
    CALL L0F46      ; routine BREAK-1
        call    L0F46           ; routine BREAK-1

line 2095:
    JR C,L066C      ; to NEXT-LINE
        jr      c, L066C        ; to NEXT-LINE

line 2097:
    LD HL,$4000     ; sv ERR_NR
        ld      hl, $4000       ; sv ERR_NR

line 2098:
    BIT 7,(HL)      ;
        bit     7, (hl)         ;

line 2099:
    JR Z,L06AE      ; to STOP-LINE
        jr      z, L06AE        ; to STOP-LINE

line 2101:
    LD (HL),$0C     ;
        ld      (hl), $0C       ;

line 2104:
L06AE:  BIT 7,(IY+$38)      ; sv PR_CC
L06AE:  bit 7, (iy+$38)         ; sv PR_CC

line 2105:
    CALL Z,L0871        ; routine COPY-BUFF
        call    z, L0871        ; routine COPY-BUFF

line 2106:
    LD BC,$0121     ;
        ld      bc, $0121       ;

line 2107:
    CALL L0918      ; routine LOC-ADDR
        call    L0918           ; routine LOC-ADDR

line 2108:
    LD A,($4000)        ; sv ERR_NR
        ld      a, ($4000)      ; sv ERR_NR

line 2109:
    LD BC,($4007)       ; sv PPC_lo
        ld      bc, ($4007)     ; sv PPC_lo

line 2110:
    INC A           ;
        inc     a               ;

line 2111:
    JR Z,L06D1      ; to REPORT
        jr      z, L06D1        ; to REPORT

line 2113:
    CP $09          ;
        cp      $09             ;

line 2114:
    JR NZ,L06CA     ; to CONTINUE
        jr      nz, L06CA       ; to CONTINUE

line 2116:
    INC BC          ;
        inc     bc              ;

line 2119:
L06CA:  LD ($402B),BC       ; sv OLDPPC_lo
L06CA:  ld ($402B), bc          ; sv OLDPPC_lo

line 2120:
    JR NZ,L06D1     ; to REPORT
        jr      nz, L06D1       ; to REPORT

line 2122:
    DEC BC          ;
        dec     bc              ;

line 2125:
L06D1:  CALL L07EB      ; routine OUT-CODE
L06D1:  call L07EB              ; routine OUT-CODE

line 2126:
    LD A,$18        ; '/'
        ld      a, $18          ; '/'

line 2128:
    RST 10H         ; PRINT-A
        rst     10H             ; PRINT-A

line 2129:
    CALL L0A98      ; routine OUT-NUM
        call    L0A98           ; routine OUT-NUM

line 2130:
    CALL L14AD      ; routine CURSOR-IN
        call    L14AD           ; routine CURSOR-IN

line 2131:
    JP L04C1        ; to DISPLAY-6
        jp      L04C1           ; to DISPLAY-6

line 2135:
L06E0:  LD ($400A),BC       ; sv E_PPC_lo
L06E0:  ld ($400A), bc          ; sv E_PPC_lo

line 2136:
    LD HL,($4016)       ; sv CH_ADD_lo
        ld      hl, ($4016)     ; sv CH_ADD_lo

line 2137:
    EX DE,HL        ;
        ex      de, hl          ;

line 2138:
    LD HL,L0413     ; Address: N/L-ONLY
        ld      hl, L0413       ; Address: N/L-ONLY

line 2139:
    PUSH HL         ;
        push    hl              ;

line 2140:
    LD HL,($401A)       ; sv STKBOT_lo
        ld      hl, ($401A)     ; sv STKBOT_lo

line 2141:
    SBC HL,DE       ;
        sbc     hl, de          ;

line 2142:
    PUSH HL         ;
        push    hl              ;

line 2143:
    PUSH BC         ;
        push    bc              ;

line 2144:
    CALL L02E7      ; routine SET-FAST
        call    L02E7           ; routine SET-FAST

line 2145:
    CALL L0A2A      ; routine CLS
        call    L0A2A           ; routine CLS

line 2146:
    POP HL          ;
        pop     hl              ;

line 2147:
    CALL L09D8      ; routine LINE-ADDR
        call    L09D8           ; routine LINE-ADDR

line 2148:
    JR NZ,L0705     ; to COPY-OVER
        jr      nz, L0705       ; to COPY-OVER

line 2150:
    CALL L09F2      ; routine NEXT-ONE
        call    L09F2           ; routine NEXT-ONE

line 2151:
    CALL L0A60      ; routine RECLAIM-2
        call    L0A60           ; routine RECLAIM-2

line 2154:
L0705:  POP BC          ;
L0705:  pop bc                  ;

line 2155:
    LD A,C          ;
        ld      a, c            ;

line 2156:
    DEC A           ;
        dec     a               ;

line 2157:
    OR B            ;
        or      b               ;

line 2158:
    RET Z           ;
        ret     z               ;

line 2160:
    PUSH BC         ;
        push    bc              ;

line 2161:
    INC BC          ;
        inc     bc              ;

line 2162:
    INC BC          ;
        inc     bc              ;

line 2163:
    INC BC          ;
        inc     bc              ;

line 2164:
    INC BC          ;
        inc     bc              ;

line 2165:
    DEC HL          ;
        dec     hl              ;

line 2166:
    CALL L099E      ; routine MAKE-ROOM
        call    L099E           ; routine MAKE-ROOM

line 2167:
    CALL L0207      ; routine SLOW/FAST
        call    L0207           ; routine SLOW/FAST

line 2168:
    POP BC          ;
        pop     bc              ;

line 2169:
    PUSH BC         ;
        push    bc              ;

line 2170:
    INC DE          ;
        inc     de              ;

line 2171:
    LD HL,($401A)       ; sv STKBOT_lo
        ld      hl, ($401A)     ; sv STKBOT_lo

line 2172:
    DEC HL          ;
        dec     hl              ;

line 2173:
    LDDR            ; copy bytes
        lddr                    ; copy bytes

line 2174:
    LD HL,($400A)       ; sv E_PPC_lo
        ld      hl, ($400A)     ; sv E_PPC_lo

line 2175:
    EX DE,HL        ;
        ex      de, hl          ;

line 2176:
    POP BC          ;
        pop     bc              ;

line 2177:
    LD (HL),B       ;
        ld      (hl), b         ;

line 2178:
    DEC HL          ;
        dec     hl              ;

line 2179:
    LD (HL),C       ;
        ld      (hl), c         ;

line 2180:
    DEC HL          ;
        dec     hl              ;

line 2181:
    LD (HL),E       ;
        ld      (hl), e         ;

line 2182:
    DEC HL          ;
        dec     hl              ;

line 2183:
    LD (HL),D       ;
        ld      (hl), d         ;

line 2185:
    RET             ; return.
        ret                     ; return.

line 2192:
L072C:  SET 1,(IY+$01)      ; sv FLAGS  - signal printer in use
L072C:  set 1, (iy+$01)         ; sv FLAGS  - signal printer in use

line 2195:
L0730:  CALL FIND_INT       ; routine FIND-INT
L0730:  call FIND_INT           ; routine FIND-INT

line 2197:
    LD A,B          ; fetch high byte of user-supplied line number.
        ld      a, b            ; fetch high byte of user-supplied line number.

line 2198:
    AND $3F         ; and crudely limit to range 1-16383.
        and     $3F             ; and crudely limit to range 1-16383.

line 2200:
    LD H,A          ;
        ld      h, a            ;

line 2201:
    LD L,C          ;
        ld      l, c            ;

line 2202:
    LD ($400A),HL       ; sv E_PPC_lo
        ld      ($400A), hl     ; sv E_PPC_lo

line 2203:
    CALL L09D8      ; routine LINE-ADDR
        call    L09D8           ; routine LINE-ADDR

line 2206:
L073E:  LD E,$00        ;
L073E:  ld e, $00               ;

line 2209:
L0740:  CALL L0745      ; routine OUT-LINE lists one line of BASIC
L0740:  call L0745              ; routine OUT-LINE lists one line of BASIC

line 2210:
                ; making an early return when the screen is
                                ; making an early return when the screen is

line 2211:
                ; full or the end of program is reached.    >>
                                ; full or the end of program is reached.    >>

line 2212:
    JR L0740        ; loop back to UNTIL-END
        jr      L0740           ; loop back to UNTIL-END

line 2219:
L0745:  LD BC,($400A)       ; sv E_PPC_lo
L0745:  ld bc, ($400A)          ; sv E_PPC_lo

line 2220:
    CALL L09EA      ; routine CP-LINES
        call    L09EA           ; routine CP-LINES

line 2221:
    LD D,$92        ;
        ld      d, $92          ;

line 2222:
    JR Z,L0755      ; to TEST-END
        jr      z, L0755        ; to TEST-END

line 2224:
    LD DE,$0000     ;
        ld      de, $0000       ;

line 2225:
    RL E            ;
        rl      e               ;

line 2228:
L0755:  LD (IY+$1E),E       ; sv BERG
L0755:  ld (iy+$1E), e          ; sv BERG

line 2229:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 2230:
    CP $40          ;
        cp      $40             ;

line 2231:
    POP BC          ;
        pop     bc              ;

line 2232:
    RET NC          ;
        ret     nc              ;

line 2234:
    PUSH BC         ;
        push    bc              ;

line 2235:
    CALL L0AA5      ; routine OUT-NO
        call    L0AA5           ; routine OUT-NO

line 2236:
    INC HL          ;
        inc     hl              ;

line 2237:
    LD A,D          ;
        ld      a, d            ;

line 2239:
    RST 10H         ; PRINT-A
        rst     10H             ; PRINT-A

line 2240:
    INC HL          ;
        inc     hl              ;

line 2241:
    INC HL          ;
        inc     hl              ;

line 2244:
L0766:  LD ($4016),HL       ; sv CH_ADD_lo
L0766:  ld ($4016), hl          ; sv CH_ADD_lo

line 2245:
    SET 0,(IY+$01)      ; sv FLAGS  - Suppress leading space
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space

line 2248:
L076D:  LD BC,($4018)       ; sv X_PTR_lo
L076D:  ld bc, ($4018)          ; sv X_PTR_lo

line 2249:
    LD HL,($4016)       ; sv CH_ADD_lo
        ld      hl, ($4016)     ; sv CH_ADD_lo

line 2250:
    AND A           ;
        and     a               ;

line 2251:
    SBC HL,BC       ;
        sbc     hl, bc          ;

line 2252:
    JR NZ,L077C     ; to TEST-NUM
        jr      nz, L077C       ; to TEST-NUM

line 2254:
    LD A,$B8        ;
        ld      a, $B8          ;

line 2256:
    RST 10H         ; PRINT-A
        rst     10H             ; PRINT-A

line 2259:
L077C:  LD HL,($4016)       ; sv CH_ADD_lo
L077C:  ld hl, ($4016)          ; sv CH_ADD_lo

line 2260:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 2261:
    INC HL          ;
        inc     hl              ;

line 2262:
    CALL L07B4      ; routine NUMBER
        call    L07B4           ; routine NUMBER

line 2263:
    LD ($4016),HL       ; sv CH_ADD_lo
        ld      ($4016), hl     ; sv CH_ADD_lo

line 2264:
    JR Z,L076D      ; to MORE-LINE
        jr      z, L076D        ; to MORE-LINE

line 2266:
    CP $7F          ;
        cp      $7F             ;

line 2267:
    JR Z,L079D      ; to OUT-CURS
        jr      z, L079D        ; to OUT-CURS

line 2269:
    CP $76          ;
        cp      $76             ;

line 2270:
    JR Z,L07EE      ; to OUT-CH
        jr      z, L07EE        ; to OUT-CH

line 2272:
    BIT 6,A         ;
        bit     6, a            ;

line 2273:
    JR Z,L079A      ; to NOT-TOKEN
        jr      z, L079A        ; to NOT-TOKEN

line 2275:
    CALL L094B      ; routine TOKENS
        call    L094B           ; routine TOKENS

line 2276:
    JR L076D        ; to MORE-LINE
        jr      L076D           ; to MORE-LINE

line 2280:
L079A:  RST 10H         ; PRINT-A
L079A:  rst 10H                 ; PRINT-A

line 2281:
    JR L076D        ; to MORE-LINE
        jr      L076D           ; to MORE-LINE

line 2285:
L079D:  LD A,($4006)        ; Fetch value of system variable MODE
L079D:  ld a, ($4006)           ; Fetch value of system variable MODE

line 2286:
    LD B,$AB        ; Prepare an inverse [F] for function cursor.
        ld      b, $AB          ; Prepare an inverse [F] for function cursor.

line 2288:
    AND A           ; Test for zero -
        and     a               ; Test for zero -

line 2289:
    JR NZ,L07AA     ; forward if not to FLAGS-2
        jr      nz, L07AA       ; forward if not to FLAGS-2

line 2291:
    LD A,($4001)        ; Fetch system variable FLAGS.
        ld      a, ($4001)      ; Fetch system variable FLAGS.

line 2292:
    LD B,$B0        ; Prepare an inverse [K] for keyword cursor.
        ld      b, $B0          ; Prepare an inverse [K] for keyword cursor.

line 2295:
L07AA:  RRA         ; 00000?00 -> 000000?0
L07AA:  rra                     ; 00000?00 -> 000000?0

line 2296:
    RRA         ; 000000?0 -> 0000000?
        rra                     ; 000000?0 -> 0000000?

line 2297:
    AND $01         ; 0000000?    0000000x
        and     $01             ; 0000000?    0000000x

line 2299:
    ADD A,B         ; Possibly [F] -> [G]  or  [K] -> [L]
        add     a, b            ; Possibly [F] -> [G]  or  [K] -> [L]

line 2301:
    CALL L07F5      ; routine PRINT-SP prints character
        call    L07F5           ; routine PRINT-SP prints character

line 2302:
    JR L076D        ; back to MORE-LINE
        jr      L076D           ; back to MORE-LINE

line 2309:
L07B4:  CP $7E          ;
L07B4:  cp $7E                  ;

line 2310:
    RET NZ          ;
        ret     nz              ;

line 2312:
    INC HL          ;
        inc     hl              ;

line 2313:
    INC HL          ;
        inc     hl              ;

line 2314:
    INC HL          ;
        inc     hl              ;

line 2315:
    INC HL          ;
        inc     hl              ;

line 2316:
    INC HL          ;
        inc     hl              ;

line 2317:
    RET             ;
        ret                     ;

line 2324:
L07BD:  LD D,$00        ;
L07BD:  ld d, $00               ;

line 2325:
    SRA B           ;
        sra     b               ;

line 2326:
    SBC A,A         ;
        sbc     a, a            ;

line 2327:
    OR $26          ;
        or      $26             ;

line 2328:
    LD L,$05        ;
        ld      l, $05          ;

line 2329:
    SUB L           ;
        sub     l               ;

line 2332:
L07C7:  ADD A,L         ;
L07C7:  add a, l                ;

line 2333:
    SCF         ; Set Carry Flag
        scf                     ; Set Carry Flag

line 2334:
    RR C            ;
        rr      c               ;

line 2335:
    JR C,L07C7      ; to KEY-LINE
        jr      c, L07C7        ; to KEY-LINE

line 2337:
    INC C           ;
        inc     c               ;

line 2338:
    RET NZ          ;
        ret     nz              ;

line 2340:
    LD C,B          ;
        ld      c, b            ;

line 2341:
    DEC L           ;
        dec     l               ;

line 2342:
    LD L,$01        ;
        ld      l, $01          ;

line 2343:
    JR NZ,L07C7     ; to KEY-LINE
        jr      nz, L07C7       ; to KEY-LINE

line 2345:
    LD HL,$007D     ; (expr reqd)
        ld      hl, $007D       ; (expr reqd)

line 2346:
    LD E,A          ;
        ld      e, a            ;

line 2347:
    ADD HL,DE       ;
        add     hl, de          ;

line 2348:
    SCF         ; Set Carry Flag
        scf                     ; Set Carry Flag

line 2349:
    RET             ;
        ret                     ;

line 2356:
L07DC:  LD A,E          ;
L07DC:  ld a, e                 ;

line 2357:
    AND A           ;
        and     a               ;

line 2358:
    RET M           ;
        ret     m               ;

line 2360:
    JR L07F1        ; to PRINT-CH
        jr      L07F1           ; to PRINT-CH

line 2364:
L07E1:  XOR A           ;
L07E1:  xor a                   ;

line 2367:
L07E2:  ADD HL,BC       ;
L07E2:  add hl, bc              ;

line 2368:
    INC A           ;
        inc     a               ;

line 2369:
    JR C,L07E2      ; to DIGIT-INC
        jr      c, L07E2        ; to DIGIT-INC

line 2371:
    SBC HL,BC       ;
        sbc     hl, bc          ;

line 2372:
    DEC A           ;
        dec     a               ;

line 2373:
    JR Z,L07DC      ; to LEAD-SP
        jr      z, L07DC        ; to LEAD-SP

line 2376:
L07EB:  LD E,$1C        ;
L07EB:  ld e, $1C               ;

line 2377:
    ADD A,E         ;
        add     a, e            ;

line 2380:
L07EE:  AND A           ;
L07EE:  and a                   ;

line 2381:
    JR Z,L07F5      ; to PRINT-SP
        jr      z, L07F5        ; to PRINT-SP

line 2384:
L07F1:  RES 0,(IY+$01)      ; update FLAGS - signal leading space permitted
L07F1:  res 0, (iy+$01)         ; update FLAGS - signal leading space permitted

line 2387:
L07F5:  EXX         ;
L07F5:  exx                     ;

line 2388:
    PUSH HL         ;
        push    hl              ;

line 2390:
    call prn_test       ;
        call    prn_test        ;

line 2392:
    pop hl          ;
        pop     hl              ;

line 2393:
    exx         ;
        exx                     ;

line 2394:
    ret             ;
        ret                     ;

line 2400:
    inc a           ; offset1 (+1) - code of zero (-27)
        inc     a               ; offset1 (+1) - code of zero (-27)

line 2402:
    add a,$1B       ; offset2 (+27) - code of '.'
        add     a, $1B          ; offset2 (+27) - code of '.'

line 2404:
    jr L07F5        ; print
        jr      L07F5           ; print

line 2409:
    bit 1,(iy+$01)      ; test FLAGS - is printer in use ?
        bit     1, (iy+$01)     ; test FLAGS - is printer in use ?

line 2410:
    jr nz,L0851     ; routine LPRINT-CH
        jr      nz, L0851       ; routine LPRINT-CH

line 2414:
L0808:  LD D,A          ;
L0808:  ld d, a                 ;

line 2415:
    LD BC,($4039)       ; sv S_POSN_x
        ld      bc, ($4039)     ; sv S_POSN_x

line 2416:
    LD A,C          ;
        ld      a, c            ;

line 2417:
    CP $21          ;
        cp      $21             ;

line 2418:
    JR Z,L082C      ; to TEST-LOW
        jr      z, L082C        ; to TEST-LOW

line 2421:
L0812:  LD A,$76        ;
L0812:  ld a, $76               ;

line 2422:
    CP D            ;
        cp      d               ;

line 2423:
    JR Z,L0847      ; to WRITE-N/L
        jr      z, L0847        ; to WRITE-N/L

line 2425:
    LD HL,($400E)       ; sv DF_CC_lo
        ld      hl, ($400E)     ; sv DF_CC_lo

line 2426:
    CP (HL)         ;
        cp      (hl)            ;

line 2427:
    LD A,D          ;
        ld      a, d            ;

line 2428:
    JR NZ,L083E     ; to WRITE-CH
        jr      nz, L083E       ; to WRITE-CH

line 2430:
    DEC C           ;
        dec     c               ;

line 2431:
    JR NZ,L083A     ; to EXPAND-1
        jr      nz, L083A       ; to EXPAND-1

line 2433:
    INC HL          ;
        inc     hl              ;

line 2434:
    LD  ($400E),HL      ; sv DF_CC_lo
        ld      ($400E), hl     ; sv DF_CC_lo

line 2435:
    LD C,$21        ;
        ld      c, $21          ;

line 2436:
    DEC B           ;
        dec     b               ;

line 2437:
    LD ($4039),BC       ; sv S_POSN_x
        ld      ($4039), bc     ; sv S_POSN_x

line 2440:
L082C:  LD A,B          ;
L082C:  ld a, b                 ;

line 2441:
    CP (IY+$22)     ; sv DF_SZ
        cp      (iy+$22)        ; sv DF_SZ

line 2442:
    JR Z,L0835      ; to REPORT-5
        jr      z, L0835        ; to REPORT-5

line 2444:
    AND A           ;
        and     a               ;

line 2445:
    JR NZ,L0812     ; to TEST-N/L
        jr      nz, L0812       ; to TEST-N/L

line 2448:
L0835:  LD L,$04        ; 'No more room on screen'
L0835:  ld l, $04               ; 'No more room on screen'

line 2449:
    JP L0058        ; to ERROR-3
        jp      L0058           ; to ERROR-3

line 2453:
L083A:  CALL L099B      ; routine ONE-SPACE
L083A:  call L099B              ; routine ONE-SPACE

line 2454:
    EX DE,HL        ;
        ex      de, hl          ;

line 2457:
L083E:  LD (HL),A       ;
L083E:  ld (hl), a              ;

line 2458:
    INC HL          ;
        inc     hl              ;

line 2459:
    LD ($400E),HL       ; sv DF_CC_lo
        ld      ($400E), hl     ; sv DF_CC_lo

line 2460:
    DEC (IY+$39)        ; sv S_POSN_x
        dec     (iy+$39)        ; sv S_POSN_x

line 2461:
    RET         ;
        ret                     ;

line 2466:
    SET 0,(IY+$01)      ; sv FLAGS  - Suppress leading space
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space

line 2468:
    DEC B           ; set line counter
        dec     b               ; set line counter

line 2470:
    LD C,$21        ; point the leading N/L character
        ld      c, $21          ; point the leading N/L character

line 2471:
    JP L0918        ; to (quick) LOC-ADDR
        jp      L0918           ; to (quick) LOC-ADDR

line 2482:
L0851:  CP $76          ; compare to NEWLINE.
L0851:  cp $76                  ; compare to NEWLINE.

line 2483:
    JR Z,L0871      ; forward if so to COPY-BUFF
        jr      z, L0871        ; forward if so to COPY-BUFF

line 2485:
    LD C,A          ; take a copy of the character in C.
        ld      c, a            ; take a copy of the character in C.

line 2486:
    LD A,($4038)        ; fetch print location from PR_CC
        ld      a, ($4038)      ; fetch print location from PR_CC

line 2487:
    AND $7F         ; ignore bit 7 to form true position.
        and     $7F             ; ignore bit 7 to form true position.

line 2488:
    CP $5C          ; compare to 33rd location
        cp      $5C             ; compare to 33rd location

line 2490:
    LD L,A          ; form low-order byte.
        ld      l, a            ; form low-order byte.

line 2491:
    LD H,$40        ; the high-order byte is fixed.
        ld      h, $40          ; the high-order byte is fixed.

line 2493:
    CALL Z,L0871        ; routine COPY-BUFF to send full buffer to
        call    z, L0871        ; routine COPY-BUFF to send full buffer to

line 2494:
                ; the printer if first 32 bytes full.
                                ; the printer if first 32 bytes full.

line 2495:
                ; (this will reset HL to start.)
                                ; (this will reset HL to start.)

line 2497:
    LD (HL),C       ; place character at location.
        ld      (hl), c         ; place character at location.

line 2498:
    INC L           ; increment - will not cross a 256 boundary.
        inc     l               ; increment - will not cross a 256 boundary.

line 2499:
    LD (IY+$38),L       ; update system variable PR_CC
        ld      (iy+$38), l     ; update system variable PR_CC

line 2500:
                ; automatically resetting bit 7 to show that
                                ; automatically resetting bit 7 to show that

line 2501:
                ; the buffer is not empty.
                                ; the buffer is not empty.

line 2502:
    RET             ; return.
        ret                     ; return.

line 2511:
L0869:  LD D,$16        ; prepare to copy twenty four text lines.
L0869:  ld d, $16               ; prepare to copy twenty four text lines.

line 2512:
    LD HL,($400C)       ; set HL to start of display file from D_FILE.
        ld      hl, ($400C)     ; set HL to start of display file from D_FILE.

line 2513:
    INC HL          ;
        inc     hl              ;

line 2514:
    JR L0876        ; forward to COPY*D
        jr      L0876           ; forward to COPY*D

line 2520:
L0871:  LD D,$01        ; prepare to copy a single text line.
L0871:  ld d, $01               ; prepare to copy a single text line.

line 2521:
    LD HL,$403C     ; set HL to start of printer buffer PRBUFF.
        ld      hl, $403C       ; set HL to start of printer buffer PRBUFF.

line 2526:
L0876:  CALL L02E7      ; routine SET-FAST
L0876:  call L02E7              ; routine SET-FAST

line 2528:
    PUSH BC         ; *** preserve BC throughout.
        push    bc              ; *** preserve BC throughout.

line 2529:
                ; a pending character may be present
                                ; a pending character may be present

line 2530:
                ; in C from LPRINT-CH
                                ; in C from LPRINT-CH

line 2533:
L087A:  PUSH HL         ; save first character of line pointer. (*)
L087A:  push hl                 ; save first character of line pointer. (*)

line 2534:
    XOR A           ; clear accumulator.
        xor     a               ; clear accumulator.

line 2535:
    LD E,A          ; set pixel line count, range 0-7, to zero.
        ld      e, a            ; set pixel line count, range 0-7, to zero.

line 2540:
L087D:  OUT ($FB),A     ; bit 2 reset starts the printer motor
L087D:  out ($FB), a            ; bit 2 reset starts the printer motor

line 2541:
                ; with an inactive stylus - bit 7 reset.
                                ; with an inactive stylus - bit 7 reset.

line 2542:
    POP HL          ; pick up first character of line pointer (*)
        pop     hl              ; pick up first character of line pointer (*)

line 2543:
                ; on inner loop.
                                ; on inner loop.

line 2546:
L0880:  CALL L0F46      ; routine BREAK-1
L0880:  call L0F46              ; routine BREAK-1

line 2547:
    JR C,L088A      ; forward with no keypress to COPY-CONT
        jr      c, L088A        ; forward with no keypress to COPY-CONT

line 2551:
    RRA         ; 0111 1111
        rra                     ; 0111 1111

line 2552:
    OUT ($FB),A     ; stop ZX printer motor, de-activate stylus.
        out     ($FB), a        ; stop ZX printer motor, de-activate stylus.

line 2555:
L0888:  RST 08H         ; ERROR-1
L0888:  rst 08H                 ; ERROR-1

line 2556:
    DEFB $0C        ; Error Report: BREAK - CONT repeats
        defb    $0C             ; Error Report: BREAK - CONT repeats

line 2560:
L088A:  IN A,($FB)      ; read from printer port.
L088A:  in a, ($FB)             ; read from printer port.

line 2561:
    ADD A,A         ; test bit 6 and 7
        add     a, a            ; test bit 6 and 7

line 2562:
    JP M,L08DE      ; jump forward with no printer to COPY-END
        jp      m, L08DE        ; jump forward with no printer to COPY-END

line 2564:
    JR NC,L0880     ; back if stylus not in position to COPY-BRK
        jr      nc, L0880       ; back if stylus not in position to COPY-BRK

line 2566:
    PUSH HL         ; save first character of line pointer (*)
        push    hl              ; save first character of line pointer (*)

line 2567:
    PUSH DE         ; ** preserve character line and pixel line.
        push    de              ; ** preserve character line and pixel line.

line 2569:
    LD A,D          ; text line count to A?
        ld      a, d            ; text line count to A?

line 2570:
    CP $02          ; sets carry if last line.
        cp      $02             ; sets carry if last line.

line 2571:
    SBC A,A         ; now $FF if last line else zero.
        sbc     a, a            ; now $FF if last line else zero.

line 2576:
    AND E           ; and with pixel line offset 0-7
        and     e               ; and with pixel line offset 0-7

line 2577:
    RLCA            ; shift to left.
        rlca                    ; shift to left.

line 2578:
    AND E           ; and again.
        and     e               ; and again.

line 2579:
    LD D,A          ; store control mask in D.
        ld      d, a            ; store control mask in D.

line 2582:
L089C:  LD C,(HL)       ; load character from screen or buffer.
L089C:  ld c, (hl)              ; load character from screen or buffer.

line 2583:
    LD A,C          ; save a copy in C for later inverse test.
        ld      a, c            ; save a copy in C for later inverse test.

line 2584:
    INC HL          ; update pointer for next time.
        inc     hl              ; update pointer for next time.

line 2585:
    CP $76          ; is character a NEWLINE ?
        cp      $76             ; is character a NEWLINE ?

line 2586:
    JR Z,L08C7      ; forward, if so, to COPY-N/L
        jr      z, L08C7        ; forward, if so, to COPY-N/L

line 2588:
    PUSH HL         ; * else preserve the character pointer.
        push    hl              ; * else preserve the character pointer.

line 2590:
    SLA A           ; (?) multiply by two
        sla     a               ; (?) multiply by two

line 2591:
    ADD A,A         ; multiply by four
        add     a, a            ; multiply by four

line 2592:
    ADD A,A         ; multiply by eight
        add     a, a            ; multiply by eight

line 2594:
    LD H,$0F        ; load H with half the address of character set.
        ld      h, $0F          ; load H with half the address of character set.

line 2595:
    RL H            ; now $1E or $1F (with carry)
        rl      h               ; now $1E or $1F (with carry)

line 2596:
    ADD A,E         ; add byte offset 0-7
        add     a, e            ; add byte offset 0-7

line 2597:
    LD L,A          ; now HL addresses character source byte
        ld      l, a            ; now HL addresses character source byte

line 2599:
    RL C            ; test character, setting carry if inverse.
        rl      c               ; test character, setting carry if inverse.

line 2600:
    SBC A,A         ; accumulator now $00 if normal, $FF if inverse.
        sbc     a, a            ; accumulator now $00 if normal, $FF if inverse.

line 2602:
    XOR (HL)        ; combine with bit pattern at end or ROM.
        xor     (hl)            ; combine with bit pattern at end or ROM.

line 2603:
    LD C,A          ; transfer the byte to C.
        ld      c, a            ; transfer the byte to C.

line 2604:
    LD B,$08        ; count eight bits to output.
        ld      b, $08          ; count eight bits to output.

line 2607:
L08B5:  LD A,D          ; fetch speed control mask from D.
L08B5:  ld a, d                 ; fetch speed control mask from D.

line 2608:
    RLC C           ; rotate a bit from output byte to carry.
        rlc     c               ; rotate a bit from output byte to carry.

line 2609:
    RRA         ; pick up in bit 7, speed bit to bit 1
        rra                     ; pick up in bit 7, speed bit to bit 1

line 2610:
    LD H,A          ; store aligned mask in H register.
        ld      h, a            ; store aligned mask in H register.

line 2613:
L08BA:  IN A,($FB)      ; read the printer port
L08BA:  in a, ($FB)             ; read the printer port

line 2614:
    RRA         ; test for alignment signal from encoder.
        rra                     ; test for alignment signal from encoder.

line 2615:
    JR NC,L08BA     ; loop if not present to COPY-WAIT
        jr      nc, L08BA       ; loop if not present to COPY-WAIT

line 2617:
    LD A,H          ; control byte to A.
        ld      a, h            ; control byte to A.

line 2618:
    OUT ($FB),A     ; and output to printer port.
        out     ($FB), a        ; and output to printer port.

line 2619:
    DJNZ L08B5      ; loop for all eight bits to COPY-BITS
        djnz    L08B5           ; loop for all eight bits to COPY-BITS

line 2621:
    POP HL          ; * restore character pointer.
        pop     hl              ; * restore character pointer.

line 2622:
    JR L089C        ; back for adjacent character line to COPY-NEXT
        jr      L089C           ; back for adjacent character line to COPY-NEXT

line 2629:
L08C7:  IN A,($FB)      ; read printer port.
L08C7:  in a, ($FB)             ; read printer port.

line 2630:
    RRA         ; wait for encoder signal.
        rra                     ; wait for encoder signal.

line 2631:
    JR NC,L08C7     ; loop back if not to COPY-N/L
        jr      nc, L08C7       ; loop back if not to COPY-N/L

line 2633:
    LD A,D          ; transfer speed mask to A.
        ld      a, d            ; transfer speed mask to A.

line 2634:
    RRCA            ; rotate speed bit to bit 1.
        rrca                    ; rotate speed bit to bit 1.

line 2635:
                ; bit 7, stylus control is reset.
                                ; bit 7, stylus control is reset.

line 2636:
    OUT ($FB),A     ; set the printer speed.
        out     ($FB), a        ; set the printer speed.

line 2638:
    POP DE          ; ** restore character line and pixel line.
        pop     de              ; ** restore character line and pixel line.

line 2639:
    INC E           ; increment pixel line 0-7.
        inc     e               ; increment pixel line 0-7.

line 2640:
    BIT 3,E         ; test if value eight reached.
        bit     3, e            ; test if value eight reached.

line 2641:
    JR Z,L087D      ; back if not to COPY-TIME
        jr      z, L087D        ; back if not to COPY-TIME

line 2645:
    POP BC          ; lose the now redundant first character
        pop     bc              ; lose the now redundant first character

line 2646:
                ; pointer
                                ; pointer

line 2647:
    DEC D           ; decrease text line count.
        dec     d               ; decrease text line count.

line 2648:
    JR NZ,L087A     ; back if not zero to COPY-LOOP
        jr      nz, L087A       ; back if not zero to COPY-LOOP

line 2650:
    LD A,$04        ; stop the already slowed printer motor.
        ld      a, $04          ; stop the already slowed printer motor.

line 2651:
    OUT ($FB),A     ; output to printer port.
        out     ($FB), a        ; output to printer port.

line 2654:
L08DE:  CALL L0207      ; routine SLOW/FAST
L08DE:  call L0207              ; routine SLOW/FAST

line 2655:
    POP BC          ; *** restore preserved BC.
        pop     bc              ; *** restore preserved BC.

line 2680:
    ld a,$3C+$80        ; signal the printer buffer is clear (bit 7)
        ld      a, $3C+$80      ; signal the printer buffer is clear (bit 7)

line 2681:
    ld ($4038),a        ; update one-byte system variable PR_CC
        ld      ($4038), a      ; update one-byte system variable PR_CC

line 2683:
    ld hl,$405D     ; address fixed end of PRBUFF (+1)
        ld      hl, $405D       ; address fixed end of PRBUFF (+1)

line 2687:
    dec hl          ; set pointer
        dec     hl              ; set pointer

line 2691:
    ld b,$20        ; prepare to blank 32 preceding characters.
        ld      b, $20          ; prepare to blank 32 preceding characters.

line 2692:
    xor a           ;
        xor     a               ;

line 2693:
    ld (hl),$76     ; place a newline at last position.
        ld      (hl), $76       ; place a newline at last position.

line 2697:
    dec hl          ; decrement address.
        dec     hl              ; decrement address.

line 2698:
    ld (hl),a       ; place a zero byte.
        ld      (hl), a         ; place a zero byte.

line 2699:
    djnz clr_prbf       ; loop for all thirty-two to PRB-BYTES
        djnz    clr_prbf        ; loop for all thirty-two to PRB-BYTES

line 2701:
    ret             ; return.
        ret                     ; return.

line 2708:
L08F5:  LD A,$17        ; test, if Y>23
L08F5:  ld a, $17               ; test, if Y>23

line 2709:
    SUB B           ;
        sub     b               ;

line 2710:
    JR C,L0905      ; yes? -> to WRONG-VAL
        jr      c, L0905        ; yes? -> to WRONG-VAL

line 2713:
L08FA:  CP (IY+$22)     ; compare to DF_SZ
L08FA:  cp (iy+$22)             ; compare to DF_SZ

line 2714:
    JP C,L0835      ; out of screen? -> to REPORT-5
        jp      c, L0835        ; out of screen? -> to REPORT-5

line 2716:
    INC A           ; else
        inc     a               ; else

line 2717:
    LD B,A          ; Y=24-Y
        ld      b, a            ; Y=24-Y

line 2721:
    LD A,$1F        ; test, if X>31
        ld      a, $1F          ; test, if X>31

line 2722:
    SUB C           ;
        sub     c               ;

line 2725:
L0905:  JP C,L0EAD      ; yes? -> to REPORT-B
L0905:  jp c, L0EAD             ; yes? -> to REPORT-B

line 2727:
    ADD A,$02       ; else
        add     a, $02          ; else

line 2728:
    LD C,A          ; X=33-X
        ld      c, a            ; X=33-X

line 2731:
L090B:  BIT 1,(IY+$01)      ; sv FLAGS  - Is printer in use?
L090B:  bit 1, (iy+$01)         ; sv FLAGS  - Is printer in use?

line 2732:
    JR Z,L0918      ; to LOC-ADDR
        jr      z, L0918        ; to LOC-ADDR

line 2734:
    LD A,$5D        ;
        ld      a, $5D          ;

line 2735:
    SUB C           ;
        sub     c               ;

line 2736:
    LD ($4038),A        ; save in PR_CC
        ld      ($4038), a      ; save in PR_CC

line 2737:
    RET             ;
        ret                     ;

line 2746:
L0918:  LD ($4039),BC       ; sv S_POSN
L0918:  ld ($4039), bc          ; sv S_POSN

line 2748:
    ld hl,$1922     ; the limits (y: 25, x: 34)
        ld      hl, $1922       ; the limits (y: 25, x: 34)

line 2749:
    ld d,c          ; save old 'X' value
        ld      d, c            ; save old 'X' value

line 2750:
    and a           ; transform the coordinates
        and     a               ; transform the coordinates

line 2751:
    sbc hl,bc       ; in to the necessary format
        sbc     hl, bc          ; in to the necessary format

line 2752:
    ld b,h          ; Y=25-Y
        ld      b, h            ; Y=25-Y

line 2753:
    ld c,l          ; X=34-X
        ld      c, l            ; X=34-X

line 2755:
    call loc_xpnd       ; if D-File is collapsed, then
        call    loc_xpnd        ; if D-File is collapsed, then

line 2756:
                ; it returns with address of
                                ; it returns with address of

line 2757:
                ; D-File in HL
                                ; D-File in HL

line 2759:
    ld a,(hl)       ; HL points the 1st N/L char ($76)
        ld      a, (hl)         ; HL points the 1st N/L char ($76)

line 2761:
    cp (hl)         ; look for the next N/L char ($76)
        cp      (hl)            ; look for the next N/L char ($76)

line 2762:
    INC HL          ; set pointer
        inc     hl              ; set pointer

line 2763:
    JR NZ,look_fw       ; to LOOK-FW, if no match
        jr      nz, look_fw     ; to LOOK-FW, if no match

line 2765:
    DJNZ look_fw        ; else set line counter (B) and jump
        djnz    look_fw         ; else set line counter (B) and jump

line 2766:
                ; back to LOOK-FW if it is nonzero
                                ; back to LOOK-FW if it is nonzero

line 2768:
    CPIR            ; look for the next N/L char ($76)
        cpir                    ; look for the next N/L char ($76)

line 2769:
    DEC HL          ; HL now points a N/L or addresses
        dec     hl              ; HL now points a N/L or addresses

line 2770:
                ; the requested coorinates in D-File
                                ; the requested coorinates in D-File

line 2771:
    LD ($400E),HL       ; save pointer in DF_CC
        ld      ($400E), hl     ; save pointer in DF_CC

line 2772:
    SCF         ; Set Carry Flag
        scf                     ; Set Carry Flag

line 2773:
    RET PO          ; return, if not found N/L
        ret     po              ; return, if not found N/L

line 2775:
    DEC D           ; if a N/L was requested (X was 1),
        dec     d               ; if a N/L was requested (X was 1),

line 2776:
    RET Z           ; then return
        ret     z               ; then return

line 2778:
    PUSH BC         ; else save byte counter
        push    bc              ; else save byte counter

line 2779:
    CALL L099E      ; routine MAKE-ROOM expands the D-File
        call    L099E           ; routine MAKE-ROOM expands the D-File

line 2780:
    POP BC          ; restore byte counter
        pop     bc              ; restore byte counter

line 2782:
    LD B,C          ; set up B as byte counter
        ld      b, c            ; set up B as byte counter

line 2783:
    LD H,D          ; save the pointer
        ld      h, d            ; save the pointer

line 2784:
    LD L,E          ; in HL
        ld      l, e            ; in HL

line 2786:
    xor a           ; the 'SPACE' character
        xor     a               ; the 'SPACE' character

line 2787:
expand2:            ;
expand2:                        ;

line 2788:
    ld (de),a       ; fill the new
        ld      (de), a         ; fill the new

line 2789:
    dec de          ; area with 'SPACE'-s
        dec     de              ; area with 'SPACE'-s

line 2790:
    DJNZ expand2        ; to EXPAND-2
        djnz    expand2         ; to EXPAND-2

line 2792:
    INC HL          ; set the new pointer
        inc     hl              ; set the new pointer

line 2794:
    LD ($400E),HL       ; save pointer in DF_CC
        ld      ($400E), hl     ; save pointer in DF_CC

line 2795:
    RET
        ret

line 2804:
L094B:  PUSH AF         ;
L094B:  push af                 ;

line 2805:
    CALL L0975      ; routine TOKEN-ADD
        call    L0975           ; routine TOKEN-ADD

line 2806:
    JR NC,L0959     ; to ALL-CHARS
        jr      nc, L0959       ; to ALL-CHARS

line 2808:
    BIT 0,(IY+$01)      ; sv FLAGS  - Leading space if set
        bit     0, (iy+$01)     ; sv FLAGS  - Leading space if set

line 2809:
    JR NZ,L0959     ; to ALL-CHARS
        jr      nz, L0959       ; to ALL-CHARS

line 2811:
    XOR A           ;
        xor     a               ;

line 2813:
    RST 10H         ; PRINT-A
        rst     10H             ; PRINT-A

line 2816:
L0959:  LD A,(BC)       ;
L0959:  ld a, (bc)              ;

line 2817:
    AND $3F         ;
        and     $3F             ;

line 2819:
    RST 10H         ; PRINT-A
        rst     10H             ; PRINT-A

line 2820:
    LD A,(BC)       ;
        ld      a, (bc)         ;

line 2821:
    INC BC          ;
        inc     bc              ;

line 2822:
    ADD A,A         ;
        add     a, a            ;

line 2823:
    JR NC,L0959     ; to ALL-CHARS
        jr      nc, L0959       ; to ALL-CHARS

line 2825:
    POP BC          ;
        pop     bc              ;

line 2826:
    BIT 7,B         ;
        bit     7, b            ;

line 2827:
    RET Z           ;
        ret     z               ;

line 2829:
    CP $1A          ;
        cp      $1A             ;

line 2830:
    JR Z,L096D      ; to TRAIL-SP
        jr      z, L096D        ; to TRAIL-SP

line 2832:
    CP $38          ;
        cp      $38             ;

line 2833:
    RET C           ;
        ret     c               ;

line 2836:
L096D:  XOR A           ;
L096D:  xor a                   ;

line 2837:
    SET 0,(IY+$01)      ; sv FLAGS  - Suppress leading space
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space

line 2838:
    JP L07F5        ; to PRINT-SP
        jp      L07F5           ; to PRINT-SP

line 2842:
L0975:  PUSH HL         ;
L0975:  push hl                 ;

line 2843:
    LD HL,L0111     ; Address of TOKENS
        ld      hl, L0111       ; Address of TOKENS

line 2844:
    BIT 7,A         ;
        bit     7, a            ;

line 2845:
    JR Z,L097F      ; to TEST-HIGH
        jr      z, L097F        ; to TEST-HIGH

line 2847:
    AND $3F         ;
        and     $3F             ;

line 2850:
L097F:  CP $43          ;
L097F:  cp $43                  ;

line 2851:
    JR NC,L0993     ; to FOUND
        jr      nc, L0993       ; to FOUND

line 2853:
    LD B,A          ;
        ld      b, a            ;

line 2854:
    INC B           ;
        inc     b               ;

line 2857:
L0985:  BIT 7,(HL)      ;
L0985:  bit 7, (hl)             ;

line 2858:
    INC HL          ;
        inc     hl              ;

line 2859:
    JR Z,L0985      ; to WORDS
        jr      z, L0985        ; to WORDS

line 2861:
    DJNZ L0985      ; to WORDS
        djnz    L0985           ; to WORDS

line 2863:
    BIT 6,A         ;
        bit     6, a            ;

line 2864:
    JR NZ,L0992     ; to COMP-FLAG
        jr      nz, L0992       ; to COMP-FLAG

line 2866:
    CP $18          ;
        cp      $18             ;

line 2869:
L0992:  CCF         ; Complement Carry Flag
L0992:  ccf                     ; Complement Carry Flag

line 2872:
L0993:  LD B,H          ;
L0993:  ld b, h                 ;

line 2873:
    LD  C,L         ;
        ld      c, l            ;

line 2874:
    POP HL          ;
        pop     hl              ;

line 2875:
    RET NC          ;
        ret     nc              ;

line 2877:
    LD A,(BC)       ;
        ld      a, (bc)         ;

line 2878:
    ADD A,$E4       ;
        add     a, $E4          ;

line 2879:
    RET             ;
        ret                     ;

line 2886:
L099B:  LD BC,$0001     ;
L099B:  ld bc, $0001            ;

line 2893:
L099E:  PUSH HL         ;
L099E:  push hl                 ;

line 2894:
    CALL TEST_ROOM      ; routine TEST-ROOM
        call    TEST_ROOM       ; routine TEST-ROOM

line 2895:
    POP HL          ;
        pop     hl              ;

line 2896:
    CALL L09AD      ; routine POINTERS
        call    L09AD           ; routine POINTERS

line 2897:
    LD HL,($401C)       ; sv STKEND
        ld      hl, ($401C)     ; sv STKEND

line 2898:
    EX DE,HL        ;
        ex      de, hl          ;

line 2899:
    LDDR            ; Copy Bytes
        lddr                    ; Copy Bytes

line 2900:
    RET             ;
        ret                     ;

line 2907:
L09AD:  PUSH AF         ;
L09AD:  push af                 ;

line 2908:
    PUSH HL         ;
        push    hl              ;

line 2909:
    LD HL,$400C     ; sv D_FILE_lo
        ld      hl, $400C       ; sv D_FILE_lo

line 2910:
    LD A,$09        ;
        ld      a, $09          ;

line 2913:
L09B4:  LD E,(HL)       ; LSB of the sv
L09B4:  ld e, (hl)              ; LSB of the sv

line 2914:
    INC HL          ; then
        inc     hl              ; then

line 2915:
    LD D,(HL)       ; MSB of the sv
        ld      d, (hl)         ; MSB of the sv

line 2917:
    EX (SP),HL      ;
        ex      (sp), hl        ;

line 2918:
    AND A           ;
        and     a               ;

line 2919:
    SBC HL,DE       ;
        sbc     hl, de          ;

line 2920:
    ADD HL,DE       ;
        add     hl, de          ;

line 2921:
    EX (SP),HL      ;
        ex      (sp), hl        ;

line 2922:
    JR NC,L09CA     ; to PTR-DONE
        jr      nc, L09CA       ; to PTR-DONE

line 2924:
    PUSH DE         ; save the old value
        push    de              ; save the old value

line 2925:
    EX DE,HL        ;
        ex      de, hl          ;

line 2926:
    ADD HL,BC       ; the offset
        add     hl, bc          ; the offset

line 2927:
    EX DE,HL        ;
        ex      de, hl          ;

line 2928:
    LD (HL),D       ; save the MSB
        ld      (hl), d         ; save the MSB

line 2929:
    DEC HL          ; then the
        dec     hl              ; then the

line 2930:
    LD (HL),E       ; LSB of the
        ld      (hl), e         ; LSB of the

line 2931:
    INC HL          ; new value
        inc     hl              ; new value

line 2932:
    POP DE          ; restore the old value
        pop     de              ; restore the old value

line 2935:
L09CA:  INC HL          ; next sv
L09CA:  inc hl                  ; next sv

line 2936:
    DEC A           ;
        dec     a               ;

line 2937:
    JR NZ,L09B4     ; to NEXT-PTR
        jr      nz, L09B4       ; to NEXT-PTR

line 2939:
    EX DE,HL        ;
        ex      de, hl          ;

line 2940:
    POP DE          ;
        pop     de              ;

line 2941:
    POP AF          ;
        pop     af              ;

line 2943:
    call L0A17      ; -> DIFFER
        call    L0A17           ; -> DIFFER

line 2945:
    inc bc          ;
        inc     bc              ;

line 2952:
    push hl         ; restore stack (HL = 0 !!!)
        push    hl              ; restore stack (HL = 0 !!!)

line 2953:
    jp L023E        ; back to DISPLAY-2
        jp      L023E           ; back to DISPLAY-2

line 2960:
L09D8:  PUSH HL         ;
L09D8:  push hl                 ;

line 2961:
    LD HL,$407D     ;
        ld      hl, $407D       ;

line 2962:
    LD D,H          ;
        ld      d, h            ;

line 2963:
    LD E,L          ;
        ld      e, l            ;

line 2966:
L09DE:  POP BC          ;
L09DE:  pop bc                  ;

line 2967:
    CALL L09EA      ; routine CP-LINES
        call    L09EA           ; routine CP-LINES

line 2968:
    RET NC          ;
        ret     nc              ;

line 2970:
    PUSH BC         ;
        push    bc              ;

line 2971:
    CALL L09F2      ; routine NEXT-ONE
        call    L09F2           ; routine NEXT-ONE

line 2972:
    EX DE,HL        ;
        ex      de, hl          ;

line 2973:
    JR L09DE        ; to NEXT-TEST
        jr      L09DE           ; to NEXT-TEST

line 2980:
L09EA:  LD A,(HL)       ;
L09EA:  ld a, (hl)              ;

line 2981:
    CP B            ;
        cp      b               ;

line 2982:
    RET NZ          ;
        ret     nz              ;

line 2984:
    INC HL          ;
        inc     hl              ;

line 2985:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 2986:
    DEC HL          ;
        dec     hl              ;

line 2987:
    CP C            ;
        cp      c               ;

line 2988:
    RET             ;
        ret                     ;

line 2995:
L09F2:  PUSH HL         ;
L09F2:  push hl                 ;

line 2996:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 2997:
    CP $40          ;
        cp      $40             ;

line 2998:
    JR C,L0A0F      ; to LINES
        jr      c, L0A0F        ; to LINES

line 3000:
    BIT 5,A         ;
        bit     5, a            ;

line 3001:
    JR Z,L0A10      ; forward to NEXT-O-4
        jr      z, L0A10        ; forward to NEXT-O-4

line 3003:
    ADD A,A         ;
        add     a, a            ;

line 3004:
    JP M,L0A01      ; to NEXT+FIVE
        jp      m, L0A01        ; to NEXT+FIVE

line 3006:
    CCF         ; Complement Carry Flag
        ccf                     ; Complement Carry Flag

line 3009:
L0A01:  LD BC,$0005     ;
L0A01:  ld bc, $0005            ;

line 3010:
    JR NC,L0A08     ; to NEXT-LETT
        jr      nc, L0A08       ; to NEXT-LETT

line 3012:
    LD C,$11        ;
        ld      c, $11          ;

line 3015:
L0A08:  RLA         ;
L0A08:  rla                     ;

line 3016:
    INC HL          ;
        inc     hl              ;

line 3017:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 3018:
    JR NC,L0A08     ; to NEXT-LETT
        jr      nc, L0A08       ; to NEXT-LETT

line 3020:
    JR L0A15        ; to NEXT-ADD
        jr      L0A15           ; to NEXT-ADD

line 3024:
L0A0F:  INC HL          ;
L0A0F:  inc hl                  ;

line 3027:
L0A10:  INC HL          ;
L0A10:  inc hl                  ;

line 3028:
    LD C,(HL)       ;
        ld      c, (hl)         ;

line 3029:
    INC HL          ;
        inc     hl              ;

line 3030:
    LD B,(HL)       ;
        ld      b, (hl)         ;

line 3031:
    INC HL          ;
        inc     hl              ;

line 3034:
L0A15:  ADD HL,BC       ;
L0A15:  add hl, bc              ;

line 3035:
    POP DE          ;
        pop     de              ;

line 3042:
L0A17:  AND A           ;
L0A17:  and a                   ;

line 3043:
    SBC HL,DE       ;
        sbc     hl, de          ;

line 3044:
    LD B,H          ;
        ld      b, h            ;

line 3045:
    LD C,L          ;
        ld      c, l            ;

line 3046:
    ADD HL,DE       ;
        add     hl, de          ;

line 3047:
    EX DE,HL        ;
        ex      de, hl          ;

line 3048:
    RET             ;
        ret                     ;

line 3055:
L0A1F:  LD B,(IY+$22)       ; sv DF_SZ
L0A1F:  ld b, (iy+$22)          ; sv DF_SZ

line 3056:
    PUSH BC         ;
        push    bc              ;

line 3057:
    CALL L0A2C      ; routine B-LINES
        call    L0A2C           ; routine B-LINES

line 3058:
    POP BC          ;
        pop     bc              ;

line 3060:
    jp loc_nxt0     ; dec b -> ld c,$21 ==> retun via LOC-ADDR
        jp      loc_nxt0        ; dec b -> ld c,$21 ==> retun via LOC-ADDR

line 3067:
L0A2A:  LD B,$18        ; set line counter: 24 lines to clear
L0A2A:  ld b, $18               ; set line counter: 24 lines to clear

line 3070:
L0A2C:  RES 1,(IY+$01)      ; sv FLAGS - Signal printer not in use
L0A2C:  res 1, (iy+$01)         ; sv FLAGS - Signal printer not in use

line 3072:
    push bc         ; save line counter
        push    bc              ; save line counter

line 3073:
    call loc_pos0       ; ld c,$21 --> LOC-ADDR
        call    loc_pos0        ; ld c,$21 --> LOC-ADDR

line 3074:
    pop bc          ; restore line counter
        pop     bc              ; restore line counter

line 3075:
    ld c,b          ; save counter
        ld      c, b            ; save counter

line 3077:
    bit 5,(IY+$3B)      ; sv CDFLAG - test expanded D-FILE
        bit     5, (iy+$3B)     ; sv CDFLAG - test expanded D-FILE

line 3078:
    jr z,cls_frst       ;
        jr      z, cls_frst     ;

line 3080:
    ld de,33        ; size of a line
        ld      de, 33          ; size of a line

line 3082:
    add hl,de       ; set address
        add     hl, de          ; set address

line 3083:
    djnz cls_addr       ; until end of D-FILE
        djnz    cls_addr        ; until end of D-FILE

line 3085:
    call clr_line       ; clear a line - part of new CLEAR-PRB
        call    clr_line        ; clear a line - part of new CLEAR-PRB

line 3086:
    dec c           ; set counter
        dec     c               ; set counter

line 3087:
    jr nz,clr_next      ; done?
        jr      nz, clr_next    ; done?

line 3089:
    ret
        ret

line 3093:
    inc b           ; set line counter
        inc     b               ; set line counter

line 3094:
    dec hl          ; points the previous N/L
        dec     hl              ; points the previous N/L

line 3095:
    ld a,(hl)       ; fetch a N/L character
        ld      a, (hl)         ; fetch a N/L character

line 3097:
    ld (hl),a       ; then
        ld      (hl), a         ; then

line 3098:
    inc hl          ; make a compressed
        inc     hl              ; make a compressed

line 3099:
    djnz next_nl        ; D-File
        djnz    next_nl         ; D-File

line 3101:
    ld de,($4010)       ; sv VARS
        ld      de, ($4010)     ; sv VARS

line 3103:
    ld a,($4005)        ; sv RAMTOP_hi
        ld      a, ($4005)      ; sv RAMTOP_hi

line 3104:
    cp $4D          ; >3KB?
        cp      $4D             ; >3KB?

line 3105:
    jp nc,cls_chck      ; yes, check room
        jp      nc, cls_chck    ; yes, check room

line 3107:
    ex de,hl        ; else return w. collapsed D-FILE via
        ex      de, hl          ; else return w. collapsed D-FILE via

line 3114:
L0A5D:  CALL L0A17      ; routine DIFFER
L0A5D:  call L0A17              ; routine DIFFER

line 3117:
L0A60:  PUSH BC         ;
L0A60:  push bc                 ;

line 3118:
    LD A,B          ;
        ld      a, b            ;

line 3119:
    CPL         ;
        cpl                     ;

line 3120:
    LD B,A          ;
        ld      b, a            ;

line 3121:
    LD A,C          ;
        ld      a, c            ;

line 3122:
    CPL         ;
        cpl                     ;

line 3123:
    LD C,A          ;
        ld      c, a            ;

line 3124:
    INC BC          ;
        inc     bc              ;

line 3125:
    CALL L09AD      ; routine POINTERS
        call    L09AD           ; routine POINTERS

line 3126:
    EX DE,HL        ;
        ex      de, hl          ;

line 3127:
    POP HL          ;
        pop     hl              ;

line 3128:
    ADD HL,DE       ;
        add     hl, de          ;

line 3129:
    PUSH DE         ;
        push    de              ;

line 3130:
    LDIR            ; Copy Bytes
        ldir                    ; Copy Bytes

line 3131:
    POP HL          ;
        pop     hl              ;

line 3132:
    RET             ;
        ret                     ;

line 3139:
L0A73:  LD HL,($4014)       ; sv E_LINE_lo
L0A73:  ld hl, ($4014)          ; sv E_LINE_lo

line 3140:
    CALL L004D      ; routine TEMP-PTR-2
        call    L004D           ; routine TEMP-PTR-2

line 3142:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 3143:
    BIT 5,(IY+$2D)      ; sv FLAGX
        bit     5, (iy+$2D)     ; sv FLAGX

line 3144:
    RET NZ          ;
        ret     nz              ;

line 3146:
    LD HL,$405D     ; sv MEM-0-1st
        ld      hl, $405D       ; sv MEM-0-1st

line 3147:
    LD ($401C),HL       ; sv STKEND_lo
        ld      ($401C), hl     ; sv STKEND_lo

line 3148:
    CALL L1548      ; routine INT-TO-FP
        call    L1548           ; routine INT-TO-FP

line 3149:
    CALL L158A      ; routine FP-TO-BC
        call    L158A           ; routine FP-TO-BC

line 3150:
    JR C,L0A91      ; to NO-NUMBER
        jr      c, L0A91        ; to NO-NUMBER

line 3152:
    LD HL,$D8F0     ; value '-10000'
        ld      hl, $D8F0       ; value '-10000'

line 3153:
    ADD HL,BC       ;
        add     hl, bc          ;

line 3156:
L0A91:  JP C,L0D9A      ; to REPORT-C
L0A91:  jp c, L0D9A             ; to REPORT-C

line 3158:
    CP A            ;
        cp      a               ;

line 3159:
    JP L14BC        ; routine SET-MIN
        jp      L14BC           ; routine SET-MIN

line 3166:
L0A98:  PUSH DE         ;
L0A98:  push de                 ;

line 3167:
    PUSH HL         ;
        push    hl              ;

line 3168:
    XOR A           ;
        xor     a               ;

line 3169:
    BIT 7,B         ;
        bit     7, b            ;

line 3170:
    JR NZ,L0ABF     ; to UNITS
        jr      nz, L0ABF       ; to UNITS

line 3172:
    LD H,B          ;
        ld      h, b            ;

line 3173:
    LD L,C          ;
        ld      l, c            ;

line 3174:
    LD E,$FF        ;
        ld      e, $FF          ;

line 3175:
    JR L0AAD        ; to THOUSAND
        jr      L0AAD           ; to THOUSAND

line 3179:
L0AA5:  PUSH DE         ;
L0AA5:  push de                 ;

line 3180:
    LD D,(HL)       ;
        ld      d, (hl)         ;

line 3181:
    INC HL          ;
        inc     hl              ;

line 3182:
    LD E,(HL)       ;
        ld      e, (hl)         ;

line 3183:
    PUSH HL         ;
        push    hl              ;

line 3184:
    EX DE,HL        ;
        ex      de, hl          ;

line 3185:
    LD E,$00        ; set E to leading space.
        ld      e, $00          ; set E to leading space.

line 3188:
L0AAD:  LD BC,$FC18     ; BC= -1000
L0AAD:  ld bc, $FC18            ; BC= -1000

line 3189:
    CALL L07E1      ; routine OUT-DIGIT
        call    L07E1           ; routine OUT-DIGIT

line 3190:
    LD BC,$FF9C     ; BC= -100
        ld      bc, $FF9C       ; BC= -100

line 3191:
    CALL L07E1      ; routine OUT-DIGIT
        call    L07E1           ; routine OUT-DIGIT

line 3192:
    LD C,$F6        ; BC= -10
        ld      c, $F6          ; BC= -10

line 3193:
    CALL L07E1      ; routine OUT-DIGIT
        call    L07E1           ; routine OUT-DIGIT

line 3194:
    LD A,L          ;
        ld      a, l            ;

line 3197:
L0ABF:  CALL L07EB      ; routine OUT-CODE
L0ABF:  call L07EB              ; routine OUT-CODE

line 3198:
    POP HL          ;
        pop     hl              ;

line 3199:
    POP DE          ;
        pop     de              ;

line 3200:
    RET             ;
        ret                     ;

line 3214:
L0AC5:  CALL L0DA6      ; routine SYNTAX-Z resets the ZERO flag if
L0AC5:  call L0DA6              ; routine SYNTAX-Z resets the ZERO flag if

line 3215:
                ; checking syntax.
                                ; checking syntax.

line 3216:
    POP HL          ; drop the return address.
        pop     hl              ; drop the return address.

line 3217:
    RET Z           ; return to previous calling routine if
        ret     z               ; return to previous calling routine if

line 3218:
                ; checking syntax.
                                ; checking syntax.

line 3220:
    JP (HL)         ; else jump to the continuation address in
        jp      (hl)            ; else jump to the continuation address in

line 3221:
                ; the calling routine as RET would have done.
                                ; the calling routine as RET would have done.

line 3228:
L0ACB:  SET 1,(IY+$01)      ; sv FLAGS  - Signal printer in use
L0ACB:  set 1, (iy+$01)         ; sv FLAGS  - Signal printer in use

line 3235:
L0ACF:  LD A,(HL)       ;
L0ACF:  ld a, (hl)              ;

line 3236:
    CP $76          ;
        cp      $76             ;

line 3237:
    JP Z,L0B84      ; to PRINT-END
        jp      z, L0B84        ; to PRINT-END

line 3240:
L0AD5:  SUB $1A         ;
L0AD5:  sub $1A                 ;

line 3241:
    ADC A,$00       ;
        adc     a, $00          ;

line 3242:
    JR Z,L0B44      ; to SPACING
        jr      z, L0B44        ; to SPACING

line 3244:
    CP $A7          ;
        cp      $A7             ;

line 3245:
    JR NZ,L0AFA     ; to NOT-AT
        jr      nz, L0AFA       ; to NOT-AT

line 3248:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 3249:
    CALL CLASS_06       ; routine CLASS-6
        call    CLASS_06        ; routine CLASS-6

line 3250:
    CP $1A          ;
        cp      $1A             ;

line 3251:
    JP NZ,L0D9A     ; to REPORT-C
        jp      nz, L0D9A       ; to REPORT-C

line 3254:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 3255:
    CALL CLASS_06       ; routine CLASS-6
        call    CLASS_06        ; routine CLASS-6

line 3256:
    CALL L0B4E      ; routine SYNTAX-ON
        call    L0B4E           ; routine SYNTAX-ON

line 3258:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 3259:
    DEFB $01    ;;exchange
        defb    $01             ;;exchange

line 3260:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 3262:
    CALL L0BF5      ; routine STK-TO-BC
        call    L0BF5           ; routine STK-TO-BC

line 3263:
    CALL L08F5      ; routine PRINT-AT
        call    L08F5           ; routine PRINT-AT

line 3264:
    JR L0B37        ; to PRINT-ON
        jr      L0B37           ; to PRINT-ON

line 3268:
L0AFA:  CP $A8          ;
L0AFA:  cp $A8                  ;

line 3269:
    JR NZ,L0B31     ; to NOT-TAB
        jr      nz, L0B31       ; to NOT-TAB

line 3272:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 3273:
    CALL CLASS_06       ; routine CLASS-6
        call    CLASS_06        ; routine CLASS-6

line 3274:
    CALL L0B4E      ; routine SYNTAX-ON
        call    L0B4E           ; routine SYNTAX-ON

line 3275:
    CALL L0C02      ; routine STK-TO-A
        call    L0C02           ; routine STK-TO-A

line 3276:
    JP NZ,L0EAD     ; to REPORT-B
        jp      nz, L0EAD       ; to REPORT-B

line 3278:
    AND $1F         ;
        and     $1F             ;

line 3279:
    LD C,A          ;
        ld      c, a            ;

line 3280:
    BIT 1,(IY+$01)      ; sv FLAGS  - Is printer in use
        bit     1, (iy+$01)     ; sv FLAGS  - Is printer in use

line 3281:
    JR Z,L0B1E      ; to TAB-TEST
        jr      z, L0B1E        ; to TAB-TEST

line 3283:
    SUB (IY+$38)        ; sv PR_CC
        sub     (iy+$38)        ; sv PR_CC

line 3284:
    SET 7,A         ;
        set     7, a            ;

line 3285:
    ADD A,$3C       ;
        add     a, $3C          ;

line 3286:
    CALL NC,L0871       ; routine COPY-BUFF
        call    nc, L0871       ; routine COPY-BUFF

line 3289:
L0B1E:  ADD A,(IY+$39)      ; sv S_POSN_x
L0B1E:  add a, (iy+$39)         ; sv S_POSN_x

line 3290:
    CP $21          ;
        cp      $21             ;

line 3291:
    LD A,($403A)        ; sv S_POSN_y
        ld      a, ($403A)      ; sv S_POSN_y

line 3292:
    SBC A,$01       ;
        sbc     a, $01          ;

line 3293:
    CALL L08FA      ; routine TEST-VAL
        call    L08FA           ; routine TEST-VAL

line 3294:
    SET 0,(IY+$01)      ; sv FLAGS  - Suppress leading space
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space

line 3295:
    JR L0B37        ; to PRINT-ON
        jr      L0B37           ; to PRINT-ON

line 3299:
L0B31:  CALL SCANNING       ; routine SCANNING
L0B31:  call SCANNING           ; routine SCANNING

line 3300:
    CALL L0B55      ; routine PRINT-STK
        call    L0B55           ; routine PRINT-STK

line 3303:
L0B37:  RST 18H         ; GET-CHAR
L0B37:  rst 18H                 ; GET-CHAR

line 3304:
    SUB $1A         ;
        sub     $1A             ;

line 3305:
    ADC A,$00       ;
        adc     a, $00          ;

line 3306:
    JR Z,L0B44      ; to SPACING
        jr      z, L0B44        ; to SPACING

line 3308:
    CALL L0D1D      ; routine CHECK-END
        call    L0D1D           ; routine CHECK-END

line 3310:
    JP L0B84        ; to PRINT-END
        jp      L0B84           ; to PRINT-END

line 3314:
L0B44:  CALL NC,L0B8B       ; routine FIELD
L0B44:  call nc, L0B8B          ; routine FIELD

line 3316:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 3317:
    CP $76          ;
        cp      $76             ;

line 3318:
    RET Z           ;
        ret     z               ;

line 3320:
    JP L0AD5        ; to PRINT-1
        jp      L0AD5           ; to PRINT-1

line 3324:
L0B4E:  CALL L0DA6      ; routine SYNTAX-Z
L0B4E:  call L0DA6              ; routine SYNTAX-Z

line 3325:
    RET NZ          ;
        ret     nz              ;

line 3327:
    POP HL          ;
        pop     hl              ;

line 3328:
    JR L0B37        ; to PRINT-ON
        jr      L0B37           ; to PRINT-ON

line 3332:
L0B55:  CALL L0AC5      ; routine UNSTACK-Z
L0B55:  call L0AC5              ; routine UNSTACK-Z

line 3333:
    BIT 6,(IY+$01)      ; sv FLAGS  - Numeric or string result?
        bit     6, (iy+$01)     ; sv FLAGS  - Numeric or string result?

line 3334:
    CALL Z,STK_FETCH    ; routine STK-FETCH
        call    z, STK_FETCH    ; routine STK-FETCH

line 3335:
    JR Z,L0B6B      ; to PR-STR-4
        jr      z, L0B6B        ; to PR-STR-4

line 3337:
    JP PRINT_FP     ; jump forward to PRINT-FP
        jp      PRINT_FP        ; jump forward to PRINT-FP

line 3341:
L0B64:  LD A,$0B        ;
L0B64:  ld a, $0B               ;

line 3344:
L0B66:  RST 10H         ; PRINT-A
L0B66:  rst 10H                 ; PRINT-A

line 3347:
L0B67:  LD DE,($4018)       ; sv X_PTR_lo
L0B67:  ld de, ($4018)          ; sv X_PTR_lo

line 3350:
L0B6B:  LD A,B          ;
L0B6B:  ld a, b                 ;

line 3351:
    OR C            ;
        or      c               ;

line 3352:
    DEC BC          ;
        dec     bc              ;

line 3353:
    RET Z           ;
        ret     z               ;

line 3355:
    LD A,(DE)       ;
        ld      a, (de)         ;

line 3356:
    INC DE          ;
        inc     de              ;

line 3357:
    LD ($4018),DE       ; sv X_PTR_lo
        ld      ($4018), de     ; sv X_PTR_lo

line 3358:
    BIT 6,A         ;
        bit     6, a            ;

line 3359:
    JR Z,L0B66      ; to PR-STR-2
        jr      z, L0B66        ; to PR-STR-2

line 3361:
    CP $C0          ;
        cp      $C0             ;

line 3362:
    JR Z,L0B64      ; to PR-STR-1
        jr      z, L0B64        ; to PR-STR-1

line 3364:
    PUSH BC         ;
        push    bc              ;

line 3365:
    CALL L094B      ; routine TOKENS
        call    L094B           ; routine TOKENS

line 3366:
    POP BC          ;
        pop     bc              ;

line 3367:
    JR L0B67        ; to PR-STR-3
        jr      L0B67           ; to PR-STR-3

line 3371:
L0B84:  CALL L0AC5      ; routine UNSTACK-Z
L0B84:  call L0AC5              ; routine UNSTACK-Z

line 3372:
    LD A,$76        ;
        ld      a, $76          ;

line 3374:
    RST 10H         ; PRINT-A
        rst     10H             ; PRINT-A

line 3375:
    RET             ;
        ret                     ;

line 3379:
L0B8B:  CALL L0AC5      ; routine UNSTACK-Z
L0B8B:  call L0AC5              ; routine UNSTACK-Z

line 3380:
    SET 0,(IY+$01)      ; sv FLAGS  - Suppress leading space
        set     0, (iy+$01)     ; sv FLAGS  - Suppress leading space

line 3381:
    XOR A           ;
        xor     a               ;

line 3383:
    RST 10H         ; PRINT-A
        rst     10H             ; PRINT-A

line 3384:
    LD BC,($4039)       ; sv S_POSN_x
        ld      bc, ($4039)     ; sv S_POSN_x

line 3385:
    LD A,C          ;
        ld      a, c            ;

line 3386:
    BIT 1,(IY+$01)      ; sv FLAGS  - Is printer in use
        bit     1, (iy+$01)     ; sv FLAGS  - Is printer in use

line 3387:
    JR Z,L0BA4      ; to CENTRE
        jr      z, L0BA4        ; to CENTRE

line 3389:
    LD A,$5D        ;
        ld      a, $5D          ;

line 3390:
    SUB (IY+$38)        ; sv PR_CC
        sub     (iy+$38)        ; sv PR_CC

line 3393:
L0BA4:  LD C,$11        ;
L0BA4:  ld c, $11               ;

line 3394:
    CP C            ;
        cp      c               ;

line 3395:
    JR NC,L0BAB     ; to RIGHT
        jr      nc, L0BAB       ; to RIGHT

line 3397:
    LD C,$01        ;
        ld      c, $01          ;

line 3401:
    jp L090B        ; return via routine SET-FIELD
        jp      L090B           ; return via routine SET-FIELD

line 3403:
    .db $FF         ; spare :D
        .db $FF                 ; spare :D

line 3414:
L0BAF:  CALL L0BF5      ; routine STK-TO-BC (B=Y, C=X)
L0BAF:  call L0BF5              ; routine STK-TO-BC (B=Y, C=X)

line 3415:
    LD ($4036),BC       ; save in sv COORDS
        ld      ($4036), bc     ; save in sv COORDS

line 3417:
    ld a,$04        ; set mosaic lower left
        ld      a, $04          ; set mosaic lower left

line 3418:
    SRA B           ; test odd values of Y
        sra     b               ; test odd values of Y

line 3419:
    JR NC,columns       ; skip if not (to COLUMNS)
        jr      nc, columns     ; skip if not (to COLUMNS)

line 3421:
    ld a,$01        ; else set mosaic upper left
        ld      a, $01          ; else set mosaic upper left

line 3425:
    SRA C           ; test odd values of X
        sra     c               ; test odd values of X

line 3426:
    JR NC,fnd_addr      ; skip if not (to FIND-ADDR)
        jr      nc, fnd_addr    ; skip if not (to FIND-ADDR)

line 3428:
    RLCA            ; else set mosaic upper/lower right
        rlca                    ; else set mosaic upper/lower right

line 3432:
    PUSH AF         ; save mosaic value
        push    af              ; save mosaic value

line 3434:
    ld a,$18        ; set limit of the line number (24)
        ld      a, $18          ; set limit of the line number (24)

line 3435:
    bit 4,(iy+$3B)      ; sv CDFLAG - test plot48 bit
        bit     4, (iy+$3B)     ; sv CDFLAG - test plot48 bit

line 3436:
    jr nz,plot_48       ; if set, then skip correction
        jr      nz, plot_48     ; if set, then skip correction

line 3438:
    inc b           ; else the origin will be at
        inc     b               ; else the origin will be at

line 3439:
    inc b           ; the beginning of line 21
        inc     b               ; the beginning of line 21

line 3441:
    inc b           ; check the limit value
        inc     b               ; check the limit value

line 3442:
    cp b            ; if it is over,
        cp      b               ; if it is over,

line 3443:
    jp c,L0EAD      ; then jump to REPORT-B
        jp      c, L0EAD        ; then jump to REPORT-B

line 3445:
    call prn_at_x       ; else test x, then return via LOC-ADDR
        call    prn_at_x        ; else test x, then return via LOC-ADDR

line 3447:
    LD A,(HL)       ; fetch character code from display file
        ld      a, (hl)         ; fetch character code from display file

line 3448:
    RLCA            ; test if it is a mosaic character
        rlca                    ; test if it is a mosaic character

line 3449:
    CP $10          ; (0..7)
        cp      $10             ; (0..7)

line 3450:
    JR NC,TABL_PTR      ; if not, then jump to TABLE-PTR
        jr      nc, TABL_PTR    ; if not, then jump to TABLE-PTR

line 3452:
    RRCA            ; test if it is an inverted mosaic char.
        rrca                    ; test if it is an inverted mosaic char.

line 3453:
    JR NC,SQ_SAVED      ; if not then skip (to SQ-SAVED)
        jr      nc, SQ_SAVED    ; if not then skip (to SQ-SAVED)

line 3455:
    XOR $8F         ; else swap bits
        xor     $8F             ; else swap bits

line 3459:
    LD B,A          ; and save in B
        ld      b, a            ; and save in B

line 3463:
    ld a,($4030)        ; fetch T_ADDR_lo
        ld      a, ($4030)      ; fetch T_ADDR_lo

line 3464:
    cp $9E          ; is P-UNPLOT?
        cp      $9E             ; is P-UNPLOT?

line 3465:
    jr c,to_plot        ; if not -> to PLOT
        jr      c, to_plot      ; if not -> to PLOT

line 3467:
    POP AF          ; restore the mosaic
        pop     af              ; restore the mosaic

line 3468:
    CPL         ; mask out
        cpl                     ; mask out

line 3469:
    AND B           ; the necessary bits
        and     b               ; the necessary bits

line 3470:
    JR to_unplt     ; forward to UNPLOT
        jr      to_unplt        ; forward to UNPLOT

line 3474:
    POP AF          ; restore the mosaic
        pop     af              ; restore the mosaic

line 3475:
    OR B            ; copy the necessary bits
        or      b               ; copy the necessary bits

line 3479:
    CP $08          ; must be inverted?
        cp      $08             ; must be inverted?

line 3480:
    jp plot_ext     ; continue in the new part
        jp      plot_ext        ; continue in the new part

line 3489:
L0BF5:  CALL L0C02      ; routine STK-TO-A
L0BF5:  call L0C02              ; routine STK-TO-A

line 3490:
    LD B,A          ;
        ld      b, a            ;

line 3491:
    PUSH BC         ;
        push    bc              ;

line 3492:
    CALL L0C02      ; routine STK-TO-A
        call    L0C02           ; routine STK-TO-A

line 3493:
    LD E,C          ;
        ld      e, c            ;

line 3494:
    POP BC          ;
        pop     bc              ;

line 3495:
    LD D,C          ;
        ld      d, c            ;

line 3496:
    LD C,A          ;
        ld      c, a            ;

line 3497:
    RET             ;
        ret                     ;

line 3504:
L0C02:  CALL FP_TO_A        ; routine FP-TO-A
L0C02:  call FP_TO_A            ; routine FP-TO-A

line 3505:
    JP C,L0EAD      ; to REPORT-B
        jp      c, L0EAD        ; to REPORT-B

line 3507:
    LD C,$01        ;
        ld      c, $01          ;

line 3508:
    RET Z           ;
        ret     z               ;

line 3510:
    LD C,$FF        ;
        ld      c, $FF          ;

line 3511:
    RET             ;
        ret                     ;

line 3520:
L0C0E:  LD B,(IY+$22)       ; fetch DF_SZ
L0C0E:  ld b, (iy+$22)          ; fetch DF_SZ

line 3522:
    ld a,$17        ; set A as counter of
        ld      a, $17          ; set A as counter of

line 3523:
    sub b           ; the lines to move
        sub     b               ; the lines to move

line 3524:
    push bc         ; save Y position (B)
        push    bc              ; save Y position (B)

line 3526:
    ld de,($400C)       ; address of the D-File
        ld      de, ($400C)     ; address of the D-File

line 3527:
    ld hl,33        ; HL points the end of
        ld      hl, 33          ; HL points the end of

line 3528:
    add hl,de       ; the 1st line
        add     hl, de          ; the 1st line

line 3530:
    bit 5,(IY+$3B)      ; test collapsed D-FILE
        bit     5, (iy+$3B)     ; test collapsed D-FILE

line 3532:
    call scrl_new       ; move lines
        call    scrl_new        ; move lines

line 3534:
    pop bc          ; restore the saved position
        pop     bc              ; restore the saved position

line 3535:
    inc b           ; the last printable line
        inc     b               ; the last printable line

line 3537:
    jp loc_pos0     ; ld c,$21 --> LOC-ADDR
        jp      loc_pos0        ; ld c,$21 --> LOC-ADDR

line 3538:
                ; set new S_POSN and DF_CC
                                ; set new S_POSN and DF_CC

line 3549:
L0C29:  DEFB L0CB4 - $  ; 8B offset to Address: P-LPRINT
L0C29:  defb L0CB4 - $          ; 8B offset to Address: P-LPRINT

line 3550:
    DEFB L0CB7 - $  ; 8D offset to Address: P-LLIST
        defb    L0CB7 - $       ; 8D offset to Address: P-LLIST

line 3551:
    DEFB L0C58 - $  ; 2D offset to Address: P-STOP
        defb    L0C58 - $       ; 2D offset to Address: P-STOP

line 3552:
    DEFB L0CAB - $  ; 7F offset to Address: P-SLOW
        defb    L0CAB - $       ; 7F offset to Address: P-SLOW

line 3553:
    DEFB L0CAE - $  ; 81 offset to Address: P-FAST
        defb    L0CAE - $       ; 81 offset to Address: P-FAST

line 3554:
    DEFB L0C77 - $  ; 49 offset to Address: P-NEW
        defb    L0C77 - $       ; 49 offset to Address: P-NEW

line 3555:
    DEFB L0CA4 - $  ; 75 offset to Address: P-SCROLL
        defb    L0CA4 - $       ; 75 offset to Address: P-SCROLL

line 3556:
    DEFB L0C8F - $  ; 5F offset to Address: P-CONT
        defb    L0C8F - $       ; 5F offset to Address: P-CONT

line 3557:
    DEFB L0C71 - $  ; 40 offset to Address: P-DIM
        defb    L0C71 - $       ; 40 offset to Address: P-DIM

line 3558:
    DEFB L0C74 - $  ; 42 offset to Address: P-REM
        defb    L0C74 - $       ; 42 offset to Address: P-REM

line 3559:
    DEFB L0C5E - $  ; 2B offset to Address: P-FOR
        defb    L0C5E - $       ; 2B offset to Address: P-FOR

line 3560:
    DEFB L0C4B - $  ; 17 offset to Address: P-GOTO
        defb    L0C4B - $       ; 17 offset to Address: P-GOTO

line 3561:
    DEFB L0C54 - $  ; 1F offset to Address: P-GOSUB
        defb    L0C54 - $       ; 1F offset to Address: P-GOSUB

line 3562:
    DEFB L0C6D - $  ; 37 offset to Address: P-INPUT
        defb    L0C6D - $       ; 37 offset to Address: P-INPUT

line 3563:
    DEFB L0C89 - $  ; 52 offset to Address: P-LOAD
        defb    L0C89 - $       ; 52 offset to Address: P-LOAD

line 3564:
    DEFB L0C7D - $  ; 45 offset to Address: P-LIST
        defb    L0C7D - $       ; 45 offset to Address: P-LIST

line 3565:
    DEFB L0C48 - $  ; 0F offset to Address: P-LET
        defb    L0C48 - $       ; 0F offset to Address: P-LET

line 3566:
    DEFB L0CA7 - $  ; 6D offset to Address: P-PAUSE
        defb    L0CA7 - $       ; 6D offset to Address: P-PAUSE

line 3567:
    DEFB L0C66 - $  ; 2B offset to Address: P-NEXT
        defb    L0C66 - $       ; 2B offset to Address: P-NEXT

line 3568:
    DEFB L0C80 - $  ; 44 offset to Address: P-POKE
        defb    L0C80 - $       ; 44 offset to Address: P-POKE

line 3569:
    DEFB L0C6A - $  ; 2D offset to Address: P-PRINT
        defb    L0C6A - $       ; 2D offset to Address: P-PRINT

line 3570:
    DEFB L0C98 - $  ; 5A offset to Address: P-PLOT
        defb    L0C98 - $       ; 5A offset to Address: P-PLOT

line 3571:
    DEFB L0C7A - $  ; 3B offset to Address: P-RUN
        defb    L0C7A - $       ; 3B offset to Address: P-RUN

line 3572:
    DEFB L0C8C - $  ; 4C offset to Address: P-SAVE
        defb    L0C8C - $       ; 4C offset to Address: P-SAVE

line 3573:
    DEFB L0C86 - $  ; 45 offset to Address: P-RAND
        defb    L0C86 - $       ; 45 offset to Address: P-RAND

line 3574:
    DEFB L0C4F - $  ; 0D offset to Address: P-IF
        defb    L0C4F - $       ; 0D offset to Address: P-IF

line 3575:
    DEFB L0C95 - $  ; 52 offset to Address: P-CLS
        defb    L0C95 - $       ; 52 offset to Address: P-CLS

line 3576:
    DEFB L0C9E - $  ; 5A offset to Address: P-UNPLOT
        defb    L0C9E - $       ; 5A offset to Address: P-UNPLOT

line 3577:
    DEFB L0C92 - $  ; 4D offset to Address: P-CLEAR
        defb    L0C92 - $       ; 4D offset to Address: P-CLEAR

line 3578:
    DEFB L0C5B - $  ; 15 offset to Address: P-RETURN
        defb    L0C5B - $       ; 15 offset to Address: P-RETURN

line 3579:
    DEFB L0CB1 - $  ; 6A offset to Address: P-COPY
        defb    L0CB1 - $       ; 6A offset to Address: P-COPY

line 3584:
L0C48:  DEFB $01    ; Class-01 - A variable is required.
L0C48:  defb $01                ; Class-01 - A variable is required.

line 3585:
    DEFB $14    ; Separator:    '='
        defb    $14             ; Separator:    '='

line 3586:
    DEFB $02    ; Class-02 - An expression, numeric or string,
        defb    $02             ; Class-02 - An expression, numeric or string,

line 3587:
            ; must follow.
                                ; must follow.

line 3590:
L0C4B:  DEFB $06    ; Class-06 - A numeric expression must follow.
L0C4B:  defb $06                ; Class-06 - A numeric expression must follow.

line 3591:
    DEFB $00    ; Class-00 - No further operands.
        defb    $00             ; Class-00 - No further operands.

line 3592:
    DEFW L0E81  ; Address: $0E81; Address: GOTO
        defw    L0E81           ; Address: $0E81; Address: GOTO

line 3595:
L0C4F:  DEFB $06    ; Class-06 - A numeric expression must follow.
L0C4F:  defb $06                ; Class-06 - A numeric expression must follow.

line 3596:
    DEFB $DE    ; Separator:    'THEN'
        defb    $de             ; Separator:    'THEN'

line 3597:
    DEFB $05    ; Class-05 - Variable syntax checked entirely
        defb    $05             ; Class-05 - Variable syntax checked entirely

line 3598:
            ; by routine.
                                ; by routine.

line 3599:
    DEFW L0DAB  ; Address: $0DAB; Address: IF
        defw    L0DAB           ; Address: $0DAB; Address: IF

line 3602:
L0C54:  DEFB $06    ; Class-06 - A numeric expression must follow.
L0C54:  defb $06                ; Class-06 - A numeric expression must follow.

line 3603:
    DEFB $00    ; Class-00 - No further operands.
        defb    $00             ; Class-00 - No further operands.

line 3604:
    DEFW L0EB5  ; Address: $0EB5; Address: GOSUB
        defw    L0EB5           ; Address: $0EB5; Address: GOSUB

line 3607:
L0C58:  DEFB $00    ; Class-00 - No further operands.
L0C58:  defb $00                ; Class-00 - No further operands.

line 3608:
    DEFW L0CDC  ; Address: $0CDC; Address: STOP
        defw    L0CDC           ; Address: $0CDC; Address: STOP

line 3611:
L0C5B:  DEFB $00    ; Class-00 - No further operands.
L0C5B:  defb $00                ; Class-00 - No further operands.

line 3612:
    DEFW L0ED8  ; Address: $0ED8; Address: RETURN
        defw    L0ED8           ; Address: $0ED8; Address: RETURN

line 3615:
L0C5E:  DEFB $04    ; Class-04 - A single character variable must
L0C5E:  defb $04                ; Class-04 - A single character variable must

line 3616:
            ; follow.
                                ; follow.

line 3617:
    DEFB $14    ; Separator:    '='
        defb    $14             ; Separator:    '='

line 3618:
    DEFB $06    ; Class-06 - A numeric expression must follow.
        defb    $06             ; Class-06 - A numeric expression must follow.

line 3619:
    DEFB $DF    ; Separator:    'TO'
        defb    $DF             ; Separator:    'TO'

line 3620:
    DEFB $06    ; Class-06 - A numeric expression must follow.
        defb    $06             ; Class-06 - A numeric expression must follow.

line 3621:
    DEFB $05    ; Class-05 - Variable syntax checked entirely
        defb    $05             ; Class-05 - Variable syntax checked entirely

line 3622:
            ; by routine.
                                ; by routine.

line 3623:
    DEFW L0DB9  ; Address: $0DB9; Address: FOR
        defw    L0DB9           ; Address: $0DB9; Address: FOR

line 3626:
L0C66:  DEFB $04    ; Class-04 - A single character variable must
L0C66:  defb $04                ; Class-04 - A single character variable must

line 3627:
            ; follow.
                                ; follow.

line 3628:
    DEFB $00    ; Class-00 - No further operands.
        defb    $00             ; Class-00 - No further operands.

line 3629:
    DEFW L0E2E  ; Address: $0E2E; Address: NEXT
        defw    L0E2E           ; Address: $0E2E; Address: NEXT

line 3632:
L0C6A:  DEFB $05    ; Class-05 - Variable syntax checked entirely
L0C6A:  defb $05                ; Class-05 - Variable syntax checked entirely

line 3633:
            ; by routine.
                                ; by routine.

line 3634:
    DEFW L0ACF  ; Address: $0ACF; Address: PRINT
        defw    L0ACF           ; Address: $0ACF; Address: PRINT

line 3637:
L0C6D:  DEFB $01    ; Class-01 - A variable is required.
L0C6D:  defb $01                ; Class-01 - A variable is required.

line 3638:
    DEFB $00    ; Class-00 - No further operands.
        defb    $00             ; Class-00 - No further operands.

line 3639:
    DEFW L0EE9  ; Address: $0EE9; Address: INPUT
        defw    L0EE9           ; Address: $0EE9; Address: INPUT

line 3642:
L0C71:  DEFB $05    ; Class-05 - Variable syntax checked entirely
L0C71:  defb $05                ; Class-05 - Variable syntax checked entirely

line 3643:
            ; by routine.
                                ; by routine.

line 3644:
    DEFW L1409  ; Address: $1409; Address: DIM
        defw    L1409           ; Address: $1409; Address: DIM

line 3647:
L0C74:  DEFB $05    ; Class-05 - Variable syntax checked entirely
L0C74:  defb $05                ; Class-05 - Variable syntax checked entirely

line 3648:
            ; by routine.
                                ; by routine.

line 3649:
    DEFW L0D6A  ; Address: $0D6A; Address: REM
        defw    L0D6A           ; Address: $0D6A; Address: REM

line 3652:
L0C77:  DEFB $00    ; Class-00 - No further operands.
L0C77:  defb $00                ; Class-00 - No further operands.

line 3653:
    DEFW L03C3  ; Address: $03C3; Address: NEW
        defw    L03C3           ; Address: $03C3; Address: NEW

line 3656:
L0C7A:  DEFB $03    ; Class-03 - A numeric expression may follow
L0C7A:  defb $03                ; Class-03 - A numeric expression may follow

line 3657:
            ; else default to zero.
                                ; else default to zero.

line 3658:
    DEFW L0EAF  ; Address: $0EAF; Address: RUN
        defw    L0EAF           ; Address: $0EAF; Address: RUN

line 3661:
L0C7D:  DEFB $03    ; Class-03 - A numeric expression may follow
L0C7D:  defb $03                ; Class-03 - A numeric expression may follow

line 3662:
            ; else default to zero.
                                ; else default to zero.

line 3663:
    DEFW L0730  ; Address: $0730; Address: LIST
        defw    L0730           ; Address: $0730; Address: LIST

line 3666:
L0C80:  DEFB $06    ; Class-06 - A numeric expression must follow.
L0C80:  defb $06                ; Class-06 - A numeric expression must follow.

line 3667:
    DEFB $1A    ; Separator:    ','
        defb    $1A             ; Separator:    ','

line 3668:
    DEFB $06    ; Class-06 - A numeric expression must follow.
        defb    $06             ; Class-06 - A numeric expression must follow.

line 3669:
    DEFB $00    ; Class-00 - No further operands.
        defb    $00             ; Class-00 - No further operands.

line 3670:
    DEFW L0E92  ; Address: $0E92; Address: POKE
        defw    L0E92           ; Address: $0E92; Address: POKE

line 3673:
L0C86:  DEFB $03    ; Class-03 - A numeric expression may follow
L0C86:  defb $03                ; Class-03 - A numeric expression may follow

line 3674:
            ; else default to zero.
                                ; else default to zero.

line 3675:
    DEFW L0E6C  ; Address: $0E6C; Address: RAND
        defw    L0E6C           ; Address: $0E6C; Address: RAND

line 3678:
L0C89:  DEFB $05    ; Class-05 - Variable syntax checked entirely
L0C89:  defb $05                ; Class-05 - Variable syntax checked entirely

line 3679:
            ; by routine.
                                ; by routine.

line 3680:
    DEFW L0340  ; Address: $0340; Address: LOAD
        defw    L0340           ; Address: $0340; Address: LOAD

line 3683:
L0C8C:  DEFB $05    ; Class-05 - Variable syntax checked entirely
L0C8C:  defb $05                ; Class-05 - Variable syntax checked entirely

line 3684:
            ; by routine.
                                ; by routine.

line 3685:
    DEFW L02F6  ; Address: $02F6; Address: SAVE
        defw    L02F6           ; Address: $02F6; Address: SAVE

line 3688:
L0C8F:  DEFB $00    ; Class-00 - No further operands.
L0C8F:  defb $00                ; Class-00 - No further operands.

line 3689:
    DEFW L0E7C  ; Address: $0E7C; Address: CONT
        defw    L0E7C           ; Address: $0E7C; Address: CONT

line 3692:
L0C92:  DEFB $00    ; Class-00 - No further operands.
L0C92:  defb $00                ; Class-00 - No further operands.

line 3693:
    DEFW L149A  ; Address: $149A; Address: CLEAR
        defw    L149A           ; Address: $149A; Address: CLEAR

line 3696:
L0C95:  DEFB $00    ; Class-00 - No further operands.
L0C95:  defb $00                ; Class-00 - No further operands.

line 3697:
    DEFW L0A2A  ; Address: $0A2A; Address: CLS
        defw    L0A2A           ; Address: $0A2A; Address: CLS

line 3700:
L0C98:  DEFB $06    ; Class-06 - A numeric expression must follow.
L0C98:  defb $06                ; Class-06 - A numeric expression must follow.

line 3701:
    DEFB $1A    ; Separator:    ','
        defb    $1A             ; Separator:    ','

line 3702:
    DEFB $06    ; Class-06 - A numeric expression must follow.
        defb    $06             ; Class-06 - A numeric expression must follow.

line 3703:
    DEFB $00    ; Class-00 - No further operands.
        defb    $00             ; Class-00 - No further operands.

line 3704:
    DEFW L0BAF  ; Address: $0BAF; Address: PLOT/UNP
        defw    L0BAF           ; Address: $0BAF; Address: PLOT/UNP

line 3707:
L0C9E:  DEFB $06    ; Class-06 - A numeric expression must follow.
L0C9E:  defb $06                ; Class-06 - A numeric expression must follow.

line 3708:
    DEFB $1A    ; Separator:    ','
        defb    $1A             ; Separator:    ','

line 3709:
    DEFB $06    ; Class-06 - A numeric expression must follow.
        defb    $06             ; Class-06 - A numeric expression must follow.

line 3710:
    DEFB $00    ; Class-00 - No further operands.
        defb    $00             ; Class-00 - No further operands.

line 3711:
    DEFW L0BAF  ; Address: $0BAF; Address: PLOT/UNP
        defw    L0BAF           ; Address: $0BAF; Address: PLOT/UNP

line 3714:
L0CA4:  DEFB $00    ; Class-00 - No further operands.
L0CA4:  defb $00                ; Class-00 - No further operands.

line 3715:
    DEFW L0C0E  ; Address: $0C0E; Address: SCROLL
        defw    L0C0E           ; Address: $0C0E; Address: SCROLL

line 3718:
L0CA7:  DEFB $06    ; Class-06 - A numeric expression must follow.
L0CA7:  defb $06                ; Class-06 - A numeric expression must follow.

line 3719:
    DEFB $00    ; Class-00 - No further operands.
        defb    $00             ; Class-00 - No further operands.

line 3720:
    DEFW L0F32  ; Address: $0F32; Address: PAUSE
        defw    L0F32           ; Address: $0F32; Address: PAUSE

line 3723:
L0CAB:  DEFB $00    ; Class-00 - No further operands.
L0CAB:  defb $00                ; Class-00 - No further operands.

line 3724:
    DEFW L0F2B  ; Address: $0F2B; Address: SLOW
        defw    L0F2B           ; Address: $0F2B; Address: SLOW

line 3727:
L0CAE:  DEFB $00    ; Class-00 - No further operands.
L0CAE:  defb $00                ; Class-00 - No further operands.

line 3728:
    DEFW L0F23  ; Address: $0F23; Address: FAST
        defw    L0F23           ; Address: $0F23; Address: FAST

line 3731:
L0CB1:  DEFB $00    ; Class-00 - No further operands.
L0CB1:  defb $00                ; Class-00 - No further operands.

line 3732:
    DEFW L0869  ; Address: $0869; Address: COPY
        defw    L0869           ; Address: $0869; Address: COPY

line 3735:
L0CB4:  DEFB $05    ; Class-05 - Variable syntax checked entirely
L0CB4:  defb $05                ; Class-05 - Variable syntax checked entirely

line 3736:
            ; by routine.
                                ; by routine.

line 3737:
    DEFW L0ACB  ; Address: $0ACB; Address: LPRINT
        defw    L0ACB           ; Address: $0ACB; Address: LPRINT

line 3740:
L0CB7:  DEFB $03    ; Class-03 - A numeric expression may follow
L0CB7:  defb $03                ; Class-03 - A numeric expression may follow

line 3741:
            ; else default to zero.
                                ; else default to zero.

line 3742:
    DEFW L072C  ; Address: $072C; Address: LLIST
        defw    L072C           ; Address: $072C; Address: LLIST

line 3749:
L0CBA:  LD (IY+$01),$01     ; sv FLAGS
L0CBA:  ld (iy+$01), $01        ; sv FLAGS

line 3750:
    CALL L0A73      ; routine E-LINE-NO
        call    L0A73           ; routine E-LINE-NO

line 3753:
L0CC1:  CALL L14BC      ; routine SET-MIN
L0CC1:  call L14BC              ; routine SET-MIN

line 3754:
    LD HL,$4000     ; sv ERR_NR
        ld      hl, $4000       ; sv ERR_NR

line 3755:
    LD (HL),$FF     ;
        ld      (hl), $FF       ;

line 3756:
    LD HL,$402D     ; sv FLAGX
        ld      hl, $402D       ; sv FLAGX

line 3757:
    BIT 5,(HL)      ;
        bit     5, (hl)         ;

line 3758:
    JR Z,L0CDE      ; to LINE-NULL
        jr      z, L0CDE        ; to LINE-NULL

line 3760:
    CP $E3          ; 'STOP' ?
        cp      $E3             ; 'STOP' ?

line 3761:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 3762:
    JP NZ,L0D6F     ; to INPUT-REP
        jp      nz, L0D6F       ; to INPUT-REP

line 3764:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 3765:
    RET Z           ;
        ret     z               ;

line 3767:
    RST 08H         ; ERROR-1
        rst     08H             ; ERROR-1

line 3768:
    DEFB $0C        ; Error Report: BREAK - CONT repeats
        defb    $0C             ; Error Report: BREAK - CONT repeats

line 3775:
L0CDC:  RST 08H         ; ERROR-1
L0CDC:  rst 08H                 ; ERROR-1

line 3776:
    DEFB $08        ; Error Report: STOP statement
        defb    $08             ; Error Report: STOP statement

line 3787:
L0CDE:  RST 18H         ; GET-CHAR
L0CDE:  rst 18H                 ; GET-CHAR

line 3788:
    LD B,$00        ; prepare to index - early.
        ld      b, $00          ; prepare to index - early.

line 3789:
    CP $76          ; compare to NEWLINE.
        cp      $76             ; compare to NEWLINE.

line 3790:
    RET Z           ; return if so.
        ret     z               ; return if so.

line 3792:
    LD C,A          ; transfer character to C.
        ld      c, a            ; transfer character to C.

line 3794:
    RST 20H         ; NEXT-CHAR advances.
        rst     20H             ; NEXT-CHAR advances.

line 3795:
    LD A,C          ; character to A
        ld      a, c            ; character to A

line 3796:
    SUB $E1         ; subtract 'LPRINT' - lowest command.
        sub     $E1             ; subtract 'LPRINT' - lowest command.

line 3797:
    JR C,L0D26      ; forward if less to REPORT-C2
        jr      c, L0D26        ; forward if less to REPORT-C2

line 3799:
    LD C,A          ; reduced token to C
        ld      c, a            ; reduced token to C

line 3800:
    LD HL,L0C29     ; set HL to address of offset table.
        ld      hl, L0C29       ; set HL to address of offset table.

line 3801:
    ADD HL,BC       ; index into offset table.
        add     hl, bc          ; index into offset table.

line 3802:
    LD C,(HL)       ; fetch offset
        ld      c, (hl)         ; fetch offset

line 3803:
    ADD HL,BC       ; index into parameter table.
        add     hl, bc          ; index into parameter table.

line 3804:
    JR L0CF7        ; to GET-PARAM
        jr      L0CF7           ; to GET-PARAM

line 3808:
L0CF4:  LD HL,($4030)       ; sv T_ADDR_lo
L0CF4:  ld hl, ($4030)          ; sv T_ADDR_lo

line 3813:
L0CF7:  LD A,(HL)       ;
L0CF7:  ld a, (hl)              ;

line 3814:
    INC HL          ;
        inc     hl              ;

line 3815:
    LD ($4030),HL       ; sv T_ADDR_lo
        ld      ($4030), hl     ; sv T_ADDR_lo

line 3817:
    LD BC,L0CF4     ; Address: SCAN-LOOP
        ld      bc, L0CF4       ; Address: SCAN-LOOP

line 3818:
    PUSH BC         ; is pushed on machine stack.
        push    bc              ; is pushed on machine stack.

line 3820:
    LD C,A          ;
        ld      c, a            ;

line 3821:
    CP $0B          ;
        cp      $0B             ;

line 3822:
    JR NC,L0D10     ; to SEPARATOR
        jr      nc, L0D10       ; to SEPARATOR

line 3824:
    LD HL,L0D16     ; class-tbl - the address of the class table.
        ld      hl, L0D16       ; class-tbl - the address of the class table.

line 3825:
    LD B,$00        ;
        ld      b, $00          ;

line 3826:
    ADD HL,BC       ;
        add     hl, bc          ;

line 3827:
    LD C,(HL)       ;
        ld      c, (hl)         ;

line 3828:
    ADD HL,BC       ;
        add     hl, bc          ;

line 3829:
    PUSH HL         ;
        push    hl              ;

line 3831:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 3832:
    RET             ; indirect jump to class routine and
        ret                     ; indirect jump to class routine and

line 3833:
                ; by subsequent RET to SCAN-LOOP.
                                ; by subsequent RET to SCAN-LOOP.

line 3840:
L0D10:  RST 18H         ; GET-CHAR
L0D10:  rst 18H                 ; GET-CHAR

line 3841:
    CP C            ;
        cp      c               ;

line 3842:
    JR NZ,L0D26     ; to REPORT-C2
        jr      nz, L0D26       ; to REPORT-C2

line 3843:
                ; 'Nonsense in BASIC'
                                ; 'Nonsense in BASIC'

line 3845:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 3846:
    RET             ; return
        ret                     ; return

line 3853:
L0D16:  DEFB L0D2D - $      ; 17 offset to Address: CLASS-0
L0D16:  defb L0D2D - $          ; 17 offset to Address: CLASS-0

line 3854:
    DEFB L0D3C - $      ; 25 offset to Address: CLASS-1
        defb    L0D3C - $       ; 25 offset to Address: CLASS-1

line 3855:
    DEFB L0D6B - $      ; 53 offset to Address: CLASS-2
        defb    L0D6B - $       ; 53 offset to Address: CLASS-2

line 3856:
    DEFB L0D28 - $      ; 0F offset to Address: CLASS-3
        defb    L0D28 - $       ; 0F offset to Address: CLASS-3

line 3857:
    DEFB L0D85 - $      ; 6B offset to Address: CLASS-4
        defb    L0D85 - $       ; 6B offset to Address: CLASS-4

line 3858:
    DEFB L0D2E - $      ; 13 offset to Address: CLASS-5
        defb    L0D2E - $       ; 13 offset to Address: CLASS-5

line 3859:
    DEFB CLASS_06 - $   ; 76 offset to Address: CLASS-6
        defb    CLASS_06 - $    ; 76 offset to Address: CLASS-6

line 3869:
L0D1D:  CALL L0DA6      ; routine SYNTAX-Z
L0D1D:  call L0DA6              ; routine SYNTAX-Z

line 3870:
    RET NZ          ; return in runtime.
        ret     nz              ; return in runtime.

line 3872:
    POP BC          ; else drop return address.
        pop     bc              ; else drop return address.

line 3874:
CHECK_2             ;(L0D22)
CHECK_2                         ;(L0D22)

line 3875:
    LD A,(HL)       ; fetch character.
        ld      a, (hl)         ; fetch character.

line 3876:
    CP $76          ; compare to NEWLINE.
        cp      $76             ; compare to NEWLINE.

line 3877:
    RET Z           ; return if so.
        ret     z               ; return if so.

line 3880:
L0D26:  JR L0D9A        ; to REPORT-C
L0D26:  jr L0D9A                ; to REPORT-C

line 3881:
                ; 'Nonsense in BASIC'
                                ; 'Nonsense in BASIC'

line 3888:
L0D28:  CP $76          ;
L0D28:  cp $76                  ;

line 3889:
    CALL L0D9C      ; routine NO-TO-STK
        call    L0D9C           ; routine NO-TO-STK

line 3892:
L0D2D:  CP A            ;
L0D2D:  cp a                    ;

line 3895:
L0D2E:  POP BC          ;
L0D2E:  pop bc                  ;

line 3896:
    CALL Z,L0D1D        ; routine CHECK-END
        call    z, L0D1D        ; routine CHECK-END

line 3897:
    EX DE,HL        ;
        ex      de, hl          ;

line 3898:
    LD HL,($4030)       ; sv T_ADDR_lo
        ld      hl, ($4030)     ; sv T_ADDR_lo

line 3899:
    LD C,(HL)       ;
        ld      c, (hl)         ;

line 3900:
    INC HL          ;
        inc     hl              ;

line 3901:
    LD B,(HL)       ;
        ld      b, (hl)         ;

line 3902:
    EX DE,HL        ;
        ex      de, hl          ;

line 3905:
L0D3A:  PUSH BC         ;
L0D3A:  push bc                 ;

line 3906:
    RET             ;
        ret                     ;

line 3913:
L0D3C:  CALL L111C      ; routine LOOK-VARS
L0D3C:  call L111C              ; routine LOOK-VARS

line 3916:
L0D3F:  LD (IY+$2D),$00     ; sv FLAGX
L0D3F:  ld (iy+$2D), $00        ; sv FLAGX

line 3917:
    JR NC,L0D4D     ; to SET-STK
        jr      nc, L0D4D       ; to SET-STK

line 3919:
    SET 1,(IY+$2D)      ; sv FLAGX
        set     1, (iy+$2D)     ; sv FLAGX

line 3920:
    JR NZ,L0D63     ; to SET-STRLN
        jr      nz, L0D63       ; to SET-STRLN

line 3923:
L0D4B:  RST 08H         ; ERROR-1
L0D4B:  rst 08H                 ; ERROR-1

line 3924:
    DEFB $01        ; Error Report: Variable not found
        defb    $01             ; Error Report: Variable not found

line 3928:
L0D4D:  CALL Z,L11A7        ; routine STK-VAR
L0D4D:  call z, L11A7           ; routine STK-VAR

line 3929:
    BIT 6,(IY+$01)      ; sv FLAGS  - Numeric or string result?
        bit     6, (iy+$01)     ; sv FLAGS  - Numeric or string result?

line 3930:
    JR NZ,L0D63     ; to SET-STRLN
        jr      nz, L0D63       ; to SET-STRLN

line 3932:
    XOR A           ;
        xor     a               ;

line 3933:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 3934:
    CALL NZ,STK_FETCH       ; routine STK-FETCH
        call    nz, STK_FETCH   ; routine STK-FETCH

line 3935:
    LD HL,$402D     ; sv FLAGX
        ld      hl, $402D       ; sv FLAGX

line 3936:
    OR (HL)         ;
        or      (hl)            ;

line 3937:
    LD (HL),A       ;
        ld      (hl), a         ;

line 3938:
    EX DE,HL        ;
        ex      de, hl          ;

line 3941:
L0D63:  LD ($402E),BC       ; sv STRLEN_lo
L0D63:  ld ($402E), bc          ; sv STRLEN_lo

line 3942:
    LD ($4012),HL       ; sv DEST-lo
        ld      ($4012), hl     ; sv DEST-lo

line 3949:
L0D6A:  RET             ;
L0D6A:  ret                     ;

line 3954:
L0D6B:  POP BC          ;
L0D6B:  pop bc                  ;

line 3955:
    LD A,($4001)        ; sv FLAGS
        ld      a, ($4001)      ; sv FLAGS

line 3958:
L0D6F:  PUSH AF         ;
L0D6F:  push af                 ;

line 3959:
    CALL SCANNING       ; routine SCANNING
        call    SCANNING        ; routine SCANNING

line 3960:
    POP AF          ;
        pop     af              ;

line 3961:
    LD BC,L1321     ; Address: LET
        ld      bc, L1321       ; Address: LET

line 3962:
    LD D,(IY+$01)       ; sv FLAGS
        ld      d, (iy+$01)     ; sv FLAGS

line 3963:
    XOR D           ;
        xor     d               ;

line 3964:
    AND $40         ;
        and     $40             ;

line 3965:
    JR NZ,L0D9A     ; to REPORT-C
        jr      nz, L0D9A       ; to REPORT-C

line 3967:
    BIT 7,D         ;
        bit     7, d            ;

line 3968:
    JR NZ,L0D3A     ; to CLASS-END
        jr      nz, L0D3A       ; to CLASS-END

line 3970:
    JR CHECK_2      ; to CHECK-2
        jr      CHECK_2         ; to CHECK-2

line 3974:
L0D85:  CALL L111C      ; routine LOOK-VARS
L0D85:  call L111C              ; routine LOOK-VARS

line 3975:
    PUSH AF         ;
        push    af              ;

line 3976:
    LD A,C          ;
        ld      a, c            ;

line 3977:
    OR $9F          ;
        or      $9F             ;

line 3978:
    INC A           ;
        inc     a               ;

line 3979:
    JR NZ,L0D9A     ; to REPORT-C
        jr      nz, L0D9A       ; to REPORT-C

line 3981:
    POP AF          ;
        pop     af              ;

line 3982:
    JR L0D3F        ; to CLASS-4-2
        jr      L0D3F           ; to CLASS-4-2

line 3985:
CLASS_06            ; (L0D92)
CLASS_06                        ; (L0D92)

line 3986:
    CALL SCANNING       ; routine SCANNING
        call    SCANNING        ; routine SCANNING

line 3987:
    BIT 6,(IY+$01)      ; sv FLAGS  - Numeric or string result?
        bit     6, (iy+$01)     ; sv FLAGS  - Numeric or string result?

line 3988:
    RET NZ          ;
        ret     nz              ;

line 3991:
L0D9A:  RST 08H         ; ERROR-1
L0D9A:  rst 08H                 ; ERROR-1

line 3992:
    DEFB $0B        ; Error Report: Nonsense in BASIC
        defb    $0B             ; Error Report: Nonsense in BASIC

line 3999:
L0D9C:  JR NZ,CLASS_06      ; back to CLASS-6 with a non-zero number.
L0D9C:  jr nz, CLASS_06         ; back to CLASS-6 with a non-zero number.

line 4001:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 4002:
    RET Z           ; return if checking syntax.
        ret     z               ; return if checking syntax.

line 4006:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 4007:
    DEFB $A0    ;;stk-zero
        defb    $A0             ;;stk-zero

line 4008:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 4010:
    RET             ; return.
        ret                     ; return.

line 4020:
L0DA6:  BIT 7,(IY+$01)      ; test FLAGS  - checking syntax only?
L0DA6:  bit 7, (iy+$01)         ; test FLAGS  - checking syntax only?

line 4021:
    RET             ; return.
        ret                     ; return.

line 4031:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 4032:
    jr z,if_end     ; forward if checking syntax to IF-END
        jr      z, if_end       ; forward if checking syntax to IF-END

line 4036:
    call STK_FETCH      ; routine STK-FETCH - exponent to A
        call    STK_FETCH       ; routine STK-FETCH - exponent to A

line 4037:
                ; mantissa to EDCB.
                                ; mantissa to EDCB.

line 4038:
    AND A           ; test exponent for zero - FALSE.
        and     a               ; test exponent for zero - FALSE.

line 4039:
    RET Z           ; return if so.
        ret     z               ; return if so.

line 4043:
    JP L0CDE        ; jump back to LINE-NULL
        jp      L0CDE           ; jump back to LINE-NULL

line 4045:
    .db $FF         ; spare
        .db $FF                 ; spare

line 4052:
L0DB9:  CP $E0          ; is current character 'STEP' ?
L0DB9:  cp $E0                  ; is current character 'STEP' ?

line 4053:
    JR NZ,L0DC6     ; forward if not to F-USE-ONE
        jr      nz, L0DC6       ; forward if not to F-USE-ONE

line 4056:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 4057:
    CALL CLASS_06       ; routine CLASS-6 stacks the number
        call    CLASS_06        ; routine CLASS-6 stacks the number

line 4058:
    CALL L0D1D      ; routine CHECK-END
        call    L0D1D           ; routine CHECK-END

line 4059:
    JR L0DCC        ; forward to F-REORDER
        jr      L0DCC           ; forward to F-REORDER

line 4063:
L0DC6:  CALL L0D1D      ; routine CHECK-END
L0DC6:  call L0D1D              ; routine CHECK-END

line 4065:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 4066:
    DEFB $A1    ;;stk-one
        defb    $A1             ;;stk-one

line 4067:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 4070:
L0DCC:  RST 28H     ;; FP-CALC  v, l, s.
L0DCC:  rst 28H                 ;; FP-CALC  v, l, s.

line 4071:
    DEFB $C0    ;;st-mem-0  v, l, s.
        defb    $C0             ;;st-mem-0  v, l, s.

line 4072:
    DEFB $02    ;;delete    v, l.
        defb    $02             ;;delete    v, l.

line 4073:
    DEFB $01    ;;exchange  l, v.
        defb    $01             ;;exchange  l, v.

line 4074:
    DEFB $E0    ;;get-mem-0 l, v, s.
        defb    $E0             ;;get-mem-0 l, v, s.

line 4075:
    DEFB $01    ;;exchange  l, s, v.
        defb    $01             ;;exchange  l, s, v.

line 4076:
    DEFB $34    ;;end-calc  l, s, v.
        defb    $34             ;;end-calc  l, s, v.

line 4078:
    CALL L1321      ; routine LET
        call    L1321           ; routine LET

line 4080:
    LD ($401F),HL       ; set MEM to address variable.
        ld      ($401F), hl     ; set MEM to address variable.

line 4081:
    DEC HL          ; point to letter.
        dec     hl              ; point to letter.

line 4082:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 4083:
    SET 7,(HL)      ;
        set     7, (hl)         ;

line 4084:
    LD BC,$0006     ;
        ld      bc, $0006       ;

line 4085:
    ADD HL,BC       ;
        add     hl, bc          ;

line 4086:
    RLCA            ;
        rlca                    ;

line 4087:
    JR C,L0DEA      ; to F-LMT-STP
        jr      c, L0DEA        ; to F-LMT-STP

line 4089:
    SLA C           ;
        sla     c               ;

line 4090:
    CALL L099E      ; routine MAKE-ROOM
        call    L099E           ; routine MAKE-ROOM

line 4091:
    INC HL          ;
        inc     hl              ;

line 4094:
L0DEA:  PUSH HL         ;
L0DEA:  push hl                 ;

line 4096:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 4097:
    DEFB $02    ;;delete
        defb    $02             ;;delete

line 4098:
    DEFB $02    ;;delete
        defb    $02             ;;delete

line 4099:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 4101:
    POP HL          ;
        pop     hl              ;

line 4102:
    EX DE,HL        ;
        ex      de, hl          ;

line 4104:
    LD C,$0A        ; ten bytes to be moved.
        ld      c, $0A          ; ten bytes to be moved.

line 4105:
    LDIR            ; copy bytes
        ldir                    ; copy bytes

line 4109:
    LD HL,($4029)       ; set HL to system variable NXTLIN current line.
        ld      hl, ($4029)     ; set HL to system variable NXTLIN current line.

line 4110:
    EX DE,HL        ; transfer to DE, variable pointer to HL.
        ex      de, hl          ; transfer to DE, variable pointer to HL.

line 4114:
    NOP         ;
        nop                     ;

line 4116:
    LD (HL),E       ;
        ld      (hl), e         ;

line 4117:
    INC HL          ;
        inc     hl              ;

line 4118:
    LD (HL),D       ;
        ld      (hl), d         ;

line 4119:
    CALL L0E5A      ; routine NEXT-LOOP considers an initial pass.
        call    L0E5A           ; routine NEXT-LOOP considers an initial pass.

line 4120:
    RET NC          ; return if possible.
        ret     nc              ; return if possible.

line 4124:
    BIT 7,(IY+$08)      ; test PPC_hi
        bit     7, (iy+$08)     ; test PPC_hi

line 4125:
    RET NZ          ; return if over 32767 ???
        ret     nz              ; return if over 32767 ???

line 4127:
    LD B,(IY+$2E)       ; fetch variable name from STRLEN_lo
        ld      b, (iy+$2E)     ; fetch variable name from STRLEN_lo

line 4128:
    RES 6,B         ; make a true letter.
        res     6, b            ; make a true letter.

line 4129:
    LD HL,($4029)       ; set HL from NXTLIN
        ld      hl, ($4029)     ; set HL from NXTLIN

line 4134:
L0E0E:  LD A,(HL)       ; fetch high byte of line number.
L0E0E:  ld a, (hl)              ; fetch high byte of line number.

line 4135:
    AND $C0         ; mask off low bits $3F
        and     $C0             ; mask off low bits $3F

line 4136:
    JR NZ,L0E2A     ; forward at end of program to FOR-END
        jr      nz, L0E2A       ; forward at end of program to FOR-END

line 4138:
    PUSH BC         ; save letter
        push    bc              ; save letter

line 4139:
    CALL L09F2      ; routine NEXT-ONE finds next line.
        call    L09F2           ; routine NEXT-ONE finds next line.

line 4140:
    POP BC          ; restore letter
        pop     bc              ; restore letter

line 4142:
    INC HL          ; step past low byte
        inc     hl              ; step past low byte

line 4143:
    INC HL          ; past the
        inc     hl              ; past the

line 4144:
    INC HL          ; line length.
        inc     hl              ; line length.

line 4145:
    CALL L004C      ; routine TEMP-PTR1 sets CH_ADD
        call    L004C           ; routine TEMP-PTR1 sets CH_ADD

line 4147:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 4148:
    CP $F3          ; compare to 'NEXT'.
        cp      $F3             ; compare to 'NEXT'.

line 4149:
    EX DE,HL        ; next line to HL.
        ex      de, hl          ; next line to HL.

line 4150:
    JR NZ,L0E0E     ; back with no match to NXTLIN-NO
        jr      nz, L0E0E       ; back with no match to NXTLIN-NO

line 4152:
    EX DE,HL        ; restore pointer.
        ex      de, hl          ; restore pointer.

line 4154:
    RST 20H         ; NEXT-CHAR advances and gets letter in A.
        rst     20H             ; NEXT-CHAR advances and gets letter in A.

line 4155:
    EX DE,HL        ; save pointer
        ex      de, hl          ; save pointer

line 4156:
    CP B            ; compare to variable name.
        cp      b               ; compare to variable name.

line 4157:
    JR NZ,L0E0E     ; back with mismatch to NXTLIN-NO
        jr      nz, L0E0E       ; back with mismatch to NXTLIN-NO

line 4161:
    JR L0E8E        ; to GOTO-3
        jr      L0E8E           ; to GOTO-3

line 4166:
    RST 08H         ; ERROR-1
        rst     08H             ; ERROR-1

line 4167:
    DEFB $00        ; Error Report: NEXT without FOR
        defb    $00             ; Error Report: NEXT without FOR

line 4174:
L0E2E:  BIT 1,(IY+$2D)      ; sv FLAGX
L0E2E:  bit 1, (iy+$2D)         ; sv FLAGX

line 4175:
    JP NZ,L0D4B     ; to REPORT-2
        jp      nz, L0D4B       ; to REPORT-2

line 4177:
    LD HL,($4012)       ; DEST (addr. of loop variable)
        ld      hl, ($4012)     ; DEST (addr. of loop variable)

line 4178:
    BIT 7,(HL)      ;
        bit     7, (hl)         ;

line 4179:
    jr z,L0E2C      ; to REPORT-1
        jr      z, L0E2C        ; to REPORT-1

line 4181:
    INC HL          ;
        inc     hl              ;

line 4182:
    LD ($401F),HL       ; set MEM to loop variable value
        ld      ($401F), hl     ; set MEM to loop variable value

line 4183:
                ; mem0: value, mem1: limit, mem2: step
                                ; mem0: value, mem1: limit, mem2: step

line 4185:
    ld de,$000A     ; offset to 'step'
        ld      de, $000A       ; offset to 'step'

line 4186:
    ex de,hl        ;
        ex      de, hl          ;

line 4187:
    add hl,de       ;
        add     hl, de          ;

line 4188:
    ex de,hl        ; HL points 'value', DE points 'step'
        ex      de, hl          ; HL points 'value', DE points 'step'

line 4189:
    call addition       ; new value = value + step
        call    addition        ; new value = value + step

line 4191:
    CALL L0E5A      ; test limit - routine NEXT-LOOP
        call    L0E5A           ; test limit - routine NEXT-LOOP

line 4193:
    RET C           ; if it has reached, then return
        ret     c               ; if it has reached, then return

line 4195:
    LD HL,($401F)       ; else fetch MEM (HL points 'value')
        ld      hl, ($401F)     ; else fetch MEM (HL points 'value')

line 4196:
    LD DE,$000F     ; offset to the starting address of the loop
        ld      de, $000F       ; offset to the starting address of the loop

line 4197:
    ADD HL,DE       ; HL now points the starting address
        add     hl, de          ; HL now points the starting address

line 4198:
    LD E,(HL)       ;
        ld      e, (hl)         ;

line 4199:
    INC HL          ;
        inc     hl              ;

line 4200:
    LD D,(HL)       ;
        ld      d, (hl)         ;

line 4201:
    EX DE,HL        ; HL now contains the starting address
        ex      de, hl          ; HL now contains the starting address

line 4205:
    JR L0E8E        ; to GOTO-3 (back to the beginning of the loop)
        jr      L0E8E           ; to GOTO-3 (back to the beginning of the loop)

line 4213:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 4215:
    .db $E0     ;;get-mem-0     value.
        .db $E0                 ;;get-mem-0     value.

line 4216:
    .db $E1     ;;get-mem-1     value, limit.
        .db $E1                 ;;get-mem-1     value, limit.

line 4218:
    DEFB $E2    ;;get-mem-2     value, limit, step.
        defb    $E2             ;;get-mem-2     value, limit, step.

line 4220:
    DEFB $32    ;;less-0        value, limit, 0/1.
        defb    $32             ;;less-0        value, limit, 0/1.

line 4221:
    DEFB $00    ;;jump-true     if 'step'<0
        defb    $00             ;;jump-true     if 'step'<0

line 4222:
    DEFB L0E62-$    ;;to LMT-V-VAL      then a=value, b=limit.
        defb    L0E62-$         ;;to LMT-V-VAL      then a=value, b=limit.

line 4224:
    DEFB $01    ;;exchange      else a=limit, b=value.
        defb    $01             ;;exchange      else a=limit, b=value.

line 4228:
    .db $02     ;;delete        a.
        .db $02                 ;;delete        a.

line 4229:
    .db $02     ;;delete        .
        .db $02                 ;;delete        .

line 4230:
    .db $34     ;;end-calc      the calculator stack is empty
        .db $34                 ;;end-calc      the calculator stack is empty

line 4232:
    ld hl,5         ; DE points 'a'
        ld      hl, 5           ; DE points 'a'

line 4233:
    add hl,de       ; HL points 'b'
        add     hl, de          ; HL points 'b'

line 4235:
    jp comp_num     ; return: if b>a then CY=1, else CY=0
        jp      comp_num        ; return: if b>a then CY=1, else CY=0

line 4247:
L0E6C:  CALL FIND_INT       ; routine FIND-INT
L0E6C:  call FIND_INT           ; routine FIND-INT

line 4248:
    LD A,B          ; test value
        ld      a, b            ; test value

line 4249:
    OR C            ; for zero
        or      c               ; for zero

line 4250:
    JR NZ,L0E77     ; forward if not zero to SET-SEED
        jr      nz, L0E77       ; forward if not zero to SET-SEED

line 4252:
    LD BC,($4034)       ; fetch value of FRAMES system variable.
        ld      bc, ($4034)     ; fetch value of FRAMES system variable.

line 4255:
L0E77:  LD  ($4032),BC      ; update the SEED system variable.
L0E77:  ld  ($4032), bc         ; update the SEED system variable.

line 4256:
    RET             ; return.
        ret                     ; return.

line 4266:
L0E7C:  LD HL,($402B)       ; set HL from system variable OLDPPC
L0E7C:  ld hl, ($402B)          ; set HL from system variable OLDPPC

line 4267:
    JR L0E86        ; forward to GOTO-2
        jr      L0E86           ; forward to GOTO-2

line 4277:
L0E81:  CALL FIND_INT       ; routine FIND-INT
L0E81:  call FIND_INT           ; routine FIND-INT

line 4278:
    LD H,B          ;
        ld      h, b            ;

line 4279:
    LD L,C          ;
        ld      l, c            ;

line 4282:
L0E86:  LD A,H          ;
L0E86:  ld a, h                 ;

line 4283:
    CP $F0          ;
        cp      $F0             ;

line 4284:
    JR NC,L0EAD     ; to REPORT-B
        jr      nc, L0EAD       ; to REPORT-B

line 4286:
    CALL L09D8      ; routine LINE-ADDR
        call    L09D8           ; routine LINE-ADDR

line 4290:
    LD ($4029),HL       ; sv NXTLIN
        ld      ($4029), hl     ; sv NXTLIN

line 4291:
    RET             ;
        ret                     ;

line 4299:
    call L0C02      ; routine STK-TO-A (with overflow check)
        call    L0C02           ; routine STK-TO-A (with overflow check)

line 4301:
    JR Z,L0E9B      ; forward, if positive, to POKE-SAVE
        jr      z, L0E9B        ; forward, if positive, to POKE-SAVE

line 4303:
    NEG         ; else negate
        neg                     ; else negate

line 4306:
L0E9B:  PUSH AF         ; preserve value.
L0E9B:  push af                 ; preserve value.

line 4307:
    CALL FIND_INT       ; routine FIND-INT gets address in BC
        call    FIND_INT        ; routine FIND-INT gets address in BC

line 4308:
                ; invoking the error routine with overflow
                                ; invoking the error routine with overflow

line 4309:
                ; or a negative number.
                                ; or a negative number.

line 4310:
    POP AF          ; restore value.
        pop     af              ; restore value.

line 4312:
    LD (BC),A       ; update the address contents.
        ld      (bc), a         ; update the address contents.

line 4313:
    RET             ; return.
        ret                     ; return.

line 4318:
    bit 7,(iy+$3B)      ; sv CDFLAG - test SLOW mode
        bit     7, (iy+$3B)     ; sv CDFLAG - test SLOW mode

line 4319:
    jp ffp_hook     ; forward
        jp      ffp_hook        ; forward

line 4325:
FIND_INT            ; (L0EA7)
FIND_INT                        ; (L0EA7)

line 4326:
    CALL L158A      ; routine FP-TO-BC
        call    L158A           ; routine FP-TO-BC

line 4327:
    JR C,L0EAD      ; forward with overflow to REPORT-B
        jr      c, L0EAD        ; forward with overflow to REPORT-B

line 4329:
    RET Z           ; return if positive (0-65535).
        ret     z               ; return if positive (0-65535).

line 4332:
L0EAD:  RST 08H         ; ERROR-1
L0EAD:  rst 08H                 ; ERROR-1

line 4333:
    DEFB $0A        ; Error Report: Integer out of range
        defb    $0A             ; Error Report: Integer out of range

line 4340:
L0EAF:  CALL L0E81      ; routine GOTO
L0EAF:  call L0E81              ; routine GOTO

line 4341:
    JP L149A        ; to CLEAR
        jp      L149A           ; to CLEAR

line 4350:
    LD HL,($4029)       ; sv NXTLIN_lo
        ld      hl, ($4029)     ; sv NXTLIN_lo

line 4351:
    NOP         ;
        nop                     ;

line 4352:
    EX (SP),HL      ;
        ex      (sp), hl        ;

line 4353:
    PUSH HL         ;
        push    hl              ;

line 4354:
    LD ($4002),SP       ; set the error stack pointer - ERR_SP
        ld      ($4002), sp     ; set the error stack pointer - ERR_SP

line 4355:
    CALL L0E81      ; routine GOTO
        call    L0E81           ; routine GOTO

line 4356:
    LD BC,$0006     ;
        ld      bc, $0006       ;

line 4362:
TEST_ROOM           ; (L0EC5)
TEST_ROOM                       ; (L0EC5)

line 4363:
    LD HL,($401C)       ; sv STKEND_lo
        ld      hl, ($401C)     ; sv STKEND_lo

line 4364:
    ADD HL,BC       ;
        add     hl, bc          ;

line 4365:
    JR C,L0ED3      ; to REPORT-4
        jr      c, L0ED3        ; to REPORT-4

line 4367:
    EX DE,HL        ;
        ex      de, hl          ;

line 4368:
    LD HL,$0024     ;
        ld      hl, $0024       ;

line 4369:
    ADD HL,DE       ;
        add     hl, de          ;

line 4370:
    SBC HL,SP       ;
        sbc     hl, sp          ;

line 4371:
    RET C           ;
        ret     c               ;

line 4374:
L0ED3:  LD L,$03        ;
L0ED3:  ld l, $03               ;

line 4375:
    JP L0058        ; to ERROR-3
        jp      L0058           ; to ERROR-3

line 4382:
L0ED8:  POP HL          ;
L0ED8:  pop hl                  ;

line 4383:
    EX (SP),HL      ;
        ex      (sp), hl        ;

line 4384:
    LD A,H          ;
        ld      a, h            ;

line 4385:
    CP $3E          ;
        cp      $3E             ;

line 4386:
    JR Z,L0EE5      ; to REPORT-7
        jr      z, L0EE5        ; to REPORT-7

line 4388:
    LD ($4002),SP       ; sv ERR_SP_lo
        ld      ($4002), sp     ; sv ERR_SP_lo

line 4392:
    JR L0E8E        ; back to GOTO-3
        jr      L0E8E           ; back to GOTO-3

line 4395:
L0EE5:  EX (SP),HL      ;
L0EE5:  ex (sp), hl             ;

line 4396:
    PUSH HL         ;
        push    hl              ;

line 4398:
    RST 08H         ; ERROR-1
        rst     08H             ; ERROR-1

line 4399:
    DEFB $06        ; Error Report: RETURN without GOSUB
        defb    $06             ; Error Report: RETURN without GOSUB

line 4406:
L0EE9:  BIT 7,(IY+$08)      ; sv PPC_hi
L0EE9:  bit 7, (iy+$08)         ; sv PPC_hi

line 4407:
    JR NZ,L0F21     ; to REPORT-8
        jr      nz, L0F21       ; to REPORT-8

line 4409:
    CALL L14A3      ; routine X-TEMP
        call    L14A3           ; routine X-TEMP

line 4410:
    LD HL,$402D     ; sv FLAGX
        ld      hl, $402D       ; sv FLAGX

line 4411:
    SET 5,(HL)      ;
        set     5, (hl)         ;

line 4412:
    RES 6,(HL)      ;
        res     6, (hl)         ;

line 4413:
    LD A,($4001)        ; sv FLAGS
        ld      a, ($4001)      ; sv FLAGS

line 4414:
    AND $40         ;
        and     $40             ;

line 4415:
    LD BC,$0002     ;
        ld      bc, $0002       ;

line 4416:
    JR NZ,L0F05     ; to PROMPT
        jr      nz, L0F05       ; to PROMPT

line 4418:
    LD C,$04        ;
        ld      c, $04          ;

line 4421:
L0F05:  OR (HL)         ;
L0F05:  or (hl)                 ;

line 4422:
    LD (HL),A       ; sv FLAGX
        ld      (hl), a         ; sv FLAGX

line 4424:
    RST 30H         ; BC-SPACES
        rst     30H             ; BC-SPACES

line 4425:
    LD (HL),$76     ;
        ld      (hl), $76       ;

line 4426:
    LD A,C          ;
        ld      a, c            ;

line 4427:
    RRCA            ;
        rrca                    ;

line 4428:
    RRCA            ;
        rrca                    ;

line 4429:
    JR C,L0F14      ; to ENTER-CUR
        jr      c, L0F14        ; to ENTER-CUR

line 4431:
    LD A,$0B        ;
        ld      a, $0B          ;

line 4432:
    LD (DE),A       ;
        ld      (de), a         ;

line 4433:
    DEC HL          ;
        dec     hl              ;

line 4434:
    LD (HL),A       ;
        ld      (hl), a         ;

line 4437:
L0F14:  DEC HL          ;
L0F14:  dec hl                  ;

line 4438:
    LD (HL),$7F     ;
        ld      (hl), $7F       ;

line 4439:
    LD HL,($4039)       ; sv S_POSN_x
        ld      hl, ($4039)     ; sv S_POSN_x

line 4440:
    LD ($4030),HL       ; sv T_ADDR_lo
        ld      ($4030), hl     ; sv T_ADDR_lo

line 4441:
    POP HL          ;
        pop     hl              ;

line 4442:
    JP L0472        ; to LOWER
        jp      L0472           ; to LOWER

line 4446:
L0F21:  RST 08H         ; ERROR-1
L0F21:  rst 08H                 ; ERROR-1

line 4447:
    DEFB $07        ; Error Report: End of file
        defb    $07             ; Error Report: End of file

line 4454:
L0F23:  CALL L02E7      ; routine SET-FAST
L0F23:  call L02E7              ; routine SET-FAST

line 4455:
    RES 6,(IY+$3B)      ; sv CDFLAG
        res     6, (iy+$3B)     ; sv CDFLAG

line 4456:
    RET             ; return.
        ret                     ; return.

line 4463:
L0F2B:  SET 6,(IY+$3B)      ; sv CDFLAG
L0F2B:  set 6, (iy+$3B)         ; sv CDFLAG

line 4464:
    JP L0207        ; to SLOW/FAST
        jp      L0207           ; to SLOW/FAST

line 4472:
    CALL FIND_INT       ; routine FIND-INT
        call    FIND_INT        ; routine FIND-INT

line 4474:
    call ffp_test       ; flicker free PAUSE (in SLOW mode)
        call    ffp_test        ; flicker free PAUSE (in SLOW mode)

line 4476:
    ld a,h          ; test if HL is
        ld      a, h            ; test if HL is

line 4477:
    or l            ; already zero
        or      l               ; already zero

line 4478:
    jr z,ffp_quit       ; done?
        jr      z, ffp_quit     ; done?

line 4480:
    bit 0,(IY+$3B)      ; test CDFLAG
        bit     0, (iy+$3B)     ; test CDFLAG

line 4481:
    jr z,wt_frame       ; back if no keypress
        jr      z, wt_frame     ; back if no keypress

line 4483:
    ld (iy+$35),$FF     ; set FRAMES_hi
        ld      (iy+$35), $FF   ; set FRAMES_hi

line 4484:
                ; return via  BREAK/DEBOUNCE
                                ; return via  BREAK/DEBOUNCE

line 4491:
L0F46:  LD A,$7F        ; read port $7FFE - keys B,N,M,.,SPACE.
L0F46:  ld a, $7F               ; read port $7FFE - keys B,N,M,.,SPACE.

line 4492:
    IN A,($FE)      ;
        in      a, ($FE)        ;

line 4493:
    RRA         ; carry will be set if space not pressed.
        rra                     ; carry will be set if space not pressed.

line 4500:
L0F4B:  RES 0,(IY+$3B)      ; update system variable CDFLAG
L0F4B:  res 0, (iy+$3B)         ; update system variable CDFLAG

line 4501:
    LD A,$FF        ;
        ld      a, $FF          ;

line 4502:
    LD ($4027),A        ; update system variable DEBOUNCE
        ld      ($4027), a      ; update system variable DEBOUNCE

line 4503:
    RET             ; return.
        ret                     ; return.

line 4513:
SCANNING            ; (L0F55)
SCANNING                        ; (L0F55)

line 4514:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 4515:
    LD B,$00        ; set B register to zero.
        ld      b, $00          ; set B register to zero.

line 4516:
    PUSH BC         ; stack zero as a priority end-marker.
        push    bc              ; stack zero as a priority end-marker.

line 4519:
L0F59:  CP $40          ; compare to the 'RND' character
L0F59:  cp $40                  ; compare to the 'RND' character

line 4520:
    JR NZ,L0F8C     ; forward, if not, to S-TEST-PI
        jr      nz, L0F8C       ; forward, if not, to S-TEST-PI

line 4526:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 4527:
    jr z,L0F99      ; forward if checking syntax to S-PI-END
        jr      z, L0F99        ; forward if checking syntax to S-PI-END

line 4529:
    LD BC,($4032)       ; sv SEED_lo
        ld      bc, ($4032)     ; sv SEED_lo

line 4530:
    CALL STACK_BC       ; routine STACK-BC
        call    STACK_BC        ; routine STACK-BC

line 4532:
    RST 28H      ;; FP-CALC
        rst     28H             ;; FP-CALC

line 4533:
    DEFB $A1     ;;stk-one
        defb    $A1             ;;stk-one

line 4534:
    DEFB $0F     ;;addition
        defb    $0F             ;;addition

line 4535:
    DEFB $30     ;;stk-data
        defb    $30             ;;stk-data

line 4536:
    DEFB $37     ;;Exponent: $87, Bytes: 1
        defb    $37             ;;Exponent: $87, Bytes: 1

line 4537:
    DEFB $16     ;;(+00,+00,+00)
        defb    $16             ;;(+00,+00,+00)

line 4538:
    DEFB $04     ;;multiply
        defb    $04             ;;multiply

line 4539:
    DEFB $30     ;;stk-data
        defb    $30             ;;stk-data

line 4540:
    DEFB $80     ;;Bytes: 3
        defb    $80             ;;Bytes: 3

line 4541:
    DEFB $41     ;;Exponent $91
        defb    $41             ;;Exponent $91

line 4542:
    DEFB $00,$00,$80 ;;(+00)
        defb    $00, $00, $80   ;;(+00)

line 4543:
    DEFB $2E     ;;n-mod-m
        defb    $2E             ;;n-mod-m

line 4544:
    DEFB $02     ;;delete
        defb    $02             ;;delete

line 4546:
    .db $39      ;;sub-one macro
        .db $39                 ;;sub-one macro

line 4548:
    DEFB $2D     ;;duplicate
        defb    $2D             ;;duplicate

line 4549:
    DEFB $34     ;;end-calc
        defb    $34             ;;end-calc

line 4551:
    CALL L158A      ; routine FP-TO-BC
        call    L158A           ; routine FP-TO-BC

line 4552:
    LD ($4032),BC       ; update the SEED system variable.
        ld      ($4032), bc     ; update the SEED system variable.

line 4553:
    LD A,(HL)       ; HL addresses the exponent of the last value.
        ld      a, (hl)         ; HL addresses the exponent of the last value.

line 4554:
    AND A           ; test for zero
        and     a               ; test for zero

line 4555:
    jr z,L0F99      ; forward, if so, to S-PI-END
        jr      z, L0F99        ; forward, if so, to S-PI-END

line 4557:
    SUB $10         ; else reduce exponent by sixteen
        sub     $10             ; else reduce exponent by sixteen

line 4558:
    LD (HL),A       ; thus dividing by 65536 for last value.
        ld      (hl), a         ; thus dividing by 65536 for last value.

line 4560:
    JR L0F99        ; forward to S-PI-END
        jr      L0F99           ; forward to S-PI-END

line 4562:
    .db $FF         ; spare
        .db $FF                 ; spare

line 4566:
L0F8C:  CP $42          ; the 'PI' character
L0F8C:  cp $42                  ; the 'PI' character

line 4567:
    JR NZ,L0F9D     ; forward, if not, to S-TST-INK
        jr      nz, L0F9D       ; forward, if not, to S-TST-INK

line 4573:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 4574:
    JR Z,L0F99      ; forward if checking syntax to S-PI-END
        jr      z, L0F99        ; forward if checking syntax to S-PI-END

line 4576:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 4577:
    DEFB $A3    ;;stk-pi/2
        defb    $A3             ;;stk-pi/2

line 4578:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 4580:
    INC (HL)        ; double the exponent giving PI on the stack.
        inc     (hl)            ; double the exponent giving PI on the stack.

line 4583:
L0F99:  RST 20H         ; NEXT-CHAR advances character pointer.
L0F99:  rst 20H                 ; NEXT-CHAR advances character pointer.

line 4585:
    JP L1083        ; jump forward to S-NUMERIC to set the flag
        jp      L1083           ; jump forward to S-NUMERIC to set the flag

line 4586:
                ; to signal numeric result before advancing.
                                ; to signal numeric result before advancing.

line 4590:
L0F9D:  CP $41          ; compare to character 'INKEY$'
L0F9D:  cp $41                  ; compare to character 'INKEY$'

line 4591:
    JR NZ,L0FB2     ; forward, if not, to S-ALPHANUM
        jr      nz, L0FB2       ; forward, if not, to S-ALPHANUM

line 4597:
    CALL L02BB      ; routine KEYBOARD
        call    L02BB           ; routine KEYBOARD

line 4598:
    LD B,H          ;
        ld      b, h            ;

line 4599:
    LD C,L          ;
        ld      c, l            ;

line 4600:
    LD D,C          ;
        ld      d, c            ;

line 4601:
    INC D           ;
        inc     d               ;

line 4602:
    CALL NZ,L07BD       ; routine DECODE
        call    nz, L07BD       ; routine DECODE

line 4603:
    LD A,D          ;
        ld      a, d            ;

line 4604:
    ADC A,D         ;
        adc     a, d            ;

line 4605:
    LD B,D          ;
        ld      b, d            ;

line 4606:
    LD C,A          ;
        ld      c, a            ;

line 4607:
    EX DE,HL        ;
        ex      de, hl          ;

line 4608:
    JR L0FED        ; forward to S-STRING
        jr      L0FED           ; forward to S-STRING

line 4612:
L0FB2:  CALL L14D2      ; routine ALPHANUM
L0FB2:  call L14D2              ; routine ALPHANUM

line 4613:
    JR C,L1025      ; forward, if alphanumeric to S-LTR-DGT
        jr      c, L1025        ; forward, if alphanumeric to S-LTR-DGT

line 4615:
    CP $1B          ; is character a '.' ?
        cp      $1B             ; is character a '.' ?

line 4616:
    JP Z,L1047      ; jump forward if so to S-DECIMAL
        jp      z, L1047        ; jump forward if so to S-DECIMAL

line 4618:
    LD BC,$09D8     ; prepare priority 09, operation 'subtract'
        ld      bc, $09D8       ; prepare priority 09, operation 'subtract'

line 4619:
    CP $16          ; is character unary minus '-' ?
        cp      $16             ; is character unary minus '-' ?

line 4620:
    JR Z,L1020      ; forward, if so, to S-PUSH-PO
        jr      z, L1020        ; forward, if so, to S-PUSH-PO

line 4622:
    CP $10          ; is character a '(' ?
        cp      $10             ; is character a '(' ?

line 4623:
    JR NZ,L0FD6     ; forward if not to S-QUOTE
        jr      nz, L0FD6       ; forward if not to S-QUOTE

line 4625:
    CALL L0049      ; routine CH-ADD+1 advances character pointer.
        call    L0049           ; routine CH-ADD+1 advances character pointer.

line 4627:
    CALL SCANNING       ; recursively call routine SCANNING to
        call    SCANNING        ; recursively call routine SCANNING to

line 4628:
                ; evaluate the sub-expression.
                                ; evaluate the sub-expression.

line 4630:
    CP $11          ; is subsequent character a ')' ?
        cp      $11             ; is subsequent character a ')' ?

line 4631:
    JR NZ,L0FFF     ; forward if not to S-RPT-C
        jr      nz, L0FFF       ; forward if not to S-RPT-C

line 4634:
    CALL L0049      ; routine CH-ADD+1  advances.
        call    L0049           ; routine CH-ADD+1  advances.

line 4635:
    JR L0FF8        ; relative jump to S-JP-CONT3 and then S-CONT3
        jr      L0FF8           ; relative jump to S-JP-CONT3 and then S-CONT3

line 4642:
L0FD6:  CP $0B          ; is character a quote (") ?
L0FD6:  cp $0B                  ; is character a quote (") ?

line 4643:
    JR NZ,L1002     ; forward, if not, to S-FUNCTION
        jr      nz, L1002       ; forward, if not, to S-FUNCTION

line 4645:
    CALL L0049      ; routine CH-ADD+1 advances
        call    L0049           ; routine CH-ADD+1 advances

line 4646:
    PUSH HL         ; * save start of string.
        push    hl              ; * save start of string.

line 4647:
    JR L0FE3        ; forward to S-QUOTE-S
        jr      L0FE3           ; forward to S-QUOTE-S

line 4651:
L0FE0:  CALL L0049      ; routine CH-ADD+1
L0FE0:  call L0049              ; routine CH-ADD+1

line 4654:
L0FE3:  CP $0B          ; is character a '"' ?
L0FE3:  cp $0B                  ; is character a '"' ?

line 4655:
    JR NZ,L0FFB     ; forward if not to S-Q-NL
        jr      nz, L0FFB       ; forward if not to S-Q-NL

line 4657:
    POP DE          ; * retrieve start of string
        pop     de              ; * retrieve start of string

line 4658:
    AND A           ; prepare to subtract.
        and     a               ; prepare to subtract.

line 4659:
    SBC HL,DE       ; subtract start from current position.
        sbc     hl, de          ; subtract start from current position.

line 4660:
    LD B,H          ; transfer this length
        ld      b, h            ; transfer this length

line 4661:
    LD C,L          ; to the BC register pair.
        ld      c, l            ; to the BC register pair.

line 4664:
L0FED:  LD HL,$4001     ; address system variable FLAGS
L0FED:  ld hl, $4001            ; address system variable FLAGS

line 4665:
    RES 6,(HL)      ; signal string result
        res     6, (hl)         ; signal string result

line 4666:
    BIT 7,(HL)      ; test if checking syntax.
        bit     7, (hl)         ; test if checking syntax.

line 4668:
    CALL NZ,STK_ST_s    ; in run-time routine STK-STO-$ stacks the
        call    nz, STK_ST_s    ; in run-time routine STK-STO-$ stacks the

line 4669:
                ; string descriptor - start DE, length BC.
                                ; string descriptor - start DE, length BC.

line 4671:
    RST 20H         ; NEXT-CHAR advances pointer.
        rst     20H             ; NEXT-CHAR advances pointer.

line 4674:
L0FF8:  JP L1088        ; jump to S-CONT-3
L0FF8:  jp L1088                ; jump to S-CONT-3

line 4679:
L0FFB:  CP $76          ; compare to NEWLINE
L0FFB:  cp $76                  ; compare to NEWLINE

line 4680:
    JR NZ,L0FE0     ; loop back if not to S-Q-AGAIN
        jr      nz, L0FE0       ; loop back if not to S-Q-AGAIN

line 4683:
L0FFF:  JP L0D9A        ; to REPORT-C
L0FFF:  jp L0D9A                ; to REPORT-C

line 4688:
L1002:  SUB $C4         ; subtract 'CODE' reducing codes
L1002:  sub $C4                 ; subtract 'CODE' reducing codes

line 4689:
                ; CODE thru '<>' to range $00 - $XX
                                ; CODE thru '<>' to range $00 - $XX

line 4690:
    JR C,L0FFF      ; back, if less, to S-RPT-C
        jr      c, L0FFF        ; back, if less, to S-RPT-C

line 4694:
    LD BC,$04EC     ; prepare priority $04, operation 'not'
        ld      bc, $04EC       ; prepare priority $04, operation 'not'

line 4695:
    CP $13          ; compare to 'NOT'  ( - CODE)
        cp      $13             ; compare to 'NOT'  ( - CODE)

line 4696:
    JR Z,L1020      ; forward, if so, to S-PUSH-PO
        jr      z, L1020        ; forward, if so, to S-PUSH-PO

line 4698:
    JR NC,L0FFF     ; back with anything higher to S-RPT-C
        jr      nc, L0FFF       ; back with anything higher to S-RPT-C

line 4702:
    LD B,$10        ; priority sixteen binds all functions to
        ld      b, $10          ; priority sixteen binds all functions to

line 4703:
                ; arguments removing the need for brackets.
                                ; arguments removing the need for brackets.

line 4705:
    ADD A,$D9       ; add $D9 to give range $D9 thru $EB
        add     a, $D9          ; add $D9 to give range $D9 thru $EB

line 4706:
                ; bit 6 is set to show numeric argument.
                                ; bit 6 is set to show numeric argument.

line 4707:
                ; bit 7 is set to show numeric result.
                                ; bit 7 is set to show numeric result.

line 4711:
    LD C,A          ; save code in C
        ld      c, a            ; save code in C

line 4713:
    CP $DC          ; separate 'CODE', 'VAL', 'LEN'
        cp      $DC             ; separate 'CODE', 'VAL', 'LEN'

line 4714:
    JR NC,L101A     ; skip forward if string operand to S-NO-TO-$
        jr      nc, L101A       ; skip forward if string operand to S-NO-TO-$

line 4716:
    RES 6,C         ; signal string operand.
        res     6, c            ; signal string operand.

line 4719:
L101A:  CP $EA          ; isolate top of range 'STR$' and 'CHR$'
L101A:  cp $EA                  ; isolate top of range 'STR$' and 'CHR$'

line 4720:
    JR C,L1020      ; skip forward with others to S-PUSH-PO
        jr      c, L1020        ; skip forward with others to S-PUSH-PO

line 4722:
    RES 7,C         ; signal string result.
        res     7, c            ; signal string result.

line 4725:
L1020:  PUSH BC         ; push the priority/operation
L1020:  push bc                 ; push the priority/operation

line 4727:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 4728:
    JP L0F59        ; jump back to S-LOOP-1
        jp      L0F59           ; jump back to S-LOOP-1

line 4732:
L1025:  CP $26          ; compare to 'A'.
L1025:  cp $26                  ; compare to 'A'.

line 4733:
    JR C,L1047      ; forward if less to S-DECIMAL
        jr      c, L1047        ; forward if less to S-DECIMAL

line 4735:
    CALL L111C      ; routine LOOK-VARS
        call    L111C           ; routine LOOK-VARS

line 4736:
    JP C,L0D4B      ; back if not found to REPORT-2
        jp      c, L0D4B        ; back if not found to REPORT-2

line 4737:
                ; a variable is always 'found' when checking
                                ; a variable is always 'found' when checking

line 4738:
                ; syntax.
                                ; syntax.

line 4740:
    CALL Z,L11A7        ; routine STK-VAR stacks string parameters or
        call    z, L11A7        ; routine STK-VAR stacks string parameters or

line 4741:
                ; returns cell location if numeric.
                                ; returns cell location if numeric.

line 4743:
    LD A,($4001)        ; fetch FLAGS
        ld      a, ($4001)      ; fetch FLAGS

line 4744:
    CP $C0          ; compare to numeric result/numeric operand
        cp      $C0             ; compare to numeric result/numeric operand

line 4745:
    JR C,L1087      ; forward if not numeric to S-CONT-2
        jr      c, L1087        ; forward if not numeric to S-CONT-2

line 4747:
    INC HL          ; address numeric contents of variable.
        inc     hl              ; address numeric contents of variable.

line 4748:
    LD DE,($401C)       ; set destination to STKEND
        ld      de, ($401C)     ; set destination to STKEND

line 4749:
    CALL COPY_FP        ; routine COPY-FP stacks the five bytes
        call    COPY_FP         ; routine COPY-FP stacks the five bytes

line 4750:
    EX DE,HL        ; transfer new free location from DE to HL.
        ex      de, hl          ; transfer new free location from DE to HL.

line 4751:
    LD ($401C),HL       ; update STKEND system variable.
        ld      ($401C), hl     ; update STKEND system variable.

line 4752:
    JR L1087        ; forward to S-CONT-2
        jr      L1087           ; forward to S-CONT-2

line 4763:
L1047:  CALL L0DA6      ; routine SYNTAX-Z
L1047:  call L0DA6              ; routine SYNTAX-Z

line 4764:
    JR NZ,L106F     ; forward in run-time to S-STK-DEC
        jr      nz, L106F       ; forward in run-time to S-STK-DEC

line 4766:
    CALL L14D9      ; routine DEC-TO-FP
        call    L14D9           ; routine DEC-TO-FP

line 4768:
    RST 18H         ; GET-CHAR advances HL past digits
        rst     18H             ; GET-CHAR advances HL past digits

line 4769:
    LD BC,$0006     ; six locations are required.
        ld      bc, $0006       ; six locations are required.

line 4770:
    CALL L099E      ; routine MAKE-ROOM
        call    L099E           ; routine MAKE-ROOM

line 4771:
    INC HL          ; point to first new location
        inc     hl              ; point to first new location

line 4772:
    LD (HL),$7E     ; insert the number marker 126 decimal.
        ld      (hl), $7E       ; insert the number marker 126 decimal.

line 4773:
    INC HL          ; increment
        inc     hl              ; increment

line 4774:
    EX DE,HL        ; transfer destination to DE.
        ex      de, hl          ; transfer destination to DE.

line 4775:
    LD HL,($401C)       ; set HL from STKEND which points to the
        ld      hl, ($401C)     ; set HL from STKEND which points to the

line 4776:
                ; first location after the 'last value'
                                ; first location after the 'last value'

line 4777:
    LD C,$05        ; five bytes to move.
        ld      c, $05          ; five bytes to move.

line 4778:
    AND A           ; clear carry.
        and     a               ; clear carry.

line 4779:
    SBC HL,BC       ; subtract five pointing to 'last value'.
        sbc     hl, bc          ; subtract five pointing to 'last value'.

line 4780:
    LD ($401C),HL       ; update STKEND thereby 'deleting the value.
        ld      ($401C), hl     ; update STKEND thereby 'deleting the value.

line 4782:
    LDIR            ; copy the five value bytes.
        ldir                    ; copy the five value bytes.

line 4784:
    EX DE,HL        ; basic pointer to HL which may be white-space
        ex      de, hl          ; basic pointer to HL which may be white-space

line 4785:
                ; following the number.
                                ; following the number.

line 4786:
    DEC HL          ; now points to last of five bytes.
        dec     hl              ; now points to last of five bytes.

line 4787:
    CALL L004C      ; routine TEMP-PTR1 advances the character
        call    L004C           ; routine TEMP-PTR1 advances the character

line 4788:
                ; address skipping any white-space.
                                ; address skipping any white-space.

line 4789:
    JR L1083        ; forward to S-NUMERIC
        jr      L1083           ; forward to S-NUMERIC

line 4790:
                ; to signal a numeric result.
                                ; to signal a numeric result.

line 4796:
L106F:  RST 20H         ; NEXT-CHAR
L106F:  rst 20H                 ; NEXT-CHAR

line 4797:
    CP $7E          ; compare to 'number marker'
        cp      $7E             ; compare to 'number marker'

line 4798:
    JR NZ,L106F     ; loop back until found to S-STK-DEC
        jr      nz, L106F       ; loop back until found to S-STK-DEC

line 4799:
                ; skipping all the digits.
                                ; skipping all the digits.

line 4801:
    INC HL          ; point to first of five hidden bytes.
        inc     hl              ; point to first of five hidden bytes.

line 4802:
    LD DE,($401C)       ; set destination from STKEND system variable
        ld      de, ($401C)     ; set destination from STKEND system variable

line 4803:
    CALL COPY_FP        ; routine COPY-FP stacks the number.
        call    COPY_FP         ; routine COPY-FP stacks the number.

line 4804:
    LD ($401C),DE       ; update system variable STKEND.
        ld      ($401C), de     ; update system variable STKEND.

line 4805:
    LD ($4016),HL       ; update system variable CH_ADD.
        ld      ($4016), hl     ; update system variable CH_ADD.

line 4808:
L1083:  SET 6,(IY+$01)      ; update FLAGS  - Signal numeric result
L1083:  set 6, (iy+$01)         ; update FLAGS  - Signal numeric result

line 4811:
L1087:  RST 18H         ; GET-CHAR
L1087:  rst 18H                 ; GET-CHAR

line 4814:
L1088:  CP $10          ; compare to opening bracket '('
L1088:  cp $10                  ; compare to opening bracket '('

line 4815:
    JR NZ,L1098     ; forward if not to S-OPERTR
        jr      nz, L1098       ; forward if not to S-OPERTR

line 4817:
    BIT 6,(IY+$01)      ; test FLAGS  - Numeric or string result?
        bit     6, (iy+$01)     ; test FLAGS  - Numeric or string result?

line 4818:
    JR NZ,L10BC     ; forward if numeric to S-LOOP
        jr      nz, L10BC       ; forward if numeric to S-LOOP

line 4822:
    CALL L1263      ; routine SLICING
        call    L1263           ; routine SLICING

line 4824:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 4825:
    JR L1088        ; back to S-CONT-3
        jr      L1088           ; back to S-CONT-3

line 4833:
L1098:  LD BC,$00C3     ; prepare operator 'subtract' as default.
L1098:  ld bc, $00C3            ; prepare operator 'subtract' as default.

line 4834:
                ; also set B to zero for later indexing.
                                ; also set B to zero for later indexing.

line 4836:
    CP $12          ; is character '>' ?
        cp      $12             ; is character '>' ?

line 4837:
    JR C,L10BC      ; forward if less to S-LOOP as
        jr      c, L10BC        ; forward if less to S-LOOP as

line 4838:
                ; we have reached end of meaningful expression
                                ; we have reached end of meaningful expression

line 4840:
    SUB $16         ; is character '-' ?
        sub     $16             ; is character '-' ?

line 4841:
    JR NC,L10A7     ; forward with - * / and '**' '<>' to SUBMLTDIV
        jr      nc, L10A7       ; forward with - * / and '**' '<>' to SUBMLTDIV

line 4843:
    ADD A,$0D       ; increase others by thirteen
        add     a, $0D          ; increase others by thirteen

line 4844:
                ; $09 '>' thru $0C '+'
                                ; $09 '>' thru $0C '+'

line 4845:
    JR L10B5        ; forward to GET-PRIO
        jr      L10B5           ; forward to GET-PRIO

line 4849:
L10A7:  CP $03          ; isolate $00 '-', $01 '*', $02 '/'
L10A7:  cp $03                  ; isolate $00 '-', $01 '*', $02 '/'

line 4850:
    JR C,L10B5      ; forward if so to GET-PRIO
        jr      c, L10B5        ; forward if so to GET-PRIO

line 4854:
    SUB $C2         ; giving range $00 to $05
        sub     $C2             ; giving range $00 to $05

line 4855:
    JR C,L10BC      ; forward if less to S-LOOP
        jr      c, L10BC        ; forward if less to S-LOOP

line 4857:
    CP $06          ; test the upper limit for nonsense also
        cp      $06             ; test the upper limit for nonsense also

line 4858:
    JR NC,L10BC     ; forward if so to S-LOOP
        jr      nc, L10BC       ; forward if so to S-LOOP

line 4860:
    ADD A,$03       ; increase by 3 to give combined operators of
        add     a, $03          ; increase by 3 to give combined operators of

line 4862:
                ; $00 '-'
                                ; $00 '-'

line 4863:
                ; $01 '*'
                                ; $01 '*'

line 4864:
                ; $02 '/'
                                ; $02 '/'

line 4866:
                ; $03 '**'
                                ; $03 '**'

line 4867:
                ; $04 'OR'
                                ; $04 'OR'

line 4868:
                ; $05 'AND'
                                ; $05 'AND'

line 4869:
                ; $06 '<='
                                ; $06 '<='

line 4870:
                ; $07 '>='
                                ; $07 '>='

line 4871:
                ; $08 '<>'
                                ; $08 '<>'

line 4873:
                ; $09 '>'
                                ; $09 '>'

line 4874:
                ; $0A '<'
                                ; $0A '<'

line 4875:
                ; $0B '='
                                ; $0B '='

line 4876:
                ; $0C '+'
                                ; $0C '+'

line 4879:
L10B5:  ADD A,C         ; add to default operation 'sub' ($C3)
L10B5:  add a, c                ; add to default operation 'sub' ($C3)

line 4880:
    LD C,A          ; and place in operator byte - C.
        ld      c, a            ; and place in operator byte - C.

line 4882:
    LD HL,L110F - $C3   ; theoretical base of the priorities table.
        ld      hl, L110F - $C3 ; theoretical base of the priorities table.

line 4883:
    ADD HL,BC       ; add C ( B is zero)
        add     hl, bc          ; add C ( B is zero)

line 4884:
    LD B,(HL)       ; pick up the priority in B
        ld      b, (hl)         ; pick up the priority in B

line 4887:
L10BC:  POP DE          ; restore previous
L10BC:  pop de                  ; restore previous

line 4888:
    LD A,D          ; load A with priority.
        ld      a, d            ; load A with priority.

line 4889:
    CP B            ; is present priority higher
        cp      b               ; is present priority higher

line 4890:
    JR C,L10ED      ; forward if so to S-TIGHTER
        jr      c, L10ED        ; forward if so to S-TIGHTER

line 4892:
    AND A           ; are both priorities zero
        and     a               ; are both priorities zero

line 4893:
    JP Z,L0018      ; exit if zero via GET-CHAR
        jp      z, L0018        ; exit if zero via GET-CHAR

line 4895:
    PUSH BC         ; stack present values
        push    bc              ; stack present values

line 4896:
    PUSH DE         ; stack last values
        push    de              ; stack last values

line 4897:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 4898:
    JR Z,L10D5      ; forward is checking syntax to S-SYNTEST
        jr      z, L10D5        ; forward is checking syntax to S-SYNTEST

line 4900:
    LD A,E          ; fetch last operation
        ld      a, e            ; fetch last operation

line 4901:
    AND $3F         ; mask off the indicator bits to give true
        and     $3F             ; mask off the indicator bits to give true

line 4902:
                ; calculator literal.
                                ; calculator literal.

line 4903:
    LD B,A          ; place in the B register for BREG
        ld      b, a            ; place in the B register for BREG

line 4907:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 4908:
    DEFB $37    ;;fp-calc-2
        defb    $37             ;;fp-calc-2

line 4909:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 4911:
    JR L10DE        ; forward to S-RUNTEST
        jr      L10DE           ; forward to S-RUNTEST

line 4915:
L10D5:  LD A,E          ; transfer masked operator to A
L10D5:  ld a, e                 ; transfer masked operator to A

line 4916:
    XOR (IY+$01)        ; XOR with FLAGS like results will reset bit 6
        xor     (iy+$01)        ; XOR with FLAGS like results will reset bit 6

line 4917:
    AND $40         ; test bit 6
        and     $40             ; test bit 6

line 4920:
L10DB:  JP NZ,L0D9A     ; back to REPORT-C if results do not agree.
L10DB:  jp nz, L0D9A            ; back to REPORT-C if results do not agree.

line 4925:
L10DE:  POP DE          ; restore last operation.
L10DE:  pop de                  ; restore last operation.

line 4926:
    LD HL,$4001     ; address system variable FLAGS
        ld      hl, $4001       ; address system variable FLAGS

line 4927:
    SET 6,(HL)      ; presume a numeric result
        set     6, (hl)         ; presume a numeric result

line 4928:
    BIT 7,E         ; test expected result in operation
        bit     7, e            ; test expected result in operation

line 4929:
    JR NZ,L10EA     ; forward if numeric to S-LOOPEND
        jr      nz, L10EA       ; forward if numeric to S-LOOPEND

line 4931:
    RES 6,(HL)      ; reset to signal string result
        res     6, (hl)         ; reset to signal string result

line 4934:
L10EA:  POP BC          ; restore present values
L10EA:  pop bc                  ; restore present values

line 4935:
    JR L10BC        ; back to S-LOOP
        jr      L10BC           ; back to S-LOOP

line 4940:
L10ED:  PUSH DE ; push last values and consider these
L10ED:  push de                 ; push last values and consider these

line 4942:
    LD A,C          ; get the present operator.
        ld      a, c            ; get the present operator.

line 4943:
    BIT 6,(IY+$01)      ; test FLAGS  - Numeric or string result?
        bit     6, (iy+$01)     ; test FLAGS  - Numeric or string result?

line 4944:
    JR NZ,L110A     ; forward if numeric to S-NEXT
        jr      nz, L110A       ; forward if numeric to S-NEXT

line 4946:
    AND $3F         ; strip indicator bits to give clear literal.
        and     $3F             ; strip indicator bits to give clear literal.

line 4947:
    ADD A,$08       ; add eight - augmenting numeric to equivalent
        add     a, $08          ; add eight - augmenting numeric to equivalent

line 4948:
                ; string literals.
                                ; string literals.

line 4949:
    LD C,A          ; place plain literal back in C.
        ld      c, a            ; place plain literal back in C.

line 4950:
    CP $10          ; compare to 'AND'
        cp      $10             ; compare to 'AND'

line 4951:
    JR NZ,L1102     ; forward if not to S-NOT-AND
        jr      nz, L1102       ; forward if not to S-NOT-AND

line 4953:
    SET 6,C         ; set the numeric operand required for 'AND'
        set     6, c            ; set the numeric operand required for 'AND'

line 4954:
    JR L110A        ; forward to S-NEXT
        jr      L110A           ; forward to S-NEXT

line 4958:
L1102:  JR C,L10DB      ; back if less than 'AND' to S-RPORT-C
L1102:  jr c, L10DB             ; back if less than 'AND' to S-RPORT-C

line 4959:
                ; Nonsense if '-', '*' etc.
                                ; Nonsense if '-', '*' etc.

line 4961:
    CP $17          ; compare to 'strs-add' literal
        cp      $17             ; compare to 'strs-add' literal

line 4962:
    JR Z,L110A      ; forward if so signaling string result
        jr      z, L110A        ; forward if so signaling string result

line 4964:
    SET 7,C         ; set bit to numeric (Boolean) for others.
        set     7, c            ; set bit to numeric (Boolean) for others.

line 4967:
L110A:  PUSH BC         ; stack 'present' values
L110A:  push bc                 ; stack 'present' values

line 4969:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 4970:
    JP L0F59        ; jump back to S-LOOP-1
        jp      L0F59           ; jump back to S-LOOP-1

line 4977:
L110F:  DEFB $06  ;  '-'
L110F:  defb $06                ;  '-'

line 4978:
    DEFB $08  ;  '*'
        defb    $08             ;  '*'

line 4979:
    DEFB $08  ;  '/'
        defb    $08             ;  '/'

line 4980:
    DEFB $0A  ;  '**'
        defb    $0A             ;  '**'

line 4981:
    DEFB $02  ;  'OR'
        defb    $02             ;  'OR'

line 4982:
    DEFB $03  ;  'AND'
        defb    $03             ;  'AND'

line 4983:
    DEFB $05  ;  '<='
        defb    $05             ;  '<='

line 4984:
    DEFB $05  ;  '>='
        defb    $05             ;  '>='

line 4985:
    DEFB $05  ;  '<>'
        defb    $05             ;  '<>'

line 4986:
    DEFB $05  ;  '>'
        defb    $05             ;  '>'

line 4987:
    DEFB $05  ;  '<'
        defb    $05             ;  '<'

line 4988:
    DEFB $05  ;  '='
        defb    $05             ;  '='

line 4989:
    DEFB $06  ;  '+'
        defb    $06             ;  '+'

line 4996:
L111C:  SET 6,(IY+$01)      ; sv FLAGS  - Signal numeric result
L111C:  set 6, (iy+$01)         ; sv FLAGS  - Signal numeric result

line 4998:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 4999:
    CALL L14CE      ; routine ALPHA
        call    L14CE           ; routine ALPHA

line 5000:
    JP NC,L0D9A     ; to REPORT-C
        jp      nc, L0D9A       ; to REPORT-C

line 5002:
    PUSH HL         ;
        push    hl              ;

line 5003:
    LD C,A          ;
        ld      c, a            ;

line 5005:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 5006:
    PUSH HL         ;
        push    hl              ;

line 5007:
    RES 5,C         ;
        res     5, c            ;

line 5008:
    CP $10  ;
        cp      $10             ;

line 5009:
    JR Z,L1148      ; to V-SYN/RUN
        jr      z, L1148        ; to V-SYN/RUN

line 5011:
    SET 6,C         ;
        set     6, c            ;

line 5012:
    CP $0D          ;
        cp      $0D             ;

line 5013:
    JR Z,L1143      ; forward to V-STR-VAR
        jr      z, L1143        ; forward to V-STR-VAR

line 5015:
    SET 5,C         ;
        set     5, c            ;

line 5018:
L1139:  CALL L14D2      ; routine ALPHANUM
L1139:  call L14D2              ; routine ALPHANUM

line 5019:
    JR NC,L1148     ; forward when not to V-RUN/SYN
        jr      nc, L1148       ; forward when not to V-RUN/SYN

line 5021:
    RES 6,C         ;
        res     6, c            ;

line 5023:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 5024:
    JR L1139        ; loop back to V-CHAR
        jr      L1139           ; loop back to V-CHAR

line 5028:
L1143:  RST 20H         ; NEXT-CHAR
L1143:  rst 20H                 ; NEXT-CHAR

line 5029:
    RES 6,(IY+$01)      ; sv FLAGS  - Signal string result
        res     6, (iy+$01)     ; sv FLAGS  - Signal string result

line 5032:
L1148:  LD B,C          ;
L1148:  ld b, c                 ;

line 5033:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 5034:
    JR NZ,L1156     ; forward to V-RUN
        jr      nz, L1156       ; forward to V-RUN

line 5036:
    LD A,C          ;
        ld      a, c            ;

line 5037:
    AND $E0         ;
        and     $E0             ;

line 5038:
    SET 7,A         ;
        set     7, a            ;

line 5039:
    LD C,A          ;
        ld      c, a            ;

line 5040:
    JR L118A        ; forward to V-SYNTAX
        jr      L118A           ; forward to V-SYNTAX

line 5044:
L1156:  LD HL,($4010)       ; sv VARS
L1156:  ld hl, ($4010)          ; sv VARS

line 5047:
L1159:  LD A,(HL)       ;
L1159:  ld a, (hl)              ;

line 5048:
    AND $7F         ;
        and     $7F             ;

line 5049:
    JR Z,L1188      ; to V-80-BYTE
        jr      z, L1188        ; to V-80-BYTE

line 5051:
    CP C            ;
        cp      c               ;

line 5052:
    JR NZ,L1180     ; to V-NEXT
        jr      nz, L1180       ; to V-NEXT

line 5054:
    RLA         ;
        rla                     ;

line 5055:
    ADD A,A         ;
        add     a, a            ;

line 5056:
    JP P,L1195      ; to V-FOUND-2
        jp      p, L1195        ; to V-FOUND-2

line 5058:
    JR C,L1195      ; to V-FOUND-2
        jr      c, L1195        ; to V-FOUND-2

line 5060:
    POP DE          ;
        pop     de              ;

line 5061:
    PUSH DE         ;
        push    de              ;

line 5062:
    PUSH HL         ;
        push    hl              ;

line 5065:
L116B:  INC HL          ;
L116B:  inc hl                  ;

line 5068:
L116C:  LD A,(DE)       ;
L116C:  ld a, (de)              ;

line 5069:
    INC DE          ;
        inc     de              ;

line 5070:
    AND A           ;
        and     a               ;

line 5071:
    JR Z,L116C      ; back to V-SPACES
        jr      z, L116C        ; back to V-SPACES

line 5073:
    CP (HL)         ;
        cp      (hl)            ;

line 5074:
    JR Z,L116B      ; back to V-MATCHES
        jr      z, L116B        ; back to V-MATCHES

line 5076:
    OR $80          ;
        or      $80             ;

line 5077:
    CP (HL)         ;
        cp      (hl)            ;

line 5078:
    JR  NZ,L117F        ; forward to V-GET-PTR
        jr      nz, L117F       ; forward to V-GET-PTR

line 5080:
    LD A,(DE)       ;
        ld      a, (de)         ;

line 5081:
    CALL L14D2      ; routine ALPHANUM
        call    L14D2           ; routine ALPHANUM

line 5082:
    JR NC,L1194     ; forward to V-FOUND-1
        jr      nc, L1194       ; forward to V-FOUND-1

line 5085:
L117F:  POP HL          ;
L117F:  pop hl                  ;

line 5088:
L1180:  PUSH BC         ;
L1180:  push bc                 ;

line 5089:
    CALL L09F2      ; routine NEXT-ONE
        call    L09F2           ; routine NEXT-ONE

line 5090:
    EX DE,HL        ;
        ex      de, hl          ;

line 5091:
    POP BC          ;
        pop     bc              ;

line 5092:
    JR L1159        ; back to V-EACH
        jr      L1159           ; back to V-EACH

line 5096:
L1188:  SET 7,B         ;
L1188:  set 7, b                ;

line 5099:
L118A:  POP DE          ;
L118A:  pop de                  ;

line 5101:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5102:
    CP $10          ;
        cp      $10             ;

line 5103:
    JR Z,L1199      ; forward to V-PASS
        jr      z, L1199        ; forward to V-PASS

line 5105:
    SET 5,B         ;
        set     5, b            ;

line 5106:
    JR L11A1        ; forward to V-END
        jr      L11A1           ; forward to V-END

line 5110:
L1194:  POP DE          ;
L1194:  pop de                  ;

line 5113:
L1195:  POP DE          ;
L1195:  pop de                  ;

line 5114:
    POP DE          ;
        pop     de              ;

line 5115:
    PUSH HL         ;
        push    hl              ;

line 5117:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5120:
L1199:  CALL L14D2      ; routine ALPHANUM
L1199:  call L14D2              ; routine ALPHANUM

line 5121:
    JR NC,L11A1     ; forward if not alphanumeric to V-END
        jr      nc, L11A1       ; forward if not alphanumeric to V-END

line 5124:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 5125:
    JR L1199        ; back to V-PASS
        jr      L1199           ; back to V-PASS

line 5129:
L11A1:  POP HL          ;
L11A1:  pop hl                  ;

line 5130:
    RL B            ;
        rl      b               ;

line 5131:
    BIT 6,B         ;
        bit     6, b            ;

line 5132:
    RET             ;
        ret                     ;

line 5139:
L11A7:  XOR A           ;
L11A7:  xor a                   ;

line 5140:
    LD B,A          ;
        ld      b, a            ;

line 5141:
    BIT 7,C         ;
        bit     7, c            ;

line 5142:
    JR NZ,L11F8     ; forward to SV-COUNT
        jr      nz, L11F8       ; forward to SV-COUNT

line 5144:
    BIT 7,(HL)      ;
        bit     7, (hl)         ;

line 5145:
    JR NZ,L11BF     ; forward to SV-ARRAYS
        jr      nz, L11BF       ; forward to SV-ARRAYS

line 5147:
    INC A           ;
        inc     a               ;

line 5150:
L11B2:  INC HL          ;
L11B2:  inc hl                  ;

line 5151:
    LD C,(HL)       ;
        ld      c, (hl)         ;

line 5152:
    INC HL          ;
        inc     hl              ;

line 5153:
    LD B,(HL)       ;
        ld      b, (hl)         ;

line 5154:
    INC HL          ;
        inc     hl              ;

line 5155:
    EX DE,HL        ;
        ex      de, hl          ;

line 5156:
    CALL STK_ST_s       ; routine STK-STO-$
        call    STK_ST_s        ; routine STK-STO-$

line 5158:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5159:
    JP L125A        ; jump forward to SV-SLICE?
        jp      L125A           ; jump forward to SV-SLICE?

line 5163:
L11BF:  INC HL          ;
L11BF:  inc hl                  ;

line 5164:
    INC HL          ;
        inc     hl              ;

line 5165:
    INC HL          ;
        inc     hl              ;

line 5166:
    LD B,(HL)       ;
        ld      b, (hl)         ;

line 5167:
    BIT 6,C         ;
        bit     6, c            ;

line 5168:
    JR Z,L11D1      ; forward to SV-PTR
        jr      z, L11D1        ; forward to SV-PTR

line 5170:
    DEC B           ;
        dec     b               ;

line 5171:
    JR Z,L11B2      ; forward to SV-SIMPLE$
        jr      z, L11B2        ; forward to SV-SIMPLE$

line 5173:
    EX DE,HL        ;
        ex      de, hl          ;

line 5175:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5176:
    CP $10          ;
        cp      $10             ;

line 5177:
    JR NZ,L1231     ; forward to REPORT-3
        jr      nz, L1231       ; forward to REPORT-3

line 5179:
    EX DE,HL        ;
        ex      de, hl          ;

line 5182:
L11D1:  EX DE,HL        ;
L11D1:  ex de, hl               ;

line 5183:
    JR L11F8        ; forward to SV-COUNT
        jr      L11F8           ; forward to SV-COUNT

line 5187:
L11D4:  PUSH HL         ;
L11D4:  push hl                 ;

line 5189:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5190:
    POP HL          ;
        pop     hl              ;

line 5191:
    CP $1A          ;
        cp      $1A             ;

line 5192:
    JR Z,L11FB      ; forward to SV-LOOP
        jr      z, L11FB        ; forward to SV-LOOP

line 5194:
    BIT 7,C         ;
        bit     7, c            ;

line 5195:
    JR Z,L1231      ; forward to REPORT-3
        jr      z, L1231        ; forward to REPORT-3

line 5197:
    BIT 6,C         ;
        bit     6, c            ;

line 5198:
    JR NZ,L11E9     ; forward to SV-CLOSE
        jr      nz, L11E9       ; forward to SV-CLOSE

line 5200:
    CP $11          ;
        cp      $11             ;

line 5201:
    JR NZ,L1223     ; forward to SV-RPT-C
        jr      nz, L1223       ; forward to SV-RPT-C

line 5203:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 5204:
    RET             ;
        ret                     ;

line 5208:
L11E9:  CP $11          ;
L11E9:  cp $11                  ;

line 5209:
    JR Z,L1259      ; forward to SV-DIM
        jr      z, L1259        ; forward to SV-DIM

line 5211:
    CP $DF          ;
        cp      $DF             ;

line 5212:
    JR NZ,L1223     ; forward to SV-RPT-C
        jr      nz, L1223       ; forward to SV-RPT-C

line 5215:
L11F1:  RST 18H         ; GET-CHAR
L11F1:  rst 18H                 ; GET-CHAR

line 5216:
    DEC HL          ;
        dec     hl              ;

line 5217:
    LD ($4016),HL       ; sv CH_ADD
        ld      ($4016), hl     ; sv CH_ADD

line 5218:
    JR L1256        ; forward to SV-SLICE
        jr      L1256           ; forward to SV-SLICE

line 5222:
L11F8:  LD HL,$0000     ;
L11F8:  ld hl, $0000            ;

line 5225:
L11FB:  PUSH HL         ;
L11FB:  push hl                 ;

line 5227:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 5228:
    POP HL          ;
        pop     hl              ;

line 5229:
    LD A,C          ;
        ld      a, c            ;

line 5230:
    CP $C0          ;
        cp      $C0             ;

line 5231:
    JR NZ,L120C     ; forward to SV-MULT
        jr      nz, L120C       ; forward to SV-MULT

line 5233:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5234:
    CP $11          ;
        cp      $11             ;

line 5235:
    JR Z,L1259      ; forward to SV-DIM
        jr      z, L1259        ; forward to SV-DIM

line 5237:
    CP $DF          ;
        cp      $DF             ;

line 5238:
    JR Z,L11F1      ; back to SV-CH-ADD
        jr      z, L11F1        ; back to SV-CH-ADD

line 5241:
L120C:  PUSH BC         ;
L120C:  push bc                 ;

line 5242:
    PUSH HL         ;
        push    hl              ;

line 5243:
    CALL L12FF      ; routine DE,(DE+1)
        call    L12FF           ; routine DE,(DE+1)

line 5244:
    EX (SP),HL      ;
        ex      (sp), hl        ;

line 5245:
    EX DE,HL        ;
        ex      de, hl          ;

line 5246:
    CALL L12DD      ; routine INT-EXP1
        call    L12DD           ; routine INT-EXP1

line 5247:
    JR C,L1231      ; forward to REPORT-3
        jr      c, L1231        ; forward to REPORT-3

line 5249:
    DEC BC          ;
        dec     bc              ;

line 5250:
    CALL L1305      ; routine GET-HL*DE
        call    L1305           ; routine GET-HL*DE

line 5251:
    ADD HL,BC       ;
        add     hl, bc          ;

line 5252:
    POP DE          ;
        pop     de              ;

line 5253:
    POP BC          ;
        pop     bc              ;

line 5254:
    DJNZ L11D4      ; loop back to SV-COMMA
        djnz    L11D4           ; loop back to SV-COMMA

line 5256:
    BIT 7,C         ;
        bit     7, c            ;

line 5259:
L1223:  JR NZ,L128B     ; relative jump to SL-RPT-C
L1223:  jr nz, L128B            ; relative jump to SL-RPT-C

line 5261:
    PUSH HL         ;
        push    hl              ;

line 5262:
    BIT 6,C         ;
        bit     6, c            ;

line 5263:
    JR NZ,L123D     ; forward to SV-ELEM$
        jr      nz, L123D       ; forward to SV-ELEM$

line 5265:
    LD B,D          ;
        ld      b, d            ;

line 5266:
    LD C,E          ;
        ld      c, e            ;

line 5268:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5269:
    CP $11          ; is character a ')' ?
        cp      $11             ; is character a ')' ?

line 5270:
    JR Z,L1233      ; skip forward to SV-NUMBER
        jr      z, L1233        ; skip forward to SV-NUMBER

line 5273:
L1231:  RST 08H         ; ERROR-1
L1231:  rst 08H                 ; ERROR-1

line 5274:
    DEFB $02        ; Error Report: Subscript wrong
        defb    $02             ; Error Report: Subscript wrong

line 5277:
L1233:  RST 20H         ; NEXT-CHAR
L1233:  rst 20H                 ; NEXT-CHAR

line 5278:
    POP HL          ;
        pop     hl              ;

line 5279:
    LD DE,$0005     ;
        ld      de, $0005       ;

line 5280:
    CALL L1305      ; routine GET-HL*DE
        call    L1305           ; routine GET-HL*DE

line 5281:
    ADD HL,BC       ;
        add     hl, bc          ;

line 5282:
    RET             ; return              >>
        ret                     ; return              >>

line 5286:
L123D:  CALL L12FF      ; routine DE,(DE+1)
L123D:  call L12FF              ; routine DE,(DE+1)

line 5287:
    EX (SP),HL      ;
        ex      (sp), hl        ;

line 5288:
    CALL L1305      ; routine GET-HL*DE
        call    L1305           ; routine GET-HL*DE

line 5289:
    POP BC          ;
        pop     bc              ;

line 5290:
    ADD HL,BC       ;
        add     hl, bc          ;

line 5291:
    INC HL          ;
        inc     hl              ;

line 5292:
    LD B,D          ;
        ld      b, d            ;

line 5293:
    LD C,E          ;
        ld      c, e            ;

line 5294:
    EX DE,HL        ;
        ex      de, hl          ;

line 5295:
    CALL L12C2      ; routine STK-ST-0
        call    L12C2           ; routine STK-ST-0

line 5297:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5298:
    CP $11          ; is it ')' ?
        cp      $11             ; is it ')' ?

line 5299:
    JR Z,L1259      ; forward if so to SV-DIM
        jr      z, L1259        ; forward if so to SV-DIM

line 5301:
    CP $1A          ; is it ',' ?
        cp      $1A             ; is it ',' ?

line 5302:
    JR NZ,L1231     ; back if not to REPORT-3
        jr      nz, L1231       ; back if not to REPORT-3

line 5305:
L1256:  CALL L1263      ; routine SLICING
L1256:  call L1263              ; routine SLICING

line 5308:
L1259:  RST 20H         ; NEXT-CHAR
L1259:  rst 20H                 ; NEXT-CHAR

line 5311:
L125A:  CP $10          ;
L125A:  cp $10                  ;

line 5312:
    JR Z,L1256      ; back to SV-SLICE
        jr      z, L1256        ; back to SV-SLICE

line 5314:
    RES 6,(IY+$01)      ; sv FLAGS  - Signal string result
        res     6, (iy+$01)     ; sv FLAGS  - Signal string result

line 5315:
    RET             ; return.
        ret                     ; return.

line 5322:
L1263:  CALL L0DA6      ; routine SYNTAX-Z
L1263:  call L0DA6              ; routine SYNTAX-Z

line 5323:
    CALL NZ,STK_FETCH   ; routine STK-FETCH
        call    nz, STK_FETCH   ; routine STK-FETCH

line 5325:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 5326:
    CP $11          ; is it ')' ?
        cp      $11             ; is it ')' ?

line 5327:
    JR Z,L12BE      ; forward if so to SL-STORE
        jr      z, L12BE        ; forward if so to SL-STORE

line 5329:
    PUSH DE         ;
        push    de              ;

line 5330:
    XOR A           ;
        xor     a               ;

line 5331:
    PUSH AF         ;
        push    af              ;

line 5332:
    PUSH BC         ;
        push    bc              ;

line 5333:
    LD DE,$0001     ;
        ld      de, $0001       ;

line 5335:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5336:
    POP HL          ;
        pop     hl              ;

line 5337:
    CP $DF          ; is it 'TO' ?
        cp      $DF             ; is it 'TO' ?

line 5338:
    JR Z,L1292      ; forward if so to SL-SECOND
        jr      z, L1292        ; forward if so to SL-SECOND

line 5340:
    POP AF          ;
        pop     af              ;

line 5341:
    CALL L12DE      ; routine INT-EXP2
        call    L12DE           ; routine INT-EXP2

line 5342:
    PUSH AF         ;
        push    af              ;

line 5343:
    LD D,B          ;
        ld      d, b            ;

line 5344:
    LD E,C          ;
        ld      e, c            ;

line 5345:
    PUSH HL         ;
        push    hl              ;

line 5347:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5348:
    POP HL          ;
        pop     hl              ;

line 5349:
    CP $DF          ; is it 'TO' ?
        cp      $DF             ; is it 'TO' ?

line 5350:
    JR Z,L1292      ; forward if so to SL-SECOND
        jr      z, L1292        ; forward if so to SL-SECOND

line 5352:
    CP $11          ;
        cp      $11             ;

line 5355:
L128B:  JP NZ,L0D9A     ; to REPORT-C
L128B:  jp nz, L0D9A            ; to REPORT-C

line 5357:
    LD H,D          ;
        ld      h, d            ;

line 5358:
    LD L,E          ;
        ld      l, e            ;

line 5359:
    JR L12A5        ; forward to SL-DEFINE
        jr      L12A5           ; forward to SL-DEFINE

line 5363:
L1292:  PUSH HL         ;
L1292:  push hl                 ;

line 5365:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 5366:
    POP HL          ;
        pop     hl              ;

line 5367:
    CP $11          ; is it ')' ?
        cp      $11             ; is it ')' ?

line 5368:
    JR Z,L12A5      ; forward if so to SL-DEFINE
        jr      z, L12A5        ; forward if so to SL-DEFINE

line 5370:
    POP AF          ;
        pop     af              ;

line 5371:
    CALL L12DE      ; routine INT-EXP2
        call    L12DE           ; routine INT-EXP2

line 5372:
    PUSH AF         ;
        push    af              ;

line 5374:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5375:
    LD H,B          ;
        ld      h, b            ;

line 5376:
    LD L,C          ;
        ld      l, c            ;

line 5377:
    CP $11          ; is it ')' ?
        cp      $11             ; is it ')' ?

line 5378:
    JR NZ,L128B     ; back if not to SL-RPT-C
        jr      nz, L128B       ; back if not to SL-RPT-C

line 5381:
L12A5:  POP AF          ;
L12A5:  pop af                  ;

line 5382:
    EX (SP),HL      ;
        ex      (sp), hl        ;

line 5383:
    ADD HL,DE       ;
        add     hl, de          ;

line 5384:
    DEC HL          ;
        dec     hl              ;

line 5385:
    EX (SP),HL      ;
        ex      (sp), hl        ;

line 5386:
    AND A           ;
        and     a               ;

line 5387:
    SBC HL,DE       ;
        sbc     hl, de          ;

line 5388:
    LD BC,$0000     ;
        ld      bc, $0000       ;

line 5389:
    JR C,L12B9      ; forward to SL-OVER
        jr      c, L12B9        ; forward to SL-OVER

line 5391:
    INC HL          ;
        inc     hl              ;

line 5392:
    AND A           ;
        and     a               ;

line 5393:
    JP M,L1231      ; jump back to REPORT-3
        jp      m, L1231        ; jump back to REPORT-3

line 5395:
    LD B,H          ;
        ld      b, h            ;

line 5396:
    LD C,L          ;
        ld      c, l            ;

line 5399:
L12B9:  POP DE          ;
L12B9:  pop de                  ;

line 5400:
    RES 6,(IY+$01)      ; sv FLAGS  - Signal string result
        res     6, (iy+$01)     ; sv FLAGS  - Signal string result

line 5403:
L12BE:  CALL L0DA6      ; routine SYNTAX-Z
L12BE:  call L0DA6              ; routine SYNTAX-Z

line 5404:
    RET Z           ; return if checking syntax.
        ret     z               ; return if checking syntax.

line 5411:
L12C2:  XOR A           ;
L12C2:  xor a                   ;

line 5413:
STK_ST_s            ; (L12C3)
STK_ST_s                        ; (L12C3)

line 5414:
    PUSH BC         ;
        push    bc              ;

line 5415:
    CALL TEST_5_SP      ; routine TEST-5-SP
        call    TEST_5_SP       ; routine TEST-5-SP

line 5416:
    POP BC          ;
        pop     bc              ;

line 5417:
    LD HL,($401C)       ; sv STKEND
        ld      hl, ($401C)     ; sv STKEND

line 5418:
    LD (HL),A       ;
        ld      (hl), a         ;

line 5419:
    INC HL          ;
        inc     hl              ;

line 5420:
    LD (HL),E       ;
        ld      (hl), e         ;

line 5421:
    INC HL          ;
        inc     hl              ;

line 5422:
    LD (HL),D       ;
        ld      (hl), d         ;

line 5423:
    INC HL          ;
        inc     hl              ;

line 5424:
    LD (HL),C       ;
        ld      (hl), c         ;

line 5425:
    INC HL          ;
        inc     hl              ;

line 5426:
    LD (HL),B       ;
        ld      (hl), b         ;

line 5427:
    INC HL          ;
        inc     hl              ;

line 5428:
    LD ($401C),HL       ; sv STKEND
        ld      ($401C), hl     ; sv STKEND

line 5429:
    RES 6,(IY+$01)      ; update FLAGS - signal string result
        res     6, (iy+$01)     ; update FLAGS - signal string result

line 5430:
    RET             ; return.
        ret                     ; return.

line 5437:
L12DD:  XOR A           ;
L12DD:  xor a                   ;

line 5440:
L12DE:  PUSH DE         ;
L12DE:  push de                 ;

line 5441:
    PUSH HL         ;
        push    hl              ;

line 5442:
    PUSH AF         ;
        push    af              ;

line 5443:
    CALL CLASS_06       ; routine CLASS-6
        call    CLASS_06        ; routine CLASS-6

line 5444:
    POP AF          ;
        pop     af              ;

line 5445:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 5446:
    JR Z,L12FC      ; forward if checking syntax to I-RESTORE
        jr      z, L12FC        ; forward if checking syntax to I-RESTORE

line 5448:
    PUSH AF         ;
        push    af              ;

line 5449:
    CALL FIND_INT       ; routine FIND-INT
        call    FIND_INT        ; routine FIND-INT

line 5450:
    POP DE          ;
        pop     de              ;

line 5451:
    LD A,B          ;
        ld      a, b            ;

line 5452:
    OR C            ;
        or      c               ;

line 5453:
    SCF         ; Set Carry Flag
        scf                     ; Set Carry Flag

line 5454:
    JR Z,L12F9      ; forward to I-CARRY
        jr      z, L12F9        ; forward to I-CARRY

line 5456:
    POP HL          ;
        pop     hl              ;

line 5457:
    PUSH HL         ;
        push    hl              ;

line 5458:
    AND A           ;
        and     a               ;

line 5459:
    SBC HL,BC       ;
        sbc     hl, bc          ;

line 5462:
L12F9:  LD A,D          ;
L12F9:  ld a, d                 ;

line 5463:
    SBC A,$00       ;
        sbc     a, $00          ;

line 5466:
L12FC:  POP HL          ;
L12FC:  pop hl                  ;

line 5467:
    POP DE          ;
        pop     de              ;

line 5468:
    RET             ;
        ret                     ;

line 5481:
L12FF:  EX DE,HL        ; move index address into HL.
L12FF:  ex de, hl               ; move index address into HL.

line 5482:
    INC HL          ; increment to address word.
        inc     hl              ; increment to address word.

line 5483:
    LD E,(HL)       ; pick up word low-order byte.
        ld      e, (hl)         ; pick up word low-order byte.

line 5484:
    INC HL          ; index high-order byte and
        inc     hl              ; index high-order byte and

line 5485:
    LD D,(HL)       ; pick it up.
        ld      d, (hl)         ; pick it up.

line 5486:
    RET             ; return with DE = word.
        ret                     ; return with DE = word.

line 5493:
L1305:  CALL L0DA6      ; routine SYNTAX-Z
L1305:  call L0DA6              ; routine SYNTAX-Z

line 5494:
    RET Z           ;
        ret     z               ;

line 5496:
    PUSH BC         ;
        push    bc              ;

line 5497:
    LD B,$10        ;
        ld      b, $10          ;

line 5498:
    LD A,H          ;
        ld      a, h            ;

line 5499:
    LD C,L          ;
        ld      c, l            ;

line 5500:
    LD HL,$0000     ;
        ld      hl, $0000       ;

line 5503:
L1311:  ADD HL,HL       ;
L1311:  add hl, hl              ;

line 5504:
    JR C,L131A      ; forward with carry to HL-END
        jr      c, L131A        ; forward with carry to HL-END

line 5506:
    RL C            ;
        rl      c               ;

line 5507:
    RLA         ;
        rla                     ;

line 5508:
    JR NC,L131D     ; forward with no carry to HL-AGAIN
        jr      nc, L131D       ; forward with no carry to HL-AGAIN

line 5510:
    ADD HL,DE       ;
        add     hl, de          ;

line 5513:
L131A:  JP C,L0ED3      ; to REPORT-4
L131A:  jp c, L0ED3             ; to REPORT-4

line 5516:
L131D:  DJNZ L1311      ; loop back to HL-LOOP
L131D:  djnz L1311              ; loop back to HL-LOOP

line 5518:
    POP BC          ;
        pop     bc              ;

line 5519:
    RET             ; return.
        ret                     ; return.

line 5526:
L1321:  LD HL,($4012)       ; sv DEST-lo
L1321:  ld hl, ($4012)          ; sv DEST-lo

line 5527:
    BIT 1,(IY+$2D)      ; sv FLAGX
        bit     1, (iy+$2D)     ; sv FLAGX

line 5528:
    JR Z,L136E      ; forward to L-EXISTS
        jr      z, L136E        ; forward to L-EXISTS

line 5530:
    LD BC,$0005     ;
        ld      bc, $0005       ;

line 5533:
L132D:  INC BC          ;
L132D:  inc bc                  ;

line 5538:
L132E:  INC HL          ;
L132E:  inc hl                  ;

line 5539:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 5540:
    AND A           ;
        and     a               ;

line 5541:
    JR Z,L132E      ; back to L-NO-SP
        jr      z, L132E        ; back to L-NO-SP

line 5543:
    CALL L14D2      ; routine ALPHANUM
        call    L14D2           ; routine ALPHANUM

line 5544:
    JR C,L132D      ; back to L-EACH-CH
        jr      c, L132D        ; back to L-EACH-CH

line 5546:
    CP $0D          ; is it '$' ?
        cp      $0D             ; is it '$' ?

line 5547:
    JP Z,L13C8      ; forward if so to L-NEW$
        jp      z, L13C8        ; forward if so to L-NEW$

line 5549:
    RST 30H         ; BC-SPACES
        rst     30H             ; BC-SPACES

line 5550:
    PUSH DE         ;
        push    de              ;

line 5551:
    LD HL,($4012)       ; sv DEST
        ld      hl, ($4012)     ; sv DEST

line 5552:
    DEC DE          ;
        dec     de              ;

line 5553:
    LD A,C          ;
        ld      a, c            ;

line 5554:
    SUB $06         ;
        sub     $06             ;

line 5555:
    LD B,A          ;
        ld      b, a            ;

line 5556:
    LD A,$40        ;
        ld      a, $40          ;

line 5557:
    JR Z,L1359      ; forward to L-SINGLE
        jr      z, L1359        ; forward to L-SINGLE

line 5560:
L134B:  INC HL          ;
L134B:  inc hl                  ;

line 5561:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 5562:
    AND A           ; is it a space ?
        and     a               ; is it a space ?

line 5563:
    JR Z,L134B      ; back to L-CHAR
        jr      z, L134B        ; back to L-CHAR

line 5565:
    INC DE          ;
        inc     de              ;

line 5566:
    LD (DE),A       ;
        ld      (de), a         ;

line 5567:
    DJNZ L134B      ; loop back to L-CHAR
        djnz    L134B           ; loop back to L-CHAR

line 5569:
    OR $80          ;
        or      $80             ;

line 5570:
    LD (DE),A       ;
        ld      (de), a         ;

line 5571:
    LD A,$80        ;
        ld      a, $80          ;

line 5574:
L1359:  LD HL,($4012)       ; sv DEST-lo
L1359:  ld hl, ($4012)          ; sv DEST-lo

line 5575:
    XOR (HL)        ;
        xor     (hl)            ;

line 5576:
    POP HL          ;
        pop     hl              ;

line 5577:
    CALL L13E7      ; routine L-FIRST
        call    L13E7           ; routine L-FIRST

line 5580:
L1361:  PUSH HL         ;
L1361:  push hl                 ;

line 5582:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 5583:
    DEFB $02    ;;delete
        defb    $02             ;;delete

line 5584:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 5586:
    POP HL          ;
        pop     hl              ;

line 5587:
    LD BC,$0005     ;
        ld      bc, $0005       ;

line 5588:
    AND A           ;
        and     a               ;

line 5589:
    SBC HL,BC       ;
        sbc     hl, bc          ;

line 5590:
    JR L13AE        ; forward to L-ENTER
        jr      L13AE           ; forward to L-ENTER

line 5594:
L136E:  BIT 6,(IY+$01)      ; sv FLAGS  - Numeric or string result?
L136E:  bit 6, (iy+$01)         ; sv FLAGS  - Numeric or string result?

line 5595:
    JR Z,L137A      ; forward to L-DELETE$
        jr      z, L137A        ; forward to L-DELETE$

line 5597:
    LD DE,$0006     ;
        ld      de, $0006       ;

line 5598:
    ADD HL,DE       ;
        add     hl, de          ;

line 5599:
    JR L1361        ; back to L-NUMERIC
        jr      L1361           ; back to L-NUMERIC

line 5603:
L137A:  LD HL,($4012)       ; sv DEST-lo
L137A:  ld hl, ($4012)          ; sv DEST-lo

line 5604:
    LD BC,($402E)       ; sv STRLEN_lo
        ld      bc, ($402E)     ; sv STRLEN_lo

line 5605:
    BIT 0,(IY+$2D)      ; sv FLAGX
        bit     0, (iy+$2D)     ; sv FLAGX

line 5606:
    JR NZ,L13B7     ; forward to L-ADD$
        jr      nz, L13B7       ; forward to L-ADD$

line 5608:
    LD A,B          ;
        ld      a, b            ;

line 5609:
    OR C            ;
        or      c               ;

line 5610:
    RET Z           ;
        ret     z               ;

line 5612:
    PUSH HL         ;
        push    hl              ;

line 5614:
    RST 30H         ; BC-SPACES
        rst     30H             ; BC-SPACES

line 5615:
    PUSH DE         ;
        push    de              ;

line 5616:
    PUSH BC         ;
        push    bc              ;

line 5617:
    LD D,H          ;
        ld      d, h            ;

line 5618:
    LD E,L          ;
        ld      e, l            ;

line 5619:
    INC HL          ;
        inc     hl              ;

line 5620:
    LD (HL),$00     ;
        ld      (hl), $00       ;

line 5621:
    LDDR            ; Copy Bytes
        lddr                    ; Copy Bytes

line 5622:
    PUSH HL         ;
        push    hl              ;

line 5623:
    CALL STK_FETCH      ; routine STK-FETCH
        call    STK_FETCH       ; routine STK-FETCH

line 5624:
    POP HL          ;
        pop     hl              ;

line 5625:
    EX (SP),HL      ;
        ex      (sp), hl        ;

line 5626:
    AND A           ;
        and     a               ;

line 5627:
    SBC HL,BC       ;
        sbc     hl, bc          ;

line 5628:
    ADD HL,BC       ;
        add     hl, bc          ;

line 5629:
    JR NC,L13A3     ; forward to L-LENGTH
        jr      nc, L13A3       ; forward to L-LENGTH

line 5631:
    LD B,H          ;
        ld      b, h            ;

line 5632:
    LD C,L          ;
        ld      c, l            ;

line 5635:
L13A3:  EX (SP),HL      ;
L13A3:  ex (sp), hl             ;

line 5636:
    EX DE,HL        ;
        ex      de, hl          ;

line 5637:
    LD A,B          ;
        ld      a, b            ;

line 5638:
    OR C            ;
        or      c               ;

line 5639:
    JR Z,L13AB      ; forward if zero to L-IN-W/S
        jr      z, L13AB        ; forward if zero to L-IN-W/S

line 5641:
    LDIR            ; Copy Bytes
        ldir                    ; Copy Bytes

line 5644:
L13AB:  POP BC          ;
L13AB:  pop bc                  ;

line 5645:
    POP DE          ;
        pop     de              ;

line 5646:
    POP HL          ;
        pop     hl              ;

line 5656:
    EX DE,HL        ;
        ex      de, hl          ;

line 5658:
    LD A,B          ;
        ld      a, b            ;

line 5659:
    OR C            ;
        or      c               ;

line 5660:
    RET Z           ;
        ret     z               ;

line 5662:
    PUSH DE         ;
        push    de              ;

line 5663:
    LDIR            ; Copy Bytes
        ldir                    ; Copy Bytes

line 5664:
    POP HL          ;
        pop     hl              ;

line 5665:
    RET             ; return.
        ret                     ; return.

line 5669:
L13B7:  DEC HL          ;
L13B7:  dec hl                  ;

line 5670:
    DEC HL          ;
        dec     hl              ;

line 5671:
    DEC HL          ;
        dec     hl              ;

line 5672:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 5673:
    PUSH HL         ;
        push    hl              ;

line 5674:
    PUSH BC         ;
        push    bc              ;

line 5676:
    CALL L13CE      ; routine L-STRING
        call    L13CE           ; routine L-STRING

line 5678:
    POP BC          ;
        pop     bc              ;

line 5679:
    POP HL          ;
        pop     hl              ;

line 5680:
    INC BC          ;
        inc     bc              ;

line 5681:
    INC BC          ;
        inc     bc              ;

line 5682:
    INC BC          ;
        inc     bc              ;

line 5683:
    JP L0A60        ; jump back to exit via RECLAIM-2
        jp      L0A60           ; jump back to exit via RECLAIM-2

line 5687:
L13C8:  LD A,$60        ; prepare mask %01100000
L13C8:  ld a, $60               ; prepare mask %01100000

line 5688:
    LD HL,($4012)       ; sv DEST-lo
        ld      hl, ($4012)     ; sv DEST-lo

line 5689:
    XOR (HL)        ;
        xor     (hl)            ;

line 5696:
L13CE:  PUSH AF         ;
L13CE:  push af                 ;

line 5697:
    CALL STK_FETCH      ; routine STK-FETCH
        call    STK_FETCH       ; routine STK-FETCH

line 5698:
    EX DE,HL        ;
        ex      de, hl          ;

line 5699:
    ADD HL,BC       ;
        add     hl, bc          ;

line 5700:
    PUSH HL         ;
        push    hl              ;

line 5701:
    INC BC          ;
        inc     bc              ;

line 5702:
    INC BC          ;
        inc     bc              ;

line 5703:
    INC BC          ;
        inc     bc              ;

line 5705:
    RST 30H         ; BC-SPACES
        rst     30H             ; BC-SPACES

line 5706:
    EX DE,HL        ;
        ex      de, hl          ;

line 5707:
    POP HL          ;
        pop     hl              ;

line 5708:
    DEC BC          ;
        dec     bc              ;

line 5709:
    DEC BC          ;
        dec     bc              ;

line 5710:
    PUSH BC         ;
        push    bc              ;

line 5711:
    LDDR            ; Copy Bytes
        lddr                    ; Copy Bytes

line 5712:
    EX DE,HL        ;
        ex      de, hl          ;

line 5713:
    POP BC          ;
        pop     bc              ;

line 5714:
    DEC BC          ;
        dec     bc              ;

line 5715:
    LD (HL),B       ;
        ld      (hl), b         ;

line 5716:
    DEC HL          ;
        dec     hl              ;

line 5717:
    LD (HL),C       ;
        ld      (hl), c         ;

line 5718:
    POP AF          ;
        pop     af              ;

line 5721:
L13E7:  PUSH AF         ;
L13E7:  push af                 ;

line 5722:
    CALL L14C7      ; routine REC-V80
        call    L14C7           ; routine REC-V80

line 5723:
    POP AF          ;
        pop     af              ;

line 5724:
    DEC HL          ;
        dec     hl              ;

line 5725:
    LD (HL),A       ;
        ld      (hl), a         ;

line 5726:
    LD HL,($401A)       ; sv STKBOT_lo
        ld      hl, ($401A)     ; sv STKBOT_lo

line 5727:
    LD ($4014),HL       ; sv E_LINE_lo
        ld      ($4014), hl     ; sv E_LINE_lo

line 5728:
    DEC HL          ;
        dec     hl              ;

line 5729:
    LD (HL),$80     ;
        ld      (hl), $80       ;

line 5730:
    RET             ;
        ret                     ;

line 5742:
STK_FETCH           ; (L13F8)
STK_FETCH                       ; (L13F8)

line 5743:
    LD HL,($401C)       ; load HL from system variable STKEND
        ld      hl, ($401C)     ; load HL from system variable STKEND

line 5745:
    DEC HL          ;
        dec     hl              ;

line 5746:
    LD B,(HL)       ;
        ld      b, (hl)         ;

line 5747:
    DEC HL          ;
        dec     hl              ;

line 5748:
    LD C,(HL)       ;
        ld      c, (hl)         ;

line 5749:
    DEC HL          ;
        dec     hl              ;

line 5750:
    LD D,(HL)       ;
        ld      d, (hl)         ;

line 5751:
    DEC HL          ;
        dec     hl              ;

line 5752:
    LD E,(HL)       ;
        ld      e, (hl)         ;

line 5753:
    DEC HL          ;
        dec     hl              ;

line 5754:
    LD A,(HL)       ;
        ld      a, (hl)         ;

line 5756:
    LD ($401C),HL       ; set system variable STKEND to lower value.
        ld      ($401C), hl     ; set system variable STKEND to lower value.

line 5757:
    RET             ; return.
        ret                     ; return.

line 5766:
L1409:  CALL L111C      ; routine LOOK-VARS
L1409:  call L111C              ; routine LOOK-VARS

line 5769:
L140C:  JP NZ,L0D9A     ; to REPORT-C
L140C:  jp nz, L0D9A            ; to REPORT-C

line 5771:
    CALL L0DA6      ; routine SYNTAX-Z
        call    L0DA6           ; routine SYNTAX-Z

line 5772:
    JR NZ,L141C     ; forward to D-RUN
        jr      nz, L141C       ; forward to D-RUN

line 5774:
    RES 6,C         ;
        res     6, c            ;

line 5775:
    CALL L11A7      ; routine STK-VAR
        call    L11A7           ; routine STK-VAR

line 5776:
    CALL L0D1D      ; routine CHECK-END
        call    L0D1D           ; routine CHECK-END

line 5779:
L141C:  JR C,L1426      ; forward to D-LETTER
L141C:  jr c, L1426             ; forward to D-LETTER

line 5781:
    PUSH BC         ;
        push    bc              ;

line 5782:
    CALL L09F2      ; routine NEXT-ONE
        call    L09F2           ; routine NEXT-ONE

line 5783:
    CALL L0A60      ; routine RECLAIM-2
        call    L0A60           ; routine RECLAIM-2

line 5784:
    POP BC          ;
        pop     bc              ;

line 5787:
L1426:  SET 7,C         ;
L1426:  set 7, c                ;

line 5788:
    LD B,$00        ;
        ld      b, $00          ;

line 5789:
    PUSH BC         ;
        push    bc              ;

line 5790:
    LD HL,$0001     ;
        ld      hl, $0001       ;

line 5791:
    BIT 6,C         ;
        bit     6, c            ;

line 5792:
    JR NZ,L1434     ; forward to D-SIZE
        jr      nz, L1434       ; forward to D-SIZE

line 5794:
    LD L,$05        ;
        ld      l, $05          ;

line 5797:
L1434:  EX DE,HL        ;
L1434:  ex de, hl               ;

line 5800:
L1435:  RST 20H         ; NEXT-CHAR
L1435:  rst 20H                 ; NEXT-CHAR

line 5801:
    LD H,$40        ;
        ld      h, $40          ;

line 5802:
    CALL L12DD      ; routine INT-EXP1
        call    L12DD           ; routine INT-EXP1

line 5803:
    JP C,L1231      ; jump back to REPORT-3
        jp      c, L1231        ; jump back to REPORT-3

line 5805:
    POP HL          ;
        pop     hl              ;

line 5806:
    PUSH BC         ;
        push    bc              ;

line 5807:
    INC H           ;
        inc     h               ;

line 5808:
    PUSH HL         ;
        push    hl              ;

line 5809:
    LD H,B          ;
        ld      h, b            ;

line 5810:
    LD L,C          ;
        ld      l, c            ;

line 5811:
    CALL L1305      ; routine GET-HL*DE
        call    L1305           ; routine GET-HL*DE

line 5812:
    EX DE,HL        ;
        ex      de, hl          ;

line 5814:
    RST 18H         ; GET-CHAR
        rst     18H             ; GET-CHAR

line 5815:
    CP $1A          ;
        cp      $1A             ;

line 5816:
    JR Z,L1435      ; back to D-NO-LOOP
        jr      z, L1435        ; back to D-NO-LOOP

line 5818:
    CP $11          ; is it ')' ?
        cp      $11             ; is it ')' ?

line 5819:
    JR NZ,L140C     ; back if not to D-RPORT-C
        jr      nz, L140C       ; back if not to D-RPORT-C

line 5821:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 5822:
    POP BC          ;
        pop     bc              ;

line 5823:
    LD A,C          ;
        ld      a, c            ;

line 5824:
    LD L,B          ;
        ld      l, b            ;

line 5825:
    LD H,$00        ;
        ld      h, $00          ;

line 5826:
    INC HL          ;
        inc     hl              ;

line 5827:
    INC HL          ;
        inc     hl              ;

line 5828:
    ADD HL,HL       ;
        add     hl, hl          ;

line 5829:
    ADD HL,DE       ;
        add     hl, de          ;

line 5830:
    JP C,L0ED3      ; jump to REPORT-4
        jp      c, L0ED3        ; jump to REPORT-4

line 5832:
    PUSH DE         ;
        push    de              ;

line 5833:
    PUSH BC         ;
        push    bc              ;

line 5834:
    PUSH HL         ;
        push    hl              ;

line 5835:
    LD B,H          ;
        ld      b, h            ;

line 5836:
    LD C,L          ;
        ld      c, l            ;

line 5837:
    LD HL,($4014)       ; sv E_LINE_lo
        ld      hl, ($4014)     ; sv E_LINE_lo

line 5838:
    DEC HL          ;
        dec     hl              ;

line 5839:
    CALL L099E      ; routine MAKE-ROOM
        call    L099E           ; routine MAKE-ROOM

line 5840:
    INC HL          ;
        inc     hl              ;

line 5841:
    LD  (HL),A      ;
        ld      (hl), a         ;

line 5842:
    POP BC          ;
        pop     bc              ;

line 5843:
    DEC BC          ;
        dec     bc              ;

line 5844:
    DEC BC          ;
        dec     bc              ;

line 5845:
    DEC BC          ;
        dec     bc              ;

line 5846:
    INC HL          ;
        inc     hl              ;

line 5847:
    LD (HL),C       ;
        ld      (hl), c         ;

line 5848:
    INC HL          ;
        inc     hl              ;

line 5849:
    LD (HL),B       ;
        ld      (hl), b         ;

line 5850:
    POP AF          ;
        pop     af              ;

line 5851:
    INC HL          ;
        inc     hl              ;

line 5852:
    LD (HL),A       ;
        ld      (hl), a         ;

line 5853:
    LD H,D          ;
        ld      h, d            ;

line 5854:
    LD L,E          ;
        ld      l, e            ;

line 5855:
    DEC DE          ;
        dec     de              ;

line 5856:
    LD (HL),$00     ;
        ld      (hl), $00       ;

line 5857:
    POP BC          ;
        pop     bc              ;

line 5858:
    LDDR            ; Copy Bytes
        lddr                    ; Copy Bytes

line 5861:
L147F:  POP BC          ;
L147F:  pop bc                  ;

line 5862:
    LD (HL),B       ;
        ld      (hl), b         ;

line 5863:
    DEC HL          ;
        dec     hl              ;

line 5864:
    LD (HL),C       ;
        ld      (hl), c         ;

line 5865:
    DEC HL          ;
        dec     hl              ;

line 5866:
    DEC A           ;
        dec     a               ;

line 5867:
    JR NZ,L147F     ; back to DIM-SIZES
        jr      nz, L147F       ; back to DIM-SIZES

line 5869:
    RET             ; return.
        ret                     ; return.

line 5876:
L1488:  LD HL,($401A)       ; address STKBOT
L1488:  ld hl, ($401A)          ; address STKBOT

line 5877:
    DEC HL          ; now last byte of workspace
        dec     hl              ; now last byte of workspace

line 5878:
    CALL L099E      ; routine MAKE-ROOM
        call    L099E           ; routine MAKE-ROOM

line 5879:
    INC HL          ;
        inc     hl              ;

line 5880:
    INC HL          ;
        inc     hl              ;

line 5881:
    POP BC          ;
        pop     bc              ;

line 5882:
    LD ($4014),BC       ; sv E_LINE_lo
        ld      ($4014), bc     ; sv E_LINE_lo

line 5883:
    POP BC          ;
        pop     bc              ;

line 5884:
    EX DE,HL        ;
        ex      de, hl          ;

line 5885:
    INC HL          ;
        inc     hl              ;

line 5886:
    RET             ;
        ret                     ;

line 5893:
L149A:  LD HL,($4010)       ; sv VARS_lo
L149A:  ld hl, ($4010)          ; sv VARS_lo

line 5894:
    LD (HL),$80     ;
        ld      (hl), $80       ;

line 5895:
    INC HL          ;
        inc     hl              ;

line 5896:
    LD ($4014),HL       ; sv E_LINE_lo
        ld      ($4014), hl     ; sv E_LINE_lo

line 5903:
L14A3:  LD HL,($4014)       ; sv E_LINE_lo
L14A3:  ld hl, ($4014)          ; sv E_LINE_lo

line 5910:
L14A6:  LD ($401A),HL       ; sv STKBOT
L14A6:  ld ($401A), hl          ; sv STKBOT

line 5913:
L14A9:  LD ($401C),HL       ; sv STKEND
L14A9:  ld ($401C), hl          ; sv STKEND

line 5914:
    RET             ;
        ret                     ;

line 5923:
L14AD:  LD HL,($4014)       ; fetch start of edit line from E_LINE
L14AD:  ld hl, ($4014)          ; fetch start of edit line from E_LINE

line 5924:
    LD (HL),$7F     ; insert cursor character
        ld      (hl), $7F       ; insert cursor character

line 5926:
    INC HL          ; point to next location.
        inc     hl              ; point to next location.

line 5927:
    LD (HL),$76     ; insert NEWLINE character
        ld      (hl), $76       ; insert NEWLINE character

line 5928:
    INC HL          ; point to next free location.
        inc     hl              ; point to next free location.

line 5930:
    LD (IY+$22),$02     ; set lower screen display file size DF_SZ
        ld      (iy+$22), $02   ; set lower screen display file size DF_SZ

line 5932:
    JR L14A6        ; exit via SET-STK-B above
        jr      L14A6           ; exit via SET-STK-B above

line 5939:
L14BC:  LD HL,$405D     ; normal location of calculator's memory area
L14BC:  ld hl, $405D            ; normal location of calculator's memory area

line 5940:
    LD ($401F),HL       ; update system variable MEM
        ld      ($401F), hl     ; update system variable MEM

line 5941:
    LD HL,($401A)       ; fetch STKBOT
        ld      hl, ($401A)     ; fetch STKBOT

line 5942:
    JR L14A9        ; back to SET-STK-E
        jr      L14A9           ; back to SET-STK-E

line 5949:
L14C7:  LD DE,($4014)       ; sv E_LINE_lo
L14C7:  ld de, ($4014)          ; sv E_LINE_lo

line 5950:
    JP L0A5D        ; to RECLAIM-1
        jp      L0A5D           ; to RECLAIM-1

line 5957:
L14CE:  CP $26          ;
L14CE:  cp $26                  ;

line 5958:
    JR L14D4        ; skip forward to ALPHA-2
        jr      L14D4           ; skip forward to ALPHA-2

line 5965:
L14D2:  CP $1C          ;
L14D2:  cp $1C                  ;

line 5968:
L14D4:  CCF         ; Complement Carry Flag
L14D4:  ccf                     ; Complement Carry Flag

line 5969:
    RET NC          ;
        ret     nc              ;

line 5971:
    CP $40          ;
        cp      $40             ;

line 5972:
    RET             ;
        ret                     ;

line 5979:
L14D9:  CALL L1548      ; routine INT-TO-FP gets first part
L14D9:  call L1548              ; routine INT-TO-FP gets first part

line 5980:
    CP $1B          ; is character a '.' ?
        cp      $1B             ; is character a '.' ?

line 5981:
    JR NZ,L14F5     ; forward if not to E-FORMAT
        jr      nz, L14F5       ; forward if not to E-FORMAT

line 5983:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 5984:
    DEFB $A1    ;;stk-one
        defb    $A1             ;;stk-one

line 5985:
    DEFB $C0    ;;st-mem-0
        defb    $C0             ;;st-mem-0

line 5986:
    DEFB $02    ;;delete
        defb    $02             ;;delete

line 5987:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 5997:
L14E5:  RST 20H         ; NEXT-CHAR
L14E5:  rst 20H                 ; NEXT-CHAR

line 5998:
    CALL L1514      ; routine STK-DIGIT
        call    L1514           ; routine STK-DIGIT

line 5999:
    JR C,L14F5      ; forward to E-FORMAT
        jr      c, L14F5        ; forward to E-FORMAT

line 6001:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 6003:
    DEFB $E0    ;;get-mem-0
        defb    $E0             ;;get-mem-0

line 6005:
    .db $3B     ;;macro mul-by-10
        .db $3B                 ;;macro mul-by-10

line 6007:
    DEFB $C0    ;;st-mem-0
        defb    $C0             ;;st-mem-0

line 6008:
    DEFB $05    ;;+division
        defb    $05             ;;+division

line 6009:
    DEFB $0F    ;;addition
        defb    $0F             ;;addition

line 6010:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 6012:
    JR L14E5        ; loop back till exhausted to NXT-DGT-1
        jr      L14E5           ; loop back till exhausted to NXT-DGT-1

line 6014:
    .db $FF         ; spare :)
        .db $FF                 ; spare :)

line 6017:
L14F5:  CP $2A          ; is character 'E' ?
L14F5:  cp $2A                  ; is character 'E' ?

line 6018:
    RET NZ          ; return if not
        ret     nz              ; return if not

line 6020:
    LD (IY+$5D),$FF     ; initialize sv MEM-0-1st to $FF TRUE
        ld      (iy+$5D), $FF   ; initialize sv MEM-0-1st to $FF TRUE

line 6022:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 6023:
    CP $15          ; is character a '+' ?
        cp      $15             ; is character a '+' ?

line 6024:
    JR Z,L1508      ; forward if so to SIGN-DONE
        jr      z, L1508        ; forward if so to SIGN-DONE

line 6026:
    CP $16          ; is it a '-' ?
        cp      $16             ; is it a '-' ?

line 6027:
    JR NZ,L1509     ; forward if not to ST-E-PART
        jr      nz, L1509       ; forward if not to ST-E-PART

line 6029:
    INC (IY+$5D)        ; sv MEM-0-1st change to FALSE
        inc     (iy+$5D)        ; sv MEM-0-1st change to FALSE

line 6032:
L1508:  RST 20H         ; NEXT-CHAR
L1508:  rst 20H                 ; NEXT-CHAR

line 6035:
L1509:  CALL L1548      ; routine INT-TO-FP
L1509:  call L1548              ; routine INT-TO-FP

line 6037:
    RST 28H     ;; FP-CALC  m, e.
        rst     28H             ;; FP-CALC  m, e.

line 6038:
    DEFB $E0    ;;get-mem-0 m, e, (1/0) TRUE/FALSE
        defb    $E0             ;;get-mem-0 m, e, (1/0) TRUE/FALSE

line 6040:
    DEFB $00    ;;jump-true
        defb    $00             ;;jump-true

line 6041:
    DEFB L1511-$    ;;to E-POSTVE
        defb    L1511-$         ;;to E-POSTVE

line 6043:
    DEFB $18    ;;neg       m, -e
        defb    $18             ;;neg       m, -e

line 6046:
L1511:  DEFB $38    ;;e-to-fp   x.
L1511:  defb $38                ;;e-to-fp   x.

line 6047:
    DEFB $34    ;;end-calc  x.
        defb    $34             ;;end-calc  x.

line 6049:
    RET             ; return.
        ret                     ; return.

line 6056:
L1514:  CP $1C          ;
L1514:  cp $1C                  ;

line 6057:
    RET C           ;
        ret     c               ;

line 6059:
    CP $26          ;
        cp      $26             ;

line 6060:
    CCF         ; Complement Carry Flag
        ccf                     ; Complement Carry Flag

line 6061:
    RET C           ;
        ret     c               ;

line 6063:
    SUB $1C         ;
        sub     $1C             ;

line 6069:
STACK_A             ; (L151D)
STACK_A                         ; (L151D)

line 6070:
    LD C,A          ;
        ld      c, a            ;

line 6071:
    LD B,$00        ;
        ld      b, $00          ;

line 6079:
STACK_BC            ; (L1520)
STACK_BC                        ; (L1520)

line 6080:
    LD IY,$4000     ; re-initialize the system variables pointer.
        ld      iy, $4000       ; re-initialize the system variables pointer.

line 6081:
    PUSH BC         ; save the integer value.
        push    bc              ; save the integer value.

line 6085:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 6086:
    DEFB $A0    ;;stk-zero  0.
        defb    $A0             ;;stk-zero  0.

line 6087:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 6089:
    POP BC          ; restore integer value.
        pop     bc              ; restore integer value.

line 6091:
    LD (HL),$91     ; place $91 in exponent 65536.
        ld      (hl), $91       ; place $91 in exponent 65536.

line 6092:
                ; this is the maximum possible value
                                ; this is the maximum possible value

line 6094:
    LD A,B          ; fetch hi-byte.
        ld      a, b            ; fetch hi-byte.

line 6095:
    AND A           ; test for zero.
        and     a               ; test for zero.

line 6096:
    JR NZ,L1536     ; forward if not zero to STK-BC-2
        jr      nz, L1536       ; forward if not zero to STK-BC-2

line 6098:
    LD (HL),A       ; else make exponent zero again
        ld      (hl), a         ; else make exponent zero again

line 6099:
    OR C            ; test lo-byte
        or      c               ; test lo-byte

line 6100:
    RET Z           ; return if BC was zero - done.
        ret     z               ; return if BC was zero - done.

line 6104:
    LD B,C          ; save C in B.
        ld      b, c            ; save C in B.

line 6105:
    LD C,(HL)       ; fetch zero to C
        ld      c, (hl)         ; fetch zero to C

line 6106:
    LD (HL),$89     ; make exponent $89  256.
        ld      (hl), $89       ; make exponent $89  256.

line 6109:
L1536:  DEC (HL)        ; decrement exponent - halving number
L1536:  dec (hl)                ; decrement exponent - halving number

line 6110:
    SLA C           ;  C<-76543210<-0
        sla     c               ;  C<-76543210<-0

line 6111:
    RL B            ;  C<-76543210<-C
        rl      b               ;  C<-76543210<-C

line 6112:
    JR NC,L1536     ; loop back if no carry to STK-BC-2
        jr      nc, L1536       ; loop back if no carry to STK-BC-2

line 6114:
    SRL B           ;  0->76543210->C
        srl     b               ;  0->76543210->C

line 6115:
    RR C            ;  C->76543210->C
        rr      c               ;  C->76543210->C

line 6117:
    INC HL          ; address first byte of mantissa
        inc     hl              ; address first byte of mantissa

line 6118:
    LD (HL),B       ; insert B
        ld      (hl), b         ; insert B

line 6119:
    INC HL          ; address second byte of mantissa
        inc     hl              ; address second byte of mantissa

line 6120:
    LD (HL),C       ; insert C
        ld      (hl), c         ; insert C

line 6122:
    DEC HL          ; point to the
        dec     hl              ; point to the

line 6123:
    DEC HL          ; exponent again
        dec     hl              ; exponent again

line 6124:
    RET             ; return.
        ret                     ; return.

line 6131:
L1548:  PUSH AF         ;
L1548:  push af                 ;

line 6133:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 6134:
    DEFB $A0    ;;stk-zero
        defb    $A0             ;;stk-zero

line 6135:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 6137:
    POP AF          ;
        pop     af              ;

line 6140:
L154D:  CALL L1514      ; routine STK-DIGIT
L154D:  call L1514              ; routine STK-DIGIT

line 6141:
    RET C           ;
        ret     c               ;

line 6144:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 6145:
    DEFB $01    ;;exchange
        defb    $01             ;;exchange

line 6147:
    .db $3B     ;;macro mul-by-10
        .db $3B                 ;;macro mul-by-10

line 6149:
    DEFB $0F    ;;addition
        defb    $0F             ;;addition

line 6150:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 6152:
    RST 20H         ; NEXT-CHAR
        rst     20H             ; NEXT-CHAR

line 6153:
    JR L154D        ; to NXT-DGT-2
        jr      L154D           ; to NXT-DGT-2

line 6155:
    .db $FF         ; spare :)
        .db $FF                 ; spare :)

line 6169:
e_to_fp             ; (L155A)
e_to_fp                         ; (L155A)

line 6170:
    call L158A      ; routine FP-TO-BC - the exponent
        call    L158A           ; routine FP-TO-BC - the exponent

line 6172:
    jr z,E_POSTV        ; test the exponent's sign
        jr      z, E_POSTV      ; test the exponent's sign

line 6174:
    inc b           ; if negative then B=1
        inc     b               ; if negative then B=1

line 6175:
    push bc         ; save counter (exponent and its sign)
        push    bc              ; save counter (exponent and its sign)

line 6177:
    rst 28H     ;; FP-CALC  x.
        rst     28H             ;; FP-CALC  x.

line 6178:
    .db $A4     ;; stk-ten  x, 10.
        .db $A4                 ;; stk-ten  x, 10.

line 6179:
    .db $34     ;; end-calc
        .db $34                 ;; end-calc

line 6181:
    jr skip_mul     ; restore counter (exponent and its sign)
        jr      skip_mul        ; restore counter (exponent and its sign)

line 6183:
    and a           ; if exponent is zero
        and     a               ; if exponent is zero

line 6184:
    ret z           ; then return
        ret     z               ; then return

line 6188:
    push bc         ; save counter (exponent and its sign)
        push    bc              ; save counter (exponent and its sign)

line 6189:
    call mul_by10       ; multiply by 10
        call    mul_by10        ; multiply by 10

line 6191:
    pop bc          ; restore counter (exponent and its sign)
        pop     bc              ; restore counter (exponent and its sign)

line 6192:
    dec c           ; set counter
        dec     c               ; set counter

line 6193:
    jr nz,LOOP_E10      ; loop while nonzero
        jr      nz, LOOP_E10    ; loop while nonzero

line 6195:
    djnz E_END      ; in case of pos. exp. return
        djnz    E_END           ; in case of pos. exp. return

line 6197:
    rst 28H     ;; FP-CALC  else
        rst     28H             ;; FP-CALC  else

line 6198:
    .db $05     ;;division  x/10^exp10.
        .db $05                 ;;division  x/10^exp10.

line 6199:
    .db $34     ;;end-calc  new x.
        .db $34                 ;;end-calc  new x.

line 6201:
    ret
        ret

line 6205:
    ld b,4          ; size of the mantissa
        ld      b, 4            ; size of the mantissa

line 6206:
    ld h,d          ; set pointer after the
        ld      h, d            ; set pointer after the

line 6207:
    ld l,e          ; LSB of the mantissa
        ld      l, e            ; LSB of the mantissa

line 6208:
    scf         ; CY=1
        scf                     ; CY=1

line 6210:
    dec hl          ; the last/prev. mantissa byte
        dec     hl              ; the last/prev. mantissa byte

line 6211:
    rl (hl)         ; CY <- 76543210 <- CY
        rl      (hl)            ; CY <- 76543210 <- CY

line 6212:
    djnz nx_mbyte       ; done? back if not
        djnz    nx_mbyte        ; done? back if not

line 6214:
    dec hl          ; points the exponent
        dec     hl              ; points the exponent

line 6215:
    dec (hl)        ; decrease it
        dec     (hl)            ; decrease it

line 6216:
    ret         ;
        ret                     ;

line 6227:
    CALL FIND_INT       ; routine FIND-INT puts address in BC.
        call    FIND_INT        ; routine FIND-INT puts address in BC.

line 6228:
    LD A,(BC)       ; load contents into A register.
        ld      a, (bc)         ; load contents into A register.

line 6230:
    JP STACK_A      ; exit via STACK-A to put value on the
        jp      STACK_A         ; exit via STACK-A to put value on the

line 6231:
                ; calculator stack.
                                ; calculator stack.

line 6243:
L158A:  CALL STK_FETCH      ; routine STK-FETCH - exponent to A
L158A:  call STK_FETCH          ; routine STK-FETCH - exponent to A

line 6244:
                ; mantissa to EDCB.
                                ; mantissa to EDCB.

line 6245:
    rla         ; test if abs(x)>=0.5  (exp>=128)
        rla                     ; test if abs(x)>=0.5  (exp>=128)

line 6246:
    jr c,L1595      ; forward if yes (CY=1) to FPBC-NZRO
        jr      c, L1595        ; forward if yes (CY=1) to FPBC-NZRO

line 6250:
    xor a           ; else clear CY and A, set Z flag
        xor     a               ; else clear CY and A, set Z flag

line 6251:
    LD B,A          ; zero to B
        ld      b, a            ; zero to B

line 6252:
    LD C,A          ; also to C
        ld      c, a            ; also to C

line 6253:
    jr L15C4        ; forward to FPBC-ZRO
        jr      L15C4           ; forward to FPBC-ZRO

line 6260:
    LD B,E          ; transfer the mantissa from EDCB
        ld      b, e            ; transfer the mantissa from EDCB

line 6261:
    LD E,C          ; to BCE. Bit 7 of E is the 17th bit which
        ld      e, c            ; to BCE. Bit 7 of E is the 17th bit which

line 6262:
    LD C,D          ; will be significant for rounding if the
        ld      c, d            ; will be significant for rounding if the

line 6263:
                ; number is already normalized.
                                ; number is already normalized.

line 6265:
    rra         ; restore the original exponent
        rra                     ; restore the original exponent

line 6267:
    SUB $91         ; subtract 65536
        sub     $91             ; subtract 65536

line 6268:
    CCF         ; complement carry flag
        ccf                     ; complement carry flag

line 6269:
    BIT 7,B         ; test sign bit
        bit     7, b            ; test sign bit

line 6270:
    PUSH AF         ; push the result
        push    af              ; push the result

line 6272:
    SET 7,B         ; set the implied bit
        set     7, b            ; set the implied bit

line 6273:
    JR C,L15C5      ; forward with carry from SUB/CCF to FPBC-END
        jr      c, L15C5        ; forward with carry from SUB/CCF to FPBC-END

line 6274:
                ; number is too big.
                                ; number is too big.

line 6276:
    cpl         ; complement to make range $00 - $0F
        cpl                     ; complement to make range $00 - $0F

line 6278:
    CP $08          ; test if one or two bytes
        cp      $08             ; test if one or two bytes

line 6279:
    JR C,L15AE      ; forward with two to BIG-INT
        jr      c, L15AE        ; forward with two to BIG-INT

line 6281:
    LD E,C          ; shift mantissa
        ld      e, c            ; shift mantissa

line 6282:
    LD C,B          ; 8 places right
        ld      c, b            ; 8 places right

line 6283:
    LD B,$00        ; insert a zero in B
        ld      b, $00          ; insert a zero in B

line 6284:
    SUB $08         ; reduce exponent by eight
        sub     $08             ; reduce exponent by eight

line 6287:
L15AE:  AND A           ; test the exponent
L15AE:  and a                   ; test the exponent

line 6288:
    LD D,A          ; save exponent in D.
        ld      d, a            ; save exponent in D.

line 6290:
    LD A,E          ; fractional bits to A
        ld      a, e            ; fractional bits to A

line 6291:
    RLCA            ; rotate most significant bit to carry for
        rlca                    ; rotate most significant bit to carry for

line 6292:
                ; rounding of an already normal number.
                                ; rounding of an already normal number.

line 6294:
    JR Z,L15BB      ; forward if exponent zero to EXP-ZERO
        jr      z, L15BB        ; forward if exponent zero to EXP-ZERO

line 6295:
                ; the number is normalized
                                ; the number is normalized

line 6298:
L15B4:  SRL B           ;   0->76543210->C
L15B4:  srl b                   ;   0->76543210->C

line 6299:
    RR C            ;   C->76543210->C
        rr      c               ;   C->76543210->C

line 6301:
    DEC D           ; decrement exponent
        dec     d               ; decrement exponent

line 6302:
    JR NZ,L15B4     ; loop back till zero to FPBC-NORM
        jr      nz, L15B4       ; loop back till zero to FPBC-NORM

line 6306:
    JR NC,L15C5     ; forward without carry to FPBC-END (NO-ROUND)
        jr      nc, L15C5       ; forward without carry to FPBC-END (NO-ROUND)

line 6308:
    INC BC          ; round up.
        inc     bc              ; round up.

line 6309:
    LD A,B          ; test result
        ld      a, b            ; test result

line 6310:
    OR C            ; for zero
        or      c               ; for zero

line 6311:
    JR NZ,L15C5     ; forward if not to FPBC-END
        jr      nz, L15C5       ; forward if not to FPBC-END

line 6313:
    POP AF          ; restore sign flag
        pop     af              ; restore sign flag

line 6314:
    SCF         ; set carry flag to indicate overflow
        scf                     ; set carry flag to indicate overflow

line 6317:
L15C4:  PUSH AF         ; save combined flags again
L15C4:  push af                 ; save combined flags again

line 6320:
L15C5:  PUSH BC         ; save BC value
L15C5:  push bc                 ; save BC value

line 6324:
    call STK_PNTRS      ; routine STK-PNTRS is called to set up the
        call    STK_PNTRS       ; routine STK-PNTRS is called to set up the

line 6325:
                ; calculator stack pointers:
                                ; calculator stack pointers:

line 6326:
                ; HL = last value on stack.
                                ; HL = last value on stack.

line 6327:
                ; DE = STKEND first location after stack.
                                ; DE = STKEND first location after stack.

line 6329:
    POP BC          ; restore BC value
        pop     bc              ; restore BC value

line 6330:
    POP AF          ; restore flags
        pop     af              ; restore flags

line 6331:
    LD A,C          ; copy low byte to A also.
        ld      a, c            ; copy low byte to A also.

line 6332:
    RET             ; return
        ret                     ; return

line 6338:
FP_TO_A             ; (L15CD)
FP_TO_A                         ; (L15CD)

line 6339:
    CALL L158A      ; routine FP-TO-BC
        call    L158A           ; routine FP-TO-BC

line 6340:
    RET C           ;
        ret     c               ;

line 6342:
    PUSH AF         ;
        push    af              ;

line 6343:
    DEC B           ;
        dec     b               ;

line 6344:
    INC B           ;
        inc     b               ;

line 6345:
    JR Z,L15D9      ; forward if in range to FP-A-END
        jr      z, L15D9        ; forward if in range to FP-A-END

line 6347:
    POP AF          ; fetch result
        pop     af              ; fetch result

line 6348:
    SCF         ; set carry flag signaling overflow
        scf                     ; set carry flag signaling overflow

line 6349:
    RET         ; return
        ret                     ; return

line 6352:
L15D9:  POP AF          ;
L15D9:  pop af                  ;

line 6353:
    RET         ;
        ret                     ;

line 6362:
    rst 28h     ; FP-CALC   x.
        rst     28h             ; FP-CALC   x.

line 6363:
    .db $C0     ;;set-mem-0 x.
        .db $C0                 ;;set-mem-0 x.

line 6364:
    .db $02     ;;delete    .   clear the
        .db $02                 ;;delete    .   clear the

line 6365:
    .db $34     ;;end-calc      calc. stack
        .db $34                 ;;end-calc      calc. stack

line 6367:
    ld a,(de)       ; pick up the exponent byte
        ld      a, (de)         ; pick up the exponent byte

line 6368:
    and a           ; if it is zero, then return via
        and     a               ; if it is zero, then return via

line 6369:
    jp z,prnt_num       ; routine OUT-CODE (prints a zero)
        jp      z, prnt_num     ; routine OUT-CODE (prints a zero)

line 6371:
    call STACK_A        ; else STACK-A places on calculator stack.
        call    STACK_A         ; else STACK-A places on calculator stack.

line 6373:
    ld hl,$405E     ; first byte of the mantissa (MEMBOT+1)
        ld      hl, $405E       ; first byte of the mantissa (MEMBOT+1)

line 6374:
    bit 7,(hl)      ; test if positive
        bit     7, (hl)         ; test if positive

line 6375:
    set 7,(hl)      ; complete the mantissa (make it negative)
        set     7, (hl)         ; complete the mantissa (make it negative)

line 6377:
    ld l,$67        ; set pointer to MEMBOT+10 (mem2)
        ld      l, $67          ; set pointer to MEMBOT+10 (mem2)

line 6378:
    push hl         ; save pointer (of the digit buffer)
        push    hl              ; save pointer (of the digit buffer)

line 6380:
    jr z,positive       ; skip if positive
        jr      z, positive     ; skip if positive

line 6382:
    ld a,$16        ; load code '-'
        ld      a, $16          ; load code '-'

line 6383:
    rst 10h         ; PRINT-A
        rst     10h             ; PRINT-A

line 6385:
    rst 28H     ;; FP-CALC      e   [1..255]
        rst     28H             ;; FP-CALC      e   [1..255]

line 6387:
        .db $30, $EF        ;; stk-data, exponent: $7F, bytes: 4
        .db $30, $EF            ;; stk-data, exponent: $7F, bytes: 4

line 6388:
        .db $9A,$20,$9A,$84 ;;      e, -0.30103 (-log 2)
        .db $9A, $20, $9A, $84  ;;      e, -0.30103 (-log 2)

line 6390:
        .db $04     ;; multiply     e*(-log 2)
        .db $04                 ;; multiply     e*(-log 2)

line 6392:
    .db $30, $36    ;; stk-data exponent:   $86, Bytes: 1
        .db $30, $36            ;; stk-data exponent:   $86, Bytes: 1

line 6393:
    .db $1C     ;; (+00,+00,+00)    e*(-log 2), 39
        .db $1C                 ;; (+00,+00,+00)    e*(-log 2), 39

line 6395:
    .db $0F     ;; addition     e*(-log 2)+39
        .db $0F                 ;; addition     e*(-log 2)+39

line 6397:
    .db $C2     ;; st-mem-2     exp10.
        .db $C2                 ;; st-mem-2     exp10.

line 6398:
    .db $E0     ;; get-mem-0        exp10, x.
        .db $E0                 ;; get-mem-0        exp10, x.

line 6399:
    .db $E2     ;; get-mem-2        exp10, x, exp10.
        .db $E2                 ;; get-mem-2        exp10, x, exp10.

line 6401:
    .db $38     ;; new e-to-fp      exp10,x * (10^exp10).
        .db $38                 ;; new e-to-fp      exp10,x * (10^exp10).

line 6402:
    .db $34     ;; end-calc
        .db $34                 ;; end-calc

line 6406:
    ld bc,$0900     ; B: 9 digits to convert
        ld      bc, $0900       ; B: 9 digits to convert

line 6407:
                ; C: exp10 factor (0 by default)
                                ; C: exp10 factor (0 by default)

line 6408:
    push bc         ; save counter/factor
        push    bc              ; save counter/factor

line 6410:
    ld a,(hl)       ; test the normalized number
        ld      a, (hl)         ; test the normalized number

line 6411:
    sub $81         ; >=1?
        sub     $81             ; >=1?

line 6412:
    jr nc,getDigit      ; if yes, then get the 1st digit
        jr      nc, getDigit    ; if yes, then get the 1st digit

line 6414:
    pop bc          ; else restore counter/factor
        pop     bc              ; else restore counter/factor

line 6415:
    dec c           ; set factor to -1
        dec     c               ; set factor to -1

line 6416:
    push bc         ; save counter/factor
        push    bc              ; save counter/factor

line 6417:
    inc hl          ; set pointer to the mantissa, then
        inc     hl              ; set pointer to the mantissa, then

line 6419:
    dec hl          ; hl points the exponent
        dec     hl              ; hl points the exponent

line 6420:
    call mul_by10       ; multiply by 10
        call    mul_by10        ; multiply by 10

line 6422:
    ld a,(hl)       ; pick up the exponent
        ld      a, (hl)         ; pick up the exponent

line 6423:
    sub $81         ; test if >=1
        sub     $81             ; test if >=1

line 6424:
    jr nc,getDigit      ; jump if so
        jr      nc, getDigit    ; jump if so

line 6426:
    xor a           ; else clear A
        xor     a               ; else clear A

line 6427:
    jr putDigit     ; less than 1? -> put zero into buffer
        jr      putDigit        ; less than 1? -> put zero into buffer

line 6431:
    inc a           ; exp-$80 gives the
        inc     a               ; exp-$80 gives the

line 6432:
    ld c,a          ; bit counter of a digit
        ld      c, a            ; bit counter of a digit

line 6433:
    xor a           ; clear CY and the bit buffer
        xor     a               ; clear CY and the bit buffer

line 6435:
    call mb_loop        ; shift left the mantissa
        call    mb_loop         ; shift left the mantissa

line 6437:
    rla         ; store 1 bit of the digit
        rla                     ; store 1 bit of the digit

line 6438:
    dec c           ; set bit counter
        dec     c               ; set bit counter

line 6439:
    jr nz,nxt_mbit      ; done? -> back if not
        jr      nz, nxt_mbit    ; done? -> back if not

line 6441:
    pop bc          ; restore counter/factor
        pop     bc              ; restore counter/factor

line 6442:
    ex (sp),hl      ; switch pointers
        ex      (sp), hl        ; switch pointers

line 6443:
    ld (hl),a       ; put digit into buffer
        ld      (hl), a         ; put digit into buffer

line 6444:
    inc l           ; set buffer pointer
        inc     l               ; set buffer pointer

line 6445:
    ex (sp),hl      ; switch back pointers
        ex      (sp), hl        ; switch back pointers

line 6447:
    dec b           ; set the digit counter
        dec     b               ; set the digit counter

line 6448:
    push bc         ; save counter/factor
        push    bc              ; save counter/factor

line 6449:
    jr z,dig9done       ; done if it was the 9th digit
        jr      z, dig9done     ; done if it was the 9th digit

line 6451:
    inc hl          ; else normalize the number
        inc     hl              ; else normalize the number

line 6452:
    bit 7,(hl)      ; test the msb of the mantissa
        bit     7, (hl)         ; test the msb of the mantissa

line 6453:
    jr nz,mul_ten       ; back if it is nonzero
        jr      nz, mul_ten     ; back if it is nonzero

line 6455:
    call mb_loop        ; shift left the mantissa
        call    mb_loop         ; shift left the mantissa

line 6456:
    jr test_msb     ;
        jr      test_msb        ;

line 6460:
    call STK_FETCH      ; remove final x from calc. stack
        call    STK_FETCH       ; remove final x from calc. stack

line 6462:
    call FP_TO_A        ; FP-TO-A (-exp10) : A=abs(exp10)
        call    FP_TO_A         ; FP-TO-A (-exp10) : A=abs(exp10)

line 6463:
    jr nz,negative      ; if it is positive
        jr      nz, negative    ; if it is positive

line 6465:
    neg         ; then make it negative
        neg                     ; then make it negative

line 6467:
    pop bc          ; get the exp10 factor (0 or -1)
        pop     bc              ; get the exp10 factor (0 or -1)

line 6468:
    add a,c         ; and add to the exp10
        add     a, c            ; and add to the exp10

line 6470:
    pop hl          ; get the buffer pointer
        pop     hl              ; get the buffer pointer

line 6471:
    dec l           ; points the 9th digit
        dec     l               ; points the 9th digit

line 6472:
    push af         ; save the final exp10
        push    af              ; save the final exp10

line 6476:
    push hl         ; save the buffer pointer
        push    hl              ; save the buffer pointer

line 6477:
    ld a,4          ; test the last digit (>=5?)
        ld      a, 4            ; test the last digit (>=5?)

line 6478:
    sub (hl)        ; CY=1 if rounding is necessary
        sub     (hl)            ; CY=1 if rounding is necessary

line 6479:
    ld b,8          ; set the digit counter
        ld      b, 8            ; set the digit counter

line 6481:
    dec l           ; set buffer pointer
        dec     l               ; set buffer pointer

line 6482:
    ld a,(hl)       ; pick up the next digit
        ld      a, (hl)         ; pick up the next digit

line 6483:
    adc a,$90       ; add the rounding bit
        adc     a, $90          ; add the rounding bit

line 6484:
    daa         ; BCD correction
        daa                     ; BCD correction

line 6485:
    jr c,overflow       ; jump if overflow
        jr      c, overflow     ; jump if overflow

line 6487:
    and $0F         ; else clear the upper nibble
        and     $0F             ; else clear the upper nibble

line 6489:
    ld (hl),a       ; store the digit
        ld      (hl), a         ; store the digit

line 6490:
    djnz round_8        ; done? -> back if not
        djnz    round_8         ; done? -> back if not

line 6492:
    jr nc,cnt_zero      ; jump if no overflow
        jr      nc, cnt_zero    ; jump if no overflow

line 6494:
    pop hl          ; get pointer of the 9th digit
        pop     hl              ; get pointer of the 9th digit

line 6495:
    pop af          ; <- exp10
        pop     af              ; <- exp10

line 6496:
    inc a           ; exp10 +1
        inc     a               ; exp10 +1

line 6497:
    push af         ; exp10 ->
        push    af              ; exp10 ->

line 6498:
    push hl         ; save pointer
        push    hl              ; save pointer

line 6499:
    ld d,h          ; set the
        ld      d, h            ; set the

line 6500:
    ld e,l          ; destination pointer
        ld      e, l            ; destination pointer

line 6501:
    dec l           ; 8th digit
        dec     l               ; 8th digit

line 6502:
    ld c,8          ; set counter
        ld      c, 8            ; set counter

line 6503:
    lddr            ; copy
        lddr                    ; copy

line 6505:
    inc l           ; HL points the first digit
        inc     l               ; HL points the first digit

line 6506:
    ld (hl),1       ; set as '1'
        ld      (hl), 1         ; set as '1'

line 6510:
    pop hl          ; HL points the 9th digit
        pop     hl              ; HL points the 9th digit

line 6511:
    pop de          ; D <- exp10
        pop     de              ; D <- exp10

line 6515:
    ld bc,$0901     ; 8 digits to print, decimal
        ld      bc, $0901       ; 8 digits to print, decimal

line 6516:
                ; point is after the first
                                ; point is after the first

line 6517:
    ld e,c          ; e=1 (not e-format)
        ld      e, c            ; e=1 (not e-format)

line 6519:
    dec l           ; points a digit of the mantissa
        dec     l               ; points a digit of the mantissa

line 6520:
    dec b           ; decrease the counter
        dec     b               ; decrease the counter

line 6521:
    ld a,(hl)       ; read in and
        ld      a, (hl)         ; read in and

line 6522:
    and a           ; test a digit of the mantissa
        and     a               ; test a digit of the mantissa

line 6523:
    jr z,cnt_back       ; if zero then check next digit
        jr      z, cnt_back     ; if zero then check next digit

line 6525:
    ld a,d          ; test the exp10
        ld      a, d            ; test the exp10

line 6526:
    bit 7,a         ; positive?
        bit     7, a            ; positive?

line 6527:
    jr z,pos_exp        ; yes, jump
        jr      z, pos_exp      ; yes, jump

line 6531:
    neg         ; make it positive
        neg                     ; make it positive

line 6532:
    cp $05          ; less than .0001?
        cp      $05             ; less than .0001?

line 6533:
    jr nc,neg_exp       ; yes -> e-format
        jr      nc, neg_exp     ; yes -> e-format

line 6537:
    ld d,a          ; nr. of leading zeros
        ld      d, a            ; nr. of leading zeros

line 6538:
    add a,b         ; increase and
        add     a, b            ; increase and

line 6539:
    ld b,a          ; save nr. of printable digits
        ld      b, a            ; save nr. of printable digits

line 6541:
    xor a           ; print
        xor     a               ; print

line 6542:
    call pr_digit       ; leading
        call    pr_digit        ; leading

line 6543:
    dec d           ; zeros
        dec     d               ; zeros

line 6544:
    jr nz,leadzero      ; done?
        jr      nz, leadzero    ; done?

line 6546:
    jr not_efmt     ; forward to printing the rest
        jr      not_efmt        ; forward to printing the rest

line 6551:
    cp $08          ; more than 99999999?
        cp      $08             ; more than 99999999?

line 6552:
    jr nc,e_format      ; yes, e-format
        jr      nc, e_format    ; yes, e-format

line 6554:
    add a,c         ; set position of
        add     a, c            ; set position of

line 6555:
    ld c,a          ; the decimal point
        ld      c, a            ; the decimal point

line 6556:
    cp b            ; if nr. of the printable digits
        cp      b               ; if nr. of the printable digits

line 6557:
    jr c,not_efmt       ; is greater than position of the
        jr      c, not_efmt     ; is greater than position of the

line 6558:
                ; decimal point then forward
                                ; decimal point then forward

line 6559:
    ld b,c          ; else set nr. of printable digits
        ld      b, c            ; else set nr. of printable digits

line 6560:
    jr not_efmt     ; to decimal point position
        jr      not_efmt        ; to decimal point position

line 6564:
    inc e           ; the exponent is negative
        inc     e               ; the exponent is negative

line 6568:
    ld d,a          ; save value of the exponent
        ld      d, a            ; save value of the exponent

line 6569:
    inc e           ; set e-format (e>1)
        inc     e               ; set e-format (e>1)

line 6573:
    ld l,$67        ; $4067 - addr. of the first digit
        ld      l, $67          ; $4067 - addr. of the first digit

line 6575:
    ld a,(hl)       ; get value
        ld      a, (hl)         ; get value

line 6576:
    inc l           ; set pointer
        inc     l               ; set pointer

line 6577:
    call pr_digit       ; display a digit
        call    pr_digit        ; display a digit

line 6579:
    jr nz,e_form1       ; back until done
        jr      nz, e_form1     ; back until done

line 6581:
    dec e           ; e-format (e>1) ?
        dec     e               ; e-format (e>1) ?

line 6582:
    ret z           ; no, done
        ret     z               ; no, done

line 6584:
    dec c           ; else set decimal point
        dec     c               ; else set decimal point

line 6586:
    ld a,$2A        ;
        ld      a, $2A          ;

line 6587:
    rst 10h         ; print 'E'
        rst     10h             ; print 'E'

line 6589:
    ld a,$15        ; load '+'
        ld      a, $15          ; load '+'

line 6590:
    dec e           ; if exp>0 then E=0
        dec     e               ; if exp>0 then E=0

line 6591:
    add a,e         ; else E=1 -> A: '-'
        add     a, e            ; else E=1 -> A: '-'

line 6592:
    rst 10h         ; PRINT-A
        rst     10h             ; PRINT-A

line 6596:
    ld a,d          ; get value of the exponent
        ld      a, d            ; get value of the exponent

line 6598:
    ld d,a          ; save as ones
        ld      d, a            ; save as ones

line 6599:
    sub 10          ; decrease by 10
        sub     10              ; decrease by 10

line 6600:
    jr c,set_E2     ; until negative
        jr      c, set_E2       ; until negative

line 6602:
    djnz set_E1     ; count tens
        djnz    set_E1          ; count tens

line 6604:
    xor a           ; the counter of tens is negative
        xor     a               ; the counter of tens is negative

line 6605:
    sub b           ; make it positive, then
        sub     b               ; make it positive, then

line 6606:
    call nz,pr_digit    ; print if nonzero
        call    nz, pr_digit    ; print if nonzero

line 6608:
    ld a,d          ; the ones
        ld      a, d            ; the ones

line 6612:
    call prnt_num       ; print as number (0..9)
        call    prnt_num        ; print as number (0..9)

line 6614:
    dec b           ; it was the last digit?
        dec     b               ; it was the last digit?

line 6615:
    ret z           ; yes return
        ret     z               ; yes return

line 6617:
    dec c           ; decimal point?
        dec     c               ; decimal point?

line 6618:
    ret nz          ; no, return
        ret     nz              ; no, return

line 6620:
    xor a           ;
        xor     a               ;

line 6621:
    jp prnt_dot     ; print '.'
        jp      prnt_dot        ; print '.'

line 6627:
    push bc         ; save counter
        push    bc              ; save counter

line 6628:
    ld a,c          ; test line counter (Y)
        ld      a, c            ; test line counter (Y)

line 6629:
    cp $18          ; clear whole screen?
        cp      $18             ; clear whole screen?

line 6630:
    jr nz,cls_skip      ; skip, if not
        jr      nz, cls_skip    ; skip, if not

line 6632:
    set 5,(IY+$3B)      ; sv CDFLAG - signal expanded D-FILE
        set     5, (iy+$3B)     ; sv CDFLAG - signal expanded D-FILE

line 6634:
    add a,a         ;  2*Y (line counter)
        add     a, a            ;  2*Y (line counter)

line 6635:
    add a,a         ;  4*Y
        add     a, a            ;  4*Y

line 6636:
    add a,a         ;  8*Y
        add     a, a            ;  8*Y

line 6637:
    ld c,a          ; BC = 8 * Y (line counter)
        ld      c, a            ; BC = 8 * Y (line counter)

line 6639:
    add hl,bc       ; + 8 * Y
        add     hl, bc          ; + 8 * Y

line 6640:
    add hl,bc       ; + 8 * Y
        add     hl, bc          ; + 8 * Y

line 6641:
    add hl,bc       ; + 8 * Y
        add     hl, bc          ; + 8 * Y

line 6642:
    add hl,bc       ; HL points the
        add     hl, bc          ; HL points the

line 6643:
    dec hl          ; end of D-FILE
        dec     hl              ; end of D-FILE

line 6644:
    call L0A17      ; routine DIFFER
        call    L0A17           ; routine DIFFER

line 6646:
    inc bc          ;
        inc     bc              ;

line 6647:
    dec hl          ; HL points the old end of D-FILE
        dec     hl              ; HL points the old end of D-FILE

line 6648:
    jr c,cls_cont       ; if room is enough then return
        jr      c, cls_cont     ; if room is enough then return

line 6650:
    call L099E      ; else routine MAKE-ROOM
        call    L099E           ; else routine MAKE-ROOM

line 6652:
    inc de          ; position of the latest N/L in D-FILE
        inc     de              ; position of the latest N/L in D-FILE

line 6654:
    ex de,hl        ;
        ex      de, hl          ;

line 6655:
    inc hl          ; points the (expected) variables area
        inc     hl              ; points the (expected) variables area

line 6656:
    pop bc          ; restore counter
        pop     bc              ; restore counter

line 6657:
    jp clr_next     ; back to renewed CLS routine
        jp      clr_next        ; back to renewed CLS routine

line 6661:
    jr z,scrl_old       ; jump if D-File is collapsed
        jr      z, scrl_old     ; jump if D-File is collapsed

line 6663:
    ld bc,33        ; set byte counter (32 spaces + 1 N/L)
        ld      bc, 33          ; set byte counter (32 spaces + 1 N/L)

line 6664:
    ldir            ; copy a line
        ldir                    ; copy a line

line 6665:
    dec a           ; set line counter
        dec     a               ; set line counter

line 6666:
    jr nz,scrl_nxt      ; done? back, if not
        jr      nz, scrl_nxt    ; done? back, if not

line 6668:
    jp clr_scrl     ; clear the last line and return
        jp      clr_scrl        ; clear the last line and return

line 6672:
    push de         ;
        push    de              ;

line 6673:
    call loc_pos0       ; ld c,$21 --> LOC-ADDR
        call    loc_pos0        ; ld c,$21 --> LOC-ADDR

line 6675:
    dec hl          ; insert a N/L before the N/L
        dec     hl              ; insert a N/L before the N/L

line 6676:
    call L099B      ; routine ONE-SPACE
        call    L099B           ; routine ONE-SPACE

line 6678:
    pop hl          ; HL points D_FILE
        pop     hl              ; HL points D_FILE

line 6679:
    INC HL          ; skip 1st N/L
        inc     hl              ; skip 1st N/L

line 6680:
    LD D,H          ; save pointer
        ld      d, h            ; save pointer

line 6681:
    LD E,L          ; in DE
        ld      e, l            ; in DE

line 6682:
    CPIR            ; find next N/L and
        cpir                    ; find next N/L and

line 6683:
    jp L0A5D        ; return via RECLAIM-1 (erase line 1)
        jp      L0A5D           ; return via RECLAIM-1 (erase line 1)

line 6710:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 6711:
    rlc b           ; the rounding bit (B'7)
        rlc     b               ; the rounding bit (B'7)

line 6712:
    exx         ;  ..   (main set)
        exx                     ;  ..   (main set)

line 6714:
    sbc a,e         ; the real subtraction
        sbc     a, e            ; the real subtraction

line 6715:
    ld e,a          ; 4th byte of the mantissa
        ld      e, a            ; 4th byte of the mantissa

line 6716:
    dec hl          ;
        dec     hl              ;

line 6717:
    ld a,(hl)       ;
        ld      a, (hl)         ;

line 6718:
    sbc a,d         ;
        sbc     a, d            ;

line 6719:
    ld d,a          ; 3rd byte of the mantissa
        ld      d, a            ; 3rd byte of the mantissa

line 6720:
    dec hl          ;
        dec     hl              ;

line 6721:
    ld a,(hl)       ;
        ld      a, (hl)         ;

line 6722:
    sbc a,c         ;
        sbc     a, c            ;

line 6723:
    ld c,a          ; 2nd byte of the mantissa
        ld      c, a            ; 2nd byte of the mantissa

line 6724:
    dec hl          ;
        dec     hl              ;

line 6725:
    ld a,(hl)       ;
        ld      a, (hl)         ;

line 6726:
    set 7,a         ; the msb is always '1'
        set     7, a            ; the msb is always '1'

line 6727:
    sbc a,b         ;
        sbc     a, b            ;

line 6728:
    ld b,a          ; B(MSB),C,D,E(LSB): the result's mantissa
        ld      b, a            ; B(MSB),C,D,E(LSB): the result's mantissa

line 6730:
    ld h,b          ;
        ld      h, b            ;

line 6731:
    ld l,c          ; HL: the upper word of the result's mantissa
        ld      l, c            ; HL: the upper word of the result's mantissa

line 6732:
    jr nc,sub_spos      ; skip if it is positive
        jr      nc, sub_spos    ; skip if it is positive

line 6734:
    ld hl,1         ; else negate the mantissa
        ld      hl, 1           ; else negate the mantissa

line 6735:
    sbc hl,de       ;
        sbc     hl, de          ;

line 6736:
    ex de,hl        ;
        ex      de, hl          ;

line 6737:
    add hl,de       ; clear HL
        add     hl, de          ; clear HL

line 6738:
    sbc hl,bc       ; H,L,D,E: the result's mantissa
        sbc     hl, bc          ; H,L,D,E: the result's mantissa

line 6740:
    ld bc,$2100     ; set counters
        ld      bc, $2100       ; set counters

line 6741:
    ld a,c          ; clear A
        ld      a, c            ; clear A

line 6742:
    rra         ; A7 indicates the sign change
        rra                     ; A7 indicates the sign change

line 6744:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 6745:
    rlc b           ; the rounding bit (B'7)
        rlc     b               ; the rounding bit (B'7)

line 6746:
    exx         ;  ..   (main set)
        exx                     ;  ..   (main set)

line 6747:
    bit 7,h         ; normalize
        bit     7, h            ; normalize

line 6748:
    jp nz,sub_end       ; done if msb=1
        jp      nz, sub_end     ; done if msb=1

line 6750:
    ex de,hl        ;
        ex      de, hl          ;

line 6751:
    adc hl,hl       ; double the lower word of the result's mantissa
        adc     hl, hl          ; double the lower word of the result's mantissa

line 6752:
    ex de,hl        ;
        ex      de, hl          ;

line 6753:
    adc hl,hl       ; double the upper word of the result's mantissa
        adc     hl, hl          ; double the upper word of the result's mantissa

line 6754:
    inc c           ; set counter
        inc     c               ; set counter

line 6755:
    djnz sub_norm       ; max. 32 shifts are accepted
        djnz    sub_norm        ; max. 32 shifts are accepted

line 6759:
    pop hl          ; drop return address
        pop     hl              ; drop return address

line 6760:
    pop hl          ; drop the greater exponent
        pop     hl              ; drop the greater exponent

line 6761:
    jr z_result     ; the result is zero
        jr      z_result        ; the result is zero

line 6778:
    LD A,(DE)       ; fetch exponent byte of second number the
        ld      a, (de)         ; fetch exponent byte of second number the

line 6779:
                ; subtrahend.
                                ; subtrahend.

line 6780:
    AND A           ; test for zero
        and     a               ; test for zero

line 6781:
    RET Z           ; return if zero - first number is result.
        ret     z               ; return if zero - first number is result.

line 6783:
    INC DE          ; address the first mantissa byte.
        inc     de              ; address the first mantissa byte.

line 6784:
    LD A,(DE)       ; fetch to accumulator.
        ld      a, (de)         ; fetch to accumulator.

line 6785:
    XOR $80         ; toggle the sign bit.
        xor     $80             ; toggle the sign bit.

line 6786:
    LD (DE),A       ; place back on calculator stack.
        ld      (de), a         ; place back on calculator stack.

line 6787:
    DEC DE          ; point to exponent byte.
        dec     de              ; point to exponent byte.

line 6788:
                ; continue into addition routine.
                                ; continue into addition routine.

line 6804:
    ld a,(de)       ; fetch OP2.exp
        ld      a, (de)         ; fetch OP2.exp

line 6805:
    and a           ; =0?
        and     a               ; =0?

line 6806:
    ret z           ; if yes, then OP1 is the result
        ret     z               ; if yes, then OP1 is the result

line 6808:
    ld c,a          ; save OP2.exp
        ld      c, a            ; save OP2.exp

line 6809:
    ld a,(hl)       ; fetch OP1.exp
        ld      a, (hl)         ; fetch OP1.exp

line 6810:
    and a           ; =0?
        and     a               ; =0?

line 6812:
    push de         ; save the original
        push    de              ; save the original

line 6813:
    push hl         ; pointers
        push    hl              ; pointers

line 6815:
    jr z,fw_OPcpy       ; if OP1=0, then OP2 is the result
        jr      z, fw_OPcpy     ; if OP1=0, then OP2 is the result

line 6816:
                ; return via 'copy_OP2'
                                ; return via 'copy_OP2'

line 6817:
    ld b,a          ; save OP1.exp
        ld      b, a            ; save OP1.exp

line 6818:
    sub c           ; OP1.exp-OP2.exp
        sub     c               ; OP1.exp-OP2.exp

line 6820:
    cp 33           ; test distance
        cp      33              ; test distance

line 6821:
    jr c,pos_dist       ; jump if it is less than 33 bit
        jr      c, pos_dist     ; jump if it is less than 33 bit

line 6823:
    cp -32          ; if it is more
        cp      -32             ; if it is more

line 6824:
    jp c,diff_33p       ; then return
        jp      c, diff_33p     ; then return

line 6826:
    cpl         ; the difference is negative
        cpl                     ; the difference is negative

line 6827:
    inc a           ; so negate it
        inc     a               ; so negate it

line 6828:
    ld b,c          ; change the greater exponent
        ld      b, c            ; change the greater exponent

line 6829:
    ex de,hl        ; de points the less number
        ex      de, hl          ; de points the less number

line 6831:
    push bc         ; save the greater exponent (B)
        push    bc              ; save the greater exponent (B)

line 6832:
    inc hl          ; n1
        inc     hl              ; n1

line 6833:
    ld c,(hl)       ; sgn
        ld      c, (hl)         ; sgn

line 6834:
    push hl         ; save pointer (man. of the greater num.)
        push    hl              ; save pointer (man. of the greater num.)

line 6835:
    ex de,hl        ; hl points the less exponent
        ex      de, hl          ; hl points the less exponent

line 6837:
    inc hl          ; m1
        inc     hl              ; m1

line 6838:
    ld b,(hl)       ; sgn
        ld      b, (hl)         ; sgn

line 6839:
    push bc         ; save MSBs
        push    bc              ; save MSBs

line 6841:
    inc hl          ; m2
        inc     hl              ; m2

line 6842:
    ld c,(hl)       ;
        ld      c, (hl)         ;

line 6843:
    inc hl          ; m3
        inc     hl              ; m3

line 6844:
    ld d,(hl)       ;
        ld      d, (hl)         ;

line 6845:
    inc hl          ; m4
        inc     hl              ; m4

line 6846:
    ld e,(hl)       ; the LSB
        ld      e, (hl)         ; the LSB

line 6848:
    set 7,b         ; the msb is always '1'
        set     7, b            ; the msb is always '1'

line 6850:
    and a           ; test distance (& clear CY)
        and     a               ; test distance (& clear CY)

line 6851:
    jr z,skp_shft       ; skip shifting if zero
        jr      z, skp_shft     ; skip shifting if zero

line 6853:
    srl b           ; 0 -> bbbbbbbb -> CY
        srl     b               ; 0 -> bbbbbbbb -> CY

line 6854:
    rr c            ; CY -> cccccccc -> CY
        rr      c               ; CY -> cccccccc -> CY

line 6855:
    rr d            ; CY -> dddddddd -> CY
        rr      d               ; CY -> dddddddd -> CY

line 6856:
    rr e            ; CY -> eeeeeeee -> CY
        rr      e               ; CY -> eeeeeeee -> CY

line 6857:
    dec a           ;
        dec     a               ;

line 6858:
    jr nz,add_shft      ;
        jr      nz, add_shft    ;

line 6860:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 6861:
    sbc a,a         ; depending on rounding bit
        sbc     a, a            ; depending on rounding bit

line 6862:
    ld b,a          ; B=$00 or B=$FF
        ld      b, a            ; B=$00 or B=$FF

line 6863:
    exx         ; ..    (main set)
        exx                     ; ..    (main set)

line 6865:
    pop hl          ; the MSBs contain the sign bits
        pop     hl              ; the MSBs contain the sign bits

line 6866:
    ld a,h          ; which select the next operation:
        ld      a, h            ; which select the next operation:

line 6867:
    xor l           ; if A7=0 then addition else subtraction
        xor     l               ; if A7=0 then addition else subtraction

line 6869:
    ld h,l          ; save sign bit (H7) and HL now
        ld      h, l            ; save sign bit (H7) and HL now

line 6870:
    ex (sp),hl      ; points the greater number's MSB
        ex      (sp), hl        ; points the greater number's MSB

line 6872:
    rla         ; if CY=0 then addition else subtraction
        rla                     ; if CY=0 then addition else subtraction

line 6873:
    call addorsub       ; execute operation
        call    addorsub        ; execute operation

line 6875:
    pop hl          ; the sign bit (h7)
        pop     hl              ; the sign bit (h7)

line 6876:
    ex (sp),hl      ; H = the greater exponent
        ex      (sp), hl        ; H = the greater exponent

line 6878:
    and a           ; test correction's value
        and     a               ; test correction's value

line 6884:
    jp m,add_nexp       ; jump if it is negative
        jp      m, add_nexp     ; jump if it is negative

line 6886:
    ld l,a          ; else decrease
        ld      l, a            ; else decrease

line 6887:
    ld a,h          ; the exponent
        ld      a, h            ; the exponent

line 6888:
    sub l           ; w. correction
        sub     l               ; w. correction

line 6889:
    jr z,z_result       ; skip if underflow (<=0)
        jr      z, z_result     ; skip if underflow (<=0)

line 6891:
    jr nc,set_Exp1      ; else store the return value
        jr      nc, set_Exp1    ; else store the return value

line 6895:
    pop hl          ; drop flags
        pop     hl              ; drop flags

line 6896:
    pop hl          ; restore the OP1 pointer
        pop     hl              ; restore the OP1 pointer

line 6897:
    xor a           ;
        xor     a               ;

line 6898:
    ld (hl),a       ; clear OP1.exp
        ld      (hl), a         ; clear OP1.exp

line 6900:
    ld c,a          ; clear the
        ld      c, a            ; clear the

line 6901:
    ld d,a          ; arithmetic
        ld      d, a            ; arithmetic

line 6902:
    ld e,a          ; buffer
        ld      e, a            ; buffer

line 6903:
    jr OP1_fill     ; and set OP1 as zero
        jr      OP1_fill        ; and set OP1 as zero

line 6907:
    pop hl          ; the sign bit (H7)
        pop     hl              ; the sign bit (H7)

line 6908:
    ex (sp),hl      ; points OP1
        ex      (sp), hl        ; points OP1

line 6909:
    ld (hl),a       ; set OP1.exp
        ld      (hl), a         ; set OP1.exp

line 6911:
    ld a,$80        ; mask of the sign bit (A7)
        ld      a, $80          ; mask of the sign bit (A7)

line 6912:
    xor b           ; toggle
        xor     b               ; toggle

line 6913:
    ld b,a          ; the sign bit (B7)
        ld      b, a            ; the sign bit (B7)

line 6915:
    pop af          ; the new sign bit (A7)
        pop     af              ; the new sign bit (A7)

line 6916:
    and $80         ; mask out the sign bit
        and     $80             ; mask out the sign bit

line 6917:
    xor b           ; apply changes
        xor     b               ; apply changes

line 6919:
    push hl         ;
        push    hl              ;

line 6920:
    inc hl          ; points OP1.man1
        inc     hl              ; points OP1.man1

line 6921:
    ld (hl),a       ;
        ld      (hl), a         ;

line 6922:
    inc hl          ; points OP1.man2
        inc     hl              ; points OP1.man2

line 6923:
    ld (hl),c       ;
        ld      (hl), c         ;

line 6924:
    inc hl          ; points OP1.man3
        inc     hl              ; points OP1.man3

line 6925:
    ld (hl),d       ;
        ld      (hl), d         ;

line 6926:
    inc hl          ; points OP1.man4
        inc     hl              ; points OP1.man4

line 6927:
    ld (hl),e       ;
        ld      (hl), e         ;

line 6929:
    pop hl          ; restore the
        pop     hl              ; restore the

line 6930:
    pop de          ; pointers
        pop     de              ; pointers

line 6931:
    ret         ; done
        ret                     ; done

line 6947:
    ld a,(hl)       ; fetch OP1.exp
        ld      a, (hl)         ; fetch OP1.exp

line 6948:
    and a           ; if it is zero,
        and     a               ; if it is zero,

line 6949:
    ret z           ; then the result is zero
        ret     z               ; then the result is zero

line 6951:
    ld b,a          ; store exp1
        ld      b, a            ; store exp1

line 6952:
    ld a,(de)       ; fetch OP2.exp
        ld      a, (de)         ; fetch OP2.exp

line 6953:
    and a           ; test zero
        and     a               ; test zero

line 6955:
    push de         ; save the original
        push    de              ; save the original

line 6956:
    push hl         ; pointers
        push    hl              ; pointers

line 6958:
    jr z,copy_OP2       ; OP2=0? -> return via 'copy_OP2'
        jr      z, copy_OP2     ; OP2=0? -> return via 'copy_OP2'

line 6960:
    ld c,a          ; store exp2
        ld      c, a            ; store exp2

line 6961:
    push bc         ; save exp1,exp2
        push    bc              ; save exp1,exp2

line 6963:
    call fetchOps       ; fetch both mantissas into Z80 registers
        call    fetchOps        ; fetch both mantissas into Z80 registers

line 6965:
    push af         ; man1.S * man2.S
        push    af              ; man1.S * man2.S

line 6966:
    push hl         ; save pointer to the next calculator literal
        push    hl              ; save pointer to the next calculator literal

line 6967:
    sbc hl,hl       ; H'L'H,L = 0
        sbc     hl, hl          ; H'L'H,L = 0

line 6969:
    ld a,b          ; transfer high mantissa byte of first number
        ld      a, b            ; transfer high mantissa byte of first number

line 6970:
    ld b,$20        ; register B can now be used to count 32 shifts.
        ld      b, $20          ; register B can now be used to count 32 shifts.

line 6974:
    rra         ; C > 76543210 > C
        rra                     ; C > 76543210 > C

line 6975:
    rr c            ; C > 76543210 > C
        rr      c               ; C > 76543210 > C

line 6976:
    exx         ; ..    (main set)
        exx                     ; ..    (main set)

line 6977:
    rr b            ; C > 76543210 > C
        rr      b               ; C > 76543210 > C

line 6978:
    rr c            ; C > 76543210 > C
        rr      c               ; C > 76543210 > C

line 6980:
    jr nc,skip_add      ; skip if no carry, else add in the multiplicand.
        jr      nc, skip_add    ; skip if no carry, else add in the multiplicand.

line 6982:
    add hl,de       ; add the lower word to result
        add     hl, de          ; add the lower word to result

line 6983:
    exx         ; switch to more significant bytes.
        exx                     ; switch to more significant bytes.

line 6984:
    adc hl,de       ; add high bytes of multiplicand and any carry.
        adc     hl, de          ; add high bytes of multiplicand and any carry.

line 6985:
    exx         ; switch back to main set
        exx                     ; switch back to main set

line 6987:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 6988:
    rr h            ; C > 76543210 > C
        rr      h               ; C > 76543210 > C

line 6989:
    rr l            ; C > 76543210 > C
        rr      l               ; C > 76543210 > C

line 6990:
    exx         ; ..    (main set)
        exx                     ; ..    (main set)

line 6991:
    rr h            ; C > 76543210 > C
        rr      h               ; C > 76543210 > C

line 6992:
    rr l            ; C > 76543210 > C
        rr      l               ; C > 76543210 > C

line 6993:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 6995:
    djnz mul_loop       ; loop back 32 times
        djnz    mul_loop        ; loop back 32 times

line 6997:
    ex (sp),hl      ; save upper word of the mantissa and
        ex      (sp), hl        ; save upper word of the mantissa and

line 6998:
                ; restore pointer to the next calculator literal
                                ; restore pointer to the next calculator literal

line 6999:
    exx         ; switch back to main set
        exx                     ; switch back to main set

line 7000:
    ex de,hl        ;
        ex      de, hl          ;

line 7001:
    pop bc          ; mantissa in B(MSB),C,D,E(LSB)
        pop     bc              ; mantissa in B(MSB),C,D,E(LSB)

line 7003:
    pop hl          ; man1.S * man2.S
        pop     hl              ; man1.S * man2.S

line 7004:
    ex (sp),hl      ; exp1,exp2
        ex      (sp), hl        ; exp1,exp2

line 7006:
    bit 7,b         ; if the mantissa's msb is '1',
        bit     7, b            ; if the mantissa's msb is '1',

line 7007:
    jr nz,man_isOK      ; then skip the shifting
        jr      nz, man_isOK    ; then skip the shifting

line 7009:
    rl e            ; else shift left the mantissa
        rl      e               ; else shift left the mantissa

line 7010:
    rl d            ;
        rl      d               ;

line 7011:
    rl c            ;
        rl      c               ;

line 7012:
    rl b            ;
        rl      b               ;

line 7013:
    rla         ; underflow bit to CY
        rla                     ; underflow bit to CY

line 7014:
    dec h           ; exponent correction
        dec     h               ; exponent correction

line 7016:
    ld a,0          ; set correction to zero
        ld      a, 0            ; set correction to zero

line 7017:
    call c,round32b     ; round if it is necessary
        call    c, round32b     ; round if it is necessary

line 7019:
    sub l           ; fetch exp2 with correction
        sub     l               ; fetch exp2 with correction

line 7020:
    add a,$80       ; remove the offset
        add     a, $80          ; remove the offset

line 7021:
    jr m_d_exit     ; go to subtract from exp1
        jr      m_d_exit        ; go to subtract from exp1

line 7027:
    xor h           ; set the sign bit
        xor     h               ; set the sign bit

line 7028:
    ld b,a          ; store the MSB of the mantissa
        ld      b, a            ; store the MSB of the mantissa

line 7029:
    ld a,c          ; store the counter
        ld      a, c            ; store the counter

line 7030:
    ld c,l          ; the 2nd byte of the mantissa
        ld      c, l            ; the 2nd byte of the mantissa

line 7031:
    ret
        ret

line 7039:
    rla         ; if difference is positive,
        rla                     ; if difference is positive,

line 7040:
    jr nc,ret_OP1       ; then OP1 is the result, else
        jr      nc, ret_OP1     ; then OP1 is the result, else

line 7042:
    ex de,hl        ; exchange the pointers
        ex      de, hl          ; exchange the pointers

line 7043:
    ld bc,5         ; 5 bytes to copy
        ld      bc, 5           ; 5 bytes to copy

line 7044:
    ldir            ; copy
        ldir                    ; copy

line 7045:
    jr ret_OP1      ; restore the pointers
        jr      ret_OP1         ; restore the pointers

line 7064:
    inc de          ; set OP2 pointer
        inc     de              ; set OP2 pointer

line 7065:
    ld a,(de)       ; fetch MSB of the man2
        ld      a, (de)         ; fetch MSB of the man2

line 7066:
    inc hl          ; set OP1 pointer
        inc     hl              ; set OP1 pointer

line 7067:
    ld b,(hl)       ; fetch MSB of the man1
        ld      b, (hl)         ; fetch MSB of the man1

line 7068:
    xor b           ; A7 = man1.S * man2.S (and CY=0!)
        xor     b               ; A7 = man1.S * man2.S (and CY=0!)

line 7070:
    inc hl          ; set OP1 pointer
        inc     hl              ; set OP1 pointer

line 7071:
    ld c,(hl)       ; fetch man1.2
        ld      c, (hl)         ; fetch man1.2

line 7072:
    push bc         ; save man1.1,man1.2
        push    bc              ; save man1.1,man1.2

line 7074:
    inc hl          ; set OP1 pointer
        inc     hl              ; set OP1 pointer

line 7075:
    ld b,(hl)       ; fetch man1.3
        ld      b, (hl)         ; fetch man1.3

line 7076:
    inc hl          ; fetch set OP1 pointer
        inc     hl              ; fetch set OP1 pointer

line 7077:
    ld c,(hl)       ; fetch man1.4
        ld      c, (hl)         ; fetch man1.4

line 7079:
    ex de,hl        ; HL points now OP2
        ex      de, hl          ; HL points now OP2

line 7081:
    ld d,(hl)       ; fetch man2.1
        ld      d, (hl)         ; fetch man2.1

line 7082:
    inc hl          ; set OP2 pointer
        inc     hl              ; set OP2 pointer

line 7083:
    ld e,(hl)       ; fetch man2.2
        ld      e, (hl)         ; fetch man2.2

line 7084:
    push de         ; save man2.1,man2.2
        push    de              ; save man2.1,man2.2

line 7086:
    inc hl          ; set OP2 pointer
        inc     hl              ; set OP2 pointer

line 7087:
    ld d,(hl)       ; fetch man2.3
        ld      d, (hl)         ; fetch man2.3

line 7088:
    inc hl          ; set OP2 pointer
        inc     hl              ; set OP2 pointer

line 7089:
    ld e,(hl)       ; fetch man2.4
        ld      e, (hl)         ; fetch man2.4

line 7091:
    sbc hl,hl       ; clear HL
        sbc     hl, hl          ; clear HL

line 7093:
    exx         ; switch to alternate set
        exx                     ; switch to alternate set

line 7094:
    pop de          ; man2.1,man2.2
        pop     de              ; man2.1,man2.2

line 7095:
    set 7,d         ; the msb is always '1'
        set     7, d            ; the msb is always '1'

line 7096:
    pop bc          ; man1.1,man1.2
        pop     bc              ; man1.1,man1.2

line 7097:
    set 7,b         ; the msb is always '1'
        set     7, b            ; the msb is always '1'

line 7099:
    ret         ;
        ret                     ;

line 7108:
    inc hl          ; set pointer
        inc     hl              ; set pointer

line 7109:
    inc hl          ;
        inc     hl              ;

line 7110:
    inc hl          ; HL now points the LSB of the mantissa
        inc     hl              ; HL now points the LSB of the mantissa

line 7111:
    ld a,(hl)       ; fetch the LSB of the mantissa
        ld      a, (hl)         ; fetch the LSB of the mantissa

line 7113:
    jp c,sub_OP2        ; CY=1? --> subtraction
        jp      c, sub_OP2      ; CY=1? --> subtraction

line 7115:
    add a,e         ; the real addition
        add     a, e            ; the real addition

line 7116:
    ld e,a          ; 4th byte of the mantissa
        ld      e, a            ; 4th byte of the mantissa

line 7117:
    dec hl          ;
        dec     hl              ;

line 7118:
    ld a,(hl)       ;
        ld      a, (hl)         ;

line 7119:
    adc a,d         ;
        adc     a, d            ;

line 7120:
    ld d,a          ; 3rd byte of the mantissa
        ld      d, a            ; 3rd byte of the mantissa

line 7121:
    dec hl          ;
        dec     hl              ;

line 7122:
    ld a,(hl)       ;
        ld      a, (hl)         ;

line 7123:
    adc a,c         ;
        adc     a, c            ;

line 7124:
    ld c,a          ; 2nd byte of the mantissa
        ld      c, a            ; 2nd byte of the mantissa

line 7125:
    dec hl          ;
        dec     hl              ;

line 7126:
    ld a,(hl)       ;
        ld      a, (hl)         ;

line 7127:
    set 7,a         ; the msb is always '1'
        set     7, a            ; the msb is always '1'

line 7128:
    adc a,b         ;
        adc     a, b            ;

line 7132:
    ld b,a          ; B(MSB),C,D,E(LSB): the result's mantissa
        ld      b, a            ; B(MSB),C,D,E(LSB): the result's mantissa

line 7134:
    sbc a,a         ; if CY=1 -> A=-1 ($FF)
        sbc     a, a            ; if CY=1 -> A=-1 ($FF)

line 7135:
    jr nc,roundbit      ; if CY=0 -> A= 0   - the correction -
        jr      nc, roundbit    ; if CY=0 -> A= 0   - the correction -

line 7137:
    rr b            ; CY -> bbbbbbbb -> CY
        rr      b               ; CY -> bbbbbbbb -> CY

line 7138:
    rr c            ; CY -> cccccccc -> CY
        rr      c               ; CY -> cccccccc -> CY

line 7139:
    rr d            ; CY -> dddddddd -> CY
        rr      d               ; CY -> dddddddd -> CY

line 7140:
    rr e            ; CY -> eeeeeeee -> CY
        rr      e               ; CY -> eeeeeeee -> CY

line 7142:
    ret nc          ;
        ret     nc              ;

line 7146:
    inc e           ; set LS byte of the mantissa
        inc     e               ; set LS byte of the mantissa

line 7147:
    ret nz          ; return if there is no overflow
        ret     nz              ; return if there is no overflow

line 7149:
    inc d           ; set 3rd byte of the mantissa
        inc     d               ; set 3rd byte of the mantissa

line 7150:
    ret nz          ; return if there is no overflow
        ret     nz              ; return if there is no overflow

line 7152:
    inc c           ; set 2nd byte of the mantissa
        inc     c               ; set 2nd byte of the mantissa

line 7153:
    ret nz          ; return if there is no overflow
        ret     nz              ; return if there is no overflow

line 7155:
    inc b           ; set MS byte of the mantissa
        inc     b               ; set MS byte of the mantissa

line 7156:
    ret nz          ; return if there is no overflow
        ret     nz              ; return if there is no overflow

line 7158:
    ld b,$80        ; else set MSB and
        ld      b, $80          ; else set MSB and

line 7159:
    dec a           ; adjust the correction
        dec     a               ; adjust the correction

line 7160:
    ret         ;
        ret                     ;

line 7164:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 7165:
    rl b            ; restore the rounding bit (B'7)
        rl      b               ; restore the rounding bit (B'7)

line 7166:
    exx         ; ..    (main set)
        exx                     ; ..    (main set)

line 7167:
    jr norm_end     ; and round if it is necessary
        jr      norm_end        ; and round if it is necessary

line 7171:
    neg         ; make it positive
        neg                     ; make it positive

line 7173:
    add a,h         ; add the 2 exponents
        add     a, h            ; add the 2 exponents

line 7174:
    jp nc,set_Exp1      ; store the result if not overflow
        jp      nc, set_Exp1    ; store the result if not overflow

line 7181:
    rst 08h         ; Error Report:
        rst     08h             ; Error Report:

line 7182:
    .db $05         ; Arithmetic overflow.
        .db $05                 ; Arithmetic overflow.

line 7198:
    ld a,(de)       ; check for division by zero
        ld      a, (de)         ; check for division by zero

line 7199:
    and a           ; if exp2=0,
        and     a               ; if exp2=0,

line 7200:
    jr z,error_6        ; then -> Arithmetic overflow
        jr      z, error_6      ; then -> Arithmetic overflow

line 7202:
    ld c,a          ; store exp2
        ld      c, a            ; store exp2

line 7203:
    ld a,(hl)       ; fetch exp1
        ld      a, (hl)         ; fetch exp1

line 7204:
    and a           ; if it is zero,
        and     a               ; if it is zero,

line 7205:
    ret z           ; then the result also is zero
        ret     z               ; then the result also is zero

line 7207:
    push de         ; save the original
        push    de              ; save the original

line 7208:
    push hl         ; pointers
        push    hl              ; pointers

line 7210:
    ld b,a          ; store exp1
        ld      b, a            ; store exp1

line 7211:
    push bc         ; save exp1,exp2
        push    bc              ; save exp1,exp2

line 7213:
    call fetchOps       ; fetch both mantissas into Z80 registers
        call    fetchOps        ; fetch both mantissas into Z80 registers

line 7215:
    push af         ; man1.S * man2.S
        push    af              ; man1.S * man2.S

line 7216:
    push hl         ; save pointer to the next calculator literal
        push    hl              ; save pointer to the next calculator literal

line 7218:
    ld h,b          ;
        ld      h, b            ;

line 7219:
    ld l,c          ; H'L' = upper 2 bytes of the dividend
        ld      l, c            ; H'L' = upper 2 bytes of the dividend

line 7221:
    xor a           ; clear MSB of the result
        xor     a               ; clear MSB of the result

line 7222:
    ld b,a          ; clear lower 2 bytes of the result
        ld      b, a            ; clear lower 2 bytes of the result

line 7223:
    ld c,a          ;
        ld      c, a            ;

line 7225:
    exx         ; switch back to main set
        exx                     ; switch back to main set

line 7226:
    ld h,b          ;
        ld      h, b            ;

line 7227:
    ld l,c          ; H,L = lower 2 bytes of the dividend
        ld      l, c            ; H,L = lower 2 bytes of the dividend

line 7228:
    ld bc,$DF00     ; B: a counter (-33), C: 2nd byte of the result
        ld      bc, $DF00       ; B: a counter (-33), C: 2nd byte of the result

line 7232:
    sbc hl,de       ; subtract divisor part
        sbc     hl, de          ; subtract divisor part

line 7233:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 7234:
    sbc hl,de       ;
        sbc     hl, de          ;

line 7235:
    jr nc,shft_inv      ; forward if there is no overflow
        jr      nc, shft_inv    ; forward if there is no overflow

line 7237:
    exx         ; ..    (main set)
        exx                     ; ..    (main set)

line 7238:
    add hl,de       ; else restore
        add     hl, de          ; else restore

line 7239:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 7240:
    adc hl,de       ;
        adc     hl, de          ;

line 7242:
    ccf         ; complement carry flag
        ccf                     ; complement carry flag

line 7244:
    rl c            ; multiply partial quotient by two
        rl      c               ; multiply partial quotient by two

line 7245:
    rl b            ; setting result bit from carry
        rl      b               ; setting result bit from carry

line 7246:
    exx         ; ..    (main set)
        exx                     ; ..    (main set)

line 7247:
    rl c            ;
        rl      c               ;

line 7248:
    rla         ;
        rla                     ;

line 7249:
    inc b           ; increment the counter
        inc     b               ; increment the counter

line 7250:
    jr c,endofdiv       ; exit, if the 33th bit is done
        jr      c, endofdiv     ; exit, if the 33th bit is done

line 7252:
    add hl,hl       ;
        add     hl, hl          ;

line 7253:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 7254:
    adc hl,hl       ;
        adc     hl, hl          ;

line 7255:
    exx         ; ..    (main set)
        exx                     ; ..    (main set)

line 7256:
    jr nc,div_loop      ;
        jr      nc, div_loop    ;

line 7258:
    and a           ; SUB-ONLY
        and     a               ; SUB-ONLY

line 7259:
    sbc hl,de       ;
        sbc     hl, de          ;

line 7260:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 7261:
    sbc hl,de       ;
        sbc     hl, de          ;

line 7263:
    scf         ; set CY to shift '1' into
        scf                     ; set CY to shift '1' into

line 7264:
    jr shft_bin     ; the partial quotient
        jr      shft_bin        ; the partial quotient

line 7266:
    exx         ; ..    (alternate set)
        exx                     ; ..    (alternate set)

line 7267:
    pop hl          ; pointer to the next calculator literal
        pop     hl              ; pointer to the next calculator literal

line 7268:
    push bc         ; the lower 2 bytes of the mantissa
        push    bc              ; the lower 2 bytes of the mantissa

line 7269:
    exx         ; ..    (main set)
        exx                     ; ..    (main set)

line 7270:
    pop de          ; D,E = lower 2 bytes of the mantissa
        pop     de              ; D,E = lower 2 bytes of the mantissa

line 7272:
    pop hl          ; man1.S * man2.S
        pop     hl              ; man1.S * man2.S

line 7273:
    ex (sp),hl      ; exp1,exp2
        ex      (sp), hl        ; exp1,exp2

line 7274:
    djnz divbit33       ; skip if there were 33 subtractions
        djnz    divbit33        ; skip if there were 33 subtractions

line 7276:
    inc l           ; else set correction
        inc     l               ; else set correction

line 7278:
    call norm_res       ; shift right and round (if it is necessary)
        call    norm_res        ; shift right and round (if it is necessary)

line 7280:
    cpl         ; set correction: -1 ->  0; -2 -> 1
        cpl                     ; set correction: -1 ->  0; -2 -> 1

line 7281:
    dec a           ;          0 -> -1;  1 -> 0
        dec     a               ;          0 -> -1;  1 -> 0

line 7282:
    add a,l         ; fetch exp2 and add correction
        add     a, l            ; fetch exp2 and add correction

line 7283:
    sub $80         ; remove the offset
        sub     $80             ; remove the offset

line 7284:
    jp m_d_exit     ; jump to subtract exponents
        jp      m_d_exit        ; jump to subtract exponents

line 7299:
    CALL FIND_INT       ; routine FIND-INT to fetch the
        call    FIND_INT        ; routine FIND-INT to fetch the

line 7300:
                ; supplied address into BC.
                                ; supplied address into BC.

line 7301:
    LD HL,STACK_BC      ; address: STACK-BC is
        ld      hl, STACK_BC    ; address: STACK-BC is

line 7302:
    PUSH HL         ; pushed onto the machine stack.
        push    hl              ; pushed onto the machine stack.

line 7303:
    PUSH BC         ; then the address of the machine code
        push    bc              ; then the address of the machine code

line 7304:
                ; routine.
                                ; routine.

line 7305:
    RET         ; make an indirect jump to the user's routine
        ret                     ; make an indirect jump to the user's routine

line 7306:
                ; and, hopefully, to STACK-BC also.
                                ; and, hopefully, to STACK-BC also.

line 7312:
truncate            ; (L18E4)
truncate                        ; (L18E4)

line 7313:
    LD A,(HL)       ; fetch exponent
        ld      a, (hl)         ; fetch exponent

line 7315:
    add a,$7F       ; if abs(number)<1       (eponent<$81)
        add     a, $7F          ; if abs(number)<1       (eponent<$81)

line 7316:
    jp nc,FP_0_1        ; then return with zero         (CY=0)
        jp      nc, FP_0_1      ; then return with zero         (CY=0)

line 7318:
    cp $1F          ; return if all 32 bits of the mantissa
        cp      $1F             ; return if all 32 bits of the mantissa

line 7319:
    ret nc          ; relate to the integer part.    (eponent>$9f)
        ret     nc              ; relate to the integer part.    (eponent>$9f)

line 7321:
    cpl         ; else form number of rightmost bits
        cpl                     ; else form number of rightmost bits

line 7322:
    add a,$20       ; to be blanked.
        add     a, $20          ; to be blanked.

line 7332:
    PUSH DE         ; save pointer to STKEND
        push    de              ; save pointer to STKEND

line 7333:
    EX DE,HL        ; HL points at STKEND
        ex      de, hl          ; HL points at STKEND

line 7335:
    dec hl          ;
        dec     hl              ;

line 7336:
    sub $08         ;
        sub     $08             ;

line 7337:
    jr c,clr_bits       ;
        jr      c, clr_bits     ;

line 7339:
    ld (hl),0       ;
        ld      (hl), 0         ;

line 7340:
    jr clr_byte     ;
        jr      clr_byte        ;

line 7345:
    add a,$08       ; the remaining bits
        add     a, $08          ; the remaining bits

line 7346:
    jr z,ix_end     ; forward if none to IX-END
        jr      z, ix_end       ; forward if none to IX-END

line 7348:
    LD B,A          ; transfer bit count to B counter.
        ld      b, a            ; transfer bit count to B counter.

line 7350:
    sbc a,a         ; form a mask 11111111
        sbc     a, a            ; form a mask 11111111

line 7354:
    SLA A           ; 1 <- 76543210 <- o    slide mask leftwards.
        sla     a               ; 1 <- 76543210 <- o    slide mask leftwards.

line 7355:
    DJNZ lessMask       ; loop back for bit count to LESS-MASK
        djnz    lessMask        ; loop back for bit count to LESS-MASK

line 7357:
    AND (HL)        ; lose the unwanted rightmost bits
        and     (hl)            ; lose the unwanted rightmost bits

line 7358:
    LD (HL),A       ; and place in mantissa byte.
        ld      (hl), a         ; and place in mantissa byte.

line 7362:
    EX DE,HL        ; restore result pointer from DE.
        ex      de, hl          ; restore result pointer from DE.

line 7363:
    POP DE          ; restore STKEND from stack.
        pop     de              ; restore STKEND from stack.

line 7364:
    RET             ; return.
        ret                     ; return.

line 7375:
    DEFB $00    ; the value zero.
        defb    $00             ; the value zero.

line 7376:
    DEFB $00    ;
        defb    $00             ;

line 7377:
    DEFB $00    ;
        defb    $00             ;

line 7378:
    DEFB $00    ;
        defb    $00             ;

line 7379:
    DEFB $00    ;
        defb    $00             ;

line 7381:
    DEFB $81    ; the floating point value 1.
        defb    $81             ; the floating point value 1.

line 7382:
    DEFB $00    ;
        defb    $00             ;

line 7383:
    DEFB $00    ;
        defb    $00             ;

line 7384:
    DEFB $00    ;
        defb    $00             ;

line 7385:
    DEFB $00    ;
        defb    $00             ;

line 7387:
    DEFB $80    ; the floating point value 1/2.
        defb    $80             ; the floating point value 1/2.

line 7388:
    DEFB $00    ;
        defb    $00             ;

line 7389:
    DEFB $00    ;
        defb    $00             ;

line 7390:
    DEFB $00    ;
        defb    $00             ;

line 7391:
    DEFB $00    ;
        defb    $00             ;

line 7393:
    DEFB $81    ; the floating point value pi/2.
        defb    $81             ; the floating point value pi/2.

line 7394:
    DEFB $49    ;
        defb    $49             ;

line 7395:
    DEFB $0F    ;
        defb    $0F             ;

line 7396:
    DEFB $DA    ;
        defb    $DA             ;

line 7397:
    DEFB $A2    ;
        defb    $A2             ;

line 7399:
    DEFB $84    ; the floating point value ten.
        defb    $84             ; the floating point value ten.

line 7400:
    DEFB $20    ;
        defb    $20             ;

line 7401:
    DEFB $00    ;
        defb    $00             ;

line 7402:
    DEFB $00    ;
        defb    $00             ;

line 7403:
    DEFB $00    ;
        defb    $00             ;

line 7413:
    DEFW  jmp_true      ; $00 - jump-true
        defw    jmp_true        ; $00 - jump-true

line 7414:
    DEFW  exchange      ; $01 - exchange
        defw    exchange        ; $01 - exchange

line 7415:
    DEFW  delete        ; $02 - delete
        defw    delete          ; $02 - delete

line 7419:
    DEFW  subtract      ; $03 - subtract
        defw    subtract        ; $03 - subtract

line 7420:
    DEFW  multiply      ; $04 - multiply
        defw    multiply        ; $04 - multiply

line 7421:
    DEFW  division      ; $05 - division
        defw    division        ; $05 - division

line 7422:
    DEFW  to_power      ; $06 - to-power
        defw    to_power        ; $06 - to-power

line 7423:
    DEFW  op_or     ; $07 - or
        defw    op_or           ; $07 - or

line 7425:
    DEFW  hnd_AND       ; $08 - no-&-no
        defw    hnd_AND         ; $08 - no-&-no

line 7426:
    DEFW  comp_not      ; $09 - no-l-eql
        defw    comp_not        ; $09 - no-l-eql

line 7427:
    DEFW  comp_not      ; $0A - no-gr-eql
        defw    comp_not        ; $0A - no-gr-eql

line 7428:
    DEFW  comp_not      ; $0B - nos-neql
        defw    comp_not        ; $0B - nos-neql

line 7429:
    DEFW  comp_tru      ; $0C - no-grtr
        defw    comp_tru        ; $0C - no-grtr

line 7430:
    DEFW  comp_tru      ; $0D - no-less
        defw    comp_tru        ; $0D - no-less

line 7431:
    DEFW  comp_tru      ; $0E - nos-eql
        defw    comp_tru        ; $0E - nos-eql

line 7432:
    DEFW  addition      ; $0F - addition
        defw    addition        ; $0F - addition

line 7434:
    DEFW  hnd_AND       ; $10 - str-&-no
        defw    hnd_AND         ; $10 - str-&-no

line 7435:
    DEFW  comp_not      ; $11 - str-l-eql
        defw    comp_not        ; $11 - str-l-eql

line 7436:
    DEFW  comp_not      ; $12 - str-gr-eql
        defw    comp_not        ; $12 - str-gr-eql

line 7437:
    DEFW  comp_not      ; $13 - strs-neql
        defw    comp_not        ; $13 - strs-neql

line 7438:
    DEFW  comp_tru      ; $14 - str-grtr
        defw    comp_tru        ; $14 - str-grtr

line 7439:
    DEFW  comp_tru      ; $15 - str-less
        defw    comp_tru        ; $15 - str-less

line 7440:
    DEFW  comp_tru      ; $16 - strs-eql
        defw    comp_tru        ; $16 - strs-eql

line 7441:
    DEFW  strs_add      ; $17 - strs-add
        defw    strs_add        ; $17 - strs-add

line 7445:
    DEFW  negate        ; $18 - neg
        defw    negate          ; $18 - neg

line 7447:
    DEFW  fn_code       ; $19 - code
        defw    fn_code         ; $19 - code

line 7448:
    DEFW  fn_val        ; $1A - val
        defw    fn_val          ; $1A - val

line 7449:
    DEFW  fn_len        ; $1B - len
        defw    fn_len          ; $1B - len

line 7450:
    DEFW  fn_sin        ; $1C - sin
        defw    fn_sin          ; $1C - sin

line 7451:
    DEFW  fn_cos        ; $1D - cos
        defw    fn_cos          ; $1D - cos

line 7452:
    DEFW  fn_tan        ; $1E - tan
        defw    fn_tan          ; $1E - tan

line 7453:
    DEFW  fn_asn        ; $1F - asn
        defw    fn_asn          ; $1F - asn

line 7454:
    DEFW  fn_acs        ; $20 - acs
        defw    fn_acs          ; $20 - acs

line 7455:
    DEFW  fn_atn        ; $21 - atn
        defw    fn_atn          ; $21 - atn

line 7456:
    DEFW  fn_ln     ; $22 - ln
        defw    fn_ln           ; $22 - ln

line 7457:
    DEFW  fn_exp        ; $23 - exp
        defw    fn_exp          ; $23 - exp

line 7458:
    DEFW  fn_int        ; $24 - int
        defw    fn_int          ; $24 - int

line 7459:
    DEFW  fn_sqr        ; $25 - sqr
        defw    fn_sqr          ; $25 - sqr

line 7460:
    DEFW  fn_sgn        ; $26 - sgn
        defw    fn_sgn          ; $26 - sgn

line 7461:
    DEFW  fn_abs        ; $27 - abs
        defw    fn_abs          ; $27 - abs

line 7462:
    DEFW  fn_peek       ; $28 - peek
        defw    fn_peek         ; $28 - peek

line 7463:
    DEFW  fn_usr        ; $29 - usr-no
        defw    fn_usr          ; $29 - usr-no

line 7464:
    DEFW  fn_strS       ; $2A - str$
        defw    fn_strS         ; $2A - str$

line 7465:
    DEFW  fn_chrS       ; $2B - chrs
        defw    fn_chrS         ; $2B - chrs

line 7466:
    DEFW  fn_not        ; $2C - not
        defw    fn_not          ; $2C - not

line 7470:
    DEFW  COPY_FP       ; $2D - duplicate
        defw    COPY_FP         ; $2D - duplicate

line 7471:
    DEFW  n_mod_m       ; $2E - n-mod-m
        defw    n_mod_m         ; $2E - n-mod-m

line 7473:
    DEFW  JUMP      ; $2F - jump
        defw    JUMP            ; $2F - jump

line 7474:
    DEFW  stk_data      ; $30 - stk-data
        defw    stk_data        ; $30 - stk-data

line 7476:
    DEFW  dec_jr_nz     ; $31 - dec-jr-nz
        defw    dec_jr_nz       ; $31 - dec-jr-nz

line 7477:
    DEFW  less_0        ; $32 - less-0
        defw    less_0          ; $32 - less-0

line 7478:
    DEFW  greater0      ; $33 - greater-0
        defw    greater0        ; $33 - greater-0

line 7479:
    DEFW  end_calc      ; $34 - end-calc
        defw    end_calc        ; $34 - end-calc

line 7480:
    DEFW  get_argt      ; $35 - get-argt
        defw    get_argt        ; $35 - get-argt

line 7481:
    DEFW  truncate      ; $36 - truncate
        defw    truncate        ; $36 - truncate

line 7482:
    DEFW  fp_calc_2     ; $37 - fp-calc-2
        defw    fp_calc_2       ; $37 - fp-calc-2

line 7483:
    DEFW  e_to_fp       ; $38 - e-to-fp
        defw    e_to_fp         ; $38 - e-to-fp

line 7487:
    .dw sub_one     ; $39 macro sub-one (part of 'INT')
        .dw sub_one             ; $39 macro sub-one (part of 'INT')

line 7488:
    .dw mul_by_2        ; $3A macro mul-by-2
        .dw mul_by_2            ; $3A macro mul-by-2

line 7489:
    .dw mul_by10        ; $3B macro mul-by-10
        .dw mul_by10            ; $3B macro mul-by-10

line 7490:
    .dw stk_squa        ; $3C macro stk-square
        .dw stk_squa            ; $3C macro stk-square

line 7497:
    DEFW  seriesg_x     ; series-xx    $80 - $9F.
        defw    seriesg_x       ; series-xx    $80 - $9F.

line 7498:
    DEFW  stk_con_x     ; stk-const-xx $A0 - $BF.
        defw    stk_con_x       ; stk-const-xx $A0 - $BF.

line 7499:
    DEFW  sto_mem_x     ; st-mem-xx    $C0 - $DF.
        defw    sto_mem_x       ; st-mem-xx    $C0 - $DF.

line 7500:
    DEFW  get_mem_x     ; get-mem-xx   $E0 - $FF.
        defw    get_mem_x       ; get-mem-xx   $E0 - $FF.

line 7510:
    CALL STK_PNTRS      ; routine STK-PNTRS is called to set up the
        call    STK_PNTRS       ; routine STK-PNTRS is called to set up the

line 7511:
                ; calculator stack pointers for a default
                                ; calculator stack pointers for a default

line 7512:
                ; unary operation. HL = last value on stack.
                                ; unary operation. HL = last value on stack.

line 7513:
                ; DE = STKEND first location after stack.
                                ; DE = STKEND first location after stack.

line 7515:
    LD A,B          ; fetch the Z80 B register to A
        ld      a, b            ; fetch the Z80 B register to A

line 7520:
    LD ($401E),A        ; and store value in system variable BREG.
        ld      ($401E), a      ; and store value in system variable BREG.

line 7521:
                ; this will be the counter for dec-jr-nz
                                ; this will be the counter for dec-jr-nz

line 7522:
                ; or if used from fp-calc2 the calculator
                                ; or if used from fp-calc2 the calculator

line 7523:
                ; instruction.
                                ; instruction.

line 7528:
    EXX         ; switch sets
        exx                     ; switch sets

line 7529:
    EX (SP),HL      ; and store the address of next instruction,
        ex      (sp), hl        ; and store the address of next instruction,

line 7530:
                ; the return address, in H'L'.
                                ; the return address, in H'L'.

line 7531:
                ; If this is a recursive call then the H'L'
                                ; If this is a recursive call then the H'L'

line 7532:
                ; of the previous invocation goes on stack.
                                ; of the previous invocation goes on stack.

line 7533:
                ; c.f. end-calc.
                                ; c.f. end-calc.

line 7534:
    EXX         ; switch back to main set.
        exx                     ; switch back to main set.

line 7539:
    LD ($401C),DE       ; save end of stack in system variable STKEND
        ld      ($401C), de     ; save end of stack in system variable STKEND

line 7540:
    EXX         ; switch to alt
        exx                     ; switch to alt

line 7541:
    LD A,(HL)       ; get next literal
        ld      a, (hl)         ; get next literal

line 7542:
    INC HL          ; increase pointer'
        inc     hl              ; increase pointer'

line 7547:
    PUSH  HL        ; save pointer on stack   *
        push    hl              ; save pointer on stack   *

line 7548:
    AND A           ; now test the literal
        and     a               ; now test the literal

line 7549:
    JP P,FIRST_7F       ; forward to FIRST-7F if in range $00 - $7F
        jp      p, FIRST_7F     ; forward to FIRST-7F if in range $00 - $7F

line 7550:
                ; anything with bit 7 set will be one of
                                ; anything with bit 7 set will be one of

line 7551:
                ; 128 compound literals.
                                ; 128 compound literals.

line 7560:
    LD D,A          ; save literal in D
        ld      d, a            ; save literal in D

line 7561:
    AND $60         ; and with 01100000 to isolate subgroup
        and     $60             ; and with 01100000 to isolate subgroup

line 7562:
    RRCA            ; rotate bits
        rrca                    ; rotate bits

line 7563:
    RRCA            ; 4 places to right
        rrca                    ; 4 places to right

line 7564:
    RRCA            ; not five as we need offset * 2
        rrca                    ; not five as we need offset * 2

line 7565:
    RRCA            ; 00000xx0
        rrca                    ; 00000xx0

line 7566:
    ADD A,tbl_offs      ; correct offset.
        add     a, tbl_offs     ; correct offset.

line 7567:
    LD L,A          ; store in L for later indexing.
        ld      l, a            ; store in L for later indexing.

line 7568:
    LD A,D          ; bring back compound literal
        ld      a, d            ; bring back compound literal

line 7569:
    AND $1F         ; use mask to isolate parameter bits
        and     $1F             ; use mask to isolate parameter bits

line 7570:
    JR ENT_TABLE        ; forward to ENT-TABLE
        jr      ENT_TABLE       ; forward to ENT-TABLE

line 7576:
    CP $18          ; compare with first unary operations.
        cp      $18             ; compare with first unary operations.

line 7577:
    JR NC,DOUBLE_A      ; to DOUBLE-A with unary operations
        jr      nc, DOUBLE_A    ; to DOUBLE-A with unary operations

line 7581:
    EXX         ;
        exx                     ;

line 7583:
    ex de,hl        ; transfer HL, the last value, to DE.
        ex      de, hl          ; transfer HL, the last value, to DE.

line 7584:
    ld hl,$FFFB     ; the value -5
        ld      hl, $FFFB       ; the value -5

line 7585:
    add hl,de       ; subtract 5 making HL point to second
        add     hl, de          ; subtract 5 making HL point to second

line 7586:
                ; value.
                                ; value.

line 7587:
    EXX         ;
        exx                     ;

line 7589:
    RLCA            ; double the literal
        rlca                    ; double the literal

line 7590:
    LD L,A          ; and store in L for indexing
        ld      l, a            ; and store in L for indexing

line 7592:
    LD DE,tbl_addrs     ; Address: tbl-addrs
        ld      de, tbl_addrs   ; Address: tbl-addrs

line 7593:
    LD H,$00        ; prepare to index
        ld      h, $00          ; prepare to index

line 7594:
    ADD HL,DE       ; add to get address of routine
        add     hl, de          ; add to get address of routine

line 7595:
    LD E,(HL)       ; low byte to E
        ld      e, (hl)         ; low byte to E

line 7596:
    INC HL          ;
        inc     hl              ;

line 7597:
    LD D,(HL)       ; high byte to D
        ld      d, (hl)         ; high byte to D

line 7599:
    LD HL,RE_ENTRY      ; Address: RE-ENTRY
        ld      hl, RE_ENTRY    ; Address: RE-ENTRY

line 7600:
    EX (SP),HL      ; goes on machine stack
        ex      (sp), hl        ; goes on machine stack

line 7601:
                ; address of next literal goes to HL. *
                                ; address of next literal goes to HL. *

line 7603:
    PUSH DE         ; now the address of routine is stacked.
        push    de              ; now the address of routine is stacked.

line 7604:
    EXX         ; back to main set
        exx                     ; back to main set

line 7605:
                ; avoid using IY register.
                                ; avoid using IY register.

line 7606:
    LD BC,($401D)       ; STKEND_hi
        ld      bc, ($401D)     ; STKEND_hi

line 7607:
                ; nothing much goes to C but BREG to B
                                ; nothing much goes to C but BREG to B

line 7608:
                ; and continue into next ret instruction
                                ; and continue into next ret instruction

line 7609:
                ; which has a dual identity
                                ; which has a dual identity

line 7622:
delete  RET         ; return - indirect jump if from above.
delete  ret                     ; return - indirect jump if from above.

line 7633:
    PUSH DE         ; save
        push    de              ; save

line 7634:
    PUSH HL         ; registers
        push    hl              ; registers

line 7635:
    LD BC,$0005     ; an overhead of five bytes
        ld      bc, $0005       ; an overhead of five bytes

line 7636:
    CALL TEST_ROOM      ; routine TEST-ROOM tests free RAM raising
        call    TEST_ROOM       ; routine TEST-ROOM tests free RAM raising

line 7637:
                ; an error if not.
                                ; an error if not.

line 7638:
    POP HL          ; else restore
        pop     hl              ; else restore

line 7639:
    POP DE          ; registers.
        pop     de              ; registers.

line 7640:
    RET         ; return with BC set at 5.
        ret                     ; return with BC set at 5.

line 7653:
    CALL TEST_5_SP      ; routine TEST-5-SP test free memory
        call    TEST_5_SP       ; routine TEST-5-SP test free memory

line 7654:
                ; and sets BC to 5.
                                ; and sets BC to 5.

line 7655:
    LDIR            ; copy the five bytes.
        ldir                    ; copy the five bytes.

line 7656:
    RET         ; return with DE addressing new STKEND
        ret                     ; return with DE addressing new STKEND

line 7657:
                ; and HL addressing new last value.
                                ; and HL addressing new last value.

line 7669:
    LD H,D          ; transfer STKEND
        ld      h, d            ; transfer STKEND

line 7670:
    LD L,E          ; to HL for result.
        ld      l, e            ; to HL for result.

line 7672:
    CALL TEST_5_SP      ; routine TEST-5-SP tests that room exists
        call    TEST_5_SP       ; routine TEST-5-SP tests that room exists

line 7673:
                ; and sets BC to $05.
                                ; and sets BC to $05.

line 7674:
    EXX         ; switch to alternate set
        exx                     ; switch to alternate set

line 7675:
    PUSH HL         ; save the pointer to next literal on stack
        push    hl              ; save the pointer to next literal on stack

line 7676:
    EXX         ; switch back to main set
        exx                     ; switch back to main set

line 7678:
    EX (SP),HL      ; pointer to HL, destination to stack.
        ex      (sp), hl        ; pointer to HL, destination to stack.

line 7680:
    LD A,(HL)       ; fetch the byte following 'stk-data'
        ld      a, (hl)         ; fetch the byte following 'stk-data'

line 7681:
    AND $C0         ; isolate bits 7 and 6
        and     $C0             ; isolate bits 7 and 6

line 7682:
    RLCA            ; rotate
        rlca                    ; rotate

line 7683:
    RLCA            ; to bits 1 and 0  range $00 - $03.
        rlca                    ; to bits 1 and 0  range $00 - $03.

line 7684:
    LD C,A          ; transfer to C
        ld      c, a            ; transfer to C

line 7685:
    INC C           ; and increment to give number of bytes
        inc     c               ; and increment to give number of bytes

line 7686:
                ; to read. $01 - $04
                                ; to read. $01 - $04

line 7687:
    LD A,(HL)       ; reload the first byte
        ld      a, (hl)         ; reload the first byte

line 7688:
    AND $3F         ; mask off to give possible exponent.
        and     $3F             ; mask off to give possible exponent.

line 7689:
    JR NZ,FORM_EXP      ; forward to FORM-EXP if it was possible to
        jr      nz, FORM_EXP    ; forward to FORM-EXP if it was possible to

line 7690:
                ; include the exponent.
                                ; include the exponent.

line 7694:
    INC HL          ; address next byte and
        inc     hl              ; address next byte and

line 7695:
    LD A,(HL)       ; pick up the exponent ( - $50).
        ld      a, (hl)         ; pick up the exponent ( - $50).

line 7697:
    ADD A,$50       ; now add $50 to form actual exponent
        add     a, $50          ; now add $50 to form actual exponent

line 7698:
    LD (DE),A       ; and load into first destination byte.
        ld      (de), a         ; and load into first destination byte.

line 7699:
    LD A,$05        ; load accumulator with $05 and
        ld      a, $05          ; load accumulator with $05 and

line 7700:
    SUB C           ; subtract C to give count of trailing
        sub     c               ; subtract C to give count of trailing

line 7701:
                ; zeros plus one.
                                ; zeros plus one.

line 7702:
    INC HL          ; increment source
        inc     hl              ; increment source

line 7703:
    INC DE          ; increment destination
        inc     de              ; increment destination

line 7704:
    LDIR            ; copy C bytes
        ldir                    ; copy C bytes

line 7706:
    EX (SP),HL      ; put HL on stack as next literal pointer
        ex      (sp), hl        ; put HL on stack as next literal pointer

line 7707:
                ; and the stack value - result pointer -
                                ; and the stack value - result pointer -

line 7708:
                ; to HL.
                                ; to HL.

line 7709:
    EXX         ; switch to alternate set.
        exx                     ; switch to alternate set.

line 7710:
    POP HL          ; restore next literal pointer from stack
        pop     hl              ; restore next literal pointer from stack

line 7711:
                ; to H'L'.
                                ; to H'L'.

line 7712:
    EXX         ; switch back to main set.
        exx                     ; switch back to main set.

line 7714:
    LD B,A          ; zero count to B
        ld      b, a            ; zero count to B

line 7715:
    XOR A           ; clear accumulator
        xor     a               ; clear accumulator

line 7717:
    DEC B           ; decrement B counter
        dec     b               ; decrement B counter

line 7718:
    RET Z           ; return if zero.       >>
        ret     z               ; return if zero.       >>

line 7719:
                ; DE points to new STKEND
                                ; DE points to new STKEND

line 7720:
                ; HL to new number.
                                ; HL to new number.

line 7722:
    LD (DE),A       ; else load zero to destination
        ld      (de), a         ; else load zero to destination

line 7723:
    INC DE          ; increase destination
        inc     de              ; increase destination

line 7724:
    JR STK_ZEROS        ; loop back to STK-ZEROS until done.
        jr      STK_ZEROS       ; loop back to STK-ZEROS until done.

line 7735:
    LD HL,($401F)       ; MEM is base address of the memory cells.
        ld      hl, ($401F)     ; MEM is base address of the memory cells.

line 7737:
    PUSH DE         ; save STKEND
        push    de              ; save STKEND

line 7739:
    CALL LOC_MEM        ; routine LOC-MEM so that HL = first byte
        call    LOC_MEM         ; routine LOC-MEM so that HL = first byte

line 7740:
    CALL COPY_FP        ; routine COPY-FP moves 5 bytes with memory check.
        call    COPY_FP         ; routine COPY-FP moves 5 bytes with memory check.

line 7741:
                ; DE now points to new STKEND.
                                ; DE now points to new STKEND.

line 7746:
    POP HL          ; the original STKEND is now RESULT pointer.
        pop     hl              ; the original STKEND is now RESULT pointer.

line 7747:
    RET         ; return.
        ret                     ; return.

line 7766:
    LD HL,TAB_CNST      ; Address: Table of constants.
        ld      hl, TAB_CNST    ; Address: Table of constants.

line 7767:
    JR INDEX_5      ; and join subsroutine above.
        jr      INDEX_5         ; and join subsroutine above.

line 7783:
    PUSH HL         ; save the result pointer.
        push    hl              ; save the result pointer.

line 7784:
    EX DE,HL        ; transfer to DE.
        ex      de, hl          ; transfer to DE.

line 7785:
    LD HL,($401F)       ; fetch MEM the base of memory area.
        ld      hl, ($401F)     ; fetch MEM the base of memory area.

line 7786:
    CALL LOC_MEM        ; routine LOC-MEM sets HL to the destination.
        call    LOC_MEM         ; routine LOC-MEM sets HL to the destination.

line 7787:
    EX DE,HL        ; swap - HL is start, DE is destination.
        ex      de, hl          ; swap - HL is start, DE is destination.

line 7789:
    LD C,$05        ;+ one extra byte but
        ld      c, $05          ;+ one extra byte but

line 7790:
    LDIR            ;+ faster and no memory check.
        ldir                    ;+ faster and no memory check.

line 7792:
    EX DE,HL        ; DE = STKEND
        ex      de, hl          ; DE = STKEND

line 7793:
    POP HL          ; restore original result pointer
        pop     hl              ; restore original result pointer

line 7794:
    RET             ; return.
        ret                     ; return.

line 7815:
    CALL GEN_ENT1       ; routine GEN-ENT-1 is called.
        call    GEN_ENT1        ; routine GEN-ENT-1 is called.

line 7816:
                ; A recursive call to a special entry point
                                ; A recursive call to a special entry point

line 7817:
                ; in the calculator that puts the B register
                                ; in the calculator that puts the B register

line 7818:
                ; in the system variable BREG. The return
                                ; in the system variable BREG. The return

line 7819:
                ; address is the next location and where
                                ; address is the next location and where

line 7820:
                ; the calculator will expect its first
                                ; the calculator will expect its first

line 7821:
                ; instruction - now pointed to by HL'.
                                ; instruction - now pointed to by HL'.

line 7822:
                ; The previous pointer to the series of
                                ; The previous pointer to the series of

line 7823:
                ; five-byte numbers goes on the machine stack.
                                ; five-byte numbers goes on the machine stack.

line 7827:
    .db $3A     ;;mul-by-2      2*x
        .db $3A                 ;;mul-by-2      2*x

line 7829:
    DEFB $C0    ;;st-mem-0      2*x
        defb    $C0             ;;st-mem-0      2*x

line 7830:
    DEFB $02    ;;delete        .
        defb    $02             ;;delete        .

line 7831:
    DEFB $A0    ;;stk-zero      0
        defb    $A0             ;;stk-zero      0

line 7833:
    .db $C1     ;;st-mem-1      0
        .db $C1                 ;;st-mem-1      0

line 7834:
    .db $2D     ;;duplicate     0,0.
        .db $2D                 ;;duplicate     0,0.

line 7836:
    .db $2F     ;;jump
        .db $2F                 ;;jump

line 7837:
    .db G_LOOP1-$   ;;to G-LOOP1    - skip the 1st round
        .db G_LOOP1-$           ;;to G-LOOP1    - skip the 1st round

line 7843:
    DEFB $2D    ;;duplicate     v,v.
        defb    $2D             ;;duplicate     v,v.

line 7844:
    DEFB $E0    ;;get-mem-0     v,v,2*x
        defb    $E0             ;;get-mem-0     v,v,2*x

line 7845:
    DEFB $04    ;;multiply      v,v*2*x
        defb    $04             ;;multiply      v,v*2*x

line 7846:
    DEFB $E2    ;;get-mem-2     v,v*2*x,v
        defb    $E2             ;;get-mem-2     v,v*2*x,v

line 7847:
    DEFB $C1    ;;st-mem-1      v,v*2*x,v
        defb    $C1             ;;st-mem-1      v,v*2*x,v

line 7848:
    DEFB $03    ;;subtract      v,v*2*x-v
        defb    $03             ;;subtract      v,v*2*x-v

line 7850:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 7855:
    CALL stk_data       ; routine STK-DATA is called directly to
        call    stk_data        ; routine STK-DATA is called directly to

line 7856:
                ; push a value and advance H'L'.
                                ; push a value and advance H'L'.

line 7857:
    CALL GEN_ENT2       ; routine GEN-ENT-2 recursively re-enters
        call    GEN_ENT2        ; routine GEN-ENT-2 recursively re-enters

line 7858:
                ; the calculator without disturbing
                                ; the calculator without disturbing

line 7859:
                ; system variable BREG
                                ; system variable BREG

line 7860:
                ; H'L' value goes on the machine stack and is
                                ; H'L' value goes on the machine stack and is

line 7861:
                ; then loaded as usual with the next address.
                                ; then loaded as usual with the next address.

line 7863:
    DEFB $0F    ;;addition
        defb    $0F             ;;addition

line 7864:
    DEFB $01    ;;exchange
        defb    $01             ;;exchange

line 7865:
    DEFB $C2    ;;st-mem-2
        defb    $C2             ;;st-mem-2

line 7866:
    DEFB $02    ;;delete
        defb    $02             ;;delete

line 7868:
    DEFB $31    ;;dec-jr-nz
        defb    $31             ;;dec-jr-nz

line 7869:
    DEFB G_LOOP-$   ;;back to G-LOOP
        defb    G_LOOP-$        ;;back to G-LOOP

line 7874:
    DEFB $E1    ;;get-mem-1
        defb    $E1             ;;get-mem-1

line 7875:
    DEFB $03    ;;subtract
        defb    $03             ;;subtract

line 7876:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 7878:
    RET         ; return with H'L' pointing to location
        ret                     ; return with H'L' pointing to location

line 7879:
                ; after last number in series.
                                ; after last number in series.

line 7887:
    LD A,(HL)       ; fetch exponent of last value on the
        ld      a, (hl)         ; fetch exponent of last value on the

line 7888:
                ; calculator stack.
                                ; calculator stack.

line 7889:
    AND A           ; test it.
        and     a               ; test it.

line 7890:
    RET Z           ; return if zero.
        ret     z               ; return if zero.

line 7892:
    INC HL          ; address the byte with the sign bit.
        inc     hl              ; address the byte with the sign bit.

line 7893:
    LD A,(HL)       ; fetch to accumulator.
        ld      a, (hl)         ; fetch to accumulator.

line 7894:
    XOR $80         ; toggle the sign bit.
        xor     $80             ; toggle the sign bit.

line 7895:
    LD (HL),A       ; put it back.
        ld      (hl), a         ; put it back.

line 7896:
    DEC HL          ; point to last value again.
        dec     hl              ; point to last value again.

line 7897:
    RET         ; return.
        ret                     ; return.

line 7907:
    ld a,(hl)       ; fetch exponent of last value on the stack
        ld      a, (hl)         ; fetch exponent of last value on the stack

line 7908:
    and a           ; test it.
        and     a               ; test it.

line 7909:
    ret z           ; return if zero.
        ret     z               ; return if zero.

line 7911:
    call greater1       ; if >0 then CY=1
        call    greater1        ; if >0 then CY=1

line 7912:
    ret c           ; and return value=1
        ret     c               ; and return value=1

line 7914:
    ld (hl),$81     ; else make value 1
        ld      (hl), $81       ; else make value 1

line 7915:
    jr negate_1     ; and return via 'unary minus'
        jr      negate_1        ; and return via 'unary minus'

line 7925:
    LD A,(HL)       ; fetch exponent.
        ld      a, (hl)         ; fetch exponent.

line 7926:
    AND A           ; test it for zero.
        and     a               ; test it for zero.

line 7927:
    RET Z           ; return if so.
        ret     z               ; return if so.

line 7929:
    LD A,$FF        ; prepare XOR mask for sign bit
        ld      a, $FF          ; prepare XOR mask for sign bit

line 7930:
    JR SGN_TO_C     ; forward to SIGN-TO-C
        jr      SGN_TO_C        ; forward to SIGN-TO-C

line 7931:
                ; to put sign in carry
                                ; to put sign in carry

line 7932:
                ; (carry will become set if sign is positive)
                                ; (carry will become set if sign is positive)

line 7933:
                ; and then overwrite location with 1 or 0
                                ; and then overwrite location with 1 or 0

line 7934:
                ; as appropriate.
                                ; as appropriate.

line 7940:
    dec b           ; correct the calculator literal in B
        dec     b               ; correct the calculator literal in B

line 7941:
    call comp_tru       ; then perform the comparison ...
        call    comp_tru        ; then perform the comparison ...

line 7957:
    LD A,(HL)       ; get exponent byte.
        ld      a, (hl)         ; get exponent byte.

line 7959:
    NEG         ; negate - sets carry if non-zero.
        neg                     ; negate - sets carry if non-zero.

line 7961:
    CCF         ; complement so carry set if zero, else reset.
        ccf                     ; complement so carry set if zero, else reset.

line 7962:
    JR FP_0_1       ; forward to FP-0/1.
        jr      FP_0_1          ; forward to FP-0/1.

line 7971:
    XOR A           ; set xor mask to zero
        xor     a               ; set xor mask to zero

line 7972:
                ; (carry will become set if sign is negative).
                                ; (carry will become set if sign is negative).

line 7977:
    INC HL          ; address 2nd byte.
        inc     hl              ; address 2nd byte.

line 7978:
    XOR (HL)        ; bit 7 of HL will be set if number is negative.
        xor     (hl)            ; bit 7 of HL will be set if number is negative.

line 7979:
    DEC HL          ; address 1st byte again.
        dec     hl              ; address 1st byte again.

line 7980:
    RLCA            ; rotate bit 7 of A to carry.
        rlca                    ; rotate bit 7 of A to carry.

line 7990:
    PUSH  HL        ; save pointer to the first byte
        push    hl              ; save pointer to the first byte

line 7991:
    LD B,$05        ; five bytes to do.
        ld      b, $05          ; five bytes to do.

line 7993:
    LD (HL),$00     ; insert a zero.
        ld      (hl), $00       ; insert a zero.

line 7994:
    INC HL          ;
        inc     hl              ;

line 7995:
    DJNZ FP_loop        ; repeat.
        djnz    FP_loop         ; repeat.

line 7997:
    POP HL          ;
        pop     hl              ;

line 7998:
    RET NC          ;
        ret     nc              ;

line 8000:
    LD (HL),$81     ; make value 1
        ld      (hl), $81       ; make value 1

line 8001:
    RET         ; return.
        ret                     ; return.

line 8017:
op_or   LD A,(DE)       ; fetch exponent of second number
op_or   ld a, (de)              ; fetch exponent of second number

line 8018:
    AND  A          ; test it.
        and     a               ; test it.

line 8019:
    RET Z           ; return if zero.
        ret     z               ; return if zero.

line 8021:
    SCF         ; set carry flag
        scf                     ; set carry flag

line 8022:
    JR FP_0_1       ; back to FP-0/1 to overwrite the first operand
        jr      FP_0_1          ; back to FP-0/1 to overwrite the first operand

line 8023:
                ; with the value 1.
                                ; with the value 1.

line 8047:
    LD A,(DE)       ; fetch exponent of second number.
        ld      a, (de)         ; fetch exponent of second number.

line 8048:
    AND A           ; test it.
        and     a               ; test it.

line 8049:
    RET NZ          ; return if not zero.
        ret     nz              ; return if not zero.

line 8051:
    JR FP_0_1       ; back to FP-0/1 to overwrite the first operand
        jr      FP_0_1          ; back to FP-0/1 to overwrite the first operand

line 8052:
                ; with zero for return value.
                                ; with zero for return value.

line 8088:
    push bc         ; save calculator literal
        push    bc              ; save calculator literal

line 8089:
    push de         ; save pointer to operand2
        push    de              ; save pointer to operand2

line 8090:
    push hl         ; save pointer to operand1
        push    hl              ; save pointer to operand1

line 8092:
                ; if operand1 < operand2 then Z=0, CY=0
                                ; if operand1 < operand2 then Z=0, CY=0

line 8093:
    call compare        ; if operand1 = operand2 then Z=1, CY=0
        call    compare         ; if operand1 = operand2 then Z=1, CY=0

line 8094:
                ; if operand1 > operand2 then Z=0, CY=1
                                ; if operand1 > operand2 then Z=0, CY=1

line 8096:
    pop hl          ; restore pointer to operand2
        pop     hl              ; restore pointer to operand2

line 8097:
    pop de          ; restore pointer to operand1
        pop     de              ; restore pointer to operand1

line 8098:
    pop bc          ; restore calculator literal
        pop     bc              ; restore calculator literal

line 8100:
    jr z,comp_equ       ; jump if operands are equal
        jr      z, comp_equ     ; jump if operands are equal

line 8102:
    jr c,comp_op1       ; jump if operand1 > operand2
        jr      c, comp_op1     ; jump if operand1 > operand2

line 8104:
    bit 0,b         ;
        bit     0, b            ;

line 8105:
                ; condition
                                ; condition

line 8106:
    jr z,FP_0_1     ; op1>op2 or op1=op2    (CY=0 -> place '0')
        jr      z, FP_0_1       ; op1>op2 or op1=op2    (CY=0 -> place '0')

line 8107:
    jr fn_not2      ; op1<op2       (CY=1 -> place '1')
        jr      fn_not2         ; op1<op2       (CY=1 -> place '1')

line 8111:
    ld a,$03        ; set mask '000000xx'
        ld      a, $03          ; set mask '000000xx'

line 8112:
    and b           ; (clears CY!)
        and     b               ; (clears CY!)

line 8113:
                ; condition
                                ; condition

line 8114:
    jr nz,FP_0_1        ; op1<op2 or op1=op2    (CY=0 -> place '0')
        jr      nz, FP_0_1      ; op1<op2 or op1=op2    (CY=0 -> place '0')

line 8115:
    jr fn_not2      ; op1>op2       (CY=1 -> place '1')
        jr      fn_not2         ; op1>op2       (CY=1 -> place '1')

line 8119:
    bit 1,b         ;
        bit     1, b            ;

line 8120:
                ; condition
                                ; condition

line 8121:
    jr nz,op_or_1       ; op1=op2       (CY=1 -> place '1')
        jr      nz, op_or_1     ; op1=op2       (CY=1 -> place '1')

line 8122:
    jr FP_0_1       ; op1<>op2      (CY=0 -> place '0')
        jr      FP_0_1          ; op1<>op2      (CY=0 -> place '0')

line 8126:
    bit 4,b         ; bit 4 selects strings as operands
        bit     4, b            ; bit 4 selects strings as operands

line 8127:
    jr z,comp_num       ; else compare numbers
        jr      z, comp_num     ; else compare numbers

line 8133:
    call STK_FETCH      ; routine STK-FETCH gets 2nd string's params
        call    STK_FETCH       ; routine STK-FETCH gets 2nd string's params

line 8134:
    push de         ; save start2 *.
        push    de              ; save start2 *.

line 8135:
    push bc         ; and the length2.
        push    bc              ; and the length2.

line 8137:
    call STK_FETCH      ; routine STK-FETCH gets 1st string's
        call    STK_FETCH       ; routine STK-FETCH gets 1st string's

line 8138:
                ; parameters - start in DE, length in BC.
                                ; parameters - start in DE, length in BC.

line 8139:
    pop hl          ; restore length of second to HL.
        pop     hl              ; restore length of second to HL.

line 8140:
    and a           ; clear CY
        and     a               ; clear CY

line 8141:
    sbc hl,bc       ; compare
        sbc     hl, bc          ; compare

line 8143:
    jr nc,cplen_eq      ; jump, if len1<=len2
        jr      nc, cplen_eq    ; jump, if len1<=len2

line 8145:
    add hl,bc       ; restore length2
        add     hl, bc          ; restore length2

line 8146:
    ld b,h          ; and set counter
        ld      b, h            ; and set counter

line 8147:
    ld c,l          ; of comparision
        ld      c, l            ; of comparision

line 8149:
    pop hl          ; restore start2 to HL.
        pop     hl              ; restore start2 to HL.

line 8150:
    jr z,comp_neg       ; if the lengths are equal compare byte by byte
        jr      z, comp_neg     ; if the lengths are equal compare byte by byte

line 8152:
    push af         ; save flags (Z=0 and CY=1, if len1>len2)
        push    af              ; save flags (Z=0 and CY=1, if len1>len2)

line 8153:
    call comp_neg       ; compare byte by byte
        call    comp_neg        ; compare byte by byte

line 8154:
    jp nz,cmp_nequ      ; jump if parts are different
        jp      nz, cmp_nequ    ; jump if parts are different

line 8156:
    pop af          ; else restore flags
        pop     af              ; else restore flags

line 8157:
    ret         ; CY=1 if 1st string is longer
        ret                     ; CY=1 if 1st string is longer

line 8163:
    ld bc,5         ; the size of a floating point number (5 bytes)
        ld      bc, 5           ; the size of a floating point number (5 bytes)

line 8164:
    inc hl          ; points the MSB of the 1st mantissa
        inc     hl              ; points the MSB of the 1st mantissa

line 8165:
    inc de          ; points the MSB of the 2nd mantissa
        inc     de              ; points the MSB of the 2nd mantissa

line 8166:
    ld a,(de)       ; compare the
        ld      a, (de)         ; compare the

line 8167:
    xor (hl)        ; sign bits
        xor     (hl)            ; sign bits

line 8168:
    rla         ; CY=1 if they are different
        rla                     ; CY=1 if they are different

line 8169:
    ld a,(de)       ; MSB of the 2nd mantissa (A7=sign bit)
        ld      a, (de)         ; MSB of the 2nd mantissa (A7=sign bit)

line 8170:
    dec de          ; restore the
        dec     de              ; restore the

line 8171:
    dec hl          ; pointers
        dec     hl              ; pointers

line 8173:
    jr nc,comp_pos      ; if signs are equals then compare byte by byte
        jr      nc, comp_pos    ; if signs are equals then compare byte by byte

line 8175:
    rla         ; else set CY if the 2nd number is negative
        rla                     ; else set CY if the 2nd number is negative

line 8176:
    ret         ; and return
        ret                     ; and return

line 8178:
    rla         ; if signs are positive
        rla                     ; if signs are positive

line 8179:
    jr nc,comp_nxt      ; then continue with byte by byte comparision
        jr      nc, comp_nxt    ; then continue with byte by byte comparision

line 8181:
    ex de,hl        ; else swap pointers
        ex      de, hl          ; else swap pointers

line 8183:
    ld a,b          ; test byte counter
        ld      a, b            ; test byte counter

line 8184:
    or c            ; if it is zero (CY=0 and Z=1)
        or      c               ; if it is zero (CY=0 and Z=1)

line 8185:
    ret z           ; then end of comparision
        ret     z               ; then end of comparision

line 8187:
    ld a,(de)       ; compare byte
        ld      a, (de)         ; compare byte

line 8188:
    cp (hl)         ; by byte
        cp      (hl)            ; by byte

line 8189:
    ret nz          ; return if they are different
        ret     nz              ; return if they are different

line 8191:
    inc hl          ; set pointers
        inc     hl              ; set pointers

line 8192:
    inc de          ;
        inc     de              ;

line 8193:
    dec bc          ; and the byte counter
        dec     bc              ; and the byte counter

line 8194:
    jr comp_tst     ;
        jr      comp_tst        ;

line 8207:
    CALL STK_FETCH      ; routine STK-FETCH fetches string parameters
        call    STK_FETCH       ; routine STK-FETCH fetches string parameters

line 8208:
                ; and deletes calculator stack entry.
                                ; and deletes calculator stack entry.

line 8209:
    PUSH DE         ; save start address.
        push    de              ; save start address.

line 8210:
    PUSH BC         ; and length.
        push    bc              ; and length.

line 8212:
    CALL STK_FETCH      ; routine STK-FETCH for first string
        call    STK_FETCH       ; routine STK-FETCH for first string

line 8213:
    POP HL          ; re-fetch first length
        pop     hl              ; re-fetch first length

line 8214:
    PUSH HL         ; and save again
        push    hl              ; and save again

line 8215:
    PUSH DE         ; save start of second string
        push    de              ; save start of second string

line 8216:
    PUSH BC         ; and its length.
        push    bc              ; and its length.

line 8218:
    ADD HL,BC       ; add the two lengths.
        add     hl, bc          ; add the two lengths.

line 8219:
    LD B,H          ; transfer to BC
        ld      b, h            ; transfer to BC

line 8220:
    LD C,L          ; and create
        ld      c, l            ; and create

line 8221:
    RST 30H         ; BC-SPACES in workspace.
        rst     30H             ; BC-SPACES in workspace.

line 8222:
                ; DE points to start of space.
                                ; DE points to start of space.

line 8224:
    CALL STK_ST_s       ; routine STK-STO-$ stores parameters
        call    STK_ST_s        ; routine STK-STO-$ stores parameters

line 8225:
                ; of new string updating STKEND.
                                ; of new string updating STKEND.

line 8227:
    POP BC          ; length of first
        pop     bc              ; length of first

line 8228:
    POP HL          ; address of start
        pop     hl              ; address of start

line 8230:
    CALL COND_MV        ;+ a conditional (NZ) ldir routine.
        call    COND_MV         ;+ a conditional (NZ) ldir routine.

line 8233:
    POP BC          ; now second length
        pop     bc              ; now second length

line 8234:
    POP HL          ; and start of string
        pop     hl              ; and start of string

line 8236:
    CALL COND_MV        ;+ a conditional (NZ) ldir routine.
        call    COND_MV         ;+ a conditional (NZ) ldir routine.

line 8254:
    LD HL,($401C)       ; fetch STKEND value from system variable.
        ld      hl, ($401C)     ; fetch STKEND value from system variable.

line 8256:
    ex de,hl        ; switch pointers
        ex      de, hl          ; switch pointers

line 8257:
    ld hl,$FFFB     ; the value -5
        ld      hl, $FFFB       ; the value -5

line 8259:
    add hl,de       ; HL = STKEND - 5
        add     hl, de          ; HL = STKEND - 5

line 8260:
    ret             ; return.
        ret                     ; return.

line 8270:
    RST 18H         ;+ shorter way to fetch CH_ADD.
        rst     18H             ;+ shorter way to fetch CH_ADD.

line 8271:
    PUSH HL         ; and save on the machine stack.
        push    hl              ; and save on the machine stack.

line 8273:
    CALL STK_FETCH      ; routine STK-FETCH fetches the string operand
        call    STK_FETCH       ; routine STK-FETCH fetches the string operand

line 8274:
                ; from calculator stack.
                                ; from calculator stack.

line 8276:
    PUSH DE         ; save the address of the start of the string.
        push    de              ; save the address of the start of the string.

line 8277:
    INC BC          ; increment the length for a carriage return.
        inc     bc              ; increment the length for a carriage return.

line 8279:
    RST 30H         ; BC-SPACES creates the space in workspace.
        rst     30H             ; BC-SPACES creates the space in workspace.

line 8280:
    POP HL          ; restore start of string to HL.
        pop     hl              ; restore start of string to HL.

line 8281:
    LD ($4016),DE       ; load CH_ADD with start DE in workspace.
        ld      ($4016), de     ; load CH_ADD with start DE in workspace.

line 8283:
    PUSH DE         ; save the start in workspace
        push    de              ; save the start in workspace

line 8284:
    LDIR            ; copy string from program or variables or
        ldir                    ; copy string from program or variables or

line 8285:
                ; workspace to the workspace area.
                                ; workspace to the workspace area.

line 8286:
    EX DE,HL        ; end of string + 1 to HL
        ex      de, hl          ; end of string + 1 to HL

line 8287:
    DEC HL          ; decrement HL to point to end of new area.
        dec     hl              ; decrement HL to point to end of new area.

line 8288:
    LD (HL),$76     ; insert a carriage return at end.
        ld      (hl), $76       ; insert a carriage return at end.

line 8289:
                ; ZX81 has a non-ASCII character set
                                ; ZX81 has a non-ASCII character set

line 8290:
    RES 7,(IY+$01)      ; update FLAGS  - signal checking syntax.
        res     7, (iy+$01)     ; update FLAGS  - signal checking syntax.

line 8291:
    CALL CLASS_06       ; routine CLASS-06 - SCANNING evaluates string
        call    CLASS_06        ; routine CLASS-06 - SCANNING evaluates string

line 8292:
                ; expression and checks for integer result.
                                ; expression and checks for integer result.

line 8294:
    CALL CHECK_2        ; routine CHECK-2 checks for carriage return.
        call    CHECK_2         ; routine CHECK-2 checks for carriage return.

line 8296:
    POP HL          ; restore start of string in workspace.
        pop     hl              ; restore start of string in workspace.

line 8298:
    LD ($4016),HL       ; set CH_ADD to the start of the string again.
        ld      ($4016), hl     ; set CH_ADD to the start of the string again.

line 8299:
    SET 7,(IY+$01)      ; update FLAGS  - signal running program.
        set     7, (iy+$01)     ; update FLAGS  - signal running program.

line 8300:
    CALL SCANNING       ; routine SCANNING evaluates the string
        call    SCANNING        ; routine SCANNING evaluates the string

line 8301:
                ; in full leaving result on calculator stack.
                                ; in full leaving result on calculator stack.

line 8303:
    POP HL          ; restore saved character address in program.
        pop     hl              ; restore saved character address in program.

line 8304:
    LD ($4016),HL       ; and reset the system variable CH_ADD.
        ld      ($4016), hl     ; and reset the system variable CH_ADD.

line 8306:
    JR STK_PNTRS        ; back to exit via STK-PNTRS.
        jr      STK_PNTRS       ; back to exit via STK-PNTRS.

line 8307:
                ; resetting the calculator stack pointers
                                ; resetting the calculator stack pointers

line 8308:
                ; HL and DE from STKEND as it wasn't possible
                                ; HL and DE from STKEND as it wasn't possible

line 8309:
                ; to preserve them during this routine.
                                ; to preserve them during this routine.

line 8320:
    CALL STK_FETCH      ; routine STK-FETCH to fetch and delete the
        call    STK_FETCH       ; routine STK-FETCH to fetch and delete the

line 8321:
                ; string parameters from the calculator stack.
                                ; string parameters from the calculator stack.

line 8322:
                ; register BC now holds the length of string.
                                ; register BC now holds the length of string.

line 8324:
    JP STACK_BC     ; jump back to STACK-BC to save result on the
        jp      STACK_BC        ; jump back to STACK-BC to save result on the

line 8325:
                ; calculator stack (with memory check).
                                ; calculator stack (with memory check).

line 8332:
    ex de,hl        ; else switch pointers
        ex      de, hl          ; else switch pointers

line 8333:
    inc hl          ;
        inc     hl              ;

line 8334:
    bit 7,(hl)      ; test if Y is negative
        bit     7, (hl)         ; test if Y is negative

line 8335:
    dec hl          ;
        dec     hl              ;

line 8336:
    ld a,(hl)       ; fetch Y.exp
        ld      a, (hl)         ; fetch Y.exp

line 8337:
    ex de,hl        ; switch back pointers
        ex      de, hl          ; switch back pointers

line 8338:
    jp z,fn_not1        ; jump if it is positive or zero to
        jp      z, fn_not1      ; jump if it is positive or zero to

line 8339:
                ; replace X with 1 (Y=0) or 0 (Y>0)
                                ; replace X with 1 (Y=0) or 0 (Y>0)

line 8341:
    rst 08h         ; else Error Report:
        rst     08h             ; else Error Report:

line 8342:
    .db $05         ; arithmetic overflow
        .db $05                 ; arithmetic overflow

line 8356:
to_power            ; HL points X, DE points Y.
to_power                        ; HL points X, DE points Y.

line 8357:
    ld a,(hl)       ; fetch X.exp
        ld      a, (hl)         ; fetch X.exp

line 8358:
    and a           ; test zero
        and     a               ; test zero

line 8359:
    jr z,to_pwr_0       ; continue if X<>0
        jr      z, to_pwr_0     ; continue if X<>0

line 8363:
    rst 28h     ;; FP-CALC      X,Y.
        rst     28h             ;; FP-CALC      X,Y.

line 8364:
    .db $01     ;;exchange      Y, X.
        .db $01                 ;;exchange      Y, X.

line 8365:
    .db $22     ;;ln            Y, LN X.
        .db $22                 ;;ln            Y, LN X.

line 8369:
    .db $04     ;;multiply      Y * LN X
        .db $04                 ;;multiply      Y * LN X

line 8370:
    .db $34     ;;end-calc
        .db $34                 ;;end-calc

line 8394:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 8395:
    DEFB $30    ;;stk-data          1/LN 2
        defb    $30             ;;stk-data          1/LN 2

line 8396:
    DEFB $F1    ;;Exponent: $81, Bytes: 4
        defb    $F1             ;;Exponent: $81, Bytes: 4

line 8397:
    DEFB $38,$AA,$3B,$29 ;;
        defb    $38, $AA, $3B, $29
                                ;;

line 8398:
    DEFB $04    ;;multiply
        defb    $04             ;;multiply

line 8399:
    DEFB $2D    ;;duplicate
        defb    $2D             ;;duplicate

line 8400:
    DEFB $24    ;;int
        defb    $24             ;;int

line 8401:
    DEFB $C3    ;;st-mem-3
        defb    $C3             ;;st-mem-3

line 8402:
    DEFB $03    ;;subtract
        defb    $03             ;;subtract

line 8404:
    .db $3A     ;;mul-by-2          *2
        .db $3A                 ;;mul-by-2          *2

line 8405:
    .db $39     ;;sub-one macro         -1
        .db $39                 ;;sub-one macro         -1

line 8407:
    DEFB $88    ;;series-08
        defb    $88             ;;series-08

line 8408:
    DEFB $13    ;;Exponent: $63, Bytes: 1
        defb    $13             ;;Exponent: $63, Bytes: 1

line 8409:
    DEFB $36    ;;(+00,+00,+00)
        defb    $36             ;;(+00,+00,+00)

line 8410:
    DEFB $58    ;;Exponent: $68, Bytes: 2
        defb    $58             ;;Exponent: $68, Bytes: 2

line 8411:
    DEFB $65,$66    ;;(+00,+00)
        defb    $65, $66        ;;(+00,+00)

line 8412:
    DEFB $9D    ;;Exponent: $6D, Bytes: 3
        defb    $9D             ;;Exponent: $6D, Bytes: 3

line 8413:
    DEFB $78,$65,$40 ;;(+00)
        defb    $78, $65, $40   ;;(+00)

line 8414:
    DEFB $A2    ;;Exponent: $72, Bytes: 3
        defb    $A2             ;;Exponent: $72, Bytes: 3

line 8415:
    DEFB $60,$32,$C9 ;;(+00)
        defb    $60, $32, $C9   ;;(+00)

line 8416:
    DEFB $E7    ;;Exponent: $77, Bytes: 4
        defb    $E7             ;;Exponent: $77, Bytes: 4

line 8417:
    DEFB $21,$F7,$AF,$24 ;;
        defb    $21, $F7, $af, $24
                                ;;

line 8418:
    DEFB $EB    ;;Exponent: $7B, Bytes: 4
        defb    $EB             ;;Exponent: $7B, Bytes: 4

line 8419:
    DEFB $2F,$B0,$B0,$14 ;;
        defb    $2F, $B0, $B0, $14
                                ;;

line 8420:
    DEFB $EE    ;;Exponent: $7E, Bytes: 4
        defb    $EE             ;;Exponent: $7E, Bytes: 4

line 8421:
    DEFB $7E,$BB,$94,$58 ;;
        defb    $7E, $BB, $94, $58
                                ;;

line 8422:
    DEFB $F1    ;;Exponent: $81, Bytes: 4
        defb    $F1             ;;Exponent: $81, Bytes: 4

line 8423:
    DEFB $3A,$7E,$F8,$CF ;;
        defb    $3A, $7E, $F8, $CF
                                ;;

line 8425:
    DEFB $E3    ;;get-mem-3
        defb    $E3             ;;get-mem-3

line 8426:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 8428:
    CALL FP_TO_A        ; routine FP-TO-A
        call    FP_TO_A         ; routine FP-TO-A

line 8429:
    JR NZ,N_NEGTV       ; to N-NEGTV
        jr      nz, N_NEGTV     ; to N-NEGTV

line 8431:
    JR C,REPORT_6b      ; to REPORT-6b
        jr      c, REPORT_6b    ; to REPORT-6b

line 8433:
    ADD A,(HL)      ;
        add     a, (hl)         ;

line 8434:
    JR NC,RESULT_OK     ; to RESULT-OK
        jr      nc, RESULT_OK   ; to RESULT-OK

line 8437:
    RST 08H         ; ERROR-1
        rst     08H             ; ERROR-1

line 8438:
    DEFB $05        ; Error Report: Number too big
        defb    $05             ; Error Report: Number too big

line 8441:
    jp c,fn_not2        ; return via FP-0/1 to replace last value with zero
        jp      c, fn_not2      ; return via FP-0/1 to replace last value with zero

line 8443:
    SUB (HL)        ;
        sub     (hl)            ;

line 8444:
    jp nc,FP_0_1        ; return via FP-0/1 to replace last value with zero
        jp      nc, FP_0_1      ; return via FP-0/1 to replace last value with zero

line 8446:
    NEG         ; Negate
        neg                     ; Negate

line 8449:
    LD (HL),A       ;
        ld      (hl), a         ;

line 8450:
    RET         ; return.
        ret                     ; return.

line 8461:
    CALL FP_TO_A        ; routine FP-TO-A puts the number in A.
        call    FP_TO_A         ; routine FP-TO-A puts the number in A.

line 8462:
    JR C,REPORT_Bd      ; forward to REPORT-Bd if overflow
        jr      c, REPORT_Bd    ; forward to REPORT-Bd if overflow

line 8464:
    JR NZ,REPORT_Bd     ; forward to REPORT-Bd if negative
        jr      nz, REPORT_Bd   ; forward to REPORT-Bd if negative

line 8466:
    LD BC,$0001     ; one space required.
        ld      bc, $0001       ; one space required.

line 8467:
    RST 30H         ; BC-SPACES makes DE point to start
        rst     30H             ; BC-SPACES makes DE point to start

line 8469:
    LD (DE),A       ; and store in workspace
        ld      (de), a         ; and store in workspace

line 8471:
    JR str_STK      ;+ relative jump to similar sequence in str$.
        jr      str_STK         ;+ relative jump to similar sequence in str$.

line 8488:
    LD BC,$0001     ; create an initial byte in workspace
        ld      bc, $0001       ; create an initial byte in workspace

line 8489:
    RST 30H         ; using BC-SPACES restart.
        rst     30H             ; using BC-SPACES restart.

line 8491:
    LD (HL),$76     ; place a carriage return there.
        ld      (hl), $76       ; place a carriage return there.

line 8493:
    LD HL,($4039)       ; fetch value of S_POSN column/line
        ld      hl, ($4039)     ; fetch value of S_POSN column/line

line 8494:
    PUSH HL         ; and preserve on stack.
        push    hl              ; and preserve on stack.

line 8496:
    LD L,$FF        ; make column value high to create a
        ld      l, $FF          ; make column value high to create a

line 8497:
                ; contrived buffer of length 254.
                                ; contrived buffer of length 254.

line 8498:
    LD ($4039),HL       ; and store in system variable S_POSN.
        ld      ($4039), hl     ; and store in system variable S_POSN.

line 8500:
    LD HL,($400E)       ; fetch value of DF_CC
        ld      hl, ($400E)     ; fetch value of DF_CC

line 8501:
    PUSH HL         ; and preserve on stack also.
        push    hl              ; and preserve on stack also.

line 8503:
    LD ($400E),DE       ; now set DF_CC which normally addresses
        ld      ($400E), de     ; now set DF_CC which normally addresses

line 8504:
                ; somewhere in the display file to the start
                                ; somewhere in the display file to the start

line 8505:
                ; of workspace.
                                ; of workspace.

line 8506:
    PUSH DE         ; save the start of new string.
        push    de              ; save the start of new string.

line 8508:
    CALL PRINT_FP       ; routine PRINT-FP.
        call    PRINT_FP        ; routine PRINT-FP.

line 8510:
    POP DE          ; retrieve start of string.
        pop     de              ; retrieve start of string.

line 8512:
    LD HL,($400E)       ; fetch end of string from DF_CC.
        ld      hl, ($400E)     ; fetch end of string from DF_CC.

line 8513:
    AND A           ; prepare for true subtraction.
        and     a               ; prepare for true subtraction.

line 8514:
    SBC  HL,DE      ; subtract to give length.
        sbc     hl, de          ; subtract to give length.

line 8516:
    LD B,H          ; and transfer to the BC
        ld      b, h            ; and transfer to the BC

line 8517:
    LD C,L          ; register.
        ld      c, l            ; register.

line 8519:
    POP HL          ; restore original
        pop     hl              ; restore original

line 8520:
    LD ($400E),HL       ; DF_CC value
        ld      ($400E), hl     ; DF_CC value

line 8522:
    POP HL          ; restore original
        pop     hl              ; restore original

line 8523:
    LD ($4039),HL       ; S_POSN values.
        ld      ($4039), hl     ; S_POSN values.

line 8528:
    CALL STK_ST_s       ; routine STK-STO-$ stores the string
        call    STK_ST_s        ; routine STK-STO-$ stores the string

line 8529:
                ; descriptor on the calculator stack.
                                ; descriptor on the calculator stack.

line 8531:
    EX DE,HL        ; HL = last value, DE = STKEND.
        ex      de, hl          ; HL = last value, DE = STKEND.

line 8532:
    RET         ; return.
        ret                     ; return.

line 8543:
    CALL STK_FETCH      ; routine STK-FETCH to fetch and delete the
        call    STK_FETCH       ; routine STK-FETCH to fetch and delete the

line 8544:
                ; string parameters.
                                ; string parameters.

line 8545:
                ; DE points to the start, BC holds the length.
                                ; DE points to the start, BC holds the length.

line 8546:
    LD A,B          ; test length
        ld      a, b            ; test length

line 8547:
    OR C            ; of the string.
        or      c               ; of the string.

line 8548:
    JR Z,STK_CODE       ; skip to STK-CODE with zero if the null string.
        jr      z, STK_CODE     ; skip to STK-CODE with zero if the null string.

line 8550:
    LD A,(DE)       ; else fetch the first character.
        ld      a, (de)         ; else fetch the first character.

line 8552:
    JP STACK_A      ; jump back to STACK-A (with memory check)
        jp      STACK_A         ; jump back to STACK-A (with memory check)

line 8564:
    LD B,$05        ; there are five bytes to be swapped
        ld      b, $05          ; there are five bytes to be swapped

line 8569:
    LD A,(DE)       ; each byte of second
        ld      a, (de)         ; each byte of second

line 8570:
    LD C,A          ;+
        ld      c, a            ;+

line 8571:
    LD A,(HL)       ;+ each byte of first
        ld      a, (hl)         ;+ each byte of first

line 8572:
    LD (DE),A       ; store each byte of first
        ld      (de), a         ; store each byte of first

line 8573:
    LD (HL),C       ; store each byte of second
        ld      (hl), c         ; store each byte of second

line 8574:
    INC HL          ; advance both
        inc     hl              ; advance both

line 8575:
    INC DE          ; pointers.
        inc     de              ; pointers.

line 8576:
    DJNZ SWAP_BYTE      ; loop back to SWAP-BYTE until all 5 done.
        djnz    SWAP_BYTE       ; loop back to SWAP-BYTE until all 5 done.

line 8578:
    RET         ; return.
        ret                     ; return.

line 8589:
    EXX         ; switch in set that addresses code
        exx                     ; switch in set that addresses code

line 8591:
    PUSH HL         ; save pointer to offset byte
        push    hl              ; save pointer to offset byte

line 8592:
    LD HL,$401E     ; address BREG in system variables
        ld      hl, $401E       ; address BREG in system variables

line 8593:
    DEC (HL)        ; decrement it
        dec     (hl)            ; decrement it

line 8594:
    POP HL          ; restore pointer
        pop     hl              ; restore pointer

line 8596:
    JR NZ,JUMP_2        ; to JUMP-2 if not zero
        jr      nz, JUMP_2      ; to JUMP-2 if not zero

line 8598:
    INC HL          ; step past the jump length.
        inc     hl              ; step past the jump length.

line 8599:
    EXX         ; switch in the main set.
        exx                     ; switch in the main set.

line 8600:
    RET         ; return.
        ret                     ; return.

line 8616:
    EXX         ; switch in pointer set
        exx                     ; switch in pointer set

line 8618:
    LD E,(HL)       ; the jump byte 0-127 forward, 128-255 back.
        ld      e, (hl)         ; the jump byte 0-127 forward, 128-255 back.

line 8620:
    LD A,E          ;+
        ld      a, e            ;+

line 8621:
    RLA         ;+
        rla                     ;+

line 8622:
    SBC A,A         ;+
        sbc     a, a            ;+

line 8624:
    LD D,A          ; transfer to high byte.
        ld      d, a            ; transfer to high byte.

line 8625:
    ADD HL,DE       ; advance calculator pointer forward or back.
        add     hl, de          ; advance calculator pointer forward or back.

line 8627:
    EXX         ; switch out pointer set.
        exx                     ; switch out pointer set.

line 8628:
    RET         ; return.
        ret                     ; return.

line 8639:
    LD A,(DE)       ; collect exponent byte
        ld      a, (de)         ; collect exponent byte

line 8640:
    AND A           ; is result 0 or 1 ?
        and     a               ; is result 0 or 1 ?

line 8641:
    EXX         ; switch in the pointer set.
        exx                     ; switch in the pointer set.

line 8643:
    jr jmp_tru1     ; back to JUMP if true (1).
        jr      jmp_tru1        ; back to JUMP if true (1).

line 8659:
    RST 28H     ;; FP-CALC      17, 3.
        rst     28H             ;; FP-CALC      17, 3.

line 8660:
    DEFB $C0    ;;st-mem-0      17, 3.
        defb    $C0             ;;st-mem-0      17, 3.

line 8661:
    DEFB $02    ;;delete        17.
        defb    $02             ;;delete        17.

line 8662:
    DEFB $2D    ;;duplicate     17, 17.
        defb    $2D             ;;duplicate     17, 17.

line 8663:
    DEFB $E0    ;;get-mem-0     17, 17, 3.
        defb    $E0             ;;get-mem-0     17, 17, 3.

line 8664:
    DEFB $05    ;;division      17, 17/3.
        defb    $05             ;;division      17, 17/3.

line 8665:
    DEFB $24    ;;int           17, 5.
        defb    $24             ;;int           17, 5.

line 8666:
    DEFB $E0    ;;get-mem-0     17, 5, 3.
        defb    $E0             ;;get-mem-0     17, 5, 3.

line 8667:
    DEFB $01    ;;exchange      17, 3, 5.
        defb    $01             ;;exchange      17, 3, 5.

line 8668:
    DEFB $C0    ;;st-mem-0      17, 3, 5.
        defb    $C0             ;;st-mem-0      17, 3, 5.

line 8669:
    DEFB $04    ;;multiply      17, 15.
        defb    $04             ;;multiply      17, 15.

line 8670:
    DEFB $03    ;;subtract      2.
        defb    $03             ;;subtract      2.

line 8671:
    DEFB $E0    ;;get-mem-0     2, 5.
        defb    $E0             ;;get-mem-0     2, 5.

line 8672:
    DEFB $34    ;;end-calc      2, 5.
        defb    $34             ;;end-calc      2, 5.

line 8674:
    RET         ; return.
        ret                     ; return.

line 8679:
    RST 08H         ; ERROR-1
        rst     08H             ; ERROR-1

line 8680:
    DEFB $0A        ; Error Report: Integer out of range
        defb    $0A             ; Error Report: Integer out of range

line 8692:
    push hl         ; save pointer to 'X'
        push    hl              ; save pointer to 'X'

line 8693:
    call COPY_FP        ; duplicate
        call    COPY_FP         ; duplicate

line 8695:
    ex de,hl        ; DE now points the duplication
        ex      de, hl          ; DE now points the duplication

line 8696:
    pop hl          ; HL now points 'X' again
        pop     hl              ; HL now points 'X' again

line 8698:
    call truncate       ; truncation towards zero
        call    truncate        ; truncation towards zero

line 8700:
    push hl         ; save pointer to the truncated 'X'
        push    hl              ; save pointer to the truncated 'X'

line 8701:
    push de         ; save pointer to the duplication
        push    de              ; save pointer to the duplication

line 8703:
    call comp_num       ; copmpare truncated 'X' to the duplication
        call    comp_num        ; copmpare truncated 'X' to the duplication

line 8705:
    pop de          ; DE now points end of the duplication
        pop     de              ; DE now points end of the duplication

line 8706:
    pop hl          ; HL now points 'X' again
        pop     hl              ; HL now points 'X' again

line 8708:
    ret z           ; return if 'X' was an integer or
        ret     z               ; return if 'X' was an integer or

line 8710:
    ret nc          ; return if 'X' was positive or zero
        ret     nc              ; return if 'X' was positive or zero

line 8722:
    push hl         ; save pointer to 'X'
        push    hl              ; save pointer to 'X'

line 8724:
    ld a,$01        ; stack 'ONE'
        ld      a, $01          ; stack 'ONE'

line 8725:
    call stk_con_x      ;
        call    stk_con_x       ;

line 8727:
    ex de,hl        ; DE now points 'ONE'
        ex      de, hl          ; DE now points 'ONE'

line 8728:
    pop hl          ; HL now points 'X' again
        pop     hl              ; HL now points 'X' again

line 8730:
    jp subtract     ; return w. X=X-1
        jp      subtract        ; return w. X=X-1

line 8773:
    ld a,(hl)       ; Fetch exponent to A.
        ld      a, (hl)         ; Fetch exponent to A.

line 8774:
    and a           ; Test for zero argument
        and     a               ; Test for zero argument

line 8775:
    jr z,REPORT_A       ; if =0 then REPORT_A: 'Invalid argument'
        jr      z, REPORT_A     ; if =0 then REPORT_A: 'Invalid argument'

line 8777:
    LD (HL),$80     ; Insert 'plus zero' as exponent.
        ld      (hl), $80       ; Insert 'plus zero' as exponent.

line 8779:
    inc hl          ; Address byte with sign bit.
        inc     hl              ; Address byte with sign bit.

line 8780:
    bit 7,(hl)      ; Test the bit.
        bit     7, (hl)         ; Test the bit.

line 8781:
    jr nz,REPORT_A      ; if <0 then REPORT_A: 'Invalid argument'
        jr      nz, REPORT_A    ; if <0 then REPORT_A: 'Invalid argument'

line 8784:
    CALL STACK_A        ; routine STACK-A stacks true binary exponent.
        call    STACK_A         ; routine STACK-A stacks true binary exponent.

line 8786:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 8787:
    DEFB $30    ;;stk-data
        defb    $30             ;;stk-data

line 8788:
    DEFB $38    ;;Exponent: $88, Bytes: 1
        defb    $38             ;;Exponent: $88, Bytes: 1

line 8789:
    DEFB $00    ;;(+00,+00,+00)
        defb    $00             ;;(+00,+00,+00)

line 8790:
    DEFB $03    ;;subtract
        defb    $03             ;;subtract

line 8791:
    DEFB $01    ;;exchange
        defb    $01             ;;exchange

line 8792:
    DEFB $2D    ;;duplicate
        defb    $2D             ;;duplicate

line 8793:
    DEFB $30    ;;stk-data
        defb    $30             ;;stk-data

line 8794:
    DEFB $F0    ;;Exponent: $80, Bytes: 4
        defb    $F0             ;;Exponent: $80, Bytes: 4

line 8795:
    DEFB $4C,$CC,$CC,$CD ;;
        defb    $4C, $CC, $CC, $CD
                                ;;

line 8796:
    DEFB $03    ;;subtract
        defb    $03             ;;subtract

line 8798:
    DEFB $33    ;;greater-0
        defb    $33             ;;greater-0

line 8799:
    DEFB $00    ;;jump-true
        defb    $00             ;;jump-true

line 8800:
    DEFB GRE_8-$    ;;to GRE_8
        defb    GRE_8-$         ;;to GRE_8

line 8802:
    DEFB $01    ;;exchange
        defb    $01             ;;exchange

line 8804:
    .db $39     ;;sub-one macro
        .db $39                 ;;sub-one macro

line 8806:
    DEFB $01    ;;exchange
        defb    $01             ;;exchange

line 8808:
    .db $3A     ;;mul-by-2          *2
        .db $3A                 ;;mul-by-2          *2

line 8810:
    DEFB $01    ;;exchange
        defb    $01             ;;exchange

line 8811:
    DEFB $30    ;;stk-data          LN 2
        defb    $30             ;;stk-data          LN 2

line 8812:
    DEFB $F0    ;;Exponent: $80, Bytes: 4
        defb    $F0             ;;Exponent: $80, Bytes: 4

line 8813:
    DEFB $31,$72,$17,$F8 ;;
        defb    $31, $72, $17, $F8
                                ;;

line 8814:
    DEFB $04    ;;multiply
        defb    $04             ;;multiply

line 8815:
    DEFB $01    ;;exchange
        defb    $01             ;;exchange

line 8817:
    .db $39      ;;sub-one macro
        .db $39                 ;;sub-one macro

line 8819:
    DEFB $2D    ;;duplicate
        defb    $2D             ;;duplicate

line 8820:
    DEFB $30    ;;stk-data
        defb    $30             ;;stk-data

line 8821:
    DEFB $32    ;;Exponent: $82, Bytes: 1
        defb    $32             ;;Exponent: $82, Bytes: 1

line 8822:
    DEFB $20    ;;(+00,+00,+00)
        defb    $20             ;;(+00,+00,+00)

line 8823:
    DEFB $04    ;;multiply
        defb    $04             ;;multiply

line 8824:
    DEFB $A2    ;;stk-half
        defb    $A2             ;;stk-half

line 8825:
    DEFB $03    ;;subtract
        defb    $03             ;;subtract

line 8826:
    DEFB $8C    ;;series-0C
        defb    $8C             ;;series-0C

line 8827:
    DEFB $11    ;;Exponent: $61, Bytes: 1
        defb    $11             ;;Exponent: $61, Bytes: 1

line 8828:
    DEFB $AC    ;;(+00,+00,+00)
        defb    $AC             ;;(+00,+00,+00)

line 8829:
    DEFB $14    ;;Exponent: $64, Bytes: 1
        defb    $14             ;;Exponent: $64, Bytes: 1

line 8830:
    DEFB $09    ;;(+00,+00,+00)
        defb    $09             ;;(+00,+00,+00)

line 8831:
    DEFB $56    ;;Exponent: $66, Bytes: 2
        defb    $56             ;;Exponent: $66, Bytes: 2

line 8832:
    DEFB $DA,$A5    ;;(+00,+00)
        defb    $DA, $A5        ;;(+00,+00)

line 8833:
    DEFB $59    ;;Exponent: $69, Bytes: 2
        defb    $59             ;;Exponent: $69, Bytes: 2

line 8834:
    DEFB $30,$C5    ;;(+00,+00)
        defb    $30, $C5        ;;(+00,+00)

line 8835:
    DEFB $5C    ;;Exponent: $6C, Bytes: 2
        defb    $5C             ;;Exponent: $6C, Bytes: 2

line 8836:
    DEFB $90,$AA    ;;(+00,+00)
        defb    $90, $AA        ;;(+00,+00)

line 8837:
    DEFB $9E    ;;Exponent: $6E, Bytes: 3
        defb    $9E             ;;Exponent: $6E, Bytes: 3

line 8838:
    DEFB $70,$6F,$61 ;;(+00)
        defb    $70, $6F, $61   ;;(+00)

line 8839:
    DEFB $A1    ;;Exponent: $71, Bytes: 3
        defb    $A1             ;;Exponent: $71, Bytes: 3

line 8840:
    DEFB $CB,$DA,$96 ;;(+00)
        defb    $CB, $DA, $96   ;;(+00)

line 8841:
    DEFB $A4    ;;Exponent: $74, Bytes: 3
        defb    $A4             ;;Exponent: $74, Bytes: 3

line 8842:
    DEFB $31,$9F,$B4 ;;(+00)
        defb    $31, $9F, $B4   ;;(+00)

line 8843:
    DEFB $E7    ;;Exponent: $77, Bytes: 4
        defb    $E7             ;;Exponent: $77, Bytes: 4

line 8844:
    DEFB $A0,$FE,$5C,$FC ;;
        defb    $A0, $FE, $5C, $FC
                                ;;

line 8845:
    DEFB $EA    ;;Exponent: $7A, Bytes: 4
        defb    $EA             ;;Exponent: $7A, Bytes: 4

line 8846:
    DEFB $1B,$43,$CA,$36 ;;
        defb    $1B, $43, $CA, $36
                                ;;

line 8847:
    DEFB $ED    ;;Exponent: $7D, Bytes: 4
        defb    $ED             ;;Exponent: $7D, Bytes: 4

line 8848:
    DEFB $A7,$9C,$7E,$5E ;;
        defb    $A7, $9C, $7E, $5E
                                ;;

line 8849:
    DEFB $F0    ;;Exponent: $80, Bytes: 4
        defb    $F0             ;;Exponent: $80, Bytes: 4

line 8850:
    DEFB $6E,$23,$80,$93 ;;
        defb    $6E, $23, $80, $93
                                ;;

line 8852:
    DEFB $04    ;;multiply
        defb    $04             ;;multiply

line 8853:
    DEFB $0F    ;;addition
        defb    $0F             ;;addition

line 8854:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 8856:
    RET         ; return.
        ret                     ; return.

line 8864:
    RST 08H         ; ERROR-1
        rst     08H             ; ERROR-1

line 8865:
    DEFB $09        ; Error Report: Invalid argument
        defb    $09             ; Error Report: Invalid argument

line 8881:
    RST 28H     ;; FP-CALC          n
        rst     28H             ;; FP-CALC          n

line 8882:
    .db $C3     ;; st-mem-3 (store in mem-3)    n
        .db $C3                 ;; st-mem-3 (store in mem-3)    n

line 8883:
    .db $34     ;; end_calc (exit calculator)   n
        .db $34                 ;; end_calc (exit calculator)   n

line 8885:
    ld a,(hl)       ;  exponent to A
        ld      a, (hl)         ;  exponent to A

line 8886:
    and a           ;  test against zero
        and     a               ;  test against zero

line 8887:
    ret z           ;  return if so
        ret     z               ;  return if so

line 8889:
    add a,$80       ;  set carry if greater or equal to 128
        add     a, $80          ;  set carry if greater or equal to 128

line 8890:
    rra         ;  divide by two
        rra                     ;  divide by two

line 8891:
    ld (hl),a       ;  replace value
        ld      (hl), a         ;  replace value

line 8893:
    inc hl          ;  next location
        inc     hl              ;  next location

line 8894:
    ld a,(hl)       ;  get sign bit
        ld      a, (hl)         ;  get sign bit

line 8895:
    rla         ;  rotate left
        rla                     ;  rotate left

line 8896:
    jr c,REPORT_A       ;  error with negative number
        jr      c, REPORT_A     ;  error with negative number

line 8898:
    ld (hl),127     ;  mantissa starts at about one
        ld      (hl), 127       ;  mantissa starts at about one

line 8899:
    ld b,5          ;  set counter
        ld      b, 5            ;  set counter

line 8901:
    RST 28H     ;; FP-CALC          x
        rst     28H             ;; FP-CALC          x

line 8902:
    .db $2D     ;; duplicate            x, x
        .db $2D                 ;; duplicate            x, x

line 8903:
    .db $E3     ;; get_mem_3            x, x, n
        .db $E3                 ;; get_mem_3            x, x, n

line 8904:
    .db $01     ;; exchange         x, n, x
        .db $01                 ;; exchange         x, n, x

line 8905:
    .db $05     ;; division         x, n / x
        .db $05                 ;; division         x, n / x

line 8906:
    .db $0F     ;; addition         x + n / x
        .db $0F                 ;; addition         x + n / x

line 8907:
    .db $34     ;; end_calc (exit calculator)
        .db $34                 ;; end_calc (exit calculator)

line 8909:
    dec (hl)        ;  halve value
        dec     (hl)            ;  halve value

line 8910:
    djnz fn_sqr1        ;  loop until found
        djnz    fn_sqr1         ;  loop until found

line 8912:
    ret         ;  return with square root on stack
        ret                     ;  return with square root on stack

line 8917:
    ld hl,jp_DISP2      ; hook to DISPLAY-2
        ld      hl, jp_DISP2    ; hook to DISPLAY-2

line 8918:
    inc bc          ; set counter
        inc     bc              ; set counter

line 8919:
    ld ($4034),bc       ; set FRAMES
        ld      ($4034), bc     ; set FRAMES

line 8920:
    ret nz          ; flicker free PAUSE (in SLOW mode)
        ret     nz              ; flicker free PAUSE (in SLOW mode)

line 8922:
    jp L0229        ; DISPLAY-1 (in FAST mode)
        jp      L0229           ; DISPLAY-1 (in FAST mode)

line 8952:
    RST 28H     ;; FP-CALC      angle in radians
        rst     28H             ;; FP-CALC      angle in radians

line 8953:
    .db $A2     ;;stk-half          X, 0.5 (offset: halfPI / PI)
        .db $A2                 ;;stk-half          X, 0.5 (offset: halfPI / PI)

line 8955:
    .db $2F     ;;jump
        .db $2F                 ;;jump

line 8956:
    .db cos_entr-$  ;;to cos_entr       continue as SINE function
        .db cos_entr-$          ;;to cos_entr       continue as SINE function

line 9012:
    RST 28H     ;; FP-CALC      angle in radians
        rst     28H             ;; FP-CALC      angle in radians

line 9013:
    .db $A0     ;;stk-zero          X, 0.    (offset)
        .db $A0                 ;;stk-zero          X, 0.    (offset)

line 9015:
    .db $01     ;;exchange      ofs, X.
        .db $01                 ;;exchange      ofs, X.

line 9017:
    DEFB $30    ;;stk-data
        defb    $30             ;;stk-data

line 9018:
    DEFB $EE    ;;Exponent: $7E, Bytes: 4
        defb    $EE             ;;Exponent: $7E, Bytes: 4

line 9019:
    DEFB $22,$F9,$83,$6E ;;         ofs, X, 1/(2*PI)
        defb    $22, $F9, $83, $6E
                                ;;         ofs, X, 1/(2*PI)

line 9020:
    DEFB $04    ;;multiply      ofs, X/(2*PI) = fraction
        defb    $04             ;;multiply      ofs, X/(2*PI) = fraction

line 9022:
    DEFB $2D    ;;duplicate         ofs, fraction, fraction
        defb    $2D             ;;duplicate         ofs, fraction, fraction

line 9023:
    DEFB $A2    ;;stk-half          ofs, fraction, fraction, 0.5
        defb    $A2             ;;stk-half          ofs, fraction, fraction, 0.5

line 9024:
    DEFB $0F    ;;addition          ofs, fraction, fraction + 0.5
        defb    $0F             ;;addition          ofs, fraction, fraction + 0.5

line 9025:
    DEFB $24    ;;int           ofs, fraction, int(fraction+0.5)
        defb    $24             ;;int           ofs, fraction, int(fraction+0.5)

line 9027:
    DEFB $03    ;;subtract      ofs, now range -.5 to .5
        defb    $03             ;;subtract      ofs, now range -.5 to .5

line 9029:
    .db $3A     ;;mul-by-2      ofs, now range -1 to 1.
        .db $3A                 ;;mul-by-2      ofs, now range -1 to 1.

line 9030:
    .db $0F     ;;addition      ofs + range (-1 to 1).
        .db $0F                 ;;addition      ofs + range (-1 to 1).

line 9032:
    .db $2D     ;;duplicate     ofs_rng, ofs_rng
        .db $2D                 ;;duplicate     ofs_rng, ofs_rng

line 9033:
    .db $39     ;;sub-one macro     ofs_rng, ofs_rng-1.
        .db $39                 ;;sub-one macro     ofs_rng, ofs_rng-1.

line 9035:
    .db $2D     ;;duplicate     ofs_rng, ofs_rng-1, ofs_rng-1.
        .db $2D                 ;;duplicate     ofs_rng, ofs_rng-1, ofs_rng-1.

line 9036:
    .db $32     ;;less-0        ofs_rng, ofs_rng-1, 0/1.
        .db $32                 ;;less-0        ofs_rng, ofs_rng-1, 0/1.

line 9037:
    .db $00     ;;jump-true
        .db $00                 ;;jump-true

line 9038:
    .db no_qchg-$   ;;to no_qchg
        .db no_qchg-$           ;;to no_qchg

line 9040:
    .db $39     ;;sub-one macro     ofs_rng, ofs_rng-2.
        .db $39                 ;;sub-one macro     ofs_rng, ofs_rng-2.

line 9041:
    .db $01     ;;exchange      ofs_rng-2, ofs_rng.
        .db $01                 ;;exchange      ofs_rng-2, ofs_rng.

line 9043:
    .db $02     ;;delete        delete test value.
        .db $02                 ;;delete        delete test value.

line 9044:
    .db $3A     ;;mul-by-2      now range -2 to 2.
        .db $3A                 ;;mul-by-2      now range -2 to 2.

line 9050:
    DEFB $2D    ;;duplicate     Y, Y.
        defb    $2D             ;;duplicate     Y, Y.

line 9051:
    DEFB $27    ;;abs           Y, abs(Y).    range 1 to 2
        defb    $27             ;;abs           Y, abs(Y).    range 1 to 2

line 9053:
    .db $39     ;;sub-one macro     Y, abs(Y)-1.  range 0 to 1
        .db $39                 ;;sub-one macro     Y, abs(Y)-1.  range 0 to 1

line 9055:
    DEFB $2D    ;;duplicate     Y, Z, Z.
        defb    $2D             ;;duplicate     Y, Z, Z.

line 9057:
    DEFB $33    ;;greater-0     Y, Z, (1/0).
        defb    $33             ;;greater-0     Y, Z, (1/0).

line 9058:
    DEFB $00    ;;jump-true
        defb    $00             ;;jump-true

line 9059:
    DEFB ZPLUS-$    ;;to ZPLUS with quadrants II and III
        defb    ZPLUS-$         ;;to ZPLUS with quadrants II and III

line 9063:
    DEFB $02    ;;delete        Y   delete test value.
        defb    $02             ;;delete        Y   delete test value.

line 9065:
    .db $2F     ;;jump
        .db $2F                 ;;jump

line 9066:
    .db YNEG-$  ;;to YNEG       Y.  with Q1 and Q4 >>>
        .db YNEG-$              ;;to YNEG       Y.  with Q1 and Q4 >>>

line 9072:
    .db $39     ;;sub-one macro     Y, Z-1.  Q3 = 0 to -1
        .db $39                 ;;sub-one macro     Y, Z-1.  Q3 = 0 to -1

line 9074:
    DEFB $01    ;;exchange      Z-1, Y.
        defb    $01             ;;exchange      Z-1, Y.

line 9076:
    DEFB $32    ;;less-0        Z-1, (1/0).
        defb    $32             ;;less-0        Z-1, (1/0).

line 9077:
    DEFB $00    ;;jump-true     Z-1.
        defb    $00             ;;jump-true     Z-1.

line 9078:
    DEFB YNEG-$ ;;to YNEG       if angle in quadrant III
        defb    YNEG-$          ;;to YNEG       if angle in quadrant III

line 9082:
    DEFB $18    ;;negate        range +1 to 0
        defb    $18             ;;negate        range +1 to 0

line 9086:
    .db $3C     ;;stk-square        x, x*x.
        .db $3C                 ;;stk-square        x, x*x.

line 9087:
    .db $3A     ;;mul-by-2      x, 2*x*x.
        .db $3A                 ;;mul-by-2      x, 2*x*x.

line 9088:
    .db $39     ;;sub-one macro     x, 2*x*x-1
        .db $39                 ;;sub-one macro     x, 2*x*x-1

line 9090:
    DEFB $86    ;;series-06
        defb    $86             ;;series-06

line 9091:
    DEFB $14    ;;Exponent: $64, Bytes: 1
        defb    $14             ;;Exponent: $64, Bytes: 1

line 9092:
    DEFB $E6    ;;(+00,+00,+00)
        defb    $E6             ;;(+00,+00,+00)

line 9093:
    DEFB $5C    ;;Exponent: $6C, Bytes: 2
        defb    $5C             ;;Exponent: $6C, Bytes: 2

line 9094:
    DEFB $1F,$0B    ;;(+00,+00)
        defb    $1F, $0B        ;;(+00,+00)

line 9095:
    DEFB $A3    ;;Exponent: $73, Bytes: 3
        defb    $A3             ;;Exponent: $73, Bytes: 3

line 9096:
    DEFB $8F,$38,$EE ;;(+00)
        defb    $8F, $38, $EE   ;;(+00)

line 9097:
    DEFB $E9    ;;Exponent: $79, Bytes: 4
        defb    $E9             ;;Exponent: $79, Bytes: 4

line 9098:
    DEFB $15,$63,$BB,$23 ;;
        defb    $15, $63, $BB, $23
                                ;;

line 9099:
    DEFB $EE    ;;Exponent: $7E, Bytes: 4
        defb    $EE             ;;Exponent: $7E, Bytes: 4

line 9100:
    DEFB $92,$0D,$CD,$ED ;;
        defb    $92, $0D, $CD, $ED
                                ;;

line 9101:
    DEFB $F1    ;;Exponent: $81, Bytes: 4
        defb    $F1             ;;Exponent: $81, Bytes: 4

line 9102:
    DEFB $23,$5D,$1B,$EA ;;
        defb    $23, $5D, $1B, $EA
                                ;;

line 9104:
    DEFB $04    ;;multiply      x*series_06
        defb    $04             ;;multiply      x*series_06

line 9105:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 9115:
    RET     ; return.
        ret                     ; return.

line 9141:
    RST 28H     ;; FP-CALC      x.
        rst     28H             ;; FP-CALC      x.

line 9142:
    DEFB $2D    ;;duplicate     x, x.
        defb    $2D             ;;duplicate     x, x.

line 9143:
    DEFB $1C    ;;sin           x, sin x.
        defb    $1C             ;;sin           x, sin x.

line 9144:
    DEFB $01    ;;exchange      sin x, x.
        defb    $01             ;;exchange      sin x, x.

line 9145:
    DEFB $1D    ;;cos           sin x, cos x.
        defb    $1D             ;;cos           sin x, cos x.

line 9146:
    DEFB $05    ;;division      sin x/cos x (= tan x).
        defb    $05             ;;division      sin x/cos x (= tan x).

line 9147:
    DEFB $34    ;;end-calc      tan x.
        defb    $34             ;;end-calc      tan x.

line 9149:
    RET         ; return.
        ret                     ; return.

line 9161:
    LD A,(HL)       ; fetch exponent
        ld      a, (hl)         ; fetch exponent

line 9162:
    CP $81          ; compare to that for 'one'
        cp      $81             ; compare to that for 'one'

line 9163:
    JR C,SMALL      ; forward, if less, to SMALL
        jr      c, SMALL        ; forward, if less, to SMALL

line 9165:
    RST 28H     ;; FP-CALC      X.
        rst     28H             ;; FP-CALC      X.

line 9166:
    DEFB $A1    ;;stk-one       X, 1.
        defb    $A1             ;;stk-one       X, 1.

line 9167:
    DEFB $18    ;;negate        X, -1.
        defb    $18             ;;negate        X, -1.

line 9168:
    DEFB $01    ;;exchange      -1, X.
        defb    $01             ;;exchange      -1, X.

line 9169:
    DEFB $05    ;;division      -1/X.
        defb    $05             ;;division      -1/X.

line 9170:
    DEFB $2D    ;;duplicate     -1/X, -1/X.
        defb    $2D             ;;duplicate     -1/X, -1/X.

line 9172:
    .db $A3     ;;stk-pi/2      -1/X, -1/X, PI/2.
        .db $A3                 ;;stk-pi/2      -1/X, -1/X, PI/2.

line 9173:
    .db $01     ;;exchange      -1/X, PI/2, -1/X.
        .db $01                 ;;exchange      -1/X, PI/2, -1/X.

line 9175:
    .db $32     ;;less-0        -1/X, PI/2, (1/0).
        .db $32                 ;;less-0        -1/X, PI/2, (1/0).

line 9176:
    DEFB $00    ;;jump-true
        defb    $00             ;;jump-true

line 9177:
    DEFB CASES-$    ;;to CASES      -1/X, PI/2.
        defb    CASES-$         ;;to CASES      -1/X, PI/2.

line 9179:
    DEFB $18    ;;negate        -1/X, -PI/2.
        defb    $18             ;;negate        -1/X, -PI/2.

line 9180:
    DEFB $2F    ;;jump
        defb    $2F             ;;jump

line 9181:
    DEFB CASES-$    ;;to CASES
        defb    CASES-$         ;;to CASES

line 9185:
    RST 28H     ;; FP-CALC
        rst     28H             ;; FP-CALC

line 9186:
    DEFB $A0    ;;stk-zero
        defb    $A0             ;;stk-zero

line 9188:
    DEFB $01    ;;exchange
        defb    $01             ;;exchange

line 9190:
    .db $3C     ;;stk-square        x, x*x.
        .db $3C                 ;;stk-square        x, x*x.

line 9191:
    .db $3A     ;;mul-by-2      x, 2*x*x.
        .db $3A                 ;;mul-by-2      x, 2*x*x.

line 9192:
    .db $39     ;;sub-one macro     x, 2*x*x-1.
        .db $39                 ;;sub-one macro     x, 2*x*x-1.

line 9194:
    DEFB $8C    ;;series-0C
        defb    $8C             ;;series-0C

line 9195:
    DEFB $10    ;;Exponent: $60, Bytes: 1
        defb    $10             ;;Exponent: $60, Bytes: 1

line 9196:
    DEFB $B2    ;;(+00,+00,+00)
        defb    $B2             ;;(+00,+00,+00)

line 9197:
    DEFB $13    ;;Exponent: $63, Bytes: 1
        defb    $13             ;;Exponent: $63, Bytes: 1

line 9198:
    DEFB $0E    ;;(+00,+00,+00)
        defb    $0E             ;;(+00,+00,+00)

line 9199:
    DEFB $55    ;;Exponent: $65, Bytes: 2
        defb    $55             ;;Exponent: $65, Bytes: 2

line 9200:
    DEFB $E4,$8D    ;;(+00,+00)
        defb    $E4, $8D        ;;(+00,+00)

line 9201:
    DEFB $58    ;;Exponent: $68, Bytes: 2
        defb    $58             ;;Exponent: $68, Bytes: 2

line 9202:
    DEFB $39,$BC    ;;(+00,+00)
        defb    $39, $bc        ;;(+00,+00)

line 9203:
    DEFB $5B    ;;Exponent: $6B, Bytes: 2
        defb    $5B             ;;Exponent: $6B, Bytes: 2

line 9204:
    DEFB $98,$FD    ;;(+00,+00)
        defb    $98, $FD        ;;(+00,+00)

line 9205:
    DEFB $9E    ;;Exponent: $6E, Bytes: 3
        defb    $9E             ;;Exponent: $6E, Bytes: 3

line 9206:
    DEFB $00,$36,$75 ;;(+00)
        defb    $00, $36, $75   ;;(+00)

line 9207:
    DEFB $A0    ;;Exponent: $70, Bytes: 3
        defb    $A0             ;;Exponent: $70, Bytes: 3

line 9208:
    DEFB $DB,$E8,$B4 ;;(+00)
        defb    $DB, $E8, $B4   ;;(+00)

line 9209:
    DEFB $63    ;;Exponent: $73, Bytes: 2
        defb    $63             ;;Exponent: $73, Bytes: 2

line 9210:
    DEFB $42,$C4    ;;(+00,+00)
        defb    $42, $C4        ;;(+00,+00)

line 9211:
    DEFB $E6    ;;Exponent: $76, Bytes: 4
        defb    $E6             ;;Exponent: $76, Bytes: 4

line 9212:
    DEFB $B5,$09,$36,$BE ;;
        defb    $B5, $09, $36, $BE
                                ;;

line 9213:
    DEFB $E9    ;;Exponent: $79, Bytes: 4
        defb    $E9             ;;Exponent: $79, Bytes: 4

line 9214:
    DEFB $36,$73,$1B,$5D ;;
        defb    $36, $73, $1B, $5D
                                ;;

line 9215:
    DEFB $EC    ;;Exponent: $7C, Bytes: 4
        defb    $EC             ;;Exponent: $7C, Bytes: 4

line 9216:
    DEFB $D8,$DE,$63,$BE ;;
        defb    $D8, $de, $63, $BE
                                ;;

line 9217:
    DEFB $F0    ;;Exponent: $80, Bytes: 4
        defb    $F0             ;;Exponent: $80, Bytes: 4

line 9218:
    DEFB $61,$A1,$B3,$0C ;;
        defb    $61, $A1, $B3, $0C
                                ;;

line 9220:
    DEFB $04    ;;multiply
        defb    $04             ;;multiply

line 9221:
    DEFB $0F    ;;addition
        defb    $0F             ;;addition

line 9222:
    DEFB $34    ;;end-calc
        defb    $34             ;;end-calc

line 9224:
    RET         ; return.
        ret                     ; return.

line 9274:
    RST 28H     ;; FP-CALC      x.
        rst     28H             ;; FP-CALC      x.

line 9276:
    .db $3C     ;;stk-square        x, x*x.
        .db $3C                 ;;stk-square        x, x*x.

line 9277:
    .db $39     ;;sub-one macro     x, x*x-1.
        .db $39                 ;;sub-one macro     x, x*x-1.

line 9279:
    DEFB $18    ;;negate        x, 1-x*x.
        defb    $18             ;;negate        x, 1-x*x.

line 9280:
    DEFB $25    ;;sqr           x, sqr(1-x*x) = y.
        defb    $25             ;;sqr           x, sqr(1-x*x) = y.

line 9281:
    DEFB $A1    ;;stk-one       x, y, 1.
        defb    $A1             ;;stk-one       x, y, 1.

line 9282:
    DEFB $0F    ;;addition      x, y+1.
        defb    $0F             ;;addition      x, y+1.

line 9283:
    DEFB $05    ;;division      x/(y+1).
        defb    $05             ;;division      x/(y+1).

line 9284:
    DEFB $21    ;;atn           a/2 (half the angle)
        defb    $21             ;;atn           a/2 (half the angle)

line 9285:
    DEFB $34    ;;end-calc      return via mul-by-2:  a=2*a/2.
        defb    $34             ;;end-calc      return via mul-by-2:  a=2*a/2.

line 9297:
    ld a,(hl)       ; test exponent
        ld      a, (hl)         ; test exponent

line 9298:
    and a           ; >0?
        and     a               ; >0?

line 9299:
    ret z           ; return if it is zero (2*0=0!)
        ret     z               ; return if it is zero (2*0=0!)

line 9301:
    inc (hl)        ; else increase the exponent (*2)
        inc     (hl)            ; else increase the exponent (*2)

line 9302:
    ret nz          ; return if no overflow occurred
        ret     nz              ; return if no overflow occurred

line 9304:
    rst 08h         ; Error Report:
        rst     08h             ; Error Report:

line 9305:
    .db $05         ; Number is too big
        .db $05                 ; Number is too big

line 9333:
fn_acs  RST 28H     ;; FP-CALC      x.
fn_acs  rst 28H                 ;; FP-CALC      x.

line 9335:
    DEFB $1F    ;;asn           asn(x).
        defb    $1F             ;;asn           asn(x).

line 9336:
    DEFB $A3    ;;stk-pi/2      asn(x), pi/2.
        defb    $A3             ;;stk-pi/2      asn(x), pi/2.

line 9337:
    DEFB $03    ;;subtract      asn(x) - pi/2.
        defb    $03             ;;subtract      asn(x) - pi/2.

line 9338:
    DEFB $18    ;;negate        pi/2 - asn(x) = acs(x).
        defb    $18             ;;negate        pi/2 - asn(x) = acs(x).

line 9339:
    DEFB $34    ;;end-calc      acs(x)
        defb    $34             ;;end-calc      acs(x)

line 9341:
    RET         ; return.
        ret                     ; return.

line 9351:
    POP AF          ; drop return address.
        pop     af              ; drop return address.

line 9352:
    LD A,($401E)        ; load accumulator from system variable BREG
        ld      a, ($401E)      ; load accumulator from system variable BREG

line 9353:
                ; value will be literal eg. 'tan'
                                ; value will be literal eg. 'tan'

line 9354:
    EXX         ; switch to alt
        exx                     ; switch to alt

line 9356:
    jp SCAN_ENT     ; back to SCAN-ENT
        jp      SCAN_ENT        ; back to SCAN-ENT

line 9357:
                ; next literal will be end-calc in scanning
                                ; next literal will be end-calc in scanning

line 9368:
    LD C,A          ; store the original number $00-$1F.
        ld      c, a            ; store the original number $00-$1F.

line 9369:
    RLCA            ; double.
        rlca                    ; double.

line 9370:
    RLCA            ; quadruple.
        rlca                    ; quadruple.

line 9371:
    ADD A,C         ; now add original value to multiply by five.
        add     a, c            ; now add original value to multiply by five.

line 9373:
    LD C,A          ; place the result in C.
        ld      c, a            ; place the result in C.

line 9374:
    LD B,$00        ; set B to 0.
        ld      b, $00          ; set B to 0.

line 9375:
    ADD HL,BC       ; add to form address of start of number in HL.
        add     hl, bc          ; add to form address of start of number in HL.

line 9376:
    RET         ; return.
        ret                     ; return.

line 9386:
    call mul_by_2       ; x1 = x*2  (tests overflow)
        call    mul_by_2        ; x1 = x*2  (tests overflow)

line 9387:
    ret z           ; return if it is zero (2*0=0!)
        ret     z               ; return if it is zero (2*0=0!)

line 9389:
    push hl         ; save OP1 pointer
        push    hl              ; save OP1 pointer

line 9390:
    call COPY_FP        ; duplicate
        call    COPY_FP         ; duplicate

line 9392:
    inc (hl)        ; increase the exponent (4*x)
        inc     (hl)            ; increase the exponent (4*x)

line 9393:
    jr z,mul2_ovf       ; if overflow occurred
        jr      z, mul2_ovf     ; if overflow occurred

line 9395:
    inc (hl)        ; increase the exponent (8*x)
        inc     (hl)            ; increase the exponent (8*x)

line 9396:
    jr z,mul2_ovf       ; if overflow occurred
        jr      z, mul2_ovf     ; if overflow occurred

line 9398:
    ex de,hl        ; de: OP2 pointer
        ex      de, hl          ; de: OP2 pointer

line 9399:
    pop hl          ; hl: OP1 pointer
        pop     hl              ; hl: OP1 pointer

line 9400:
    jp addition     ; routine addition (L1755)
        jp      addition        ; routine addition (L1755)

line 9401:
                ; y = 2*x + 8*x    (=10*x)
                                ; y = 2*x + 8*x    (=10*x)

line 9414:
    call COPY_FP        ; duplicate
        call    COPY_FP         ; duplicate

line 9416:
    push de         ; save stack end
        push    de              ; save stack end

line 9417:
    ld d,h          ; set pointer to
        ld      d, h            ; set pointer to

line 9418:
    ld e,l          ; last value on stack
        ld      e, l            ; last value on stack

line 9419:
    call multiply       ; multiplication
        call    multiply        ; multiplication

line 9421:
    pop de          ; restore pointer
        pop     de              ; restore pointer

line 9422:
    ret         ; return w. square
        ret                     ; return w. square

line 9428:
    ld hl,($400C)       ; HL points the beginning of the D-File
        ld      hl, ($400C)     ; HL points the beginning of the D-File

line 9429:
    bit 5,(IY+$3B)      ; sv CDFLAG - test expanded display file
        bit     5, (iy+$3B)     ; sv CDFLAG - test expanded display file

line 9430:
    ret z           ; return if not
        ret     z               ; return if not

line 9432:
    pop de          ; else drop return address
        pop     de              ; else drop return address

line 9433:
    ld de,33        ; size of a complete line in bytes
        ld      de, 33          ; size of a complete line in bytes

line 9434:
    jr add_33b      ; skip the 1st addition
        jr      add_33b         ; skip the 1st addition

line 9436:
    add hl,de       ; set pointer to the next line
        add     hl, de          ; set pointer to the next line

line 9438:
    djnz add_33a        ; back if the line counter is nonzero
        djnz    add_33a         ; back if the line counter is nonzero

line 9440:
    add hl,bc       ; add value of the X coordinate
        add     hl, bc          ; add value of the X coordinate

line 9441:
    jp set_DFCC     ; jump back to the caller
        jp      set_DFCC        ; jump back to the caller

line 9446:
plot_ext            ; must be inverted?
plot_ext                        ; must be inverted?

line 9447:
    jr c,plot_end       ; forward to PLOT-END, if not
        jr      c, plot_end     ; forward to PLOT-END, if not

line 9449:
    xor $8F         ; swap the necessary bits
        xor     $8F             ; swap the necessary bits

line 9453:
    bit 5,(iy+$3B)      ; sv CDFLAG - test expanded D-FILE
        bit     5, (iy+$3B)     ; sv CDFLAG - test expanded D-FILE

line 9454:
    jp z,L07EE      ; if not, then return via OUT-CH
        jp      z, L07EE        ; if not, then return via OUT-CH

line 9456:
    ld (hl),a       ; else write D-File immediate
        ld      (hl), a         ; else write D-File immediate

line 9457:
    ret             ; and return
        ret                     ; and return

line 9471:
L1E00:  DEFB    %00000000
L1E00:  defb    %00000000

line 9472:
    DEFB    %00000000
        defb    %00000000

line 9473:
    DEFB    %00000000
        defb    %00000000

line 9474:
    DEFB    %00000000
        defb    %00000000

line 9475:
    DEFB    %00000000
        defb    %00000000

line 9476:
    DEFB    %00000000
        defb    %00000000

line 9477:
    DEFB    %00000000
        defb    %00000000

line 9478:
    DEFB    %00000000
        defb    %00000000

line 9482:
    DEFB    %11110000
        defb    %11110000

line 9483:
    DEFB    %11110000
        defb    %11110000

line 9484:
    DEFB    %11110000
        defb    %11110000

line 9485:
    DEFB    %11110000
        defb    %11110000

line 9486:
    DEFB    %00000000
        defb    %00000000

line 9487:
    DEFB    %00000000
        defb    %00000000

line 9488:
    DEFB    %00000000
        defb    %00000000

line 9489:
    DEFB    %00000000
        defb    %00000000

line 9494:
    DEFB    %00001111
        defb    %00001111

line 9495:
    DEFB    %00001111
        defb    %00001111

line 9496:
    DEFB    %00001111
        defb    %00001111

line 9497:
    DEFB    %00001111
        defb    %00001111

line 9498:
    DEFB    %00000000
        defb    %00000000

line 9499:
    DEFB    %00000000
        defb    %00000000

line 9500:
    DEFB    %00000000
        defb    %00000000

line 9501:
    DEFB    %00000000
        defb    %00000000

line 9506:
    DEFB    %11111111
        defb    %11111111

line 9507:
    DEFB    %11111111
        defb    %11111111

line 9508:
    DEFB    %11111111
        defb    %11111111

line 9509:
    DEFB    %11111111
        defb    %11111111

line 9510:
    DEFB    %00000000
        defb    %00000000

line 9511:
    DEFB    %00000000
        defb    %00000000

line 9512:
    DEFB    %00000000
        defb    %00000000

line 9513:
    DEFB    %00000000
        defb    %00000000

line 9517:
    DEFB    %00000000
        defb    %00000000

line 9518:
    DEFB    %00000000
        defb    %00000000

line 9519:
    DEFB    %00000000
        defb    %00000000

line 9520:
    DEFB    %00000000
        defb    %00000000

line 9521:
    DEFB    %11110000
        defb    %11110000

line 9522:
    DEFB    %11110000
        defb    %11110000

line 9523:
    DEFB    %11110000
        defb    %11110000

line 9524:
    DEFB    %11110000
        defb    %11110000

line 9528:
    DEFB    %11110000
        defb    %11110000

line 9529:
    DEFB    %11110000
        defb    %11110000

line 9530:
    DEFB    %11110000
        defb    %11110000

line 9531:
    DEFB    %11110000
        defb    %11110000

line 9532:
    DEFB    %11110000
        defb    %11110000

line 9533:
    DEFB    %11110000
        defb    %11110000

line 9534:
    DEFB    %11110000
        defb    %11110000

line 9535:
    DEFB    %11110000
        defb    %11110000

line 9539:
    DEFB    %00001111
        defb    %00001111

line 9540:
    DEFB    %00001111
        defb    %00001111

line 9541:
    DEFB    %00001111
        defb    %00001111

line 9542:
    DEFB    %00001111
        defb    %00001111

line 9543:
    DEFB    %11110000
        defb    %11110000

line 9544:
    DEFB    %11110000
        defb    %11110000

line 9545:
    DEFB    %11110000
        defb    %11110000

line 9546:
    DEFB    %11110000
        defb    %11110000

line 9550:
    DEFB    %11111111
        defb    %11111111

line 9551:
    DEFB    %11111111
        defb    %11111111

line 9552:
    DEFB    %11111111
        defb    %11111111

line 9553:
    DEFB    %11111111
        defb    %11111111

line 9554:
    DEFB    %11110000
        defb    %11110000

line 9555:
    DEFB    %11110000
        defb    %11110000

line 9556:
    DEFB    %11110000
        defb    %11110000

line 9557:
    DEFB    %11110000
        defb    %11110000

line 9561:
    DEFB    %10101010
        defb    %10101010

line 9562:
    DEFB    %01010101
        defb    %01010101

line 9563:
    DEFB    %10101010
        defb    %10101010

line 9564:
    DEFB    %01010101
        defb    %01010101

line 9565:
    DEFB    %10101010
        defb    %10101010

line 9566:
    DEFB    %01010101
        defb    %01010101

line 9567:
    DEFB    %10101010
        defb    %10101010

line 9568:
    DEFB    %01010101
        defb    %01010101

line 9572:
    DEFB    %00000000
        defb    %00000000

line 9573:
    DEFB    %00000000
        defb    %00000000

line 9574:
    DEFB    %00000000
        defb    %00000000

line 9575:
    DEFB    %00000000
        defb    %00000000

line 9576:
    DEFB    %10101010
        defb    %10101010

line 9577:
    DEFB    %01010101
        defb    %01010101

line 9578:
    DEFB    %10101010
        defb    %10101010

line 9579:
    DEFB    %01010101
        defb    %01010101

line 9583:
    DEFB    %10101010
        defb    %10101010

line 9584:
    DEFB    %01010101
        defb    %01010101

line 9585:
    DEFB    %10101010
        defb    %10101010

line 9586:
    DEFB    %01010101
        defb    %01010101

line 9587:
    DEFB    %00000000
        defb    %00000000

line 9588:
    DEFB    %00000000
        defb    %00000000

line 9589:
    DEFB    %00000000
        defb    %00000000

line 9590:
    DEFB    %00000000
        defb    %00000000

line 9594:
    DEFB    %00000000
        defb    %00000000

line 9595:
    DEFB    %00100100
        defb    %00100100

line 9596:
    DEFB    %00100100
        defb    %00100100

line 9597:
    DEFB    %00000000
        defb    %00000000

line 9598:
    DEFB    %00000000
        defb    %00000000

line 9599:
    DEFB    %00000000
        defb    %00000000

line 9600:
    DEFB    %00000000
        defb    %00000000

line 9601:
    DEFB    %00000000
        defb    %00000000

line 9605:
    DEFB    %00000000
        defb    %00000000

line 9606:
    DEFB    %00011100
        defb    %00011100

line 9607:
    DEFB    %00100010
        defb    %00100010

line 9608:
    DEFB    %01111000
        defb    %01111000

line 9609:
    DEFB    %00100000
        defb    %00100000

line 9610:
    DEFB    %00100000
        defb    %00100000

line 9611:
    DEFB    %01111110
        defb    %01111110

line 9612:
    DEFB    %00000000
        defb    %00000000

line 9616:
    DEFB    %00000000
        defb    %00000000

line 9617:
    DEFB    %00001000
        defb    %00001000

line 9618:
    DEFB    %00111110
        defb    %00111110

line 9619:
    DEFB    %00101000
        defb    %00101000

line 9620:
    DEFB    %00111110
        defb    %00111110

line 9621:
    DEFB    %00001010
        defb    %00001010

line 9622:
    DEFB    %00111110
        defb    %00111110

line 9623:
    DEFB    %00001000
        defb    %00001000

line 9627:
    DEFB    %00000000
        defb    %00000000

line 9628:
    DEFB    %00000000
        defb    %00000000

line 9629:
    DEFB    %00000000
        defb    %00000000

line 9630:
    DEFB    %00010000
        defb    %00010000

line 9631:
    DEFB    %00000000
        defb    %00000000

line 9632:
    DEFB    %00000000
        defb    %00000000

line 9633:
    DEFB    %00010000
        defb    %00010000

line 9634:
    DEFB    %00000000
        defb    %00000000

line 9638:
    DEFB    %00000000
        defb    %00000000

line 9639:
    DEFB    %00111100
        defb    %00111100

line 9640:
    DEFB    %01000010
        defb    %01000010

line 9641:
    DEFB    %00000100
        defb    %00000100

line 9642:
    DEFB    %00001000
        defb    %00001000

line 9643:
    DEFB    %00000000
        defb    %00000000

line 9644:
    DEFB    %00001000
        defb    %00001000

line 9645:
    DEFB    %00000000
        defb    %00000000

line 9649:
    DEFB    %00000000
        defb    %00000000

line 9650:
    DEFB    %00000100
        defb    %00000100

line 9651:
    DEFB    %00001000
        defb    %00001000

line 9652:
    DEFB    %00001000
        defb    %00001000

line 9653:
    DEFB    %00001000
        defb    %00001000

line 9654:
    DEFB    %00001000
        defb    %00001000

line 9655:
    DEFB    %00000100
        defb    %00000100

line 9656:
    DEFB    %00000000
        defb    %00000000

line 9660:
    DEFB    %00000000
        defb    %00000000

line 9661:
    DEFB    %00100000
        defb    %00100000

line 9662:
    DEFB    %00010000
        defb    %00010000

line 9663:
    DEFB    %00010000
        defb    %00010000

line 9664:
    DEFB    %00010000
        defb    %00010000

line 9665:
    DEFB    %00010000
        defb    %00010000

line 9666:
    DEFB    %00100000
        defb    %00100000

line 9667:
    DEFB    %00000000
        defb    %00000000

line 9671:
    DEFB    %00000000
        defb    %00000000

line 9672:
    DEFB    %00000000
        defb    %00000000

line 9673:
    DEFB    %00010000
        defb    %00010000

line 9674:
    DEFB    %00001000
        defb    %00001000

line 9675:
    DEFB    %00000100
        defb    %00000100

line 9676:
    DEFB    %00001000
        defb    %00001000

line 9677:
    DEFB    %00010000
        defb    %00010000

line 9678:
    DEFB    %00000000
        defb    %00000000

line 9682:
    DEFB    %00000000
        defb    %00000000

line 9683:
    DEFB    %00000000
        defb    %00000000

line 9684:
    DEFB    %00000100
        defb    %00000100

line 9685:
    DEFB    %00001000
        defb    %00001000

line 9686:
    DEFB    %00010000
        defb    %00010000

line 9687:
    DEFB    %00001000
        defb    %00001000

line 9688:
    DEFB    %00000100
        defb    %00000100

line 9689:
    DEFB    %00000000
        defb    %00000000

line 9693:
    DEFB    %00000000
        defb    %00000000

line 9694:
    DEFB    %00000000
        defb    %00000000

line 9695:
    DEFB    %00000000
        defb    %00000000

line 9696:
    DEFB    %00111110
        defb    %00111110

line 9697:
    DEFB    %00000000
        defb    %00000000

line 9698:
    DEFB    %00111110
        defb    %00111110

line 9699:
    DEFB    %00000000
        defb    %00000000

line 9700:
    DEFB    %00000000
        defb    %00000000

line 9704:
    DEFB    %00000000
        defb    %00000000

line 9705:
    DEFB    %00000000
        defb    %00000000

line 9706:
    DEFB    %00001000
        defb    %00001000

line 9707:
    DEFB    %00001000
        defb    %00001000

line 9708:
    DEFB    %00111110
        defb    %00111110

line 9709:
    DEFB    %00001000
        defb    %00001000

line 9710:
    DEFB    %00001000
        defb    %00001000

line 9711:
    DEFB    %00000000
        defb    %00000000

line 9715:
    DEFB    %00000000
        defb    %00000000

line 9716:
    DEFB    %00000000
        defb    %00000000

line 9717:
    DEFB    %00000000
        defb    %00000000

line 9718:
    DEFB    %00000000
        defb    %00000000

line 9719:
    DEFB    %00111110
        defb    %00111110

line 9720:
    DEFB    %00000000
        defb    %00000000

line 9721:
    DEFB    %00000000
        defb    %00000000

line 9722:
    DEFB    %00000000
        defb    %00000000

line 9726:
    DEFB    %00000000
        defb    %00000000

line 9727:
    DEFB    %00000000
        defb    %00000000

line 9728:
    DEFB    %00010100
        defb    %00010100

line 9729:
    DEFB    %00001000
        defb    %00001000

line 9730:
    DEFB    %00111110
        defb    %00111110

line 9731:
    DEFB    %00001000
        defb    %00001000

line 9732:
    DEFB    %00010100
        defb    %00010100

line 9733:
    DEFB    %00000000
        defb    %00000000

line 9737:
    DEFB    %00000000
        defb    %00000000

line 9738:
    DEFB    %00000000
        defb    %00000000

line 9739:
    DEFB    %00000010
        defb    %00000010

line 9740:
    DEFB    %00000100
        defb    %00000100

line 9741:
    DEFB    %00001000
        defb    %00001000

line 9742:
    DEFB    %00010000
        defb    %00010000

line 9743:
    DEFB    %00100000
        defb    %00100000

line 9744:
    DEFB    %00000000
        defb    %00000000

line 9748:
    DEFB    %00000000
        defb    %00000000

line 9749:
    DEFB    %00000000
        defb    %00000000

line 9750:
    DEFB    %00010000
        defb    %00010000

line 9751:
    DEFB    %00000000
        defb    %00000000

line 9752:
    DEFB    %00000000
        defb    %00000000

line 9753:
    DEFB    %00010000
        defb    %00010000

line 9754:
    DEFB    %00010000
        defb    %00010000

line 9755:
    DEFB    %00100000
        defb    %00100000

line 9759:
    DEFB    %00000000
        defb    %00000000

line 9760:
    DEFB    %00000000
        defb    %00000000

line 9761:
    DEFB    %00000000
        defb    %00000000

line 9762:
    DEFB    %00000000
        defb    %00000000

line 9763:
    DEFB    %00000000
        defb    %00000000

line 9764:
    DEFB    %00001000
        defb    %00001000

line 9765:
    DEFB    %00001000
        defb    %00001000

line 9766:
    DEFB    %00010000
        defb    %00010000

line 9770:
    DEFB    %00000000
        defb    %00000000

line 9771:
    DEFB    %00000000
        defb    %00000000

line 9772:
    DEFB    %00000000
        defb    %00000000

line 9773:
    DEFB    %00000000
        defb    %00000000

line 9774:
    DEFB    %00000000
        defb    %00000000

line 9775:
    DEFB    %00011000
        defb    %00011000

line 9776:
    DEFB    %00011000
        defb    %00011000

line 9777:
    DEFB    %00000000
        defb    %00000000

line 9781:
    DEFB    %00000000
        defb    %00000000

line 9782:
    DEFB    %00111100
        defb    %00111100

line 9783:
    DEFB    %01000110
        defb    %01000110

line 9784:
    DEFB    %01001010
        defb    %01001010

line 9785:
    DEFB    %01010010
        defb    %01010010

line 9786:
    DEFB    %01100010
        defb    %01100010

line 9787:
    DEFB    %00111100
        defb    %00111100

line 9788:
    DEFB    %00000000
        defb    %00000000

line 9792:
    DEFB    %00000000
        defb    %00000000

line 9793:
    DEFB    %00011000
        defb    %00011000

line 9794:
    DEFB    %00101000
        defb    %00101000

line 9795:
    DEFB    %00001000
        defb    %00001000

line 9796:
    DEFB    %00001000
        defb    %00001000

line 9797:
    DEFB    %00001000
        defb    %00001000

line 9798:
    DEFB    %00111110
        defb    %00111110

line 9799:
    DEFB    %00000000
        defb    %00000000

line 9803:
    DEFB    %00000000
        defb    %00000000

line 9804:
    DEFB    %00111100
        defb    %00111100

line 9805:
    DEFB    %01000010
        defb    %01000010

line 9806:
    DEFB    %00000010
        defb    %00000010

line 9807:
    DEFB    %00111100
        defb    %00111100

line 9808:
    DEFB    %01000000
        defb    %01000000

line 9809:
    DEFB    %01111110
        defb    %01111110

line 9810:
    DEFB    %00000000
        defb    %00000000

line 9814:
    DEFB    %00000000
        defb    %00000000

line 9815:
    DEFB    %00111100
        defb    %00111100

line 9816:
    DEFB    %01000010
        defb    %01000010

line 9817:
    DEFB    %00001100
        defb    %00001100

line 9818:
    DEFB    %00000010
        defb    %00000010

line 9819:
    DEFB    %01000010
        defb    %01000010

line 9820:
    DEFB    %00111100
        defb    %00111100

line 9821:
    DEFB    %00000000
        defb    %00000000

line 9825:
    DEFB    %00000000
        defb    %00000000

line 9826:
    DEFB    %00001000
        defb    %00001000

line 9827:
    DEFB    %00011000
        defb    %00011000

line 9828:
    DEFB    %00101000
        defb    %00101000

line 9829:
    DEFB    %01001000
        defb    %01001000

line 9830:
    DEFB    %01111110
        defb    %01111110

line 9831:
    DEFB    %00001000
        defb    %00001000

line 9832:
    DEFB    %00000000
        defb    %00000000

line 9836:
    DEFB    %00000000
        defb    %00000000

line 9837:
    DEFB    %01111110
        defb    %01111110

line 9838:
    DEFB    %01000000
        defb    %01000000

line 9839:
    DEFB    %01111100
        defb    %01111100

line 9840:
    DEFB    %00000010
        defb    %00000010

line 9841:
    DEFB    %01000010
        defb    %01000010

line 9842:
    DEFB    %00111100
        defb    %00111100

line 9843:
    DEFB    %00000000
        defb    %00000000

line 9847:
    DEFB    %00000000
        defb    %00000000

line 9848:
    DEFB    %00111100
        defb    %00111100

line 9849:
    DEFB    %01000000
        defb    %01000000

line 9850:
    DEFB    %01111100
        defb    %01111100

line 9851:
    DEFB    %01000010
        defb    %01000010

line 9852:
    DEFB    %01000010
        defb    %01000010

line 9853:
    DEFB    %00111100
        defb    %00111100

line 9854:
    DEFB    %00000000
        defb    %00000000

line 9858:
    DEFB    %00000000
        defb    %00000000

line 9859:
    DEFB    %01111110
        defb    %01111110

line 9860:
    DEFB    %00000010
        defb    %00000010

line 9861:
    DEFB    %00000100
        defb    %00000100

line 9862:
    DEFB    %00001000
        defb    %00001000

line 9863:
    DEFB    %00010000
        defb    %00010000

line 9864:
    DEFB    %00010000
        defb    %00010000

line 9865:
    DEFB    %00000000
        defb    %00000000

line 9869:
    DEFB    %00000000
        defb    %00000000

line 9870:
    DEFB    %00111100
        defb    %00111100

line 9871:
    DEFB    %01000010
        defb    %01000010

line 9872:
    DEFB    %00111100
        defb    %00111100

line 9873:
    DEFB    %01000010
        defb    %01000010

line 9874:
    DEFB    %01000010
        defb    %01000010

line 9875:
    DEFB    %00111100
        defb    %00111100

line 9876:
    DEFB    %00000000
        defb    %00000000

line 9880:
    DEFB    %00000000
        defb    %00000000

line 9881:
    DEFB    %00111100
        defb    %00111100

line 9882:
    DEFB    %01000010
        defb    %01000010

line 9883:
    DEFB    %01000010
        defb    %01000010

line 9884:
    DEFB    %00111110
        defb    %00111110

line 9885:
    DEFB    %00000010
        defb    %00000010

line 9886:
    DEFB    %00111100
        defb    %00111100

line 9887:
    DEFB    %00000000
        defb    %00000000

line 9891:
    DEFB    %00000000
        defb    %00000000

line 9892:
    DEFB    %00111100
        defb    %00111100

line 9893:
    DEFB    %01000010
        defb    %01000010

line 9894:
    DEFB    %01000010
        defb    %01000010

line 9895:
    DEFB    %01111110
        defb    %01111110

line 9896:
    DEFB    %01000010
        defb    %01000010

line 9897:
    DEFB    %01000010
        defb    %01000010

line 9898:
    DEFB    %00000000
        defb    %00000000

line 9902:
    DEFB    %00000000
        defb    %00000000

line 9903:
    DEFB    %01111100
        defb    %01111100

line 9904:
    DEFB    %01000010
        defb    %01000010

line 9905:
    DEFB    %01111100
        defb    %01111100

line 9906:
    DEFB    %01000010
        defb    %01000010

line 9907:
    DEFB    %01000010
        defb    %01000010

line 9908:
    DEFB    %01111100
        defb    %01111100

line 9909:
    DEFB    %00000000
        defb    %00000000

line 9913:
    DEFB    %00000000
        defb    %00000000

line 9914:
    DEFB    %00111100
        defb    %00111100

line 9915:
    DEFB    %01000010
        defb    %01000010

line 9916:
    DEFB    %01000000
        defb    %01000000

line 9917:
    DEFB    %01000000
        defb    %01000000

line 9918:
    DEFB    %01000010
        defb    %01000010

line 9919:
    DEFB    %00111100
        defb    %00111100

line 9920:
    DEFB    %00000000
        defb    %00000000

line 9924:
    DEFB    %00000000
        defb    %00000000

line 9925:
    DEFB    %01111000
        defb    %01111000

line 9926:
    DEFB    %01000100
        defb    %01000100

line 9927:
    DEFB    %01000010
        defb    %01000010

line 9928:
    DEFB    %01000010
        defb    %01000010

line 9929:
    DEFB    %01000100
        defb    %01000100

line 9930:
    DEFB    %01111000
        defb    %01111000

line 9931:
    DEFB    %00000000
        defb    %00000000

line 9935:
    DEFB    %00000000
        defb    %00000000

line 9936:
    DEFB    %01111110
        defb    %01111110

line 9937:
    DEFB    %01000000
        defb    %01000000

line 9938:
    DEFB    %01111100
        defb    %01111100

line 9939:
    DEFB    %01000000
        defb    %01000000

line 9940:
    DEFB    %01000000
        defb    %01000000

line 9941:
    DEFB    %01111110
        defb    %01111110

line 9942:
    DEFB    %00000000
        defb    %00000000

line 9946:
    DEFB    %00000000
        defb    %00000000

line 9947:
    DEFB    %01111110
        defb    %01111110

line 9948:
    DEFB    %01000000
        defb    %01000000

line 9949:
    DEFB    %01111100
        defb    %01111100

line 9950:
    DEFB    %01000000
        defb    %01000000

line 9951:
    DEFB    %01000000
        defb    %01000000

line 9952:
    DEFB    %01000000
        defb    %01000000

line 9953:
    DEFB    %00000000
        defb    %00000000

line 9957:
    DEFB    %00000000
        defb    %00000000

line 9958:
    DEFB    %00111100
        defb    %00111100

line 9959:
    DEFB    %01000010
        defb    %01000010

line 9960:
    DEFB    %01000000
        defb    %01000000

line 9961:
    DEFB    %01001110
        defb    %01001110

line 9962:
    DEFB    %01000010
        defb    %01000010

line 9963:
    DEFB    %00111100
        defb    %00111100

line 9964:
    DEFB    %00000000
        defb    %00000000

line 9968:
    DEFB    %00000000
        defb    %00000000

line 9969:
    DEFB    %01000010
        defb    %01000010

line 9970:
    DEFB    %01000010
        defb    %01000010

line 9971:
    DEFB    %01111110
        defb    %01111110

line 9972:
    DEFB    %01000010
        defb    %01000010

line 9973:
    DEFB    %01000010
        defb    %01000010

line 9974:
    DEFB    %01000010
        defb    %01000010

line 9975:
    DEFB    %00000000
        defb    %00000000

line 9979:
    DEFB    %00000000
        defb    %00000000

line 9980:
    DEFB    %00111110
        defb    %00111110

line 9981:
    DEFB    %00001000
        defb    %00001000

line 9982:
    DEFB    %00001000
        defb    %00001000

line 9983:
    DEFB    %00001000
        defb    %00001000

line 9984:
    DEFB    %00001000
        defb    %00001000

line 9985:
    DEFB    %00111110
        defb    %00111110

line 9986:
    DEFB    %00000000
        defb    %00000000

line 9990:
    DEFB    %00000000
        defb    %00000000

line 9991:
    DEFB    %00000010
        defb    %00000010

line 9992:
    DEFB    %00000010
        defb    %00000010

line 9993:
    DEFB    %00000010
        defb    %00000010

line 9994:
    DEFB    %01000010
        defb    %01000010

line 9995:
    DEFB    %01000010
        defb    %01000010

line 9996:
    DEFB    %00111100
        defb    %00111100

line 9997:
    DEFB    %00000000
        defb    %00000000

line 10001:
    DEFB    %00000000
        defb    %00000000

line 10002:
    DEFB    %01000100
        defb    %01000100

line 10003:
    DEFB    %01001000
        defb    %01001000

line 10004:
    DEFB    %01110000
        defb    %01110000

line 10005:
    DEFB    %01001000
        defb    %01001000

line 10006:
    DEFB    %01000100
        defb    %01000100

line 10007:
    DEFB    %01000010
        defb    %01000010

line 10008:
    DEFB    %00000000
        defb    %00000000

line 10012:
    DEFB    %00000000
        defb    %00000000

line 10013:
    DEFB    %01000000
        defb    %01000000

line 10014:
    DEFB    %01000000
        defb    %01000000

line 10015:
    DEFB    %01000000
        defb    %01000000

line 10016:
    DEFB    %01000000
        defb    %01000000

line 10017:
    DEFB    %01000000
        defb    %01000000

line 10018:
    DEFB    %01111110
        defb    %01111110

line 10019:
    DEFB    %00000000
        defb    %00000000

line 10023:
    DEFB    %00000000
        defb    %00000000

line 10024:
    DEFB    %01000010
        defb    %01000010

line 10025:
    DEFB    %01100110
        defb    %01100110

line 10026:
    DEFB    %01011010
        defb    %01011010

line 10027:
    DEFB    %01000010
        defb    %01000010

line 10028:
    DEFB    %01000010
        defb    %01000010

line 10029:
    DEFB    %01000010
        defb    %01000010

line 10030:
    DEFB    %00000000
        defb    %00000000

line 10034:
    DEFB    %00000000
        defb    %00000000

line 10035:
    DEFB    %01000010
        defb    %01000010

line 10036:
    DEFB    %01100010
        defb    %01100010

line 10037:
    DEFB    %01010010
        defb    %01010010

line 10038:
    DEFB    %01001010
        defb    %01001010

line 10039:
    DEFB    %01000110
        defb    %01000110

line 10040:
    DEFB    %01000010
        defb    %01000010

line 10041:
    DEFB    %00000000
        defb    %00000000

line 10045:
    DEFB    %00000000
        defb    %00000000

line 10046:
    DEFB    %00111100
        defb    %00111100

line 10047:
    DEFB    %01000010
        defb    %01000010

line 10048:
    DEFB    %01000010
        defb    %01000010

line 10049:
    DEFB    %01000010
        defb    %01000010

line 10050:
    DEFB    %01000010
        defb    %01000010

line 10051:
    DEFB    %00111100
        defb    %00111100

line 10052:
    DEFB    %00000000
        defb    %00000000

line 10056:
    DEFB    %00000000
        defb    %00000000

line 10057:
    DEFB    %01111100
        defb    %01111100

line 10058:
    DEFB    %01000010
        defb    %01000010

line 10059:
    DEFB    %01000010
        defb    %01000010

line 10060:
    DEFB    %01111100
        defb    %01111100

line 10061:
    DEFB    %01000000
        defb    %01000000

line 10062:
    DEFB    %01000000
        defb    %01000000

line 10063:
    DEFB    %00000000
        defb    %00000000

line 10067:
    DEFB    %00000000
        defb    %00000000

line 10068:
    DEFB    %00111100
        defb    %00111100

line 10069:
    DEFB    %01000010
        defb    %01000010

line 10070:
    DEFB    %01000010
        defb    %01000010

line 10071:
    DEFB    %01010010
        defb    %01010010

line 10072:
    DEFB    %01001010
        defb    %01001010

line 10073:
    DEFB    %00111100
        defb    %00111100

line 10074:
    DEFB    %00000000
        defb    %00000000

line 10078:
    DEFB    %00000000
        defb    %00000000

line 10079:
    DEFB    %01111100
        defb    %01111100

line 10080:
    DEFB    %01000010
        defb    %01000010

line 10081:
    DEFB    %01000010
        defb    %01000010

line 10082:
    DEFB    %01111100
        defb    %01111100

line 10083:
    DEFB    %01000100
        defb    %01000100

line 10084:
    DEFB    %01000010
        defb    %01000010

line 10085:
    DEFB    %00000000
        defb    %00000000

line 10089:
    DEFB    %00000000
        defb    %00000000

line 10090:
    DEFB    %00111100
        defb    %00111100

line 10091:
    DEFB    %01000000
        defb    %01000000

line 10092:
    DEFB    %00111100
        defb    %00111100

line 10093:
    DEFB    %00000010
        defb    %00000010

line 10094:
    DEFB    %01000010
        defb    %01000010

line 10095:
    DEFB    %00111100
        defb    %00111100

line 10096:
    DEFB    %00000000
        defb    %00000000

line 10100:
    DEFB    %00000000
        defb    %00000000

line 10101:
    DEFB    %11111110
        defb    %11111110

line 10102:
    DEFB    %00010000
        defb    %00010000

line 10103:
    DEFB    %00010000
        defb    %00010000

line 10104:
    DEFB    %00010000
        defb    %00010000

line 10105:
    DEFB    %00010000
        defb    %00010000

line 10106:
    DEFB    %00010000
        defb    %00010000

line 10107:
    DEFB    %00000000
        defb    %00000000

line 10111:
    DEFB    %00000000
        defb    %00000000

line 10112:
    DEFB    %01000010
        defb    %01000010

line 10113:
    DEFB    %01000010
        defb    %01000010

line 10114:
    DEFB    %01000010
        defb    %01000010

line 10115:
    DEFB    %01000010
        defb    %01000010

line 10116:
    DEFB    %01000010
        defb    %01000010

line 10117:
    DEFB    %00111100
        defb    %00111100

line 10118:
    DEFB    %00000000
        defb    %00000000

line 10122:
    DEFB    %00000000
        defb    %00000000

line 10123:
    DEFB    %01000010
        defb    %01000010

line 10124:
    DEFB    %01000010
        defb    %01000010

line 10125:
    DEFB    %01000010
        defb    %01000010

line 10126:
    DEFB    %01000010
        defb    %01000010

line 10127:
    DEFB    %00100100
        defb    %00100100

line 10128:
    DEFB    %00011000
        defb    %00011000

line 10129:
    DEFB    %00000000
        defb    %00000000

line 10133:
    DEFB    %00000000
        defb    %00000000

line 10134:
    DEFB    %01000010
        defb    %01000010

line 10135:
    DEFB    %01000010
        defb    %01000010

line 10136:
    DEFB    %01000010
        defb    %01000010

line 10137:
    DEFB    %01000010
        defb    %01000010

line 10138:
    DEFB    %01011010
        defb    %01011010

line 10139:
    DEFB    %00100100
        defb    %00100100

line 10140:
    DEFB    %00000000
        defb    %00000000

line 10144:
    DEFB    %00000000
        defb    %00000000

line 10145:
    DEFB    %01000010
        defb    %01000010

line 10146:
    DEFB    %00100100
        defb    %00100100

line 10147:
    DEFB    %00011000
        defb    %00011000

line 10148:
    DEFB    %00011000
        defb    %00011000

line 10149:
    DEFB    %00100100
        defb    %00100100

line 10150:
    DEFB    %01000010
        defb    %01000010

line 10151:
    DEFB    %00000000
        defb    %00000000

line 10155:
    DEFB    %00000000
        defb    %00000000

line 10156:
    DEFB    %10000010
        defb    %10000010

line 10157:
    DEFB    %01000100
        defb    %01000100

line 10158:
    DEFB    %00101000
        defb    %00101000

line 10159:
    DEFB    %00010000
        defb    %00010000

line 10160:
    DEFB    %00010000
        defb    %00010000

line 10161:
    DEFB    %00010000
        defb    %00010000

line 10162:
    DEFB    %00000000
        defb    %00000000

line 10166:
    DEFB    %00000000
        defb    %00000000

line 10167:
    DEFB    %01111110
        defb    %01111110

line 10168:
    DEFB    %00000100
        defb    %00000100

line 10169:
    DEFB    %00001000
        defb    %00001000

line 10170:
    DEFB    %00010000
        defb    %00010000

line 10171:
    DEFB    %00100000
        defb    %00100000

line 10172:
    DEFB    %01111110
        defb    %01111110

line 10173:
    DEFB    %00000000
        defb    %00000000

line 10175:
.END                ;TASM assembler instruction.
.END                            ;TASM assembler instruction.

Update test.asm
