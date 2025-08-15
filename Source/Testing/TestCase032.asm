TestCase032:        ; Test case 32: 1000 × 45 = 45000 (16x8 multiplication)
                    LD      HL, 1000        ; 16-bit multiplicand
                    LD      B, 45           ; 8-bit multiplier
                    LD      C, PERFORMANCE_COMPACT ; Set performance level
                    CALL    Multiply16x8_Unified

                    ; Since 45000 fits in 16 bits, DE should be 0 and HL should be 45000
                    LD      A, D
                    OR      E               ; Check if high word is zero
                    JR      NZ, Test32Failed ; Should be zero for this test case
                    
                    ; Check if HL = 45000
                    PUSH    DE              ; Save high result
                    LD      DE, 45000       ; Expected low result
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare
                    POP     DE              ; Restore high result   
                    LD      HL, MsgTestCase032
                    RET     Z               ; Z set is test passed, else test failed.
Test32Failed:       LD      HL, MsgTestCase032
                    LD      A, 32
                    JP      PrintFailedMessage

MsgTestCase032:     DB      " (1000 x 45 = 45000)", 0