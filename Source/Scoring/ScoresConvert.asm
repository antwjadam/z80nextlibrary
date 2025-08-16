; This file contains routines for converting 16-bit values to ASCII strings
; suitable for display with the PrintString function.
;
; Functions provided:
; - ConvertToDecimal: Converts 16-bit value to zero-terminated ASCII string
;
; Entry points:
; - ConvertToDecimal: Main conversion routine with leading zero control
;
; ConvertToDecimal - Simple and working decimal conversion
; Entry: HL = value, A = leading zero flag, DE = buffer
; Exit: A = length, buffer filled with null-terminated string
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ConvertToDecimal:
                    ; Initialize state for this conversion
                    PUSH    AF              ; Save leading zero flag temporarily
                    XOR     A               ; Clear A
                    LD      (HasStarted), A ; Reset started flag for each call
                    POP     AF              ; Restore leading zero flag

                    CALL    ClearBuffer     ; Clear 6 bytes, all registers preserved
                    
                    PUSH    HL              ; Save original value
                    PUSH    DE              ; Save buffer pointer
                    LD      (LeadingZeroFlag), A ; Save leading zero flag
                    
                    ; Special case: value is zero
                    LD      A, H
                    OR      L
                    JR      NZ, NonZeroValue
                    
                    ; Handle zero
                    ; Clear buffer first
                    
                    LD      A, (LeadingZeroFlag)
                    OR      A
                    JR      NZ, SingleZero
                    
                    ; Five zeros
                    LD      A, '0'
                    LD      (DE), A
                    INC     DE
                    LD      (DE), A
                    INC     DE
                    LD      (DE), A
                    INC     DE
                    LD      (DE), A
                    INC     DE
                    LD      (DE), A
                    LD      A, 5            ; Length = 5, null terminator already in buffer
                    JR      ExitConvert
                    
SingleZero:         LD      A, '0'
                    LD      (DE), A
                    LD      A, 1            ; Length = 1, null terminator already in buffer
                    JR      ExitConvert
                    
NonZeroValue:       ; Convert non-zero value
                    LD      (BufferStart), DE
                    XOR     A               ; Clear A
                    LD      (HasStarted), A ; Initialize HasStarted to 0
                    
                    ; Process each decimal place
                    LD      DE, 10000
                    CALL    ProcessDigit
                    LD      DE, 1000
                    CALL    ProcessDigit
                    LD      DE, 100
                    CALL    ProcessDigit
                    LD      DE, 10
                    CALL    ProcessDigit
                    LD      DE, 1
                    CALL    ProcessDigit
                    
                    ; Count non-zero bytes in buffer to get length into A
                    CALL    CountBufferLength
ExitConvert:        POP     DE
                    POP     HL
                    RET

; Process one decimal digit
; Entry: HL = value, DE = place value (10000,1000,100,10,1)
; Exit: HL = remainder
ProcessDigit:       XOR     A               ; Digit counter
                    PUSH    HL              ; Save original value
DivLoop:            OR      A               ; Clear carry  
                    SBC     HL, DE          ; Subtract place value
                    JR      C, DivDone      ; If negative, we're done
                    INC     A               ; Count successful subtraction
                    JR      DivLoop         ; Continue dividing
DivDone:            POP     HL              ; Restore original value
                    PUSH    AF              ; Save digit count
                    
                    ; Calculate remainder: original - (digit * place_value)
                    PUSH    BC              ; Save BC
                    LD      B, A            ; B = digit count
                    OR      A               ; Test if digit = 0
                    JR      Z, RemainderZero ; If digit = 0, remainder = original
CalcRemainder:      PUSH    AF              ; Save A since we're about to modify flags
                    OR      A               ; Clear carry
                    SBC     HL, DE          ; Subtract place value
                    POP     AF              ; Restore A
                    DJNZ    CalcRemainder   ; Repeat for digit count
