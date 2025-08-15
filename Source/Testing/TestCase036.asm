TestCase036:        ; Test case 36: 45 ÷ 7 = 6 remainder 3         - Added due to Unified Refactor  
                    LD      A, 45           ; Dividend
                    LD      B, 7            ; Divisor
                    LD      C, PERFORMANCE_COMPACT
                    CALL    Divide8x8_Unified

                    ; Result should be A=6, B=3
                    LD      HL, MsgTestCase036
                    CP      6               ; Check quotient
                    JR      NZ, Test36Failed
                    LD      A, B            ; Get remainder
                    CP      3               ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
Test36Failed:       LD      A, 36           ; test number
                    JP      PrintFailedMessage

MsgTestCase036:     DB      " (45 / 7 = 6r3)", 0