TestCase055:            ; Test Case 55: Z80N 16-bit LFSR Random Generation
                        LD      BC, 54321                      ; Test seed
                        LD      HL, 2000                       ; Upper limit
                        LD      D, PERFORMANCE_Z80N_RANDOM_LFSR ; Algorithm
                        CALL    Random16_Unified_Seed          ; Seed and get first value
                        ; Verify result is in range [0, 2000]
                        LD      DE, 2000                       ; Upper limit check
                        LD      A, H                           ; Check if HL <= 2000
                        CP      D
                        JR      C, Test55_InRange              ; H < D, in range
                        JR      NZ, Test055SeedInRangeFail     ; H > D, out of range
                        LD      A, L                           ; H = D, check L
                        CP      E
                        JR      NC, Test055SeedInRangeFail     ; L >= E, might be out of range
Test55_InRange:         ; Test 2: Generate subsequent value
                        PUSH    HL                             ; Save first result
                        LD      HL, 2000                       ; Same limit
                        LD      D, PERFORMANCE_Z80N_RANDOM_LFSR
                        CALL    Random16_Unified_Next          ; Get next value
                        POP     BC                             ; BC = first result
                        ; Verify second result is different
                        LD      A, B
                        CP      H
                        JR      NZ, Test055Passes              ; Different!
                        LD      A, C
                        CP      L
                        JP      Z, Test055NextFailed           ; Same values (very unlikely)
Test055Passes:          LD      HL, MsgTestCase055
                        XOR     A
                        OR      A                              ; Set Z flag
                        RET
Test055NextFailed:      LD      HL, MsgTestCase055Next
Test055PrtFailure:      LD      A, 55
                        JP      PrintFailedMessage
Test055SeedInRangeFail: LD      HL, MsgTestCase055SeedInRng
                        JR      Test055PrtFailure
MsgTestCase055:         DB      " Z80N 16-bit LFSR", 0
MsgTestCase055Next:     DB      " Z80N 16-bit LFSR Nxt", 0
MsgTestCase055SeedInRng:
                        DB      " Z80N 16-bit LFSR SIR", 0