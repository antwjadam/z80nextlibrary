TestCase026:        ; Test26 - Convert 123 without leading zeros, should produce "123"
                    LD      HL, 123         ; Value to convert
                    LD      A, 1            ; No leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should be 3
                    CP      3
                    JR      NZ, Test26Failed

                    ; Check result should be "123"
                    LD      HL, ConversionBuffer
                    LD      A, (HL)
                    CP      '1'
                    JR      NZ, Test26Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '2'
                    JR      NZ, Test26Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '3'
                    JR      NZ, Test26Failed
                    INC     HL
                    LD      A, (HL)
                    CP      0               ; Null terminator
                    LD      HL, MsgTestCase026
                    RET     Z               ; Z set is test passed, else test failed.
Test26Failed:       LD      HL, MsgTestCase026
                    LD      A, 26
                    JP      PrintFailedMessage

MsgTestCase026:     DB " Cvt. 123", 0
