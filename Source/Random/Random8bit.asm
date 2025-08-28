; Unified 8-bit Random number generation routines.
;
; Always call Random8_Unified_Seed to set up the seed and limits for the selected algorithm.
; After setting seed and limit, call Random8_Unified_Next to get each subsequent random number.
;
; Input:  A = upper limit INCLUSIVE (0 to A)
;         B = initial seed value (algorithm dependent)
;         C = algorithm selection (PERFORMANCE_RANDOM_xxx)
; Output: A = random number in range 0 to limit inclusive.
;
; T-States summary shows for each random number generation as:
;
; Random8_Unified_Seed (includes first random generation):
; PERFORMANCE_RANDOM_LCG               - ~75-90 T-states for seed+first call
; PERFORMANCE_RANDOM_LFSR              - ~115-145 T-states for seed+first call  
; PERFORMANCE_RANDOM_XORSHIFT          - ~70-85 T-states for seed+first call
; PERFORMANCE_RANDOM_MIDDLESQUARE      - ~165-200 T-states for seed+first call
; PERFORMANCE_Z80N_RANDOM_LCG          - ~55-70 T-states for seed+first call
; PERFORMANCE_Z80N_RANDOM_LFSR         - ~75-90 T-states for seed+first call
; PERFORMANCE_Z80N_RANDOM_XORSHIFT     - ~50-65 T-states for seed+first call
; PERFORMANCE_Z80N_RANDOM_MIDDLESQUARE - ~95-120 T-states for seed+first call
;
; Random8_Unified_Next (subsequent calls only):
; PERFORMANCE_RANDOM_LCG               - ~45-55 T-states per call
; PERFORMANCE_RANDOM_LFSR              - ~85-95 T-states per call  
; PERFORMANCE_RANDOM_XORSHIFT          - ~35-45 T-states per call
; PERFORMANCE_RANDOM_MIDDLESQUARE      - ~115-150 T-states per call
; PERFORMANCE_Z80N_RANDOM_LCG          - ~25-35 T-states per call
; PERFORMANCE_Z80N_RANDOM_LFSR         - ~45-55 T-states per call
; PERFORMANCE_Z80N_RANDOM_XORSHIFT     - ~20-30 T-states per call
; PERFORMANCE_Z80N_RANDOM_MIDDLESQUARE - ~65-75 T-states per call
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Random8_Unified_Seed:   ; Set seed and get first random number
                        PUSH    AF
                        PUSH    BC
                        LD      A, C                            ; Get algorithm selector
                        CP      PERFORMANCE_RANDOM_LCG
                        JP      Z, Random8_Seed_LCG
                        CP      PERFORMANCE_Z80N_RANDOM_LCG
                        JP      Z, Random8_Seed_LCG
                        CP      PERFORMANCE_RANDOM_LFSR
                        JP      Z, Random8_Seed_LFSR
                        CP      PERFORMANCE_Z80N_RANDOM_LFSR
                        JP      Z, Random8_Seed_LFSR
                        CP      PERFORMANCE_RANDOM_XORSHIFT
                        JP      Z, Random8_Seed_XORShift
                        CP      PERFORMANCE_Z80N_RANDOM_XORSHIFT
                        JP      Z, Random8_Seed_XORShift
                        JP      Random8_Seed_MiddleSquare
Random8_Seed_LCG:
                        LD      A, B                            ; Get seed from B
                        LD      (RandomSeed8_CurrentSeed), A    ; Store the seed
RestoreParams:          POP     BC                              ; restore seed and selector
                        POP     AF                              ; restore limit
                        JP      Random8_Unified_Next

