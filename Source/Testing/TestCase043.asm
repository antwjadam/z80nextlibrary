TestCase043:        ; Test case 43: 500 × 200 = 100000 (16x8 MAXIMUM multiplication, using Z80N op codes)
                    LD      HL, 500         ; 16-bit multiplicand
                    LD      B, 200          ; 8-bit multiplier
                    LD      C, PERFORMANCE_NEXT_MAXIMUM ; Set performance level
                    CALL    Multiply16x8_Unified

                    ; Result should be 100000 = 0x0186A0 in DE:HL
                    ; DE should be 1 (0x01) and HL should be 34464 (0x86A0)
                    LD      A, D
                    CP      1               ; Check if high word high byte is 1
                    JR      NZ, Test043Failed
                    LD      A, E
                    OR      A               ; Check if high word low byte is 0
                    JR      NZ, Test043Failed

                    ; Check if HL = 34464 (0x86A0)
                    PUSH    DE              ; Save high result
                    LD      DE, 34464       ; Expected low result (0x86A0)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare
                    POP     DE              ; Restore high result
                    LD      HL, MsgTestCase043
                    RET     Z               ; Z set is test passed, else test failed.
Test043Failed:      LD      HL, MsgTestCase043
                    LD      A, 43
                    JP      PrintFailedMessage

MsgTestCase043:     DB      " Z80N (500x200=100K)", 0