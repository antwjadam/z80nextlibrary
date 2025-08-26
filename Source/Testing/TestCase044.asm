TestCase044:        ; Test case 44: 45 ÷ 7 = 6 remainder 3 (8x8 COMPACT multiplication, using Z80N op codes)
                    LD      A, 45           ; Dividend
                    LD      B, 7            ; Divisor
                    LD      C, PERFORMANCE_NEXT_COMPACT ; uses traditional methods for small divisions.
                    CALL    Divide8x8_Unified

                    ; Result should be A=6, B=3
                    LD      HL, MsgTestCase044
                    CP      6               ; Check quotient
                    JR      NZ, Test044Failed
                    LD      A, B            ; Get remainder
                    CP      3               ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
Test044Failed:      LD      A, 44           ; test number
                    JP      PrintFailedMessage

MsgTestCase044:     DB      " Z80N (45 / 7 = 6r3)", 0