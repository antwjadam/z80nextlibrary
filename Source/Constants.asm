; Screen dimensions and memory layout
SCREEN_WIDTH                    EQU     32      ; Characters per row
SCREEN_HEIGHT                   EQU     24      ; Rows
SCREEN_PIXEL_BASE               EQU     0x4000  ; Start of pixel memory
SCREEN_ATTR_BASE                EQU     0x5800  ; Start of attribute memory

; Performance levels for multiply and divide routines.
PERFORMANCE_COMPACT             EQU     0       ; Smallest code base required
PERFORMANCE_BALANCED            EQU     1       ; Balance between speed and memory usage
PERFORMANCE_MAXIMUM             EQU     2       ; Maximum speed but larger memory usage

; Random number generator options
PERFORMANCE_RANDOM_LCG          EQU     0       ; Fast, good distribution, full period
PERFORMANCE_RANDOM_LFSR         EQU     1       ; Best quality, maximum period, moderate speed
PERFORMANCE_RANDOM_XORSHIFT     EQU     2       ; Fastest execution, very good quality, likley best for games.
PERFORMANCE_RANDOM_MIDDLESQUARE EQU     3       ; Educational software use only.