; Unified Multiply 8x8 operations with performance level
;
; Always call Multiply8x8_Unified to ensure HL is cleared at start of calculation.
;
; Input: A = multiplicand, B = multiplier, C = performance level,
; Output: HL = result (16-bit)
;
; T-States summary shows:
;
; PERFORMANCE_COMPACT:  ~35-75 T-states (variable, depends on multiplier bit pattern)
; PERFORMANCE_BALANCED: ~160 T-states (fixed, 8 iterations regardless of multiplier)  
; PERFORMANCE_MAXIMUM:  ~120 T-states (fixed, unrolled loop with all bit checks)
; PERFORMANCE_NEXT_COMPACT: ~14 T-states (Z80N MUL DE instruction, does not check for overflow)
; PERFORMANCE_NEXT_BALANCED: ~29 T-states (Z80N MUL DE instruction, checks for overflow returning Z set for no overflow and NZ if overflow occurred.)
; PERFORMANCE_NEXT_MAXIMUM: ~20 T-states (Z80N MUL DE instruction, accounts for 0 and 1 special cases, checks for overflow as balanced does.)
;
; Performance Improvement: Up to 85% faster on Spectrum Next
;
; @COMPAT: 48K,128K,+2,+3,NEXT for first 3 choices, NEXT for last 3 choices

Multiply8x8_Unified:    LD      H, 0                          ; Clear high byte of result
                        LD      L, 0                          ; Clear low byte of result
                        LD      D, 0                          ; Clear high byte of multiplicand
                        LD      E, A                          ; Move multiplicand to low byte of DE
                        LD      A, C                          ; Get Performance Level
                        CP      PERFORMANCE_COMPACT
                        JP      Z, Multiply8x8_Compact
                        CP      PERFORMANCE_MAXIMUM
                        JP      Z, Multiply8x8_Unrolled
                        CP      PERFORMANCE_BALANCED
                        JP      Z, Multiply8x8_Std
                        
                        ; The following are only compatible with the Spectrum Next Z80N architecture.
                        ; So using these prevents your code base generating for original Spectrum hardware

                        ; we will be using the MUL DE op code, so for these lets move the multiplicand to D and the multiplier to E.
                        ; The MUL D, E opcode will put the result in HL just like the other methods.

                        LD      D, E                          ; Move multiplicand to D, it was moved to E earlier to allow performance level selection
                        LD      E, B                          ; Move multiplier to E 
                        
                        CP      PERFORMANCE_NEXT_COMPACT
                        JP      Z, Multiply8x8_Next_Compact
                        CP      PERFORMANCE_NEXT_BALANCED
                        JP      Z, Multiply8x8_Next_Balanced
                        JP      Multiply8x8_Next_Maximum      ; the default is fastest Next only
;
; @COMPAT: 48K,128K,+2,+3,NEXT - device independent choice
Multiply8x8_Compact:    ; optimised for code size
                        OR      A                             ; Clear carry flag
Multiply8_Compact_Loop: RR      B                             ; Rotate multiplier right, bit 0 -> carry
                        JR      NC, Multiply8_Compact_Skip
                        ADD     HL, DE                        ; Add multiplicand (in DE) to result if bit is set.
Multiply8_Compact_Skip: EX      DE, HL
                        ADD     HL, HL                        ; Double multiplicand
                        EX      DE, HL
                        LD      A, B                          ; Check if more bits to process
                        OR      A                             ; If B is zero, we're done
                        JR      NZ, Multiply8_Compact_Loop
                        RET                                   ; Return with result in HL
;
; @COMPAT: 48K,128K,+2,+3,NEXT - device independent choice
Multiply8x8_Std:        LD      C, 8                          ; 8 bits to process
                        OR      A                             ; Clear carry flag
Multiply8_Std_Loop:     RR      B                             ; Rotate multiplier right, bit 0 -> carry
                        JR      NC, Multiply8_Std_NoAdd       ; If carry clear, skip addition
                        ADD     HL, DE                        ; Add multiplicand (in DE) to result
Multiply8_Std_NoAdd:    EX      DE, HL                        ; Swap DE and HL to allow use of ADD HL, HL
                        ADD     HL, HL                        ; Shift multiplicand left (double it)
                        EX      DE, HL                        ; Swap back
                        DEC     C                             ; Decrement bit counter
                        JR      NZ, Multiply8_Std_Loop        ; Continue if more bits to process
                        RET                                   ; Return with result in HL

;
; @COMPAT: 48K,128K,+2,+3,NEXT - device independent choice
Multiply8x8_Unrolled:   ; Bit 0 (LSB) - multiplicand × 1
                        RR      B                             ; Shift multiplier right, bit 0 -> carry
                        JR      NC, Multiply8x8_Unrolled_Bit1 ; If carry clear, skip addition
                        ADD     HL, DE                        ; Add multiplicand × 1
Multiply8x8_Unrolled_Bit1:
                        EX      DE, HL                        ; Swap DE and HL
                        ADD     HL, HL                        ; Double multiplicand (now × 2)
                        EX      DE, HL                        ; Swap back
                        RR      B                             ; Next bit of multiplier
                        JR      NC, Multiply8x8_Unrolled_Bit2 ; If carry clear, skip addition
                        ADD     HL, DE                        ; Add multiplicand × 2

