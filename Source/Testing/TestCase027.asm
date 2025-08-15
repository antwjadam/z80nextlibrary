TestCase027:        ; Test27 - Convert 123 with leading zeros, should produce "00123"
                    LD      HL, 123         ; Value to convert
                    LD      A, 0            ; With leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should be 5
                    CP      5
                    JR      NZ, Test27Failed

                    ; Check result should be "00123"
                    LD      HL, ConversionBuffer
                    LD      A, (HL)
                    CP      '0'
                    JR      NZ, Test27Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '0'
                    JR      NZ, Test27Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '1'
                    JR      NZ, Test27Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '2'
                    JR      NZ, Test27Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '3'
                    JR      NZ, Test27Failed
                    INC     HL
                    LD      A, (HL)
                    CP      0               ; Null terminator
                    LD      HL, MsgTestCase027
                    RET     Z               ; Z set is test passed, else test failed.
Test27Failed:       LD      HL, MsgTestCase027
                    LD      A, 27
                    JP      PrintFailedMessage

MsgTestCase027:      DB " Cvt. 123 with ldg 0", 0
