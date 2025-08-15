TestCase007:        ; Test case 7: 100 ÷ 8 = 12 remainder 4
                    LD      A, 100          ; Dividend
                    LD      B, 8            ; Divisor
                    LD      C, PERFORMANCE_MAXIMUM
                    CALL    Divide8x8_Unified

                    ; Result should be A=12, B=4
                    LD      HL, MsgTestCase007
                    CP      12              ; Check quotient
                    JR      NZ, Test7Failed
                    LD      A, B            ; Get remainder
                    CP      4               ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
Test7Failed:        LD      A, 7            ; test number
                    JP      PrintFailedMessage

MsgTestCase007:     DB      " (100 / 8 = 12r4)", 0
