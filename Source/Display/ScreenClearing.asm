
; Unified Screen clearing routines organised by performance level
;
; Always call Screen_FullReset_Unified clear pixels and reset attributes.
; Always call Screen_ClearPixel_Unified clear pixels only, attributes not altered.
; Always call Screen_ClearAttr_Unified clear attributes only, pixels unaltered.
;
; Input: A = attribute, C = performance level
;
; T-States summary shows:
;
; SCREEN_COMPACT: Standard LDIR operation       - Pixel Only ~129,074 T-States, Attribute Only ~16,191 T-States, Full Reset ~145,265 T-States
; SCREEN_1PUSH: Sets 2 pixels simultaneously    - Pixel Only ~81,640 T-States, Attribute Only ~10,270 T-States, Full Reset ~91,910 T-States
; SCREEN_2PUSH: Sets 4 pixels simultaneously    - Pixel Only ~57,240 T-States, Attribute Only ~7,230 T-States, Full Reset ~64,470 T-States
; SCREEN_4PUSH: Sets 8 pixels simultaneously    - Pixel Only ~45,240 T-States, Attribute Only ~5,710 T-States, Full Reset ~50,950 T-States
; SCREEN_8PUSH: Sets 16 pixels simultaneously   - Pixel Only ~39,240 T-States, Attribute Only ~4,900 T-States, Full Reset ~44,140 T-States
; SCREEN_ALLPUSH: Sets 256 pixels per loop      - Pixel Only ~34,140 T-States, Attribute Only ~4,270 T-States, Full Reset ~38,410 T-States
;
; @COMPAT: 48K,128K,+2,+3,NEXT

Screen_FullReset_Unified:   LD      (CurrentAttr), A                ; Set current attribute for text system.
                            LD      A, C                            ; Get Performance Level
                            CP      SCREEN_1PUSH
                            JP      Z, ScreenReset1Push
                            CP      SCREEN_2PUSH
                            JP      Z, ScreenReset2Push
                            CP      SCREEN_4PUSH
                            JP      Z, ScreenReset4Push
                            CP      SCREEN_8PUSH
                            JP      Z, ScreenReset8Push
                            CP      SCREEN_ALLPUSH
                            JP      Z, ScreenResetAllPush
                            ; fall through to SCREEN_COMPACT

; Clear the entire screen using direct memory access
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenFullReset:            CALL    ClearFullPixels                 ; Clear pixel memory
                            JP      SetAttributes                   ; Set attribute memory

;
; @COMPAT: 48K,128K,+2,+3,NEXT
Screen_ClearPixel_Unified:  LD      (CurrentAttr), A                ; Set current attribute for text system.
                            LD      A, C                            ; Get Performance Level
                            CP      SCREEN_1PUSH
                            JP      Z, ScreenPixels1Push
                            CP      SCREEN_2PUSH
                            JP      Z, ScreenPixels2Push
                            CP      SCREEN_4PUSH
                            JP      Z, ScreenPixels4Push
                            CP      SCREEN_8PUSH
                            JP      Z, ScreenPixels8Push
                            CP      SCREEN_ALLPUSH
                            JP      Z, ScreenPixelsAllPush
                            ; fall through to SCREEN_COMPACT

;
; @COMPAT: 48K,128K,+2,+3,NEXT
ClearFullPixels:            ; Clear pixel memory (0x4000-0x57FF)
                            LD      HL, SCREEN_PIXEL_BASE
                            LD      DE, SCREEN_PIXEL_BASE + 1
                            LD      BC, 0x1800                      ; 6144 bytes in pixel area
                            LD      (HL), 0                         ; Clear first byte
                            LDIR                                    ; Clear rest
                            RET

;
; @COMPAT: 48K,128K,+2,+3,NEXT
Screen_ClearAttr_Unified:   LD      (CurrentAttr), A                ; Set current attribute for text system.
                            LD      A, C                            ; Get Performance Level
                            CP      SCREEN_1PUSH
                            JP      Z, ScreenAttrs1Push
                            CP      SCREEN_2PUSH
                            JP      Z, ScreenAttrs2Push
                            CP      SCREEN_4PUSH
                            JP      Z, ScreenAttrs4Push
                            CP      SCREEN_8PUSH
                            JP      Z, ScreenAttrs8Push
                            CP      SCREEN_ALLPUSH
                            JP      Z, ScreenAttrsAllPush
                            ; fall through to SCREEN_COMPACT

