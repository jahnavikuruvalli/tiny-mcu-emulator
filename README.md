# Tiny MCU Emulator

A minimal, inspectable software model of a custom microcontroller built from first principles.

This project implements a complete **tiny MCU platform**, including:

* a custom instruction set architecture (ISA)
* a software CPU execution model
* a two-pass assembler
* a stack-based calling convention
* support for structured control flow and subroutines

The goal is **clarity, correctness, and architectural understanding**, not performance.

---

# Architecture Overview

## CPU

The Tiny MCU models a simple 8-bit processor.

**Registers**

```
R0–R7  (8 general-purpose 8-bit registers)
```

**Special Registers**

```
PC   Program Counter
SP   Stack Pointer
```

**Flags**

```
Z    Zero flag
```

**Memory**

```
256 bytes RAM
```

**Execution model**

```
fetch → decode → execute → update PC
```

---

# Instruction Set

Tiny MCU v2.0 supports a small but expressive ISA.

### Data Movement

```
MOV reg,imm
```

Load an immediate value into a register.

---

### Arithmetic

```
ADD reg,reg
SUB reg,reg
```

Arithmetic operations update the **zero flag**.

---

### Control Flow

```
JMP addr
JZ reg,addr
```

`JZ` performs a conditional jump based on a register value.

---

### Stack Operations

```
PUSH reg
POP reg
```

The stack grows downward from the top of memory.

---

### Subroutines

```
CALL addr
RET
```

Subroutine calls use the stack to store return addresses.

---

### System

```
NOP
HALT
```

---

# Toolchain

## Assembler

The project includes a **two-pass assembler** that converts human-readable assembly into machine code.

Features:

* label resolution
* symbolic jumps and calls
* line-numbered diagnostics
* simple assembly syntax

---

# Example Program

Factorial of 5.

```asm
MOV R0,5
MOV R1,1
MOV R2,1

loop:
JZ R0,done

PUSH R0
CALL multiply
POP R0

SUB R0,R2
JMP loop

done:
HALT
```

Expected result:

```
R1 = 120
```

---

# Design Goals

Tiny MCU is designed to be:

* **small enough to understand completely**
* **simple enough to modify**
* **powerful enough to run real programs**

It demonstrates core concepts of:

* CPU architecture
* instruction decoding
* stack-based subroutines
* assembler design
* emulator-driven development

---

# Why This Exists

Most projects focus on **using microcontrollers**.

This project focuses on **designing one**.

It serves as a foundation for exploring:

* custom instruction set design
* embedded firmware architecture
* emulator-based development
* FPGA soft-core CPUs
* RTL implementations

---

# Status

```
v2.0 — minimal programmable MCU platform
```

Features:

* complete instruction set
* stack and subroutine support
* two-pass assembler
* factorial validation program

