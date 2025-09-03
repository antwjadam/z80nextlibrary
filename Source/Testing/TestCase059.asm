TestCase059:        ; Test case 59: Detect as DMA available
                    CALL    CheckDMAAvailable
                    JP      Z, DMATestFailed ; may need to swap to NZ if on an emulator with no DMA support

DMATestPassed:      LD      HL, MsgTestCase059
                    XOR     A
                    OR      A               ; Set Z flag to indicate test passed.
                    RET

DMATestFailed:      LD      HL, MsgTestCase059
                    LD      A, 59           ; Test number
                    JP      PrintFailedMessage

MsgTestCase059:     DB      " DMA Available", 0