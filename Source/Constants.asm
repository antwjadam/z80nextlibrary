; Screen dimensions and memory layout
SCREEN_WIDTH                            EQU     32      ; Characters per row
SCREEN_HEIGHT                           EQU     24      ; Rows
SCREEN_PIXEL_BASE                       EQU     0x4000  ; Start of pixel memory
SCREEN_ATTR_BASE                        EQU     0x5800  ; Start of attribute memory

; Performance levels for multiply and divide routines.
PERFORMANCE_COMPACT                     EQU     0       ; Smallest code base required - device independent choice.
PERFORMANCE_BALANCED                    EQU     1       ; Balance between speed and memory usage - device independent choice.
PERFORMANCE_MAXIMUM                     EQU     2       ; Maximum speed but larger memory usage - device independent choice.
PERFORMANCE_NEXT_COMPACT                EQU     3       ; Smallest code base required - Next only compatible choice.
PERFORMANCE_NEXT_BALANCED               EQU     4       ; Balance between speed and memory usage - Next only compatible choice.
PERFORMANCE_NEXT_MAXIMUM                EQU     5       ; Maximum speed but larger memory usage - Next only compatible choice.

; Random number generator options
PERFORMANCE_RANDOM_LCG                  EQU     0       ; Fast, good distribution, full period
PERFORMANCE_RANDOM_LFSR                 EQU     1       ; Best quality, maximum period, moderate speed
PERFORMANCE_RANDOM_XORSHIFT             EQU     2       ; Fastest execution, very good quality, likley best for games.
PERFORMANCE_RANDOM_MIDDLESQUARE         EQU     3       ; Educational software use only.
PERFORMANCE_Z80N_RANDOM_LCG             EQU     4       ; Fast, good distribution, full period - Next only compatible choice.
PERFORMANCE_Z80N_RANDOM_LFSR            EQU     5       ; Best quality, maximum period, moderate speed - Next only compatible choice.
PERFORMANCE_Z80N_RANDOM_XORSHIFT        EQU     6       ; Fastest execution, very good quality, likley best for games - Next only compatible choice. - Next only compatible choice.
PERFORMANCE_Z80N_RANDOM_MIDDLESQUARE    EQU     7       ; Educational software use only - Next only compatible choice.

; Screen clear and copy performance choices
SCREEN_COMPACT                          EQU     0       ; Standard LDIR operation, slowest but most compact code.
SCREEN_1PUSH                            EQU     1       ; Sets 2 pixels simultaneously, faster but more complex code.
SCREEN_2PUSH                            EQU     2       ; Sets 4 pixels simultaneously, even faster but slightly larger code overhead.
SCREEN_4PUSH                            EQU     3       ; Sets 8 pixels simultaneously, even faster but slightly larger code overhead.
SCREEN_8PUSH                            EQU     4       ; Sets 16 pixels simultaneously, fastest but largest code overhead with loops.
SCREEN_ALLPUSH                          EQU     5       ; Sets all 2,048 pixels (256 bytes) simultaneously, maximum speed but very large code overhead.
SCREEN_Z80N_COMPACT                     EQU     6       ; Standard LDIR operation, slowest but most compact code - Next only compatible choice.
SCREEN_DMA_FILL                         EQU     7       ; Uses Spectrum Next DMA to fill screen, hardware fast speed but requires Spectrum Next with DMA architecture.
SCREEN_DMA_BURST                        EQU     8       ; Uses Spectrum Next DMA Burst mode to fill screen, maximum speed but requires Spectrum Next with DMA architecture.

; DMA Constants
DMA_BURST_CONTROL                       EQU     $18
DMA_BURST_LOAD                          EQU     $DF
DMA_BURSTMODE                           EQU     $FF
DMA_BURST_TRANSFER                      EQU     $7F
DMA_FUNCTION_CONTROL                    EQU     $14
DMA_FILL                                EQU     $79
DMA_LOAD                                EQU     $CF
DMA_RESET                               EQU     $C3
ZXN_DMA_PORT                            EQU     $6B
