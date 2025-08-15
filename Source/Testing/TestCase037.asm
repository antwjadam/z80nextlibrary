TestCase037:        ; Test case 37: 5000 ÷ 13 = 384 remainder 8 (16-bit division)
                    LD      HL, 5000        ; Dividend (16-bit)
                    LD      B, 13           ; Divisor
                    LD      C, PERFORMANCE_COMPACT
                    CALL    Divide16x8_Unified

                    ; Result should be HL=384, A=8
                    PUSH    AF              ; Save remainder
                    LD      DE, 384         ; Expected quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Compare quotient
                    LD      HL, MsgTestCase037
                    JR      NZ, Test37Failed
                    POP     AF              ; Restore remainder
                    CP      8               ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
                    PUSH    AF              ; Balance the stack for drop thru
Test37Failed:       POP     AF              ; Clean up stack
                    LD      A, 37
                    JP      PrintFailedMessage

MsgTestCase037:     DB      " (5000 / 13 = 384r8)", 0