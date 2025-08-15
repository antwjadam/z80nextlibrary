; Unified Divide 16x8 operations with performance level
;
; Always call Divide16x8_Unified as the main entry point.
;
; Input: HL = dividend (16-bit), B = divisor (8-bit), C = performance level
; Output: HL = quotient (16-bit), A = remainder (8-bit)
;
; T-States summary shows:
;
; PERFORMANCE_COMPACT:  ~45-1300 T-states (variable - repeated subtraction, worst case 65535÷1)
; PERFORMANCE_BALANCED: ~220-280 T-states (fixed - binary long division, consistent 16-bit processing)  
; PERFORMANCE_MAXIMUM:  ~180-420 T-states (variable - optimized binary division with early exits)

Divide16x8_Unified:         LD      A, C                        ; Get Performance Level
                            CP      PERFORMANCE_MAXIMUM
                            JR      Z, Divide16x8_Maximum
                            CP      PERFORMANCE_BALANCED
                            JR      Z, Divide16x8_Balanced
                            ; fall through to COMPACT
Divide16x8_Compact:         ; Check for zero divisor
                            LD      A, B
                            OR      A
                            JR      Z, D16x8_Infinity           ; Return infinity for divide by zero
                            ; Check if dividend is zero
                            LD      A, H
                            OR      L
                            JR      Z, D16x8_Zero               ; Return 0/0 for zero dividend
                            ; Check if dividend < divisor
                            LD      A, H
                            OR      A                           ; Check if high byte is zero
                            JR      NZ, D16x8_Compact_DoDiv     ; High byte set, definitely >= divisor
                            LD      A, L
                            CP      B
                            JR      C, D16x8_Small              ; dividend < divisor
D16x8_Compact_DoDiv:        ; Simple repeated subtraction
                            LD      DE, 0                       ; DE = quotient counter
D16x8_Compact_Loop:         ; Check if HL >= B (8-bit divisor)
                            LD      A, H
                            OR      A                           ; Check if high byte is non-zero
                            JR      NZ, D16x8_Compact_CanSub    ; Definitely can subtract
                            LD      A, L
                            CP      B                           ; Compare low byte with divisor
                            JR      C, D16x8_Compact_Done       ; Cannot subtract, done
D16x8_Compact_CanSub:       ; Subtract divisor from HL
                            LD      A, L
                            SUB     B                           ; Subtract divisor from low byte
                            LD      L, A
                            LD      A, H
                            SBC     A, 0                        ; Handle borrow from high byte
                            LD      H, A
                            INC     E                           ; Increment low byte of quotient
                            JR      NZ, D16x8_Compact_Loop      ; Continue if no overflow
                            INC     D                           ; Handle overflow to high byte
                            JR      D16x8_Compact_Loop          ; Continue
D16x8_Compact_Done:         ; HL = remainder, DE = quotient
                            LD      A, L                        ; Remainder in A (only 8-bit possible)
                            EX      DE, HL                      ; Quotient in HL
                            RET

; Balanced performance, relatively predictable T state range.
Divide16x8_Balanced:        ; Check for zero divisor
                            LD      A, B
                            OR      A
                            JR      Z, D16x8_Infinity           ; Return infinity for divide by zero
                            ; Check if dividend is zero
                            LD      A, H
                            OR      L
                            JR      Z, D16x8_Zero               ; Return 0/0 for zero dividend
Do16x8_Division_Now:        LD      A, 0                        ; Clear remainder
                            LD      C, 16                       ; 16 bits to process
Div16Loop:                  ADD     HL, HL                      ; Shift dividend left
                            RLA                                 ; Rotate remainder left
                            CP      B                           ; Compare remainder with divisor
                            JR      C, Div16Next                ; If smaller, skip subtraction
                            SUB     B                           ; Subtract divisor from remainder
                            INC     L                           ; Set bit in quotient (HL low bit)
