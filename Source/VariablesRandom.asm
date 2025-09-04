; Random Generator Store - default values set in case you forget to seed at least once.
RandomSeed8_CurrentSeed:    DB      1               ; Current seed value (initialized to 1)
LfsrSeed8_State:            DB      1               ; LFSR state (never 0)
MiddleSquareSeed8_State:    DB      1               ; Middle Square state
XorShiftSeed8_State:        DB      1               ; XORShift state (never 0)

RandomSeed16_CurrentSeed:   DW      1234            ; Current seed value (initialized to 1234)
LfsrSeed16_State:           DW      1234            ; LFSR state (never 0)
MiddleSquareSeed16_State:   DW      1234            ; Middle Square state
XorShiftSeed16_State:       DW      1234            ; XORShift state (never 0)
