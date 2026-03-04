# Tiny MCU v2.0 — Instruction Set Architecture

This document defines the behavior of the **Tiny MCU v2.0 architecture** used by the emulator.

The architecture is intentionally minimal and designed for clarity and educational use.

---

# 1. CPU State

## General Purpose Registers

R0–R7

* 8 registers
* each register is **8-bit**

---

## Special Registers

### PC — Program Counter


PC : u8

* Holds address of next instruction
* Automatically updated during execution

---

### SP — Stack Pointer


SP : u8

* Points to top of stack
* Stack grows **downward**
* Initial value: `0xFF`

---

## Flags

### Zero Flag (Z)


Z = 1 if result == 0
Z = 0 otherwise

Set by:

MOV
ADD
SUB

---

# 2. Memory

## Address Space

0x00 – 0xFF

Total RAM:

256 bytes

---

## Stack

The stack occupies the **top of RAM**.

0xFF  ← initial SP
0x00

Stack operations:

PUSH → store value then decrement SP
POP  → increment SP then read value

---

# 3. Execution Cycle

Each instruction executes using the standard CPU cycle:

fetch → decode → execute → update PC

Steps:

1. fetch instruction at `PC`
2. decode opcode
3. execute instruction
4. update PC

---

# 4. Instruction Encoding

Instructions use **variable length encoding**.

| Format                     | Bytes |
| -------------------------- | ----- |
| opcode                     | 1     |
| opcode + operand           | 2     |
| opcode + operand + operand | 3     |

---

# 5. Instruction Set

## Data Movement

### MOV

MOV reg, imm

Example

MOV R0,5

Operation

R0 = 5
Z = (R0 == 0)

Bytes

[ MOV | reg | imm ]

---

## Arithmetic

### ADD

ADD R1,R2

Operation

R1 = R1 + R2
Z = (R1 == 0)

---

### SUB

SUB R1,R2

Operation

R1 = R1 - R2
Z = (R1 == 0)

---

# 6. Control Flow

### JMP

JMP address

Operation

PC = address

---

### JZ

JZ reg,address

Jump if register is zero.

Operation

if reg == 0
    PC = address
else
    PC += 3

Example

JZ R0,done

---

# 7. Stack Operations

### PUSH

PUSH reg

Operation

RAM[SP] = reg
SP -= 1

---

### POP

POP reg

Operation

SP += 1
reg = RAM[SP]

---

# 8. Subroutine Instructions

### CALL

CALL address

Operation

push(PC + instruction_size)
PC = address

---

### RET

RET

Operation

PC = pop()

---

# 9. System Instructions

### NOP

NOP

No operation.

---

### HALT

HALT

Stops CPU execution.

---

# 10. Example Program

Factorial of 5

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

Expected result:

R1 = 120

---

# 11. Summary

Tiny MCU v2.0 supports:

MOV
ADD
SUB
JMP
JZ reg,label
PUSH
POP
CALL
RET
NOP
HALT

Architecture:

8 registers
256B RAM
stack pointer
program counter
zero flag


