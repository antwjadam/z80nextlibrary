TestCase025:        ; Test25 - Convert 1 with leading zeros. should produce "00001"
                    LD      HL, 1           ; Value to convert
                    LD      A, 0            ; With leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should be 5
                    CP      5
                    JR      NZ, Test25Failed

                    ; Check result should be "00001"
                    LD      HL, ConversionBuffer
                    LD      B, 4            ; Check first 4 zeros
Test25CheckZeros:   LD      A, (HL)
                    CP      '0'
                    JR      NZ, Test25Failed
                    INC     HL
                    DJNZ    Test25CheckZeros
                    LD      A, (HL)         ; Check last digit
                    CP      '1'
                    JR      NZ, Test25Failed
                    INC     HL
                    LD      A, (HL)
                    CP      0               ; Null terminator
                    LD      HL, MsgTestCase025
                    RET     Z               ; Z set is test passed, else test failed.
Test25Failed:       LD      HL, MsgTestCase025
                    LD      A, 25
                    JP      PrintFailedMessage

MsgTestCase025:     DB " Cvt. 1 with ldg 0", 0
