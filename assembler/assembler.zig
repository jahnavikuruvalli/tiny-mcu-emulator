const std = @import("std");
const isa = @import("../cpu/isa.zig");

pub fn assemble(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    var labels = std.StringHashMap(u8).init(allocator);
    defer labels.deinit();

    var output = std.ArrayList(u8){};
    defer output.deinit(allocator);

    //  PASS 1: find labels
    var pc: u8 = 0;
    var it = std.mem.tokenizeAny(u8, source, "\n");

    while (it.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t");
        if (trimmed.len == 0) continue;

        if (trimmed[trimmed.len - 1] == ':') {
            const name = trimmed[0 .. trimmed.len - 1];
            try labels.put(name, pc);
        } else {
            pc += instructionSize(trimmed);
        }
    }

    //  PASS 2: emit bytecode
    it = std.mem.tokenizeAny(u8, source, "\n");

    while (it.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t");
        if (trimmed.len == 0) continue;
        if (trimmed[trimmed.len - 1] == ':') continue;

        try emitInstruction(&output, trimmed, &labels, allocator);
    }

    return output.toOwnedSlice(allocator);
}

fn instructionSize(line: []const u8) u8 {
    if (std.mem.startsWith(u8, line, "HALT")) return 1;
    if (std.mem.startsWith(u8, line, "JMP")) return 2;
    if (std.mem.startsWith(u8, line, "JZ")) return 2;
    return 3;
}

fn emitInstruction(
    out: *std.ArrayList(u8),
    line: []const u8,
    labels: *std.StringHashMap(u8),
    allocator: std.mem.Allocator,
) !void {
    var parts = std.mem.tokenizeAny(u8, line, " ,");
    const instr = parts.next().?;

    if (std.mem.eql(u8, instr, "HALT")) {
        try out.append(allocator, isa.HALT);
        return;
    }

    if (std.mem.eql(u8, instr, "JMP") or std.mem.eql(u8, instr, "JZ")) {
        const label = parts.next().?;
        const addr = labels.get(label).?;

        try out.append(allocator, if (instr[1] == 'M') isa.JMP else isa.JZ);
        try out.append(allocator, addr);
        return;
    }

    const r1 = parseRegister(parts.next().?);
    const r2_or_imm = parts.next().?;

    if (std.mem.eql(u8, instr, "MOV")) {
        try out.append(allocator, isa.MOV);
        try out.append(allocator, r1);
        try out.append(allocator, try std.fmt.parseInt(u8, r2_or_imm, 10));
    } else if (std.mem.eql(u8, instr, "ADD")) {
        try out.append(allocator, isa.ADD);
        try out.append(allocator, r1);
        try out.append(allocator, parseRegister(r2_or_imm));
    } else if (std.mem.eql(u8, instr, "SUB")) {
        try out.append(allocator, isa.SUB);
        try out.append(allocator, r1);
        try out.append(allocator, parseRegister(r2_or_imm));
    }
}

fn parseRegister(tok: []const u8) u8 {
    return tok[1] - '0';
}
