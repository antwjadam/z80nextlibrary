;
; DMA Detection - allows you to check if you are running on hardware or emulator with DMA support.
;
; Output: Z flag is set if DMA NOT available, NZ if DMA IS available
;
; T-States summary shows:
; DMA Not Available: 58 T-states
; DMA Is Available: 66 T-states
;
; @COMPAT: 48K,128K,+2,+3,NEXT
CheckDMAAvailable:      ; Test DMA availability by attempting to reset then read DMA status
                        LD      A, DMA_RESET                   ; Load reset command
                        OUT     (ZXN_DMA_PORT), A              ; Send reset command
                        IN      A, (ZXN_DMA_PORT)              ; Read back DMA status
                        OR      A                              ; Set Z flag if A is 0 (DMA available)
                        JR      Z, FoundDMA
NoDMA:                  XOR     A                              ; Set A to zero for DMA not found flag setting.
                        OR      A                              ; Set Flag Z to indicate no DMA available.
                        RET
FoundDMA:               LD      A, 1                           ; Set A to 1 (boolean true if you like :P)
                        OR      A                              ; Set Flag NZ to indicate DMA available
                        RET
;
; DMA Memory Fill - fills memory using DMA controller
;
; Input: HL = Destination Address, A = fill byte, BC = Byte Count
;
; T-States summary shows:
; CPU overhead: ~240-260 T-states (setup and wait)
; Hardware transfer: Parallel to CPU execution
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
DMA_MemoryFill:         PUSH    HL
                        PUSH    BC
                        PUSH    AF
                        ; Initialize DMA transfer
                        LD      A, DMA_RESET
                        OUT     (ZXN_DMA_PORT), A

                        ; Set DMA to fill operation - WR0
                        LD      A, DMA_FILL
                        OUT     (ZXN_DMA_PORT), A

                        ; Set DMA function control - WR1
                        LD      A, DMA_FUNCTION_CONTROL
                        OUT     (ZXN_DMA_PORT), A

                        ; Tell DMA controller to use fill byte value
                        POP     AF                              ; Restore fill byte
                        LD      (DMAFillByte), A                ; Store fill byte
                        LD      HL, DMAFillByte
                        LD      A, L
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, H
                        OUT     (ZXN_DMA_PORT), A

                        ; Set destination address
                        POP     BC                              ; Restore byte count
                        POP     HL                              ; Restore destination address
                        LD      A, L
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, H
                        OUT     (ZXN_DMA_PORT), A

                        ; Set transfer length in bytes
                        LD      A, C
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, B
                        OUT     (ZXN_DMA_PORT), A

                        ; Start transfer
                        LD      A, DMA_LOAD
                        OUT     (ZXN_DMA_PORT), A

                        ; Wait for transfer to complete
DMA_FillWait:           IN      A, (ZXN_DMA_PORT)
                        BIT     7, A                            ; Check if DMA is busy
                        JR      NZ, DMA_FillWait
                        RET
;
; DMA Burst Fill - fills memory using DMA controller in burst mode
;
; Input: HL = Destination Address, A = fill byte, BC = Byte Count, D = Burst Mode
;
; T-States summary shows:
; CPU overhead: ~235-250 T-states (setup and wait)
; Hardware transfer: Parallel to CPU execution (faster than standard DMA)
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
DMA_BurstFill:          PUSH    HL
                        PUSH    BC
                        PUSH    AF

                        ; Initialize DMA transfer
                        LD      A, DMA_RESET
                        OUT     (ZXN_DMA_PORT), A

                        ; Set DMA to burst fill
                        LD      A, DMA_BURST_TRANSFER
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, DMA_BURST_CONTROL
                        OUT     (ZXN_DMA_PORT), A

                        ; Tell DMA controller to use fill byte value
                        POP     AF                              ; Restore fill byte
                        LD      (DMAFillByte), A                ; Store fill byte
                        LD      HL, DMAFillByte
                        LD      A, L
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, H
                        OUT     (ZXN_DMA_PORT), A

                        ; Set destination address
                        POP     BC                              ; Restore byte count
                        POP     HL                              ; Restore destination address
                        LD      A, L
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, H
                        OUT     (ZXN_DMA_PORT), A

                        ; Set burst length in bytes
                        LD      A, C
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, B
                        OUT     (ZXN_DMA_PORT), A

                        ; Start burst transfer
                        LD      A, DMA_BURST_LOAD
                        OUT     (ZXN_DMA_PORT), A

                        ; Wait for burst to complete
