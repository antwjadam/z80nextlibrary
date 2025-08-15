ScanAllKeys:        ; scans all keys returning NZ set if a key is pressed, else returns Z set
                    LD      B, 0xFE         ; First keyboard row
                    CALL    ScanKeyPort
                    RET     NZ
                    ; Check row 0xFD (A, S, D, F, G)
                    LD      B, 0xFD
                    CALL    ScanKeyPort
                    RET     NZ
                    ; Check row 0xFB (Q, W, E, R, T)
                    LD      B, 0xFB
                    CALL    ScanKeyPort
                    RET     NZ
                    ; Check row 0xF7 (1, 2, 3, 4, 5)
                    LD      B, 0xF7
                    CALL    ScanKeyPort
                    RET     NZ
                    ; Check row 0xEF (0, 9, 8, 7, 6)
                    LD      B, 0xEF
                    CALL    ScanKeyPort
                    RET     NZ
                    ; Check row 0xDF (P, O, I, U, Y)
                    LD      B, 0xDF
                    CALL    ScanKeyPort
                    RET     NZ
                    ; Check row 0xBF (ENTER, L, K, J, H)
                    LD      B, 0xBF
                    CALL    ScanKeyPort
                    RET     NZ
                    ; Check row 0x7F (SPACE, SYM SHIFT, M, N, B)
                    LD      B, 0x7F
                    CALL    ScanKeyPort
                    RET

; scan key port set up in B, SET NZ if a key is pressed on that key port else sets Z
ScanKeyPort:        LD      C, 0xFE         ; Keyboard port
                    IN      A, (C)
                    AND     0x1F
                    CP      0x1F
                    RET                     ; NZ set, key pressed, else Z set no key pressed
