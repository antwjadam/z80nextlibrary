TestCase004:        ; Test case 4: 0 × 123 = 0
                    LD      A, 0            ; Multiplicand
                    LD      B, 123          ; Multiplier
                    LD      C, PERFORMANCE_MAXIMUM
                    CALL    Multiply8x8_Unified

                    ; Result should be 0 in HL
                    LD      A, H            ; Check high byte
                    OR      L               ; OR with low byte
                    LD      HL, MsgTestCase004
                    RET     Z               ; Z set is test passed, else test failed.
Test4Failed:        LD      A, 4            ; Test number
                    JP      PrintFailedMessage

MsgTestCase004:     DB      " (0 x 123 = 0)", 0
