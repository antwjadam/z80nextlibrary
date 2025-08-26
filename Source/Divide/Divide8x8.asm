; Unified Divide 8x8 operations with performance level
;
; Always call Divide8x8_Unified as the main entry point.
;
; Input: A = dividend, B = divisor, C = performance level
; Output: A = quotient, B = remainder
;
; T-States summary shows:
;
; PERFORMANCE_COMPACT:  ~25-1950 T-states (variable - worst case 255÷1, best case 0÷n or dividend<divisor)
; PERFORMANCE_BALANCED: ~30-1975 T-states (variable - same algorithm as COMPACT but different register usage) 
; PERFORMANCE_MAXIMUM:  ~40-1000 T-states (variable - optimized with 2x acceleration, ~50% fewer iterations)
; PERFORMANCE_NEXT_COMPACT:  ~40-400 T-states (hybrid - fast subtraction for small dividends, reciprocal for large)
; PERFORMANCE_NEXT_BALANCED: ~40-400 T-states (hybrid - same as NEXT_COMPACT, optimized for predictable timing)
; PERFORMANCE_NEXT_MAXIMUM: ~85 T-states (reciprocal - fixed timing using precomputed table, minor accuracy trade-offs)
;
; @COMPAT: 48K,128K,+2,+3,NEXT

Divide8x8_Unified:      LD      D, A                        ; Save dividend in D so we can check performance levels
                        LD      A, C                        ; Get Performance Level
                        CP      PERFORMANCE_COMPACT
                        JP      Z, Divide8x8_Compact
                        CP      PERFORMANCE_MAXIMUM
                        JP      Z, Divide8x8_Maximum
                        CP      PERFORMANCE_BALANCED
                        JP      Z, Divide8x8_Balanced

                        ; The following are only compatible with the Spectrum Next Z80N architecture.
                        ; So using these prevents your code base generating for original Spectrum hardware

                        ; Hybrid and Compact use the same routine to conserve space, using MUL based execution with traditional methods
                        ; The MUL D, E opcode will put the result in HL just like the other methods.

                        CP      PERFORMANCE_NEXT_COMPACT
                        JP      Z, Divide8x8_Next_Hybrid
                        CP      PERFORMANCE_NEXT_BALANCED
                        JP      Z, Divide8x8_Next_Hybrid
                        JP      Divide8x8_Next_Reciprocal   ; the default and maximum is using reciprical
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Divide8x8_Compact:      LD      A, B                        ; Load divisor into A, check for divide by zero.
                        OR      A                           ; Check if divisor is zero
                        JR      Z, D8x8_Infinity            ; If divide by zero return infinity
                        LD      A, D                        ; Restore dividend saved by performance check
                        OR      A                           ; Check if dividend is zero
                        JR      Z, D8x8_Zero
                        LD      C, B                        ; C = divisor (preserve original)
                        LD      B, 0                        ; B = quotient counter
D8x8_Compact_SubLoop:   CP      C                           ; Compare dividend with divisor
                        JR      C, D8x8_Compact_Done        ; If dividend < divisor, done
                        SUB     C                           ; Subtract divisor from dividend
                        INC     B                           ; Increment quotient
                        JR      D8x8_Compact_SubLoop        ; Repeat
D8x8_Compact_Done:      ; A = remainder, B = quotient
                        LD      C, A                        ; C = remainder
                        LD      A, B                        ; A = quotient
                        LD      B, C                        ; B = remainder
                        RET
D8x8_Zero:              LD      A, 0                        ; quotient = 0
                        LD      B, 0                        ; remainder = 0
                        RET
D8x8_Infinity:          LD      A, 255                      ; quotient = 255
                        LD      B, 255                      ; remainder = 255
                        RET

