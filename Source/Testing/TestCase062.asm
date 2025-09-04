TestCase062:        ; Test case 62: Get active Layer 2 info - I dont have an active Layer 2, so I check for zero state.
                    CALL    GetLayer2Info

                    ; Also check the stored Layer2ScreenAddress is zero
                    LD      HL, (Layer2ScreenAddress)
                    LD      A, H
                    OR      L               ; Check HL is zero
                    JP      NZ, Test062Failed

                    LD      A, (Layer2Resolution)
                    CP      0               ; Check resolution is 0
                    JP      NZ, Test062Failed

                    LD      HL, (Layer2Width)
                    LD      A, H
                    OR      L               ; Check HL is zero
                    JP      NZ, Test062Failed

                    LD      HL, (Layer2Height)
                    LD      A, H
                    OR      L               ; Check HL is zero
                    JP      NZ, Test062Failed

                    LD      A, (Layer2Bpp)
                    CP      0               ; Check Bpp is 0
                    JP      NZ, Test062Failed
Test062Passed:      LD      HL, MsgTestCase062
                    XOR     A
                    OR      A               ; Set Z flag to indicate test passed.
                    RET

Test062Failed:      LD      HL, MsgTestCase062
                    LD      A, 62           ; Test number
                    JP      PrintFailedMessage

MsgTestCase062:     DB      " Get L2 Info", 0


;Layer2Resolution:           DB      1               ; Storage for current Layer 2 resolution mode - 0 = 256x192, 1 = 320x256, 2 = 640x256
;Layer2Width:                DS      2               ; Storage for current Layer 2 width in pixels
;Layer2Height:               DS      2               ; Storage for current Layer 2 height in pixels
;Layer2Bpp:                  DB      8               ; Storage for current Layer 2 bits per pixel mode - 8 (256 color mode) or 4 (128 color mode)