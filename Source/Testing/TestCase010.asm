TestCase010:        ; Test case 10: 5000 ÷ 13 = 384 remainder 8 (16-bit division)
                    LD      HL, 5000        ; Dividend (16-bit)
                    LD      B, 13           ; Divisor
                    LD      C, PERFORMANCE_BALANCED
                    CALL    Divide16x8_Unified

                    ; Result should be HL=384, A=8
                    PUSH    AF              ; Save remainder
                    LD      DE, 384         ; Expected quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare quotient
                    LD      HL, MsgTestCase010
                    JR      NZ, Test10Failed
                    POP     AF              ; Restore remainder
                    CP      8               ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
                    PUSH    AF              ; Balance the stack for drop thru
Test10Failed:       POP     AF              ; Clean up stack
                    LD      A, 10
                    JP      PrintFailedMessage

MsgTestCase010:     DB      " (5000 / 13 = 384r8)", 0
