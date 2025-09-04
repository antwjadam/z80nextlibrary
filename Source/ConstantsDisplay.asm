; Screen dimensions and memory layout
SCREEN_WIDTH                            EQU     32      ; Characters per row
SCREEN_HEIGHT                           EQU     24      ; Rows
SCREEN_PIXEL_BASE                       EQU     0x4000  ; Start of pixel memory
SCREEN_ATTR_BASE                        EQU     0x5800  ; Start of attribute memory

; Screen clearing performance choices
SCREEN_COMPACT                          EQU     0       ; Standard LDIR operation, slowest but most compact code.
SCREEN_1PUSH                            EQU     1       ; Sets 2 pixels simultaneously, faster but more complex code.
SCREEN_2PUSH                            EQU     2       ; Sets 4 pixels simultaneously, even faster but slightly larger code overhead.
SCREEN_4PUSH                            EQU     3       ; Sets 8 pixels simultaneously, even faster but slightly larger code overhead.
SCREEN_8PUSH                            EQU     4       ; Sets 16 pixels simultaneously, fastest but largest code overhead with loops.
SCREEN_ALLPUSH                          EQU     5       ; Sets all 2,048 pixels (256 bytes) simultaneously, maximum speed but very large code overhead.
SCREEN_Z80N_COMPACT                     EQU     6       ; Standard LDIR operation, slowest but most compact code - Next only compatible choice.
SCREEN_DMA_FILL                         EQU     7       ; Uses Spectrum Next DMA to fill screen, hardware fast speed but requires Spectrum Next with DMA architecture.
SCREEN_DMA_BURST                        EQU     8       ; Uses Spectrum Next DMA Burst mode to fill screen, maximum speed but requires Spectrum Next with DMA architecture.
SCREEN_LAYER2_MANUAL_256by192           EQU     9       ; Uses manual Layer 2 address in HL and LDIRX to fill Layer 2 256x192 mode to colour defined by attribute parameter.
SCREEN_LAYER2_MANUAL_320by256           EQU     10      ; Uses manual Layer 2 address in HL and LDIRX to fill Layer 2 320x256 mode to colour defined by attribute parameter.
SCREEN_LAYER2_MANUAL_640by256           EQU     11      ; Uses manual Layer 2 address in HL and LDIRX to fill Layer 2 640x256 mode to colour defined by attribute parameter.
SCREEN_LAYER2_MANUAL_DMA_256by192       EQU     12      ; Uses manual Layer 2 address in HL and DMA to fill Layer 2 256x192 mode to colour defined by attribute parameter.
SCREEN_LAYER2_MANUAL_DMA_320by256       EQU     13      ; Uses manual Layer 2 address in HL and DMA to fill Layer 2 320x256 mode to colour defined by attribute parameter.
SCREEN_LAYER2_MANUAL_DMA_640by256       EQU     14      ; Uses manual Layer 2 address in HL and DMA to fill Layer 2 640x256 mode to colour defined by attribute parameter.
SCREEN_LAYER2_AUTO_ACTIVE               EQU     15      ; Uses automatic Layer 2 address and resolution detection and LDIRX to the colour defined by attribute parameter.
SCREEN_LAYER2_AUTO_DMA                  EQU     16      ; Uses automatic Layer 2 address and resolution detection and DMA BURST to the colour defined by attribute parameter.

; Next only Layer 2 Display Constants
LAYER2_REGISTER_DATA_PORT               EQU     $243B   ; Next register data port for Layer 2
LAYER2_REGISTER_SELECT_PORT             EQU     $253B   ; Next register select port for Layer 2
LAYER2_ADDRESS_REGISTER                 EQU     0x12    ; Next Layer 2 address register
LAYER2_CONTROL_REGISTER                 EQU     0x15    ; Next Layer 2 control register
LAYER2_BYTES_256by192                   EQU     $C000   ; Number of bytes in Layer 2 256x192 mode - 48KB
; These next two sizes cannot fit the bit count in 16 bits, so we define the 320x256 half size for 16-bit operations and do the screen clear twice, and then use that four times for 640x256
LAYER2_BYTES_320by256_HALF              EQU     $A000   ; Full EQU     81920   ; Number of bytes in Layer 2 320x256 mode = 80KB so do 40K then 40K to fit the byte count in 16 bits
LAYER2_BYTES_640by256_QTR               EQU     $A000   ; Full EQU    163840   ; Number of bytes in Layer 2 640x256 mode - 160KB so do 40K four times to fit in 16 bit registers

