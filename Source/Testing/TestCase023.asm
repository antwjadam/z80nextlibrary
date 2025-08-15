TestCase023:        ; Test23 - Convert 0 with leading zeros, should produce "00000"
                    LD      HL, 0           ; Value to convert
                    LD      A, 0            ; With leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should be 5
                    CP      5
                    JR      NZ, Test23Failed

                    ; Check result should be "00000"
                    LD      HL, ConversionBuffer
                    LD      B, 5            ; Check 5 zeros
Test23CheckLoop:    LD      A, (HL)
                    CP      '0'
                    JR      NZ, Test23Failed
                    INC     HL
                    DJNZ    Test23CheckLoop
                    LD      A, (HL)
                    CP      0               ; Null terminator
                    LD      HL, MsgTestCase023
                    RET     Z               ; Z set is test passed, else test failed.
Test23Failed:       LD      HL, MsgTestCase023
                    LD      A, 23
                    JP      PrintFailedMessage

MsgTestCase023:     DB " Cvt. 0 with ldg 0", 0
