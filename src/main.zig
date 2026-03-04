const std = @import("std");
const CPU = @import("cpu").CPU;
const assembler = @import("assembler");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 1. Read assembly file
    const source = try std.fs.cwd().readFileAlloc(
        allocator,
        "programs/loop.asm",
        10 * 1024,
    );
    defer allocator.free(source);

    // 2. Assemble into bytecode
    const program = try assembler.assemble(allocator, source);
    defer allocator.free(program);

    // 3. Create CPU
    var cpu = CPU.init();

    // 4. Load program into RAM
    for (program, 0..) |byte, i| {
        cpu.ram[i] = byte;
    }

    // 5. Run CPU
    while (!cpu.halted) {
        try cpu.step();
    }

    // 6. Print result
    std.debug.print("DONE — R0={} R1={}\n", .{ cpu.regs[0], cpu.regs[1] });
}