;
; @COMPAT: 48K,128K,+2,+3,NEXT
SetAttributes:              ; Set attribute memory (0x5800-0x5AFF)
                            LD      A, (CurrentAttr)                ; Get saved attribute to set to.
                            LD      HL, SCREEN_ATTR_BASE
                            LD      DE, SCREEN_ATTR_BASE + 1
                            LD      BC, 768                         ; 768 bytes in attribute area
                            LD      (HL), A                         ; Set first attribute
                            LDIR                                    ; Set rest
                            RET

; by temporary move stack to screen area, we can push two bytes per instruction instead of just one. We have to save and then restore the current stack pointer before returning.
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenReset1Push:           CALL    ScreenPixels1Push
                            JP      ScreenAttrs1Push
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenPixels1Push:          LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      DE, 0                           ; DE = 0x0000 (clear value)
                            LD      SP, SCREEN_PIXEL_BASE + 6144    ; Point to end of pixel memory
                            LD      B, 24                           ; 24 × 128 = 6144 bytes / 2
ClearPixel_1Push_Loop:      LD      C, 128                          ; 128 × 2 = 256 bytes per inner loop
ClearPixel_1Push_Inner:     PUSH    DE                              ; Clear 2 bytes - only 11 T-states, we also have no loop and decrement cost here, halving our loop cost.
                            DEC     C                               ; (4 T-states)
                            JP      NZ, ClearPixel_1Push_Inner      ; (12/7 T-states) - this loops 128 times, with 2 pixels set per loop = 256 pixels for the inner loop.
                            DEC     B                               ; (4 T-states)
                            JP      NZ, ClearPixel_1Push_Loop       ; (12/7 T-states)
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenAttrs1Push:           LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      A, (CurrentAttr)                ; Load attribute into A
                            LD      D, A                            ; D = attribute
                            LD      E, A                            ; E = attribute
                            LD      SP, SCREEN_ATTR_BASE + 768      ; Point to end of attribute memory
                            LD      B, 3                            ; 3 × 128 = 768 bytes / 2 - we can reuse the pixel 128 loop now.
                            JP      ClearPixel_1Push_Loop

; by increasing the pushes by a factor of 2, the code size increases slighlty but the looping halves again.
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenReset2Push:           CALL    ScreenPixels2Push
                            JP      ScreenAttrs2Push
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenPixels2Push:          LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      DE, 0                           ; DE = 0x0000 (clear value)
                            LD      SP, SCREEN_PIXEL_BASE + 6144    ; Point to end of pixel memory
                            LD      B, 24                           ; 24 × 64 = 6144 bytes / 4
ClearPixel_2Push_Loop:      LD      C, 64                           ; 64 × 4 = 256 bytes per inner loop
ClearPixel_2Push_Inner:     PUSH    DE                              ; Clear 2 bytes - only 11 T-states, we also have no loop and decrement cost here, halving our loop cost.
                            PUSH    DE                              ; Clear 2 more bytes for only 11 T-states, halving the loop cost of 1push ;)
                            DEC     C                               ; (4 T-states)
                            JP      NZ, ClearPixel_2Push_Inner      ; (12/7 T-states) - this loops 64 times, with 4 pixels set per loop = 256 pixels for the inner loop.
                            DEC     B                               ; (4 T-states)
                            JP      NZ, ClearPixel_2Push_Loop       ; (12/7 T-states)
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenAttrs2Push:           LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      A, (CurrentAttr)                ; Load attribute into A
                            LD      D, A                            ; D = attribute
                            LD      E, A                            ; E = attribute
                            LD      SP, SCREEN_ATTR_BASE + 768      ; Point to end of attribute memory
                            LD      B, 3                            ; 3 × 64 = 768 bytes / 4 - we can reuse the pixel loop again.
                            JP      ClearPixel_2Push_Loop

; x 2 pushes again
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenReset4Push:           CALL    ScreenPixels4Push
                            JP      ScreenAttrs4Push
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenPixels4Push:          LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      DE, 0                           ; DE = 0x0000 (clear value)
                            LD      SP, SCREEN_PIXEL_BASE + 6144    ; Point to end of pixel memory
                            LD      B, 24                           ; 24 × 32 = 6144 bytes / 8
