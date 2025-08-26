TestCase047:        ; Test case 47: Simple Z80N 16x8 8-bit reciprocal division test
                    ; Test with exact division that should work perfectly
                    LD      HL, 256         ; 16-bit dividend
                    LD      B, 1            ; 8-bit divisor (table[1] = 255 ≈ 256)
                    LD      C, PERFORMANCE_NEXT_BALANCED ; Use Z80N 8-bit reciprocal
                    CALL    Divide16x8_Unified

                    ; Expected: 256 ÷ 1 = 256 remainder 0
                    PUSH    AF              ; Save remainder
                    LD      DE, 250         ; Minimum acceptable quotient (allow small error)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Check if quotient >= 250
                    JP      C, Test47Failed ; Quotient too small
                    ADD     HL, DE          ; Restore quotient
                    LD      DE, 260         ; Maximum acceptable quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Check if quotient <= 260
                    JP      NC, Test47Failed ; Quotient too large
                    
                    POP     AF              ; Get remainder
                    CP      10              ; Check if remainder <= 10
                    JP      C, SetTest47Passing                    
Test47Failed:       POP     AF              ; Clean stack - remainder  
                    LD      HL, MsgTestCase047
                    LD      A, 47
                    JP      PrintFailedMessage
SetTest47Passing:   LD      HL, MsgTestCase047
                    XOR     A
                    OR      A               ; Set Z flag
                    RET                     ; returns with Z set to indicate test passes.

MsgTestCase047:     DB      " Z80N 16x8 (8-bt rec)", 0
