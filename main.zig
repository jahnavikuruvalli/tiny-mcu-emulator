const std = @import("std");
const cpu_mod = @import("cpu/cpu.zig");
const isa = @import("cpu/isa.zig");
const assembler = @import("assembler/assembler.zig");
const trace = @import("cpu/trace.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const source = @embedFile("programs/loop.asm");
    const program = try assembler.assemble(allocator, source);
    defer allocator.free(program);

    var cpu = cpu_mod.CPU.init();

    while (!cpu.halted) {
        const op = program[cpu.pc];
        trace.print(cpu.pc, program);

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

            else => unreachable,
        }
    }

    std.debug.print("DONE — R0 = {d}\n", .{cpu.regs[0]});
}
