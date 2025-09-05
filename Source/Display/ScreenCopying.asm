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
; Note that we can use hardware double buffering on the Next, using bank switching to swap the display memory bank with an off-screen buffer bank,
; or by using hardware address switching, or Layer 2 hardware double buffering in Layer 2 screen modes.
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
