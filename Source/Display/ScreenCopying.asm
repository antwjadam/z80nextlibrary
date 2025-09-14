; Unified Screen copying routines organised by performance level.
;
; By having an in memory screen buffer, you can double buffer your display. On prlatforms where you cannot swap the screen vector for display, then these routines
; allow you to copy the contents of your off-screen buffer to the actual display memory, providing the software equivalent of double buffering.
;
; Performance gains on pop options allow T-States to be save by popping multiple bytes from the stack at once, and then setting individually on the target. The limitation
; of 1 stack pointer prevents us pushing and popping between the source and destination as stack swapping and preserving was too costly for any performance gain.
;
; Always call Screen_FullCopy_Unified to copy pixels and attributes.
; Always call Screen_PixelCopy_Unified to copy pixels only, attributes not altered on destination.
; Always call Screen_AttrCopy_Unified copy attributes only, pixels unaltered in destination.
;
; Input: HL = source address, DE = target address, C = performance level
;
; T-States summary shows:
;
; SCREEN_COPY_COMPACT: Standard LDIR operation    - Pixel Only ~129,024 T-States, Attribute Only ~16,128 T-States, Full Copy ~145,152 T-States
; SCREEN_COPY_1PUSH: Pops 2 bytes at a time       - Pixel Only ~154,036 T-States, Attribute Only ~19,342 T-States, Full Copy ~173,278 T-States, slightly slower but gets the pattern proven
; SCREEN_COPY_2PUSH: Pops 4 bytes at a time       - Pixel Only ~132,532 T-States, Attribute Only ~16,654 T-States, Full Copy ~149,086 T-States, approaching the performance tipping point now
; SCREEN_COPY_4PUSH: Pops 8 bytes at a time       - Pixel Only ~121,780 T-States, Attribute Only ~15,310 T-States, Full Copy ~136,990 T-States, 5.6% faster than COMPACT LDIR variants
; SCREEN_COPY_8PUSH: Pops 16 bytes at a time      - Pixel Only ~116,404 T-States, Attribute Only ~14,638 T-States, Full Copy ~130,942 T-States, 9.8% faster than COMPACT LDIR variants
; SCREEN_COPY_ALLPUSH: Pops 256 bytes at a time   - Pixel Only ~111,042 T-States, Attribute Only ~13,980 T-States, Full Copy ~124,908 T-States, 14% faster than COMPACT LDIR variants
;
; Next Only options T-States:
; SCREEN_COPY_Z80N_COMPACT: Z80N LDIRX operation  - Pixel Only ~98,324 T-States, Attribute Only ~12,308 T-States, Full Copy ~110,612 T-States, 24% faster than COMPACT LDIR variants
; SCREEN_COPY_DMA_FILL: DMA memory fill operation - Pixel Only ~300 T-States, Attribute Only ~300 T-States, Full Copy ~300 T-States, 99.8% faster than COMPACT LDIR variants
; SCREEN_COPY_DMA_BURST: DMA burst fill operation - Pixel Only ~270 T-States, Attribute Only ~270 T-States, Full Copy ~270 T-States, 99.8% faster than COMPACT LDIR variants
;
; Next Only Layer 2 options T-States:
; SCREEN_COPY_LAYER2_MANUAL_256by192: LDIRX       - Next Only - Full Copy only for Layer 2 takes ~78,663 T-States (44.4 FPS at 3.5MHz)
; SCREEN_COPY_LAYER2_MANUAL_320by256: LDIRX       - Next Only - Full Copy only for Layer 2 takes ~131,112 T-States (26.7 FPS at 3.5MHz)
; SCREEN_COPY_LAYER2_MANUAL_640by256: LDIRX       - Next Only - Full Copy only for Layer 2 takes ~262,224 T-States (13.3 FPS at 3.5MHz)
; SCREEN_COPY_LAYER2_MANUAL_DMA_256by192: BURST   - Next Only - Full Copy only for Layer 2 takes ~260 T-States (13,500+ FPS at 3.5MHz)
; SCREEN_COPY_LAYER2_MANUAL_DMA_320by256: BURST   - Next Only - Full Copy only for Layer 2 takes ~350 T-States (10,000+ FPS at 3.5MHz)
; SCREEN_COPY_LAYER2_MANUAL_DMA_640by256: BURST   - Next Only - Full Copy only for Layer 2 takes ~600 T-States (5,800+ FPS at 3.5MHz)
; SCREEN_COPY_LAYER2_AUTO_ACTIVE: LDIRX           - Next Only - Full Copy. Variable by resolution: 256×192 (~78,763 T-states), 320×256 (~131,212 T-states), 640×256 (~262,324 T-states)
; SCREEN_COPY_LAYER2_AUTO_DMA: DMA BURST          - Next Only - Full Copy. Variable by resolution: 256×192 (~360 T-states), 320×256 (~450 T-states), 640×256 (~700 T-states)
;
; These options assume Layer 2 is already enabled and set up, and the screen mode is already set. It replicates the base copying operation for Layer 2 screen modes but
; much faster double buffering is possibe by simply "activating" the off screen bugffer so that the current active display becomes the off-screen buffer. The next call and all drawing then
; should target the current off screen buffer. These first choices mimic the copy from off screen to active screen layer 2 memory. Also note that layer 2 has no attributes, so we only
; use the Screen_FullCopy_Unified entry point for layer 2 options. 
;
; Plus3 Double Buffering Support T-States:
; PLUS3_SETUP_DOUBLE_BUFFER                  ; +3 and Next Only - ~200 T-states + screen clearing time
; PLUS3_SET_OFFSCREEN_BUFFER                 ; +3 and Next Only - ~45 T-states (ensures correct banking state)
; PLUS3_DOUBLE_BUFFER_TOGGLE                 ; +3 and Next Only - ~95 T-states (includes HALT + banking operations)
;
; Added Plus 3 double buffering support - this simply switches the current visible bank to the other bank, so no copying is required, just a bank switch. This is very fast.
; These are called directly rather than through the Screen_FullCopy_Unified entry point as they do no copying, just a bank switch.
;
; CALL PLUS3_SETUP_DOUBLE_BUFFER                  ; to set up Plus 3 double buffering (call once at start of program)
; CALL PLUS3_SET_OFFSCREEN_BUFFER                 ; to get the current off-screen buffer address and ensure the correct bank is at $C000 for drawing before any drawing/clearing etc are performed.
; CALL PLUS3_DOUBLE_BUFFER_TOGGLE                 ; to toggle between the two screen banks (5 and 7)
;
; TODO: - Next Only - Use ZX Spectrum Next Registers to change the current active display banks.
;
; Platform notes regarding double buffering and screen copying operations:
;
; ZX Spectrum specific notes: (3.5MHz CPU speed)
;
; It is worth noting a raster full frame is 69,888 T-states at 50Hz, so the fastest ZX Spectrum full screen copy currently is 124,908 T-states which is 1.79 frames.
; We can perform a full screen copy every 2 frames on original hardware. This gives a maximum theoretical frame rate for a full screen copy on Spectrum hardware of 27.9 FPS.
; Your FPS will be slower depending on how you wipe and redraw the buffer between copies.
;
; Frame rate capabilities of ZX Spectrum ALLPUSH variant at different Next CPU speeds available on the Next:
; 3.5MHz: 27.9 FPS maximum (1.79 frames per copy)  - Standard ZX Spectrum speed and compatibility
; 7MHz:   56.1 FPS maximum (0.89 frames per copy)  - 2× enhanced speed  
; 14MHz:  112.1 FPS maximum (0.45 frames per copy) - 4× enhanced speed
; 28MHz:  224.3 FPS maximum (0.22 frames per copy) - 8× maximum speed
;
; ZX Spectrum Next specific notes: (Much higher frame rates achievable with faster CPU speeds)
;
; The fastest Next only option is the DMA burst operation which can do a full screen copy in just 270 T-states which is 0.004 frames at 3.5MHz.
; This gives a maximum theoretical frame rate for a full screen copy on Next hardware of 12,500+ FPS at 3.5MHz.
; In practical terms, screen copying becomes negligible overhead, allowing the CPU to focus entirely on game logic.
;
; Frame rate capabilities of ZX Spectrum Next fastest variant - DMA BURST at different Next CPU speeds:
; 3.5MHz: 12,500+ FPS maximum (0.004 frames per copy)   - DMA overhead becomes negligible
; 7MHz:   25,000+ FPS maximum (0.002 frames per copy)   - Practically unlimited frame rate
; 14MHz:  50,000+ FPS maximum (0.001 frames per copy)   - Practically unlimited frame rate  
; 28MHz:  100,000+ FPS maximum (0.0005 frames per copy) - Practically unlimited frame rate  
;
; Note that we can use hardware double buffering on the Next, using bank switching to swap the display memory.
;
; @COMPAT: 48K,128K,+2,+3,NEXT
Screen_FullCopy_Unified:    ; If DE is 0, default to ZX Spectrum screen base address as the destination address
                            LD      A, D
                            OR      E
                            JP      NZ, FullCopyCustomDestination
                            LD      DE, SCREEN_PIXEL_BASE           ; Default to ZX Spectrum screen base address
