TestCase053:        ; Test case 17: Middle Square random number generator
                    LD      A, 3                ; Upper limit (inclusive)
                    LD      B, 57               ; Set seed to 57
                    LD      C, PERFORMANCE_Z80N_RANDOM_MIDDLESQUARE

                    CALL    Random8_Unified_Seed

                    ; A now contains first random number in range 0-3
                    CP      4                   ; Check if <= 3
                    JR      NC, Test053Failed   ; If >= 4, test failed
                    
                    ; Test range 0-10 (limit = 10, inclusive)
                    LD      A, 10               ; Upper limit (inclusive)
                    LD      C, PERFORMANCE_Z80N_RANDOM_MIDDLESQUARE

                    CALL    Random8_Unified_Next
                    CP      11                  ; Check if <= 10
                    LD      HL, MsgTestCase053
                    JP      C, SetTestPassing   ; if < 11, test passed.
Test053Failed:      LD      HL, MsgTestCase053
                    LD      A, 53
                    JP      PrintFailedMessage

MsgTestCase053:     DB      " Z80N Random Mid Sq", 0