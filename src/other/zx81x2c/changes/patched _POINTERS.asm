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

;;-	AND     A               ;
;;-	SBC     HL,DE           ;
;;-	LD      B,H             ;
;;-	LD      C,L             ;
;;-	INC     BC              ;
;;-	ADD     HL,DE           ;
;;-	EX      DE,HL           ;

	call L0A17		; -> DIFFER
	inc bc			;

        RET                     ;
;
;	===============================================
;	in "SLOW" mode the DISPLAY-1 routine joins here
;	if FRAMES is in use by PAUSE
jp_DISP2
	push hl			; restore stack (HL = 0 !!!)
	jp L023E		; back to DISPLAY-2