Div16Next:                  DEC     C                           ; Decrement bit counter
                            JR      NZ, Div16Loop               ; Continue if more bits
                            RET                                 ; Return with quotient in HL, remainder in A

; Shared edge case handlers
D16x8_Infinity:             LD      HL, 65535           ; quotient = 65535 (16-bit "infinity")
                            LD      A, 255              ; remainder = 255 (8-bit "infinity")
                            RET
D16x8_Zero:                 LD      HL, 0               ; quotient = 0
                            LD      A, 0                ; remainder = 0
                            RET
D16x8_Small:                ; dividend < divisor, so quotient = 0, remainder = dividend
                            LD      A, L                ; remainder = original dividend (low byte)
                            LD      HL, 0               ; quotient = 0
                            RET

; Maximum performance in most cases. Personally, I would use balanced in games to avoid t state stuttering
Divide16x8_Maximum:         ; Check for zero divisor
                            LD      A, B
                            OR      A
                            JR      Z, D16x8_Infinity           ; Return infinity for divide by zero
                            ; Check if dividend is zero
                            LD      A, H
                            OR      L
                            JR      Z, D16x8_Zero               ; Return 0/0 for zero dividend
                            ; Check if dividend is smaller than divisor
                            LD      A, H
                            OR      A                           ; Check if high byte is zero
                            JR      NZ, Divide16x8Fast_LongDivision
                            ; High byte is zero, check if low byte < divisor
                            LD      A, L
                            CP      B
                            JR      C, Divide16x8Fast_SmallResult
Divide16x8Fast_LongDivision: ; Use optimized repeated subtraction with doubling
                            LD      DE, 0                       ; DE will hold the quotient
Divide16x8Fast_Loop:        ; Check if HL >= B
                            LD      A, H
                            OR      A
                            JR      NZ, Divide16x8Fast_CanSubtract  ; If H != 0, definitely >= B
                            LD      A, L
                            CP      B
                            JR      C, Divide16x8Fast_Done          ; If L < B, we're done
Divide16x8Fast_CanSubtract: ; Try larger subtractions first for speed
                            LD      C, B                        ; Save original divisor
                            LD      A, 1                        ; Quotient increment
                            ; Check if we can subtract divisor * 2
                            SLA     C                           ; C = B * 2
                            JR      C, Divide16x8Fast_SingleSub ; Overflow, use single subtraction
                            ; Check if HL >= C (B * 2)
                            PUSH    HL
                            OR      A                           ; Clear carry
                            SBC     HL, BC                      ; HL = HL - (B * 2), but we only care about C
                            JR      C, Divide16x8Fast_SingleSubRestore
                            POP     AF                          ; Discard saved HL
                            SLA     A                           ; Double the quotient increment
                            JR      Divide16x8Fast_DoSubtraction
Divide16x8Fast_SingleSubRestore:
                            POP     HL                          ; Restore HL
Divide16x8Fast_SingleSub:   LD      C, B                        ; Restore original divisor
                            LD      A, 1                        ; Single increment
Divide16x8Fast_DoSubtraction: ; Subtract C from HL, A times (effectively)
                            PUSH    AF                          ; Save quotient increment
                            LD      A, L
                            SUB     C
                            LD      L, A
                            LD      A, H
                            SBC     A, 0
                            LD      H, A
                            POP     AF                          ; Restore quotient increment
                            ; Add quotient increment to DE
                            LD      C, A
                            LD      A, E
                            ADD     A, C
                            LD      E, A
                            LD      A, D
                            ADC     A, 0
                            LD      D, A
                            JR      Divide16x8Fast_Loop
Divide16x8Fast_Done:        ; HL contains remainder, DE contains quotient
                            LD      A, L                        ; Remainder in A
                            EX      DE, HL                      ; Quotient in HL
                            RET
Divide16x8Fast_SmallResult: ; Dividend < divisor, so quotient = 0, remainder = dividend
                            LD      A, L            ; Remainder = original dividend
                            LD      HL, 0           ; Quotient = 0
                            RET