DMA_BurstWait:          IN      A, (ZXN_DMA_PORT)               ; Read DMA status
                        AND     $C0                             ; Check bits 6 and 7
                        JR      NZ, DMA_BurstWait               ; Wait if either busy bit set

                        RET
;
; DMA Memory Copy - copies memory using DMA controller
;
; Input: HL = Source Address, DE = Destination Address, BC = Byte Count
;
; T-States summary shows:
; CPU overhead: ~280-300 T-states (setup and wait)
; Hardware transfer: Parallel to CPU execution
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
DMA_MemoryCopy:         ; Check if byte count is valid
                        LD      A, B
                        OR      C
                        JP      Z, DMA_CopyExit                 ; Exit if BC = 0

                        ; Initialize DMA transfer
                        LD      A, DMA_RESET
                        OUT     (ZXN_DMA_PORT), A

                        ; Set DMA to memory copy operation - WR0
                        LD      A, DMA_COPY
                        OUT     (ZXN_DMA_PORT), A

                        ; Set DMA function control - WR1
                        LD      A, DMA_FUNCTION_CONTROL
                        OUT     (ZXN_DMA_PORT), A

                        ; Set source address (HL)
                        LD      A, L
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, H
                        OUT     (ZXN_DMA_PORT), A

                        ; Set destination address (DE)
                        LD      A, E
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, D
                        OUT     (ZXN_DMA_PORT), A

                        ; Set transfer length in bytes (BC)
                        LD      A, C
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, B
                        OUT     (ZXN_DMA_PORT), A

                        ; Start transfer
                        LD      A, DMA_LOAD
                        OUT     (ZXN_DMA_PORT), A

                        ; Wait for transfer to complete
DMA_CopyWait:           IN      A, (ZXN_DMA_PORT)
                        BIT     7, A                            ; Check if DMA is busy
                        JR      NZ, DMA_CopyWait

DMA_CopyExit:           RET

;
; DMA Memory Copy Burst - copies memory using DMA controller in burst mode
;
; Input: HL = Source Address, DE = Destination Address, BC = Byte Count
;
; T-States summary shows:
; CPU overhead: ~260-280 T-states (setup and wait)
; Hardware transfer: Parallel to CPU execution (faster than standard DMA)
;
; @COMPAT: NEXT
; @REQUIRES: Spectrum Next with DMA architecture.
DMA_MemoryCopy_Burst:   ; Check if byte count is valid
                        LD      A, B
                        OR      C
                        JP      Z, DMA_BurstCopyExit            ; Exit if BC = 0

                        ; Initialize DMA transfer
                        LD      A, DMA_RESET
                        OUT     (ZXN_DMA_PORT), A

                        ; Set DMA to burst copy mode
                        LD      A, DMA_BURST_TRANSFER
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, DMA_BURST_COPY_CONTROL
                        OUT     (ZXN_DMA_PORT), A

                        ; Set source address (HL)
                        LD      A, L
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, H
                        OUT     (ZXN_DMA_PORT), A

                        ; Set destination address (DE)
                        LD      A, E
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, D
                        OUT     (ZXN_DMA_PORT), A

                        ; Set burst length in bytes (BC)
                        LD      A, C
                        OUT     (ZXN_DMA_PORT), A
                        LD      A, B
                        OUT     (ZXN_DMA_PORT), A

                        ; Start burst transfer
                        LD      A, DMA_BURST_LOAD
                        OUT     (ZXN_DMA_PORT), A

                        ; Wait for burst to complete
DMA_BurstCopyWait:      IN      A, (ZXN_DMA_PORT)               ; Read DMA status
                        AND     $C0                             ; Check bits 6 and 7
                        JR      NZ, DMA_BurstCopyWait           ; Wait if either busy bit set

DMA_BurstCopyExit:      RET
