TestCase039:        ; Test case 3: 15 × 17 = 255  (using Z80N op codes) 
                    LD      A, 15           ; Multiplicand
                    LD      B, 17           ; Multiplier
                    LD      C, PERFORMANCE_NEXT_BALANCED
                    CALL    Multiply8x8_Unified

                    ; if overflow (NZ) is set, then test failed (255 does not overflow)
                    JR      NZ, Test039Failed

                    ; Result should be 255 in HL
                    LD      DE, 255         ; Expected result
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare result with expected
                    LD      HL, MsgTestCase039
                    RET     Z               ; Z set is test passed, else test failed.
Test039Failed:      LD      HL, MsgTestCase039
                    LD      A, 39           ; Test number
                    JP      PrintFailedMessage

MsgTestCase039:     DB      " Z80N (15 x 17 = 255)", 0