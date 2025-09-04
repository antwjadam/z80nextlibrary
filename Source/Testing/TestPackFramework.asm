RunTests:           CALL    TestPackTests
                    ; A register now contains result:
                    ; 0xFF = all passed
                    ; 1-62 = test number that failed
                    RET
AllTestsPassed:     ; Print success message at bottom
                    LD      B, 20           ; Row 20
                    LD      C, 0            ; Column 0 (left)
                    CALL    BlankLineAt     ; Blank line at 20
                    INC     B               ; Move to next line (21)
                    CALL    BlankLineAt     ; Blank line at 21
                    INC     B               ; Move to next line (22)
                    CALL    BlankLineAt     ; Blank line at 22
                    DEC     B               ; Move back to line 21
                    LD      HL, MsgAllPassed
                    CALL    PrintStringAt
                    CALL    WaitForKey
                    LD      A, 0xFF         ; Success indicator
                    RET

BlankLineAt:        PUSH    BC              ; Save cursor position
                    LD      HL, BlankLine
                    CALL    PrintStringAt
                    POP     BC              ; Restore cursor position (line 21)
                    RET

PrintFailed:        ; Print "FAILED" message at current cursor position
                    PUSH    HL              ; Preserve HL for message description
                    PUSH    AF              ; A contains test number, so preserve it for middle of message
                    AND     A, 15           ; Ensure A is in range 0-15 to ensure no scrolling when > 15 tests
                    ADD     A, 2
                    LD      (CurrentLine), A ; Save current line for blanking later
                    LD      B, A            ; Row 2+test number
                    LD      C, 0            ; Column 0 (left)
                    LD      HL, MsgTest
                    CALL    PrintStringAt
                    POP     AF              ; Restore A with test number
                    CALL    PrintDecimal
                    POP     HL              ; Restore HL with message description
                    CALL    PrintString
                    LD      HL, MsgFailed
                    CALL    PrintString
                    JR      BlankNextLine   ; Blank the next line after the failed test result

PrintPassed:        ; Print "PASSED" message at current cursor position
                    PUSH    HL              ; Preserve HL for message description
                    PUSH    AF              ; A contains test number, so preserve it for middle of message
                    AND     A, 0x0F         ; Ensure A is in range 0-15 to ensure no scrolling when > 15 tests
                    ADD     A, 2
                    LD      (CurrentLine), A ; Save current line for blanking later
                    LD      B, A            ; Row 2 (down from title)
                    LD      C, 0            ; Column 0 (left)
                    LD      HL, MsgTest
                    CALL    PrintStringAt
                    POP     AF              ; Restore A with test number
                    CALL    PrintDecimal
                    POP     HL              ; Restore HL with message description
                    CALL    PrintString
                    LD      HL, MsgPassed
                    CALL    PrintString

BlankNextLine:      LD      A, (CurrentLine)    ; Get current line to blank
                    INC     A
                    LD      B, A            ; Row to blank
                    LD      C, 0            ; Column 0 (left)
                    LD      HL, BlankLine
                    CALL    PrintStringAt   ; Blank the line after the test result
                    RET

PrintFailedMessage: CALL    PrintFailed
                    LD      A, 1
                    OR      A               ; Set NOT ZERO to allow tests to stop
                    RET

CurrentLine:        DB      0            ; Current line for blanking after

BlankLine:          DB      "                                ", 0 ; Blank line for spacing
MsgTitle:           DB      "Next Library Test Suite", 0
MsgTest:            DB      "T.", 0
MsgFailed:          DB      " : FAIL", 0
MsgPassed:          DB      " : PASS", 0
MsgAllPassed:       DB      "All tests PASSED!", 0

; Buffer for conversion results
ConversionBuffer:   DB      0               ; Most Sig Digit
                    DB      0               ; Second Sig Digit
                    DB      0               ; Third Sig Digit
                    DB      0               ; Fourth Sig Digit
                    DB      0               ; Fifth Sig Digit
                    DB      0               ; always a null terminator
                    DB      0

; Number conversion helper to print length and resulting string for debugging purposes.
PrintLengthAndString:
                    PUSH BC
                    PUSH AF
                    LD      B, 19
                    LD      C, 0            ; Column 0 (left)
                    PUSH    BC
                    LD      HL, BlankLine
                    CALL    PrintStringAt   ; Blank the line
                    POP     BC
                    CALL    SetCursor
                    POP     AF
                    PUSH    AF
                    CALL    PrintDecimal
                    LD      B, 19
                    LD      C, 4
                    LD      HL, ConversionBuffer
                    CALL    PrintStringAt
                    POP     AF
                    POP     BC
                    RET

; Needed to forze Z flag on tests relying on Carry flag
SetTestPassing:     XOR     A
                    OR      A               ; Sets Z flag
                    RET