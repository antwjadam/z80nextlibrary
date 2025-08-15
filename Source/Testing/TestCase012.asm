TestCase012:        ; Test case 12: 200 × 25 = 5000 (16x8 fast multiplication)
                    LD      HL, 200         ; 16-bit multiplicand
                    LD      B, 25           ; 8-bit multiplier
                    LD      C, PERFORMANCE_MAXIMUM
                    CALL    Multiply16x8_Unified

                    ; Result should be 5000 = 0x1388 in DE:HL
                    ; Since 5000 fits in 16 bits, DE should be 0 and HL should be 5000
                    LD      A, D
                    OR      E               ; Check if high word is zero
                    JR      NZ, Test12Failed ; Should be zero for this test case
                    
                    ; Check if HL = 5000 (0x1388)
                    PUSH    DE              ; Save high result  
                    LD      DE, 5000        ; Expected low result
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare
                    POP     DE              ; Restore high result
                    LD      HL, MsgTestCase012
                    RET     Z               ; Z set is test passed, else test failed.
Test12Failed:       LD      HL, MsgTestCase012
                    LD      A, 12
                    JP      PrintFailedMessage

MsgTestCase012:     DB      " (200 x 25 = 5000)", 0
