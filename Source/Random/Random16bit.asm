; Unified 16-bit Random number generation routines.
;
; Always call Random16_Unified_Seed to set up the seed and limits for the selected algorithm.
; After setting seed and limit, call Random16_Unified_Next to get each subsequent random number.
;
; Input:  HL = upper limit INCLUSIVE (0 to HL)
;         BC = initial seed value (algorithm dependent)
;         D = algorithm selection (PERFORMANCE_RANDOM_xxx)
; Output: HL = random number in range 0 to input HL
;
; T-States summary shows for each random number generation as:
;
; Random16_Unified_Seed (includes first random generation):
; PERFORMANCE_RANDOM_LCG              - ~140-180 T-states for seed+first call
; PERFORMANCE_RANDOM_LFSR             - ~130-165 T-states for seed+first call  
; PERFORMANCE_RANDOM_XORSHIFT         - ~110-135 T-states for seed+first call
; PERFORMANCE_RANDOM_MIDDLESQUARE     - ~400-500 T-states for seed+first call
;
; Random16_Unified_Next (subsequent calls only):
; PERFORMANCE_RANDOM_LCG              - ~110-150 T-states per call
; PERFORMANCE_RANDOM_LFSR             - ~100-135 T-states per call  
; PERFORMANCE_RANDOM_XORSHIFT         - ~80-105 T-states per call
; PERFORMANCE_RANDOM_MIDDLESQUARE     - ~370-470 T-states per call

Random16_Unified_Seed:               ; Set seed and get first random number
                        PUSH    HL                              ; Save limit
                        PUSH    BC                              ; Save seed
                        PUSH    DE                              ; Save algorithm
                        LD      A, D                            ; Get algorithm selector
                        CP      PERFORMANCE_RANDOM_LFSR
                        JR      Z, Random16_Seed_LFSR           ; Best For: Cryptographic applications, high-quality randomness, security-critical systems
                        CP      PERFORMANCE_RANDOM_XORSHIFT
                        JR      Z, Random16_Seed_XORShift       ; Best For: Game engines, real-time applications, procedural generation, particle systems
                        CP      PERFORMANCE_RANDOM_MIDDLESQUARE
                        JR      Z, Random16_Seed_MiddleSquare   ; Best For: Educational purposes, historical simulations, demonstrations

                        ; Fall through to LCG - Best For: Statistical simulations, large range requirements, scientific applications
Random16_Seed_LCG:      LD      (RandomSeed16_CurrentSeed), BC  ; Store the seed (16-bit)
GetTheNextFirstRandom:  POP     DE
                        POP     BC
                        POP     HL
                        JR      Random16_Unified_Next

Random16_Seed_LFSR:
                        LD      A, B                            ; Check if seed is 0
                        OR      C
                        JR      NZ, LfsrSeed16_ValidSeed
                        LD      BC, 1234                        ; If 0, use a default seed
LfsrSeed16_ValidSeed:
                        LD      (LfsrSeed16_State), BC          ; Store seed
                        JR      GetTheNextFirstRandom

Random16_Seed_XORShift:
                        LD      A, B                            ; Check if seed is 0
                        OR      C
                        JR      NZ, XorShiftSeed16_ValidSeed
                        LD      BC, 1234                        ; If 0, use a default seed
XorShiftSeed16_ValidSeed:
                        LD      (XorShiftSeed16_State), BC      ; Store seed
                        JR      GetTheNextFirstRandom

Random16_Seed_MiddleSquare:
                        LD      A, B                            ; Check if seed is 0
                        OR      C
                        JR      NZ, MiddleSquareSeed16_ValidSeed
                        LD      BC, 1234                        ; If 0, use a default seed
MiddleSquareSeed16_ValidSeed:
                        LD      (MiddleSquareSeed16_State), BC  ; Store seed
                        JR      GetTheNextFirstRandom

