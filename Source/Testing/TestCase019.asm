TestCase019:        ; Test case 19: 16-bit XORShift random number generator
                    LD      HL, 127         ; Upper limit (inclusive)
                    LD      BC, 54321       ; Set seed to 54321
                    LD      D, PERFORMANCE_RANDOM_XORSHIFT
                    CALL    Random16_Unified_Seed

                    ; HL now contains first random number in range 0-127
                    LD      DE, 128         ; Check if <= 127 (same as < 128)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare HL with 128
                    ADD     HL, DE          ; Restore HL
                    JR      NC, Test19Failed ; If >= 128, test failed
                    
                    ; Test range 0-255 (limit = 255, inclusive)  
                    LD      HL, 255         ; Upper limit (inclusive)
                    LD      D, PERFORMANCE_RANDOM_XORSHIFT
                    CALL    Random16_Unified_Next

                    ; HL now contains first random number in range 0-255
                    LD      DE, 256         ; Check if <= 255 (same as < 256)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare HL with 256
                    LD      HL, MsgTestCase019
                    JP      C, SetTestPassing ; If carry set, test passed
Test19Failed:       LD      HL, MsgTestCase019
                    LD      A, 19
                    JP      PrintFailedMessage

MsgTestCase019:     DB      " Random16 XOR", 0
