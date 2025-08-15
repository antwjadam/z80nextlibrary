TestCase003:        ; Test case 3: 15 × 17 = 255
                    LD      A, 15           ; Multiplicand
                    LD      B, 17           ; Multiplier
                    LD      C, PERFORMANCE_BALANCED
                    CALL    Multiply8x8_Unified

                    ; Result should be 255 in HL
                    LD      DE, 255         ; Expected result
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare result with expected
                    LD      HL, MsgTestCase003
                    RET     Z               ; Z set is test passed, else test failed.
Test3Failed:        LD      A, 3            ; Test number
                    JP      PrintFailedMessage

MsgTestCase003:     DB      " (15 x 17 = 255)", 0
