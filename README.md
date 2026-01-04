# Tiny MCU Emulator

A minimal, inspectable software model of a custom microcontroller, built from first principles.

This project defines a complete MCU design workflow:
- a custom instruction set
- a CPU execution model
- a two-pass assembler
- instruction tracing and diagnostics

The goal is correctness, clarity, and architectural understanding — not performance.

---

## Architecture Overview

### CPU
- 8 general-purpose 8-bit registers (R0–R7)
- Program Counter (PC)
- Zero flag (Z)
- 256 bytes of RAM
- Fetch–decode–execute loop

### Instruction Set
- Data movement: `MOV`, `LD`, `ST`
- Arithmetic: `ADD`, `SUB`
- Control flow: `JMP`, `JZ`
- System: `HALT`

---

## Toolchain

### Assembler
- Two-pass assembler
- Label resolution
- Line-numbered error diagnostics
- Human-readable assembly syntax

### Tracing
- Instruction-level execution trace
- Disassembly-style output
- Register and control flow visibility

---

## Example Assembly

```asm
MOV R0, 3
MOV R1, 1

loop:
SUB R0, R1
JZ end
JMP loop

end:
HALT
````

---

## Why This Exists

Most projects focus on *using* microcontrollers.

This project focuses on *designing* one.

It serves as a foundation for:

* custom MCU design
* FPGA / RTL work
* firmware–hardware co-design
* emulator-driven development

---

## Status

v1.0 — feature-complete minimal MCU platform.
