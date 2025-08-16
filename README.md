# NextLibrary - Z80 Assembly Utilities Library for Spectrum and Next

[![Platform: ZX Spectrum Next](https://img.shields.io/badge/Platform-ZX%20Spectrum%20Next-blue.svg)](https://www.specnext.com/)
[![Assembly: Z80](https://img.shields.io/badge/Assembly-Z80-green.svg)](https://en.wikipedia.org/wiki/Zilog_Z80)

**A high-performance, unified utility library for Z80 assembly development on the ZX Spectrum and ZX Spectrum Next platforms.**

NextLibrary provides world-class mathematical operations, random number generation, and utility functions optimized for retro game development and system programming.

There are some Z80N extended opcodes on the Next which could eliminate or speed up some of these routines further. For now, I'm focusing on standard Z80 opcodes to ensure best compatibility for both Spectrum and Next development. "Next only" options using Z80N instructions will be added in the future once the baseline Spectrum routines are complete.

## 📝 **TODO List**

### 🎯 **Platform Compatibility**
- Create tagging system for routines by ZX Spectrum model compatibility (48K, 128K, +2, +3)
- Add "Next Only" variants using Z80N extended opcodes for enhanced performance

### 🖥️ **Display & Graphics**
- Screen copy utilities and in-memory second screen management
- Extended screen manipulation functions

### 🎮 **Input Systems**  
- Joystick input support with multiple controller options
- Enhanced text input utilities and keyboard handling

### 🏆 **Scoring & Data**
- Extended scoring system supporting up to 12-digit scores (beyond 65535)
- Leaderboard and score table management utilities

### 🔊 **Audio Support**
- Sound utilities for 48K and later Spectrum models
- Audio system integration

### ⚡ **Optimization**
- Complete T-state optimization pass (e.g., replace JR with JP where beneficial)
- Z80N instruction integration for Next-specific performance gains
- Memory usage optimization analysis

## 🚀 **Current Features**

### 📊 **Mathematical Operations**
- **8×8 Unsigned Multiplication**: Three performance levels (35-160 T-states)
- **16×8 Unsigned Multiplication**: Optimized for 16-bit arithmetic (45-380 T-states)
- **8÷8 Unsigned Division**: Variable timing division algorithms (25-1975 T-states)
- **16÷8 Unsigned Division**: High-precision 16-bit division (45-1300 T-states)

### 🎲 **Random Number Generation**
- **8-bit Random**: Four different algorithms (LCG, LFSR, XorShift, Middle Square)
- **16-bit Random**: Same four algorithms as 8-bit with extended precision
- **Unified Interface**: Single API for multiple random algorithms
- **Performance Optimized**: T-state accurate timing (40-500 T-states)

### 🖥️ **Display Utilities**
- **Text Rendering**: Embedded font system with screen utilities
- **Unified Screen Clearing**: Six performance levels with up to 74% speed improvement
- **Flexible Operations**: Clear pixels only, attributes only, or full screen reset
- **Stack-Based Optimization**: Advanced PUSH techniques for maximum performance

### ⌨️ **Input Handling**
- **Keyboard Scanning**: Efficient input detection utilities
- **Player Control**: Game-ready input processing functions

### 🏆 **Scoring System**
- **BCD Conversion**: Binary to BCD score conversion utilities
- **Display Integration**: Score rendering and management

## 🎯 **Performance Levels**

NextLibrary uses a unified performance system across all mathematical operations:

| Performance Level | Characteristics | Use Case |
|-------------------|----------------|----------|
| **PERFORMANCE_COMPACT** | Variable timing, minimal code size | Memory-constrained applications |
| **PERFORMANCE_BALANCED** | Fixed timing, predictable performance | Real-time applications, games |
| **PERFORMANCE_MAXIMUM** | Optimized for speed, larger code size | Performance-critical operations |

## 📋 **Quick Start**

### Basic Usage Example

```asm
; Include the NextLibrary
INCLUDE "NextLibrary.asm"

; 8×8 Multiplication Example
LD      A, 25           ; Multiplicand
LD      B, 12           ; Multiplier  
LD      C, PERFORMANCE_BALANCED
CALL    Multiply8x8_Unified
; Result in HL = 300

; Random Number Generation
LD      A, 123          ; Seed value
LD      C, PERFORMANCE_RANDOM_LCG
CALL    RandomSeed8_Unified

LD      C, PERFORMANCE_RANDOM_LCG
CALL    Random8_Unified
; Random value in A
```

### 16-bit Operations

```asm
; 16×8 Multiplication
LD      HL, 1000        ; 16-bit multiplicand
LD      B, 50           ; 8-bit multiplier
LD      C, PERFORMANCE_MAXIMUM
CALL    Multiply16x8_Unified
; Result in HL = 50000

; 16÷8 Division  
LD      HL, 1234        ; 16-bit dividend
LD      B, 10           ; 8-bit divisor
LD      C, PERFORMANCE_BALANCED
CALL    Divide16x8_Unified
; Quotient in HL, remainder in A
```

### Screen Clearing Operations

```asm
; Clear entire screen with white on black attributes
LD      A, %00000111    ; White ink, black paper
LD      C, SCREEN_4PUSH ; High performance mode
CALL    Screen_FullReset_Unified

; Clear pixels only (preserve attributes)
LD      A, 0            ; Not used for pixel clearing
LD      C, SCREEN_2PUSH ; Medium performance
CALL    Screen_ClearPixel_Unified

; Set attributes only (preserve pixels)
LD      A, %01000010    ; Green ink, black paper, bright
LD      C, SCREEN_1PUSH ; Low overhead mode  
CALL    Screen_ClearAttr_Unified
```

## 🔧 **API Reference**

### Mathematical Operations

#### Multiplication
- `Multiply8x8_Unified` - 8×8 bit unsigned multiplication
- `Multiply16x8_Unified` - 16×8 bit unsigned multiplication

**Input**: A/HL = multiplicand, B = multiplier, C = performance level  
**Output**: HL = result

#### Division
- `Divide8x8_Unified` - 8÷8 bit unsigned division  
- `Divide16x8_Unified` - 16÷8 bit unsigned division

**Input**: A/HL = dividend, B = divisor, C = performance level  
**Output**: A/HL = quotient, remainder in A

### Random Number Generation

#### 8-bit Random
- `RandomSeed8_Unified` - Initialize 8-bit random seed
- `Random8_Unified` - Generate 8-bit random number

**Input**: A = seed (for seeding), C = algorithm selection  
**Output**: A = random value

#### 16-bit Random  
- `RandomSeed16_Unified` - Initialize 16-bit random seed
- `Random16_Unified` - Generate 16-bit random number

**Input**: BC = seed (for seeding), D = algorithm selection  
**Output**: BC = random value

### Algorithm Constants

```asm
; Performance Levels
PERFORMANCE_COMPACT        EQU 0
PERFORMANCE_BALANCED       EQU 1  
PERFORMANCE_MAXIMUM        EQU 2

; Random Algorithms
PERFORMANCE_RANDOM_LCG           EQU 0    ; Linear Congruential Generator
PERFORMANCE_RANDOM_LFSR          EQU 1    ; Linear Feedback Shift Register
PERFORMANCE_RANDOM_XORSHIFT      EQU 2    ; XorShift Algorithm
PERFORMANCE_RANDOM_MIDDLESQUARE  EQU 3    ; Middle Square Method

; Screen Performance Levels
SCREEN_COMPACT               EQU 0    ; Standard LDIR operation
SCREEN_1PUSH                 EQU 1    ; 2 pixels simultaneously  
SCREEN_2PUSH                 EQU 2    ; 4 pixels simultaneously
SCREEN_4PUSH                 EQU 3    ; 8 pixels simultaneously
SCREEN_8PUSH                 EQU 4    ; 16 pixels simultaneously
SCREEN_ALLPUSH               EQU 5    ; 256 pixels per loop
```

### Screen Management

#### Unified Screen Clearing
- `Screen_FullReset_Unified` - Clear pixels and set attributes
- `Screen_ClearPixel_Unified` - Clear pixels only, preserve attributes
- `Screen_ClearAttr_Unified` - Set attributes only, preserve pixels

**Input**: A = attribute value, C = performance level  
**Output**: Screen cleared according to specified operation

**Performance Levels**:
- **SCREEN_COMPACT**: Standard LDIR operation (baseline)
- **SCREEN_1PUSH**: Stack-based clearing, 2 pixels per operation (~37% faster)
- **SCREEN_2PUSH**: Enhanced stack method, 4 pixels per operation (~56% faster)  
- **SCREEN_4PUSH**: Advanced optimization, 8 pixels per operation (~65% faster)
- **SCREEN_8PUSH**: High-performance mode, 16 pixels per operation (~70% faster)
- **SCREEN_ALLPUSH**: Maximum speed, 256 pixels per loop (~74% faster)

## ⚡ **Performance Characteristics**

### T-State Timing (3.5MHz)

| Operation | Compact | Balanced | Maximum |
|-----------|---------|----------|---------|
| **Multiply 8×8 Unsigned** | 35-75 | 160 | 120 |
| **Multiply 16×8 Unsigned** | 45-380 | 180 | 140 |
| **Divide 8×8 Unsigned** | 25-1950 | 30-1975 | 40-1000 |
| **Divide 16×8 Unsigned** | 45-1300 | 220-280 | 180-420 |

### Random Generation T-States

| Algorithm | Seed+First Call | Subsequent Calls |
|-----------|----------------|------------------|
| **LCG 8-bit** | 75-90 | 45-60 |
| **LFSR 8-bit** | 95-125 | 65-95 |
| **XorShift 8-bit** | 70-85 | 40-55 |
| **Middle Square 8-bit** | 145-180 | 115-150 |
| **LCG 16-bit** | 140-180 | 110-150 |
| **LFSR 16-bit** | 130-165 | 100-135 |
| **XorShift 16-bit** | 110-135 | 80-105 |
| **Middle Square 16-bit** | 400-500 | 370-470 |

### Screen Clearing T-States

| Performance Level | Pixel Clear | Attribute Set | Full Reset | Speed Improvement |
|-------------------|-------------|---------------|------------|-------------------|
| **SCREEN_COMPACT** | 129,074 | 16,191 | 145,265 | Baseline (100%) |
| **SCREEN_1PUSH** | 81,640 | 10,270 | 91,910 | ~37% faster |
| **SCREEN_2PUSH** | 57,240 | 7,230 | 64,470 | ~56% faster |
| **SCREEN_4PUSH** | 45,240 | 5,710 | 50,950 | ~65% faster |
| **SCREEN_8PUSH** | 39,240 | 4,900 | 44,140 | ~70% faster |
| **SCREEN_ALLPUSH** | 34,140 | 4,270 | 38,410 | ~74% faster |

## 🧪 **Testing**

NextLibrary includes comprehensive test suites:

- **37 Test Cases** covering all mathematical operations
- **Algorithm Validation** for all random number generators
- **Performance Verification** across all performance levels
- **Edge Case Testing** for boundary conditions

Run tests using the included test framework:

```asm
INCLUDE "Testing/TestCases.asm"
```

## 🏗️ **Building**

### Requirements
- **sjasmplus** assembler
- **ZX Spectrum Next** development environment

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

**Example**: If you only need 8×8 multiplication, simply extract:
- `Source/Multiply/Multiply8x8.asm` - The multiplication routines
- Relevant constants from `Source/Constants.asm`
- Any required variables from `Source/Variables.asm`

This modular approach ensures you can integrate specific functionality into your projects without including the entire library.

## 📁 **Project Structure**

```
NextLibrary/
├── Source/
│   ├── NextLibrary.asm      # Main library file
│   ├── Constants.asm        # System constants
│   ├── Variables.asm        # Variable definitions
│   ├── Multiply/           # Multiplication routines
│   ├── Divide/             # Division routines  
│   ├── Random/             # Random number generation
│   ├── Display/            # Screen and text utilities
│   ├── Input/              # Input handling
│   ├── Scoring/            # Score management
│   └── Testing/            # Test suites
├── Output/
│   └── nextlibrary.nex     # Compiled library
└── README.md              # This file
```

## 🤝 **Contributing**

Contributions are welcome! Please ensure:

1. **Code Quality**: Follow Z80 assembly best practices
2. **Performance**: Maintain T-state accuracy documentation  
3. **Testing**: Add test cases for new functionality
4. **Documentation**: Update README and inline comments

## 🎮 **Use Cases**

NextLibrary is perfect for:

- **Retro Game Development**: High-performance math for physics, scoring, and graphics
- **System Programming**: Efficient utilities for Next-specific applications  
- **Educational Projects**: Well-documented Z80 assembly examples
- **Performance-Critical Code**: T-state accurate timing for real-time applications

## 🔗 **Related Projects**

- [ZX Spectrum Next Official](https://www.specnext.com/)
- [sjasmplus Assembler](https://github.com/z00m128/sjasmplus)
- [NextBuild Development Tools](https://github.com/Threetwosevensixseven/NextBuild)

## 📧 **Contact**

For questions, suggestions, or support, please open an issue on GitHub.

---

**NextLibrary** - *Empowering Z80 assembly development with world-class mathematics and utilities.*
