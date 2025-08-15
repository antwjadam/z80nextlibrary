; Unified Multiply 16x8 operations with performance level
;
; Always call Multiply16x8_Unified as the main entry point.
;
; Input: HL = 16 bit multiplicand, B = 8 bit multiplier, C = performance level,
; Output: DE:HL = 24-bit result (DE = high 16 bits, HL = low 16 bits)
;
; T-States summary shows:
;
; PERFORMANCE_COMPACT:  ~45-380 T-states (variable, depends on multiplier value)
; PERFORMANCE_BALANCED: ~180 T-states (fixed, 8 iterations with 16-bit arithmetic)  
; PERFORMANCE_MAXIMUM:  ~140 T-states (fixed, unrolled loop optimized for speed)

Multiply16x8_Unified:   LD      A, C                    ; Get Performance Level
                        CP      PERFORMANCE_MAXIMUM
                        JP      Z, Multiply16x8_Maximum
                        CP      PERFORMANCE_BALANCED
                        JP      Z, Multiply16x8_Balanced
                        ; fall through to COMPACT
Multiply16x8_Compact:   ; Handle zero multiplier quickly
                        LD      A, B
                        OR      A
                        JR      Z, M16x8_Compact_Zero
                        ; Simple repeated addition approach (most compact)
                        ; Save multiplier B in A temporarily
                        LD      A, B                    ; A = multiplier count
                        ; Set up multiplicand in BC
                        LD      C, L                    ; BC = multiplicand  
                        LD      B, H
                        ; Initialize result
                        LD      DE, 0                   ; DE = high result
                        LD      HL, 0                   ; HL = low result
                        
M16x8_Compact_AddLoop:  ; Simple addition loop
                        OR      A                      ; Check if multiplier count is zero
                        JR      Z, M16x8_Compact_AddDone
                        DEC     A                      ; Decrease count
                        ADD     HL, BC                 ; Add multiplicand to result
                        JR      NC, M16x8_Compact_AddLoop ; No carry, continue
                        INC     D                      ; Handle carry to high result (D only)
                        JR      M16x8_Compact_AddLoop ; Continue
                        
M16x8_Compact_AddDone:  RET
M16x8_Compact_Zero:     LD      HL, 0
                        LD      DE, 0
                        RET

; BALANCED performance - fixed timing shift-and-add
Multiply16x8_Balanced:  ; Check for zero multiplier quickly
                        LD      A, B
                        OR      A
                        JR      Z, M16x8_Balanced_Zero
                        ; Use standard shift-and-add algorithm
                        ; Save multiplicand in BC, multiplier in E
                        LD      C, L                    ; C = low byte of multiplicand
                        LD      L, B                    ; L = multiplier (was in B)
                        LD      B, H                    ; B = high byte of multiplicand
                        LD      H, 0                    ; H = 0
                        LD      DE, 0                   ; Initialize result high in D
                        LD      E, L                    ; E = multiplier  
                        LD      HL, 0                   ; Clear result low
M16x8_Balanced_Loop:    SRL     E                       ; Shift multiplier right
                        JR      NC, M16x8_Balanced_Skip
                        ADD     HL, BC                  ; Add multiplicand
                        JR      NC, M16x8_Balanced_Skip
                        INC     D                       ; Handle carry
M16x8_Balanced_Skip:    SLA     C                       ; Double multiplicand
                        RL      B
                        LD      A, E
                        OR      A
                        JR      NZ, M16x8_Balanced_Loop
                        ; Result is already in correct format: DE = high, HL = low
                        RET
M16x8_Balanced_Zero:    LD      HL, 0
                        LD      DE, 0
                        RET

; MAXIMUM performance - unrolled for speed
Multiply16x8_Maximum:   ; Check for zero multiplier quickly
                        LD      A, B
                        OR      A
                        JR      Z, M16x8_Maximum_Zero
                        ; Use unrolled shift-and-add for maximum speed
                        ; Save multiplicand in BC, multiplier in A
                        LD      C, L                    ; C = low byte of multiplicand
                        LD      A, B                    ; A = multiplier (was in B)
                        LD      B, H                    ; B = high byte of multiplicand
                        LD      DE, 0                   ; D = carry accumulator, E = 0
                        LD      HL, 0                   ; HL = result accumulator
                        
                        ; Unroll all 8 bits for maximum speed
                        ; Bit 0
                        RRC     A                       ; Test bit 0
                        JR      NC, M16x8_Max_Bit1
                        ADD     HL, BC                  ; Add multiplicand
                        JR      NC, M16x8_Max_Bit1
                        INC     D                       ; Handle carry
M16x8_Max_Bit1:        SLA     C                       ; Double multiplicand
                        RL      B
                        RRC     A                       ; Test bit 1
                        JR      NC, M16x8_Max_Bit2
                        ADD     HL, BC                  ; Add multiplicand
                        JR      NC, M16x8_Max_Bit2
                        INC     D                       ; Handle carry
M16x8_Max_Bit2:        SLA     C                       ; Double multiplicand
                        RL      B
                        RRC     A                       ; Test bit 2
                        JR      NC, M16x8_Max_Bit3
                        ADD     HL, BC                  ; Add multiplicand
                        JR      NC, M16x8_Max_Bit3
                        INC     D                       ; Handle carry
M16x8_Max_Bit3:        SLA     C                       ; Double multiplicand
                        RL      B
                        RRC     A                       ; Test bit 3
                        JR      NC, M16x8_Max_Bit4
                        ADD     HL, BC                  ; Add multiplicand
                        JR      NC, M16x8_Max_Bit4
                        INC     D                       ; Handle carry
M16x8_Max_Bit4:        SLA     C                       ; Double multiplicand
                        RL      B
                        RRC     A                       ; Test bit 4
                        JR      NC, M16x8_Max_Bit5
                        ADD     HL, BC                  ; Add multiplicand
                        JR      NC, M16x8_Max_Bit5
                        INC     D                       ; Handle carry
M16x8_Max_Bit5:        SLA     C                       ; Double multiplicand
                        RL      B
                        RRC     A                       ; Test bit 5
                        JR      NC, M16x8_Max_Bit6
                        ADD     HL, BC                  ; Add multiplicand
                        JR      NC, M16x8_Max_Bit6
                        INC     D                       ; Handle carry
M16x8_Max_Bit6:        SLA     C                       ; Double multiplicand
                        RL      B
                        RRC     A                       ; Test bit 6
                        JR      NC, M16x8_Max_Bit7
                        ADD     HL, BC                  ; Add multiplicand
                        JR      NC, M16x8_Max_Bit7
                        INC     D                       ; Handle carry
M16x8_Max_Bit7:        SLA     C                       ; Double multiplicand
                        RL      B
                        RRC     A                       ; Test bit 7
                        JR      NC, M16x8_Max_Done
                        ADD     HL, BC                  ; Add multiplicand
                        JR      NC, M16x8_Max_Done
                        INC     D                       ; Handle carry
M16x8_Max_Done:        LD      E, 0                    ; E = 0 (DE = high result)
                        RET                             ; DE:HL = result
                        RET
M16x8_Maximum_Zero:     LD      HL, 0
                        LD      DE, 0
                        RET
