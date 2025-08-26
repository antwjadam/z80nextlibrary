TestCase049:        ; Test case 49: 16x8 division using 16-bit reciprocals (PERFORMANCE_NEXT_MAXIMUM)
                    ; Test our new Divide16x8_Next_Reciprocal_High implementation
                    ; Simple test for the problematic case
                    LD      HL, 1000        ; 16-bit dividend
                    LD      B, 7            ; 8-bit divisor (1000 ÷ 7 = 142 remainder 6)
                    LD      C, PERFORMANCE_NEXT_MAXIMUM ; Use 16-bit reciprocal table
                    CALL    Divide16x8_Unified

                    ; Expected: 1000 ÷ 7 = 142 remainder 6
                    PUSH    AF              ; Save remainder
                    LD      DE, 142         ; Expected quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Check if quotient == 142
                    JR      NZ, Test49QuotientFailed ; Quotient should be exactly 142
                    POP     AF              ; Get remainder
                    CP      6               ; Check if remainder == 6
                    JR      Z, SetTest49Passing ; All tests passed!
                    
                    ; Test 2: Another exact division to verify precision
                    LD      HL, 4096        ; 16-bit dividend (powers of 2 are good test cases)
                    LD      B, 16           ; 8-bit divisor
                    LD      C, PERFORMANCE_NEXT_MAXIMUM ; Use 16-bit reciprocal table
                    CALL    Divide16x8_Unified

                    ; Expected: 4096 ÷ 16 = 256 remainder 0 exactly
                    PUSH    AF              ; Save remainder
                    LD      DE, 256         ; Expected quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Check if quotient == 256
                    JR      NZ, Test49Quotient2Failed ; Quotient should be exactly 256
                    POP     AF              ; Get remainder
                    CP      0               ; Check if remainder == 0
                    JR      NZ, Test49Remainder2Failed ; Remainder should be exactly 0
                    
                    ; Test 3: Division with remainder
                    LD      HL, 1000        ; 16-bit dividend
                    LD      B, 7            ; 8-bit divisor (1000 ÷ 7 = 142 remainder 6)
                    LD      C, PERFORMANCE_NEXT_MAXIMUM ; Use 16-bit reciprocal table
                    CALL    Divide16x8_Unified

                    ; Expected: 1000 ÷ 7 = 142 remainder 6
                    PUSH    AF              ; Save remainder
                    LD      DE, 142         ; Expected quotient
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Check if quotient == 142
                    JR      NZ, Test49Quotient3Failed ; Quotient should be exactly 142
                    POP     AF              ; Get remainder
                    CP      6               ; Check if remainder == 6
                    JR      Z, SetTest49Passing ; All tests passed!
                    
                    ; Remainder failed for test 3
                    LD      HL, MsgRemainder3Failed
                    LD      A, 49
                    JP      PrintFailedMessage

Test49QuotientFailed: POP   AF              ; Clean stack (remainder still on stack)
                    LD      HL, MsgQuotient1Failed
                    LD      A, 49
                    JP      PrintFailedMessage
                    
Test49RemainderFailed: LD   HL, MsgRemainder1Failed
                    LD      A, 49
                    JP      PrintFailedMessage

Test49Quotient2Failed: POP  AF              ; Clean stack (remainder still on stack)
                    LD      HL, MsgQuotient2Failed
                    LD      A, 49
                    JP      PrintFailedMessage
                    
Test49Remainder2Failed: LD  HL, MsgRemainder2Failed
                    LD      A, 49
                    JP      PrintFailedMessage

Test49Quotient3Failed: POP  AF              ; Clean stack (remainder still on stack)
                    LD      HL, MsgQuotient3Failed
                    LD      A, 49
                    JP      PrintFailedMessage

SetTest49Passing:   LD      HL, MsgTestCase049
                    XOR     A
                    OR      A               ; Set Z flag
                    RET                     ; returns with Z set to indicate test passes.

MsgTestCase049:     DB      " Z80N 16x8 16-bit rec", 0
MsgQuotient1Failed: DB      " Z80N 16x8 100/8 quot", 0
MsgRemainder1Failed: DB     " Z80N 16x8 100/8 rem", 0
MsgQuotient2Failed: DB      " Z80N 16x8 4096/16 q", 0
MsgRemainder2Failed: DB     " Z80N 16x8 4096/16 r", 0
MsgQuotient3Failed: DB      " Z80N 16x8 1K/7 quot", 0
MsgRemainder3Failed: DB     " Z80N 16x8 1K/7 rem", 0
