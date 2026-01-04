const std = @import("std");
const cpu_mod = @import("cpu/cpu.zig");
const isa = @import("cpu/isa.zig");

pub fn main() void {
    var cpu = cpu_mod.CPU.init();

    // Byte layout (IMPORTANT):
    //  0: MOV R0, 3
    //  3: MOV R1, 1
    //  6: SUB R0, R1
    //  9: JZ 13
    // 11: JMP 6
    // 13: HALT
    const program = [_]u8{
        isa.MOV, 0x00, 0x03, // 0–2
        isa.MOV, 0x01, 0x01, // 3–5
        isa.SUB, 0x00, 0x01, // 6–8
        isa.JZ, 0x0D, // 9–10 (jump to HALT)
        isa.JMP, 0x06, // 11–12 (jump to SUB)
        isa.HALT, // 13
    };

    while (!cpu.halted) {
        const op = program[cpu.pc];

        switch (op) {
            isa.HALT => cpu.halted = true,

            isa.MOV => {
                const r = program[cpu.pc + 1];
                const v = program[cpu.pc + 2];
                cpu.regs[r] = v;
                cpu.zf = (v == 0);
                cpu.pc += 3;
            },

            isa.SUB => {
                const rd = program[cpu.pc + 1];
                const rs = program[cpu.pc + 2];
                cpu.regs[rd] -%= cpu.regs[rs];
                cpu.zf = (cpu.regs[rd] == 0);
                cpu.pc += 3;
            },

            isa.JZ => {
                const addr = program[cpu.pc + 1];
                if (cpu.zf) cpu.pc = addr else cpu.pc += 2;
            },

            isa.JMP => {
                cpu.pc = program[cpu.pc + 1];
            },

            else => {
                std.debug.print("Invalid opcode at PC={d}\n", .{cpu.pc});
                break;
            },
        }
    }

    std.debug.print("DONE — R0 = {d}\n", .{cpu.regs[0]});
}