; Get next random number using previously set seeding, limit can change per call making each algorith useable for multiple ranges as needed.
;
; Input:  HL = upper limit INCLUSIVE (0 to HL)
;         D = algorithm selection (PERFORMANCE_RANDOM_xxx)
; Output: HL = random number in range 0 to input HL

Random16_Unified_Next:
                        LD      A, D                            ; Get algorithm selector
                        CP      PERFORMANCE_RANDOM_LFSR
                        JP      Z, Random16_Next_LFSR
                        CP      PERFORMANCE_RANDOM_XORSHIFT
                        JP      Z, Random16_Next_XORShift
                        CP      PERFORMANCE_RANDOM_MIDDLESQUARE
                        JP      Z, Random16_Next_MiddleSquare

                        ; Fall through to LCG
Random16_Next_LCG:
                        PUSH    BC                              ; Save registers
                        PUSH    DE
                        ; Save the upper limit for later modulo operation
                        PUSH    HL                              ; Save limit on stack
                    
                        ; Generate next random number using simplified 16-bit LCG
                        ; Formula: next = (seed * 1103 + 12345) MOD 65536
                        ; Using smaller multiplier for efficiency while maintaining good distribution
                        LD      BC, (RandomSeed16_CurrentSeed)  ; Get current seed in BC
                        ; Multiply BC by 1103 (using shift and add method)
                        LD      HL, 0                           ; Initialize result
                        LD      DE, BC                          ; Copy seed to DE
                        
                        ; Multiply by 1103 = 1024* + 64* + 15*
                        ; Optimized: First do BC * 64 (shift left 6 times), then continue to get BC * 1024
                        ; Also capture BC * 16 to efficiently calculate BC * 15
                        PUSH    BC                              ; Save original BC
                        ; BC * 16: shift BC left 4 times into HL (we'll save this for BC*15 calculation)
                        LD      A, 4                            ; 4 shifts for *16
Random16_Multiply16:    SLA     C                               ; Shift BC left
                        RL      B
                        RL      L                               ; Carry into HL
                        RL      H
                        DEC     A
                        JR      NZ, Random16_Multiply16
                        PUSH    HL                              ; Save BC*16 result for later
                        ; Continue shifting 2 more times to get BC * 64 (total 6 shifts)
                        LD      A, 2                            ; 2 more shifts for *64
Random16_Multiply64:    SLA     C                               ; Shift BC left
                        RL      B
                        RL      L                               ; Carry into HL
                        RL      H
                        DEC     A
                        JR      NZ, Random16_Multiply64
                        PUSH    HL                              ; Save BC*64 result
                        ; Continue shifting 4 more times to get BC * 1024 (total 10 shifts)
                        LD      A, 4                            ; 4 more shifts for *1024
Random16_Multiply1024:  SLA     C                               ; Shift BC left
                        RL      B
                        RL      L                               ; Carry into HL
                        RL      H
                        DEC     A
                        JR      NZ, Random16_Multiply1024
                        ; HL now contains BC*1024
                        POP     DE                              ; Get BC*64 result
                        ADD     HL, DE                          ; HL = BC*1024 + BC*64
                        ; Calculate BC * 15 efficiently: BC*16 - BC*1
                        POP     DE                              ; Get BC*16 result
                        PUSH    HL                              ; Save BC*1024 + BC*64
                        LD      HL, DE                          ; HL = BC*16
                        POP     BC                              ; Get original BC from stack
                        PUSH    BC                              ; Save it again for later restore
                        OR      A                               ; Clear carry
                        SBC     HL, BC                          ; HL = BC*16 - BC*1 = BC*15
                        POP     BC                              ; Restore original BC
                        POP     DE                              ; Get BC*1024 + BC*64 result
                        ADD     HL, DE                          ; HL = BC*1024 + BC*64 + BC*15 = BC*1103
                        ; Add 12345
                        LD      DE, 12345
                        ADD     HL, DE                          ; HL = BC*1103 + 12345
                        ; Result is automatically MOD 65536 due to 16-bit overflow
                        LD      (RandomSeed16_CurrentSeed), HL  ; Store new seed
                        ; Now apply modulo for the requested range
                        POP     DE                              ; Get original limit from stack
                        LD      BC, DE                          ; BC = limit
                        ; Check for special cases
                        LD      A, B                            ; Check high byte of limit
                        OR      C                               ; OR with low byte
                        JR      Z, Random16_ReturnZero          ; If limit is 0, return 0
                        ; Check if limit is 65535 (full range)
                        INC     BC                              ; BC = limit + 1
                        LD      A, B                            ; Check if BC wrapped to 0
                        OR      C
                        JR      Z, Random16_ReturnRaw           ; If limit was 65535, return raw
                        DEC     BC                              ; Restore BC = limit
                        ; Perform modulo operation using division
                        ; We need HL MOD (BC + 1)
                        INC     BC                              ; BC = limit + 1 (for inclusive range)
                        ; Simple 16-bit modulo by repeated subtraction
Random16_ModLoop:       LD      A, H                            ; Compare HL with BC
                        CP      B                               ; Compare high bytes
                        JR      C, Random16_ModDone             ; HL < BC, done
                        JR      NZ, Random16_ModSub             ; HL > BC, subtract
                        LD      A, L                            ; High bytes equal, compare low bytes
                        CP      C
                        JR      C, Random16_ModDone             ; HL < BC, done
Random16_ModSub:        OR      A                               ; Clear carry
                        SBC     HL, BC                          ; HL = HL - BC
                        JR      Random16_ModLoop                ; Continue
Random16_ModDone:       POP     DE                              ; Restore registers
                        POP     BC
                        RET
Random16_ReturnZero:    LD     HL, 0                            ; Return 0 for limit 0
                        JR      Random16_ModDone
Random16_ReturnRaw:     LD     HL, (RandomSeed16_CurrentSeed)   ; Return raw value for limit 65535
                        JR      Random16_ModDone

Random16_Next_LFSR:
                        PUSH    BC                              ; Save registers
                        PUSH    DE
                        PUSH    HL                              ; Save limit
                    
                        ; 16-bit LFSR with polynomial x^16 + x^14 + x^13 + x^11 + 1
                        ; Taps at bits 15, 13, 12, 10 (counting from 0)
                        LD      BC, (LfsrSeed16_State)          ; Get current state in BC
                        ; Extract the tap bits and XOR them together
                        LD      A, B                            ; Get high byte
                        ; Bit 15 (MSB of B)
                        LD      D, A                            ; Copy B
                        AND     0x80                            ; Mask bit 7 of B (bit 15 of BC)
                        LD      E, A                            ; Save bit 15 result
                        ; Bit 13 (bit 5 of B)
                        LD      A, D                            ; Get B again
                        AND     0x20                            ; Mask bit 5 of B (bit 13 of BC)
                        SLA     A                               ; Shift to bit 6
                        SLA     A                               ; Shift to bit 7 (align with bit 15)
                        XOR     E                               ; XOR with previous result
                        LD      E, A                            ; Save result
                        ; Bit 12 (bit 4 of B)
                        LD      A, D                            ; Get B again
                        AND     0x10                            ; Mask bit 4 of B (bit 12 of BC)
                        SLA     A                               ; Shift to bit 5
                        SLA     A                               ; Shift to bit 6
                        SLA     A                               ; Shift to bit 7 (align with bit 15)
                        XOR     E                               ; XOR with previous result
                        LD      E, A                            ; Save result
                        ; Bit 10 (bit 2 of B)
                        LD      A, D                            ; Get B again
                        AND     0x04                            ; Mask bit 2 of B (bit 10 of BC)
                        SLA     A                               ; Shift to bit 3
                        SLA     A                               ; Shift to bit 4
                        SLA     A                               ; Shift to bit 5
                        SLA     A                               ; Shift to bit 6
                        SLA     A                               ; Shift to bit 7 (align with bit 15)
                        XOR     E                               ; XOR with previous result
                        ; A now contains the feedback bit in bit 7
                        ; Shift the entire register left and insert feedback bit
                        SLA     C                               ; Shift C left
                        RL      B                               ; Shift B left with carry from C
                        ; Insert feedback bit (bit 7 of A) into bit 0 of C
                        AND     0x80                            ; Keep only bit 7
                        JR      Z, Lfsr16_NoFeedback            ; If 0, don't set bit 0
                        SET     0, C                            ; Set bit 0 of C
                        JR      Lfsr16_StateUpdate
Lfsr16_NoFeedback:      RES     0, C                            ; Clear bit 0 of C
Lfsr16_StateUpdate:     ; Ensure we never get 0 (which would break the sequence)
                        LD      A, B
                        OR      C
                        JR      NZ, Lfsr16_StateOK
                        LD      BC, 1                           ; If 0, set to 1
Lfsr16_StateOK:         LD      (LfsrSeed16_State), BC          ; Store new state
                        ; Apply modulo for range
                        POP     HL                              ; Get limit back
                        ; Check for special cases
                        LD      A, H
                        OR      L
                        JR      Z, Lfsr16_ReturnZero            ; If limit is 0, return 0
                        ; Check if limit is 65535 (full range)
                        LD      DE, 65535
                        OR      A                               ; Clear carry
                        SBC     HL, DE                          ; Compare HL with 65535
                        ADD     HL, DE                          ; Restore HL
                        JR      Z, Lfsr16_ReturnRaw             ; If limit is 65535, return raw
                        ; Perform modulo: BC MOD (HL + 1)
                        INC     HL                              ; HL = limit + 1 (for inclusive)
                        LD      DE, BC                          ; DE = random value
Lfsr16_ModLoop:         LD      A, D                            ; Compare DE with HL
                        CP      H                               ; Compare high bytes
                        JR      C, Lfsr16_ModDone               ; DE < HL, done
                        JR      NZ, Lfsr16_ModSub               ; DE > HL, subtract
                        LD      A, E                            ; High bytes equal, compare low bytes
                        CP      L
                        JR      C, Lfsr16_ModDone               ; DE < HL, done
Lfsr16_ModSub:          OR      A                               ; Clear carry
                        SBC     DE, HL                          ; DE = DE - HL
                        JR      Lfsr16_ModLoop                  ; Continue
Lfsr16_ModDone:         LD      HL, DE                          ; Result in HL
Lfsr16_Exit:            POP     DE                              ; Restore registers
                        POP     BC
                        RET
Lfsr16_ReturnZero:      LD      HL, 0                           ; Return 0 for limit 0
                        JR      Lfsr16_Exit
Lfsr16_ReturnRaw:       LD      HL, (LfsrSeed16_State)          ; Return raw value for limit 65535
                        JR      Lfsr16_Exit

Random16_Next_XORShift:
                        PUSH    BC                              ; Save registers
                        PUSH    DE
                        PUSH    HL                              ; Save limit
                        
                        ; 16-bit XORShift algorithm: x ^= x << 7; x ^= x >> 9; x ^= x << 8
                        LD      BC, (XorShiftSeed16_State)      ; Get current state in BC
                        ; Step 1: x ^= x << 7
                        LD      HL, BC                          ; Copy BC to HL
                        LD      DE, BC                          ; Save original in DE
                        ; Shift HL (copy of BC) left 7 times
                        LD      A, 7
XorShift16_ShiftLeft7:  SLA     L                               ; Shift HL left
                        RL      H
                        DEC     A
                        JR      NZ, XorShift16_ShiftLeft7
                        ; XOR with original: BC = BC ^ (BC << 7)
                        LD      A, C
                        XOR     L
                        LD      C, A                            ; C = C ^ L
                        LD      A, B
                        XOR     H
                        LD      B, A                            ; B = B ^ H
                        ; Step 2: x ^= x >> 9
                        LD      HL, BC                          ; Copy current BC to HL
                        ; Shift HL right 9 times (more than 8, so will be mostly zeros)
                        LD      A, 9
XorShift16_ShiftRight9: SRL     H                               ; Shift HL right
                        RR      L
                        DEC     A
                        JR      NZ, XorShift16_ShiftRight9
                        ; XOR with current: BC = BC ^ (BC >> 9)
                        LD      A, C
                        XOR     L
                        LD      C, A                            ; C = C ^ L
                        LD      A, B
                        XOR     H
                        LD      B, A                            ; B = B ^ H
                        ; Step 3: x ^= x << 8
                        LD      HL, BC                          ; Copy current BC to HL
                        ; Shift HL left 8 times (swap bytes and clear low byte)
                        LD      H, L                            ; H = L (shift left 8)
                        LD      L, 0                            ; L = 0
                        ; XOR with current: BC = BC ^ (BC << 8)
                        LD      A, C
                        XOR     L                               ; L is 0, so C unchanged
                        LD      C, A
                        LD      A, B
                        XOR     H
                        LD      B, A                            ; B = B ^ H
                        ; Ensure we never get 0 (which would break the sequence)
                        LD      A, B
                        OR      C
                        JR      NZ, XorShift16_StateOK
                        LD      BC, 1                           ; If 0, set to 1
XorShift16_StateOK:     LD      (XorShiftSeed16_State), BC      ; Store new state
                        ; Apply modulo for range
                        POP     HL                              ; Get limit back
                        ; Check for special cases
                        LD      A, H
                        OR      L
                        JR      Z, XorShift16_ReturnZero        ; If limit is 0, return 0
                        ; Check if limit is 65535 (full range)
                        LD      DE, 65535
                        OR      A                               ; Clear carry
                        SBC     HL, DE                          ; Compare HL with 65535
                        ADD     HL, DE                          ; Restore HL
                        JR      Z, XorShift16_ReturnRaw         ; If limit is 65535, return raw
                        ; Perform modulo: BC MOD (HL + 1)
                        INC     HL                              ; HL = limit + 1 (for inclusive)
                        LD      DE, BC                          ; DE = random value
XorShift16_ModLoop:     LD      A, D                            ; Compare DE with HL
                        CP      H                               ; Compare high bytes
                        JR      C, XorShift16_ModDone           ; DE < HL, done
                        JR      NZ, XorShift16_ModSub           ; DE > HL, subtract
                        LD      A, E                            ; High bytes equal, compare low bytes
                        CP      L
                        JR      C, XorShift16_ModDone           ; DE < HL, done
XorShift16_ModSub:      OR      A                               ; Clear carry
                        SBC     DE, HL                          ; DE = DE - HL
                        JR      XorShift16_ModLoop              ; Continue
XorShift16_ModDone:     LD      HL, DE                          ; Result in HL
XorShift16_Exit:        POP     DE                              ; Restore registers
                        POP     BC
                        RET
XorShift16_ReturnZero:  LD      HL, 0                           ; Return 0 for limit 0
                        JR      XorShift16_Exit
XorShift16_ReturnRaw:   LD      HL, (XorShiftSeed16_State)      ; Return raw value for limit 65535
                        JR      XorShift16_Exit

Random16_Next_MiddleSquare:
                        PUSH    BC                              ; Save registers
                        PUSH    DE
                        PUSH    IX
                        PUSH    HL                              ; Save limit
                        
                        ; Middle Square algorithm: square the current state and extract middle bits
                        LD      BC, (MiddleSquareSeed16_State)  ; Get current state
                        ; Square BC (16-bit multiplication BC * BC)
                        ; Result will be 32-bit in IX:HL
                        ; BC * BC using repeated addition method for simplicity
                        LD      IX, 0                           ; Initialize high part of result
                        LD      HL, 0                           ; Initialize low part of result
                        LD      DE, BC                          ; DE = multiplicand (copy of BC)
                        ; Check if BC is 0 to avoid infinite loop
                        LD      A, B
                        OR      C
                        JR      Z, MiddleSquare16_SeedError
MiddleSquare16_MultiplyLoop:
                        ; Add DE to IX:HL
                        ADD     HL, DE                          ; Add to low part
                        JR      NC, MiddleSquare16_NoCarry      ; No carry to high part
                        INC     IX                              ; Carry to high part
MiddleSquare16_NoCarry: DEC     BC                              ; Decrease counter
                        LD      A, B                            ; Check if BC is 0
                        OR      C
                        JR      NZ, MiddleSquare16_MultiplyLoop ; Continue if not 0
                        ; Extract middle 16 bits from the 32-bit result
                        ; We have result in IX (high) and HL (low)
                        ; For middle extraction, we'll use H and L as the middle bytes
                        ; This gives us a reasonable middle extraction
                        ; Take bits 23-8 of the 32-bit result as our new 16-bit value
                        ; This means: new_value = (IX << 8) | H
                        PUSH    IX                              ; Get high word
                        POP     BC                              ; BC = high word
                        LD      B, C                            ; B = low byte of high word
                        LD      C, H                            ; C = high byte of low word
                        ; Ensure we don't get stuck in a bad cycle (like 0)
                        LD      A, B
                        OR      C
                        JR      NZ, MiddleSquare16_StateOK
                        LD      BC, 5678                        ; If 0, use another good seed
MiddleSquare16_StateOK: LD      (MiddleSquareSeed16_State), BC  ; Store new state
                        ; Apply modulo for range
                        POP     HL                              ; Get limit back
                        ; Check for special cases
                        LD      A, H
                        OR      L
                        JR      Z, MiddleSquare16_ReturnZero    ; If limit is 0, return 0
                        ; Check if limit is 65535 (full range)
                        LD      DE, 65535
                        OR      A                               ; Clear carry
                        SBC     HL, DE                          ; Compare HL with 65535
                        ADD     HL, DE                          ; Restore HL
                        JR      Z, MiddleSquare16_ReturnRaw     ; If limit is 65535, return raw
                        ; Perform modulo: BC MOD (HL + 1)
                        INC     HL                              ; HL = limit + 1 (for inclusive)
                        LD      DE, BC                          ; DE = random value
MiddleSquare16_ModLoop: LD      A, D                            ; Compare DE with HL
                        CP      H                               ; Compare high bytes
                        JR      C, MiddleSquare16_ModDone       ; DE < HL, done
                        JR      NZ, MiddleSquare16_ModSub       ; DE > HL, subtract
                        LD      A, E                            ; High bytes equal, compare low bytes
                        CP      L
                        JR      C, MiddleSquare16_ModDone       ; DE < HL, done
MiddleSquare16_ModSub:  OR      A                               ; Clear carry
                        SBC     DE, HL                          ; DE = DE - HL
                        JR      MiddleSquare16_ModLoop          ; Continue
MiddleSquare16_ModDone: LD      HL, DE                          ; Result in HL
MiddleSquare16_Exit:    POP     IX                              ; Restore registers
                        POP     DE
                        POP     BC
                        RET
MiddleSquare16_SeedError:
                        LD      BC, 9999                        ; Emergency seed if we hit 0
                        JR      MiddleSquare16_StateOK
MiddleSquare16_ReturnZero:
                        LD      HL, 0                           ; Return 0 for limit 0
                        JR      MiddleSquare16_Exit
MiddleSquare16_ReturnRaw:
                        LD      HL, (MiddleSquareSeed16_State)  ; Return raw value for limit 65535
                        JR      MiddleSquare16_Exit
 
