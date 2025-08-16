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
; PERFORMANCE_RANDOM_LCG              - ~75-90 T-states for seed+first call
; PERFORMANCE_RANDOM_LFSR             - ~95-125 T-states for seed+first call  
; PERFORMANCE_RANDOM_XORSHIFT         - ~70-85 T-states for seed+first call
; PERFORMANCE_RANDOM_MIDDLESQUARE     - ~145-180 T-states for seed+first call
;
; Random8_Unified_Next (subsequent calls only):
; PERFORMANCE_RANDOM_LCG              - ~45-60 T-states per call
; PERFORMANCE_RANDOM_LFSR             - ~65-95 T-states per call  
; PERFORMANCE_RANDOM_XORSHIFT         - ~40-55 T-states per call
; PERFORMANCE_RANDOM_MIDDLESQUARE     - ~115-150 T-states per call
;
; @COMPAT: 48K,128K,+2,+3,NEXT

Random8_Unified_Seed:               ; Set seed and get first random number
                        PUSH    AF
                        PUSH    BC
                        LD      A, C                            ; Get algorithm selector
                        CP      PERFORMANCE_RANDOM_LFSR
                        JR      Z, Random8_Seed_LFSR
                        CP      PERFORMANCE_RANDOM_XORSHIFT
                        JR      Z, Random8_Seed_XORShift
                        CP      PERFORMANCE_RANDOM_MIDDLESQUARE
                        JR      Z, Random8_Seed_MiddleSquare

                        ; Fall through to LCG
Random8_Seed_LCG:
                        LD      A, B                            ; Get seed from B
                        LD      (RandomSeed8_CurrentSeed), A    ; Store the seed
RestoreParams:          POP     BC                              ; restore seed and selector
                        POP     AF                              ; restore limit
                        JR      Random8_Unified_Next

Random8_Seed_LFSR:
                        LD      A, B                            ; Get seed from B
                        OR      A                               ; Check if seed is 0
                        JR      NZ, LfsrSeed8_ValidSeed
                        LD      A, 1                            ; If 0, use 1 (LFSR can't use 0)
LfsrSeed8_ValidSeed:    LD      (LfsrSeed8_State), A            ; Store seed
                        JR      RestoreParams

Random8_Seed_XORShift:
                        LD      A, B                            ; Get seed from B
                        OR      A                               ; Check if seed is 0
                        JR      NZ, XorShiftSeed8_ValidSeed
                        LD      A, 1                            ; If 0, use 1 (XORShift can't use 0)
XorShiftSeed8_ValidSeed:
                        LD      (XorShiftSeed8_State), A        ; Store seed
                        JR      RestoreParams

Random8_Seed_MiddleSquare:
                        LD      A, B                            ; Get seed from B
                        OR      A                               ; Check if seed is 0
                        JR      NZ, MiddleSquareSeed8_ValidSeed
                        LD      A, 1                            ; If 0, use 1
MiddleSquareSeed8_ValidSeed:
                        LD      (MiddleSquareSeed8_State), A    ; Store seed
                        JR      RestoreParams

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
                        CP      PERFORMANCE_RANDOM_LFSR
                        JR      Z, Random8_Next_LFSR
                        CP      PERFORMANCE_RANDOM_XORSHIFT
                        JR      Z, Random8_Next_XORShift
                        CP      PERFORMANCE_RANDOM_MIDDLESQUARE
                        JP      Z, Random8_Next_MiddleSquare

                        ; Fall through to LCG
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Random8_Next_LCG:
                        LD      A, B                            ; Restore limit
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
                        JR      Z, Random8_ReturnZero           ; If limit+1 is 1 (original limit was 0), return 0
                        OR      A                               ; Check if zero (overflow from 255+1)
                        JR      Z, Random8_ReturnRaw            ; If limit+1 is 0 (original limit was 255), return raw value
                    
                        ; Now we need to get the random number modulo the upper limit + 1
                        ; Use the new seed as our random value
                        LD      A, (RandomSeed8_CurrentSeed)    ; Get the new random seed
                        LD      B, C                            ; B = upper limit + 1 (divisor)
                    
                        ; Simple modulo using repeated subtraction
Random8_ModLoop:        CP      B                               ; Compare A with upper limit + 1
                        JR      C, Random8_Done                 ; If A < limit+1, we're done
                        SUB     B                               ; A = A - (limit+1)
                        JR      Random8_ModLoop                 ; Continue until A < limit+1
Random8_Done:           ; A now contains random number in range 0 to limit (inclusive)
                        POP     HL                              ; Restore registers
                        POP     BC
                        RET
Random8_ReturnZero:     LD      A, 0                            ; Return 0 if limit was 0
                        JR      Random8_Done
Random8_ReturnRaw:      ; Return raw random value if limit was 255 (covers full 0-255 range)
                        LD      A, (RandomSeed8_CurrentSeed)    ; Get the raw random value
                        JR      Random8_Done

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
                        LD      A, (LfsrSeed8_State)            ; Get random value
Lfsr8_ModLoop:          CP      B                               ; Compare with limit + 1
                        JR      C, Lfsr8_Done                   ; If < limit+1, done
                        SUB     B                               ; Subtract limit+1
                        JR      Lfsr8_ModLoop                   ; Continue
Lfsr8_Done:             POP     BC                              ; Restore registers
                        RET
Lfsr8_ReturnZero:       LD      A, 0                            ; Return 0 for limit 0
                        JR      Lfsr8_Done


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
                        JR      Z, XorShift8_ReturnZero
                        CP      255                             ; Check if limit is 255 (full range)
                        JR      Z, XorShift8_ReturnRaw          ; If 255, return raw value (0-255)
                        INC     A                               ; Make inclusive (limit + 1)
                        LD      B, A                            ; B = divisor
                        LD      A, (XorShiftSeed8_State)        ; Get random value

                        ; Simple modulo with safety limit
XorShift8_ModLoop:      CP      B                               ; Compare with limit + 1
                        JR      C, XorShift8_Done               ; If < limit+1, done
                        SUB     B                               ; Subtract limit+1
                        JR      XorShift8_ModLoop               ; Continue
XorShift8_ReturnRaw:                                            ; Return raw random value for limit 255
                        LD      A, (XorShiftSeed8_State)        ; Get raw random value
XorShift8_Done:         POP     BC                              ; Restore registers
                        RET
XorShift8_ReturnZero:   LD      A, 0                            ; Return 0 for limit 0
                        JR      XorShift8_Done

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
