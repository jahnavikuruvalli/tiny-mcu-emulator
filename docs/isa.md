# Tiny MCU v0.1 — Instruction Set Architecture

This document defines the behavior of the Tiny MCU.
All emulator code must follow this specification.

---

## 1. CPU State

### Registers
- R0 to R7
- Each register is 8-bit

### Special Registers
- PC (Program Counter)
- SP (Stack Pointer)

### Flags
- Z (Zero flag)

---

## 2. Memory

- RAM: 256 bytes
- ROM: program memory

---

## 3. Execution Cycle

fetch → decode → execute → update PC

---

## 4. Instructions

MOV  
LD  
ST  
ADD  
SUB  
JMP  
JZ  
NOP  
HALT
