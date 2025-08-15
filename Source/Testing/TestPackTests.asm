
TestPackTests:      CALL    ScreenReset     ; Clear the screen
                    ; Print title at top
                    LD      B, 0            ; Row 0 (top)
                    LD      C, 0            ; Column 0 (left)
                    LD      HL, MsgTitle
                    CALL    PrintStringAt
                    ; Position cursor for test results (2 lines below title)
                    LD      B, 3            ; Row 3 (leaving space after title)
                    LD      C, 0            ; Column 0 (left)
                    CALL    SetCursor
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    CALL    TestCase001     ; Test case 1: 5 × 3 = 15
                    RET     NZ              ; If test failed, return
                    LD      A, 1            ; Test number
                    CALL    PrintPassed
                    CALL    TestCase002     ; Test case 2: 12 × 8 = 96
                    RET     NZ              ; If test failed, return
                    LD      A, 2            ; Test number
                    CALL    PrintPassed                       
                    CALL    TestCase003     ; Test case 3: 15 × 17 = 255
                    RET     NZ              ; If test failed, return
                    LD      A, 3            ; Test number
                    CALL    PrintPassed
                    CALL    TestCase004     ; Test case 4: 0 × 123 = 0
                    RET     NZ              ; If test failed, return
                    LD      A, 4            ; Test number
                    CALL    PrintPassed
                    CALL    TestCase005     ; Test case 5: 16 × 16 = 256
                    RET     NZ              ; If test failed, return
                    LD      A, 5            ; Test number
                    CALL    PrintPassed
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    CALL    TestCase006     ; Test case 6: 45 ÷ 7 = 6 remainder 3
                    RET     NZ              ; If test failed, return
                    LD      A, 6            ; Test number
                    CALL    PrintPassed           
                    CALL    TestCase007     ; Test case 7: 100 ÷ 8 = 12 remainder 4
                    RET     NZ              ; If test failed, return
                    LD      A, 7            ; Test number
                    CALL    PrintPassed           
                    CALL    TestCase008     ; Test case 8: 255 ÷ 15 = 17 remainder 0
                    RET     NZ              ; If test failed, return
                    LD      A, 8            ; Test number
                    CALL    PrintPassed
                    CALL    TestCase009     ; Test case 9: 50 ÷ 200 = 0 remainder 50 (dividend < divisor)
                    RET     NZ              ; If test failed, return
                    LD      A, 9            ; Test number
                    CALL    PrintPassed
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    CALL    TestCase010     ; Test case 10: 5000 ÷ 13 = 384 remainder 8 (16-bit division)
                    RET     NZ              ; If test failed, return
                    LD      A, 10           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase011     ; Test case 11: 1000 × 50 = 50000 (16x8 multiplication)
                    RET     NZ              ; If test failed, return
                    LD      A, 11           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase012     ; Test case 12: 200 × 25 = 5000 (16x8 fast multiplication)
                    RET     NZ              ; If test failed, return
                    LD      A, 12           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase013     ; Test case 13: 5000 ÷ 25 = 200 remainder 0 (16x8 fast division)
                    RET     NZ              ; If test failed, return
                    LD      A, 13           ; Test number
                    CALL    PrintPassed
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    CALL    TestCase014     ; Test case 14: Random number generator validation LCG
                    RET     NZ              ; If test failed, return
                    LD      A, 14           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase015     ; Test case 15: Random number generator validation XORShift
                    RET     NZ              ; If test failed, return
                    LD      A, 15           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase016     ; Test case 16: LFSR random number generator
                    RET     NZ              ; If test failed, return
                    LD      A, 16           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase017     ; Test case 17: Middle Square random number generator
                    RET     NZ              ; If test failed, return
                    LD      A, 17           ; Test number
                    CALL    PrintPassed
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    CALL    TestCase018     ; Test case 18: Random number generator validation LCG 16 bit
                    RET     NZ              ; If test failed, return
                    LD      A, 18           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase019     ; Test case 19: Random number generator validation XORShift 16 bit
                    RET     NZ              ; If test failed, return
                    LD      A, 19           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase020     ; Test case 20: Random number generator validation LFSR 16 bit
                    RET     NZ              ; If test failed, return
                    LD      A, 20           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase021     ; Test case 21: Random number generator validation Middle Square 16 bit
                    RET     NZ              ; If test failed, return
                    LD      A, 21           ; Test number
                    CALL    PrintPassed
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    CALL    TestCase022     ; Test case 22: Convert 0 without leading zeros
                    RET     NZ              ; If test failed, return
                    LD      A, 22           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase023     ; Test case 23: Convert 0 with leading zeros
                    RET     NZ              ; If test failed, return
                    LD      A, 23           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase024     ; Test case 24: Convert 1 without leading zeros
                    RET     NZ              ; If test failed, return
                    LD      A, 24           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase025     ; Test case 25: Convert 1 with leading zeros
                    RET     NZ              ; If test failed, return
                    LD      A, 25           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase026     ; Test case 26: Convert 123 without leading zeros
                    RET     NZ              ; If test failed, return
                    LD      A, 26           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase027     ; Test case 27: Convert 123 with leading zeros
                    RET     NZ              ; If test failed, return
                    LD      A, 27           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase028     ; Test case 28: Convert 9999 without leading zeros
                    RET     NZ              ; If test failed, return
                    LD      A, 28           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase029     ; Test case 29: Convert 65535 without leading zeros
                    RET     NZ              ; If test failed, return
                    LD      A, 29           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase030     ; Test case 30: Convert 12345 in both modes
                    RET     NZ              ; If test failed, return
                    LD      A, 30           ; Test number
                    CALL    PrintPassed
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - Unification Refactor extra test cases
                    CALL    TestCase031     ; Test case 31: Compact Multiply 8x8
                    RET     NZ              ; If test failed, return
                    LD      A, 31           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase032     ; Test case 32: Compact Multiply 16x8
                    RET     NZ              ; If test failed, return
                    LD      A, 32           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase033     ; Test case 33: Compact Multiply 16x8 - Large Result
                    RET     NZ              ; If test failed, return
                    LD      A, 33           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase034     ; Test case 34: Balanced Multiply 16x8 - Large Result
                    RET     NZ              ; If test failed, return
                    LD      A, 34           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase035     ; Test case 35: Maximum Multiply 16x8 - Large Result
                    RET     NZ              ; If test failed, return
                    LD      A, 35           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase036     ; Test case 36: Compact Divide 8x8
                    RET     NZ              ; If test failed, return
                    LD      A, 36           ; Test number
                    CALL    PrintPassed
                    CALL    TestCase037     ; Test case 37: Compact Divide 16x8
                    RET     NZ              ; If test failed, return
                    LD      A, 37           ; Test number
                    CALL    PrintPassed
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    JP      AllTestsPassed  ; If we reach here, all tests passed