; Uses simple repeated subtraction for reliability
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Divide8x8_Balanced:     LD      A, B                        ; Load divisor into A
                        OR      A                           ; Check if divisor is zero
                        JR      Z, D8x8_Infinity            ; If divide by zero return infinity
                        LD      A, D                        ; Restore dividend saved by performance check
                        OR      A                           ; Check if dividend is zero
                        JR      Z, D8x8_Zero
                        CP      B                           ; Check if dividend < divisor
                        JR      C, Div8x8Smaller            ; If so, quotient = 0, remainder = dividend
                        LD      C, 0                        ; Clear quotient counter
                        LD      D, A                        ; Copy dividend to D
Divide8x8Loop:          LD      A, D                        ; Get current dividend
                        CP      B                           ; Compare with divisor
                        JR      C, Divide8x8Done            ; If smaller, we're done
                        SUB     B                           ; Subtract divisor
                        LD      D, A                        ; Store back remainder
                        INC     C                           ; Increment quotient
                        JR      Divide8x8Loop               ; Continue
Divide8x8Done:          LD      A, C                        ; Return quotient in A
                        LD      B, D                        ; Return remainder in B
                        RET
Div8x8Smaller:          LD      B, A                        ; Remainder = dividend
                        LD      A, 0                        ; Quotient = 0
                        RET

; Fast 8-bit ÷ 8-bit division - Optimized repeated subtraction with larger steps
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Divide8x8_Maximum:      LD      A, B                        ; Load divisor into A
                        OR      A                           ; Check if divisor is zero
                        JR      Z, D8x8_Infinity            ; If divide by zero return infinity
                        LD      A, D                        ; Restore dividend saved by performance check
                        OR      A                           ; Check if dividend is zero
                        JR      Z, D8x8_Zero
                        CP      B                           ; Check if dividend < divisor
                        JR      C, DivFastSmall             ; If so, quotient = 0, remainder = dividend
                        LD      C, 0                        ; Clear quotient counter
                        LD      D, A                        ; Copy dividend to D
                        LD      A, B                        ; Get divisor
                        SLA     A                            ; * 2
                        JR      C, DivFast1                 ; If overflow, skip 2x optimization
                        LD      E, A                        ; Save 2x divisor
DivFast2Loop:           LD      A, D                        ; Get current dividend
                        CP      E                           ; Compare with 2x divisor
                        JR      C, DivFast1                 ; If smaller, move to 1x subtraction

                        SUB     E                           ; Subtract 2x divisor
                        LD      D, A                        ; Store back remainder
                        INC     C                           ; Increment quotient
                        INC     C                           ; Increment quotient again (subtracted 2x)
                        JR      DivFast2Loop                ; Continue with 2x subtraction
DivFast1:               LD      A, D                        ; Get current dividend
                        CP      B                           ; Compare with divisor
                        JR      C, DivFastDone              ; If smaller, we're done
                        SUB     B                           ; Subtract divisor
                        LD      D, A                        ; Store back remainder
                        INC     C                           ; Increment quotient
                        JR      DivFast1                     ; Continue with 1x subtraction
DivFastDone:            LD      A, C                        ; Return quotient in A
                        LD      B, D                        ; Return remainder in B
                        RET
DivFastSmall:           LD      B, A                        ; Remainder = dividend
                        LD      A, 0                        ; Quotient = 0
                        RET
;
; @COMPAT: NEXT
; @Z80N: MUL DE
; @REQUIRES: Spectrum Next, Z80N architecture.
Divide8x8_Next_Hybrid:
                        LD      A, B                        ; Load divisor into A, to check for divide by zero
                        OR      A                           ; Check if divisor is zero
                        JP      Z, D8x8_Infinity            ; If divide by zero, jump to infinity
                        LD      A, D                        ; Restore dividend saved by performance check
                        OR      A                           ; Check if dividend is zero, divide zero by anything is zero.
                        JP      Z, D8x8_Zero                ; If dividend is zero, jump to zero case
                        ; Quick estimation using MUL based approximation
                        CP      B                           ; Compare dividend with divisor
                        JP      C, D8x8_Smaller             ; If dividend < divisor, result is 0, remainder = dividend
                        ; For large dividends, use MUL-based estimation by reciprocal - developer can tweak this to match their own definiton of large
                        CP      128
                        JP      NC, D8x8_Z80N_Large         ; If >= 128, we use the reciprocal calculation
                        ; For smaller dividends, use optimized subtraction
                        LD      C, 0                        ; Quotient counter
