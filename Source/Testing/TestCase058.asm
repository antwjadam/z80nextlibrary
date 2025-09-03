TestCase058:        ; Test case 58: Detect as Z80N 
                    CALL    CheckOnZ80N
                    JP      Z, Z80NTestFailed

Z80NTestPassed:     LD      HL, MsgTestCase058
                    XOR     A
                    OR      A               ; Set Z flag to indicate test passed.
                    RET

Z80NTestFailed:     LD      HL, MsgTestCase058
                    LD      A, 58           ; Test number
                    JP      PrintFailedMessage

MsgTestCase058:     DB      " Z80N Detected", 0