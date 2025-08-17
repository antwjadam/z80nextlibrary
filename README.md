# NextLibrary - Z80 Assembly Utilities Library for Spectrum and Next

[![Platform: ZX Spectrum Next](https://img.shields.io/badge/Platform-ZX%20Spectrum%20Next-blue.svg)](https://www.specnext.com/)
[![Assembly: Z80](https://img.shields.io/badge/Assembly-Z80-green.svg)](https://en.wikipedia.org/wiki/Zilog_Z80)

**A high-performance, utility library for Z80 assembly development on the ZX Spectrum and ZX Spectrum Next platforms. The choice is yours, you can use device independent routines or limit yourself to platform specific functionality.**

NextLibrary provides world-class mathematical operations, random number generation, and utility functions optimized for retro game development and system programming. It offers hardware independent routines that work on both Spectrum and Spectrum Next hardware and optimised Next only versions making use of Z80N Next only extended op code.

As I extend this library over time (see the TODO list), I will first share the device independent routines and then will on a subsequent push will add the Z80N optimised routines.

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
- New: Z80N extended opcodes, copper, etc.

## 🚀 **Current Features**

### 📊 **Mathematical Operations**
- **8×8 Unsigned Multiplication**: Six performance levels (10-160 T-states)
  - Standard Z80: COMPACT, BALANCED, MAXIMUM (35-160 T-states)
  - Next Z80N: NEXT_COMPACT, NEXT_BALANCED, NEXT_MAXIMUM (10-29 T-states)
- **16×8 Unsigned Multiplication**: Six performance levels (45-380 T-states)
  - Standard Z80: COMPACT, BALANCED, MAXIMUM (45-380 T-states)
  - Next Z80N: NEXT_COMPACT, NEXT_BALANCED, NEXT_MAXIMUM (97 T-states)
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

## 📝 **TODO List**

### 🖥️ **Display & Graphics**
- Screen copy utilities and in-memory second screen management
- Extended screen manipulation functions, e.g. line draw, fill, patterned fill

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
- DMA (tags likely to be @COMPAT: NEXT, @REQUIRES: Next DMA)
- More features... (one thing added at a time)
- May need tags NEXT1, NEXT2 and NEXT3 to indicate minimum NEXT issue - we will see. I'm hoping not as far as machine code goes

### ⚡ **Optimization**
- Complete T-state optimization pass (e.g., replace JR with JP where beneficial)
- Add "Next Only" variants using Z80N extended opcodes for enhanced performance:
  - Next_FastMemCopy - @COMPAT: NEXT, @Z80N: LDPIRX, LDDX
  - Next_RegisterAccess - @COMPAT: NEXT, @Z80N: NEXTREG
  - Next_FastMultiply - @COMPAT: NEXT, @Z80N: MUL DE
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

; Random Number Generation
LD      A, 123          ; Seed value
LD      C, PERFORMANCE_RANDOM_LCG
CALL    RandomSeed8_Unified

LD      C, PERFORMANCE_RANDOM_LCG
CALL    Random8_Unified
; Random value in A
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
; Performance Levels (Standard Z80)
PERFORMANCE_COMPACT        EQU 0
PERFORMANCE_BALANCED       EQU 1  
PERFORMANCE_MAXIMUM        EQU 2

; Performance Levels (Next Z80N)
PERFORMANCE_NEXT_COMPACT   EQU 3
PERFORMANCE_NEXT_BALANCED  EQU 4
PERFORMANCE_NEXT_MAXIMUM   EQU 5

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
| **Multiply 16×8 Z80N** | 97 | 97 | 97 |
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

- **43 Test Cases** covering all mathematical operations
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
- **Routines Used**: Which NextLibrary functions you're using (e.g., "8×8 multiplication (Z80N), XORShift random, screen clearing")
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
Routines: Multiply8x8 (NEXT_COMPACT), Multiply16x8 (MAXIMUM), Random8 XORShift, Screen clearing (4PUSH)
Platform: ZX Spectrum Next (Using Z80N optimizations)
Description: Side-scrolling shooter with procedural enemies and ultra-fast multiplication
```

**TL;DR**: Use it freely, modify it, distribute it, make money with it - just don't blame me if something goes wrong! And if you feel like sharing what you built, that's awesome! 😊

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