Multiply8x8_Unrolled_Bit2:
                        EX      DE, HL                        ; Swap DE and HL
                        ADD     HL, HL                        ; Double multiplicand (now × 4)
                        EX      DE, HL                        ; Swap back
                        RR      B                             ; Next bit of multiplier
                        JR      NC, Multiply8x8_Unrolled_Bit3 ; If carry clear, skip addition
                        ADD     HL, DE                        ; Add multiplicand × 4

Multiply8x8_Unrolled_Bit3:
                        EX      DE, HL                        ; Swap DE and HL
                        ADD     HL, HL                        ; Double multiplicand (now × 8)
                        EX      DE, HL                        ; Swap back
                        RR      B                             ; Next bit of multiplier
                        JR      NC, Multiply8x8_Unrolled_Bit4 ; If carry clear, skip addition
                        ADD     HL, DE                        ; Add multiplicand × 8

Multiply8x8_Unrolled_Bit4:
                        EX      DE, HL                        ; Swap DE and HL
                        ADD     HL, HL                        ; Double multiplicand (now × 16)
                        EX      DE, HL                        ; Swap back
                        RR      B                             ; Next bit of multiplier
                        JR      NC, Multiply8x8_Unrolled_Bit5 ; If carry clear, skip addition
                        ADD     HL, DE                        ; Add multiplicand × 16

Multiply8x8_Unrolled_Bit5:
                        EX      DE, HL                        ; Swap DE and HL
                        ADD     HL, HL                        ; Double multiplicand (now × 32)
                        EX      DE, HL                        ; Swap back
                        RR      B                             ; Next bit of multiplier
                        JR      NC, Multiply8x8_Unrolled_Bit6 ; If carry clear, skip addition
                        ADD     HL, DE                        ; Add multiplicand × 32

Multiply8x8_Unrolled_Bit6:
                        EX      DE, HL                        ; Swap DE and HL
                        ADD     HL, HL                        ; Double multiplicand (now × 64)
                        EX      DE, HL                        ; Swap back
                        RR      B                             ; Next bit of multiplier
                        JR      NC, Multiply8x8_Unrolled_Bit7 ; If carry clear, skip addition
                        ADD     HL, DE                        ; Add multiplicand × 64

Multiply8x8_Unrolled_Bit7:
                        EX      DE, HL                        ; Swap DE and HL
                        ADD     HL, HL                        ; Double multiplicand (now × 128)
                        EX      DE, HL                        ; Swap back
                        RR      B                             ; MSB of multiplier
                        RET     NC                            ; If carry clear, we're done. Return with result in HL
                        ADD     HL, DE                        ; Add multiplicand × 128
                        RET                                   ; Return with result in HL
;
; @COMPAT: NEXT
; @Z80N: MUL DE
; @REQUIRES: Spectrum Next, Z80N architecture.
Multiply8x8_Next_Compact:
                        MUL     DE                            ; Z80N op code. DE = D * E.
                        EX      DE, HL                        ; Swap DE and HL - MUL DE puts result in DE, we want it in HL
                        RET
;
; @COMPAT: NEXT
; @Z80N: MUL DE
; @REQUIRES: Spectrum Next, Z80N architecture.
Multiply8x8_Next_Maximum:                                     ; Includes special case handling
                        LD      HL, 0                         ; Clear HL for result
                        LD      A, D                          ; Load multiplicand into A
                        OR      A                             ; Check if multiplicand is zero, which also sets no overflow Z, HL is correct value at 0
                        RET     Z
                        DEC     A                             ; this checks for 1 x multiplier, so no multiplication needed.
                        JP      Z, Next8_Multiplicand_1
                        LD      A, E                          ; Load multiplier into A
                        OR      A                             ; Check if multiplier is zero, which also sets no overflow Z, HL is correct value at 0
                        RET     Z
                        DEC     A                             ; this checks for multiplicand x 1, so no multiplication needed.
                        JP      Z, Next8_Multiplier_1
;
; @COMPAT: NEXT
; @Z80N: MUL DE
; @REQUIRES: Spectrum Next, Z80N architecture.
Multiply8x8_Next_Balanced:
                        PUSH    DE                            ; Save DE for access to multiplicand and multiplier
                        MUL     DE                            ; Z80N op code. DE = D * E.
                        EX      DE, HL                        ; Swap DE and HL - MUL DE puts result in DE, we want it in HL
                        POP     DE                            ; Restore DE multiplicand and multiplier
Next8_SetOverflowFlag:  LD      A, H                          ; Check high byte (4 T-states)
                        ; Set overflow indicator - Z set is no overflow, otherise NZ is set
                        OR      A                             ; Set flags (4 T-states)
                        RET                                   ; Return with Z bit set if no overflow, otherwise NZ is set.
Next8_Multiplicand_1:   LD      L, E                          ; If multiplicand is 1, result is just multiplier
                        JR      Next8_SetOverflowFlag
Next8_Multiplier_1:     LD      L, D                          ; If multiplier is 1, result is just multiplicand
                        JR      Next8_SetOverflowFlag
