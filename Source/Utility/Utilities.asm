; Retro programming utilities to check environments
;
; Z80N Detection - allows you to check if you are running on a Z80N architecture, i.e. a Spectrum Next.
;
; Output: Z flag is set if not running on Z80N, NZ if running on Z80N
;
; T-States summary shows:
; Z80N Not Found: 60 T-states
; Z80N found: 81 T-states
;
; @COMPAT: 48K,128K,+2,+3,NEXT
CheckOnZ80N:            ; Test for Z80N architecture by attempting a MUL DE instruction
                        LD      D, 2
                        LD      E, 3
                        MUL     DE          ; Z80N will put 6 in DE, Z80 will treat as two NOPs leaving DE unchanged.
                        LD      A, D
                        OR      A           ; Set Z flag if D is 0 (Z80N), else NZ if D is 2 (Z80)
                        JP      NZ, FoundZ80
                        LD      A, E
                        CP      6
                        JP      Z, FoundZ80N
FoundZ80:               XOR     A           ; Set A to zero for Z80N not found flag setting.
                        OR      A           ; Set Flag Z to indicate not Z80N
                        RET
FoundZ80N:              LD      A, 1        ; Set A to 1 (boolean true if you like :P)
                        OR      A           ; Set Flag NZ to indicate Z80N found
                        RET
