TestCase002:        ; Test case 2: 12 × 8 = 96
                    LD      A, 12               ; Multiplicand
                    LD      B, 8                ; Multiplier
                    LD      C, PERFORMANCE_MAXIMUM
                    CALL    Multiply8x8_Unified

                    ; Result should be 96 in HL
                    LD      DE, 96              ; Expected result
                    OR      A                   ; Clear carry
                    SBC     HL, DE              ; Compare result with expected
                    LD      HL, MsgTestCase002
                    RET     Z                   ; Z set is test passed, else test failed.
Test2Failed:        LD      A, 2                ; Test number
                    JP      PrintFailedMessage

MsgTestCase002:     DB      " (12 x 8 = 96)", 0
