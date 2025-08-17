TestCase001:        ; Test case 1: 5 × 3 = 15                    
                    LD      A, 5            ; Multiplicand
                    LD      B, 3            ; Multiplier
                    LD      C, PERFORMANCE_COMPACT
                    CALL    Multiply8x8_Unified

                    ; Result should be 15 in HL
                    LD      DE, 15          ; Expected result
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare result with expected
                    LD      HL, MsgTestCase001
                    RET     Z               ; Z set is test passed, else test failed.
Test1Failed:        LD      A, 1            ; Test number
                    JP      PrintFailedMessage

MsgTestCase001:     DB      " (5 x 3 = 15)", 0
