# NextLibrary - Z80 Assembly Utilities Library for Spectrum and Next

[![Platform: ZX Spectrum 48K](https://img.shields.io/badge/Platform-ZX%20Spectrum%2048K-blue.svg)](https://en.wikipedia.org/wiki/ZX_Spectrum)
[![Platform: ZX Spectrum 128K](https://img.shields.io/badge/Platform-ZX%20Spectrum%20128K-blue.svg)](https://en.wikipedia.org/wiki/ZX_Spectrum)
[![Platform: ZX Spectrum +2](https://img.shields.io/badge/Platform-ZX%20Spectrum%20%2B2-blue.svg)](https://en.wikipedia.org/wiki/ZX_Spectrum)
[![Platform: ZX Spectrum +3](https://img.shields.io/badge/Platform-ZX%20Spectrum%20%2B3-blue.svg)](https://en.wikipedia.org/wiki/ZX_Spectrum)
[![Platform: ZX Spectrum Next](https://img.shields.io/badge/Platform-ZX%20Spectrum%20Next-purple.svg)](https://www.specnext.com/)
[![Assembly: Z80](https://img.shields.io/badge/Assembly-Z80-green.svg)](https://en.wikipedia.org/wiki/Zilog_Z80)
[![Assembly: Z80N](https://img.shields.io/badge/Assembly-Z80N-orange.svg)](https://wiki.specnext.dev/Z80N_Extended_Opcodes)
[![DMA: Supported](https://img.shields.io/badge/DMA-Supported-red.svg)](https://wiki.specnext.dev/DMA)
[![Layer 2: Supported](https://img.shields.io/badge/Layer%202-Supported-purple.svg)](https://wiki.specnext.dev/Layer_2)

**A high-performance, utility library for Z80 assembly development on the ZX Spectrum and ZX Spectrum Next platforms. The choice is yours, you can use device independent routines or limit yourself to platform specific routines for a single target architecture.**

NextLibrary provides world-class mathematical operations, random number generation, screen management, DMA operations, and utility functions optimized for retro game development and system programming.

It offers hardware independent routines that work on both Spectrum and Spectrum Next hardware. It also provides equivalent and optimised Next only versions making use of Z80N Next only extended op codes and DMA for best performance.

T-State tables in this document also allow for easy performance and requirement assessment by the developer.

## Release History

**v1.7** - Layer 2 Graphics Support and Enhanced Modularity

Key improvements:
- **62 Test Cases**: Expanded test suite from 59 to 62 comprehensive test cases including Layer 2 validation
- **Layer 2 Graphics Support**: Complete Layer 2 utility functions for Next hardware graphics programming
- **Layer 2 Screen Clearing**: Ultra-fast Layer 2 clearing using DMA with support for all resolutions (256×192, 320×256, 640×256)
- **Layer 2 Detection**: Hardware detection for active Layer 2 with resolution and address retrieval
- **Enhanced Modularity**: Split constants and variables into separate domain-specific files for easier partial library adoption
- **Improved Developer Experience**: Cleaner file organization allowing developers to include only needed components
- **Layer 2 Information Retrieval**: Complete Layer 2 configuration detection including resolution, color depth, and memory requirements
- **Extended Graphics Pipeline**: Foundation for advanced Layer 2 graphics operations and double-buffering

Layer 2 performance improvements:
- **Layer 2 DMA Clearing**: Up to 99.8% faster Layer 2 screen clearing using DMA burst mode
- **Resolution Detection**: Fast Layer 2 configuration retrieval (83-157 T-states)
- **Memory Efficient**: Optimized Layer 2 operations with minimal CPU overhead
- **Hardware Adaptive**: Automatic fallback to standard operations if Layer 2 unavailable

File structure improvements:
- **Modular Constants**: Separate files for Maths, Random, Display, and DMA constants
- **Organized Variables**: Domain-specific variable files for cleaner partial library usage
- **Developer Friendly**: Extract only needed components without dependency overhead

**v1.6** - Enhanced Screen Management and DMA Support

Key improvements:
- **59 Test Cases**: Expanded test suite from 57 to 59 comprehensive test cases including DMA validation
- **Flexible Screen Addressing**: All screen clearing routines now accept HL parameter for custom screen locations
- **In-Memory Screen Support**: Full support for off-screen rendering and secondary screen buffers
- **DMA Screen Clearing**: Ultra-fast screen clearing using Spectrum Next DMA controller (99% faster)
- **Z80N Enhanced Screen Operations**: LDIRX optimization for 33% faster screen clearing on Next hardware
- **Hardware Detection**: Automatic detection of Z80N and DMA capabilities with graceful fallbacks
- **Memory Fill Operations**: Complete DMA memory fill routines with burst mode support
- **Utility Functions**: Enhanced utility library with Z80N detection and DMA availability checking
- **Performance Optimization**: Comprehensive T-States analysis and optimization across all screen operations

Screen clearing performance improvements:
- **Standard Z80**: Up to 74% faster with stack-based optimizations
- **Z80N LDIRX**: Additional 33% improvement using extended opcodes  
- **DMA Fill**: 99.7% faster pixel clearing, 99.2% faster attribute setting
- **DMA Burst**: 99.8% faster with maximum hardware acceleration

**v1.5** - Enhanced Test Framework and Maintainability

Key improvements:
- **Streamlined Test Framework**: Replaced repetitive test execution code with elegant table-driven loop system
- **Simplified Test Management**: Adding new tests now requires only 3 simple steps: create TestCase0nn routine, add to table, update counter
- **Reduced Code Complexity**: Test execution code reduced from ~240 lines to ~80 lines (70% reduction)
- **Improved Maintainability**: Single point of control for test count and execution flow
- **Enhanced Reliability**: Proper stack management and flag preservation throughout test execution
- **Developer Experience**: Much easier to add, modify, or debug individual test cases
- **Code Quality**: Eliminated copy-paste errors and inconsistencies in test execution flow

**v1.4** - Enhanced 16-bit Random Operations with Z80N Support

Key improvements:
- **57 Test Cases**: Expanded test suite from 53 to 57 comprehensive test cases
- **16-bit Random Algorithms**: Complete suite of 16-bit random number generators (LFSR, XOR Shift, Middle Square) with both standard Z80 and Z80N optimized versions
- **Z80N 16-bit Random Performance**: 33-38% faster 16-bit random generation using MUL instruction
- **Hardware-Accelerated 16-bit Random**: Single-cycle multiplication for enhanced Middle Square, optimized bit operations for LFSR/XOR Shift
- **Seed Compatibility**: Z80N 16-bit random versions maintain identical output sequences to standard algorithms
- **Complete T-state Analysis**: Accurate performance benchmarks for all random number generation routines

**v1.3** - Enhanced Random 8-bit Operations with Z80N Support

Key improvements:
- **53 Test Cases**: Expanded test suite from 43 to 53 comprehensive test cases
- **8-bit Random Algorithms**: Four standard Z80 algorithms (LCG, LFSR, XOR Shift, Middle Square) plus four Z80N optimized versions
- **Z80N 8-bit Random Performance**: 20-47% faster random generation using MUL instruction
- **Hardware-Accelerated Random**: Single-cycle multiplication for LCG, optimized bit operations for LFSR/XorShift/MiddleSquare
- **Seed Compatibility**: Z80N random versions maintain identical output sequences to standard algorithms

**v1.2** - Enhanced Division Operations with Z80N Support

Key improvements:
- **50 Test Cases**: Expanded test suite from 43 to 50 comprehensive test cases
- **Enhanced 8÷8 Division**: Three Z80N options (COMPACT hybrid, BALANCED 8-bit reciprocal, MAXIMUM 16-bit reciprocal)
- **Enhanced 16÷8 Division**: Three Z80N options with hybrid algorithms and high-precision reciprocal methods
- **Accuracy Validation**: All algorithms pass comprehensive test validation ensuring mathematical correctness
- **Performance Optimization**: Up to 95% faster division on Spectrum Next hardware
- **Algorithm Selection**: Intelligent hybrid approaches combining traditional and reciprocal methods for optimal speed/precision balance

Three primary Z80N division approaches are provided:
1. **Hybrid routines**: Combination of MUL DE and traditional subtraction for optimal convergence  
2. **8-bit Reciprocal methods**: Pre-computed reciprocal tables using Z80N MUL for maximum speed with validated precision
2. **16-bit Reciprocal methods**: Pre-computed 16-bit reciprocal tables providing the highest precision over 8-bit reciprocals

## Target Platforms

The following platforms are targetted. The main entry points and individual functionality are tagged with @COMPAT: 48K,128K,+2,+3,NEXT - where the list shown is the known compatability of the routine. I also detail below the main differences of the platforms which will give rise to the compatability of the routines. This means NEXT only routines will be tagged with just @COMPAT: NEXT, and if Z80N op codes are present, then @Z80N: MUL DE, ... will be documented as to which extended op codes are being used.

### ZX SPECTRUM 48K:
- CPU: Z80 @ 3.5MHz
- Memory: 48KB RAM
- Features: Basic ULA, beeper sound
- Limitations: No extra RAM banks, no AY sound

### ZX SPECTRUM 128K:
- CPU: Z80 @ 3.5MHz  
- Memory: 128KB RAM (banked)
- Features: AY-3-8912 sound chip, extra RAM banks
- New: Memory paging, enhanced sound

### ZX SPECTRUM +2:
- CPU: Z80 @ 3.5MHz
- Memory: 128KB RAM (banked) 
- Features: Built-in tape deck, AY sound
- Differences: Different ROM, tape interface

### ZX SPECTRUM +3:
- CPU: Z80 @ 3.5MHz
- Memory: 128KB RAM (banked)
- Features: Built-in disk drive, +2A/+3 ROM
- New: Disk interface, different memory map

### ZX SPECTRUM NEXT:
- CPU: Z80N @ 3.5/7/14/28MHz
- Memory: 1MB+ RAM, advanced banking
- Features: Enhanced graphics, sprites, DMA
- New: Z80N extended opcodes, copper, DMA controller

## 🚀 **Current Features**

### 📊 **Mathematical Operations**
- **8×8 Unsigned Multiplication**: Six performance levels (10-160 T-states)
  - Standard Z80: COMPACT, BALANCED, MAXIMUM (35-160 T-states)
  - Next Z80N: NEXT_COMPACT, NEXT_BALANCED, NEXT_MAXIMUM (10-29 T-states)
- **16×8 Unsigned Multiplication**: Six performance levels (45-380 T-states)
  - Standard Z80: COMPACT, BALANCED, MAXIMUM (45-380 T-states)
  - Next Z80N: NEXT_COMPACT, NEXT_BALANCED, NEXT_MAXIMUM (97 T-states)
- **8÷8 Unsigned Division**: Six performance levels (25-1975 T-states)
  - Standard Z80: COMPACT, BALANCED, MAXIMUM (25-1975 T-states)
  - Next Z80N: NEXT_COMPACT (40-400 T-states hybrid - subtraction <128, 8-bit reciprocal ≥128)
  - Next Z80N: NEXT_BALANCED (~175 T-states 8-bit reciprocal table - accuracy +/- 1)
  - Next Z80N: NEXT_MAXIMUM (~218 T-states 16-bit reciprocal table - maximum precision)
- **16÷8 Unsigned Division**: High-precision 16-bit division with Z80N support
  - Standard Z80: COMPACT, BALANCED, MAXIMUM (45-1300 T-states)
  - Next Z80N: NEXT_COMPACT (~118-500 T-states hybrid - subtraction <128, 8-bit reciprocal ≥128)
  - Next Z80N: NEXT_BALANCED (~118-500 T-states 8-bit reciprocal table - accuracy +/- 1)
  - Next Z80N: NEXT_MAXIMUM (~107-520 T-states 16-bit reciprocal table - maximum precision)

### 🖥️ **Screen Management**
- **Flexible Screen Clearing**: Support for standard screen and custom memory locations
  - Parameterized addressing: HL parameter specifies screen base address (0 = default 16384)
  - In-memory screen support: Full support for off-screen rendering capabilities
  - Secondary screen buffers: Support for double-buffering and screen composition
- **Performance Levels**: Nine optimization levels from basic to DMA-accelerated
  - **SCREEN_COMPACT**: Standard LDIR operation (145,265 T-states full reset)
  - **SCREEN_Z80N_COMPACT**: Z80N LDIRX optimization (96,700 T-states, 33% faster)
  - **SCREEN_1PUSH to SCREEN_ALLPUSH**: Stack-based optimizations (91,910 to 40,344 T-states)
  - **SCREEN_DMA_FILL**: DMA memory fill (400 T-states, 99.7% faster)
  - **SCREEN_DMA_BURST**: DMA burst mode (260 T-states, 99.8% faster)
- **Hardware Detection**: Automatic Z80N and DMA detection with graceful fallbacks

### 🎨 **Layer 2 Graphics (Spectrum Next)**
- **Layer 2 Detection**: Hardware detection and active Layer 2 identification
  - CheckForActiveLayer2: Z80N and Layer 2 availability checking (109-157 T-states)
  - GetActiveLayer2Addr: Active Layer 2 base address retrieval (83-87 T-states)
  - GetLayer2FullInfo: Complete Layer 2 configuration detection (varies by resolution)
- **Layer 2 Screen Clearing**: Ultra-fast Layer 2 clearing with DMA acceleration
  - Support for all Layer 2 resolutions: 256×192 (48KB), 320×256 (80KB), 640×256 (160KB)
  - DMA-optimized clearing with automatic chunking for 16-bit operations
  - Hardware detection with graceful fallbacks to standard operations
- **Layer 2 Information Retrieval**: Comprehensive Layer 2 status and configuration
  - Resolution detection: 256×192, 320×256, 640×256 modes
  - Color depth identification: 4bpp (16 colors) or 8bpp (256 colors)
  - Memory requirements calculation and address management

### 🎲 **Random Number Generation**
- **8-bit Random**: Eight different algorithms with standard Z80 and Z80N optimized versions
  - Standard Z80: LCG (~45-55 T-states), LFSR (~85-95 T-states), XorShift (~35-45 T-states), Middle Square (~115-150 T-states)
  - Next Z80N: LCG (~25-35 T-states), LFSR (~45-55 T-states), XorShift (~20-30 T-states), Middle Square (~65-75 T-states)
- **16-bit Random**: Six different algorithms with standard Z80 and Z80N optimized versions
  - Standard Z80: LCG (~85-95 T-states), LFSR (~68 T-states), XorShift (~55 T-states), Middle Square (~78 T-states)
  - Next Z80N: LCG (~55-65 T-states), LFSR (~42 T-states), XorShift (~35 T-states), Middle Square (~48 T-states)

### 🔧 **Utility Functions**
- **Hardware Detection**: Z80N processor detection (60-81 T-states)
- **DMA Detection**: DMA controller availability checking (58-66 T-states)
- **Memory Operations**: DMA-accelerated memory fill and burst operations

### ⚡ **DMA Support (Spectrum Next)**
- **DMA Memory Fill**: High-speed memory filling using DMA controller
  - CPU overhead: ~240-260 T-states for setup
  - Hardware transfer: Parallel to CPU execution
  - Automatic fallback to standard routines if DMA unavailable
- **DMA Burst Fill**: Maximum performance burst mode operations
  - CPU overhead: ~235-250 T-states for setup
  - Fastest possible memory operations on Next hardware
  - Optimized wait loops with comprehensive status checking

### Screen Clearing T-States Performance

| Performance Level | Pixel Clear | Attr Clear | Full Reset | Platform | Improvement |
|-------------------|-------------|------------|------------|----------|-------------|
| **SCREEN_COMPACT** | 129,074 T | 16,191 T | 145,265 T | All | Baseline |
| **SCREEN_Z80N_COMPACT** | 86,000 T | 10,700 T | 96,700 T | Next | 33% faster |
| **SCREEN_1PUSH** | 81,640 T | 10,270 T | 91,910 T | All | 37% faster |
| **SCREEN_2PUSH** | 61,476 T | 7,702 T | 69,178 T | All | 52% faster |
| **SCREEN_3PUSH** | 51,236 T | 6,412 T | 57,648 T | All | 60% faster |
| **SCREEN_4PUSH** | 43,908 T | 5,508 T | 49,416 T | All | 66% faster |
| **SCREEN_ALLPUSH** | 35,844 T | 4,500 T | 40,344 T | All | 72% faster |
| **SCREEN_DMA_FILL** | 280 T | 120 T | 400 T | Next | 99.7% faster |
| **SCREEN_DMA_BURST** | 180 T | 80 T | 260 T | Next | 99.8% faster |

### Layer 2 Utility T-States

| Function | Scenario | T-States | Description |
|----------|----------|----------|-------------|
| **CheckForActiveLayer2** | Next Not Found | 109 | Z80N detection fails |
| **CheckForActiveLayer2** | Layer 2 Inactive | 151 | Z80N found, Layer 2 disabled |
| **CheckForActiveLayer2** | Layer 2 Active | 157 | Z80N found, Layer 2 enabled |
| **GetActiveLayer2Addr** | No Layer 2 | 87 | Returns HL = 0 |
| **GetActiveLayer2Addr** | Active Layer 2 | 83 | Returns Layer 2 base address |
| **GetLayer2FullInfo** | Variable | 200-300+ | Complete configuration retrieval |

### Layer 2 Constants

```asm
; Layer 2 Memory Requirements
LAYER2_BYTES_256x192         EQU     $C000   ; 49,152 bytes (48KB) - 256×192 mode
LAYER2_BYTES_320x256         EQU     $14000  ; 81,920 bytes (80KB) - 320×256 mode  
LAYER2_BYTES_640x256         EQU     $28000  ; 163,840 bytes (160KB) - 640×256 mode
LAYER2_BYTES_320x256_HALF    EQU     $A000   ; 40,960 bytes (40KB) - Half for 16-bit DMA

; Layer 2 Resolutions
LAYER2_RESOLUTION_256x192    EQU     0       ; Standard Layer 2 resolution
LAYER2_RESOLUTION_320x256    EQU     1       ; Enhanced Layer 2 resolution
LAYER2_RESOLUTION_640x256    EQU     2       ; Maximum Layer 2 resolution

; Layer 2 Performance Levels
SCREEN_LAYER2_DMA_FILL       EQU     9       ; Layer 2 DMA fill mode
SCREEN_LAYER2_DMA_BURST      EQU     10      ; Layer 2 DMA burst mode

### Random Generation T-States

| Algorithm | 8-bit Standard | 8-bit Z80N | 16-bit Standard | 16-bit Z80N | Improvement |
|-----------|----------------|------------|-----------------|-------------|-------------|
| **LCG** | 45-55 | 25-35 | 85-95 | 55-65 | 30-35% faster |
| **LFSR** | 85-95 | 45-55 | 68 | 42 | 38-47% faster |
| **XorShift** | 35-45 | 20-30 | 55 | 35 | 36-43% faster |
| **Middle Square** | 115-150 | 65-75 | 78 | 48 | 33-43% faster |

#### Random Algorithm Constants

```asm
; 8-bit Standard Z80 Random Algorithms
PERFORMANCE_STANDARD_RANDOM_LCG       EQU 0    ; Linear Congruential Generator (45-55 T-states)
PERFORMANCE_STANDARD_RANDOM_LFSR      EQU 1    ; Linear Feedback Shift Register (85-95 T-states)
PERFORMANCE_STANDARD_RANDOM_XORSHIFT  EQU 2    ; XorShift Algorithm (35-45 T-states)
PERFORMANCE_STANDARD_RANDOM_MIDDLESQUARE EQU 3 ; Middle Square Method (115-150 T-states)

; 8-bit Next Z80N Random Algorithms  
PERFORMANCE_Z80N_RANDOM_LCG           EQU 4    ; Z80N optimized LCG (25-35 T-states)
PERFORMANCE_Z80N_RANDOM_LFSR          EQU 5    ; Z80N optimized LFSR (45-55 T-states)
PERFORMANCE_Z80N_RANDOM_XORSHIFT      EQU 6    ; Z80N optimized XorShift (20-30 T-states)
PERFORMANCE_Z80N_RANDOM_MIDDLESQUARE  EQU 7    ; Z80N optimized Middle Square (65-75 T-states)

; 16-bit Standard Z80 Random Algorithms
PERFORMANCE_STANDARD_RANDOM16_LCG      EQU 0   ; Linear Congruential Generator (85-95 T-states)
PERFORMANCE_STANDARD_RANDOM16_LFSR     EQU 1   ; Linear Feedback Shift Register (68 T-states)
PERFORMANCE_STANDARD_RANDOM16_XORSHIFT EQU 2   ; XorShift Algorithm (55 T-states)
PERFORMANCE_STANDARD_RANDOM16_MIDDLESQUARE EQU 3 ; Middle Square Method (78 T-states)

; 16-bit Next Z80N Random Algorithms
PERFORMANCE_Z80N_RANDOM16_LCG          EQU 4   ; Z80N optimized 16-bit LCG (55-65 T-states)
PERFORMANCE_Z80N_RANDOM16_LFSR         EQU 5   ; Z80N optimized 16-bit LFSR (42 T-states)
PERFORMANCE_Z80N_RANDOM16_XORSHIFT     EQU 6   ; Z80N optimized 16-bit XorShift (35 T-states)
PERFORMANCE_Z80N_RANDOM16_MIDDLESQUARE EQU 7   ; Z80N optimized 16-bit Middle Square (48 T-states)
```

### Utility Functions T-States

| Function | Available Path | Not Available Path | Description |
|----------|---------------|-------------------|-------------|
| **CheckOnZ80N** | 81 T-states | 60 T-states | Z80N processor detection |
| **CheckDMAAvailable** | 66 T-states | 58 T-states | DMA controller detection |

### DMA Operations T-States

| Operation | CPU Overhead | Hardware Time | Total Benefit |
|-----------|-------------|---------------|---------------|
| **DMA_MemoryFill** | ~240-260 T | Parallel | 99%+ faster |
| **DMA_BurstFill** | ~235-250 T | Parallel | 99%+ faster |

## 🧮 **Random Number Generation Algorithms**

NextLibrary provides comprehensive 8-bit and 16-bit random number generation algorithms optimized for different scenarios:

### 8-bit Standard Z80 Methods
- **LCG (Linear Congruential Generator)**: Fast with good uniformity (45-55 T-states)
  - Best for: High-speed applications requiring uniform distribution
  - Uses: Multiply-add formula (a*seed + c) mod m
  - Quality: Good distribution, very fast, widely used in games

- **LFSR (Linear Feedback Shift Register)**: High-quality randomness (85-95 T-states)
  - Best for: Cryptographic applications, high-quality sequences
  - Uses: Bit shifting with XOR feedback polynomial
  - Quality: Excellent distribution, maximum period (255 values)

- **XorShift**: Fast with good quality (35-45 T-states)
  - Best for: Games requiring fast, good-quality random numbers
  - Uses: XOR and bit shifting operations
  - Quality: Very good distribution, fast execution

- **Middle Square**: Classic algorithm with moderate speed (115-150 T-states)
  - Best for: Educational purposes, moderate quality needs
  - Uses: Squares the seed and extracts middle digits
  - Quality: Fair distribution, requires careful seed management

### 8-bit Next Z80N Methods (Spectrum Next Only)
- **Z80N_LCG**: Hardware-accelerated LCG (25-35 T-states)
  - Best for: Ultra-fast uniform random generation
  - Uses: Z80N MUL for single-cycle multiplication in LCG formula
  - Quality: Same as standard LCG, 35% faster execution

- **Z80N_LFSR**: Z80N optimized LFSR (45-55 T-states)
  - Best for: High-quality randomness with hardware acceleration
  - Uses: Z80N MUL for efficient bit extraction and manipulation
  - Quality: Same as standard LFSR, 47% faster execution

- **Z80N_XorShift**: Ultra-fast XorShift (20-30 T-states)
  - Best for: Fastest possible random generation with good quality
  - Uses: Z80N MUL for optimized bit operations
  - Quality: Same as standard XorShift, 43% faster execution

- **Z80N_MiddleSquare**: Hardware-accelerated Middle Square (65-75 T-states)
  - Best for: Classic algorithm with modern performance
  - Uses: Z80N MUL for single-cycle squaring operation
  - Quality: Same as standard Middle Square, 43% faster execution

### 16-bit Standard Z80 Methods
- **LCG (Linear Congruential Generator)**: Fast 16-bit uniform generation (85-95 T-states)
  - Best for: High-speed 16-bit applications requiring uniform distribution
  - Uses: Extended 16-bit multiply-add formula
  - Quality: Good distribution, fastest 16-bit method, widely used

- **LFSR (Linear Feedback Shift Register)**: High-quality 16-bit randomness (68 T-states)
  - Best for: High-quality sequences with extended precision
  - Uses: 16-bit polynomial feedback with bit manipulation
  - Quality: Excellent distribution, maximum period (65535 values)

- **XorShift**: Fast 16-bit generation (55 T-states)
  - Best for: Fast 16-bit random numbers with good quality
  - Uses: Extended XOR and bit shifting operations
  - Quality: Very good distribution, optimal speed/quality balance

- **Middle Square**: 16-bit classic algorithm (78 T-states)
  - Best for: Extended precision middle square method
  - Uses: 16-bit squaring with middle extraction
  - Quality: Good distribution with careful seed management

### 16-bit Next Z80N Methods (Spectrum Next Only)
- **Z80N_LCG**: Hardware-accelerated 16-bit LCG (55-65 T-states)
  - Best for: Ultra-fast 16-bit uniform random generation
  - Uses: Z80N MUL for efficient 16-bit LCG calculations
  - Quality: Same as standard 16-bit LCG, 30% faster execution

- **Z80N_LFSR**: Z80N optimized 16-bit LFSR (42 T-states)
  - Best for: High-quality 16-bit randomness with hardware acceleration
  - Uses: Z80N MUL for efficient 16-bit polynomial operations
  - Quality: Same as standard 16-bit LFSR, 38% faster execution

- **Z80N_XorShift**: Ultra-fast 16-bit XorShift (35 T-states)
  - Best for: Fastest possible 16-bit random generation
  - Uses: Z80N MUL for optimized 16-bit bit operations
  - Quality: Same as standard 16-bit XorShift, 36% faster execution

- **Z80N_MiddleSquare**: Hardware-accelerated 16-bit Middle Square (48 T-states)
  - Best for: 16-bit classic algorithm with modern performance
  - Uses: Z80N MUL for single-cycle 16-bit squaring operation
  - Quality: Same as standard 16-bit Middle Square, 38% faster execution

### Z80N Performance Benefits

The Z80N optimized versions provide significant performance improvements:

- **Hardware Multiplication**: Single-cycle MUL instruction vs multi-cycle addition loops
- **Efficient Bit Operations**: MUL-based bit extraction vs traditional shifting
- **Maintained Quality**: Identical mathematical properties and output sequences
- **Same Seed Compatibility**: Drop-in replacements for standard versions

**Performance Summary**: Z80N random generators are 30-47% faster while maintaining identical output quality and seed compatibility with their standard Z80 counterparts.

## 📝 **TODO List**

### 🖥️ **Display & Graphics**
- Screen copy utilities and in-memory second screen management
- Extended screen manipulation functions, e.g. line draw, fill, patterned fill
- Layer 2 screen support and enhanced graphics modes

### 🎮 **Input Systems**  
- Joystick input support with multiple controller options
- Enhanced text input utilities and keyboard handling

### 🏆 **Scoring & Data**
- Extended scoring system supporting up to 12-digit scores (beyond 65535)
- Leaderboard and score table management utilities

### 🔊 **Audio Support**
- Beeper sound utilities (tags likely to be @COMPAT: 48K,128K,+2,+3,NEXT)
- AY sound routines (tags likely to be @COMPAT: 128K,+2,+3,NEXT, @REQUIRES: AY-3-8912)

### 🏦 **Memory Banking**
- Memory bank switching and loading (tags likely to be @COMPAT: 128K,+2,+3,NEXT, @REQUIRES: Memory banking)

### 💾 **Loading and Saving**
- Tape routines (tags likely to be @COMPAT: 48K,128K,+2,+3,NEXT)
- Microdrive routines (tags likely to be @COMPAT: 48K,128K,+2,+3) - likely requires Next to be in a required compatibility mode with microdrive interface attached and active - not sure yet
- Disk routines (tags likely to be @COMPAT: +3, @REQUIRES: +3 disk interface) - potentially no Next compatibility as very hardware based

### 🚀 **Advanced Next Features**
*Tagged @COMPAT NEXT as they will be specific to the Next, this list is not exhaustive*
- Sprites (tags likely to be @COMPAT: NEXT, @REQUIRES: Next sprites)
- Copper (tags likely to be @COMPAT: NEXT, @REQUIRES: Next copper)  
- Enhanced DMA operations (pattern fills, memory copies, etc.)
- More features... (one thing added at a time)

### ⚡ **Optimization**
- Complete T-state optimization pass (e.g., replace JR with JP where beneficial)
- Memory usage optimization analysis

## 🎯 **Performance Levels**

NextLibrary uses a unified performance system across all mathematical operations:

| Performance Level | Characteristics | Use Case |
|-------------------|----------------|----------|
| **PERFORMANCE_COMPACT** | Variable timing, minimal code size | Memory-constrained applications |
| **PERFORMANCE_BALANCED** | Fixed timing, predictable performance | Real-time applications, games |
| **PERFORMANCE_MAXIMUM** | Optimized for speed, larger code size | Performance-critical operations |
| **PERFORMANCE_NEXT_COMPACT** | Z80N MUL instruction, fastest code | Next-only, maximum speed |
| **PERFORMANCE_NEXT_BALANCED** | Z80N MUL with overflow checking | Next-only, speed + validation |
| **PERFORMANCE_NEXT_MAXIMUM** | Z80N MUL with special case handling | Next-only, optimized edge cases |

### Screen Performance Levels

| Performance Level | Characteristics | T-States (Full Reset) | Platform |
|-------------------|----------------|----------------------|----------|
| **SCREEN_COMPACT** | Standard LDIR operation | 145,265 | All |
| **SCREEN_Z80N_COMPACT** | Z80N LDIRX optimization | 96,700 | Next |
| **SCREEN_1PUSH** | Stack-based, 2 pixels | 91,910 | All |
| **SCREEN_2PUSH** | Stack-based, 4 pixels | 69,178 | All |
| **SCREEN_3PUSH** | Stack-based, 6 pixels | 57,648 | All |
| **SCREEN_4PUSH** | Stack-based, 8 pixels | 49,416 | All |
| **SCREEN_ALLPUSH** | Stack-based, 12 pixels | 40,344 | All |
| **SCREEN_DMA_FILL** | DMA memory fill | 400 | Next |
| **SCREEN_DMA_BURST** | DMA burst mode | 260 | Next |

## 📋 **Quick Start**

### Basic Usage Example

```asm
; Include the NextLibrary
INCLUDE "NextLibrary.asm"

; 8×8 Multiplication Example (Standard Z80)
LD      A, 25           ; Multiplicand
LD      B, 12           ; Multiplier  
LD      C, PERFORMANCE_BALANCED
CALL    Multiply8x8_Unified
; Result in HL = 300

; 8×8 Multiplication Example (Next Z80N - Ultra Fast!)
LD      A, 25           ; Multiplicand
LD      B, 12           ; Multiplier
LD      C, PERFORMANCE_NEXT_COMPACT   ; Uses Z80N MUL instruction
CALL    Multiply8x8_Unified
; Result in HL = 300 (85% faster!)

; 8-bit Random Number Generation
LD      A, 15           ; Upper limit (inclusive)
LD      B, 123          ; Seed value
LD      C, PERFORMANCE_Z80N_RANDOM_LFSR ; Z80N LFSR algorithm
CALL    Random8_Unified_Seed
; First random value in A

LD      A, 7            ; New upper limit
LD      C, PERFORMANCE_Z80N_RANDOM_LFSR ; Same algorithm  
CALL    Random8_Unified_Next
; Next random value in A

; 16-bit Random Number Generation
LD      HL, 1000        ; Upper limit (inclusive)
LD      BC, 9876        ; Seed value
LD      D, PERFORMANCE_Z80N_RANDOM16_MIDDLESQUARE ; Z80N 16-bit Middle Square
CALL    Random16_Unified_Seed
; First random value in HL

LD      HL, 5000        ; New upper limit
LD      D, PERFORMANCE_Z80N_RANDOM16_MIDDLESQUARE ; Same algorithm
CALL    Random16_Unified_Next  
; Next random value in HL
```

### Enhanced Screen Management Examples

```asm
; Clear entire screen with white on black attributes (standard screen)
LD      A, %00000111    ; White ink, black paper
LD      C, SCREEN_4PUSH ; High performance mode
LD      HL, 0           ; Use default screen address (16384)
CALL    Screen_FullReset_Unified

; Clear off-screen buffer with different attributes
LD      A, %01000010    ; Green ink, black paper, bright
LD      C, SCREEN_DMA_FILL ; Ultra-fast DMA clearing (Next only)
LD      HL, $8000       ; Custom screen buffer address
CALL    Screen_FullReset_Unified

; Clear pixels only in secondary screen buffer
LD      A, 0            ; Not used for pixel clearing
LD      C, SCREEN_Z80N_COMPACT ; Z80N LDIRX optimization
LD      HL, $C000       ; Another screen buffer
CALL    Screen_ClearPixel_Unified

; Set attributes only in main screen, preserve pixels
LD      A, %01000010    ; Green ink, black paper, bright
LD      C, SCREEN_DMA_BURST ; Maximum DMA performance (Next only)
LD      HL, 0           ; Use default screen address
CALL    Screen_ClearAttr_Unified

; High-speed double buffering example
; Clear back buffer at maximum speed while displaying front buffer
LD      A, %00000111    ; White on black
LD      C, SCREEN_DMA_BURST ; Fastest possible
LD      HL, BackBuffer  ; Address of back buffer
CALL    Screen_FullReset_Unified
; ... render to back buffer ...
; ... swap buffers when ready ...

; Hardware detection example
CALL    CheckOnZ80N     ; Check if Z80N available
JR      Z, UseStandard  ; Use standard routines if not Z80N

CALL    CheckDMAAvailable ; Check if DMA available
JR      Z, Z80NOnly     ; Use Z80N only if no DMA

; Use DMA for maximum performance
LD      C, SCREEN_DMA_BURST
JR      ClearScreen

Z80NOnly:
LD      C, SCREEN_Z80N_COMPACT ; Use Z80N optimizations
JR      ClearScreen

UseStandard:
LD      C, SCREEN_ALLPUSH

ClearScreen:
LD      A, %00000111    ; Screen attribute
LD      HL, 0           ; Default screen
CALL    Screen_FullReset_Unified
```

### Layer 2 Graphics Examples

```asm
; Detect if Layer 2 is available and active
CALL    CheckForActiveLayer2    ; Check Layer 2 availability
JR      Z, NoLayer2            ; Jump if not available

; Get Layer 2 configuration
CALL    GetLayer2FullInfo      ; Get complete Layer 2 info
; Layer2Resolution now contains: 0=256×192, 1=320×256, 2=640×256
; Layer2Width/Height contain pixel dimensions
; Layer2Bpp contains color depth (4 or 8 bits per pixel)

; Clear Layer 2 screen with DMA acceleration
LD      A, $FF                 ; Fill color (white in 8bpp mode)
LD      C, SCREEN_LAYER2_DMA_BURST ; Maximum performance
CALL    GetActiveLayer2Addr    ; Get Layer 2 address in HL
CALL    Screen_Layer2Clear_Unified ; Clear Layer 2 screen

; Double buffering example
CALL    GetActiveLayer2Addr    ; Get current display buffer
LD      (DisplayBuffer), HL    ; Store display buffer
LD      HL, BackBuffer         ; Set back buffer address
; ... render to back buffer ...
; ... swap buffers when ready ...

NoLayer2:
; Fall back to standard ULA screen operations
LD      HL, 0                  ; Use standard screen
LD      A, $07                 ; White on black
LD      C, SCREEN_DMA_BURST    ; Use DMA if available
CALL    Screen_FullReset_Unified
```

### DMA Memory Operations

```asm
; Fill large memory area using DMA
LD      HL, $8000       ; Destination address
LD      A, $FF          ; Fill pattern
LD      BC, 16384       ; Size (16KB)
CALL    DMA_MemoryFill  ; ~240 T-states CPU + hardware time

; Ultra-fast burst fill
LD      HL, $C000       ; Destination
LD      A, $00          ; Clear pattern
LD      BC, 8192        ; Size (8KB)
LD      D, $FF          ; Burst mode flag
CALL    DMA_BurstFill   ; ~235 T-states CPU + hardware time
```

### Hardware Detection Utilities

```asm
; Check what hardware is available and select optimal routines
CALL    CheckOnZ80N     ; Returns NZ if Z80N available
JR      Z, StandardZ80  ; Jump if not Z80N

; Z80N detected - check for DMA
CALL    CheckDMAAvailable ; Returns NZ if DMA available
JR      Z, Z80NOnly     ; Jump if no DMA

; Full Next hardware available
LD      C, SCREEN_DMA_BURST ; Use maximum performance
JR      PerformOperation

Z80NOnly:
LD      C, SCREEN_Z80N_COMPACT ; Use Z80N optimizations
JR      PerformOperation

StandardZ80:
LD      C, SCREEN_ALLPUSH

PerformOperation:
LD      A, %00000111    ; Screen attribute
LD      HL, 0           ; Default screen
CALL    Screen_FullReset_Unified
```

## ⚡ **Z80N Performance Comparison**

### 8×8 Multiplication Performance

| Performance Level | T-States | Platform | Description |
|------------------|----------|----------|-------------|
| **PERFORMANCE_COMPACT** | 35-75 | All | Variable timing, compact code |
| **PERFORMANCE_BALANCED** | ~160 | All | Fixed timing, predictable |
| **PERFORMANCE_MAXIMUM** | ~120 | All | Optimized for speed |
| **PERFORMANCE_NEXT_COMPACT** | ~14 | Next | Z80N MUL instruction |
| **PERFORMANCE_NEXT_BALANCED** | ~29 | Next | Z80N MUL + overflow check |
| **PERFORMANCE_NEXT_MAXIMUM** | ~20 | Next | Z80N MUL + special cases |

**Performance Improvement**: Up to **85% faster** on Spectrum Next!

### 16×8 Multiplication Performance

| Performance Level | T-States | Platform | Description |
|------------------|----------|----------|-------------|
| **PERFORMANCE_COMPACT** | 45-380 | All | Variable timing, compact code |
| **PERFORMANCE_BALANCED** | ~180 | All | Fixed timing, predictable |
| **PERFORMANCE_MAXIMUM** | ~140 | All | Optimized for speed |
| **PERFORMANCE_NEXT_COMPACT** | ~97 | Next | Z80N MUL instruction |
| **PERFORMANCE_NEXT_BALANCED** | ~97 | Next | Z80N MUL + same algorithm |
| **PERFORMANCE_NEXT_MAXIMUM** | ~97 | Next | Z80N MUL + same algorithm |

**Performance Improvement**: Up to **75% faster** on Spectrum Next for balanced/maximum modes!

### 8÷8 Division Performance

| Performance Level | T-States | Platform | Description |
|------------------|----------|----------|-------------|
| **PERFORMANCE_COMPACT** | 25-1950 | All | Variable timing, compact subtraction |
| **PERFORMANCE_BALANCED** | 30-1975 | All | Similar to compact, different registers |
| **PERFORMANCE_MAXIMUM** | 40-1000 | All | Optimized with 2× acceleration |
| **PERFORMANCE_NEXT_COMPACT** | 40-400 | Next | Z80N MUL hybrid method |
| **PERFORMANCE_NEXT_BALANCED** | ~175 | Next | Z80N MUL 8-bit reciprocal table |
| **PERFORMANCE_NEXT_MAXIMUM** | ~218 | Next | Z80N MUL 16-bit reciprocal table |

**Performance Improvement**: Up to **90% faster** on Spectrum Next!  
**✅ Accuracy Note**: NEXT_COMPACT and NEXT_MAXIMUM provide exact mathematical results. NEXT_BALANCED uses 8-bit reciprocal for speed with minor accuracy trade-offs only for edge cases. NEXT_MAXIMUM uses 16-bit reciprocal for maximum precision. All algorithms pass comprehensive test validation.

### 16÷8 Division Performance

| Performance Level | T-States | Platform | Description |
|------------------|----------|----------|-------------|
| **PERFORMANCE_COMPACT** | 45-1300 | All | Variable subtraction, worst case 65535÷1 |
| **PERFORMANCE_BALANCED** | 220-280 | All | Fixed binary long division, consistent timing |
| **PERFORMANCE_MAXIMUM** | 180-420 | All | Optimized binary division with early exits |
| **PERFORMANCE_NEXT_COMPACT** | 118-500 | Next | Z80N hybrid: 8×8 for H=0, traditional for larger |
| **PERFORMANCE_NEXT_BALANCED** | 118-500 | Next | Uses 8-bit reciprocal table, some precision tradeoff |
| **PERFORMANCE_NEXT_MAXIMUM** | 107-520 | Next | Use 16-bit reciprocal table, high precision |

**Algorithm Selection (NEXT_COMPACT/BALANCED)**:
- **H=0** (dividend ≤255): Uses Z80N 8×8 hybrid division
- **H=1-15** (256-4095): Uses traditional balanced division  
- **H≥16** (4096+): Uses traditional maximum division

**Algorithm Selection (NEXT_MAXIMUM)**:
- **H=0 and L<B**: Direct return with quotient=0, remainder=L
- **H=0 and L≥B**: Uses Z80N 8×8 16-bit reciprocal division for maximum precision
- **H≠0**: Uses traditional maximum division algorithm

**Performance Improvement**: Up to **65% faster** for small dividends on Spectrum Next!  

### Screen Clearing Performance

| Performance Level | Full Reset T-States | Platform | Improvement |
|------------------|-------------------|----------|-------------|
| **SCREEN_COMPACT** | 145,265 | All | Baseline |
| **SCREEN_Z80N_COMPACT** | 96,700 | Next | 33% faster |
| **SCREEN_ALLPUSH** | 40,344 | All | 72% faster |
| **SCREEN_DMA_FILL** | 400 | Next | 99.7% faster |
| **SCREEN_DMA_BURST** | 260 | Next | 99.8% faster |

**DMA Performance Notes**:
- T-States shown are CPU overhead only
- Actual memory transfer happens in hardware parallel to CPU
- DMA provides dramatic speed improvements for large memory operations
- Automatic fallback to standard routines if DMA unavailable

### 16-bit Operations

```asm
; 16×8 Multiplication (Standard Z80)
LD      HL, 1000        ; 16-bit multiplicand
LD      B, 50           ; 8-bit multiplier
LD      C, PERFORMANCE_MAXIMUM
CALL    Multiply16x8_Unified
; Result in DE:HL = 50000

; 16×8 Multiplication (Next Z80N - Ultra Fast!)
LD      HL, 1000        ; 16-bit multiplicand  
LD      B, 50           ; 8-bit multiplier
LD      C, PERFORMANCE_NEXT_COMPACT   ; Uses Z80N MUL instruction
CALL    Multiply16x8_Unified
; Result in DE:HL = 50000 (75% faster!)

; 16÷8 Division (Standard Z80)
LD      HL, 1234        ; 16-bit dividend
LD      B, 10           ; 8-bit divisor
LD      C, PERFORMANCE_BALANCED
CALL    Divide16x8_Unified
; Quotient in HL = 123, remainder in A = 4

; 16÷8 Division (Next Z80N - Hybrid Method)
LD      HL, 5000        ; 16-bit dividend
LD      B, 25           ; 8-bit divisor
LD      C, PERFORMANCE_NEXT_COMPACT   ; Uses Z80N hybrid algorithm
CALL    Divide16x8_Unified
; Quotient in HL = 200, remainder in A = 0 (65% faster for H≥16!)
```

## 🔧 **API Reference**

### Mathematical Operations

#### Multiplication
- `Multiply8x8_Unified` - 8×8 bit unsigned multiplication
  - Standard Z80: COMPACT/BALANCED/MAXIMUM (35-160 T-states)
  - Next Z80N: NEXT_COMPACT/NEXT_BALANCED/NEXT_MAXIMUM (10-29 T-states)
- `Multiply16x8_Unified` - 16×8 bit unsigned multiplication
  - Standard Z80: COMPACT/BALANCED/MAXIMUM (45-380 T-states)
  - Next Z80N: NEXT_COMPACT/NEXT_BALANCED/NEXT_MAXIMUM (97 T-states)

**Input**: A/HL = multiplicand, B = multiplier, C = performance level  
**Output**: HL = result (8×8), DE:HL = result (16×8)  
**Z80N Performance**: Up to 85% faster (8×8) and 75% faster (16×8) on Spectrum Next

#### Division
- `Divide8x8_Unified` - 8÷8 bit unsigned division
  - Standard Z80: COMPACT/BALANCED/MAXIMUM (25-1975 T-states)
  - Next Z80N: NEXT_COMPACT (40-400 T-states hybrid - subtraction <128, 8-bit reciprocal ≥128)
  - Next Z80N: NEXT_BALANCED (~175 T-states 8-bit reciprocal table)
  - Next Z80N: NEXT_MAXIMUM (~175 T-states currently fallback to 8-bit reciprocal)
- `Divide16x8_Unified` - 16÷8 bit unsigned division
  - Standard Z80: COMPACT/BALANCED/MAXIMUM (45-1300 T-states)
  - Next Z80N: NEXT_COMPACT/NEXT_BALANCED (118-500 T-states hybrid method)
  - Next Z80N: NEXT_MAXIMUM (107-520 T-states reciprocal with fallback)

**Input**: A/HL = dividend, B = divisor, C = performance level  
**Output**: A/HL = quotient, A/B = remainder  
**Z80N Performance**: Up to 95% faster (8÷8), 65% faster (16÷8) on Spectrum Next  
**✅ Accuracy Note**: All division algorithms pass comprehensive test validation. Reciprocal methods use optimized approximation with validated accuracy for typical use cases.

### Random Number Generation

#### 8-bit Random
- `Random8_Unified_Seed` - Initialize 8-bit random seed and generate first value
- `Random8_Unified_Next` - Generate subsequent 8-bit random numbers

**Input**: A = upper limit (inclusive), B = seed (seeding only), C = algorithm selection  
**Output**: A = random value in range [0, limit]

#### 16-bit Random  
- `Random16_Unified_Seed` - Initialize 16-bit random seed and generate first value
- `Random16_Unified_Next` - Generate subsequent 16-bit random numbers

**Input**: HL = upper limit (inclusive), BC = seed (seeding only), D = algorithm selection  
**Output**: HL = random value in range [0, limit]

### Screen Management

#### Unified Screen Clearing with Flexible Addressing
- `Screen_FullReset_Unified` - Clear pixels and set attributes
- `Screen_ClearPixel_Unified` - Clear pixels only, preserve attributes  
- `Screen_ClearAttr_Unified` - Set attributes only, preserve pixels

**Input**: 
- A = attribute value (for full reset and attribute operations)
- C = performance level
- HL = screen base address (0 = use default 16384, other values = custom address)

**Output**: Screen cleared according to specified operation

**Enhanced Features**:
- **Flexible Addressing**: Support for any memory location as screen buffer
- **Off-Screen Rendering**: Full support for secondary screen buffers
- **Double Buffering**: Enable smooth animations with back-buffer rendering
- **Memory Conservation**: Efficient in-memory screen composition

**Performance Levels**:
- **SCREEN_COMPACT**: Standard LDIR operation (baseline, ~145,265 T-states)
- **SCREEN_Z80N_COMPACT**: Z80N LDIRX optimization (33% faster, ~96,700 T-states)
- **SCREEN_1PUSH to SCREEN_ALLPUSH**: Stack-based optimizations (37-72% faster)
- **SCREEN_DMA_FILL**: DMA memory fill (99.7% faster, ~400 T-states CPU)
- **SCREEN_DMA_BURST**: DMA burst mode (99.8% faster, ~260 T-states CPU)

### Hardware Detection

#### Utility Functions
- `CheckOnZ80N` - Detect Z80N processor availability
- `CheckDMAAvailable` - Detect DMA controller availability

**Input**: None  
**Output**: Z flag set if feature not available, NZ if available  
**Performance**: 58-81 T-states depending on feature and availability

### DMA Operations (Spectrum Next Only)

#### Memory Fill Operations
- `DMA_MemoryFill` - DMA-accelerated memory fill
- `DMA_BurstFill` - DMA burst mode memory fill

**Input**: HL = destination address, A = fill byte, BC = byte count, D = burst mode (BurstFill only)  
**Output**: Memory filled via DMA controller  
**Performance**: ~235-260 T-states CPU overhead + parallel hardware transfer

### Algorithm Constants

```asm
; Performance Levels (Standard Z80)
PERFORMANCE_COMPACT        EQU 0
PERFORMANCE_BALANCED       EQU 1  
PERFORMANCE_MAXIMUM        EQU 2

; Performance Levels (Next Z80N)
PERFORMANCE_NEXT_COMPACT   EQU 3
PERFORMANCE_NEXT_BALANCED  EQU 4
PERFORMANCE_NEXT_MAXIMUM   EQU 5

; Screen Performance Levels
SCREEN_COMPACT             EQU 0    ; Standard LDIR operation
SCREEN_Z80N_COMPACT        EQU 6    ; Z80N LDIRX optimization  
SCREEN_1PUSH               EQU 1    ; 2 pixels simultaneously  
SCREEN_2PUSH               EQU 2    ; 4 pixels simultaneously
SCREEN_3PUSH               EQU 3    ; 6 pixels simultaneously
SCREEN_4PUSH               EQU 4    ; 8 pixels simultaneously
SCREEN_ALLPUSH             EQU 5    ; 12 pixels simultaneously
SCREEN_DMA_FILL            EQU 7    ; DMA memory fill
SCREEN_DMA_BURST           EQU 8    ; DMA burst mode

; 8-bit Random Algorithms (Standard Z80)
PERFORMANCE_STANDARD_RANDOM_LCG           EQU 0    ; Linear Congruential Generator
PERFORMANCE_STANDARD_RANDOM_LFSR          EQU 1    ; Linear Feedback Shift Register
PERFORMANCE_STANDARD_RANDOM_XORSHIFT      EQU 2    ; XorShift Algorithm
PERFORMANCE_STANDARD_RANDOM_MIDDLESQUARE  EQU 3    ; Middle Square Method

; 8-bit Random Algorithms (Next Z80N)
PERFORMANCE_Z80N_RANDOM_LCG               EQU 4    ; Z80N optimized LCG
PERFORMANCE_Z80N_RANDOM_LFSR              EQU 5    ; Z80N optimized LFSR
PERFORMANCE_Z80N_RANDOM_XORSHIFT          EQU 6    ; Z80N optimized XorShift
PERFORMANCE_Z80N_RANDOM_MIDDLESQUARE      EQU 7    ; Z80N optimized Middle Square

; 16-bit Random Algorithms (Standard Z80)
PERFORMANCE_STANDARD_RANDOM16_LCG         EQU 0    ; 16-bit Linear Congruential Generator
PERFORMANCE_STANDARD_RANDOM16_LFSR        EQU 1    ; 16-bit Linear Feedback Shift Register
PERFORMANCE_STANDARD_RANDOM16_XORSHIFT    EQU 2    ; 16-bit XorShift Algorithm
PERFORMANCE_STANDARD_RANDOM16_MIDDLESQUARE EQU 3   ; 16-bit Middle Square Method

; 16-bit Random Algorithms (Next Z80N)
PERFORMANCE_Z80N_RANDOM16_LCG             EQU 4    ; Z80N optimized 16-bit LCG
PERFORMANCE_Z80N_RANDOM16_LFSR            EQU 5    ; Z80N optimized 16-bit LFSR
PERFORMANCE_Z80N_RANDOM16_XORSHIFT        EQU 6    ; Z80N optimized 16-bit XorShift
PERFORMANCE_Z80N_RANDOM16_MIDDLESQUARE    EQU 7    ; Z80N optimized 16-bit Middle Square

; DMA Constants (Next Only)
DMA_RESET                 EQU $C3    ; DMA reset command
DMA_FILL                  EQU $79    ; DMA fill transfer mode
DMA_BURST_TRANSFER        EQU $7F    ; DMA burst transfer mode
DMA_BURST_CONTROL         EQU $18    ; DMA burst control
DMA_LOAD                  EQU $CF    ; DMA load/start command
DMA_BURST_LOAD            EQU $DF    ; DMA burst load/start command
ZXN_DMA_PORT              EQU $6B    ; Next DMA port
```

## 🧪 **Testing**

NextLibrary includes comprehensive test suites:

- **62 Test Cases** continually being expanded to cover more functionality
- **Algorithm Validation** for all random number generators (8-bit and 16-bit)
- **Performance Verification** across all performance levels
- **Edge Case Testing** for boundary conditions
- **Statistical Distribution Testing** for random number quality
- **Seed Compatibility Testing** between standard and Z80N versions
- **Screen Management Testing** for all performance levels and addressing modes
- **DMA Validation** for hardware detection and memory operations
- **Hardware Detection Testing** for Z80N and DMA capability verification

### New Test Cases in v1.6

- **Test 058**: Parameterized screen clearing with custom addresses
- **Test 059**: DMA screen clearing validation (Next hardware only)

Run tests using the included test framework:

```asm
INCLUDE "Testing/TestCases.asm"
```

## 🏗️ **Building**

### Requirements
- **sjasmplus** assembler
- **ZX Spectrum Next** development environment (for Next-specific features)

### Build Instructions

```bash
# Assemble the library
sjasmplus --lst=NextLibrary.lst NextLibrary.asm

# Build output will be generated in Output/nextlibrary.nex
```

### 🔧 **Modular Usage**

NextLibrary is designed with a clear, modular structure that allows developers to extract only the routines they need:

- **Selective Inclusion**: Each mathematical operation is self-contained in its own file
- **Minimal Dependencies**: Most routines only depend on constants and variables
- **Clean Code Structure**: Well-commented code makes extraction straightforward
- **No Overhead**: Include only what you need for optimal memory usage

**Example**: If you only need 8×8 multiplication and basic screen clearing, simply extract:
- `Source/Multiply/Multiply8x8.asm` - The multiplication routines
- `Source/Display/ScreenClearing.asm` - Screen clearing routines
- Relevant constants from `Source/Constants.asm`
- Any required variables from `Source/Variables.asm`

This modular approach ensures you can integrate specific functionality into your projects without including the entire library.


## 📁 **Project Structure**

```
NextLibrary/
├── Source/
│   ├── Display/                # Screen, Layer 2, and text utilities
│   ├── Divide/                 # Division routines  
│   ├── DMA/                    # DMA support routines
│   ├── Input/                  # Input handling routines
│   ├── Multiply/               # Multiplication routines
│   ├── Random/                 # Random number generation
│   ├── Scoring/                # Score management
│   ├── Testing/                # Test suites
│   ├── Utility/                # Hardware detection utilities
│   ├── ConstantsDisplay.asm    # Display and graphics constants
│   ├── ConstantsDMA.asm        # DMA operation constants
│   ├── ConstantsMaths.asm      # Mathematical constants
│   ├── ConstantsRandom.asm     # Random generation constants 
│   ├── NextLibrary.asm         # Main library file
│   ├── Variables.asm           # Global ariables
│   ├── VariablesDisplay.asm    # Display-specific variables
│   ├── VariablesDMA.asm        # DMA operation variables
│   └── VariablesRandom.asm     # Random Generator variables
├── Output/
│   └── nextlibrary.nex     # Compiled library
└── README.md              # This file
```

## 📄 **License**

**NextLibrary is available for free use under the following terms:**

### Free Use License

This software is provided **FREE OF CHARGE** for any purpose, including commercial and non-commercial use. You are granted the following rights:

✅ **Use**: Use this library in any project without restriction  
✅ **Modify**: Modify the source code to suit your needs  
✅ **Distribute**: Redistribute original or modified versions  
✅ **Commercial Use**: Use in commercial projects without royalties or fees  
✅ **Private Use**: Use in private/personal projects  

### Disclaimer of Warranty and Liability

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.**

**IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.**

By using this library, you acknowledge that:

- **No Support Obligation**: The author has no obligation to provide support, updates, or bug fixes
- **Use at Your Own Risk**: You assume all risks associated with using this software
- **No Responsibility**: The author takes no responsibility for any consequences of using this library in your projects
- **Your Responsibility**: You are responsible for testing and validating the library's suitability for your specific use case

### Attribution (Optional)

While not required, attribution is appreciated:
```
"Uses NextLibrary - Z80 Assembly Utilities by [Author Name]"
```

### Usage Information (Encouraged)

**Help the community!** If you use NextLibrary in your project, please consider:

📝 **Opening an issue or discussion** in this repository with:
- **Project Name**: What you're building
- **Routines Used**: Which NextLibrary functions you're using (e.g., "8×8 multiplication (Z80N), XORShift random, DMA screen clearing")
- **Platform Target**: 48K, 128K, +2, +3, Next, or multi-platform
- **Brief Description**: What your project does
- **Optional Link**: Share your project if it's public!

This information helps:
- **Other Developers**: See real-world usage examples and inspiration
- **Library Development**: The author gaining an understanding of which routines are most valuable and most used
- **Community Building**: Connect developers using similar functionality
- **Documentation**: Improve examples based on actual use cases

Example usage report:
```
Project: "RetroBlaster 2024"
Routines: Multiply8x8 (NEXT_COMPACT), DMA screen clearing (BURST), Random8 XORShift, Off-screen rendering
Platform: ZX Spectrum Next (Using Z80N optimizations and DMA)
Description: Side-scrolling shooter with procedural enemies, ultra-fast multiplication, and smooth double-buffered graphics
```

This information helps improve the library and provides inspiration to other developers.

**TL;DR**: Use it freely, modify it, distribute it, make money with it - just don't blame me if something goes wrong! And if you feel like sharing what you built, that's awesome! 😊

## 🤝 **Contributing**

Contributions are welcome! Please ensure:

1. **Code Quality**: Follow Z80 assembly best practices
2. **Performance**: Maintain T-state accuracy documentation  
3. **Testing**: Add test cases for new functionality
4. **Documentation**: Update README and inline comments
5. **Hardware Compatibility**: Test on both standard Z80 and Next hardware where applicable

## 🎮 **Use Cases**

NextLibrary is perfect for:

- **Retro Game Development**: High-performance math for physics, scoring, and graphics
- **System Programming**: Efficient utilities for Next-specific applications  
- **Educational Projects**: Well-documented Z80 assembly examples
- **Performance-Critical Code**: T-state accurate timing for real-time applications
- **Graphics Programming**: Fast screen clearing and off-screen rendering
- **Hardware Optimization**: Automatic detection and utilization of Next-specific features

## 🔗 **Related Projects**

- [ZX Spectrum Next Official](https://www.specnext.com/)
- [sjasmplus Assembler](https://github.com/z00m128/sjasmplus)
- [NextBuild Development Tools](https://github.com/Threetwosevensixseven/NextBuild)
- [ZX Spectrum Next Wiki](https://wiki.specnext.dev/)

## 📧 **Contact**

For questions, suggestions, or support, please open an issue on GitHub.

---

**NextLibrary** - *Empowering Z80 assembly development with world-class mathematics, utilities, and hardware-accelerated performance.*
