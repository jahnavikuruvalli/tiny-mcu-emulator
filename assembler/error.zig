const std = @import("std");

pub const AsmError = error{
    InvalidInstruction,
    InvalidRegister,
    UndefinedLabel,
    InvalidImmediate,
};

pub fn report(line_no: usize, msg: []const u8) void {
    std.debug.print("Assembly error on line {d}: {s}\n", .{ line_no, msg });
}
