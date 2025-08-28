TestCase052:        ; Test case 52: LFSR random number generator for Next, Z80N opcodes used for performance.
                    LD      A, 15               ; Upper limit (inclusive)
                    LD      B, 123              ; Set seed to 123
                    LD      C, PERFORMANCE_Z80N_RANDOM_LFSR

                    CALL    Random8_Unified_Seed

                    ; A now contains first random number in range 0-15
                    CP      16                  ; Check if <= 15
                    JR      NC, Test052Failed   ; If >= 16, test failed
                    
                    ; Test multiple calls to ensure generator advances
                    LD      A, 31               ; Upper limit (inclusive)
                    LD      C, PERFORMANCE_Z80N_RANDOM_LFSR

                    CALL    Random8_Unified_Next
                    CP      32                  ; Check if < 32 (0 - 31)
                    LD      HL, MsgTestCase052
                    JP      C, SetTestPassing   ; Pass if < 32.
Test052Failed:      LD      HL, MsgTestCase052
                    LD      A, 52
                    JP      PrintFailedMessage
MsgTestCase052:     DB      " Z80N Random LFSR", 0
