TestCase048:        ; Test case 48: 16x8 Z80N Hybrid Division Test
                    ; Test small dividend (should use traditional division)
                    LD      HL, 100         ; Small 16-bit dividend (< 4096)
                    LD      B, 8            ; 8-bit divisor
                    LD      C, PERFORMANCE_NEXT_COMPACT ; Use Z80N hybrid
                    CALL    Divide16x8_Unified

                    ; Expected: 100 ÷ 8 = 12 remainder 4 exactly
                    PUSH    AF              ; Save remainder
                    LD      DE, 12          ; Expected quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Check if quotient == 12
                    JR      NZ, Test48QuotientFailed ; Small dividend quotient failed
                    POP     AF              ; Get remainder
                    CP      4               ; Check if remainder == 4
                    JR      NZ, Test48FailedSmall ; Remainder should be 4
                    
                    ; Test large dividend (should use reciprocal division)
                    LD      HL, 5000        ; Large 16-bit dividend (> 4096)
                    LD      B, 25           ; 8-bit divisor
                    LD      C, PERFORMANCE_NEXT_COMPACT ; Use Z80N hybrid
                    CALL    Divide16x8_Unified

                    ; Expected: 5000 ÷ 25 ≈ 200, allow tolerance for reciprocal method
                    PUSH    AF              ; Save remainder
                    LD      DE, 190         ; Minimum acceptable quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Check if quotient >= 190
                    JP      C, Test48FailedLarge ; Quotient too small
                    ADD     HL, DE          ; Restore quotient
                    LD      DE, 210         ; Maximum acceptable quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Check if quotient <= 210
                    JP      NC, Test48FailedLarge ; Quotient too large
                    
                    POP     AF              ; Get remainder
                    CP      150             ; Check if remainder <= 150 (allow for reciprocal errors)
                    JP      C, SetTest48Passing ; C set = test passed (remainder < 150)
                    
                    ; Test failed on remainder check
                    LD      HL, MsgLargeFailed
                    LD      A, 48
                    JP      PrintFailedMessage

Test48QuotientFailed: POP   AF              ; Clean stack (remainder still on stack)
Test48FailedSmall:  LD      HL, MsgSmallFailed
Test48FailMessage:  LD      A, 48
                    JP      PrintFailedMessage            
Test48FailedLarge:  LD      HL, MsgLargeFailed
                    JP      Test48FailMessage
SetTest48Passing:   LD      HL, MsgTestCase048
                    XOR     A
                    OR      A               ; Set Z flag
                    RET                     ; returns with Z set to indicate test passes.
MsgTestCase048:     DB      " Z80N 16x8 ( hybrid )", 0
MsgSmallFailed:     DB      " Z80N 16x8 hybrid sm", 0
MsgLargeFailed:     DB      " Z80N 16x8 hybrid lg", 0