Random8_Seed_LFSR:
                        LD      A, B                            ; Get seed from B
                        OR      A                               ; Check if seed is 0
                        JP      NZ, LfsrSeed8_ValidSeed
                        LD      A, 1                            ; If 0, use 1 (LFSR can't use 0)
LfsrSeed8_ValidSeed:    LD      (LfsrSeed8_State), A            ; Store seed
                        JP      RestoreParams

Random8_Seed_XORShift:
                        LD      A, B                            ; Get seed from B
                        OR      A                               ; Check if seed is 0
                        JP      NZ, XorShiftSeed8_ValidSeed
                        LD      A, 1                            ; If 0, use 1 (XORShift can't use 0)
XorShiftSeed8_ValidSeed:
                        LD      (XorShiftSeed8_State), A        ; Store seed
                        JP      RestoreParams

Random8_Seed_MiddleSquare:
                        LD      A, B                            ; Get seed from B
                        OR      A                               ; Check if seed is 0
                        JP      NZ, MiddleSquareSeed8_ValidSeed
                        LD      A, 1                            ; If 0, use 1
MiddleSquareSeed8_ValidSeed:
                        LD      (MiddleSquareSeed8_State), A    ; Store seed
                        JP      RestoreParams

; Get next random number using previously set seeding, limit can change per call making each algorith useable for multiple ranges as needed.
;
; Input:  A = upper limit INCLUSIVE (0 to A)
;         C = algorithm selection (PERFORMANCE_RANDOM_xxx)
; Output: A = random number in range 0 to limit inclusive.
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Random8_Unified_Next:
                        LD      B, A                            ; Save limit
                        LD      A, C                            ; Get algorithm selector
                        CP      PERFORMANCE_RANDOM_LCG
                        JP      Z, Random8_Next_LCG
                        CP      PERFORMANCE_Z80N_RANDOM_LCG
                        JP      Z, Random8_Z80N_Next_LCG
                        CP      PERFORMANCE_RANDOM_LFSR
                        JP      Z, Random8_Next_LFSR
                        CP      PERFORMANCE_Z80N_RANDOM_LFSR
                        JP      Z, Random8_Z80N_Next_LFSR
                        CP      PERFORMANCE_RANDOM_XORSHIFT
                        JP      Z, Random8_Next_XORShift
                        CP      PERFORMANCE_Z80N_RANDOM_XORSHIFT
                        JP      Z, Random8_Z80N_Next_XORShift
                        CP      PERFORMANCE_RANDOM_MIDDLESQUARE
                        JP      Z, Random8_Next_MiddleSquare
                        JP      Random8_Z80N_Next_MiddleSquare
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Random8_Next_LCG:       LD      A, B                            ; Restore limit
                        PUSH    BC                              ; Save registers
                        PUSH    HL

                        ; Save the upper limit and convert to exclusive for modulo operation
                        LD      C, A                            ; C = upper limit (inclusive)
                        INC     C                               ; C = upper limit + 1 (for modulo)
                    
                        ; Generate next random number using LCG formula: next = (seed * 5 + 7) MOD 256
                        LD      A, (RandomSeed8_CurrentSeed)    ; Get current seed
                    
                        ; Multiply by 5 (seed * 5)
                        LD      H, A                            ; Save original seed
                        ADD     A, A                            ; seed * 2
                        ADD     A, A                            ; seed * 4
                        ADD     A, H                            ; seed * 4 + seed = seed * 5
                        ; Add 7
                        ADD     A, 7                            ; (seed * 5) + 7
                    
                        ; Result is automatically MOD 256 due to 8-bit overflow
                        LD      (RandomSeed8_CurrentSeed), A    ; Store new seed
                    
                        ; Check if upper limit + 1 is 0 or 1 (special cases)
                        LD      A, C                            ; Get upper limit + 1
                        CP      1                               ; Compare with 1
                        JP      Z, Random8_ReturnZero           ; If limit+1 is 1 (original limit was 0), return 0
                        OR      A                               ; Check if zero (overflow from 255+1)
                        JP      Z, Random8_ReturnRaw            ; If limit+1 is 0 (original limit was 255), return raw value

                        ; Now we need to get the random number modulo the upper limit + 1
                        ; Use the new seed as our random value
                        LD      A, (RandomSeed8_CurrentSeed)    ; Get the new random seed
                        LD      B, C                            ; B = upper limit + 1 (divisor)
                    
                        ; Simple modulo using repeated subtraction
Random8_ModLoop:        CP      B                               ; Compare A with upper limit + 1
                        JP      C, Random8_Done                 ; If A < limit+1, we're done
                        SUB     B                               ; A = A - (limit+1)
                        JP      Random8_ModLoop                 ; Continue until A < limit+1
Random8_Done:           ; A now contains random number in range 0 to limit (inclusive)
                        POP     HL                              ; Restore registers
                        POP     BC
                        RET
Random8_ReturnZero:     XOR     A                               ; Return 0 if limit was 0
                        JP      Random8_Done
Random8_ReturnRaw:      ; Return raw random value if limit was 255 (covers full 0-255 range)
                        LD      A, (RandomSeed8_CurrentSeed)    ; Get the raw random value
                        JP      Random8_Done
;
; @COMPAT: NEXT
; @Z80N: MUL DE
; @REQUIRES: Spectrum Next, Z80N architecture.
Random8_Z80N_Next_LCG:  LD      A, B                            ; Restore limit
                        PUSH    BC                              ; Save registers
                        PUSH    HL
                        LD      C, A                            ; C = upper limit (inclusive)
                        INC     C                               ; C = upper limit + 1 (for modulo)

                        ; Generate next random number using LCG formula: next = (seed * 5 + 7) MOD 256
                        LD      A, (RandomSeed8_CurrentSeed)    ; Get current seed
                        LD      D, A                            ; D = seed
                        LD      E, 5                            ; E = 5
                        MUL     DE                              ; DE = seed * 5
                        LD      A, E                            ; A = low byte of result (seed * 5)
                        ADD     A, 7                            ; A = (seed * 5) + 7

                        ; Multiply by 5 (seed * 5)
                        LD      H, A                            ; Save original seed
                        ADD     A, A                            ; seed * 2
                        ADD     A, A                            ; seed * 4
                        ADD     A, H                            ; seed * 4 + seed = seed * 5
                        ; Add 7
                        ADD     A, 7                            ; (seed * 5) + 7

                        ; Result is automatically MOD 256 due to 8-bit overflow
                        LD      (RandomSeed8_CurrentSeed), A    ; Store new seed

                        ; Check if upper limit + 1 is 0 or 1 (special cases)
                        LD      A, C                            ; Get upper limit + 1
                        CP      1                               ; Compare with 1
                        JP      Z, Random8_ReturnZero           ; If limit+1 is 1 (original limit was 0), return 0
                        OR      A                               ; Check if zero (overflow from 255+1)
                        JP      Z, Random8_ReturnRaw            ; If limit+1 is 0 (original limit was 255), return raw value

                        ; Simple modulo using Z80N-optimized division
                        LD      A, (RandomSeed8_CurrentSeed)
                        LD      D, A                            ; Dividend saved - so we dont need unified
                        LD      B, C                            ; Divisor is upper limit + 1
                        CALL    Divide8x8_Next_Hybrid
                        LD      A, B                            ; Remainder is in B
                        JP      Random8_Done

; Get next random number using LFSR algorithm
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Random8_Next_LFSR:
                        LD      A, B                            ; Restore limit
Lfsr8:                  ; Get next LFSR random number
                        PUSH    BC                              ; Save registers
                        LD      C, A                            ; Save limit

                        ; LFSR with polynomial x^8 + x^6 + x^5 + x^4 + 1
                        LD      A, (LfsrSeed8_State)            ; Get current state
                        LD      B, A                            ; Save original

                        ; Calculate feedback bit: bit7 XOR bit5 XOR bit4 XOR bit3
                        AND     0x80                            ; Isolate bit 7
                        JR      Z, Lfsr8_Bit7Clear
                        LD      A, 1                            ; Set feedback if bit 7 set
                        JR      Lfsr8_CheckBit5
Lfsr8_Bit7Clear:        LD      A, 0                            ; Clear feedback if bit 7 clear
Lfsr8_CheckBit5:        LD      H, A                            ; Save feedback so far
                        LD      A, B                            ; Get original value
                        AND     0x20                            ; Isolate bit 5
                        JR      Z, Lfsr8_CheckBit4
                        LD      A, H                            ; Get current feedback
                        XOR     1                               ; XOR with bit 5
                        LD      H, A                            ; Save result
Lfsr8_CheckBit4:        LD      A, B                            ; Get original value
                        AND     0x10                            ; Isolate bit 4
                        JR      Z, Lfsr8_CheckBit3
                        LD      A, H                            ; Get current feedback
                        XOR     1                               ; XOR with bit 4
                        LD      H, A                            ; Save result
Lfsr8_CheckBit3:        LD      A, B                            ; Get original value
                        AND     0x08                            ; Isolate bit 3
                        JR      Z, Lfsr8_Shift
                        LD      A, H                            ; Get current feedback
                        XOR     1                               ; XOR with bit 3
                        LD      H, A                            ; Save result
Lfsr8_Shift:            LD      A, B                            ; Get original state
                        SLA     A                               ; Shift left
                        LD      B, H                            ; Get feedback bit
                        OR      B                               ; Set bit 0 to feedback
                        LD      (LfsrSeed8_State), A            ; Store new state
                        ; Apply modulo for range
                        LD      A, C                            ; Get limit
                        OR      A                               ; Check if 0
                        JR      Z, Lfsr8_ReturnZero
                        INC     A                               ; Make inclusive
                        LD      B, A                            ; B = divisor
Lfsr8Modulo:            LD      A, (LfsrSeed8_State)            ; Get random value
Lfsr8_ModLoop:          CP      B                               ; Compare with limit + 1
                        JR      C, Lfsr8_Done                   ; If < limit+1, done
                        SUB     B                               ; Subtract limit+1
                        JR      Lfsr8_ModLoop                   ; Continue
Lfsr8_Done:             POP     BC                              ; Restore registers
                        RET
Lfsr8_ReturnZero:       LD      A, 0                            ; Return 0 for limit 0
                        JR      Lfsr8_Done
;
; @COMPAT: NEXT
; @Z80N: MUL DE
; @REQUIRES: Spectrum Next, Z80N architecture.
Random8_Z80N_Next_LFSR:     PUSH    BC                          ; Preserve BC
                            ; Load current seed
                            LD      A, (LfsrSeed8_State)        ; A = current seed
                            ; Check for zero seed (forbidden state)
                            OR      A                           ; Test if seed is zero
                            JR      NZ, R8_Z80N_LFSR_Process    ; If not zero, continue
                            LD      A, 0x9A                     ; Use default non-zero seed
                            LD      (LfsrSeed8_State), A        ; Store it
R8_Z80N_LFSR_Process:       ; We'll use Z80N MUL to accelerate the bit extraction (bit 5)
                            LD      B, A                        ; B = seed (preserve original)
                            ; Extract bit 0 using MUL (bit 0 → carry when multiplied by 2)
                            LD      D, A                        ; D = seed
                            LD      E, 2                        ; E = 2 (multiply by 2 puts bit 0 in carry)
                            MUL     DE                          ; DE = seed * 2, carry = bit 0
                            LD      C, 0                        ; C = 0
                            ADC     C, C                        ; C = bit 0 (from carry)
                            ; Extract bit 2 using Z80N bit manipulation
                            LD      A, B                        ; A = original seed
                            SRL     A                           ; Shift right 1 (bit 2 → bit 1)
                            SRL     A                           ; Shift right 2 (bit 2 → bit 0)
                            PUSH    AF                          ; Save A
                            AND     1                           ; Isolate bit 0 (original bit 2)
                            XOR     C                           ; XOR with bit 0
                            LD      C, A                        ; C = bit 0 xor bit 2
                            ; Extract bit 3 using efficient shifting
                            POP     AF                          ; Restore A
                            SRL     A                           ; Shift right 3 (bit 3 → bit 0)
                            AND     1                           ; Isolate bit 0 (original bit 3)
                            XOR     C                           ; XOR with previous result
                            LD      C, A                        ; C = bit 0 xor bit 2 xor bit 3
                            ; Extract bit 5 using Z80N MUL for fast division
                            LD      D, B                        ; D = original seed
                            LD      E, 8                        ; E = 8 (2^3)
                            MUL     DE                          ; DE = seed * 8
                            LD      A, D                        ; A = high byte (contains bit 5 in bit 0)
                            AND     1                           ; Isolate bit 0 (original bit 5)
                            XOR     C                           ; XOR with previous result
                            LD      C, A                        ; C = feedback bit
                            ; Shift seed right and insert feedback bit at position 7
                            LD      A, B                        ; A = original seed
                            SRL     A                           ; Shift right (bit 7 becomes 0)
                            ; Insert feedback bit at position 7 using Z80N optimization
                            LD      B, C                        ; B = feedback bit (0 or 1)
                            LD      D, B                        ; D = feedback bit
                            LD      E, 128                      ; E = 128 (bit 7 mask)
                            MUL     DE                          ; DE = feedback_bit * 128
                            LD      B, E                        ; B = feedback bit shifted to position 7
                            OR      B                           ; A = new seed with feedback bit
                            ; Store new seed and return
                            LD      (LfsrSeed8_State), A        ; Store new seed
                            ; Apply modulo for range - INLINE instead of JP
                            POP     BC                          ; Restore BC first!
                            LD      A, B                        ; Get limit
                            OR      A                           ; Check if 0
                            JR      Z, R8_Z80N_LFSR_ReturnZero
                            INC     A                           ; Make inclusive
                            LD      B, A                        ; B = divisor
                            LD      A, (LfsrSeed8_State)        ; Get random value
                            
R8_Z80N_LFSR_ModLoop:       CP      B                           ; Compare with limit + 1
                            JR      C, R8_Z80N_LFSR_Done        ; If < limit+1, done
                            SUB     B                           ; Subtract limit+1
                            JR      R8_Z80N_LFSR_ModLoop        ; Continue
R8_Z80N_LFSR_ReturnZero:    XOR     A                           ; Return 0 for limit 0
R8_Z80N_LFSR_Done:          RET                                 ; Return properly

; Get next random number using XOR Shift algorithm
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Random8_Next_XORShift:
                        LD      A, B                            ; Restore limit
                        PUSH    BC                              ; Save registers
                        LD      C, A                            ; Save limit
                        ; XORShift algorithm with proven 8-bit parameters
                        LD      A, (XorShiftSeed8_State)        ; Get current state
                        ; Proven variant: x ^= x << 3; x ^= x >> 5; x ^= x << 1
                        LD      B, A                            ; Save original
                        ; x ^= x << 3
                        SLA     A                               ; x << 1
                        SLA     A                               ; x << 2
                        SLA     A                               ; x << 3
                        XOR     B                               ; x ^= (x << 3)
                        LD      B, A                            ; Save current state
                        ; x ^= x >> 5  
                        SRL     A                               ; x >> 1
                        SRL     A                               ; x >> 2
                        SRL     A                               ; x >> 3
                        SRL     A                               ; x >> 4
                        SRL     A                               ; x >> 5
                        XOR     B                               ; x ^= (x >> 5)
                        LD      B, A                            ; Save current state
                        ; x ^= x << 1
                        ADD     A, A                            ; x << 1
                        XOR     B                               ; x ^= (x << 1)
                        ; Ensure non-zero
                        OR      A                               ; Test if 0
                        JR      NZ, XorShift8_StateOK
                        LD      A, 1                            ; If 0, use 1
XorShift8_StateOK:      LD      (XorShiftSeed8_State), A        ; Store new state
                        ; Apply modulo for range (optimized for large ranges)
                        LD      A, C                            ; Get limit
                        OR      A                               ; Check if 0
                        JP      Z, XorShift8_ReturnZero
                        CP      255                             ; Check if limit is 255 (full range)
                        JP      Z, XorShift8_ReturnRaw          ; If 255, return raw value (0-255)
                        INC     A                               ; Make inclusive (limit + 1)
                        LD      B, A                            ; B = divisor
                        LD      A, (XorShiftSeed8_State)        ; Get random value

                        ; Simple modulo with safety limit
XorShift8_ModLoop:      CP      B                               ; Compare with limit + 1
                        JP      C, XorShift8_Done               ; If < limit+1, done
                        SUB     B                               ; Subtract limit+1
                        JR      XorShift8_ModLoop               ; Continue
XorShift8_ReturnRaw:                                            ; Return raw random value for limit 255
                        LD      A, (XorShiftSeed8_State)        ; Get raw random value
XorShift8_Done:         POP     BC                              ; Restore registers
                        RET
XorShift8_ReturnZero:   LD      A, 0                            ; Return 0 for limit 0
                        JR      XorShift8_Done
;
; @COMPAT: NEXT
; @Z80N: MUL DE
; @REQUIRES: Spectrum Next, Z80N architecture.
Random8_Z80N_Next_XORShift:  
                        LD      A, B                            ; Restore limit
                        PUSH    BC                              ; Save registers
                        LD      C, A                            ; Save limit    
                        ; Algorithm : x ^= x << 7; x ^= x >> 9; x ^= x << 8
                        LD      A, (XorShiftSeed8_State)        ; Get current state
                        LD      B, A                            ; Save original state
                        ; x ^= (x << 7) - left shift 7, XOR with original
                        LD      D, A                            ; Copy original
                        LD      E, 128                          ; same as 7 shifts
                        MUL     DE
                        ADD     A, E                            ; x << 7
                        XOR     B                               ; XOR with original
                        LD      B, A                            ; Save intermediate state
                        ; x ^= (x >> 1) - right shift 9 simplified for 8 bit, XOR with original
                        SRL     A
                        XOR     B
                        LD      B, A                            ; Save intermediate state
                        ; x ^= (x << 1) - simplified left shift 1, XOR with original
                        ADD     A, A
                        XOR     B
                        LD      (XorShiftSeed8_State), A        ; store new state
                        ; Simple modulo using Z80N-optimized division
                        LD      D, A                            ; Dividend saved - so we dont need unified
                        LD      B, C                            ; Divisor is upper limit
                        INC     B                               ; Make inclusive (limit + 1)
                        CALL    Divide8x8_Next_Hybrid
                        LD      A, B                            ; Remainder is in B
                        POP     BC                              ; Restore registers
                        RET

; Get next random number using Middle Square algorithm
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Random8_Next_MiddleSquare:
                        LD      A, B                            ; Restore limit
                        PUSH    BC                              ; Save registers
                        PUSH    DE
                        PUSH    HL
                        LD      C, A                            ; Save limit
                        
                        ; Square the current state
                        LD      A, (MiddleSquareSeed8_State)    ; Get current state
                        LD      D, 0                            ; Clear high byte
                        LD      E, A                            ; DE = seed
                        LD      B, A                            ; B = multiplier
                        LD      HL, 0                           ; Initialize result
                        
                        ; Multiply A * A using repeated addition
MiddleSquare8_MultLoop:
                        LD      A, B                            ; Get multiplier
                        OR      A                               ; Check if zero
                        JR      Z, MiddleSquare8_MultDone
                        ADD     HL, DE                          ; Add multiplicand
                        DEC     B                               ; Decrement counter
                        JR      MiddleSquare8_MultLoop
MiddleSquare8_MultDone:
                        ; HL now contains seed^2 (16-bit result)
                        ; Extract middle 8 bits: take bits 11-4 of 16-bit result
                        LD      A, L                            ; Get low byte
                        SRL     A                               ; Shift right 1
                        SRL     A                               ; Shift right 2
                        SRL     A                               ; Shift right 3
                        SRL     A                               ; Shift right 4 (now bits 7-4 of L)
                        LD      B, A                            ; Save low part
                        LD      A, H                            ; Get high byte
                        AND     0x0F                            ; Keep only bits 3-0 of H
                        SLA     A                               ; Shift left 1
                        SLA     A                               ; Shift left 2
                        SLA     A                               ; Shift left 3
                        SLA     A                               ; Shift left 4 (now bits 3-0 become 7-4)
                        OR      B                               ; Combine with low part
                        OR      A                               ; Check if result is 0
                        JR      NZ, MiddleSquare8_ValidResult
                        LD      A, 1                            ; If 0, use 1 to avoid stuck state
MiddleSquare8_ValidResult:
                        LD      (MiddleSquareSeed8_State), A    ; Store new state
                        
                        ; Apply modulo for range
                        LD      A, C                            ; Get limit
                        OR      A                               ; Check if 0
                        JR      Z, MiddleSquare8_ReturnZero
                        INC     A                               ; Make inclusive
                        LD      B, A                            ; B = divisor
                        LD      A, (MiddleSquareSeed8_State)    ; Get random value
MiddleSquare8_ModLoop:  CP   B                                  ; Compare with limit + 1
                        JR      C, MiddleSquare8_Done           ; If < limit+1, done
                        SUB     B                               ; Subtract limit+1
                        JR      MiddleSquare8_ModLoop           ; Continue
MiddleSquare8_Done:     POP     HL                              ; Restore registers
                        POP     DE
                        POP     BC
                        RET
MiddleSquare8_ReturnZero: 
                        LD      A, 0                            ; Return 0 for limit 0
                        JR      MiddleSquare8_Done
;
; @COMPAT: NEXT
; @Z80N: MUL DE
; @REQUIRES: Spectrum Next, Z80N architecture.
Random8_Z80N_Next_MiddleSquare:
                        LD      A, B                            ; Restore limit from B
                        PUSH    BC                              ; Save registers
                        PUSH    DE
                        PUSH    HL
                        LD      C, A                            ; Save limit in C
                        ; Load current seed and square it using Z80N MUL
                        LD      A, (MiddleSquareSeed8_State)    ; Get current state
                        OR      A                               ; Check for zero seed
                        JP      NZ, MS_Z80N_ValidSeed
                        LD      A, 1                            ; If zero, use 1 to avoid stuck state
                        LD      (MiddleSquareSeed8_State), A    ; Store non-zero seed
MS_Z80N_ValidSeed:      ; Square the seed using Z80N hardware multiplication
                        LD      D, A                            ; D = seed
                        LD      E, A                            ; E = seed  
                        MUL     DE                              ; DE = seed * seed (16-bit result)
                        ; For 8-bit Middle Square: take bits 11-4 from DE
                        ; Shift DE right by 4 bits using Z80N optimization
                        ; Instead of 4 SRL operations, use division by 16
                        EX      DE, HL                          ; Exchange DE and HL for easy shifting
                        ; Extract bits 11-4 by shifting right 4 positions
                        SRL     H                               ; Shift bit 15 to 14, etc.
                        RR      L                               ; Rotate through carry to L
                        SRL     H                               ; Shift right 2
                        RR      L
                        SRL     H                               ; Shift right 3  
                        RR      L
                        SRL     H                               ; Shift right 4
                        RR      L                               ; L now contains middle 8 bits of DE result
                        LD      A, L                            ; A = extracted middle bits
                        ; Ensure we don't have a zero result (would cause stuck state)
                        OR      A                               ; Check if result is 0
                        JP      NZ, MS_Z80N_ValidResult
                        LD      A, 1                            ; If 0, use 1 to avoid stuck state
MS_Z80N_ValidResult:    LD      (MiddleSquareSeed8_State), A    ; Store new state
                        ; Apply modulo to return random State in the correct range.
                        LD      A, C                            ; Get limit
                        OR      A                               ; Check if limit is 0
                        JR      Z, MS_Z80N_ReturnZero
                        CP      255                             ; Check if limit is 255 (full range)
                        JR      Z, MS_Z80N_ReturnRaw            ; If 255, return raw value
                        INC     A                               ; A = limit + 1 (exclusive upper bound)
                        LD      B, A                            ; B = divisor (limit + 1)
                        LD      A, (MiddleSquareSeed8_State)    ; A = dividend (random value)
                        LD      D, A                            ; D = dividend for division routine
                        CALL    Divide8x8_Next_Hybrid          ; Call Z80N optimized division
                        LD      A, B                            ; A = remainder (result in range 0 to limit)
                        JR      MS_Z80N_Done
MS_Z80N_ReturnZero:     LD      A, 0                            ; Return 0 for limit 0
                        JR      MS_Z80N_Done
MS_Z80N_ReturnRaw:      LD      A, (MiddleSquareSeed8_State)    ; Return raw value for limit 255
MS_Z80N_Done:           POP     HL                              ; Restore registers
                        POP     DE
                        POP     BC
                        RET                                     ; Return with random value in A
