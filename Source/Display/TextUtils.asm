;
; @COMPAT: 48K,128K,+2,+3,NEXT

; Initialize system
InitDisplay:        CALL    ResetCursorTopLeft
                    LD      A, 0x07         ; White on black for base attribute when clearing attribute memory
                    LD      (CurrentAttr), A
                    RET

; Set cursor position
; Input: B = row (0-23), C = column (0-31)
SetCursor:          LD      A, B
                    CP      SCREEN_HEIGHT
                    JR      NC, SetCursor_End ; Row out of bounds
                    LD      A, C
                    CP      SCREEN_WIDTH
                    JR      NC, SetCursor_End ; Column out of bounds
                    
                    LD      A, B
                    LD      (CursorRow), A
                    LD      A, C
                    LD      (CursorCol), A
SetCursor_End:      RET

ResetCursorTopLeft: ; Reset cursor position to 0,0 (top left)
                    XOR     A               ; Clear A to zero
                    LD      (CursorRow), A
                    LD      (CursorCol), A
                    RET

; Print a character using direct screen memory access
; Input: A = character to print
PrintChar:          PUSH    AF
                    PUSH    BC
                    PUSH    DE
                    PUSH    HL
                    
                    ; Handle special characters
                    CP      13              ; Carriage return
                    JR      Z, PrintChar_CR
                    CP      10              ; Line feed
                    JR      Z, PrintChar_LF
                    CP      32              ; Space or higher
                    JR      C, PrintChar_End ; Skip control chars (except CR/LF)
                    
                    ; Print normal character
                    CALL    PrintChar_Normal
                    CALL    AdvanceCursor
                    JR      PrintChar_End
                    
PrintChar_CR:       ; Carriage return - move to start of current line
                    LD      A, 0
                    LD      (CursorCol), A
                    JR      PrintChar_End
                    
PrintChar_LF:       ; Line feed - move to next line
                    LD      A, (CursorRow)
                    INC     A
                    CP      SCREEN_HEIGHT
                    JR      C, PrintChar_LF_OK
                    ; Scroll screen up (simplified - just go to top for now)
                    LD      A, 0
PrintChar_LF_OK:    LD      (CursorRow), A
                    
PrintChar_End:      POP     HL
                    POP     DE
                    POP     BC
                    POP     AF
                    RET

; Print normal character (internal routine)
; Input: A = character, uses cursor position
PrintChar_Normal:   ; Get character font data (use embedded font)
                    PUSH    AF
                    LD      HL, EmbeddedFont ; Use our embedded font
                    SUB     32              ; ASCII 32 is first printable
                    LD      D, 0
                    LD      E, A
                    ADD     HL, DE
                    ADD     HL, DE
                    ADD     HL, DE
                    ADD     HL, DE
                    ADD     HL, DE
                    ADD     HL, DE
                    ADD     HL, DE
                    ADD     HL, DE          ; Each char is 8 bytes
                    
                    ; Get screen position for current cursor
                    CALL    GetScreenAddress
                    ; DE now points to screen memory
                    
                    ; Copy 8 bytes of character data
                    LD      B, 8
PrintChar_Loop:     LD      A, (HL)
                    LD      (DE), A
                    INC     HL
                    LD      A, D
                    ADD     A, 1            ; Move to next pixel row
                    LD      D, A
                    DJNZ    PrintChar_Loop
                    
                    ; Set attribute
                    CALL    GetAttrAddress
                    LD      A, (CurrentAttr)
                    LD      (DE), A
                    
                    POP     AF
                    RET

; Get screen memory address for current cursor position
; Output: DE = screen memory address
GetScreenAddress:   LD      A, (CursorRow)
                    LD      D, A
                    LD      A, (CursorCol)
                    LD      E, A
                    
                    ; Calculate screen address: Base + (row * 256) + (row & 7) * 32 + col
                    ; Simplified for now - just do basic calculation
                    LD      A, D            ; Row
                    AND     0x18            ; Get high bits of row
                    ADD     A, 0x40         ; Add screen base high byte
                    LD      D, A
                    
                    LD      A, (CursorRow)  ; Row again
                    AND     0x07            ; Get low bits
                    RRCA
                    RRCA
                    RRCA                    ; Multiply by 32
                    ADD     A, E            ; Add column
                    LD      E, A
                    RET

; Get attribute memory address for current cursor position  
; Output: DE = attribute memory address
GetAttrAddress:     LD      A, (CursorRow)
                    LD      D, 0
                    LD      E, A
                    ADD     HL, DE
                    ADD     HL, DE
                    ADD     HL, DE
                    ADD     HL, DE
                    ADD     HL, DE          ; Row * 32
                    LD      DE, SCREEN_ATTR_BASE
                    ADD     HL, DE
                    LD      A, (CursorCol)
                    LD      E, A
                    LD      D, 0
                    ADD     HL, DE          ; Add column
                    EX      DE, HL          ; Result in DE
                    RET

; Advance cursor to next position
AdvanceCursor:      LD      A, (CursorCol)
                    INC     A
                    CP      SCREEN_WIDTH
                    JR      C, AdvanceCursor_OK
                    
                    ; Wrap to next line
                    LD      A, 0
                    LD      (CursorCol), A
                    LD      A, (CursorRow)
                    INC     A
                    CP      SCREEN_HEIGHT
                    JR      C, AdvanceCursor_Row_OK
                    LD      A, 0            ; Wrap to top (simplified scrolling)
AdvanceCursor_Row_OK: LD    (CursorRow), A
                    RET
                    
AdvanceCursor_OK:   LD      (CursorCol), A
                    RET

; Print a null-terminated string using direct screen memory
; Input: HL = pointer to string
PrintString:        LD      A, (HL)         ; Get character
                    OR      A               ; Check if zero
                    RET     Z               ; Return if end of string
                    CALL    PrintChar       ; Print using our direct routine
                    INC     HL              ; Next character
                    JR      PrintString     ; Continue

; Print a decimal number (0-255) using direct screen memory
; Input: A = number to print
PrintDecimal:       LD      D, A            ; Save number
                    LD      E, 0            ; Hundreds counter
                    
                    ; Extract hundreds
PrintDec_Hundreds:  LD      A, D
                    CP      100
                    JR      C, PrintDec_Tens
                    SUB     100
                    LD      D, A
                    INC     E
                    JR      PrintDec_Hundreds
                    
PrintDec_Tens:      LD      A, E            ; Hundreds
                    OR      A
                    JR      Z, PrintDec_SkipH
                    ADD     A, '0'
                    CALL    PrintChar
                    
PrintDec_SkipH:     LD      B, 0            ; Tens counter
PrintDec_TensLoop:  LD      A, D
                    CP      10
                    JR      C, PrintDec_Units
                    SUB     10
                    LD      D, A
                    INC     B
                    JR      PrintDec_TensLoop
                    
PrintDec_Units:     LD      A, B            ; Tens
                    OR      E               ; Check if we printed hundreds
                    JR      Z, PrintDec_SkipT
                    LD      A, B
                    ADD     A, '0'
                    CALL    PrintChar
                    
PrintDec_SkipT:     LD      A, D            ; Units
                    ADD     A, '0'
                    CALL    PrintChar
                    RET

; Set text color attribute
; Input: A = attribute byte
SetTextColor:       LD      (CurrentAttr), A
                    RET

; Print at specific position
; Input: B = row, C = column, HL = string
PrintAt:            CALL    SetCursor
                    CALL    PrintString
                    RET

; Alias for PrintAt with more descriptive name
; Input: B = row, C = column, HL = string
PrintStringAt:      CALL    SetCursor
                    CALL    PrintString
                    RET