RemainderZero:      POP     BC              ; Restore BC
                    POP     AF              ; Restore digit count
                    
                    ; A = digit (0-9), HL = remainder
                    OR      A
                    JR      NZ, StoreNonZero ; Non-zero digits always stored
                    
                    ; Zero digit - check if we should store it
                    PUSH    AF              ; Save zero digit
                    LD      A, (HasStarted)
                    OR      A
                    JR      NZ, StoreZeroToo ; If started, store zeros too
                    
                    ; Not started - check leading zero flag
                    LD      A, (LeadingZeroFlag) ; Get leading zero flag
                    OR      A
                    JR      Z, StoreLeadingZero ; If leading zeros wanted, store it
                    
                    ; No leading zeros wanted - clean up stack and skip
                    POP     AF              ; Remove zero digit from stack
                    RET                     ; Skip this digit
                    
StoreLeadingZero:   ; Store leading zero and mark as started
                    LD      A, 1
                    LD      (HasStarted), A ; Mark as started for leading zeros too
                    POP     AF              ; Restore zero digit
                    JR      StoreThisDigit  ; Store the zero
                    
StoreZeroToo:       POP     AF              ; Restore zero digit
StoreNonZero:       ; Mark as started and store digit
                    PUSH    AF
                    LD      A, 1
                    LD      (HasStarted), A
                    POP     AF
                    
StoreThisDigit:     ; Store digit A in first zero byte of buffer
                    ADD     A, '0'             ; Convert to ASCII
                    PUSH    HL                 ; Save current value
                    PUSH    DE                 ; Save place value
                    PUSH    AF                 ; Save digit
                    
                    ; Find first zero byte in buffer
                    LD      HL, (BufferStart)  ; Start of buffer
FindZeroByte:       LD      A, (HL)            ; Get byte from buffer
                    OR      A                  ; Check if zero
                    JR      Z, FoundZero       ; Found zero byte
                    INC     HL                 ; Next byte
                    JR      FindZeroByte       ; Keep looking
                    
FoundZero:          POP     AF                 ; Restore digit
                    LD      (HL), A            ; Store digit in first zero position
                    POP     DE                 ; Restore place value
                    POP     HL                 ; Restore current value
                    RET

; CountBufferLength - Count non-zero bytes in buffer to determine length
; Entry: BufferStart points to buffer
; Exit: A = length (number of non-zero bytes)
;
; @COMPAT: 48K,128K,+2,+3,NEXT
CountBufferLength:  PUSH    HL                 ; Preserve HL
                    LD      HL, (BufferStart)  ; Start of buffer
                    LD      A, 0               ; Length counter
CountLoop:          PUSH    AF                 ; Save counter
                    LD      A, (HL)            ; Get byte from buffer
                    OR      A                  ; Check if zero
                    JR      Z, CountDone       ; Zero byte means end
                    POP     AF                 ; Restore counter
                    INC     A                  ; Increment length
                    INC     HL                 ; Next byte
                    JR      CountLoop          ; Continue counting
CountDone:          POP     AF                 ; Restore final count
                    POP     HL                 ; Restore HL
                    RET

; Working storage
BufferStart:        DW      0
HasStarted:         DB      0
LeadingZeroFlag:    DB      0

; ClearBuffer - Clear 6 bytes of buffer with full register preservation
; Entry: DE = buffer pointer
; Exit: All registers preserved, buffer cleared to zeros
;
; @COMPAT: 48K,128K,+2,+3,NEXT
ClearBuffer:        PUSH    AF              ; Preserve AF
                    PUSH    HL              ; Preserve HL
                    PUSH    DE              ; Preserve DE
                    LD      HL, DE          ; HL = buffer start
                    LD      (HL), 0         ; Clear byte 0
                    INC     HL
                    LD      (HL), 0         ; Clear byte 1
                    INC     HL
                    LD      (HL), 0         ; Clear byte 2
                    INC     HL
                    LD      (HL), 0         ; Clear byte 3
                    INC     HL
                    LD      (HL), 0         ; Clear byte 4
                    INC     HL
                    LD      (HL), 0         ; Clear byte 5
                    POP     DE              ; Restore DE
                    POP     HL              ; Restore HL
                    POP     AF              ; Restore AF
                    RET