FullCopyCustomDestination:  ; Calculate stack pointer to end of source attribute area of source address, popping moves backwards through the buffer, so we need to be at the end of it
                            PUSH    HL                              ; Save source address
                            PUSH    DE                              ; Save destination address
                            LD      DE, 6912                        ; Full screen pixels plus attributes byte count on a ZX spectrum standard screen
                            ADD     HL, DE                          ; HL = is now the correct end of buffer address
                            LD      (CalculatedStackPointer), HL    ; Save calculated stack pointer
                            POP     DE                              ; Restore destination address
                            POP     HL                              ; Restore source address
                            LD      A, C                            ; Get Performance Level
                            CP      SCREEN_COPY_COMPACT
                            JP      Z, FullCopyScreen_LDIR
                            CP      SCREEN_COPY_1PUSH
                            JP      Z, FullCopyScreen_1PUSH
                            CP      SCREEN_COPY_2PUSH
                            JP      Z, FullCopyScreen_2PUSH
                            CP      SCREEN_COPY_4PUSH
                            JP      Z, FullCopyScreen_4PUSH
                            CP      SCREEN_COPY_8PUSH
                            JP      Z, FullCopyScreen_8PUSH
                            CP      SCREEN_COPY_ALLPUSH
                            JP      Z, FullCopyScreen_ALLPUSH
                            CP      SCREEN_COPY_Z80N_COMPACT        ; Next only compatible options from here
                            JP      Z, FullCopyScreen_LDIRX
                            CP      SCREEN_COPY_DMA_FILL
                            JP      Z, FullCopyScreen_DMA_FILL
                            CP      SCREEN_COPY_DMA_BURST
                            JP      Z, FullCopyScreen_DMA_BURST
                            CP      SCREEN_COPY_LAYER2_MANUAL_256by192
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_256by192
                            CP      SCREEN_COPY_LAYER2_MANUAL_320by256
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_320by256
                            CP      SCREEN_COPY_LAYER2_MANUAL_640by256
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_640by256
                            CP      SCREEN_COPY_LAYER2_MANUAL_DMA_256by192
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_DMA_256by192
                            CP      SCREEN_COPY_LAYER2_MANUAL_DMA_320by256
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_DMA_320by256
                            CP      SCREEN_COPY_LAYER2_MANUAL_DMA_640by256
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_DMA_640by256
                            CP      SCREEN_COPY_LAYER2_AUTO_ACTIVE
                            JP      Z, FullCopyScreen_LAYER2_AUTO_ACTIVE
                            CP      SCREEN_COPY_LAYER2_AUTO_DMA
                            JP      Z, FullCopyScreen_LAYER2_AUTO_DMA

                            ; TODO: Add Layer 2 and Hardware Double Buffering options here

                            ; fall through to Compact LDIR copy

