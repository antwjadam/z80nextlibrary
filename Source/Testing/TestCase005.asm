TestCase005:        ; Test case 5: 16 × 16 = 256
                    LD      A, 16           ; Multiplicand
                    LD      B, 16           ; Multiplier
                    LD      C, PERFORMANCE_BALANCED
                    CALL    Multiply8x8_Unified

                    ; Result should be 256 in HL
                    LD      DE, 256         ; Expected result
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare result with expected
                    LD      HL, MsgTestCase005
                    RET     Z               ; Z set is test passed, else test failed.
Test5Failed:        LD      A, 5            ; Test number
                    JP      PrintFailedMessage

MsgTestCase005:     DB      " (16 x 16 = 256)", 0
