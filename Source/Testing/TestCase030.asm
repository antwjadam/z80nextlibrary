TestCase030:        ; Test30 - Convert 12345 in both modes, should produce "12345" in both modes
                    ; First test without leading zeros
                    LD      HL, 12345       ; Value to convert
                    LD      A, 1            ; No leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should be 5
                    CP      5
                    JR      NZ, Test30Failed

                    ; Check result should be "12345"
                    CALL    CheckTest30Result
                    JR      NZ, Test30Failed
                    
                    ; Now test with leading zeros (should be same result)
                    LD      HL, 12345       ; Value to convert
                    LD      A, 0            ; With leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should still be 5
                    CP      5
                    JR      NZ, Test30Failed

                    ; Check result should still be "12345"
                    CALL    CheckTest30Result
                    LD      HL, MsgTestCase030
                    RET     Z               ; Z set is test passed, else test failed.
Test30Failed:       LD      HL, MsgTestCase030
                    LD      A, 30
                    JP      PrintFailedMessage

CheckTest30Result:  ; if NZ set on return, test failed.
                    LD      HL, ConversionBuffer
                    LD      A, (HL)
                    CP      '1'
                    RET     NZ
                    INC     HL
                    LD      A, (HL)
                    CP      '2'
                    RET     NZ
                    INC     HL
                    LD      A, (HL)
                    CP      '3'
                    RET     NZ
                    INC     HL
                    LD      A, (HL)
                    CP      '4'
                    RET     NZ
                    INC     HL
                    LD      A, (HL)
                    CP      '5'
                    RET     NZ
                    INC     HL
                    LD      A, (HL)
                    CP      0               ; Null terminator
                    RET

MsgTestCase030:     DB " Cvt. 12345", 0
