TestCase061:        ; Test case 61: Get active Layer 2 address - I dont have an active Layer 2, so I check for zero.
                    CALL    GetActiveLayer2Addr
                    ; we dont have an active layer 2 so HL should be zero
                    LD      A, H
                    OR      L               ; Check HL is zero
                    JP      NZ, L2AddrTestFailed
                    ; Also check the stored Layer2ScreenAddress is zero
                    LD      HL, (Layer2ScreenAddress)
                    LD      A, H
                    OR      L               ; Check HL is zero
                    JP      NZ, L2AddrTestFailed

L2AddrTestPassed:   LD      HL, MsgTestCase061
                    XOR     A
                    OR      A               ; Set Z flag to indicate test passed.
                    RET

L2AddrTestFailed:   LD      HL, MsgTestCase061
                    LD      A, 61           ; Test number
                    JP      PrintFailedMessage

MsgTestCase061:     DB      " Get L2 Address", 0