TestCase020:        ; Test case 20: 16-bit LFSR random number generator
                    LD      HL, 511         ; Upper limit (inclusive)
                    LD      BC, 9876        ; Set seed to 9876
                    LD      D, PERFORMANCE_RANDOM_LFSR
                    CALL    Random16_Unified_Seed

                    ; HL now contains first random number in range 0-511
                    LD      DE, 512         ; Check if <= 511 (same as < 512)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare HL with 512
                    ADD     HL, DE          ; Restore HL
                    JR      NC, Test20Failed ; If >= 512, test failed
                    
                    ; Test multiple calls to ensure generator advances
                    LD      HL, 1023        ; Upper limit (inclusive)
                    LD      D, PERFORMANCE_RANDOM_LFSR
                    CALL    Random16_Unified_Next
                    LD      DE, 1024        ; Check if <= 1023 (same as < 1024)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare HL with 1024
                    LD      HL, MsgTestCase020
                    JP      C, SetTestPassing ; If carry set, test passed
Test20Failed:       LD      HL, MsgTestCase020
                    LD      A, 20
                    JP      PrintFailedMessage

MsgTestCase020:     DB      " Random16 LFSR", 0
