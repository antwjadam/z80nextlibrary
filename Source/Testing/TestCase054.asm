TestCase054:            ; Test Case 54: Z80N 16-bit LCG Random Generation
                        LD      BC, 12345                      ; Test seed
                        LD      HL, 1000                       ; Upper limit
                        LD      D, PERFORMANCE_Z80N_RANDOM_LCG ; Algorithm
                        CALL    Random16_Unified_Seed          ; Seed and get first value
                        ; Verify result is in range [0, 1000]
                        LD      DE, 1000                       ; Upper limit check
                        LD      A, H                           ; Check if HL <= 1000
                        CP      D
                        JR      C, Test54_InRange              ; H < D, in range
                        JR      NZ, Test054SeedInRangeFail     ; H > D, out of range
                        LD      A, L                           ; H = D, check L
                        CP      E
                        JR      NC, Test054SeedInRangeFail     ; L >= E, might be out of range
Test54_InRange:         ; Test 2: Generate subsequent value
                        PUSH    HL                             ; Save first result
                        LD      HL, 1000                       ; Same limit
                        LD      D, PERFORMANCE_Z80N_RANDOM_LCG
                        CALL    Random16_Unified_Next          ; Get next value
                        POP     BC                             ; BC = first result
                        ; Verify second result is different
                        LD      A, B
                        CP      H
                        JR      NZ, Test054Passes              ; Different!
                        LD      A, C
                        CP      L
                        JP      Z, Test054NextFailed           ; Same values (very unlikely)
Test054Passes:          LD      HL, MsgTestCase054
                        XOR     A
                        OR      A                              ; Set Z flag
                        RET
Test054NextFailed:      LD      HL, MsgTestCase054Next
Test054PrtFailure:      LD      A, 54
                        JP      PrintFailedMessage
Test054SeedInRangeFail: LD      HL, MsgTestCase054SeedInRng
                        JR      Test054PrtFailure
MsgTestCase054:         DB      " Z80N 16-bit LCG", 0
MsgTestCase054Next:
                        DB      " Z80N 16-bit LCG Nxt", 0
MsgTestCase054SeedInRng:
                        DB      " Z80N 16-bit LCG SIR", 0
