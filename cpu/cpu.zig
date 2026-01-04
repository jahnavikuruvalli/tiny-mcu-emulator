const isa = @import("isa.zig");

pub const NUM_REGS = 8;

pub const CPU = struct {
    regs: [NUM_REGS]u8,
    ram: [256]u8,
    pc: u8,
    zf: bool,
    halted: bool,

    pub fn init() CPU {
        return CPU{
            .regs = [_]u8{0} ** NUM_REGS,
            .ram = [_]u8{0} ** 256,
            .pc = 0,
            .zf = false,
            .halted = false,
        };
    }
};
