TestCase018:        ; Test case 18: 16-bit LCG random number generator
                    LD      HL, 999         ; Upper limit (inclusive)
                    LD      BC, 12345       ; Set seed to 12345
                    LD      D, PERFORMANCE_RANDOM_LCG
                    CALL    Random16_Unified_Seed

                    ; HL now contains first random number in range 0-999
                    LD      DE, 1000        ; Check if <= 999 (same as < 1000)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare HL with 1000
                    ADD     HL, DE          ; Restore HL
                    JR      NC, Test18Failed ; If >= 1000, test failed
                    
                    ; Test range 0-49 (limit = 49, inclusive)  
                    LD      HL, 49          ; Upper limit (inclusive)
                    LD      D, PERFORMANCE_RANDOM_LCG
                    CALL    Random16_Unified_Next
                    LD      DE, 50          ; Check if <= 49 (same as < 50)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare HL with 50
                    ADD     HL, DE          ; Restore HL
                    JR      NC, Test18Failed ; If >= 50, test failed
                    
                    ; Test edge case: limit = 0 (should return 0)
                    LD      HL, 0           ; Upper limit (inclusive)
                    LD      D, PERFORMANCE_RANDOM_LCG
                    CALL    Random16_Unified_Next
                    LD      A, H            ; Check if HL is 0
                    OR      L
                    LD      HL, MsgTestCase018
                    RET     Z               ; Z set is test passed, else test failed.
Test18Failed:       LD      HL, MsgTestCase018
                    LD      A, 18
                    JP      PrintFailedMessage

MsgTestCase018:     DB      " Random16 LCG", 0