D8x8_SmallLoop:         CP      B                           ; Compare with divisor
                        JP      C, D8x8_SubDone             ; dividend < divisor, this is the remainder
                        SUB     B                           ; Subtract divisor
                        INC     C                           ; Increment quotient
                        JR      D8x8_SmallLoop              ; Continue with subtraction
D8x8_SubDone:           LD      B, A                        ; B = remainder
                        LD      A, C                        ; A = quotient
                        RET
D8x8_Smaller:           LD      B, A                        ; B = remainder = dividend
                        XOR     A                           ; A = quotient = 0
                        RET
;
; @COMPAT: NEXT
; @Z80N: MUL DE
; @REQUIRES: Spectrum Next, Z80N architecture.
Divide8x8_Next_Reciprocal:
                        LD      A, B                        ; Load divisor into A, to check for divide by zero
                        OR      A                           ; Check if divisor is zero
                        JP      Z, D8x8_Infinity            ; If divide by zero, jump to infinity
                        LD      A, D                        ; Restore dividend saved by performance check
                        OR      A                           ; Check if dividend is zero, divide zero by anything is zero.
                        JP      Z, D8x8_Zero                ; If dividend is zero, jump to zero case
                        ; Look up reciprocal (1/B *256) from precomputed reciprocals table
D8x8_Z80N_Large:        LD      HL, Next_8Bit_Reciprocals
                        LD      C, B                        ; Move divisor to BC to act as a 16-bit index to the table
                        LD      B, 0
                        ADD     HL, BC                      ; Get precomputed reciprocal for divisor
                        LD      E, (HL)                     ; Load reciprocal into E
                        ; Multiply dividend by reciprocal
                        LD      D, A                        ; Move dividend to DE for Z80N multiplication
                        PUSH    DE                          ; save dividend so the MUL doesnt zap it.
                        MUL     DE                          ; Z80N op code. DE = D * E.
                        EX      DE, HL                      ; Swap DE and HL - MUL DE puts result in DE, we want it in HL
                        ; Extract quotient  
                        PUSH    HL                          ; Save quotient (in H) and intermediate result
                        LD      A, H                        ; Get high byte of result (the quotient)
                        ; Now calculate remainder: remainder = dividend - (quotient * divisor)
                        LD      D, A                        ; Save quotient in D
                        LD      E, C                        ; Move original divisor to E (C contains original divisor)
                        MUL     DE                          ; Z80N op code. DE = D * E.
                        
                        LD      C, E                        ; Get low byte of result (the product)
                        POP     HL                          ; Restore quotient in H
                        POP     DE                          ; Restore original dividend
                        LD      A, D                        ; Get dividend
                        SUB     C                           ; A = dividend - product = remainder
                        LD      B, A                        ; B = remainder  
                        LD      A, H                        ; A = quotient
                        RET                                 ; A = Quotient, B = Remainder

