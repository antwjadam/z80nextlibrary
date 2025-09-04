; Spectrum Next native display routines to aid in the development of Layer 2 graphics.
;
; Layer 2 Detection - allows you to check if Layer 2 is available and Active.
;
; Output: Z flag is set if no layer 2 not available and enabled, NZ layer 2 available and active.
;
; T-States summary shows:
; Next Not Found: 109 T-states
; Active Layer 2 Not Found: 151 T-states
; Active Layer 2 Found: 157 T-states
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next in Normal Next mode with access to Layer 2 display choices (i.e. not in ZX Spectrum compatibility modes.)
CheckForActiveLayer2:   ; check if we are on Next via the Z80N detect, if that fails, we cant have an active layer 2.
                        CALL    CheckOnZ80N
                        JP      Z, NotFoundLayer2
                        LD      BC, LAYER2_REGISTER_SELECT_PORT
                        LD      A, LAYER2_CONTROL_REGISTER
                        OUT     (C), A              ; Select Layer 2 control register
                        LD      BC, LAYER2_REGISTER_DATA_PORT
                        IN      A, (C)              ; Read Layer 2 control register
                        BIT     7, A                ; Check if Layer 2 is enabled (bit 7 set)
                        JP      NZ, FoundLayer2     ; Layer 2 is found and active!
NotFoundLayer2:         XOR     A                   ; Set A to zero (boolean false if you like)
                        OR      A                   ; Set Flag Z to indicate no active Layer 2 found
                        RET
FoundLayer2:            LD      A, 1                ; Set A to 1 (boolean true if you like :P)
                        OR      A                   ; Set Flag NZ to indicate an active Layer 2 was found
                        RET

;
; Get current active Layer 2 address
;
; Use for example for double buffering to identify the current layer 2 address.
;
; Output: HL = Layer 2 base address, HL = 0 if no layer 2 screen is active.
;
; T-States summary shows:
; HL return as zero, no active layer 2: 87 T-states
; HL returns active Layer 2 address: 83 T-states
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next in Normal Next mode with access to Layer 2 display choices (i.e. not in ZX Spectrum compatibility modes.)
GetActiveLayer2Addr:    ; Check if we have an active Layer 2
                        CALL    CheckForActiveLayer2
                        JP      Z, NoActiveLayer2
                        ; Read Layer 2 mapping from Next registers
                        LD      BC, LAYER2_REGISTER_SELECT_PORT
                        LD      A, LAYER2_ADDRESS_REGISTER
                        OUT     (C), A                     ; Select Layer 2 address register
                        LD      BC, LAYER2_REGISTER_DATA_PORT
                        IN      A, (C)                     ; Read Layer 2 register value
                        OR      A                          ; Check if Layer 2 is active (non-zero)
                        JR      Z, NoActiveLayer2
                        LD      H, A                       ; Convert to full address
                        LD      L, 0                       ; Layer 2 must be aligned on 256 byte boundaries
                        JP      StoreLayer2Address
NoActiveLayer2:         LD      HL, 0                      ; No active Layer 2
StoreLayer2Address:     LD      (Layer2ScreenAddress), HL  ; Store Layer 2 address
                        RET

;
; Get full Layer 2 information including resolution, dimensions, and color depth
;
; Reads Layer 2 control register and populates global variables with current configuration
;
; Output: Global variables populated with Layer 2 configuration
;         Layer2Resolution = 0 (256×192), 1 (320×256), or 2 (640×256)
;         Layer2Width/Height = pixel dimensions
;         Layer2Bpp = bits per pixel (4 or 8)
;         HL = stride (bytes per scanline)
;
; T-States summary shows:
; Variable timing based on resolution: 250-350 T-states (includes table lookups and calculations)
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next in Normal Next mode with access to Layer 2 display choices (i.e. not in ZX Spectrum compatibility modes.)
GetLayer2Info:          CALL    GetActiveLayer2Addr        ; Get current Layer 2 address, HL = 0 if no active layer 2
                        LD      A, H                       ; Check if HL = 0, no active Layer 2
                        OR      L
                        JR      Z, NoActiveLayer2Info      ; If no active Layer 2, skip the rest
                        LD      BC, LAYER2_REGISTER_SELECT_PORT
                        LD      A, LAYER2_CONTROL_REGISTER
                        OUT     (C), A                     ; Select Layer 2 control register
                        LD      BC, LAYER2_REGISTER_DATA_PORT
                        IN      A, (C)                     ; Read Layer 2 control register

; Now decode the Layer 2 control register to get the information we need. This is from the Spectrum Next documentation:
; 
; Bit	Function
; 7	    Layer 2 visible (1 = visible, 0 = not visible)
; 6	    Layer 2 write enable (1 = CPU can write, 0 = write protected)
; 4	    Layer 2 256-colour mode (1 = 256 colours, 0 = 128 colours)
; 2	    Layer 2 resolution (1 = 640×256, 0 = 320×256 when combined with bits 1-0)
; 1-0	Layer 2 resolution bits
;
; Resolution Encoding (bits 2,1,0):
; 000 = 256×192
; 001 = 320×256
; 010 = 640×256
; 011 = 256×192 (same as 000)

                        PUSH    AF
                        AND     %00000111                  ; Mask out bits 0-2 for resolution
                        OR      A
                        JP      Z, Is256by192              ; 000 or 011 = 256x192
                        CP      1                          ; 001 = 320x256
                        JP      Z, SetResolutionVariable
                        CP      2                          ; 010 = 640x256
                        JP      Z, SetResolutionVariable
Is256by192:             LD      HL, 256
                        LD      (Layer2Width), HL
                        LD      HL, 192
                        LD      (Layer2Height), HL
                        XOR     A                          ; lets have only one value in our variables 0 = 256x192
                        JP      SetResolutionVariable
Is320by256:             LD      HL, 320
                        LD      (Layer2Width), HL
                        LD      HL, 256
                        LD      (Layer2Height), HL
                        JP      SetResolutionVariable      ; A contains 1 = 320x256
Is640by256:             LD      HL, 640
                        LD      (Layer2Width), HL
                        LD      HL, 256
                        LD      (Layer2Height), HL
                        ; A contains 2 = 640x256
SetResolutionVariable:  LD      (Layer2Resolution), A
                        POP     AF                         ; Restore control register value
                        BIT     4, A                       ; Check if 8bpp (256 color mode) or 4bpp (128 color mode)
                        JP      NZ, Is4bpp
                        LD      A, 8
                        LD      (Layer2Bpp), A             ; Set current Bpp to 8bpp
                        RET
Is4bpp:                 LD      A, 4
                        LD      (Layer2Bpp), A             ; Set current Bpp to 4bpp
                        RET
NoActiveLayer2Info:     LD      HL, 0                      ; No active Layer 2, set defaults to zero.
                        LD      (Layer2Width), HL
                        LD      (Layer2Height), HL
                        XOR     A
                        LD      (Layer2Resolution), A
                        LD      (Layer2Bpp), A
                        RET