;
; @COMPAT: 48K,128K,+2,+3,NEXT
FullCopyScreen_LDIR:        LD      BC, 6912                        ; Full screen pixels plus attributes byte count on a ZX spectrum standard screen
                            LDIR                                    ; Copy all bytes
                            RET
;
; @COMPAT: NEXT
; @Z80N: LDIRX
; @REQUIRES: Spectrum Next, Z80N architecture.
FullCopyScreen_LDIRX:       LD      BC, 6912                        ; Full screen pixels plus attributes byte count on a ZX spectrum standard screen
                            LDIRX                                   ; Copy all bytes using Z80N extended op code
                            RET
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
FullCopyScreen_DMA_FILL:    LD      BC, 6912                        ; Full screen pixels plus attributes byte count on a ZX spectrum standard screen
                            JP      DMA_MemoryCopy                  ; HL=source, DE=dest already set
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
FullCopyScreen_DMA_BURST:   LD      BC, 6912                        ; Full screen pixels plus attributes byte count on a ZX spectrum standard screen
                            JP      DMA_MemoryCopy_Burst            ; HL=source, DE=dest already set
;
; @COMPAT: 48K,128K,+2,+3,NEXT
FullCopyScreen_1PUSH:       LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6912                        ; Calculate to end of destination buffer
                            ADD     HL, DE                          ; This primes the HL to be the destination end address as SP is now the source
                            LD      B, 27                           ; 27 × 256 = 6912 bytes / 2
FullCopy_1Pop_Loop:         LD      C, 128                          ; 128 × 2 = 256 bytes per outer loop, 2 because we pop 2 bytes per loop
FullCopy_1Pop_Inner:        POP     DE                              ; Read 2 bytes from source (10 T-states)
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            DEC     C                               ; inner count decrement
                            JP      NZ, FullCopy_1Pop_Inner
                            DEC     B                               ; outer count decrement
                            JP      NZ, FullCopy_1Pop_Loop
                            ; copy complete, so restore stack back to the original
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET
;
; @COMPAT: 48K,128K,+2,+3,NEXT
FullCopyScreen_2PUSH:       LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6912                        ; Calculate to end of destination buffer
                            ADD     HL, DE                          ; This primes the HL to be the destination end address as SP is now the source
                            LD      B, 27                           ; 27 × 256 = 6912 bytes / 2
FullCopy_2Pop_Loop:         LD      C, 64                           ; 64 × 4 = 256 bytes per outer loop, 4 because we pop 4 bytes per loop
FullCopy_2Pop_Inner:        POP     DE                              ; Read 2 bytes from source
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 4 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            DEC     C                               ; inner count decrement
                            JP      NZ, FullCopy_2Pop_Inner
                            DEC     B                               ; outer count decrement
                            JP      NZ, FullCopy_2Pop_Loop
                            ; copy complete, so restore stack back to the original
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET
;
; @COMPAT: 48K,128K,+2,+3,NEXT
FullCopyScreen_4PUSH:       LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6912                        ; Calculate to end of destination buffer
                            ADD     HL, DE                          ; This primes the HL to be the destination end address as SP is now the source
                            LD      B, 27                           ; 27 × 256 = 6912 bytes / 2
FullCopy_4Pop_Loop:         LD      C, 32                           ; 32 × 8 = 256 bytes per outer loop, 8 because we pop 8 bytes per loop
FullCopy_4Pop_Inner:        POP     DE                              ; Read 2 bytes from source
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 4 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 6 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 8 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            DEC     C                               ; inner count decrement
                            JP      NZ, FullCopy_4Pop_Inner
                            DEC     B                               ; outer count decrement
                            JP      NZ, FullCopy_4Pop_Loop
                            ; copy complete, so restore stack back to the original
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET
;
; @COMPAT: 48K,128K,+2,+3,NEXT
FullCopyScreen_8PUSH:       LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6912                        ; Calculate to end of destination buffer
                            ADD     HL, DE                          ; This primes the HL to be the destination end address as SP is now the source
                            LD      B, 27                           ; 27 × 256 = 6912 bytes / 2
