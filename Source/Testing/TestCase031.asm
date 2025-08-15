TestCase031:        ; Test case 31: 6 × 3 = 15         - Added due to Unified Refactor           
                    LD      A, 6                    ; Multiplicand
                    LD      B, 3                    ; Multiplier
                    LD      C, PERFORMANCE_COMPACT
                    CALL    Multiply8x8_Unified

                    ; Result should be 18 in HL
                    LD      DE, 18                  ; Expected result
                    OR      A                       ; Clear carry
                    SBC     HL, DE                  ; Compare result with expected
                    LD      HL, MsgTestCase031
                    RET     Z                       ; Z set is test passed, else test failed.
Test031Failed:      LD      A, 31                   ; Test number
                    JP      PrintFailedMessage

MsgTestCase031:     DB      " (6 x 3 = 18)", 0