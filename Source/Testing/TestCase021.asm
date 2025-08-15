TestCase021:        ; Test case 21: 16-bit Middle Square random number generator
                    LD      HL, 63          ; Upper limit (inclusive)
                    LD      BC, 4567        ; Set seed to 4567
                    LD      D, PERFORMANCE_RANDOM_MIDDLESQUARE
                    CALL    Random16_Unified_Seed

                    ; HL now contains first random number in range 0-63
                    LD      DE, 64          ; Check if <= 63 (same as < 64)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare HL with 64
                    ADD     HL, DE          ; Restore HL
                    JR      NC, Test21Failed ; If >= 64, test failed
                    
                    ; Test range 0-31 (limit = 31, inclusive)
                    LD      HL, 31          ; Upper limit (inclusive)
                    LD      D, PERFORMANCE_RANDOM_MIDDLESQUARE
                    CALL    Random16_Unified_Next

                    LD      DE, 32          ; Check if <= 31 (same as < 32)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare HL with 32
                    LD      HL, MsgTestCase021
                    JP      C, SetTestPassing ; If carry set, test passed
Test21Failed:       LD      HL, MsgTestCase021
                    LD      A, 21
                    JP      PrintFailedMessage

MsgTestCase021:     DB      " Random16 Mid Square", 0
