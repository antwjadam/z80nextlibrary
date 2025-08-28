; Test Case 57: Z80N 16-bit Middle Square Random Generation - TRULY CORRECTED VERSION
TestCase057:            ; Test 1: Basic functionality with known seed
                        LD      BC, 9876                       ; Test seed
                        LD      HL, 1000                       ; Upper limit
                        LD      D, PERFORMANCE_Z80N_RANDOM_MIDDLESQUARE ; Algorithm
                        CALL    Random16_Unified_Seed          ; Seed and get first value
                        
                        ; Verify result is in INCLUSIVE range [0, 1000]
                        PUSH    HL                             ; Save first result BEFORE range check
                        LD      DE, 1000                       ; DE = 1000 (for range check)
                        LD      A, H                           ; Check if HL <= 1000
                        CP      D                              ; Compare high bytes
                        JR      C, Test57_InRange              ; H < D, definitely in range
                        JR      NZ, Test057SeedInRangeFail     ; H > D, out of range
                        
                        ; High bytes equal, check low byte for INCLUSIVE range
                        LD      A, L                           ; A = low byte of result
                        CP      E                              ; Compare with low byte of limit
                        JR      Z, Test57_InRange              ; L = E (exactly at limit), VALID for inclusive
                        JR      C, Test57_InRange              ; L < E (less than limit), VALID
                        ; If we get here, L > E, so result > limit, which is invalid
                        POP     HL                             ; Clean up stack before error
                        JR      Test057SeedInRangeFail
                        
Test57_InRange:         ; Test 2: Generate subsequent value - FIXED APPROACH
                        ; First result is already saved on stack from above
                        
                        ; Generate second value
                        LD      HL, 1000                       ; Same limit
                        LD      D, PERFORMANCE_Z80N_RANDOM_MIDDLESQUARE
                        CALL    Random16_Unified_Next          ; Get next value
                        ; HL now contains second result
                        
                        ; Now we have: Stack = first result, HL = second result
                        EX      DE, HL                         ; DE = second result
                        POP     HL                             ; HL = first result (restored from stack)
                        
                        ; Compare: first result (HL) with second result (DE)
                        LD      A, H                           ; A = high byte of first result
                        CP      D                              ; Compare with high byte of second result
                        JR      NZ, Test057Passes              ; Different high bytes = different values
                        
                        LD      A, L                           ; A = low byte of first result
                        CP      E                              ; Compare with low byte of second result
                        JR      NZ, Test057Passes              ; Different low bytes = different values
                        
                        ; Both bytes are identical = duplicate values (test failure)
                        JP      Test057NextFailed
                        
Test057Passes:          LD      HL, MsgTestCase057
                        XOR     A
                        OR      A                              ; Set Z flag
                        RET
                        
Test057NextFailed:      LD      HL, MsgTestCase057Next
Test057PrtFailure:      LD      A, 57
                        JP      PrintFailedMessage
                        
Test057SeedInRangeFail: LD      HL, MsgTestCase057SeedInRng
                        JR      Test057PrtFailure
                        
MsgTestCase057:         DB      " Z80N 16-bit MSq", 0
MsgTestCase057Next:     DB      " Z80N 16-bit MSq Nxt", 0
MsgTestCase057SeedInRng: DB     " Z80N 16-bit MSq SIR", 0