FullCopy_8Pop_Loop:         LD      C, 16                           ; 16 × 16 = 256 bytes per outer loop, 16 because we pop 16 bytes per loop
FullCopy_8Pop_Inner:        POP     DE                              ; Read 2 bytes from source
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 4 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 6 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 8 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 10 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 12 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 14 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                              ; Read next 2 bytes from source without looping, totalling 16 bytes per inner loop    
                            DEC     HL                              ; Move to next destination position
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            DEC     C                               ; inner count decrement
                            JP      NZ, FullCopy_8Pop_Inner
                            DEC     B                               ; outer count decrement
                            JP      NZ, FullCopy_8Pop_Loop
                            ; copy complete, so restore stack back to the original
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET
;
; @COMPAT: 48K,128K,+2,+3,NEXT
FullCopyScreen_ALLPUSH:     LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6912                        ; Calculate to end of destination buffer
                            ADD     HL, DE                          ; This primes the HL to be the destination end address as SP is now the source
                            LD      B, 27                           ; 27 × 256 = 6912 bytes / 2
FullCopy_AllPop_Loop:       POP     DE                              
                            DEC     HL
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 2 bytes done
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 4 bytes done
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 6 bytes done
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 8 bytes done
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 16 bytes done
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 24 bytes done
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 32 bytes done
                            POP     DE
                            DEC     HL
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 64 bytes done
                            POP     DE
                            DEC     HL
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 96 bytes done
                            POP     DE
                            DEC     HL
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 128 bytes done
                            POP     DE
                            DEC     HL
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 160 bytes done
                            POP     DE
                            DEC     HL
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 192 bytes done
                            POP     DE
                            DEC     HL
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 224 bytes done
                            POP     DE
                            DEC     HL
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         
                            POP     DE                                  
                            DEC     HL                              
                            LD      (HL), E
                            DEC     HL
                            LD      (HL), D                         ; 256 bytes done
                            DEC     B                               ; outer count decrement
                            JP      NZ, FullCopy_AllPop_Loop
                            ; copy complete, so restore stack back to the original
                            LD      SP, (ScreenStackPointer)        ; Restore stack pointer
                            RET

;
; @COMPAT: 48K,128K,+2,+3,NEXT
Screen_PixelCopy_Unified:   ; If DE is 0, default to ZX Spectrum screen base pixel address as the destination address
                            LD      A, D
                            OR      E
                            JP      NZ, PixelCopyCustomDestination
                            LD      DE, SCREEN_PIXEL_BASE           ; Default to ZX Spectrum screen base pixel address
PixelCopyCustomDestination: ; Calculate stack pointer to end of source pixels, popping moves backwards through the buffer, so we need to be at the end of it
                            PUSH    HL                              ; Save source address
                            PUSH    DE                              ; Save destination address
                            LD      DE, 6144                        ; Full screen pixels byte count on a ZX spectrum standard screen
                            ADD     HL, DE                          ; HL = is now the correct end of buffer address
                            LD      (CalculatedStackPointer), HL    ; Save calculated stack pointer
                            POP     DE                              ; Restore destination address
                            POP     HL                              ; Restore source address
                            LD      A, C                            ; Get Performance Level
                            CP      SCREEN_COPY_COMPACT
                            JP      Z, PixelCopyScreen_LDIR
                            CP      SCREEN_COPY_1PUSH
                            JP      Z, PixelCopyScreen_1PUSH
                            CP      SCREEN_COPY_2PUSH
                            JP      Z, PixelCopyScreen_2PUSH
                            CP      SCREEN_COPY_4PUSH
                            JP      Z, PixelCopyScreen_4PUSH
                            CP      SCREEN_COPY_8PUSH
                            JP      Z, PixelCopyScreen_8PUSH
                            CP      SCREEN_COPY_ALLPUSH
                            JP      Z, PixelCopyScreen_ALLPUSH
                            CP      SCREEN_COPY_Z80N_COMPACT        ; Next only compatible options from here
                            JP      Z, PixelCopyScreen_Z80N_LDIRX
                            CP      SCREEN_COPY_DMA_FILL
                            JP      Z, PixelCopyScreen_DMA_FILL
                            CP      SCREEN_COPY_DMA_BURST
                            JP      Z, PixelCopyScreen_DMA_BURST

                            ; TODO: Add Layer 2 and Hardware Double Buffering options here

                            ; fall through to Compact LDIR copy

;
; @COMPAT: 48K,128K,+2,+3,NEXT
PixelCopyScreen_LDIR:       LD      BC, 6144                        ; Full screen pixels byte count on a ZX spectrum standard screen
                            LDIR                                    ; Copy all bytes
                            RET
