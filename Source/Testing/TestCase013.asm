TestCase013:        ; Test case 13: 5000 ÷ 25 = 200 remainder 0 (16x8 fast division)
                    LD      HL, 5000        ; 16-bit dividend
                    LD      B, 25           ; 8-bit divisor
                    LD      C, PERFORMANCE_MAXIMUM
                    CALL    Divide16x8_Unified

                    ; Result should be quotient=200 in HL, remainder=0 in A
                    PUSH    AF              ; Save remainder
                    LD      DE, 200         ; Expected quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare quotient
                    JR      NZ, Test13Failed ; Quotient mismatch
                    POP     AF              ; Get remainder
                    OR      A               ; Check if remainder is 0
                    LD      HL, MsgTestCase013
                    RET     Z               ; Z set is test passed, else test failed.
                    PUSH    AF
Test13Failed:       POP     AF
                    LD      HL, MsgTestCase013
                    LD      A, 13
                    JP      PrintFailedMessage

MsgTestCase013:      DB      " (5000 / 25 = 200r0)", 0
