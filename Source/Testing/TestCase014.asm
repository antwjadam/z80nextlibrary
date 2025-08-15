TestCase014:        ; Test case 14: Random number generator validation LCG
                    ; Test that random numbers are within specified range (inclusive)
                    LD      A, 7            ; Upper limit (inclusive) 
                    LD      B, 42           ; Set seed to 42
                    LD      C, PERFORMANCE_RANDOM_LCG

                    CALL    Random8_Unified_Seed
                    ; A now contains first random number in range 0-7
                    CP      8               ; Check if < 8
                    JR      NC, Test14Failed ; If >= 8, test failed

                    ; Test range 0-9 (limit = 9, inclusive)  
                    LD      A, 9            ; Upper limit (inclusive)
                    LD      C, PERFORMANCE_RANDOM_LCG

                    CALL    Random8_Unified_Next
                    CP      10              ; Check if < 10
                    JR      NC, Test14Failed ; If >= 10, test failed

                    ; Test edge case: limit = 1 (should return 0 or 1)
                    LD      A, 1            ; Upper limit (inclusive)
                    LD      C, PERFORMANCE_RANDOM_LCG

                    CALL    Random8_Unified_Next
                    CP      2               ; Check if < 2
                    JR      NC, Test14Failed ; If >= 2, test failed

                    ; Test edge case: limit = 0 (should return 0)
                    LD      A, 0            ; Upper limit (inclusive)
                    LD      C, PERFORMANCE_RANDOM_LCG

                    CALL    Random8_Unified_Next
                    OR      A               ; Check if 0
                    LD      HL, MsgTestCase014
                    RET     Z               ; Z set is test passed, else test failed.
Test14Failed:       LD      HL, MsgTestCase014
                    LD      A, 14
                    JP      PrintFailedMessage

MsgTestCase014:     DB      " Random LCG", 0