;
; @COMPAT: NEXT
; @Z80N: LDIRX
; @REQUIRES: Spectrum Next, Z80N architecture.
PixelCopyScreen_Z80N_LDIRX: LD      BC, 6144                        ; Full screen pixels byte count on a ZX spectrum standard screen
                            LDIRX                                   ; Copy all bytes using Z80N extended instruction
                            RET
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
PixelCopyScreen_DMA_FILL:   LD      BC, 6144                        ; Pixel area size
                            JP      DMA_MemoryCopy                  ; HL=source, DE=dest already set
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
PixelCopyScreen_DMA_BURST:  LD      BC, 6144                        ; Pixel area size
                            JP      DMA_MemoryCopy_Burst            ; HL=source, DE=dest already set
;
; @COMPAT: 48K,128K,+2,+3,NEXT
PixelCopyScreen_1PUSH:      LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6144                        ; Calculate to end of destination pixels
                            ADD     HL, DE                          ; This primes the HL to be the destination pixel end address as SP is now the source
                            LD      B, 24                           ; 24 × 256 = 6144 bytes / 2
                            ; The rest of this routine is identical to FullCopy_1PUSH from FullCopy_1Pop_Loop so we can reuse it - both use the same C loop count.
                            JP      FullCopy_1Pop_Loop
;
; @COMPAT: 48K,128K,+2,+3,NEXT
PixelCopyScreen_2PUSH:      LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6144                        ; Calculate to end of destination pixels
                            ADD     HL, DE                          ; This primes the HL to be the destination pixel end address as SP is now the source
                            LD      B, 24                           ; 24 × 256 = 6144 bytes / 2
                            ; The rest of this routine is identical to FullCopy_2PUSH from FullCopy_2Pop_Loop so we can reuse it - both use the same C loop count.
                            JP      FullCopy_2Pop_Loop
;
; @COMPAT: 48K,128K,+2,+3,NEXT
PixelCopyScreen_4PUSH:      LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6144                        ; Calculate to end of destination pixels
                            ADD     HL, DE                          ; This primes the HL to be the destination pixel end address as SP is now the source
                            LD      B, 24                           ; 24 × 256 = 6144 bytes / 2
                            ; The rest of this routine is identical to FullCopy_4PUSH from FullCopy_4Pop_Loop so we can reuse it - both use the same C loop count.
                            JP      FullCopy_4Pop_Loop
;
; @COMPAT: 48K,128K,+2,+3,NEXT
PixelCopyScreen_8PUSH:      LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6144                        ; Calculate to end of destination pixels
                            ADD     HL, DE                          ; This primes the HL to be the destination pixel end address as SP is now the source
                            LD      B, 24                           ; 24 × 256 = 6144 bytes / 2
                            ; The rest of this routine is identical to FullCopy_8PUSH from FullCopy_8Pop_Loop so we can reuse it - both use the same C loop count.
                            JP      FullCopy_8Pop_Loop
;
; @COMPAT: 48K,128K,+2,+3,NEXT
PixelCopyScreen_ALLPUSH:    LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 6144                        ; Calculate to end of destination pixels
                            ADD     HL, DE                          ; This primes the HL to be the destination pixel end address as SP is now the source
                            LD      B, 24                           ; 24 × 256 = 6144 bytes / 2
                            ; The rest of this routine is identical to FullCopy_ALLPUSH from FullCopy_AllPop_Loop so we can reuse it.
                            JP      FullCopy_AllPop_Loop

;
; @COMPAT: 48K,128K,+2,+3,NEXT
Screen_AttrCopy_Unified:    ; If DE is 0, default to ZX Spectrum screen base attributes address as the destination address
                            LD      A, D
                            OR      E
                            JP      NZ, AttrCopyCustomDestination
                            LD      DE, SCREEN_ATTR_BASE            ; Default to ZX Spectrum screen base attribute address
AttrCopyCustomDestination:  ; Calculate stack pointer to end of source attributes, popping moves backwards through the buffer, so we need to be at the end of it
                            PUSH    HL                              ; Save source address
                            PUSH    DE                              ; Save destination address
                            LD      DE, 768                         ; Full screen attributes byte count on a ZX spectrum standard screen
                            ADD     HL, DE                          ; HL = is now the correct end of buffer address
                            LD      (CalculatedStackPointer), HL    ; Save calculated stack pointer
                            POP     DE                              ; Restore destination address
                            POP     HL                              ; Restore source address
                            LD      A, C                            ; Get Performance Level
                            CP      SCREEN_COPY_COMPACT
                            JP      Z, AttrCopyScreen_LDIR
                            CP      SCREEN_COPY_1PUSH
                            JP      Z, AttrCopyScreen_1PUSH
                            CP      SCREEN_COPY_2PUSH
                            JP      Z, AttrCopyScreen_2PUSH
                            CP      SCREEN_COPY_4PUSH
                            JP      Z, AttrCopyScreen_4PUSH
                            CP      SCREEN_COPY_8PUSH
                            JP      Z, AttrCopyScreen_8PUSH
                            CP      SCREEN_COPY_ALLPUSH
                            JP      Z, AttrCopyScreen_ALLPUSH
                            CP      SCREEN_COPY_Z80N_COMPACT        ; Next only compatible options from here
                            JP      Z, AttrCopyScreen_Z80N_LDIRX
                            CP      SCREEN_COPY_DMA_FILL
                            JP      Z, AttrCopyScreen_DMA_FILL
                            CP      SCREEN_COPY_DMA_BURST
                            JP      Z, AttrCopyScreen_DMA_BURST

                            ; TODO: Add Layer 2 and Hardware Double Buffering options here

                            ; fall through to Compact LDIR copy

