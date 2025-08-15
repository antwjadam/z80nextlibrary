; Clear the entire screen using direct memory access
ClearScreen:        ; Clear pixel memory (0x4000-0x57FF)
                    LD      HL, SCREEN_PIXEL_BASE
                    LD      DE, SCREEN_PIXEL_BASE + 1
                    LD      BC, 0x1800      ; 6144 bytes
                    LD      (HL), 0         ; Clear first byte
                    LDIR                    ; Clear rest
                    
                    ; Clear attribute memory (0x5800-0x5AFF)
                    LD      HL, SCREEN_ATTR_BASE
                    LD      DE, SCREEN_ATTR_BASE + 1
                    LD      BC, 0x02FF      ; 767 bytes
                    LD      A, (CurrentAttr)
                    LD      (HL), A         ; Set first attribute
                    LDIR                    ; Set rest
                    
                    ; Reset cursor position
                    LD      A, 0
                    LD      (CursorRow), A
                    LD      (CursorCol), A
                    RET
