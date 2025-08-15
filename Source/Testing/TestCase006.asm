TestCase006:        ; Test case 6: 45 ÷ 7 = 6 remainder 3
                    LD      A, 45           ; Dividend
                    LD      B, 7            ; Divisor
                    LD      C, PERFORMANCE_BALANCED
                    CALL    Divide8x8_Unified

                    ; Result should be A=6, B=3
                    LD      HL, MsgTestCase006
                    CP      6               ; Check quotient
                    JR      NZ, Test6Failed
                    LD      A, B            ; Get remainder
                    CP      3               ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
Test6Failed:        LD      A, 6            ; test number
                    JP      PrintFailedMessage

MsgTestCase006:     DB      " (45 / 7 = 6r3)", 0
