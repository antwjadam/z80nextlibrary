TestCase024:        ; Test24 - Convert 1 without leading zeros, should produce "1"
                    LD      HL, 1           ; Value to convert
                    LD      A, 1            ; No leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should be 1
                    CP      1
                    JR      NZ, Test24Failed
                    
                    ; Check result should be "1"
                    LD      HL, ConversionBuffer
                    LD      A, (HL)
                    CP      '1'
                    JR      NZ, Test24Failed
                    INC     HL
                    LD      A, (HL)
                    CP      0               ; Null terminator
                    LD      HL, MsgTestCase024
                    RET     Z               ; Z set is test passed, else test failed.
Test24Failed:       LD      HL, MsgTestCase024
                    LD      A, 24
                    JP      PrintFailedMessage

MsgTestCase024:     DB " Cvt. 1", 0
