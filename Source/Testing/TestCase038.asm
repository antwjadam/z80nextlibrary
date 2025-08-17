TestCase038:        ; Test case 1: 5 × 3 = 15 (using Z80N op codes)                    
                    LD      A, 5            ; Multiplicand
                    LD      B, 3            ; Multiplier
                    LD      C, PERFORMANCE_NEXT_COMPACT
                    CALL    Multiply8x8_Unified

                    ; Result should be 15 in HL
                    LD      DE, 15          ; Expected result
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare result with expected
                    LD      HL, MsgTestCase038
                    RET     Z               ; Z set is test passed, else test failed.
Test038Failed:      LD      A, 38           ; Test number
                    JP      PrintFailedMessage

MsgTestCase038:     DB      " Z80N (5 x 3 = 15)", 0