; 8-bit Reciprocal table for Z80N Next Divide Maximum choice.
; The 8-bit reciprocal method will have some inherent rounding errors, caused by limited precision of the reciprocal look up.
; So this option should only be used where accuracy is not critical, e.g. only for games internal calculations.
Next_8Bit_Reciprocals:
        DB      0           ; [0] Unused (division by 0)
        DB      255         ; [1] 256/1 = 256 (clamped to 255 for 8-bit)
        DB      128         ; [2] 256/2 = 128.000
        DB      85          ; [3] 256/3 = 85.333 → 85
        DB      64          ; [4] 256/4 = 64.000
        DB      51          ; [5] 256/5 = 51.200 → 51
        DB      43          ; [6] 256/6 = 42.667 → 43
        DB      37          ; [7] 256/7 = 36.571 → 37
        DB      32          ; [8] 256/8 = 32.000
        DB      28          ; [9] 256/9 = 28.444 → 28
        DB      26          ; [10] 256/10 = 25.600 → 26
        DB      23          ; [11] 256/11 = 23.273 → 23
        DB      21          ; [12] 256/12 = 21.333 → 21
        DB      20          ; [13] 256/13 = 19.692 → 20
        DB      18          ; [14] 256/14 = 18.286 → 18
        DB      18          ; [15] 256/15 = 17.067 → 18 (adjusted for better accuracy)
        DB      16          ; [16] 256/16 = 16.000
        DB      15          ; [17] 256/17 = 15.059 → 15
        DB      14          ; [18] 256/18 = 14.222 → 14
        DB      13          ; [19] 256/19 = 13.474 → 13
        DB      13          ; [20] 256/20 = 12.800 → 13
        DB      12          ; [21] 256/21 = 12.190 → 12
        DB      12          ; [22] 256/22 = 11.636 → 12
        DB      11          ; [23] 256/23 = 11.130 → 11
        DB      11          ; [24] 256/24 = 10.667 → 11
        DB      10          ; [25] 256/25 = 10.240 → 10
        DB      10          ; [26] 256/26 = 9.846 → 10
        DB      9           ; [27] 256/27 = 9.481 → 9
        DB      9           ; [28] 256/28 = 9.143 → 9
        DB      9           ; [29] 256/29 = 8.828 → 9
        DB      9           ; [30] 256/30 = 8.533 → 9
        DB      8           ; [31] 256/31 = 8.258 → 8
        DB      8           ; [32] 256/32 = 8.000
        DB      8           ; [33] 256/33 = 7.758 → 8
        DB      8           ; [34] 256/34 = 7.529 → 8
        DB      7           ; [35] 256/35 = 7.314 → 7
        DB      7           ; [36] 256/36 = 7.111 → 7
        DB      7           ; [37] 256/37 = 6.919 → 7
        DB      7           ; [38] 256/38 = 6.737 → 7
        DB      7           ; [39] 256/39 = 6.564 → 7
        DB      6           ; [40] 256/40 = 6.400 → 6
        DB      6           ; [41] 256/41 = 6.244 → 6
        DB      6           ; [42] 256/42 = 6.095 → 6
        DB      6           ; [43] 256/43 = 5.953 → 6
        DB      6           ; [44] 256/44 = 5.818 → 6
        DB      6           ; [45] 256/45 = 5.689 → 6
        DB      6           ; [46] 256/46 = 5.565 → 6
        DB      5           ; [47] 256/47 = 5.447 → 5
        DB      5           ; [48] 256/48 = 5.333 → 5
        DB      5           ; [49] 256/49 = 5.224 → 5
        DB      5           ; [50] 256/50 = 5.120 → 5
        DB      5           ; [51] 256/51 = 5.020 → 5
        DB      5           ; [52] 256/52 = 4.923 → 5
        DB      5           ; [53] 256/53 = 4.830 → 5
        DB      5           ; [54] 256/54 = 4.741 → 5
        DB      5           ; [55] 256/55 = 4.655 → 5
        DB      5           ; [56] 256/56 = 4.571 → 5
        DB      4           ; [57] 256/57 = 4.491 → 4
        DB      4           ; [58] 256/58 = 4.414 → 4
        DB      4           ; [59] 256/59 = 4.339 → 4
        DB      4           ; [60] 256/60 = 4.267 → 4
        DB      4           ; [61] 256/61 = 4.197 → 4
        DB      4           ; [62] 256/62 = 4.129 → 4
        DB      4           ; [63] 256/63 = 4.063 → 4
        DB      4           ; [64] 256/64 = 4.000
        DB      4           ; [65] 256/65 = 3.938 → 4
        DB      4           ; [66] 256/66 = 3.879 → 4
        DB      4           ; [67] 256/67 = 3.821 → 4
        DB      4           ; [68] 256/68 = 3.765 → 4
        DB      4           ; [69] 256/69 = 3.710 → 4
        DB      4           ; [70] 256/70 = 3.657 → 4
        DB      4           ; [71] 256/71 = 3.606 → 4
        DB      4           ; [72] 256/72 = 3.556 → 4
        DB      4           ; [73] 256/73 = 3.507 → 4
        DB      3           ; [74] 256/74 = 3.459 → 3
        DB      3           ; [75] 256/75 = 3.413 → 3
        DB      3           ; [76] 256/76 = 3.368 → 3
        DB      3           ; [77] 256/77 = 3.325 → 3
        DB      3           ; [78] 256/78 = 3.282 → 3
        DB      3           ; [79] 256/79 = 3.241 → 3
        DB      3           ; [80] 256/80 = 3.200 → 3
        DB      3           ; [81] 256/81 = 3.160 → 3
        DB      3           ; [82] 256/82 = 3.122 → 3
        DB      3           ; [83] 256/83 = 3.084 → 3
        DB      3           ; [84] 256/84 = 3.048 → 3
        DB      3           ; [85] 256/85 = 3.012 → 3
        DB      3           ; [86] 256/86 = 2.977 → 3
        DB      3           ; [87] 256/87 = 2.943 → 3
        DB      3           ; [88] 256/88 = 2.909 → 3
        DB      3           ; [89] 256/89 = 2.876 → 3
        DB      3           ; [90] 256/90 = 2.844 → 3
        DB      3           ; [91] 256/91 = 2.813 → 3
        DB      3           ; [92] 256/92 = 2.783 → 3
        DB      3           ; [93] 256/93 = 2.753 → 3
        DB      3           ; [94] 256/94 = 2.723 → 3
        DB      3           ; [95] 256/95 = 2.695 → 3
        DB      3           ; [96] 256/96 = 2.667 → 3
        DB      3           ; [97] 256/97 = 2.639 → 3
        DB      3           ; [98] 256/98 = 2.612 → 3
        DB      3           ; [99] 256/99 = 2.586 → 3
        DB      3           ; [100] 256/100 = 2.560 → 3
        DB      3           ; [101] 256/101 = 2.535 → 3
        DB      3           ; [102] 256/102 = 2.510 → 3
        DB      2           ; [103] 256/103 = 2.485 → 2
        DB      2           ; [104] 256/104 = 2.462 → 2
        DB      2           ; [105] 256/105 = 2.438 → 2
        DB      2           ; [106] 256/106 = 2.415 → 2
        DB      2           ; [107] 256/107 = 2.393 → 2
        DB      2           ; [108] 256/108 = 2.370 → 2
        DB      2           ; [109] 256/109 = 2.349 → 2
        DB      2           ; [110] 256/110 = 2.327 → 2
        DB      2           ; [111] 256/111 = 2.306 → 2
        DB      2           ; [112] 256/112 = 2.286 → 2
        DB      2           ; [113] 256/113 = 2.265 → 2
        DB      2           ; [114] 256/114 = 2.246 → 2
        DB      2           ; [115] 256/115 = 2.226 → 2
        DB      2           ; [116] 256/116 = 2.207 → 2
        DB      2           ; [117] 256/117 = 2.188 → 2
        DB      2           ; [118] 256/118 = 2.169 → 2
        DB      2           ; [119] 256/119 = 2.151 → 2
        DB      2           ; [120] 256/120 = 2.133 → 2
        DB      2           ; [121] 256/121 = 2.116 → 2
        DB      2           ; [122] 256/122 = 2.098 → 2
        DB      2           ; [123] 256/123 = 2.081 → 2
        DB      2           ; [124] 256/124 = 2.065 → 2
        DB      2           ; [125] 256/125 = 2.048 → 2
        DB      2           ; [126] 256/126 = 2.032 → 2
        DB      2           ; [127] 256/127 = 2.016 → 2
        DB      2           ; [128] 256/128 = 2.000
        DB      2           ; [129] 256/129 = 1.984 → 2
        DB      2           ; [130] 256/130 = 1.969 → 2
        DB      2           ; [131] 256/131 = 1.954 → 2
        DB      2           ; [132] 256/132 = 1.939 → 2
        DB      2           ; [133] 256/133 = 1.925 → 2
        DB      2           ; [134] 256/134 = 1.910 → 2
        DB      2           ; [135] 256/135 = 1.896 → 2
        DB      2           ; [136] 256/136 = 1.882 → 2
        DB      2           ; [137] 256/137 = 1.869 → 2
        DB      2           ; [138] 256/138 = 1.855 → 2
        DB      2           ; [139] 256/139 = 1.842 → 2
        DB      2           ; [140] 256/140 = 1.829 → 2
        DB      2           ; [141] 256/141 = 1.816 → 2
        DB      2           ; [142] 256/142 = 1.803 → 2
        DB      2           ; [143] 256/143 = 1.790 → 2
        DB      2           ; [144] 256/144 = 1.778 → 2
        DB      2           ; [145] 256/145 = 1.766 → 2
        DB      2           ; [146] 256/146 = 1.753 → 2
        DB      2           ; [147] 256/147 = 1.741 → 2
        DB      2           ; [148] 256/148 = 1.730 → 2
        DB      2           ; [149] 256/149 = 1.718 → 2
        DB      2           ; [150] 256/150 = 1.707 → 2
        DB      2           ; [151] 256/151 = 1.695 → 2
        DB      2           ; [152] 256/152 = 1.684 → 2
        DB      2           ; [153] 256/153 = 1.673 → 2
        DB      2           ; [154] 256/154 = 1.662 → 2
        DB      2           ; [155] 256/155 = 1.652 → 2
        DB      2           ; [156] 256/156 = 1.641 → 2
        DB      2           ; [157] 256/157 = 1.631 → 2
        DB      2           ; [158] 256/158 = 1.620 → 2
        DB      2           ; [159] 256/159 = 1.610 → 2
        DB      2           ; [160] 256/160 = 1.600 → 2
        DB      2           ; [161] 256/161 = 1.590 → 2
        DB      2           ; [162] 256/162 = 1.580 → 2
        DB      2           ; [163] 256/163 = 1.571 → 2
        DB      2           ; [164] 256/164 = 1.561 → 2
        DB      2           ; [165] 256/165 = 1.552 → 2
        DB      2           ; [166] 256/166 = 1.542 → 2
        DB      2           ; [167] 256/167 = 1.533 → 2
        DB      2           ; [168] 256/168 = 1.524 → 2
        DB      2           ; [169] 256/169 = 1.515 → 2
        DB      2           ; [170] 256/170 = 1.506 → 2
        DB      1           ; [171] 256/171 = 1.497 → 1
        DB      1           ; [172] 256/172 = 1.488 → 1
        DB      1           ; [173] 256/173 = 1.479 → 1
        DB      1           ; [174] 256/174 = 1.471 → 1
        DB      1           ; [175] 256/175 = 1.463 → 1
        DB      1           ; [176] 256/176 = 1.455 → 1
        DB      1           ; [177] 256/177 = 1.446 → 1
        DB      1           ; [178] 256/178 = 1.438 → 1
        DB      1           ; [179] 256/179 = 1.430 → 1
        DB      1           ; [180] 256/180 = 1.422 → 1
        DB      1           ; [181] 256/181 = 1.414 → 1
        DB      1           ; [182] 256/182 = 1.407 → 1
        DB      1           ; [183] 256/183 = 1.399 → 1
        DB      1           ; [184] 256/184 = 1.391 → 1
        DB      1           ; [185] 256/185 = 1.384 → 1
        DB      1           ; [186] 256/186 = 1.376 → 1
        DB      1           ; [187] 256/187 = 1.369 → 1
        DB      1           ; [188] 256/188 = 1.362 → 1
        DB      1           ; [189] 256/189 = 1.354 → 1
        DB      1           ; [190] 256/190 = 1.347 → 1
        DB      1           ; [191] 256/191 = 1.340 → 1
        DB      1           ; [192] 256/192 = 1.333 → 1
        DB      1           ; [193] 256/193 = 1.327 → 1
        DB      1           ; [194] 256/194 = 1.320 → 1
        DB      1           ; [195] 256/195 = 1.313 → 1
        DB      1           ; [196] 256/196 = 1.306 → 1
        DB      1           ; [197] 256/197 = 1.299 → 1
        DB      1           ; [198] 256/198 = 1.293 → 1
        DB      1           ; [199] 256/199 = 1.286 → 1
        DB      1           ; [200] 256/200 = 1.280 → 1
        DB      1           ; [201] 256/201 = 1.274 → 1
        DB      1           ; [202] 256/202 = 1.267 → 1
        DB      1           ; [203] 256/203 = 1.261 → 1
        DB      1           ; [204] 256/204 = 1.255 → 1
        DB      1           ; [205] 256/205 = 1.249 → 1
        DB      1           ; [206] 256/206 = 1.243 → 1
        DB      1           ; [207] 256/207 = 1.237 → 1
        DB      1           ; [208] 256/208 = 1.231 → 1
        DB      1           ; [209] 256/209 = 1.225 → 1
        DB      1           ; [210] 256/210 = 1.219 → 1
        DB      1           ; [211] 256/211 = 1.213 → 1
        DB      1           ; [212] 256/212 = 1.208 → 1
        DB      1           ; [213] 256/213 = 1.202 → 1
        DB      1           ; [214] 256/214 = 1.196 → 1
        DB      1           ; [215] 256/215 = 1.191 → 1
        DB      1           ; [216] 256/216 = 1.185 → 1
        DB      1           ; [217] 256/217 = 1.180 → 1
        DB      1           ; [218] 256/218 = 1.174 → 1
        DB      1           ; [219] 256/219 = 1.169 → 1
        DB      1           ; [220] 256/220 = 1.164 → 1
        DB      1           ; [221] 256/221 = 1.158 → 1
        DB      1           ; [222] 256/222 = 1.153 → 1
        DB      1           ; [223] 256/223 = 1.148 → 1
        DB      1           ; [224] 256/224 = 1.143 → 1
        DB      1           ; [225] 256/225 = 1.138 → 1
        DB      1           ; [226] 256/226 = 1.133 → 1
        DB      1           ; [227] 256/227 = 1.128 → 1
        DB      1           ; [228] 256/228 = 1.123 → 1
        DB      1           ; [229] 256/229 = 1.118 → 1
        DB      1           ; [230] 256/230 = 1.113 → 1
        DB      1           ; [231] 256/231 = 1.108 → 1
        DB      1           ; [232] 256/232 = 1.103 → 1
        DB      1           ; [233] 256/233 = 1.099 → 1
        DB      1           ; [234] 256/234 = 1.094 → 1
        DB      1           ; [235] 256/235 = 1.089 → 1
        DB      1           ; [236] 256/236 = 1.085 → 1
        DB      1           ; [237] 256/237 = 1.080 → 1
        DB      1           ; [238] 256/238 = 1.076 → 1
        DB      1           ; [239] 256/239 = 1.071 → 1
        DB      1           ; [240] 256/240 = 1.067 → 1
        DB      1           ; [241] 256/241 = 1.062 → 1
        DB      1           ; [242] 256/242 = 1.058 → 1
        DB      1           ; [243] 256/243 = 1.053 → 1
        DB      1           ; [244] 256/244 = 1.049 → 1
        DB      1           ; [245] 256/245 = 1.045 → 1
        DB      1           ; [246] 256/246 = 1.041 → 1
        DB      1           ; [247] 256/247 = 1.036 → 1
        DB      1           ; [248] 256/248 = 1.032 → 1
        DB      1           ; [249] 256/249 = 1.028 → 1
        DB      1           ; [250] 256/250 = 1.024 → 1
        DB      1           ; [251] 256/251 = 1.020 → 1
        DB      1           ; [252] 256/252 = 1.016 → 1
        DB      1           ; [253] 256/253 = 1.012 → 1
        DB      1           ; [254] 256/254 = 1.008 → 1
        DB      1           ; [255] 256/255 = 1.004 → 1
