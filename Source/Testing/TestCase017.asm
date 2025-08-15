TestCase017:             ; Test case 17: Middle Square random number generator
                    LD      A, 3            ; Upper limit (inclusive)
                    LD      B, 57           ; Set seed to 57
                    LD      C, PERFORMANCE_RANDOM_MIDDLESQUARE

                    CALL    Random8_Unified_Seed
                    ; A now contains first random number in range 0-3
                    CP      4               ; Check if <= 3
                    JR      NC, Test17Failed ; If >= 4, test failed
                    
                    ; Test range 0-10 (limit = 10, inclusive)
                    LD      A, 10           ; Upper limit (inclusive)
                    LD      C, PERFORMANCE_RANDOM_MIDDLESQUARE

                    CALL    Random8_Unified_Next
                    CP      11              ; Check if <= 10
                    LD      HL, MsgTestCase017
                    JP      C, SetTestPassing ; if < 11, test passed.
Test17Failed:       LD      HL, MsgTestCase017
                    LD      A, 17
                    JP      PrintFailedMessage

MsgTestCase017:     DB      " Random Mid Square", 0