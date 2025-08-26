TestCase041:        ; Test case 41: 1000 × 100 = 100000 (16x8 COMPACT multiplication, using Z80N op codes)
                    LD      HL, 1000        ; 16-bit multiplicand
                    LD      B, 100          ; 8-bit multiplier
                    LD      C, PERFORMANCE_NEXT_COMPACT ; Set performance level
                    CALL    Multiply16x8_Unified

                    ; Result should be 100000 = 0x0186A0 in DE:HL
                    ; DE should be 1 (0x01) and HL should be 34464 (0x86A0)
                    LD      A, D
                    CP      1               ; Check if high word high byte is 1
                    JR      NZ, Test041Failed
                    LD      A, E
                    OR      A               ; Check if high word low byte is 0
                    JR      NZ, Test041Failed

                    ; Check if HL = 34464 (0x86A0)
                    PUSH    DE              ; Save high result
                    LD      DE, 34464       ; Expected low result (0x86A0)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare
                    POP     DE              ; Restore high result   
                    LD      HL, MsgTestCase041
                    RET     Z               ; Z set is test passed, else test failed.
Test041Failed:      LD      HL, MsgTestCase041
                    LD      A, 41
                    JP      PrintFailedMessage

MsgTestCase041:     DB      " Z80N (1Kx100=100K)", 0
