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
; Total: ~240 T-States + (19 * wait_iterations)
; For typical transfers: ~240-260 T-States CPU time
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
; DMA Burst Fill - fills memory using DMA controller
;
; Input: HL = Destination Address, A = fill byte, BC = Byte Count, D = Burst Mode
;
; T-States summary shows:
; Total: ~235 T-States + (18 * wait_iterations)
; For typical transfers: ~235-250 T-States CPU time
; Burst mode completes faster so fewer wait iterations
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
