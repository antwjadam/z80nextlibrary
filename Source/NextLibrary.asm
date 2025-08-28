                OPT     --zxnext    
                DEVICE  ZXSPECTRUMNEXT
                ORG     0x8000

                INCLUDE "Constants.asm"                    ; Include the Constants definitions

StartAddress:   ; Main program entry point
                LD      (OriginalStack), SP                ; Save original stack pointer first
                LD      SP, StackTop                       ; Set up our stack pointer
                
                ; Initialize display system
                CALL    InitDisplay

                LD      A, 0x07                            ; Set default attribute (white on black)
                LD      C, SCREEN_COMPACT                  ; Set performance level to compact (this demo's LDIR, for higher performing screen clearing see ScreenClearing.asm)
                CALL    Screen_FullReset_Unified
                
                ; Run the test pack
                CALL    RunTests

                ; wait for any key before exiting the program
                CALL    WaitForKey
                
                LD      SP, (OriginalStack)                ; Restore original stack pointer
                RET


TestPack:       INCLUDE "Testing/TestPackFramework.asm"    ; Include the Test Pack Framework entry points
                INCLUDE "Testing/TestPackTests.asm"        ; Include the Test Pack Tests Executor
                INCLUDE "Testing/TestCases.asm"            ; Include all test cases

                INCLUDE "Variables.asm"                    ; Include the Variables definitions

RandomHelpers:  INCLUDE "Random/Random8bit.asm"            ; Include 8-bit Random Number Generator - Unified
                INCLUDE "Random/Random16bit.asm"           ; Include 16-bit Random Number Generator - Unified

MathsHelpers:   INCLUDE "Divide/Divide8x8.asm"             ; Include Unified Divide 8-bit routines
                INCLUDE "Divide/Divide16x8.asm"            ; Include Unified Divide 16x8 routines
                INCLUDE "Multiply/Multiply8x8.asm"         ; Include Unified Multiply 8-bit routines
                INCLUDE "Multiply/Multiply16x8.asm"        ; Include Unified Multiply 16-bit routines

DisplayUtils:   INCLUDE "Display/ScreenClearing.asm"       ; Include the Screen Clearing routines
                INCLUDE "Display/TextUtils.asm"            ; Include the Text Utils routines
                INCLUDE "Display/EmbeddedFont.asm"         ; Include the Embedded Font

KeysHelpers:    INCLUDE "Input/InputScanUtils.asm"         ; Include the Input scanning routines
                INCLUDE "Input/WaitPlayerUtils.asm"        ; Include the Wait Player Interaction routines

ScoreHelpers:   INCLUDE "Scoring/ScoresConvert.asm"        ; Include the 16bit score to display string routines

SaveNexFileOutput:
                SAVENEX OPEN "Output/nextlibrary.nex", StartAddress
                SAVENEX CORE 3, 0, 0                       ; Next core 3.0.0 required as minimum
                SAVENEX CFG  0
                SAVENEX AUTO
                SAVENEX CLOSE
