const std = @import("std");
const isa = @import("isa");

pub const NUM_REGS = 8;

pub const CPU = struct {
    regs: [NUM_REGS]u8,
    ram: [256]u8,
    pc: u8,
    sp: u8,
    zf: bool,
    halted: bool,

    pub fn init() CPU {
        return CPU{
            .regs = [_]u8{0} ** NUM_REGS,
            .ram = [_]u8{0} ** 256,
            .pc = 0,
            .sp = 0xFF,
            .zf = false,
            .halted = false,
        };
    }

    pub fn step(self: *CPU) !void {
        const op = self.ram[self.pc];

        switch (op) {

            // MOV register, immediate
            isa.MOV => {
                const reg = self.ram[self.pc + 1];
                const value = self.ram[self.pc + 2];

                self.regs[reg] = value;
                self.zf = (value == 0);

                self.pc += 3;
            },

            isa.PUSH => {
                const reg = self.ram[self.pc + 1];

                // write register value to stack
                self.ram[self.sp] = self.regs[reg];

                // move stack pointer down
                self.sp -%= 1;

                self.pc += 2;
            },

            isa.POP => {
                const reg = self.ram[self.pc + 1];

                // move stack pointer up
                self.sp +%= 1;

                // read value from stack
                self.regs[reg] = self.ram[self.sp];

                self.pc += 2;
            },

            isa.HALT => {
                self.halted = true;
            },

            isa.ADD => {
                const r1 = self.ram[self.pc + 1];
                const r2 = self.ram[self.pc + 2];

                const result: u8 = self.regs[r1] + self.regs[r2];

                self.regs[r1] = result;
                self.zf = (result == 0);

                self.pc += 3;
            },

            isa.SUB => {
                const r1 = self.ram[self.pc + 1];
                const r2 = self.ram[self.pc + 2];

                const result: u8 = self.regs[r1] - self.regs[r2];

                self.regs[r1] = result;
                self.zf = (result == 0);

                self.pc += 3;
            },

            isa.JMP => {
                const addr = self.ram[self.pc + 1];
                self.pc = addr;
            },

            isa.JZ => {
                const reg = self.ram[self.pc + 1];
                const addr = self.ram[self.pc + 2];

                if (self.regs[reg] == 0) {
                    self.pc = addr;
                } else {
                    self.pc += 3;
                }
            },

            isa.CALL => {
                const addr = self.ram[self.pc + 1];

                // push return address
                const ret_addr: u8 = self.pc + 2;
                self.ram[self.sp] = ret_addr;
                self.sp -%= 1;

                // jump to function
                self.pc = addr;
            },

            isa.RET => {
                // pop return address
                self.sp +%= 1;
                const addr = self.ram[self.sp];

                self.pc = addr;
            },

            else => {
                std.debug.print("Unknown opcode: {x}\n", .{op});
                self.halted = true;
            },
        }
    }
};