;
; @COMPAT: 48K,128K,+2,+3,NEXT
AttrCopyScreen_LDIR:        LD      BC, 768                         ; Full screen attributes byte count on a ZX spectrum standard screen
                            LDIR                                    ; Copy all bytes
                            RET
;
; @COMPAT: NEXT
; @Z80N: LDIRX
; @REQUIRES: Spectrum Next, Z80N architecture.
AttrCopyScreen_Z80N_LDIRX:  LD      BC, 768                         ; Full screen attributes byte count on a ZX spectrum standard screen
                            LDIRX                                   ; Copy all bytes using Z80N extended instruction
                            RET
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
AttrCopyScreen_DMA_FILL:    LD      BC, 768                         ; Attribute area size
                            JP      DMA_MemoryCopy                  ; HL=source, DE=dest already set
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
AttrCopyScreen_DMA_BURST:  LD      BC, 768                          ; Attribute area size
                           JP      DMA_MemoryCopy_Burst             ; HL=source, DE=dest already set
;
; @COMPAT: 48K,128K,+2,+3,NEXT
AttrCopyScreen_1PUSH:       LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 768                         ; Calculate to end of destination attributes
                            ADD     HL, DE                          ; This primes the HL to be the destination attribute end address as SP is now the source
                            LD      B, 3                            ; 3 × 256 = 768 bytes / 2
                            ; The rest of this routine is identical to FullCopy_1PUSH from FullCopy_1Pop_Loop so we can reuse it - both use the same C loop count.
                            JP      FullCopy_1Pop_Loop
;
; @COMPAT: 48K,128K,+2,+3,NEXT
AttrCopyScreen_2PUSH:       LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 768                         ; Calculate to end of destination attributes
                            ADD     HL, DE                          ; This primes the HL to be the destination attribute end address as SP is now the source
                            LD      B, 3                            ; 3 × 256 = 768 bytes / 2
                            ; The rest of this routine is identical to FullCopy_2PUSH from FullCopy_2Pop_Loop so we can reuse it - both use the same C loop count.
                            JP      FullCopy_2Pop_Loop
;
; @COMPAT: 48K,128K,+2,+3,NEXT
AttrCopyScreen_4PUSH:       LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 768                         ; Calculate to end of destination attributes
                            ADD     HL, DE                          ; This primes the HL to be the destination attribute end address as SP is now the source
                            LD      B, 3                            ; 3 × 256 = 768 bytes / 2
                            ; The rest of this routine is identical to FullCopy_4PUSH from FullCopy_4Pop_Loop so we can reuse it - both use the same C loop count.
                            JP      FullCopy_4Pop_Loop
;
; @COMPAT: 48K,128K,+2,+3,NEXT
AttrCopyScreen_8PUSH:       LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 768                         ; Calculate to end of destination attributes
                            ADD     HL, DE                          ; This primes the HL to be the destination attribute end address as SP is now the source
                            LD      B, 3                            ; 3 × 256 = 768 bytes / 2
                            ; The rest of this routine is identical to FullCopy_8PUSH from FullCopy_8Pop_Loop so we can reuse it - both use the same C loop count.
                            JP      FullCopy_8Pop_Loop
