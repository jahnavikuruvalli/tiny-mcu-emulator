# Tiny MCU Emulator (v0.1)

A minimal, inspectable software model of a custom microcontroller.

This project implements a simple CPU with:
- 8 general-purpose registers
- 256 bytes of RAM
- Custom instruction set
- Fetch–decode–execute loop
- Conditional branching

## Instruction Set
- MOV, ADD, SUB
- LD, ST
- JMP, JZ
- NOP, HALT

## Purpose
This emulator exists to:
- Define and test an instruction set
- Validate execution semantics
- Serve as a bridge to a future custom MCU implementation

No optimization. No cycle accuracy. Only correctness.
