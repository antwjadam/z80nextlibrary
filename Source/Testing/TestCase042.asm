TestCase042:        ; Test case 42: 2000 × 50 = 100000 (16x8 BALANCED multiplication, using Z80N op codes)
                    LD      HL, 2000        ; 16-bit multiplicand
                    LD      B, 50           ; 8-bit multiplier
                    LD      C, PERFORMANCE_NEXT_BALANCED ; Set performance level
                    CALL    Multiply16x8_Unified

                    ; Result should be 100000 = 0x0186A0 in DE:HL
                    ; DE should be 1 (0x01) and HL should be 34464 (0x86A0)
                    LD      A, D
                    CP      1               ; Check if high word high byte is 1
                    JR      NZ, Test042Failed
                    LD      A, E
                    OR      A               ; Check if high word low byte is 0
                    JR      NZ, Test042Failed

                    ; Check if HL = 34464 (0x86A0)
                    PUSH    DE              ; Save high result
                    LD      DE, 34464       ; Expected low result (0x86A0)
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare
                    POP     DE              ; Restore high result   
                    LD      HL, MsgTestCase042
                    RET     Z               ; Z set is test passed, else test failed.
Test042Failed:      LD      HL, MsgTestCase042
                    LD      A, 42
                    JP      PrintFailedMessage

MsgTestCase042:     DB      " Z80N (2K x 50 = 100K)", 0