ClearPixel_4Push_Loop:      LD      C, 32                           ; 32 × 8 = 256 bytes per inner loop
ClearPixel_4Push_Inner:     PUSH    DE                              ; Clear 2 bytes - only 11 T-states, we also have no loop and decrement cost here, halving our loop cost.
                            PUSH    DE                              ; Clear 6 more bytes for only 33 T-states, halving the loop cost of 2push ;)
                            PUSH    DE
                            PUSH    DE
                            DEC     C                               ; (4 T-states)
                            JP      NZ, ClearPixel_4Push_Inner      ; (12/7 T-states) - this loops 64 times, with 4 pixels set per loop = 256 pixels for the inner loop.
                            DEC     B                               ; (4 T-states)
                            JP      NZ, ClearPixel_4Push_Loop       ; (12/7 T-states)
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenAttrs4Push:           LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      A, (CurrentAttr)                ; Load attribute into A
                            LD      D, A                            ; D = attribute
                            LD      E, A                            ; E = attribute
                            LD      SP, SCREEN_ATTR_BASE + 768      ; Point to end of attribute memory
                            LD      B, 3                            ; 3 × 32 = 768 bytes / 8 - we can reuse the pixel loop again.
                            JP      ClearPixel_4Push_Loop

; x 2 pushes again
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenReset8Push:           CALL    ScreenPixels8Push
                            JP      ScreenAttrs8Push
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenPixels8Push:          LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      DE, 0                           ; DE = 0x0000 (clear value)
                            LD      SP, SCREEN_PIXEL_BASE + 6144    ; Point to end of pixel memory
                            LD      B, 24                           ; 24 × 16 = 6144 bytes / 16
ClearPixel_8Push_Loop:      LD      C, 16                           ; 16 × 16 = 256 bytes per inner loop
ClearPixel_8Push_Inner:     PUSH    DE                              ; Clear 2 bytes - only 11 T-states, we also have no loop and decrement cost here, halving our loop cost.
                            PUSH    DE                              ; Clear 14 more bytes, halving the loop cost of 4push ;)
                            PUSH    DE
                            PUSH    DE
                            PUSH    DE
                            PUSH    DE
                            PUSH    DE
                            PUSH    DE
                            DEC     C                               ; (4 T-states)
                            JP      NZ, ClearPixel_8Push_Inner      ; (12/7 T-states) - this loops 64 times, with 4 pixels set per loop = 256 pixels for the inner loop.
                            DEC     B                               ; (4 T-states)
                            JP      NZ, ClearPixel_8Push_Loop       ; (12/7 T-states)
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenAttrs8Push:           LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      A, (CurrentAttr)                ; Load attribute into A
                            LD      D, A                            ; D = attribute
                            LD      E, A                            ; E = attribute
                            LD      SP, SCREEN_ATTR_BASE + 768      ; Point to end of attribute memory
                            LD      B, 3                            ; 3 × 16 = 768 bytes / 16 - we can reuse the pixel loop again.
                            JP      ClearPixel_8Push_Loop

; x 2 pushes again
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenResetAllPush:         CALL    ScreenPixelsAllPush
                            JP      ScreenAttrsAllPush
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenPixelsAllPush:        LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      DE, 0                           ; DE = 0x0000 (clear value)
                            LD      SP, SCREEN_PIXEL_BASE + 6144    ; Point to end of pixel memory
                            LD      B, 24                           ; 24 × 256 bytes = 6144 bytes
