TestCase033:        ; Test case 33: 1000 × 100 = 100000 (16x8 COMPACT multiplication)
                    LD      HL, 1000        ; 16-bit multiplicand
                    LD      B, 100          ; 8-bit multiplier
                    LD      C, PERFORMANCE_COMPACT ; Set performance level
                    CALL    Multiply16x8_Unified

                    ; Result should be 100000 = 0x0186A0 in DE:HL
                    ; DE should be 1 (0x01) and HL should be 34464 (0x86A0)
                    LD      A, D
                    CP      1               ; Check if high word high byte is 1
                    JR      NZ, Test33Failed
                    LD      A, E
                    OR      A               ; Check if high word low byte is 0
                    JR      NZ, Test33Failed
                    
                    ; Check if HL = 34464 (0x86A0)
                    PUSH    DE              ; Save high result
                    LD      DE, 34464       ; Expected low result (0x86A0)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare
                    POP     DE              ; Restore high result   
                    LD      HL, MsgTestCase033
                    RET     Z               ; Z set is test passed, else test failed.
Test33Failed:       LD      HL, MsgTestCase033
                    LD      A, 33
                    JP      PrintFailedMessage

MsgTestCase033:     DB      " (1000 x 100 = 100000)", 0
