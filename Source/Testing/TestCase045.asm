TestCase045:        ; Test case 45: 100 ÷ 8 = 12 remainder 4 (8x8 MAXIMUM multiplication, using Z80N op codes with 16-bit reciprocals)
                    LD      A, 100          ; Dividend
                    LD      B, 8            ; Divisor
                    LD      C, PERFORMANCE_NEXT_MAXIMUM ; uses 16-bit reciprocal table
                    CALL    Divide8x8_Unified

                    ; Result should be A=12, B=4
                    LD      HL, MsgTestCase045
                    CP      12              ; Check quotient
                    JR      NZ, Test045Failed
                    LD      A, B            ; Get remainder
                    CP      4               ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
Test045Failed:      LD      A, 45           ; test number
                    JP      PrintFailedMessage

MsgTestCase045:     DB      " Z80N (100/8=12r4)", 0