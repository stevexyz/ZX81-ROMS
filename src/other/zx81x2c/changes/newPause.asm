;
; -------------------------------
; THE old 'PAUSE' COMMAND ROUTINE
; -------------------------------
;
;; PAUSE
L0F32:	CALL FIND_INT		; routine FIND-INT
	CALL L02E7		; routine SET-FAST
	LD H,B			;
	LD L,C			;
	CALL L022D		; routine DISPLAY-P

	LD (IY+$35),$FF		; sv FRAMES_hi

	CALL L0207		; routine SLOW/FAST
	JR L0F4B		; routine DEBOUNCE
;
;	========================================================
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
;	========================================================
ffp_hook
	ld hl,jp_DISP2		; hook to DISPLAY-2
	inc bc			; set counter
	ld ($4034),bc		; set FRAMES
	ret nz			; flicker free PAUSE (in SLOW mode)

	jp L0229		; DISPLAY-1 (in FAST mode)
;
;	========================================================
jp_DISP2
	push hl			; restore HL (= 0 !!!)
	jp L023E		; back to DISPLAY-2
;
;	========================================================
ffp_test
	bit 7,(iy+$3B)		; sv CDFLAG - test SLOW mode
	jp ffp_hook		; forward 

