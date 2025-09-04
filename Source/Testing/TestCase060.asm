TestCase060:        ; Test case 60: Check for active Layer 2 - I dont have an active Layer 2, so if you do you may need to swap the checks for pass and fail.
                    CALL    CheckForActiveLayer2
                    JP      NZ, Layer2TestFailed ; may need to swap to Z if running with an active Layer 2

Layer2TestPassed:   LD      HL, MsgTestCase060
                    XOR     A
                    OR      A               ; Set Z flag to indicate test passed.
                    RET

Layer2TestFailed:   LD      HL, MsgTestCase060
                    LD      A, 60           ; Test number
                    JP      PrintFailedMessage

MsgTestCase060:     DB      " Check 4 Layer 2", 0