ClearPixel_AllPush_Loop:    PUSH    DE                              ; push 001 - Clear 2 bytes, 128 pushes give us 256 bytes and eliminates one of the loops! Does use a lot more memory though, so tradeoff as needed
                            PUSH    DE                              ; push 002
                            PUSH    DE                              ; push 003
                            PUSH    DE                              ; push 004
                            PUSH    DE                              ; push 005
                            PUSH    DE                              ; push 006
                            PUSH    DE                              ; push 007
                            PUSH    DE                              ; push 008
                            PUSH    DE                              ; push 009
                            PUSH    DE                              ; push 010
                            PUSH    DE                              ; push 011
                            PUSH    DE                              ; push 012
                            PUSH    DE                              ; push 013
                            PUSH    DE                              ; push 014
                            PUSH    DE                              ; push 015
                            PUSH    DE                              ; push 016
                            PUSH    DE                              ; push 017
                            PUSH    DE                              ; push 018
                            PUSH    DE                              ; push 019
                            PUSH    DE                              ; push 020
                            PUSH    DE                              ; push 021
                            PUSH    DE                              ; push 022
                            PUSH    DE                              ; push 023
                            PUSH    DE                              ; push 024
                            PUSH    DE                              ; push 025
                            PUSH    DE                              ; push 026
                            PUSH    DE                              ; push 027
                            PUSH    DE                              ; push 028
                            PUSH    DE                              ; push 029
                            PUSH    DE                              ; push 030
                            PUSH    DE                              ; push 031
                            PUSH    DE                              ; push 032
                            PUSH    DE                              ; push 033
                            PUSH    DE                              ; push 034
                            PUSH    DE                              ; push 035
                            PUSH    DE                              ; push 036
                            PUSH    DE                              ; push 037
                            PUSH    DE                              ; push 038
                            PUSH    DE                              ; push 039
                            PUSH    DE                              ; push 040
                            PUSH    DE                              ; push 041
                            PUSH    DE                              ; push 042
                            PUSH    DE                              ; push 043
                            PUSH    DE                              ; push 044
                            PUSH    DE                              ; push 045
                            PUSH    DE                              ; push 046
                            PUSH    DE                              ; push 047
                            PUSH    DE                              ; push 048
                            PUSH    DE                              ; push 049
                            PUSH    DE                              ; push 050
                            PUSH    DE                              ; push 051
                            PUSH    DE                              ; push 052
                            PUSH    DE                              ; push 053
                            PUSH    DE                              ; push 054
                            PUSH    DE                              ; push 055
                            PUSH    DE                              ; push 056
                            PUSH    DE                              ; push 057
                            PUSH    DE                              ; push 058
                            PUSH    DE                              ; push 059
                            PUSH    DE                              ; push 060
                            PUSH    DE                              ; push 061
                            PUSH    DE                              ; push 062
                            PUSH    DE                              ; push 063
                            PUSH    DE                              ; push 064
                            PUSH    DE                              ; push 065
                            PUSH    DE                              ; push 066
                            PUSH    DE                              ; push 067
                            PUSH    DE                              ; push 068
                            PUSH    DE                              ; push 069
                            PUSH    DE                              ; push 070
                            PUSH    DE                              ; push 071
                            PUSH    DE                              ; push 072
                            PUSH    DE                              ; push 073
                            PUSH    DE                              ; push 074
                            PUSH    DE                              ; push 075
                            PUSH    DE                              ; push 076
                            PUSH    DE                              ; push 077
                            PUSH    DE                              ; push 078
                            PUSH    DE                              ; push 079
                            PUSH    DE                              ; push 080
                            PUSH    DE                              ; push 081
                            PUSH    DE                              ; push 082
                            PUSH    DE                              ; push 083
                            PUSH    DE                              ; push 084
                            PUSH    DE                              ; push 085
                            PUSH    DE                              ; push 086
                            PUSH    DE                              ; push 087
                            PUSH    DE                              ; push 088
                            PUSH    DE                              ; push 089
                            PUSH    DE                              ; push 090
                            PUSH    DE                              ; push 091
                            PUSH    DE                              ; push 092
                            PUSH    DE                              ; push 093
                            PUSH    DE                              ; push 094
                            PUSH    DE                              ; push 095
                            PUSH    DE                              ; push 096
                            PUSH    DE                              ; push 097
                            PUSH    DE                              ; push 098
                            PUSH    DE                              ; push 099
                            PUSH    DE                              ; push 100
                            PUSH    DE                              ; push 101
                            PUSH    DE                              ; push 102
                            PUSH    DE                              ; push 103
                            PUSH    DE                              ; push 104
                            PUSH    DE                              ; push 105
                            PUSH    DE                              ; push 106
                            PUSH    DE                              ; push 107
                            PUSH    DE                              ; push 108
                            PUSH    DE                              ; push 109
                            PUSH    DE                              ; push 110
                            PUSH    DE                              ; push 111
                            PUSH    DE                              ; push 112
                            PUSH    DE                              ; push 113
                            PUSH    DE                              ; push 114
                            PUSH    DE                              ; push 115
                            PUSH    DE                              ; push 116
                            PUSH    DE                              ; push 117
                            PUSH    DE                              ; push 118
                            PUSH    DE                              ; push 119
                            PUSH    DE                              ; push 120
                            PUSH    DE                              ; push 121
                            PUSH    DE                              ; push 122
                            PUSH    DE                              ; push 123
                            PUSH    DE                              ; push 124
                            PUSH    DE                              ; push 125
                            PUSH    DE                              ; push 126
                            PUSH    DE                              ; push 127
                            PUSH    DE                              ; push 128 - we have now set 256 bytes this pass!
                            DEC     B                               ; (4 T-states)
                            JP      NZ, ClearPixel_AllPush_Loop     ; (12/7 T-states)
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ScreenAttrsAllPush:         LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      A, (CurrentAttr)                ; Load attribute into A
                            LD      D, A                            ; D = attribute
                            LD      E, A                            ; E = attribute
                            LD      SP, SCREEN_ATTR_BASE + 768      ; Point to end of attribute memory
                            LD      B, 3                            ; 3 × 256 = 768 bytes - we can reuse the pixel loop again.
                            JP      ClearPixel_AllPush_Loop
