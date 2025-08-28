TestCase056:            ; Test Case 56: Z80N 16-bit XorShift Random Generation
                        LD      BC, 13579                      ; Test seed
                        LD      HL, 5000                       ; Upper limit
                        LD      D, PERFORMANCE_Z80N_RANDOM_XORSHIFT ; Algorithm
                        CALL    Random16_Unified_Seed          ; Seed and get first value
                        ; Verify result is in range [0, 5000]
                        LD      DE, 5000                       ; Upper limit check
                        LD      A, H                           ; Check if HL <= 5000
                        CP      D
                        JR      C, Test56_InRange              ; H < D, in range
                        JR      NZ, Test056SeedInRangeFail     ; H > D, out of range
                        LD      A, L                           ; H = D, check L
                        CP      E
                        JR      NC, Test056SeedInRangeFail     ; L >= E, might be out of range
Test56_InRange:         ; Test 2: Generate subsequent value
                        PUSH    HL                             ; Save first result
                        LD      HL, 5000                       ; Same limit
                        LD      D, PERFORMANCE_Z80N_RANDOM_XORSHIFT
                        CALL    Random16_Unified_Next          ; Get next value
                        POP     BC                             ; BC = first result
                        ; Verify second result is different
                        LD      A, B
                        CP      H
                        JR      NZ, Test056Passes              ; Different!
                        LD      A, C
                        CP      L
                        JP      Z, Test056NextFailed           ; Same values (very unlikely)
Test056Passes:          LD      HL, MsgTestCase056
                        XOR     A
                        OR      A                              ; Set Z flag
                        RET
Test056NextFailed:      LD      HL, MsgTestCase056Next
Test056PrtFailure:      LD      A, 56
                        JP      PrintFailedMessage
Test056SeedInRangeFail: LD      HL, MsgTestCase056SeedInRng
                        JR      Test056PrtFailure
MsgTestCase056:         DB      " Z80N 16-bit XorShift", 0
MsgTestCase056Next:
                        DB      " Z80N 16-bit XorShift Nxt", 0
MsgTestCase056SeedInRng:
                        DB      " Z80N 16-bit XorShift SIR", 0