TestCase011:        ; Test case 11: 1000 × 50 = 50000 (16x8 multiplication)
                    LD      HL, 1000        ; 16-bit multiplicand
                    LD      B, 50           ; 8-bit multiplier
                    LD      C, PERFORMANCE_BALANCED ; Set performance level
                    CALL    Multiply16x8_Unified

                    ; Result should be 50000 = 0xC350 in DE:HL
                    ; Since 50000 fits in 16 bits, DE should be 0 and HL should be 50000
                    LD      A, D
                    OR      E               ; Check if high word is zero
                    JR      NZ, Test11Failed ; Should be zero for this test case
                    
                    ; Check if HL = 50000 (0xC350)
                    PUSH    DE              ; Save high result  
                    LD      DE, 50000       ; Expected low result
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare
                    POP     DE              ; Restore high result
                    LD      HL, MsgTestCase011
                    RET     Z               ; Z set is test passed, else test failed.
Test11Failed:       LD      HL, MsgTestCase011
                    LD      A, 11
                    JP      PrintFailedMessage

MsgTestCase011:     DB      " (1000 x 50 = 50000)", 0
