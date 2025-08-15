; Clear the entire screen using direct memory access
ScreenReset:        CALL    ClearScreenPixels   ; Clear pixel memory
                    CALL    SetAllAttributes    ; Set attribute memory
                    CALL    ResetCursorTopLeft  ; Reset cursor position
                    RET

ClearScreenPixels:  ; Clear pixel memory (0x4000-0x57FF)
                    LD      HL, SCREEN_PIXEL_BASE
                    LD      DE, SCREEN_PIXEL_BASE + 1
                    LD      BC, 0x1800      ; 6144 bytes
                    LD      (HL), 0         ; Clear first byte
                    LDIR                    ; Clear rest

SetAllAttributes:   ; Set attribute memory (0x5800-0x5AFF)
                    LD      HL, SCREEN_ATTR_BASE
                    LD      DE, SCREEN_ATTR_BASE + 1
                    LD      BC, 0x02FF      ; 767 bytes
                    LD      A, (CurrentAttr)
                    LD      (HL), A         ; Set first attribute
                    LDIR                    ; Set rest

