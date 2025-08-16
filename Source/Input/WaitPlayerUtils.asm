; Ultra-simple keyboard wait routine
; No complex loops - just basic key detection
;
; @COMPAT: 48K,128K,+2,+3,NEXT
WaitForKey:         ; Simple approach: just wait for any key press
WaitLoop:           CALL    ScanAllKeys
                    JR      Z, WaitLoop      ; If no key pressed, keep waiting
KeyPressFound:      ; Simple debounce - small delay
                    LD      B, 100
Delay:              DJNZ    Delay
                    RET
