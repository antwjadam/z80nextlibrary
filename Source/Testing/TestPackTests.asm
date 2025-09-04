
TestPackTests:      LD      HL, 0                               ; Default screen area to ZX Spectrum screen base
                    LD      A, 0x07                             ; Set default attribute (white on black)
                    LD      C, SCREEN_DMA_BURST                 ; SCREEN_Z80N_COMPACT
                    CALL    Screen_FullReset_Unified
                    ; Print title at top
                    LD      B, 0                                ; Row 0 (top)
                    LD      C, 0                                ; Column 0 (left)
                    LD      HL, MsgTitle
                    CALL    PrintStringAt
                    ; Position cursor for test results (2 lines below title)
                    LD      B, 3                                ; Row 3 (leaving space after title)
                    LD      C, 0                                ; Column 0 (left)
                    CALL    SetCursor
                    ; Initialize test loop
                    LD      HL, TestCaseTable                   ; HL points to test case address table
                    LD      A, (TestCaseCount)
                    LD      B, A                                ; Total number of tests
                    XOR     A                                   ; Test counter for printing, start at zero
RunNextTest:        INC     A                                   ; Increment test case number
                    PUSH    AF                                  ; Preserve test case number
                    ; Get test case address from table and call it
                    PUSH    HL                                  ; Preserve current test case address
                    LD      E, (HL)                             ; Low byte of test address
                    INC     HL
                    LD      D, (HL)                             ; High byte of test address
                    EX      DE, HL                              ; HL = test case address
                    CALL    SafeCallTest                        ; Call the test case pointed to by HL
                    POP     HL                                  ; Restore currenttest case address
                    JP      NZ,ExitOnFail                       ; Return if test failed
                    POP     AF                                  ; Get test number for printing passed message
                    CALL    SafePrintPassed                     ; Print test passed message
                    INC     HL                                  ; Move to next address in table
                    INC     HL                                  ; (addresses are 2 bytes each)
                    DJNZ    RunNextTest                         ; Decrement B and loop if not zero
                    JP      AllTestsPassed                      ; If we reach here, all tests passed

ExitOnFail:         ; AF still on stack, Z flag preserved from test result
                    POP     AF                                  ; Clean up stack (AF no longer needed)
                    RET                                         ; Safe to return at the point of test failure.

SafePrintPassed:    ; Helper routine to ensure safe call of print passed
                    PUSH    AF                                  ; Preserve test number
                    PUSH    BC                                  ; Preserve BC
                    PUSH    DE                                  ; Preserve DE
                    PUSH    HL                                  ; Preserve HL
                    ; get the message the test produced
                    LD      HL, (TestResultMessage)
                    CALL    PrintPassed                         ; Call print routine
                    POP     HL                                  ; Restore HL
                    POP     DE                                  ; Restore DE
                    POP     BC                                  ; Restore loop counter
                    POP     AF                                  ; Restore test number
                    RET

SafeCallTest:       ; Helper routine to call address in HL
                    PUSH    BC                                  ; Preserve BC
                    PUSH    DE                                  ; Preserve DE
                    PUSH    HL                                  ; Preserve HL
                    CALL    CallHL                              ; Call the test case
                    ; on exit, test will have a message pointed to by HL, so save it
                    LD      (TestResultMessage), HL
                    POP     HL                                  ; Restore HL
                    POP     DE                                  ; Restore DE
                    POP     BC                                  ; Restore BC
                    RET

; Calling this is effectively a CALL to address pointed to by HL.
CallHL:             JP      (HL)                                ; Jump to address in HL

TestResultMessage:  DS      2                                   ; Placeholder for test result message

