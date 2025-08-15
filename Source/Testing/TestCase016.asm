TestCase016:        ; Test case 16: LFSR random number generator
                    LD      A, 15           ; Upper limit (inclusive)
                    LD      B, 123          ; Set seed to 123
                    LD      C, PERFORMANCE_RANDOM_LFSR

                    CALL    Random8_Unified_Seed
                    ; A now contains first random number in range 0-15
                    CP      16              ; Check if <= 15
                    JR      NC, Test16Failed ; If >= 16, test failed
                    
                    ; Test multiple calls to ensure generator advances
                    LD      A, 31           ; Upper limit (inclusive)
                    LD      C, PERFORMANCE_RANDOM_LFSR

                    CALL    Random8_Unified_Next
                    CP      32              ; Check if < 32 (0 - 31)
                    LD      HL, MsgTestCase016
                    JP      C, SetTestPassing ; Pass if < 32.
                    
Test16Failed:       LD      HL, MsgTestCase016
                    LD      A, 16
                    JP      PrintFailedMessage

MsgTestCase016:     DB      " Random LFSR", 0
