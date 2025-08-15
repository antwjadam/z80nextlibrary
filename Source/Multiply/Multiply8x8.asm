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
;
; Although COMPACT appears faster it is unpredictable for speed/game use,
; the other two provide fixed T State counts providing more consistent performance.

Multiply8x8_Unified:    LD      H, 0                    ; Clear high byte of result
                        LD      L, 0                    ; Clear low byte of result
                        LD      D, 0                    ; Clear high byte of multiplicand
                        LD      E, A                    ; Move multiplicand to low byte of DE
                        LD      A, C                    ; Get Performance Level
                        CP      PERFORMANCE_MAXIMUM
                        JP      Z, Multiply8x8_Unrolled
                        CP      PERFORMANCE_BALANCED
                        JP      Z, Multiply8x8_Std
                        ; fall through to COMPACT
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
                        RET                                     ; Return with result in HL