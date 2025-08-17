TestCase040:        ; Test case 2: 12 × 8 = 96  (using Z80N op codes) 
                    LD      A, 12               ; Multiplicand
                    LD      B, 8                ; Multiplier
                    LD      C, PERFORMANCE_NEXT_MAXIMUM
                    CALL    Multiply8x8_Unified

                    ; if overflow (NZ) is set, then test failed (96 does not overflow)
                    JR      NZ, Test040Failed

                    ; Result should be 96 in HL
                    LD      DE, 96              ; Expected result
                    OR      A                   ; Clear carry
                    SBC     HL, DE              ; Compare result with expected
                    LD      HL, MsgTestCase040
                    RET     Z                   ; Z set is test passed, else test failed.
Test040Failed:      LD      HL, MsgTestCase040
                    LD      A, 2                ; Test number
                    JP      PrintFailedMessage

MsgTestCase040:     DB      " Z80N (12 x 8 = 96)", 0