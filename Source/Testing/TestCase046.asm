TestCase046:        ; Test case 46: 255 ÷ 15 = 17 remainder 0 (8x8 BALANCED multiplication, using Z80N op codes)
                    LD      A, 255          ; Dividend
                    LD      B, 15           ; Divisor
                    LD      C, PERFORMANCE_NEXT_BALANCED
                    CALL    Divide8x8_Unified

                    ; Result should be A=17, B=0
                    LD      HL, MsgTestCase046
                    CP      17              ; Check quotient
                    JR      NZ, Test046Failed
                    LD      A, B            ; Get remainder
                    CP      0               ; Check remainder
                    RET     Z               ; Z set is test passed, else test failed.
Test046Failed:      LD      A, 46
                    JP      PrintFailedMessage

MsgTestCase046:     DB      " Z80N (255/15=17r0)", 0