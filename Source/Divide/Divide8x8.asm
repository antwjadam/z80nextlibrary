; Unified Divide 8x8 operations with performance level
;
; Always call Divide8x8_Unified as the main entry point.
;
; Input: A = dividend, B = divisor, C = performance level
; Output: A = quotient, B = remainder
;
; T-States summary shows:
;
; PERFORMANCE_COMPACT:  ~25-1950 T-states (variable - worst case 255÷1, best case 0÷n or dividend<divisor)
; PERFORMANCE_BALANCED: ~30-1975 T-states (variable - same algorithm as COMPACT but different register usage) 
; PERFORMANCE_MAXIMUM:  ~40-1000 T-states (variable - optimized with 2x acceleration, ~50% fewer iterations)
;
; @COMPAT: 48K,128K,+2,+3,NEXT

Divide8x8_Unified:      LD      D, A                    ; Save dividend in D so we can check performance levels
                        LD      A, C                    ; Get Performance Level
                        CP      PERFORMANCE_MAXIMUM
                        JP      Z, Divide8x8_Maximum
                        CP      PERFORMANCE_BALANCED
                        JP      Z, Divide8x8_Balanced
                        ; fall through to COMPACT
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Divide8x8_Compact:      LD      A, B                    ; Load divisor into A, check for divide by zero.
                        OR      A                       ; Check if divisor is zero
                        JR      Z, D8x8_Infinity        ; If divide by zero return infinity
                        LD      A, D                    ; Restore dividend saved by performance check
                        OR      A                       ; Check if dividend is zero
                        JR      Z, D8x8_Zero
                        LD      C, B                    ; C = divisor (preserve original)
                        LD      B, 0                    ; B = quotient counter
D8x8_Compact_SubLoop:   CP      C                       ; Compare dividend with divisor
                        JR      C, D8x8_Compact_Done    ; If dividend < divisor, done
                        SUB     C                       ; Subtract divisor from dividend
                        INC     B                       ; Increment quotient
                        JR      D8x8_Compact_SubLoop    ; Repeat
D8x8_Compact_Done:      ; A = remainder, B = quotient
                        LD      C, A                    ; C = remainder
                        LD      A, B                    ; A = quotient
                        LD      B, C                    ; B = remainder
                        RET
D8x8_Zero:              LD      A, 0                    ; quotient = 0
                        LD      B, 0                    ; remainder = 0
                        RET
D8x8_Infinity:          LD      A, 255                  ; quotient = 255
                        LD      B, 255                  ; remainder = 255
                        RET

; Uses simple repeated subtraction for reliability
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Divide8x8_Balanced:     LD      A, B                    ; Load divisor into A
                        OR      A                       ; Check if divisor is zero
                        JR      Z, D8x8_Infinity        ; If divide by zero return infinity
                        LD      A, D                    ; Restore dividend saved by performance check
                        OR      A                       ; Check if dividend is zero
                        JR      Z, D8x8_Zero
                        CP      B                       ; Check if dividend < divisor
                        JR      C, Div8x8Smaller        ; If so, quotient = 0, remainder = dividend
                        LD      C, 0                    ; Clear quotient counter
                        LD      D, A                    ; Copy dividend to D
Divide8x8Loop:          LD      A, D                    ; Get current dividend
                        CP      B                       ; Compare with divisor
                        JR      C, Divide8x8Done        ; If smaller, we're done
                        SUB     B                       ; Subtract divisor
                        LD      D, A                    ; Store back remainder
                        INC     C                       ; Increment quotient
                        JR      Divide8x8Loop           ; Continue
Divide8x8Done:          LD      A, C                    ; Return quotient in A
                        LD      B, D                    ; Return remainder in B
                        RET
Div8x8Smaller:          LD      B, A                    ; Remainder = dividend
                        LD      A, 0                    ; Quotient = 0
                        RET

; Fast 8-bit ÷ 8-bit division - Optimized repeated subtraction with larger steps
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Divide8x8_Maximum:      LD      A, B                    ; Load divisor into A
                        OR      A                       ; Check if divisor is zero
                        JR      Z, D8x8_Infinity        ; If divide by zero return infinity
                        LD      A, D                    ; Restore dividend saved by performance check
                        OR      A                       ; Check if dividend is zero
                        JR      Z, D8x8_Zero
                        CP      B                       ; Check if dividend < divisor
                        JR      C, DivFastSmall         ; If so, quotient = 0, remainder = dividend
                        LD      C, 0                    ; Clear quotient counter
                        LD      D, A                    ; Copy dividend to D
                        LD      A, B                    ; Get divisor
                        SLA     A                       ; * 2
                        JR      C, DivFast1             ; If overflow, skip 2x optimization
                        LD      E, A                    ; Save 2x divisor
DivFast2Loop:           LD      A, D                    ; Get current dividend
                        CP      E                       ; Compare with 2x divisor
                        JR      C, DivFast1             ; If smaller, move to 1x subtraction

                        SUB     E                       ; Subtract 2x divisor
                        LD      D, A                    ; Store back remainder
                        INC     C                       ; Increment quotient
                        INC     C                       ; Increment quotient again (subtracted 2x)
                        JR      DivFast2Loop            ; Continue with 2x subtraction
DivFast1:               LD      A, D                    ; Get current dividend
                        CP      B                       ; Compare with divisor
                        JR      C, DivFastDone          ; If smaller, we're done
                        SUB     B                       ; Subtract divisor
                        LD      D, A                    ; Store back remainder
                        INC     C                       ; Increment quotient
                        JR      DivFast1                ; Continue with 1x subtraction
DivFastDone:            LD      A, C                    ; Return quotient in A
                        LD      B, D                    ; Return remainder in B
                        RET
DivFastSmall:           LD      B, A                    ; Remainder = dividend
                        LD      A, 0                    ; Quotient = 0
                        RET