;
; @COMPAT: 48K,128K,+2,+3,NEXT
AttrCopyScreen_ALLPUSH:     LD      (ScreenStackPointer), SP        ; Save current stack pointer
                            LD      SP, (CalculatedStackPointer)    ; Set stack pointer to end of source buffer
                            LD      HL, 768                         ; Calculate to end of destination attributes
                            ADD     HL, DE                          ; This primes the HL to be the destination attribute end address as SP is now the source
                            LD      B, 3                            ; 3 × 256 = 768 bytes / 2
                            ; The rest of this routine is identical to FullCopy_ALLPUSH from FullCopy_AllPop_Loop so we can reuse it - both use the same C loop count.
                            JP      FullCopy_AllPop_Loop
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with Layer 2 architecture.
FullCopyScreen_LAYER2_MANUAL_256by192:
                            LD      BC, LAYER2_BYTES_256by192       ; 256x192 Layer 2 size (49152 bytes)
                            LDIRX                                   ; Copy using Z80N extended op code
                            RET
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with Layer 2 architecture.
FullCopyScreen_LAYER2_MANUAL_320by256:
                            ; First half: 40KB - this is done as total bytes is larger than 64k, so needs to be split into two LDIRX operations
                            LD      BC, LAYER2_BYTES_320by256_HALF  ; 40KB
                            LDIRX
                            ; Second half: 40KB
                            LD      BC, LAYER2_BYTES_320by256_HALF  ; 40KB
                            LDIRX
                            RET
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with Layer 2 architecture.
FullCopyScreen_LAYER2_MANUAL_640by256:
                            ; First quarter: 40KB - this is done as total bytes is larger than 64k, so needs to be split into four LDIRX operations
                            LD      BC, LAYER2_BYTES_640by256_QTR   ; 40KB
                            LDIRX
                            ; Second quarter: 40KB
                            LD      BC, LAYER2_BYTES_640by256_QTR   ; 40KB
                            LDIRX
                            ; Third quarter: 40KB
                            LD      BC, LAYER2_BYTES_640by256_QTR   ; 40KB
                            LDIRX
                            ; Fourth quarter: 40KB
                            LD      BC, LAYER2_BYTES_640by256_QTR   ; 40KB
                            LDIRX
                            RET
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA and Layer 2 architecture.
FullCopyScreen_LAYER2_MANUAL_DMA_256by192:
                            LD      BC, LAYER2_BYTES_256by192       ; 256x192 Layer 2 size (49152 bytes)
                            JP      DMA_MemoryCopy_Burst            ; Use DMA burst for maximum speed
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA and Layer 2 architecture.
FullCopyScreen_LAYER2_MANUAL_DMA_320by256:
                            ; First half: 40KB via DMA
                            LD      BC, LAYER2_BYTES_320by256_HALF  ; 40KB
                            CALL    DMA_MemoryCopy_Burst
                            ; Second half: 40KB via DMA
                            LD      BC, LAYER2_BYTES_320by256_HALF  ; 40KB
                            JP      DMA_MemoryCopy_Burst
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA and Layer 2 architecture.
FullCopyScreen_LAYER2_MANUAL_DMA_640by256:
                            ; First quarter: 40KB via DMA
                            LD      BC, LAYER2_BYTES_640by256_QTR   ; 40KB
                            CALL    DMA_MemoryCopy_Burst
                            ; Second quarter
                            LD      BC, LAYER2_BYTES_640by256_QTR   ; 40KB
                            CALL    DMA_MemoryCopy_Burst
                            ; Third quarter
                            LD      BC, LAYER2_BYTES_640by256_QTR   ; 40KB
                            CALL    DMA_MemoryCopy_Burst
                            ; Fourth quarter
                            LD      BC, LAYER2_BYTES_640by256_QTR   ; 40KB
                            JP      DMA_MemoryCopy_Burst
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with Layer 2 architecture.
FullCopyScreen_LAYER2_AUTO_ACTIVE:
                            PUSH    HL                              ; Save source address
                            CALL    GetLayer2Info                   ; Get current Layer 2 configuration
                            LD      HL, (Layer2ScreenAddress)       ; Get Active Layer 2 screen address
                            EX      DE, HL                          ; DE = destination address (active layer 2 screen)
                            POP     HL                              ; Restore source address (off screen layer 2 buffer address)
                            ; A = mode (0=256x192, 1=320x256, 2=640x256)
                            LD      A, (Layer2Resolution)           ; Check resolution mode
                            CP      2
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_640by256
                            CP      1
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_320by256
                            JP      FullCopyScreen_LAYER2_MANUAL_256by192

;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA and Layer 2 architecture.
FullCopyScreen_LAYER2_AUTO_DMA:
                            PUSH    HL                              ; Save source address
                            CALL    GetLayer2Info                   ; Get current Layer 2 configuration
                            LD      HL, (Layer2ScreenAddress)       ; Get Active Layer 2 screen address
                            EX      DE, HL                          ; DE = destination address (active layer 2 screen)
                            POP     HL                              ; Restore source address (off screen layer 2 buffer address)
                            ; A = mode (0=256x192, 1=320x256, 2=640x256)
                            LD      A, (Layer2Resolution)           ; Check resolution mode
                            CP      2
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_DMA_640by256
                            CP      1
                            JP      Z, FullCopyScreen_LAYER2_MANUAL_DMA_320by256
                            JP      FullCopyScreen_LAYER2_MANUAL_DMA_256by192
;
; Toggle between screen banks at $4000 and $C000 for double buffering support on +3 and Next
;
; The Spectrum +3 has 128K RAM, divided into eight 16K banks (Bank 0 to Bank 7). The memory map is:
;
; $0000–$3FFF: ROM (or RAM Bank 0/1 if paging)
; $4000–$7FFF: Always paged RAM (Bank 5 by default)
; $8000–$BFFF: Fixed RAM (Bank 2)
; $C000–$FFFF: Paged RAM via port $7FFD
;
; to allow ease of writing to the off screen buffer, we set up the memory banks as follows:
;
; Default state: Bank 5 at $4000 (visible screen)
; Bank 7 at $C000 (off-screen buffer)
;
; Port $7FFD bit layout:
; Bit 0-2: RAM bank (0-7) at $C000-$FFFF  
; Bit 3: Screen select (0=Bank 5, 1=Bank 7) <- This is what we toggle
; Bit 4: ROM select
; Bit 5: Disable paging
;
; Memory layout we want:
; $4000-$7FFF: Current visible screen (Bank 5 or 7)
; $C000-$FFFF: Off-screen buffer (Bank 7 or 5) 
;;
; When drawing to off-screen: Bank 7 at $4000 (off-screen buffer)
; After drawing is complete: switch visible screen to Bank 7 at $4000 (visible screen), and Bank 5 at $C000 (off-screen buffer)
; Then we can safely draw to Bank 5 at $4000 (off-screen buffer)
; After drawing is complete: switch visible screen to Bank 5 at $4000 (visible screen), and Bank 7 at $C000 (off-screen buffer)
; Rinse and repeat...
;
; @COMPAT: +3,NEXT
; @REQUIRES: +3 or Next with 128K paging, and interrupts must be enabled to allow HALT to work.

