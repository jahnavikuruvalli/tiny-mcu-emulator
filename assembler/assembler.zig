const std = @import("std");
const isa = @import("../cpu/isa.zig");
const asmerr = @import("error.zig");

pub fn assemble(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    var labels = std.StringHashMap(u8).init(allocator);
    defer labels.deinit();

    var output = std.ArrayList(u8){};
    defer output.deinit(allocator);

    //  PASS 1: collect labels
    var pc: u8 = 0;
    var line_no: usize = 0;
    var it = std.mem.tokenizeAny(u8, source, "\n");

    while (it.next()) |line| {
        line_no += 1;

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
    line_no = 0;

    while (it.next()) |line| {
        line_no += 1;

        const trimmed = std.mem.trim(u8, line, " \t");
        if (trimmed.len == 0) continue;
        if (trimmed[trimmed.len - 1] == ':') continue;

        try emitInstruction(&output, trimmed, &labels, allocator, line_no);
    }

    return output.toOwnedSlice(allocator);
}

fn instructionSize(line: []const u8) u8 {
    if (std.mem.startsWith(u8, line, "HALT")) return 1;
    if (std.mem.startsWith(u8, line, "JMP")) return 2;
    if (std.mem.startsWith(u8, line, "JZ")) return 2;
    return 3; // MOV, ADD, SUB, LD, ST
}

fn emitInstruction(
    out: *std.ArrayList(u8),
    line: []const u8,
    labels: *std.StringHashMap(u8),
    allocator: std.mem.Allocator,
    line_no: usize,
) !void {
    var parts = std.mem.tokenizeAny(u8, line, " ,");
    const instr = parts.next().?;

    if (std.mem.eql(u8, instr, "HALT")) {
        try out.append(allocator, isa.HALT);
        return;
    }

    if (std.mem.eql(u8, instr, "JMP") or std.mem.eql(u8, instr, "JZ")) {
        const label = parts.next().?;
        const addr = labels.get(label) orelse {
            asmerr.report(line_no, "undefined label");
            return asmerr.AsmError.UndefinedLabel;
        };

        try out.append(allocator, if (instr[1] == 'M') isa.JMP else isa.JZ);
        try out.append(allocator, addr);
        return;
    }

    const r1 = parseRegister(parts.next().?);
    const r2 = parts.next().?;

    if (std.mem.eql(u8, instr, "MOV")) {
        try out.append(allocator, isa.MOV);
        try out.append(allocator, r1);
        try out.append(allocator, try std.fmt.parseInt(u8, r2, 10));
    } else if (std.mem.eql(u8, instr, "ADD")) {
        try out.append(allocator, isa.ADD);
        try out.append(allocator, r1);
        try out.append(allocator, parseRegister(r2));
    } else if (std.mem.eql(u8, instr, "SUB")) {
        try out.append(allocator, isa.SUB);
        try out.append(allocator, r1);
        try out.append(allocator, parseRegister(r2));
    } else if (std.mem.eql(u8, instr, "LD")) {
        try out.append(allocator, isa.LD);
        try out.append(allocator, r1);
        try out.append(allocator, try std.fmt.parseInt(u8, r2, 10));
    } else if (std.mem.eql(u8, instr, "ST")) {
        try out.append(allocator, isa.ST);
        try out.append(allocator, r1);
        try out.append(allocator, try std.fmt.parseInt(u8, r2, 10));
    } else {
        asmerr.report(line_no, "invalid instruction");
        return asmerr.AsmError.InvalidInstruction;
    }
}

fn parseRegister(tok: []const u8) u8 {
    if (tok.len != 2 or tok[0] != 'R') {
        return 0; // will be caught later if needed
    }
    return tok[1] - '0';
}
