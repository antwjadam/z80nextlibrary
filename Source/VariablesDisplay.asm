; Text cursor position
CursorRow:                  DB      0               ; Current row (0-23)
CursorCol:                  DB      0               ; Current column (0-31)

; Attribute for text and clearing of attribute area
CurrentAttr:                DB      0x07            ; Current attribute (white on black)

; Stack stores for optimised screen clearing.
ScreenStackPointer:         DS      2               ; Storage for screen clear/copy routines stack pointer saving
CalculatedStackPointer:     DS      2               ; Storage for calculated stack pointer

; Storage for Active Layer 2 details
Layer2ScreenAddress:        DS      2               ; Storage for current Layer 2 address
Layer2Resolution:           DB      1               ; Storage for current Layer 2 resolution mode - 0 = 256x192, 1 = 320x256, 2 = 640x256
Layer2Width:                DS      2               ; Storage for current Layer 2 width in pixels
Layer2Height:               DS      2               ; Storage for current Layer 2 height in pixels
Layer2Bpp:                  DB      8               ; Storage for current Layer 2 bits per pixel mode - 8 (256 color mode) or 4 (128 color mode)