const std = @import("std");
const isa = @import("isa.zig");

pub fn print(pc: u8, program: []const u8) void {
    const op = program[pc];

    switch (op) {
        isa.MOV => {
            std.debug.print("PC={d}: MOV R{d}, {d}\n", .{ pc, program[pc + 1], program[pc + 2] });
        },

        isa.ADD => {
            std.debug.print("PC={d}: ADD R{d}, R{d}\n", .{ pc, program[pc + 1], program[pc + 2] });
        },

        isa.SUB => {
            std.debug.print("PC={d}: SUB R{d}, R{d}\n", .{ pc, program[pc + 1], program[pc + 2] });
        },

        isa.JMP => {
            std.debug.print("PC={d}: JMP {d}\n", .{ pc, program[pc + 1] });
        },

        isa.JZ => {
            std.debug.print("PC={d}: JZ {d}\n", .{ pc, program[pc + 1] });
        },

        isa.HALT => {
            std.debug.print("PC={d}: HALT\n", .{pc});
        },

        isa.LD => {
            std.debug.print("PC={d}: LD R{d}, {d}\n", .{ pc, program[pc + 1], program[pc + 2] });
        },

        isa.ST => {
            std.debug.print("PC={d}: ST R{d}, {d}\n", .{ pc, program[pc + 1], program[pc + 2] });
        },

        else => {
            std.debug.print("PC={d}: UNKNOWN {x}\n", .{ pc, op });
        },
    }
}
