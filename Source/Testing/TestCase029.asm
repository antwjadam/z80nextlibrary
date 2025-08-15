TestCase029:        ; Test29 - Convert 65535 without leading zeros, should produce "65535"
                    LD      HL, 65535       ; Value to convert (maximum 16-bit)
                    LD      A, 1            ; No leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should be 5
                    CP      5
                    JR      NZ, Test29Failed
                    
                    ; Check result should be "65535"
                    LD      HL, ConversionBuffer
                    LD      A, (HL)
                    CP      '6'
                    JR      NZ, Test29Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '5'
                    JR      NZ, Test29Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '5'
                    JR      NZ, Test29Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '3'
                    JR      NZ, Test29Failed
                    INC     HL
                    LD      A, (HL)
                    CP      '5'
                    JR      NZ, Test29Failed
                    INC     HL
                    LD      A, (HL)
                    CP      0               ; Null terminator
                    LD      HL, MsgTestCase029
                    RET     Z               ; Z set is test passed, else test failed.
Test29Failed:       LD      HL, MsgTestCase029
                    LD      A, 29
                    JP      PrintFailedMessage

MsgTestCase029:     DB " Cvt. 65535", 0
