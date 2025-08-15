TestCase009:        ; Test case 9: 50 ÷ 200 = 0 remainder 50 (dividend < divisor)
                    LD      A, 50           ; Dividend
                    LD      B, 200          ; Divisor
                    LD      C, PERFORMANCE_MAXIMUM
                    CALL    Divide8x8_Unified

                    ; Result should be A=0, B=50
                    LD      HL, MsgTestCase009
                    CP      0               ; Check quotient
                    JR      NZ, Test9Failed
                    LD      A, B            ; Get remainder
                    CP      50              ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
Test9Failed:        LD      A, 9
                    JP      PrintFailedMessage

MsgTestCase009:     DB      " (50 / 200 = 0r50)", 0