TestCaseCount:      DB      62                                  ; Total number of test cases
;
; Test case address table - maintains order from original code
TestCaseTable:      DW      TestCase001                         ; Test 1: 5 × 3 = 15
                    DW      TestCase002                         ; Test 2: 12 × 8 = 96
                    DW      TestCase003                         ; Test 3: 15 × 17 = 255
                    DW      TestCase004                         ; Test 4: 0 × 123 = 0
                    DW      TestCase005                         ; Test 5: 16 × 16 = 256
                    DW      TestCase006                         ; Test 6: 45 ÷ 7 = 6 remainder 3
                    DW      TestCase007                         ; Test 7: 100 ÷ 8 = 12 remainder 4
                    DW      TestCase008                         ; Test 8: 255 ÷ 15 = 17 remainder 0
                    DW      TestCase009                         ; Test 9: 50 ÷ 200 = 0 remainder 50
                    DW      TestCase010                         ; Test 10: 5000 ÷ 13 = 384 remainder 8
                    DW      TestCase011                         ; Test 11: 1000 × 50 = 50000
                    DW      TestCase012                         ; Test 12: 200 × 25 = 5000
                    DW      TestCase013                         ; Test 13: 5000 ÷ 25 = 200 remainder 0
                    DW      TestCase014                         ; Test 14: Random LCG validation
                    DW      TestCase015                         ; Test 15: Random XORShift validation
                    DW      TestCase016                         ; Test 16: LFSR random generator
                    DW      TestCase017                         ; Test 17: Middle Square random generator
                    DW      TestCase018                         ; Test 18: Random LCG 16-bit validation
                    DW      TestCase019                         ; Test 19: Random XORShift 16-bit validation
                    DW      TestCase020                         ; Test 20: Random LFSR 16-bit validation
                    DW      TestCase021                         ; Test 21: Random Middle Square 16-bit validation
                    DW      TestCase022                         ; Test 22: Convert 0 without leading zeros
                    DW      TestCase023                         ; Test 23: Convert 0 with leading zeros
                    DW      TestCase024                         ; Test 24: Convert 1 without leading zeros
                    DW      TestCase025                         ; Test 25: Convert 1 with leading zeros
                    DW      TestCase026                         ; Test 26: Convert 123 without leading zeros
                    DW      TestCase027                         ; Test 27: Convert 123 with leading zeros
                    DW      TestCase028                         ; Test 28: Convert 9999 without leading zeros
                    DW      TestCase029                         ; Test 29: Convert 65535 without leading zeros
                    DW      TestCase030                         ; Test 30: Convert 12345 in both modes
                    DW      TestCase031                         ; Test 31: Compact Multiply 8x8
                    DW      TestCase032                         ; Test 32: Compact Multiply 16x8
                    DW      TestCase033                         ; Test 33: Compact Multiply 16x8 - Large Result
                    DW      TestCase034                         ; Test 34: Balanced Multiply 16x8 - Large Result
                    DW      TestCase035                         ; Test 35: Maximum Multiply 16x8 - Large Result
                    DW      TestCase036                         ; Test 36: Compact Divide 8x8
                    DW      TestCase037                         ; Test 37: Compact Divide 16x8
                    DW      TestCase038                         ; Test 38: Z80N Compact Multiply 8x8
                    DW      TestCase039                         ; Test 39: Z80N Balanced Multiply 8x8
                    DW      TestCase040                         ; Test 40: Z80N Maximum Multiply 8x8
                    DW      TestCase041                         ; Test 41: Z80N Compact Multiply 16x8
                    DW      TestCase042                         ; Test 42: Z80N Balanced Multiply 16x8
                    DW      TestCase043                         ; Test 43: Z80N Maximum Multiply 16x8
                    DW      TestCase044                         ; Test 44: Z80N Compact Divide 8x8
                    DW      TestCase045                         ; Test 45: Z80N Maximum Divide 16x8
                    DW      TestCase046                         ; Test 46: Z80N Balanced Divide 8x8
                    DW      TestCase047                         ; Test 47: Z80N Balanced Divide 16x8
                    DW      TestCase048                         ; Test 48: Z80N Hybrid Divide 16x8
                    DW      TestCase049                         ; Test 49: Z80N Maximum Divide 16x8
                    DW      TestCase050                         ; Test 50: Z80N Random LCG validation
                    DW      TestCase051                         ; Test 51: Z80N Random XORShift validation
                    DW      TestCase052                         ; Test 52: Z80N LFSR random generator
                    DW      TestCase053                         ; Test 53: Z80N Random 8-bit Middle Square
                    DW      TestCase054                         ; Test 54: Z80N 16-bit LCG Random Generation
                    DW      TestCase055                         ; Test 55: Z80N 16-bit LFSR Random Generation
                    DW      TestCase056                         ; Test 56: Z80N 16-bit XorShift Random Generation
                    DW      TestCase057                         ; Test 57: Z80N 16-bit Middle Square Random Generation
                    DW      TestCase058                         ; Test 58: Z80N Detection
                    DW      TestCase059                         ; Test 59: DMA Available Detection
                    DW      TestCase060                         ; Test 60: Check for Active Layer 2
                    DW      TestCase061                         ; Test 61: Get Active Layer 2 Address
                    DW      TestCase062                         ; Test 62: Get Active Layer 2 Info