PLUS3_DOUBLE_BUFFER_TOGGLE: HALT                                    ; Wait for next frame (HALT until interrupt) to avoid tearing
                            ; Read current bank from variable and switch to the other bank
                            LD      BC, $7FFD                       ; Paging port
                            LD      A, (Dbl_Buffer_Current_Bank)
                            XOR     %00001000                       ; Toggle bit 3 (screen display)
                            OUT     (C), A                          ; Switch displayed screen
                            ; Now set up off-screen bank at $C000 for drawing ( we always draw to $C000)
                            BIT     3, A                            ; Check which screen is visible
                            JR      Z, SetBank7AtC000               ; If Bank 5 visible, put Bank 7 at $C000
                            ; Bank 7 is visible, put Bank 5 at $C000 for drawing
SetBank5AtC000:             AND     %11111000                       ; Clear bits 0-2 (bank selection bits) - keep screen display bit 3
                            OR      %00000101                       ; Bank 5 at $C000
                            LD      (Dbl_Buffer_Current_Bank), A    ; Save new state
                            OUT     (C), A
                            RET
SetBank7AtC000:             AND     %11111000                       ; Clear bits 0-2 (bank selection bits) - keep screen display bit 3
                            OR      %00000111                       ; Bank 7 at $C000
                            LD      (Dbl_Buffer_Current_Bank), A    ; Save new state
                            OUT     (C), A
                            RET
;
; This small routines are needed for to set up Bank 7 at $C000 as the off-screen buffer at the start of the program, only need to call this once.
;
; @COMPAT: +3,NEXT
; @REQUIRES: +3 or Next with 128K paging
PLUS3_SETUP_DOUBLE_BUFFER:  LD      BC, $7FFD                       ; Paging port
                            LD      A, %00000111                    ; Bank 7 at $C000, Bank 5 screen visible
                            OUT     (C), A
                            LD      (Dbl_Buffer_Current_Bank), A    ; Save current state
                            ; Clear visible screen (Bank 5 at $4000)
                            LD      HL, $4000                       ; Visible screen
                            LD      A, $00                          ; Clear value - pixels unset, attributes black on black - change to pixel and attribute call if needed.
                            LD      C, SCREEN_8PUSH                 ; Performance level
                            CALL    Screen_FullReset_Unified
                            ; Clear off-screen buffer (Bank 7 at $C000)
                            LD      HL, $C000                       ; Off-screen buffer
                            LD      A, $00                          ; Clear value - pixels unset, attributes black on black - change to pixel and attribute call if needed.
                            LD      C, SCREEN_8PUSH                 ; Performance level
                            JP      Screen_FullReset_Unified
;
; Get current off-screen buffer address for drawing. Always call this to ensure the correct bank is set at $C000 for drawing before any drawing/clearing etc are performed.
; Only call once at the start of your drawing loop to set up the off-screen buffer, as it is assumed that you will be drawing to $C000 until the next toggle call.
;
; Output, HL = address of off screen buffer (always $C000 as bank 5 and 7 swap places with toggle routine and this call), A = bank number (5 or 7 for reference)
;
; @COMPAT: +3,NEXT
; @REQUIRES: +3 or Next with 128K paging
; @OUTPUT: HL = address of off-screen buffer ($C000)
; @OUTPUT: A = bank number of off-screen buffer (5 or 7)
PLUS3_SET_OFFSCREEN_BUFFER: LD      A, (Dbl_Buffer_Current_Bank)
                            BIT     3, A                            ; Check which screen is visible
                            JR      Z, OffScreenIsBank7             ; If Bank 5 visible, off-screen is Bank 7 at $C000
                            AND     $07                             ; Mask out other bits, keep bits 0-2 (bank selection bits)
                            CP      5
                            JP      Z, Bank5Already                 ; If already Bank 5 at $C000, just return expected values.
                            ; Bank 7 visible, need Bank 5 at $C000 for drawing
                            LD      A, (Dbl_Buffer_Current_Bank)
                            AND     %11111000                       ; Clear bits 0-2 (bank selection bits) - keep screen display bit 3
                            OR      %00000101                       ; Bank 5 at $C000
                            LD      BC, $7FFD
                            OUT     (C), A
                            LD      (Dbl_Buffer_Current_Bank), A    ; Save state
Bank5Already:               LD      HL, $C000                       ; Off-screen buffer address
                            LD      A, 5                            ; Bank number
                            RET
OffScreenIsBank7:           ; Bank 5 visible, Bank 7 should be at $C000
                            LD      A, (Dbl_Buffer_Current_Bank)
                            AND     $07                             ; Mask out other bits, keep bits 0-2 (bank selection bits)
                            CP      7
                            JP      Z, Bank7Already                 ; If already Bank 7 at $C000, just return expected values.
                            LD      A, (Dbl_Buffer_Current_Bank)
                            AND     %11111000                       ; Clear bits 0-2 (bank selection bits)
                            OR      %00000111                       ; Bank 7 at $C000
                            LD      BC, $7FFD
                            OUT     (C), A
Bank7Already:               LD      HL, $C000                       ; Off-screen buffer address
                            LD      A, 7                            ; Bank number
                            RET