TestCase028:        ; Test28 - Convert 9999 without leading zeros, should produce "9999"
                    LD      HL, 9999        ; Value to convert
                    LD      A, 1            ; No leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should be 4
                    CP      4
                    JR      NZ, Test28Failed

                    ; Check result should be "9999"
                    LD      HL, ConversionBuffer
                    LD      B, 4            ; Check 4 nines
Test28CheckLoop:    LD      A, (HL)
                    CP      '9'
                    JR      NZ, Test28Failed
                    INC     HL
                    DJNZ    Test28CheckLoop
                    LD      A, (HL)
                    CP      0               ; Null terminator
                    LD      HL, MsgTestCase028
                    RET     Z               ; Z set is test passed, else test failed.
Test28Failed:       LD      HL, MsgTestCase028
                    LD      A, 28
                    JP      PrintFailedMessage

MsgTestCase028:     DB " Cvt. 9999", 0
