TestCase022:        ; Test 22 - Convert 0 without leading zeros, should produce "0"
                    LD      HL, 0           ; Value to convert
                    LD      A, 1            ; No leading zeros
                    LD      DE, ConversionBuffer
                    CALL    ConvertToDecimal
;
;                    CALL    PrintLengthAndString ; use to debug test when it fails
;
                    ; Check length should be 1
                    CP      1
                    JR      NZ, Test22Failed

                    ; Check result should be "0", 0
                    LD      HL, ConversionBuffer
                    LD      A, (HL)
                    CP      '0'
                    JR      NZ, Test22Failed
                    INC     HL
                    LD      A, (HL)
                    CP      0               ; Null terminator
                    LD      HL, MsgTestCase022
                    RET     Z               ; Z set is test passed, else test failed.
Test22Failed:       LD      HL, MsgTestCase022
                    LD      A, 22
                    JP      PrintFailedMessage

MsgTestCase022:     DB " Cvt. 0", 0
