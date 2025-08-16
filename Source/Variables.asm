; Simple stack setup
StackSpace:                 DS      256             ; 256 bytes for stack, add more space if a bigger stack area is needed
StackTop:                   DS      2               ; Storage for stack top pointer
OriginalStack:              DS      2               ; Storage for original stack pointer
ScreenStackPointer:         DS      2               ; Storage for screen clear/copy routines stack pointer saving

; Current cursor position (global text variables)
CursorRow:                  DB      0               ; Current row (0-23)
CursorCol:                  DB      0               ; Current column (0-31)
CurrentAttr:                DB      0x07            ; Current attribute (white on black)

; Random Generator Store - default values set in case you forget to seed at least once.
RandomSeed8_CurrentSeed:    DB      1               ; Current seed value (initialized to 1)
LfsrSeed8_State:            DB      1               ; LFSR state (never 0)
MiddleSquareSeed8_State:    DB      1               ; Middle Square state
XorShiftSeed8_State:        DB      1               ; XORShift state (never 0)

RandomSeed16_CurrentSeed:   DW      1234            ; Current seed value (initialized to 1234)
LfsrSeed16_State:           DW      1234            ; LFSR state (never 0)
MiddleSquareSeed16_State:   DW      1234            ; Middle Square state
XorShiftSeed16_State:       DW      1234            ; XORShift state (never 0)
