TestCase008:        ; Test case 8: 255 ÷ 15 = 17 remainder 0
                    LD      A, 255          ; Dividend
                    LD      B, 15           ; Divisor
                    LD      C, PERFORMANCE_BALANCED
                    CALL    Divide8x8_Unified

                    ; Result should be A=17, B=0
                    LD      HL, MsgTestCase008
                    CP      17              ; Check quotient
                    JR      NZ, Test8Failed
                    LD      A, B            ; Get remainder
                    CP      0               ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
Test8Failed:        LD      A, 8
                    JP      PrintFailedMessage

MsgTestCase008:     DB      " (255 / 15 = 17r0)", 0
